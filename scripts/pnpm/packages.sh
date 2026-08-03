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
# Reads `pnpm ls -g --json`, which is the same source doctor.sh trusts.
#
# This used to read the global package.json at `dirname $(pnpm root -g)`, for a
# good reason at the time: pnpm then omitted the `dependencies` key from the
# JSON, so `jq '.[0].dependencies'` errored, printed nothing, and the `>`
# redirect had already truncated the manifest to zero bytes -- destroying the
# file while still exiting 0 and printing "packages have been exported".
#
# pnpm 11 (03.08.2026) invalidated the replacement instead. It no longer keeps
# one global node_modules with package-name entries; each install gets its own
# hash-named directory under global/v11, and there is no global/package.json at
# all, so the read failed outright. The same release fixed the JSON, which now
# does carry `dependencies`, so that is the supported source again.
#
# Writes via a temp file so the manifest is only replaced by a verified,
# non-empty result. Never redirect straight onto $PACKAGES_FILE here.
export_packages() {
  local tmp
  tmp="$(mktemp)"
  if ! pnpm ls -g --depth=0 --json 2>/dev/null |
    jq -er '.[0].dependencies // {} | keys[]' | sort >"$tmp"; then
    rm -f "$tmp"
    echo "Failed to read global packages from pnpm; $PACKAGES_FILE left untouched" >&2
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
