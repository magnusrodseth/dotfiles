#!/usr/bin/env python3
"""Export T3 Code projects to a portable manifest, or compare a manifest with this machine.

Never writes to T3's database. Restoring is left to an agent (see SKILL.md).

  t3-projects.py export [-o FILE]   print the manifest (or write it to FILE)
  t3-projects.py status [FILE]      show each manifest project's state on this machine

Default FILE: ~/dotfiles/.t3/projects.json
"""
import argparse
import json
import os
import sqlite3
import subprocess
import sys
from pathlib import Path

HOME = Path.home()
T3_HOME = Path(os.environ.get("T3CODE_HOME", HOME / ".t3"))
DB = T3_HOME / "userdata" / "statev2.sqlite"
MANIFEST = HOME / "dotfiles" / ".t3" / "projects.json"
SKIP_ROOTS = {T3_HOME / "scratch"}  # T3's built-in "No project"


def tilde(p: Path) -> str:
    try:
        return "~/" + str(p.relative_to(HOME))
    except ValueError:
        return str(p)


def expand(p: str) -> Path:
    return Path(os.path.expanduser(p))


def git(path: Path, *args: str) -> str | None:
    r = subprocess.run(["git", "-C", str(path), *args], capture_output=True, text=True)
    return r.stdout.strip() or None if r.returncode == 0 else None


def load_db() -> list[dict]:
    if not DB.exists():
        sys.exit(f"error: T3 database not found at {DB}")
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    return [dict(r) for r in con.execute(
        "select * from projection_projects where deleted_at is null order by created_at")]


def parse(raw):
    return json.loads(raw) if raw else None


def export(args):
    projects = []
    for r in load_db():
        root = Path(r["workspace_root"])
        if root in SKIP_ROOTS:
            continue
        p = {
            "title": r["title"],
            "path": tilde(root),
            "remote": git(root, "remote", "get-url", "origin") if root.exists() else None,
            "exists_on_source": root.exists(),
            "scripts": parse(r["scripts_json"]) or [],
            "projectIcon": parse(r.get("project_icon_json")),
            "faviconPath": r.get("favicon_path"),
            "pinned": r.get("pinned_at") is not None,
            "archived": r.get("archived_at") is not None,
            "autoPull": bool(r.get("auto_pull")),
            "defaultThreadEnvMode": r.get("default_thread_env_mode"),
            "defaultModelSelection": parse(r.get("default_model_selection_json")),
        }
        projects.append({k: v for k, v in p.items() if v not in (None, [], False) or k in ("remote", "exists_on_source")})
    out = json.dumps({"version": 1, "projects": projects}, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        Path(args.output).expanduser().parent.mkdir(parents=True, exist_ok=True)
        Path(args.output).expanduser().write_text(out)
        print(f"wrote {len(projects)} projects to {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(out)


def status(args):
    manifest = json.loads(Path(args.file).expanduser().read_text())
    registered = {Path(r["workspace_root"]): r["title"] for r in load_db()}
    rows = []
    for p in manifest["projects"]:
        path = expand(p["path"])
        if path in registered:
            state = "registered"
        elif (path / ".git").exists() or (path.exists() and any(path.iterdir())):
            state = "cloned"   # on disk, not in T3
        else:
            state = "missing"  # needs a clone (or has no remote)
        rows.append((state, p["title"], p["path"], p.get("remote") or "-"))
    order = {"missing": 0, "cloned": 1, "registered": 2}
    for state, title, path, remote in sorted(rows, key=lambda r: order[r[0]]):
        print(f"{state:<11} {title:<38} {path:<55} {remote}")
    counts = {s: sum(r[0] == s for r in rows) for s in order}
    print(f"\n{counts['missing']} missing, {counts['cloned']} cloned but unregistered, "
          f"{counts['registered']} registered", file=sys.stderr)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    e = sub.add_parser("export")
    e.add_argument("-o", "--output", help=f"write here instead of stdout (e.g. {tilde(MANIFEST)})")
    e.set_defaults(fn=export)
    s = sub.add_parser("status")
    s.add_argument("file", nargs="?", default=str(MANIFEST))
    s.set_defaults(fn=status)
    args = ap.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
