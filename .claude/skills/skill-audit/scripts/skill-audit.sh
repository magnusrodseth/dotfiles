#!/usr/bin/env bash
#
# skill-audit.sh - which installed skills earn their context budget?
#
# Every skill's name + description is loaded into Claude Code's context in
# every session. This script inventories the loaded skills, estimates that
# always-paid token cost, and mines ~/.claude/projects transcripts for real
# usage evidence, so unused skills can be removed with confidence.
#
# Usage evidence (heuristic, three signals):
#   1. Skill tool invocations   "skill":"<name>"
#   2. Slash commands           <command-name>/<name>
#   3. SKILL.md reads           .../<name>/SKILL.md
#
# Usage: skill-audit.sh [--root DIR]...
#   --root DIR  additional skill root to inventory (repeatable), e.g. a
#               project's .claude/skills. Default root: ~/.claude/skills

set -uo pipefail

PROJECTS_DIR="$HOME/.claude/projects"
ROOTS=("$HOME/.claude/skills")

while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOTS+=("$2"); shift 2 ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- inventory: name, source, token estimate per skill ------------------------

classify() {
  local entry="$1"
  if [ -L "$entry" ]; then
    case "$(readlink "$entry")" in
      *dotfiles/.claude/skills/*) echo "dotfiles" ;;
      *.agents/skills/*)          echo "skills-cli" ;;
      *)                          echo "link" ;;
    esac
  else
    echo "local"
  fi
}

for root in "${ROOTS[@]}"; do
  [ -d "$root" ] || { echo "skip missing root: $root" >&2; continue; }
  for entry in "$root"/*; do
    [ -f "$entry/SKILL.md" ] || continue
    awk -v name_default="$(basename "$entry")" -v src="$(classify "$entry")" '
      NR == 1 { if ($0 != "---") exit; next }
      /^---[ \t]*$/ { exit }
      descblock && /^[^ \t]/ { descblock = 0 }
      /^name:/ {
        val = $0; sub(/^name:[ \t]*/, "", val)
        gsub(/^["'\'']+|["'\'']+$/, "", val)
        if (val != "") name = val
      }
      /^description:/ {
        val = $0; sub(/^description:[ \t]*/, "", val)
        if (val ~ /^[>|][+-]?[ \t]*$/) descblock = 1
        else desc = val
      }
      descblock && /^[ \t]+[^ \t]/ {
        val = $0; sub(/^[ \t]+/, "", val)
        desc = (desc == "" ? val : desc " " val)
      }
      END {
        if (name == "") name = name_default
        # model-visible line is roughly "- name: description"; ~4 bytes/token
        tokens = int((length(name) + length(desc) + 4) / 4) + 1
        printf "%s\t%s\t%d\n", name, src, tokens
      }
    ' "$entry/SKILL.md" >> "$TMP/inventory.tsv"
  done
done

if [ ! -s "$TMP/inventory.tsv" ]; then
  echo "No skills found under: ${ROOTS[*]}" >&2
  exit 1
fi

# --- usage: mine transcripts for the three signals -----------------------------

if [ -d "$PROJECTS_DIR" ]; then
  {
    rg -oH --no-heading -g '*.jsonl' -r '$1' '"skill"[[:space:]]*:[[:space:]]*"([a-z0-9:_-]+)"' "$PROJECTS_DIR" 2>/dev/null
    rg -oH --no-heading -g '*.jsonl' -r '$1' '<command-name>/?([a-z0-9:_-]+)' "$PROJECTS_DIR" 2>/dev/null
    rg -oH --no-heading -g '*.jsonl' -r '$1' '/([a-z0-9_-]+)/SKILL\.md' "$PROJECTS_DIR" 2>/dev/null
  } | awk '{ i = index($0, ":"); if (i > 1) printf "%s\t%s\n", substr($0, 1, i - 1), substr($0, i + 1) }' \
    > "$TMP/pairs.tsv"

  cut -f1 "$TMP/pairs.tsv" | sort -u > "$TMP/files.txt"
  # epoch + formatted mtime per transcript, to derive last-used dates
  # (BSD awk has no strftime, so dates are formatted here by stat)
  xargs stat -t '%Y-%m-%d' -f '%m%t%Sm%t%N' < "$TMP/files.txt" > "$TMP/mtimes.tsv" 2>/dev/null

  window_from="$(sort -n "$TMP/mtimes.tsv" 2>/dev/null | head -1 | cut -f2)"
else
  : > "$TMP/pairs.tsv"; : > "$TMP/mtimes.tsv"
  window_from=""
fi

# --- report --------------------------------------------------------------------

awk -F'\t' \
  -v mtimes="$TMP/mtimes.tsv" -v pairs="$TMP/pairs.tsv" -v from="$window_from" '
  BEGIN {
    while ((getline line < mtimes) > 0) {
      split(line, a, "\t"); mtime[a[3]] = a[1] + 0; mdate[a[3]] = a[2]
    }
    while ((getline line < pairs) > 0) {
      split(line, a, "\t"); file = a[1]; skill = a[2]
      uses[skill]++
      if (mtime[file] > last[skill]) { last[skill] = mtime[file]; lastdate[skill] = mdate[file] }
    }
  }
  { name = $1; src[name] = $2; tokens[name] = $3; order[++n] = name; total += $3 }
  END {
    printf "SKILL AUDIT — %d skills loaded, ~%d tokens of always-loaded descriptions\n", n, total
    if (from != "") printf "Usage window: transcripts since %s\n", from
    printf "\n%6s  %-11s  %7s  %-34s %s\n", "USES", "LAST-USED", "TOKENS", "SKILL", "SOURCE"
    # used skills, most-used first
    m = 0
    for (i = 1; i <= n; i++) {
      name = order[i]
      if (uses[name] > 0) { used[++m] = name }
      else { unused[++u] = name; utokens += tokens[name] }
    }
    for (i = 1; i <= m; i++)
      for (j = i + 1; j <= m; j++)
        if (uses[used[j]] > uses[used[i]]) { t = used[i]; used[i] = used[j]; used[j] = t }
    for (i = 1; i <= m; i++) {
      name = used[i]
      printf "%6d  %-11s  %7d  %-34s %s\n", uses[name], lastdate[name], tokens[name], name, src[name]
    }
    if (u > 0) {
      for (i = 1; i <= u; i++)
        for (j = i + 1; j <= u; j++)
          if (tokens[unused[j]] > tokens[unused[i]]) { t = unused[i]; unused[i] = unused[j]; unused[j] = t }
      printf "\nUNUSED IN WINDOW — %d skills, ~%d tokens (%d%% of budget):\n", u, utokens, int(utokens * 100 / total)
      for (i = 1; i <= u; i++) {
        name = unused[i]
        printf "%6d  %-11s  %7d  %-34s %s\n", 0, "never", tokens[name], name, src[name]
      }
    }
  }
' "$TMP/inventory.tsv"
