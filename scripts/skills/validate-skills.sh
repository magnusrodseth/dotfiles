#!/usr/bin/env bash
#
# validate-skills.sh - fail loud when a skill in .claude/skills/ would be
# silently invisible to Claude Code.
#
# Claude Code only loads a skill whose SKILL.md has YAML frontmatter starting
# on line 1 with non-empty `name` and `description`. A malformed block does
# not error anywhere; the skill just vanishes from the model's skill list.
# This script is the loud failure. Run standalone, from doctor.sh, or from
# the pre-commit hook (scripts/githooks/pre-commit).
#
# Checks (authored skills, i.e. real directories):
#   - SKILL.md exists
#   - frontmatter opens with --- on line 1 and is closed with ---
#   - non-empty `name` (lowercase letters/digits/hyphens) and `description`
#     (inline or block scalar)
#   - no duplicate skill names across the tree
#
# Usage: validate-skills.sh [--links]
#   --links  also require symlinked skill entries (installed via the skills
#            lock file) to resolve. This is machine state, not repo content:
#            doctor.sh passes it, the pre-commit hook does not.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/../../.claude/skills" && pwd)"

CHECK_LINKS=0
[ "${1:-}" = "--links" ] && CHECK_LINKS=1

errors=0
err() { echo "- $1" >&2; errors=$((errors + 1)); }

names=""        # "name<TAB>skill-dir" lines, for duplicate detection
validated=0
links_ok=0

for entry in "$SKILLS_DIR"/*; do
  name_dir="$(basename "$entry")"

  if [ -L "$entry" ]; then
    # Externally managed skill (skill-lock.json / ~/.agents). Its content is
    # not authored here, so only check the link resolves when asked to.
    if [ "$CHECK_LINKS" -eq 1 ]; then
      if [ -f "$entry/SKILL.md" ]; then
        links_ok=$((links_ok + 1))
      else
        err "$name_dir: broken symlink ($(readlink "$entry"))"
      fi
    fi
    continue
  fi

  [ -d "$entry" ] || continue

  skill_md="$entry/SKILL.md"
  if [ ! -f "$skill_md" ]; then
    err "$name_dir: missing SKILL.md"
    continue
  fi

  result="$(awk '
    NR == 1 {
      if ($0 != "---") { print "ERR|frontmatter must open with --- on line 1"; bad = 1; exit }
      next
    }
    /^---[ \t]*$/ { closed = 1; exit }
    descblock && /^[^ \t]/ { descblock = 0 }
    /^name:/ {
      val = $0; sub(/^name:[ \t]*/, "", val)
      gsub(/^["'\'']+|["'\'']+$/, "", val)
      name = val
    }
    /^description:/ {
      val = $0; sub(/^description:[ \t]*/, "", val)
      if (val ~ /^[>|][+-]?[ \t]*$/) descblock = 1
      else if (val != "") desc = 1
    }
    descblock && /^[ \t]+[^ \t]/ { desc = 1; descblock = 0 }
    END {
      if (bad) exit
      if (!closed) print "ERR|frontmatter never closed with ---"
      if (name == "") print "ERR|missing non-empty name"
      else if (name !~ /^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/) print "ERR|name must be lowercase letters, digits, hyphens: \"" name "\""
      if (!desc) print "ERR|missing non-empty description"
      if (name != "") print "NAME|" name
    }
  ' "$skill_md")"

  had_err=0
  while IFS= read -r line; do
    case "$line" in
      ERR\|*) err "$name_dir/SKILL.md: ${line#ERR|}"; had_err=1 ;;
      NAME\|*) names="${names}${line#NAME|}	${name_dir}
" ;;
    esac
  done <<< "$result"

  [ "$had_err" -eq 0 ] && validated=$((validated + 1))
done

# Duplicate names across authored skills.
dupes="$(printf '%s' "$names" | sort | awk -F'\t' '
  $1 == prev { print "- duplicate skill name \"" $1 "\" in " dir " and " $2 }
  { prev = $1; dir = $2 }
')"
if [ -n "$dupes" ]; then
  echo "$dupes" >&2
  errors=$((errors + 1))
fi

if [ "$errors" -gt 0 ]; then
  echo "Skill validation failed ($errors problem(s))." >&2
  exit 1
fi

msg="Validated $validated authored skill(s)"
[ "$CHECK_LINKS" -eq 1 ] && msg="$msg, $links_ok symlinked skill(s) resolve"
echo "$msg."
