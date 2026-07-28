#!/bin/bash

# Directory to store the list of packages
PACKAGES_DIR="$HOME/dotfiles/scripts/pnpm"
# File to store the list of packages
PACKAGES_FILE="$PACKAGES_DIR/pnpm_packages.txt"

# Ensure the directory exists
mkdir -p "$PACKAGES_DIR"

# Function to display help
show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Manage pnpm global packages."
  echo
  echo "Options:"
  echo "  export     Export all installed pnpm global packages to $PACKAGES_FILE"
  echo "  install    Install all pnpm global packages listed in $PACKAGES_FILE"
  echo "  help       Display this help and exit"
}

# Function to export installed pnpm global packages
#
# Reads the global package.json directly, which is the same source doctor.sh
# trusts. It does NOT use `pnpm list --global --json`: current pnpm omits the
# `dependencies` key entirely from that output, so `jq '.[0].dependencies'`
# errored, printed nothing, and the `>` redirect had already truncated the
# manifest to zero bytes. That destroyed the file and still exited 0, printing
# "packages have been exported".
#
# Writes via a temp file so the manifest is only replaced by a verified,
# non-empty result. Never redirect straight onto $PACKAGES_FILE here.
export_packages() {
  local gdir pkgjson tmp
  gdir="$(pnpm root -g 2>/dev/null)" || { echo "pnpm root -g failed" >&2; exit 1; }
  pkgjson="$(dirname "$gdir")/package.json"
  if [[ ! -f "$pkgjson" ]]; then
    echo "No global package.json at $pkgjson; refusing to touch $PACKAGES_FILE" >&2
    exit 1
  fi

  tmp="$(mktemp)"
  if ! jq -er '.dependencies // {} | keys[]' "$pkgjson" | sort >"$tmp"; then
    rm -f "$tmp"
    echo "Failed to read dependencies from $pkgjson; $PACKAGES_FILE left untouched" >&2
    exit 1
  fi
  if [[ ! -s "$tmp" ]]; then
    rm -f "$tmp"
    echo "Refusing to write an empty manifest; $PACKAGES_FILE left untouched" >&2
    exit 1
  fi

  mv "$tmp" "$PACKAGES_FILE"
  echo "pnpm global packages have been exported to $PACKAGES_FILE"
}

# Function to install packages from the list
install_packages() {
  if [[ ! -f "$PACKAGES_FILE" ]]; then
    echo "File $PACKAGES_FILE not found!"
    exit 1
  fi

  local -a failures=()
  while IFS= read -r package; do
    [[ -z "$package" ]] && continue
    if ! pnpm install -g "$package"; then
      failures+=("$package")
      echo "Failed to install package: $package"
    fi
  done <"$PACKAGES_FILE"

  if (( ${#failures[@]} > 0 )); then
    echo
    echo "pnpm install completed with ${#failures[@]} failure(s):"
    printf '  - %s\n' "${failures[@]}"
    exit 1
  fi
  echo "All pnpm global packages from $PACKAGES_FILE have been installed."
}

# Ensure pnpm is installed, otherwise prompt the user to install it
ensure_pnpm_installed() {
  if ! command -v pnpm >/dev/null 2>&1; then
    echo "pnpm not found. Please install pnpm first."
    exit 1
  fi
}

# Ensure jq is installed, otherwise prompt the user to install it
ensure_jq_installed() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found. Please install jq first."
    exit 1
  fi
}

# Ensure pnpm and jq are installed before proceeding
ensure_pnpm_installed
ensure_jq_installed

# Check the input argument and execute the corresponding function
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
