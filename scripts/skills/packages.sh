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
