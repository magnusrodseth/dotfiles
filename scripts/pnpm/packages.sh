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
export_packages() {
  # Use pnpm list --global --depth=0 --json and extract package names from dependencies
  pnpm list --global --depth=0 --json | jq -r '.[0].dependencies | keys[]' >"$PACKAGES_FILE"
  echo "pnpm global packages have been exported to $PACKAGES_FILE"
}

# Function to install packages from the list
install_packages() {
  if [[ ! -f "$PACKAGES_FILE" ]]; then
    echo "File $PACKAGES_FILE not found!"
    exit 1
  fi

  # Install each package listed in the file
  while IFS= read -r package; do
    if ! pnpm install -g "$package"; then
      echo "Failed to install package: $package"
    fi
  done <"$PACKAGES_FILE"

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
