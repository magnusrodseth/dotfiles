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
#   4. STALE - a skill's docs describe an older release than the binary that is
#      actually installed. The skill loads fine and reads as authoritative, so
#      this is the quietest failure of the four: you follow documentation for
#      flags that no longer match the tool. Observed 28.07.2026, when gws-gmail
#      still documented only --to/--subject/--body and sent us down a hand-rolled
#      MIME path, while the installed gws 0.22.5 had --attach and --draft all
#      along. Drift is routine (upstream ships, docs lag), so it WARNS on stdout
#      and never fails the exit code - doctor.sh must not go red for this.
#
# Read-only: reports, never mutates. Run standalone or from doctor.sh.
#
# Usage: check-skill-integrity.sh [--drift]
#          (no args) full integrity check, drift appended as a warning
#          --drift   only the version-drift check; silent when clean

set -uo pipefail

MODE="full"
if [ "${1:-}" = "--drift" ]; then
  MODE="drift"
elif [ -n "${1:-}" ]; then
  echo "usage: check-skill-integrity.sh [--drift]" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_SKILLS="$(cd "$SCRIPT_DIR/../../.claude/skills" && pwd)"
LOCK="$SCRIPT_DIR/skill-lock.json"
LIVE_SKILLS="$HOME/.claude/skills"
AGENTS_SKILLS="$HOME/.agents/skills"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found; cannot check skill integrity." >&2
  exit 1
fi

python3 - "$DOTFILES_SKILLS" "$LOCK" "$LIVE_SKILLS" "$AGENTS_SKILLS" "$MODE" <<'PY'
import json, os, sys, re, glob, subprocess

dotfiles_skills, lock_path, live_skills, agents_skills, mode = sys.argv[1:6]


def find_drift(root):
    """Compare each skill's documented version against the binary it declares.

    Skills generated from a CLI carry both `version:` and the backing binary in
    `requires.bins`, which makes the comparison mechanical. Skills without both
    are simply invisible here - there is nothing to compare them to.
    """
    claims = {}  # binary -> {version -> [skill, ...]}
    for p in glob.glob(os.path.join(root, "*", "SKILL.md")):
        try:
            s = open(p, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        if not s.startswith("---"):
            continue
        parts = s.split("---", 2)
        if len(parts) < 3:
            continue
        fm = parts[1]
        ver = re.search(r"^\s*version:\s*[\"']?([\w.\-]+)", fm, re.M)
        # bins is either a YAML list or an inline JSON array
        b = re.search(r"bins:\s*(?:\n\s*-\s*([\w-]+)|\[\s*\"?([\w-]+)\"?)", fm)
        if not (ver and b):
            continue
        binary = b.group(1) or b.group(2)
        name = os.path.basename(os.path.dirname(p))
        claims.setdefault(binary, {}).setdefault(ver.group(1), []).append(name)

    drift = []
    for binary, by_ver in sorted(claims.items()):
        try:
            r = subprocess.run([binary, "--version"], capture_output=True,
                               text=True, timeout=10)
        except (OSError, subprocess.SubprocessError):
            continue  # not installed / not runnable: nothing to compare
        out = (r.stdout or "") + " " + (r.stderr or "")
        m = re.search(r"\d+\.\d+(?:\.\d+)?", out)
        if not m:
            continue
        installed = m.group(0)
        for ver, skills in sorted(by_ver.items()):
            if ver != installed:
                drift.append((binary, installed, ver, sorted(skills)))
    return drift


def print_drift(drift, stream):
    print(f"- {len(drift)} skill doc(s) describe a different release than the "
          f"installed binary (docs may omit newer flags):", file=stream)
    for binary, installed, documented, skills in drift:
        shown = ", ".join(skills[:4]) + (f" +{len(skills) - 4} more" if len(skills) > 4 else "")
        print(f"    {binary}: binary {installed}, docs {documented}  ({shown})",
              file=stream)
    print("    fix: npx skills update -g -y   "
          "(embedded skills may need reinstalling from the app instead)",
          file=stream)


if mode == "drift":
    d = find_drift(live_skills)
    if d:
        print_drift(d, sys.stdout)
    sys.exit(0)

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

# Drift is routine rather than rot, so it rides on stdout and leaves the exit
# code alone. doctor.sh surfaces this text under its pass line.
drift = find_drift(live_skills)
if drift:
    print_drift(drift, sys.stdout)
PY
