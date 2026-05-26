#!/bin/bash

# Lock file source (tracked in dotfiles)
LOCK_SOURCE="$HOME/dotfiles/scripts/skills/skill-lock.json"
# Lock file destination (where npx skills expects it)
LOCK_DEST="$HOME/.agents/.skill-lock.json"

# Function to display help
show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Manage agent skills via npx skills."
  echo
  echo "Options:"
  echo "  export     Copy current skill-lock.json into dotfiles for tracking"
  echo "  install    Restore skills from tracked skill-lock.json"
  echo "  help       Display this help and exit"
}

# Function to export current lock file to dotfiles
export_packages() {
  if [[ ! -f "$LOCK_DEST" ]]; then
    echo "No skill-lock.json found at $LOCK_DEST"
    exit 1
  fi

  cp "$LOCK_DEST" "$LOCK_SOURCE"
  echo "skill-lock.json exported to $LOCK_SOURCE"
}

# Function to restore skills from lock file
install_packages() {
  if [[ ! -f "$LOCK_SOURCE" ]]; then
    echo "No skill-lock.json found at $LOCK_SOURCE"
    echo "Run '$0 export' first to snapshot your current skills."
    exit 1
  fi

  # Ensure destination directory exists
  mkdir -p "$(dirname "$LOCK_DEST")"

  # Copy lock file to where npx skills expects it
  cp "$LOCK_SOURCE" "$LOCK_DEST"
  echo "Copied skill-lock.json to $LOCK_DEST"

  # Restore all skills from lock file
  npx skills experimental_install
  echo "Skills restored from lock file."

  # Mirror custom skills from dotfiles into ~/.agents/skills/ so they're
  # available to both Claude Code (.claude/skills) and other agent runtimes
  # that read from .agents/skills. Only mirrors real directories; skips
  # symlinks (those already point the other direction, into .agents/skills).
  mirror_custom_skills
}

# Function to symlink custom skills from dotfiles into ~/.agents/skills/
mirror_custom_skills() {
  local src_dir="$HOME/dotfiles/.claude/skills"
  local dest_dir="$HOME/.agents/skills"

  [[ ! -d "$src_dir" ]] && return 0
  mkdir -p "$dest_dir"

  for skill_path in "$src_dir"/*/; do
    [[ -L "${skill_path%/}" ]] && continue
    local skill_name
    skill_name="$(basename "$skill_path")"
    local target="$dest_dir/$skill_name"

    if [[ -L "$target" ]]; then
      continue
    elif [[ -e "$target" ]]; then
      echo "Skipping $skill_name: $target exists and is not a symlink"
      continue
    fi

    ln -s "${skill_path%/}" "$target"
    echo "Linked custom skill: $skill_name"
  done
}

# Ensure npx is available
if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found. Install Node.js first."
  exit 1
fi

case "$1" in
export)
  export_packages
  ;;
install)
  install_packages
  ;;
help)
  show_help
  ;;
*)
  echo "Invalid option: $1"
  show_help
  exit 1
  ;;
esac
