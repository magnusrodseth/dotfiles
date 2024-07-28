#!/bin/bash

# Directory to store the list of extensions
EXTENSIONS_DIR="$HOME/dotfiles/scripts/vscode"
# File to store the list of extensions
EXTENSIONS_FILE="$EXTENSIONS_DIR/vscode_extensions.txt"

# Ensure the directory exists
mkdir -p "$EXTENSIONS_DIR"

# Function to display help
show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Manage VSCode extensions."
  echo
  echo "Options:"
  echo "  export     Export all installed VSCode extensions to $EXTENSIONS_FILE"
  echo "  install    Install all VSCode extensions listed in $EXTENSIONS_FILE"
  echo "  help       Display this help and exit"
}

# Function to export extensions
export_extensions() {
  code --list-extensions > "$EXTENSIONS_FILE"
  echo "VSCode extensions have been exported to $EXTENSIONS_FILE"
}

# Function to install extensions
install_extensions() {
  if [[ ! -f "$EXTENSIONS_FILE" ]]; then
    echo "File $EXTENSIONS_FILE not found!"
    exit 1
  fi

  while IFS= read -r extension; do
    code --install-extension "$extension"
  done < "$EXTENSIONS_FILE"

  echo "All VSCode extensions from $EXTENSIONS_FILE have been installed."
}

# Check the input argument
case "$1" in
  export)
    export_extensions
    ;;
  install)
    install_extensions
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
