#!/bin/bash

# Idempotently symlink every skill in ~/dotfiles/.claude/skills/ into the
# user-scope skill roots so they are available globally, not just in the
# dotfiles project. Safe to rerun. Skips entries that are already correctly
# linked. Warns (does not overwrite) on conflicts.
#
# TWO ROOTS, because two agents scan different directories:
#   ~/.claude/skills   Claude Code
#   ~/.agents/skills   Codex CLI and the ChatGPT app (same codex binary)
# Codex never reads ~/.claude/skills. Linking into one root only is why 46
# dotfiles-authored skills were invisible to Codex until 25.07.2026. Verified
# with `codex debug prompt-input`, which renders the skill roots it actually
# scans; it follows these symlinks and reports the resolved dotfiles path.
#
# Both roots sit two levels below $HOME, so one relative link target is
# correct for both. Keep it that way when adding a root.
#
# Also prunes: managed links (those pointing into dotfiles/.claude/skills)
# whose target no longer resolves are removed, so deleted/renamed skills
# don't leave dangling links behind. Real files and foreign symlinks are
# never touched.

set -eu

SRC="$HOME/dotfiles/.claude/skills"
DESTS="$HOME/.claude/skills $HOME/.agents/skills"

if [ ! -d "$SRC" ]; then
  echo "Source dir not found: $SRC"
  exit 1
fi

total_linked=0
total_skipped=0
total_conflicts=0
total_pruned=0

for DEST in $DESTS; do

mkdir -p "$DEST"

linked=0
skipped=0
conflicts=0

for entry in "$SRC"/*; do
  [ -e "$entry" ] || continue
  name="$(basename "$entry")"
  target="$DEST/$name"
  expected_resolved="$(cd "$SRC" && pwd -P)/$name"

  if [ -L "$target" ]; then
    actual_resolved="$(readlink "$target")"
    case "$actual_resolved" in
      /*) resolved="$actual_resolved" ;;
      *)  resolved="$(cd "$DEST" && cd "$(dirname "$actual_resolved")" 2>/dev/null && pwd -P)/$(basename "$actual_resolved")" ;;
    esac
    if [ "$resolved" = "$expected_resolved" ]; then
      skipped=$((skipped + 1))
      continue
    fi
    echo "WARN: $target -> $actual_resolved (expected $expected_resolved); skipping"
    conflicts=$((conflicts + 1))
    continue
  fi

  if [ -e "$target" ]; then
    echo "WARN: $target exists as a real path; skipping"
    conflicts=$((conflicts + 1))
    continue
  fi

  ln -s "../../dotfiles/.claude/skills/$name" "$target"
  echo "linked $name -> $DEST"
  linked=$((linked + 1))
done

pruned=0

for target in "$DEST"/*; do
  [ -L "$target" ] || continue
  case "$(readlink "$target")" in
    *dotfiles/.claude/skills/*) ;;   # managed by this script
    *) continue ;;                   # foreign symlink; leave alone
  esac
  [ -e "$target" ] && continue       # still resolves
  rm "$target"
  echo "pruned $(basename "$target") from $DEST (target gone)"
  pruned=$((pruned + 1))
done

echo "$DEST: $linked linked, $skipped already correct, $conflicts conflicts, $pruned pruned"

total_linked=$((total_linked + linked))
total_skipped=$((total_skipped + skipped))
total_conflicts=$((total_conflicts + conflicts))
total_pruned=$((total_pruned + pruned))

done

echo "Done: $total_linked linked, $total_skipped already correct, $total_conflicts conflicts, $total_pruned pruned"
