#!/bin/bash

# npm global packages.
#
# These live under nvm's active node prefix, NOT in the pnpm store, so
# scripts/pnpm/packages.sh cannot see or restore them. They were undeclared
# entirely until 28.07.2026, which meant a fresh machine restored all 62 gws-*
# and recipe-* skills from skill-lock.json and then had every one of them fail
# at its first command, because `gws` itself was never installed. `ctx7` (the
# CLI .claude/rules/context7.md mandates), `agent-browser`, `playwriter` and the
# typescript language server were missing for the same reason.
#
# npm and corepack are deliberately excluded: they ship with node, and pinning
# them here would fight the node install rather than reproduce it.

PACKAGES_DIR="$HOME/dotfiles/scripts/npm"
PACKAGES_FILE="$PACKAGES_DIR/npm_packages.txt"

# Bundled with node; never export or install these.
EXCLUDE_RE='^(npm|corepack)$'

mkdir -p "$PACKAGES_DIR"

show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Manage npm global packages."
  echo
  echo "Options:"
  echo "  export     Export all installed npm global packages to $PACKAGES_FILE"
  echo "  install    Install all npm global packages listed in $PACKAGES_FILE"
  echo "  help       Display this help and exit"
}

# Writes via a temp file so a failed read can never truncate the manifest.
# (scripts/pnpm/packages.sh had exactly that bug: a redirect onto the manifest
# emptied it when jq failed, and still exited 0.)
export_packages() {
  local tmp
  tmp="$(mktemp)"
  if ! npm ls -g --depth=0 --json 2>/dev/null |
    jq -er '.dependencies // {} | keys[]' |
    grep -vE "$EXCLUDE_RE" | sort >"$tmp"; then
    rm -f "$tmp"
    echo "Failed to read npm global packages; $PACKAGES_FILE left untouched" >&2
    exit 1
  fi
  if [[ ! -s "$tmp" ]]; then
    rm -f "$tmp"
    echo "Refusing to write an empty manifest; $PACKAGES_FILE left untouched" >&2
    exit 1
  fi
  mv "$tmp" "$PACKAGES_FILE"
  echo "npm global packages have been exported to $PACKAGES_FILE"
}

install_packages() {
  if [[ ! -f "$PACKAGES_FILE" ]]; then
    echo "File $PACKAGES_FILE not found!"
    exit 1
  fi

  local -a failures=()
  while IFS= read -r package; do
    [[ -z "$package" ]] && continue
    case "$package" in \#*) continue ;; esac
    if ! npm install -g "$package"; then
      failures+=("$package")
      echo "Failed to install package: $package"
    fi
  done <"$PACKAGES_FILE"

  if ((${#failures[@]} > 0)); then
    echo
    echo "npm install completed with ${#failures[@]} failure(s):"
    printf '  - %s\n' "${failures[@]}"
    exit 1
  fi
  echo "All npm global packages from $PACKAGES_FILE have been installed."
}

ensure_npm_installed() {
  if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found. Install node (Brewfile) or activate nvm first."
    exit 1
  fi
}

ensure_jq_installed() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found. Please install jq first."
    exit 1
  fi
}

ensure_npm_installed
ensure_jq_installed

case "${1:-}" in
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
  echo "Invalid option: ${1:-}"
  show_help
  exit 1
  ;;
esac
