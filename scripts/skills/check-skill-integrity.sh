#!/usr/bin/env bash
#
# check-skill-integrity.sh - fail loud when the skill tree has rotted in a way
# that validate-skills.sh cannot see.
#
# validate-skills.sh reads ~/dotfiles/.claude/skills (repo content). It never
# looks at ~/.claude/skills, which is what Claude Code ACTUALLY loads. That gap
# is where the rot lives, so this script checks the live tree instead.
#
# The three failure modes this catches, all observed on this machine:
#
#   1. ORPHANS - a skill loads from ~/.claude/skills but is neither authored
#      here nor in the lock. Nothing can reinstall it; if the disk dies it is
#      gone. Fix by vendoring it into .claude/skills/ (a real dir, committed).
#   2. DANGLING - a symlink in ~/.claude/skills whose target is gone. Dead
#      weight; the skill silently does not load.
#   3. PHANTOMS - the lock promises a skill that is absent from disk. A fresh
#      `packages.sh install` would try to restore it and report MISSING.
#
# Read-only: reports, never mutates. Run standalone or from doctor.sh.
#
# Usage: check-skill-integrity.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_SKILLS="$(cd "$SCRIPT_DIR/../../.claude/skills" && pwd)"
LOCK="$SCRIPT_DIR/skill-lock.json"
LIVE_SKILLS="$HOME/.claude/skills"
AGENTS_SKILLS="$HOME/.agents/skills"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found; cannot check skill integrity." >&2
  exit 1
fi

python3 - "$DOTFILES_SKILLS" "$LOCK" "$LIVE_SKILLS" "$AGENTS_SKILLS" <<'PY'
import json, os, sys

dotfiles_skills, lock_path, live_skills, agents_skills = sys.argv[1:5]

def die(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)

if not os.path.isdir(live_skills):
    die(f"{live_skills} missing (run: bash scripts/skills/link-dotfiles-skills.sh)")
try:
    lock = set(json.load(open(lock_path))["skills"])
except (OSError, ValueError, KeyError) as e:
    die(f"cannot read {lock_path}: {e}")

# Authored = a real directory in the repo. Those are tracked in git, so they
# need no lock entry; the lock only carries their provenance.
authored = {
    s for s in os.listdir(dotfiles_skills)
    if os.path.isdir(f"{dotfiles_skills}/{s}") and not os.path.islink(f"{dotfiles_skills}/{s}")
}

orphans, dangling = [], []
for s in sorted(os.listdir(live_skills)):
    p = f"{live_skills}/{s}"
    if os.path.islink(p) and not os.path.exists(os.path.realpath(p)):
        dangling.append((s, os.readlink(p)))
        continue
    if not os.path.isdir(p):
        continue
    # Anything resolving into the repo is authored and safe by definition.
    if os.path.realpath(p).startswith(os.path.realpath(dotfiles_skills) + os.sep):
        continue
    if s in authored or s in lock:
        continue
    orphans.append(s)

phantoms = sorted(
    s for s in lock
    if s not in authored
    and not os.path.isdir(f"{agents_skills}/{s}")
    and not os.path.isdir(f"{live_skills}/{s}")
)

problems = 0
if orphans:
    problems += 1
    print(f"- {len(orphans)} skill(s) load but are in neither git nor the lock "
          f"(unreproducible; vendor into .claude/skills/):", file=sys.stderr)
    for s in orphans:
        print(f"    {s}", file=sys.stderr)
if dangling:
    problems += 1
    print(f"- {len(dangling)} dangling symlink(s) in {live_skills} "
          f"(skill silently does not load):", file=sys.stderr)
    for s, t in dangling:
        print(f"    {s} -> {t}", file=sys.stderr)
if phantoms:
    problems += 1
    print(f"- {len(phantoms)} lock entr(ies) absent from disk "
          f"(run: bash scripts/skills/packages.sh export):", file=sys.stderr)
    for s in phantoms:
        print(f"    {s}", file=sys.stderr)

if problems:
    print(f"Skill integrity failed ({problems} problem class(es)).", file=sys.stderr)
    sys.exit(1)

live = sum(
    1 for s in os.listdir(live_skills)
    if os.path.exists(os.path.realpath(f"{live_skills}/{s}"))
)
print(f"Skill integrity OK ({live} live, {len(authored)} authored, {len(lock)} locked).")
PY
