#!/bin/zsh


# Ensure the current working directory is the dotfiles directory
if [ "$(pwd)" != "$HOME/dotfiles" ]; then
    echo "Error: The install script must be run from the \$HOME/dotfiles directory."
    exit 1
fi

# Prompt for sudo at the start
if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires sudo privileges. Please enter your password."
    sudo -v || { echo "Failed to obtain sudo privileges. Exiting."; exit 1; }
fi

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Ensure stow is installed
if ! command -v stow &> /dev/null; then
    echo "stow is not installed. Installing stow..."
    brew install stow
else
    echo "`stow` is already installed."
fi

# Symlink the dotfiles using `stow` 
echo "Creating symlinks using stow..."
stow .
echo "Symlinks created successfully."

# Install Homebrew packages from `Brewfile`
echo "Installing Homebrew packages from Brewfile..."
brew bundle install --file="$HOME/dotfiles/Brewfile"
echo "Homebrew packages installed successfully."

# Source the `.zshrc` file
echo "Sourcing the .zshrc file..."
source $HOME/.zshrc
echo "Sourced the .zshrc file successfully."


echo "Installing Cargo packages..."
sh scripts/cargo/packages.sh install
echo "Cargo packages installed successfully."

# Install App Store apps
echo "Installing App Store apps..."
source scripts/macos/install-app-store-apps.sh
echo "App Store apps installed successfully."

# Setup tmux
echo "Setting up tmux..."
tmux source $HOME/.tmux.conf
echo "tmux setup successfully."

# Install `tpm` plugins
echo "Installing tpm plugins..."
tmux start-server
tmux new-session -d
sh $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
echo "Installed tpm plugins successfully."

# Configure macOS defaults settings
echo "Configuring macOS defaults settings..."
source scripts/macos/defaults.sh
echo "macOS defaults settings configured successfully."