#!/usr/bin/env bash
#
# sync-rules.sh - keep the instruction rules that apply to every agent in one
# place, and splice them into the agent files that cannot import a file.
#
#   source of truth   scripts/agents/rules/<name>.md   (body only, no heading)
#   targets           see MANIFEST below
#
# The sources sit under scripts/ because .stow-local-ignore already excludes that
# whole directory, so they never leak into $HOME as files of their own. Only the
# spliced copies ship.
#
# Why this exists rather than a symlink or an import:
#
#   Claude Code   could read these from ~/.claude/rules/, which it auto-loads
#                 with no @import. That was the original design here and it was
#                 wrong for two reasons: the behaviour is undocumented, and it
#                 gave a rule a delivery path with different failure modes from
#                 the rest of CLAUDE.md. On 11.08.2026 a new rule file was added
#                 and the em-dash rule was moved into it, which left Claude Code
#                 with the rule in neither place until the next `stow --restow`.
#                 Every agent is now spliced the same way and nothing depends on
#                 the auto-load.
#   Codex         cannot import at all. .codex/AGENTS.md used to end with a bare
#                 `@RTK.md` and Codex received three literal characters, so the
#                 RTK rules never applied there for months (verified 25.07.2026
#                 with `codex debug prompt-input`). A silent failure of exactly
#                 this shape is what this script is here to prevent.
#   OpenCode      already used hand-maintained `<!-- context7 -->` markers. This
#                 formalises that convention instead of inventing one.
#
# The target file owns the heading and the placement. This script owns only the
# bytes between the markers:
#
#   ## Writing Style
#
#   <!-- rules:writing-style -->
#   ...replaced verbatim from scripts/agents/rules/writing-style.md...
#   <!-- /rules:writing-style -->
#
# A rule listed for a target whose markers are absent is appended at the end of
# the file, once. Move the block afterwards if you want it somewhere else; the
# markers are what the script finds, not the position.
#
# Verbs:
#   sync    rewrite every block from its source. Idempotent. Prints what changed.
#   check   exit 1 if any block has drifted or is missing. Reads only.
#
# Note that `sync` writes into this repo, not into $HOME. A dirty working tree
# after `install.sh` therefore means a rule source changed and a target was
# behind; commit the result.

set -uo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
cd "$DOTFILES" || { echo "sync-rules: cannot cd to $DOTFILES" >&2; exit 1; }

RULES_DIR="scripts/agents/rules"

# <target path>:<comma-separated rule names>
#
# OpenCode is deliberately thin. It carries only the two rules that change what
# it does on every task; the rest would be prompt weight for no behaviour. Widen
# its list only on purpose, not for symmetry with the other two.
MANIFEST="
.claude/CLAUDE.md:dev-server,task-completion,writing-style,norwegian,context7
.codex/AGENTS.md:dev-server,task-completion,writing-style,norwegian,context7
.config/opencode/AGENTS.md:writing-style,context7
"

TMPDIR_RUN="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_RUN"' EXIT

# apply_rule <name> : stdin -> stdout, with that rule's block brought up to date
apply_rule() {
  local name="$1" src="$RULES_DIR/$1.md"
  if [ ! -f "$src" ]; then
    echo "sync-rules: no such rule: $name (expected $src)" >&2
    return 1
  fi
  awk -v name="$name" -v src="$src" '
    BEGIN {
      begin = "<!-- rules:" name " -->"
      end   = "<!-- /rules:" name " -->"
      while ((getline line < src) > 0) body = body line "\n"
      close(src)
      sub(/\n+$/, "\n", body)
    }
    $0 == begin        { inblock = 1; found = 1; printf "%s\n%s%s\n", begin, body, end; next }
    inblock && $0 == end { inblock = 0; next }
    inblock            { next }
                       { print }
    END {
      if (!found) printf "\n%s\n%s%s\n", begin, body, end
    }
  '
}

# render <target> <rules> : print what the target should contain
render() {
  local file="$1" rules="$2" content name
  content="$(cat "$file")" || return 1
  local IFS=,
  for name in $rules; do
    content="$(printf '%s\n' "$content" | apply_rule "$name")" || return 1
  done
  printf '%s\n' "$content"
}

# Rules on disk that no target lists. The other drift direction: you write a rule
# file, commit it, and no agent ever sees it because nothing splices it anywhere.
orphan_rules() {
  local f name
  for f in "$RULES_DIR"/*.md; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .md)"
    case "$MANIFEST" in
      *":$name,"*|*",$name,"*|*":$name"$'\n'*|*",$name"$'\n'*) ;;
      *) echo "$name" ;;
    esac
  done
}

verb="${1:-}"
case "$verb" in
  sync|check) ;;
  *) echo "usage: bash scripts/agents/sync-rules.sh {sync|check}" >&2; exit 2 ;;
esac

fails=0
changed=0
for entry in $MANIFEST; do
  target="${entry%%:*}"
  rules="${entry#*:}"

  if [ ! -f "$target" ]; then
    echo "sync-rules: target missing: $target" >&2
    fails=$((fails + 1))
    continue
  fi

  out="$TMPDIR_RUN/$(echo "$target" | tr '/' '_')"
  if ! render "$target" "$rules" > "$out"; then
    fails=$((fails + 1))
    continue
  fi

  if cmp -s "$out" "$target"; then
    continue
  fi

  if [ "$verb" = "sync" ]; then
    cat "$out" > "$target" || { fails=$((fails + 1)); continue; }
    echo "updated $target"
    changed=$((changed + 1))
  else
    echo "drifted: $target" >&2
    diff -u "$target" "$out" | sed -n '3,15p' >&2
    fails=$((fails + 1))
  fi
done

orphans="$(orphan_rules)"
if [ -n "$orphans" ]; then
  echo "sync-rules: rule(s) in $RULES_DIR listed by no target: $(echo "$orphans" | tr '\n' ' ')" >&2
  echo "  No agent reads them until they are in MANIFEST." >&2
  [ "$verb" = "check" ] && fails=$((fails + 1))
fi

if [ "$fails" -gt 0 ]; then
  exit 1
fi

if [ "$verb" = "sync" ]; then
  [ "$changed" -eq 0 ] && echo "agent rules already in sync"
else
  echo "agent rules in sync across $(echo "$MANIFEST" | grep -c .) target(s)"
fi
exit 0
