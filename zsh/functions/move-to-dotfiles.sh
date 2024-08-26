#!/bin/zsh

# Function to move a file or directory to the mirrored location in $HOME/dotfiles
move-to-dotfiles() {
  if [ $# -eq 0 ]; then
    echo "Usage: move-to-dotfiles <file_or_directory>"
    return 1
  fi

  local src_path="$1"
  local dest_dir="$HOME/dotfiles"
  local relative_path
  local dest_path

  # Check if the source exists
  if [ ! -e "$src_path" ]; then
    echo "Error: $src_path does not exist."
    return 1
  fi

  # Calculate the relative path from $HOME
  relative_path="${src_path/#$HOME\//}"
  dest_path="$dest_dir/$relative_path"

  # Create the destination directory if it doesn't exist
  mkdir -p "$(dirname "$dest_path")"

  # Move the file/directory to the destination
  mv "$src_path" "$dest_path"

  # Navigate to $HOME/dotfiles and run stow
  (cd "$HOME/dotfiles" && stow .)

  # Move back to the original directory
  cd "$(dirname "$src_path")"
}
