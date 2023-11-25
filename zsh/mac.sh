#!/bin/zsh

# Define the paths
source_path='~/dev/dotfiles/macos/com.local.KeyRemapping.plist'
destination_path='~/Library/LaunchAgents/com.local.KeyRemapping.plist'

# Expand the tilde in paths
eval expanded_source_path=$source_path
eval expanded_destination_path=$destination_path

# Check if the symlink already exists
if [[ ! -L $expanded_destination_path ]]; then
    # Add symlink if it does not exist
    ln -s "$expanded_source_path" "$expanded_destination_path"
else
    echo "Symlink already exists. Skipping..."
fi

# Make sure the config is unloaded first
launchctl unload "$expanded_destination_path"

# Then load the config
launchctl load "$expanded_destination_path"

# Check that the config was loaded
launchctl list | grep local

# Start the remapping on system startup
launchctl start com.local.KeyRemapping.plist
