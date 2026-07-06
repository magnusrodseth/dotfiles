#!/usr/bin/env python3
"""Domain availability checker — DNS + RDAP (+ whois fallback), zero dependencies.

Inspired by imprvhub/mcp-domain-availability, rebuilt as a dependency-free CLI
using only the Python standard library and system tools already on macOS/Linux
(`dig`, and `whois` as a fallback). No pip installs, no MCP server.

Why not plain whois? WHOIS is being retired under ICANN's RDAP transition
(registries now answer "the WHOIS service has been retired... use RDAP"), and
macOS `whois` does not reliably follow registry referrals for new gTLDs — it
returns the IANA delegation record instead, which misreads as taken/available.
So this tool leads with signals that actually work:

  1. DNS NS-delegation (`dig NS`): registered domains are delegated (have NS
     records in the parent zone). NS present => taken. This is the ground truth
     for "taken" and needs no rate-limited service.
  2. RDAP (https://rdap.org/domain/<d>): WHOIS's JSON replacement. HTTP 200 =>
     registered, 404 => available. Authoritative where the registry supports it.
  3. WHOIS: consulted only when RDAP is inconclusive (429/timeout/no-RDAP TLD),
     with a guard against IANA non-answers.

Combined status:
  taken      -> NS delegated OR RDAP 200 OR (RDAP inconclusive AND whois taken)
  available  -> not delegated AND (RDAP 404 OR whois "no match")
  unknown    -> everything inconclusive (no dig, no RDAP, whois can't tell)

This is a strong heuristic for naming research, not registrar-grade truth.
Always confirm at a registrar before buying.

Usage:
  check_domains.py <name-or-domain> [options]

  check_domains.py acme                 # 'acme' across the popular TLD set
  check_domains.py acme.com             # that exact domain + popular set
  check_domains.py acme --all           # across ~90 TLDs (popular+country+new)
  check_domains.py acme --tlds com,io,ai,dev
  check_domains.py acme --json          # machine-readable output
"""
from __future__ import annotations

import argparse
import concurrent.futures
import json
import re
import shutil
import subprocess
import sys
import urllib.error
import urllib.request

# --- TLD catalog (ported from the MCP) -------------------------------------

POPULAR_TLDS = ["com", "net", "org", "io", "ai", "app", "dev", "co", "xyz", "me", "info", "biz"]

COUNTRY_TLDS = [
    "us", "uk", "ca", "au", "de", "fr", "it", "es", "nl", "jp", "kr", "cn", "in",
    "br", "mx", "ar", "cl", "pe", "ru", "pl", "cz", "ch", "at", "se", "no",
    "dk", "fi", "be", "pt", "gr", "tr", "za", "eg", "ma", "ng", "ke",
]

NEW_TLDS = [
    "tech", "online", "site", "website", "store", "shop", "cloud", "digital",
    "blog", "news", "agency", "studio", "design", "media", "photo", "video",
    "music", "art", "gallery", "education", "university", "academy", "training",
    "business", "company", "solutions", "services", "consulting", "finance",
    "legal", "health", "medical", "travel", "hotel", "restaurant", "food",
    "coffee", "bar", "club", "sport", "fitness", "games", "fun", "live",
    "world", "global", "international", "network", "email", "mobile",
]

ALL_TLDS = list(dict.fromkeys(POPULAR_TLDS + COUNTRY_TLDS + NEW_TLDS))

TLD_MIN_LENGTH = {
    "com": 2, "net": 2, "org": 2, "info": 2, "biz": 3,
    "io": 2, "ai": 2, "co": 3, "me": 3,
    "de": 2, "fr": 2, "it": 2, "es": 2, "nl": 3,
    "ch": 3, "at": 3, "be": 3, "dk": 3, "se": 3,
    "no": 3, "fi": 3, "pl": 3, "cz": 3, "pt": 3,
    "gr": 3, "tr": 3, "ru": 3, "uk": 3, "au": 3,
    "ca": 3, "us": 3, "jp": 3, "kr": 3, "cn": 3,
    "in": 3, "br": 3, "mx": 3, "ar": 3, "cl": 3,
    "pe": 3, "za": 3, "eg": 3, "ma": 3, "ng": 3, "ke": 3,
    "app": 3, "dev": 3, "xyz": 3, "tech": 3,
    "online": 3, "site": 3, "website": 3, "store": 3,
    "shop": 3, "cloud": 3, "digital": 3, "blog": 3, "news": 3,
}

# WHOIS "no registration" phrasings (checked before the taken markers).
AVAILABLE_MARKERS = [
    "no match", "not found", "no data found", "no entries found",
    "domain not found", "no object found", "not registered",
    "available for registration", "free for registration",
    "status: free", "status: available", "no matching record",
    "nothing found", "object does not exist",
]
# WHOIS registration markers => taken.
TAKEN_MARKERS = [
    "registrar:", "creation date", "created:", "registry domain id",
    "registrant", "name server", "nserver:", "domain status:",
    "status: connect", "status: active", "updated date",
]


def get_min_length_for_tld(tld: str) -> int:
    return TLD_MIN_LENGTH.get(tld, 3)


def is_valid_domain_name(base_name: str, tld: str) -> bool:
    if len(base_name) < get_min_length_for_tld(tld):
        return False
    if not re.match(r"^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", base_name):
        return False
    if base_name.startswith("-") or base_name.endswith("-"):
        return False
    if "--" in base_name:
        return False
    if len(base_name) > 63:
        return False
    return True


def clean_domain_name(domain: str) -> str:
    domain = domain.lower().strip()
    if "//" in domain:
        domain = domain.split("//")[-1]
    if "/" in domain:
        domain = domain.split("/")[0]
    return domain


def extract_domain_parts(domain: str):
    """Return (base_name, tld). Single-label TLDs only (matches the MCP)."""
    domain = clean_domain_name(domain)
    if "." in domain:
        parts = domain.split(".")
        return ".".join(parts[:-1]), parts[-1]
    return domain, ""


def ns_delegated(domain: str, timeout: float):
    """True/False if delegated (NS records in parent zone); None if undetermined."""
    if shutil.which("dig") is None:
        return None
    try:
        proc = subprocess.run(
            ["dig", "+short", "+time=3", "+tries=1", "NS", domain],
            capture_output=True, text=True, timeout=timeout,
        )
    except Exception:
        return None
    lines = [ln for ln in (proc.stdout or "").splitlines()
             if ln.strip() and not ln.strip().startswith(";")]
    return len(lines) > 0


def rdap_status(domain: str, timeout: float) -> str:
    """Return 'registered' (HTTP 200), 'available' (404), or 'unknown'."""
    req = urllib.request.Request(
        f"https://rdap.org/domain/{domain}",
        headers={"User-Agent": "domain-availability-skill/1.0",
                 "Accept": "application/rdap+json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return "registered" if resp.getcode() == 200 else "unknown"
    except urllib.error.HTTPError as exc:
        return "available" if exc.code == 404 else "unknown"
    except Exception:
        return "unknown"


def whois_signal(domain: str, timeout: float) -> str:
    """Fallback WHOIS read: available | taken | unknown | no-whois | timeout."""
    if shutil.which("whois") is None:
        return "no-whois"
    try:
        proc = subprocess.run(
            ["whois", domain], capture_output=True, text=True, timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        return "timeout"
    except Exception:
        return "unknown"

    text = ((proc.stdout or "") + "\n" + (proc.stderr or "")).lower()
    if not text.strip():
        return "unknown"
    # macOS whois didn't follow the referral (returned the IANA delegation
    # record) — it describes the TLD, not the domain, so it can't judge.
    if "iana whois server" in text or "no whois server" in text:
        return "no-whois"
    if any(marker in text for marker in AVAILABLE_MARKERS):
        return "available"
    if any(marker in text for marker in TAKEN_MARKERS):
        return "taken"
    return "unknown"


def check_domain(base_name: str, tld: str, timeout: float) -> dict:
    domain = f"{base_name}.{tld}"
    if not is_valid_domain_name(base_name, tld):
        return {
            "domain": domain, "status": "invalid",
            "reason": f'"{base_name}" fails .{tld} rules (min length {get_min_length_for_tld(tld)})',
        }

    delegated = ns_delegated(domain, timeout)
    rdap = rdap_status(domain, timeout)
    whois = None

    if rdap == "registered" or delegated is True:
        status = "taken"
    elif rdap == "available":
        status = "available"
    else:
        # RDAP inconclusive (429/timeout/no-RDAP TLD): consult whois.
        whois = whois_signal(domain, timeout)
        if whois == "taken":
            status = "taken"
        elif whois == "available":
            status = "available"
        elif delegated is False:
            status = "available"  # not delegated, nothing says taken
        else:
            status = "unknown"

    signals = {"ns": delegated, "rdap": rdap}
    if whois is not None:
        signals["whois"] = whois
    return {"domain": domain, "status": status, "signals": signals}


def resolve_tlds(args, given_tld: str):
    if args.tlds:
        tlds = [t.strip().lstrip(".") for t in args.tlds.split(",") if t.strip()]
    elif args.all:
        tlds = list(ALL_TLDS)
    else:
        tlds = list(POPULAR_TLDS)
    if given_tld:
        tlds = [given_tld] + tlds
    return list(dict.fromkeys(tlds))


def _signal_str(signals: dict) -> str:
    ns = signals.get("ns")
    ns_s = "yes" if ns is True else "no" if ns is False else "n/a"
    parts = [f"ns:{ns_s}", f"rdap:{signals.get('rdap')}"]
    if "whois" in signals:
        parts.append(f"whois:{signals['whois']}")
    return ", ".join(parts)


def main() -> int:
    ap = argparse.ArgumentParser(
        prog="check_domains.py",
        description="Check domain availability across TLDs via DNS + RDAP (+ whois fallback).",
    )
    ap.add_argument("query", help="A bare name ('acme') or a domain ('acme.com').")
    ap.add_argument("--all", action="store_true", help="Check ~90 TLDs (popular+country+new).")
    ap.add_argument("--tlds", help="Comma-separated TLDs to check, e.g. com,io,ai,dev.")
    ap.add_argument("--timeout", type=float, default=8.0, help="Per-request timeout seconds (default 8).")
    ap.add_argument("--concurrency", type=int, default=10, help="Parallel checks (default 10).")
    ap.add_argument("--json", action="store_true", help="Emit JSON instead of text.")
    args = ap.parse_args()

    base_name, given_tld = extract_domain_parts(args.query)
    if not base_name:
        print("error: could not parse a domain name from the query", file=sys.stderr)
        return 2

    tlds = resolve_tlds(args, given_tld)

    results: list[dict] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, args.concurrency)) as pool:
        futures = [pool.submit(check_domain, base_name, tld, args.timeout) for tld in tlds]
        for fut in concurrent.futures.as_completed(futures):
            results.append(fut.result())
    results.sort(key=lambda r: r["domain"])

    buckets = {"available": [], "taken": [], "unknown": [], "invalid": []}
    for r in results:
        buckets[r["status"]].append(r)
    summary = {k: len(v) for k, v in buckets.items()}

    if args.json:
        print(json.dumps(
            {"query": args.query, "base_name": base_name, "requested_tld": given_tld or None,
             "results": results, "summary": summary},
            indent=2,
        ))
        return 0

    print(f'Domain check for "{base_name}" across {len(results)} TLD(s)\n')
    if buckets["available"]:
        print(f"AVAILABLE ({summary['available']}):")
        for r in buckets["available"]:
            print(f"  {r['domain']:<32} [{_signal_str(r['signals'])}]")
        print()
    if buckets["taken"]:
        print(f"TAKEN ({summary['taken']}):")
        for r in buckets["taken"]:
            print(f"  {r['domain']}")
        print()
    if buckets["unknown"]:
        print(f"UNKNOWN ({summary['unknown']}) — inconclusive, verify manually:")
        for r in buckets["unknown"]:
            print(f"  {r['domain']:<32} [{_signal_str(r['signals'])}]")
        print()
    if buckets["invalid"]:
        print(f"INVALID ({summary['invalid']}):")
        for r in buckets["invalid"]:
            print(f"  {r['domain']:<32} {r.get('reason', '')}")
        print()

    print(
        f"Summary: {summary['available']} available · {summary['taken']} taken · "
        f"{summary['unknown']} unknown · {summary['invalid']} invalid"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
