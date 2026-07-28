#!/bin/bash

# Directory to store the list of packages
PACKAGES_DIR="$HOME/dotfiles/scripts/cargo"
# File to store the list of packages
PACKAGES_FILE="$PACKAGES_DIR/cargo_packages.txt"

# Ensure the directory exists
mkdir -p "$PACKAGES_DIR"

# Function to display help
show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Manage Cargo packages."
  echo
  echo "Options:"
  echo "  export     Export all installed Cargo packages to $PACKAGES_FILE"
  echo "  install    Install all Cargo packages listed in $PACKAGES_FILE"
  echo "  help       Display this help and exit"
}

# Function to export installed Cargo packages
#
# Reads ~/.cargo/.crates2.json and keeps only crates.io installs, because those
# are the ones `cargo install <name>` can reproduce from a bare name. Anything
# installed from a git or path source is listed as a warning instead: writing
# its bare name here would make `install` silently fetch a different, unrelated
# crates.io crate.
#
# That is not hypothetical. `uv 0.4.28 (git+https://github.com/astral-sh/uv)`
# was installed this way; the old exporter would have written a bare `uv` into
# the manifest, and since .zshenv puts ~/.cargo/bin ahead of /opt/homebrew/bin,
# the next `install` run would have shadowed the brew-managed uv with a stale
# 2024 build. That is exactly the 105 GB-cache incident the Brewfile warns about.
#
# Writes atomically: never redirect straight onto $PACKAGES_FILE.
export_packages() {
  local crates="$HOME/.cargo/.crates2.json" tmp skipped
  if [[ ! -f "$crates" ]]; then
    echo "No $crates; $PACKAGES_FILE left untouched" >&2
    exit 1
  fi

  skipped="$(jq -r '.installs | keys[] | select(contains("(registry+") | not) | split(" ")[0]' "$crates" 2>/dev/null)"
  if [[ -n "$skipped" ]]; then
    echo "Skipping non-crates.io installs (cannot be reproduced by name):" >&2
    printf '  - %s\n' $skipped >&2
  fi

  tmp="$(mktemp)"
  if ! jq -er '.installs | keys[] | select(contains("(registry+")) | split(" ")[0]' \
    "$crates" | sort -u >"$tmp"; then
    rm -f "$tmp"
    echo "Failed to read $crates; $PACKAGES_FILE left untouched" >&2
    exit 1
  fi
  if [[ ! -s "$tmp" ]]; then
    rm -f "$tmp"
    echo "Refusing to write an empty manifest; $PACKAGES_FILE left untouched" >&2
    exit 1
  fi

  mv "$tmp" "$PACKAGES_FILE"
  echo "Cargo packages have been exported to $PACKAGES_FILE"
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
    if ! cargo install "$package"; then
      failures+=("$package")
      echo "Failed to install package: $package"
    fi
  done <"$PACKAGES_FILE"

  if (( ${#failures[@]} > 0 )); then
    echo
    echo "Cargo install completed with ${#failures[@]} failure(s):"
    printf '  - %s\n' "${failures[@]}"
    exit 1
  fi
  echo "All Cargo packages from $PACKAGES_FILE have been installed."
}

# Ensure Rust and Cargo are installed, otherwise install them using rustup
ensure_rust_installed() {
  if ! command -v cargo >/dev/null 2>&1; then
    echo "Rust and Cargo not found. Installing using rustup..."
    curl https://sh.rustup.rs -sSf | sh
    source $HOME/.cargo/env
  fi
}

# Ensure Rust and Cargo are installed before proceeding
ensure_rust_installed

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
