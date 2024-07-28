#!/bin/sh

# Add symlink for KeyRemapping
ln -s "$HOME/dotfiles/macos/com.local.KeyRemapping.plist" "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist" 

# Make sure the config is unloaded first
launchctl unload "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist"

# Then load the config
launchctl load "$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist"

# Check that the config was loaded
if ! launchctl list | grep -q "com.local.KeyRemapping"; then
    echo "Error: The KeyRemapping configuration was not loaded."
    exit 1
else
    echo "KeyRemapping configuration loaded successfully."
fi

# Start the remapping on system startup
launchctl start com.local.KeyRemapping.plist