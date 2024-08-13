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

# Function to export packages
export_packages() {
  cargo install --list | grep -E '^[a-zA-Z0-9_-]+' | awk '{print $1}' >"$PACKAGES_FILE"
  echo "Cargo packages have been exported to $PACKAGES_FILE"
}

# Function to install packages
install_packages() {
  if [[ ! -f "$PACKAGES_FILE" ]]; then
    echo "File $PACKAGES_FILE not found!"
    exit 1
  fi
  while IFS= read -r package; do
    cargo install "$package"
  done <"$PACKAGES_FILE"
  echo "All Cargo packages from $PACKAGES_FILE have been installed."
}

# Check the input argument
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
