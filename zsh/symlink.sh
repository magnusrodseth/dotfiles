#!/bin/zsh

# Base directory where your dotfiles are stored
source_base=~/dev/dotfiles

# Function to create a symlink
symlink() {
    local relative_from=$1
    local to=$2

    # Full source path
    local from="$source_base/$relative_from"

    # Expand the tilde in the destination path
    eval expanded_to=$to

    # Check if the file or directory already exists at the destination
    if [[ -e $expanded_to || -L $expanded_to ]]; then
        echo "A file or symlink for $expanded_to already exists. Skipping..."
        return 1
    fi

    # Create the parent directory for the symlink if it doesn't exist
    local parent_dir=$(dirname "$expanded_to")
    if [[ ! -d $parent_dir ]]; then
        mkdir -p "$parent_dir"
        echo "Created directory $parent_dir"
    fi

    # Create the symlink
    ln -s "$from" "$expanded_to"
    echo "Symlink created for $expanded_to"
}

# Call the symlink function for each dotfile (now only need to specify the relative path from source_base)
symlink ".config/nvim" "~/.config/nvim"
symlink "macos/com.local.KeyRemapping.plist" "~/Library/LaunchAgents/com.local.KeyRemapping.plist"
symlink ".gitconfig" "~/.gitconfig"
symlink ".config/lazygit" "~/Library/Application\ Support/lazygit"
symlink ".config/lazydocker" "~/Library/Application\ Support/lazydocker"
symlink ".config/starship" "~/.config/starship"
symlink "vscode/snippets" "~/Library/Application\ Support/Code/User/snippets" 
symlink "vscode/keybindings.json" "~/Library/Application\ Support/Code/User/keybindings.json"
symlink "vim/.ideavimrc" "~/.ideavimrc"
symlink "vim/.vimrc" "~/.vimrc"
# Add more symlinks here in the format:
# symlink "relative_source_path" "destination_path"

echo "Symlink setup complete."
