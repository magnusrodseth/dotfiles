# Mac OS backups

```sh
# Add symlink
ln -s $HOME/dotfiles/macos/com.local.KeyRemapping.plist ~/Library/LaunchAgents/com.local.KeyRemapping.plist

# Make sure the config is unloaded first
launchctl unload ~/Library/LaunchAgents/com.local.KeyRemapping.plist

# Then load the config
launchctl load ~/Library/LaunchAgents/com.local.KeyRemapping.plist

# Check this the config was loaded
launchctl list | grep local

# Start the remapping on system startup
launchctl start com.local.KeyRemapping.plist
```

**Now, restart the system, and CAPS LOCK should be mapped to ESC.**
