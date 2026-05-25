#!/bin/bash

# Idempotently symlink every skill in ~/dotfiles/.claude/skills/ into
# ~/.claude/skills/ so they are available globally, not just in the
# dotfiles project. Safe to rerun. Skips entries that are already
# correctly linked. Warns (does not overwrite) on conflicts.

set -eu

SRC="$HOME/dotfiles/.claude/skills"
DEST="$HOME/.claude/skills"

if [ ! -d "$SRC" ]; then
  echo "Source dir not found: $SRC"
  exit 1
fi

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
  echo "linked $name"
  linked=$((linked + 1))
done

echo "Done: $linked linked, $skipped already correct, $conflicts conflicts"
