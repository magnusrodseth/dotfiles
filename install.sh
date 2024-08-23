#!/bin/sh


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
    echo "`stow` is not installed. Installing `stow`..."
    brew install stow
else
    echo "`stow` is already installed."
fi

# Symlink the dotfiles using `stow` 
echo "Creating symlinks using `stow`..."
stow .
echo "Symlinks created successfully."

# Install Homebrew packages from `Brewfile`
echo "Installing Homebrew packages from `Brewfile`..."
brew bundle install --file=~/dotfiles/Brewfile
echo "Homebrew packages installed successfully."

echo "Updating the path for tmux in the alacritty configuration file based on architecture..."

# Determine the correct path for tmux based on architecture
if [ "$(uname -m)" = "arm64" ]; then
    TMUX_PATH="/opt/homebrew/bin/tmux"
else
    TMUX_PATH="/usr/local/bin/tmux"
fi

# Updating the `alacritty.toml` with the correct path for tmux
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
TEMP_CONF="$HOME/.config/alacritty/alacritty_temp.toml"

# Make a copy of the configuration file
cp "$ALACRITTY_CONF" "$TEMP_CONF"

# Replace the tmux path in the configuration file
sed -i.bak "s|/usr/local/bin/tmux|$TMUX_PATH|g" "$TEMP_CONF"
mv "$TEMP_CONF" "$ALACRITTY_CONF"

# Remove the backup file created by sed
rm -f "$TEMP_CONF.bak"

echo "Path updated successfully."


# Source the `.zshrc` file
echo "Sourcing the .zshrc file..."
source $HOME/.zshrc
echo "Sourced the .zshrc file successfully."

# Configure macOS defaults settings
echo "Configuring macOS defaults settings..."
source scripts/macos/defaults.sh
echo "macOS defaults settings configured successfully."

echo "Installing Cargo packages..."
sh scripts/cargo/packages.sh install
echo "Cargo packages installed successfully."

# Install App Store apps
echo "Installing App Store apps..."
source scripts/macos/install-app-store-apps.sh
echo "App Store apps installed successfully."

# Mapping ESC to CAPS
echo "Mapping ESC to CAPS on the Mac machine..."
source scripts/macos/map-esc-to-caps.sh
echo "Mapped ESC to CAPS successfully."

# Ensure crontabs are installed
echo "Installing crontabs..."
sudo crontab ~/dotfiles/cron/$(whoami).crontab
echo "Crontabs installed successfully."

# Setup tmux
echo "Setting up tmux..."
tmux source $HOME/.tmux.conf
echo "Tmux setup successfully."

# Install `tpm` plugins
echo "Installing `tpm` plugins..."
tmux start-server
tmux new-session -d
sh $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
tmux kill-server
echo "Installed `tpm` plugins successfully."
