#!/bin/sh

FILENAME="com.local.KeyRemapping"

# Check if the com.local.KeyRemapping.plist file exists
if [ ! -f "$HOME/Library/LaunchAgents/$FILENAME.plist" ]; then
  echo "Error: The KeyRemapping configuration file does not exist."
  exit 1
fi

# Make sure the config is unloaded first
launchctl unload "$HOME/Library/LaunchAgents/$FILENAME.plist"

# Then load the config
launchctl load "$HOME/Library/LaunchAgents/$FILENAME.plist"

# Check that the config was loaded
if ! launchctl list | grep "$FILENAME"; then
  echo "Error: The KeyRemapping configuration was not loaded."
  exit 1
else
  echo "KeyRemapping configuration loaded successfully."
fi

# Start the remapping on system startup
launchctl start "$FILENAME.plist"
