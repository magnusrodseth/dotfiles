#!/usr/bin/env python3
"""Export T3 Code scheduled tasks to a portable manifest, or compare a manifest with this machine.

Never writes to T3's database. Restoring is left to an agent (see SKILL.md).

  t3-scheduled-tasks.py export [-o FILE]   print the manifest (or write it to FILE)
  t3-scheduled-tasks.py status [FILE]      show each manifest task's state on this machine

Default FILE: ~/dotfiles/.t3/scheduled-tasks.json (git-ignored).
Webhook token and secret, thread ids and run history are never exported.
"""
import argparse
import json
import os
import sqlite3
import sys
from datetime import datetime
from pathlib import Path

HOME = Path.home()
T3_HOME = Path(os.environ.get("T3CODE_HOME", HOME / ".t3"))
DB = T3_HOME / "userdata" / "statev2.sqlite"
MANIFEST = HOME / "dotfiles" / ".t3" / "scheduled-tasks.json"

# Columns copied into the manifest. Everything else stays behind: webhook_token,
# webhook_secret and thread_id are machine-bound or secret, the rest is run history.
FIELDS = ("title", "enabled", "schedule_json", "workspace_strategy_json", "model_selection_json",
          "runtime_mode", "interaction_mode", "thread_mode", "prompt")


def tilde(p: str) -> str:
    try:
        return "~/" + str(Path(p).relative_to(HOME))
    except ValueError:
        return p


def connect() -> sqlite3.Connection:
    if not DB.exists():
        sys.exit(f"error: T3 database not found at {DB}")
    con = sqlite3.connect(DB.resolve().as_uri() + "?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    return con


def load_tasks(con) -> list[dict]:
    roots = {r["project_id"]: r["workspace_root"]
             for r in con.execute("select project_id, workspace_root from projection_projects")}
    tasks = []
    for r in con.execute(f"select project_id, {', '.join(FIELDS)} from scheduled_tasks order by created_at"):
        t = {}
        for k in FIELDS:
            v = r[k]
            if k.endswith("_json"):
                t[k[:-5]] = json.loads(v) if v else None
            else:
                t[k] = bool(v) if k == "enabled" else v
        root = roots.get(r["project_id"])
        t["project_path"] = tilde(root) if root else None
        tasks.append(t)
    return tasks


def export(args):
    tasks = load_tasks(connect())
    out = json.dumps({"version": 1, "exported_at": datetime.now().astimezone().isoformat(timespec="seconds"),
                      "tasks": tasks}, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        dest = Path(args.output).expanduser()
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.touch(mode=0o600)
        dest.chmod(0o600)  # prompts can name private repos and people
        dest.write_text(out)
        print(f"wrote {len(tasks)} scheduled tasks to {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(out)


def status(args):
    manifest = json.loads(Path(args.file).expanduser().read_text())
    local = load_tasks(connect())
    for side, tasks in (("manifest", manifest["tasks"]), ("this machine", local)):
        titles = [t["title"] for t in tasks]
        for dup in sorted({t for t in titles if titles.count(t) > 1}):
            print(f"warning: {side} has more than one task titled {dup!r}; status matches by title", file=sys.stderr)
    here = {t["title"]: t for t in local}
    keys = ("prompt", "schedule", "project_path", "workspace_strategy", "model_selection",
            "runtime_mode", "interaction_mode", "thread_mode", "enabled")
    rows = []
    for t in manifest["tasks"]:
        cur = here.get(t["title"])
        if cur is None:
            state, diff = "missing", ""
        else:
            changed = [k for k in keys if cur.get(k) != t.get(k)]
            state, diff = ("differs", ", ".join(changed)) if changed else ("present", "")
        rows.append((state, t["title"], t.get("project_path") or "-", diff))
    order = {"missing": 0, "differs": 1, "present": 2}
    for state, title, path, diff in sorted(rows, key=lambda r: order[r[0]]):
        print(f"{state:<8} {title:<40} {path:<30} {diff}")
    counts = {s: sum(r[0] == s for r in rows) for s in order}
    print(f"\n{counts['missing']} missing, {counts['differs']} differ, {counts['present']} present", file=sys.stderr)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    e = sub.add_parser("export")
    e.add_argument("-o", "--output", help=f"write here instead of stdout (e.g. {tilde(str(MANIFEST))})")
    e.set_defaults(fn=export)
    s = sub.add_parser("status")
    s.add_argument("file", nargs="?", default=str(MANIFEST))
    s.set_defaults(fn=status)
    args = ap.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
