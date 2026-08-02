#!/usr/bin/env bash
#
# check-staged-skills.sh - block a commit that re-introduces skill shadowing.
#
# Authored skills live in .claude/skills/<name>/ in this repo and are linked
# out to ~/.agents/skills by link-dotfiles-skills.sh. Installed skills come
# from skill-lock.json and land in ~/.agents/skills as real directories.
#
# When the SAME name exists in both, the installed copy wins in every agent
# (Claude Code, Codex, Zed all resolve through ~/.agents), and the committed
# copy becomes dead code that still reads like the source of truth. That is
# how 42 skills silently diverged by 02.08.2026, 4 of them with real content
# differences that made Claude Code and Zed disagree.
#
# So: committing a skill directory whose name is already in skill-lock.json is
# an error. Either the skill is yours (remove the lock entry and let
# packages.sh export reflect that) or it is upstream's (do not vendor it).
#
# Reads the INDEX, not the working tree, so it judges what is being committed.

set -uo pipefail

cd "$(git rev-parse --show-toplevel)" || exit 1

LOCK="scripts/skills/skill-lock.json"
[ -f "$LOCK" ] || exit 0

staged="$(git diff --cached --name-only --diff-filter=A -- '.claude/skills/*/SKILL.md' || true)"
[ -n "$staged" ] || exit 0

command -v python3 >/dev/null 2>&1 || exit 0

# shellcheck disable=SC2086  # word splitting on newline-separated paths is intended
python3 - "$LOCK" $staged <<'PY'
import json, sys

lock_path = sys.argv[1]
try:
    lock = set(json.load(open(lock_path))["skills"])
except (OSError, ValueError, KeyError):
    sys.exit(0)

names = {p.split("/")[2] for p in sys.argv[2:] if p.count("/") >= 3}
clash = sorted(n for n in names if n in lock)
if not clash:
    sys.exit(0)

print(f"pre-commit: {len(clash)} staged skill(s) collide with skill-lock.json.",
      file=sys.stderr)
print("  The installed copy in ~/.agents wins, so the committed copy would "
      "load nowhere:", file=sys.stderr)
for n in clash:
    print(f"    .claude/skills/{n}/", file=sys.stderr)
print("  Fix: keep one. To adopt it as your own, remove it from the lock "
      "(npx skills remove -g " + clash[0] + ") and re-run "
      "scripts/skills/packages.sh export.", file=sys.stderr)
sys.exit(1)
PY
