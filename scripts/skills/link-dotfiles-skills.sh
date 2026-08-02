#!/bin/bash

# Maintain the two user-scope skill roots. Safe to rerun; idempotent.
#
# LAYOUT (one rule, no exceptions):
#
#   ~/.agents/skills/<name>   CANONICAL. Either a real directory (installed by
#                             `npx skills`, provenance in skill-lock.json) or a
#                             symlink into ~/dotfiles/.claude/skills (authored).
#   ~/.claude/skills/<name>   ALWAYS a symlink -> ../../.agents/skills/<name>
#
# Three agents read these, and they disagree about where to look:
#   ~/.claude/skills   Claude Code
#   ~/.agents/skills   Codex CLI, the ChatGPT app, and Zed's agent panel
# Zed is the strictest: it scans ONLY .agents/skills, one level deep, and will
# not look at .claude/skills at all (see crates/agent_skills/README.md upstream).
# That is why .agents is canonical and .claude is a pure mirror of it.
#
# This replaced an older design that linked dotfiles into BOTH roots
# independently. That design let the two roots disagree: `npx skills` writes a
# real dir into ~/.agents, the old script saw a real path and skipped it, and
# the dotfiles copy kept loading in Claude Code while Codex and Zed loaded the
# installed one. On 02.08.2026 that had produced 42 shadowed skills, 4 of them
# with genuinely different content. Mirroring one root into the other makes
# that class of drift unrepresentable.
#
# Prunes managed links whose target is gone, so deleted or renamed skills do
# not leave dangling entries. Real directories and foreign symlinks in
# ~/.agents are never touched: they are lock-file territory.

set -eu

SRC="$HOME/dotfiles/.claude/skills"
AGENTS="$HOME/.agents/skills"
CLAUDE="$HOME/.claude/skills"

if [ ! -d "$SRC" ]; then
  echo "Source dir not found: $SRC"
  exit 1
fi

mkdir -p "$AGENTS" "$CLAUDE"

# --- 1. authored skills: dotfiles -> ~/.agents/skills -------------------------

linked=0
skipped=0
conflicts=0

for entry in "$SRC"/*; do
  [ -e "$entry" ] || continue
  name="$(basename "$entry")"
  target="$AGENTS/$name"
  expected="../../dotfiles/.claude/skills/$name"

  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$expected" ]; then
      skipped=$((skipped + 1))
    else
      echo "WARN: $target -> $(readlink "$target") (expected $expected); skipping"
      conflicts=$((conflicts + 1))
    fi
    continue
  fi

  if [ -e "$target" ]; then
    # A real dir here means `npx skills` installed the same name. The installed
    # copy wins (it is the one three agents already load); the dotfiles copy is
    # a duplicate that should be removed from the repo. check-skill-integrity.sh
    # reports these so they do not accumulate silently.
    echo "WARN: $target is a real dir (installed copy shadows the dotfiles one); skipping"
    conflicts=$((conflicts + 1))
    continue
  fi

  ln -s "$expected" "$target"
  echo "linked $name -> ~/.agents/skills"
  linked=$((linked + 1))
done

pruned=0
for target in "$AGENTS"/*; do
  [ -L "$target" ] || continue
  case "$(readlink "$target")" in
    *dotfiles/.claude/skills/*) ;;   # managed by this script
    *) continue ;;                   # foreign symlink; leave alone
  esac
  [ -e "$target" ] && continue       # still resolves
  rm "$target"
  echo "pruned $(basename "$target") from ~/.agents/skills (target gone)"
  pruned=$((pruned + 1))
done

echo "~/.agents/skills: $linked linked, $skipped already correct, $conflicts conflicts, $pruned pruned"

# --- 2. mirror: ~/.agents/skills -> ~/.claude/skills --------------------------
#
# Every entry, whatever its kind. Claude Code then loads exactly what Codex and
# Zed load, by construction.

mirrored=0
mir_ok=0

for entry in "$AGENTS"/*; do
  [ -e "$entry" ] || [ -L "$entry" ] || continue
  name="$(basename "$entry")"
  target="$CLAUDE/$name"
  expected="../../.agents/skills/$name"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$expected" ]; then
    mir_ok=$((mir_ok + 1))
    continue
  fi

  rm -rf "$target"
  ln -s "$expected" "$target"
  echo "mirrored $name -> ~/.claude/skills"
  mirrored=$((mirrored + 1))
done

mir_pruned=0
for target in "$CLAUDE"/*; do
  [ -L "$target" ] || continue
  case "$(readlink "$target")" in
    ../../.agents/skills/*) ;;
    *) continue ;;
  esac
  [ -e "$target" ] && continue
  rm "$target"
  echo "pruned $(basename "$target") from ~/.claude/skills (target gone)"
  mir_pruned=$((mir_pruned + 1))
done

echo "~/.claude/skills: $mirrored mirrored, $mir_ok already correct, $mir_pruned pruned"
echo "Done."
