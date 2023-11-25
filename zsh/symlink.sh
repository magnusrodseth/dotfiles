#!/bin/zsh

# The directory where your dotfiles are stored
source=~/dev/dotfiles/

# List of dotfiles to symlink
dotfiles=(
  ".config/nvim" 
  
) 

# Loop through the list and create symlinks
for dotfile in $dotfiles; do
    # Destination path in the home directory
    destination=~/$dotfile

    # Check if the file or directory already exists in the home directory
    if [[ -e $destination || -L $destination ]]; then
        echo "A file or symlink for $dotfile already exists. Skipping..."
    else
        # Create the symlink
        ln -s "$source$dotfile" "$destination"
        echo "Symlink created for $dotfile"
    fi
done

echo "Symlink setup complete."
