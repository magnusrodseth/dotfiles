#!/bin/bash

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

configure_global() {
    echo "Configuring global settings..."

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "

    # Restart automatically on power loss
    sudo pmset -a autorestart 1

    # Restart automatically if the computer freezes
    sudo systemsetup -setrestartfreeze on

    echo "Global settings configured."
}

# Function to apply Dock settings
configure_dock() {
    echo "Configuring Dock settings..."

    # Set Dock tile size
    defaults write com.apple.dock tilesize -int 42

    # Auto-hide the Dock
    defaults write com.apple.dock autohide -bool true

    # Do not display recent apps in the Dock
    defaults write com.apple.dock "show-recents" -bool "false"

    # Set animation effect to 'scale'
    defaults write com.apple.dock "mineffect" -string "scale"

    # Apply the changes
    killall Dock

    echo "Dock settings configured."
}

configure_finder() {
    echo "Configuring Finder settings..."

    # Show path bar
    defaults write com.apple.finder "ShowPathbar" -bool "true"

    # Default view style to column view
    defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv"

    # Apply changes
    killall Finder

    echo "Finder settings configured."
}

configure_menu_bar() {
    echo "Configuring menu bar settings..."

    # Set date format like "Thu 18 Aug 21:46"
    defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm\""

    # Apply changes
    killall SystemUIServer

    echo "Menu bar settings configured."
}

configure_keyboard() {
    echo "Configuring keyboard settings..."

    # Repeats the key as long as it is held down, and very quickly
    defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool "false"
    defaults write NSGlobalDomain KeyRepeat -int 6
    defaults write NSGlobalDomain InitialKeyRepeat -int 25

    echo "Keyboard settings configured."
}

configure_trackpad() {
    echo "Configuring trackpad settings..."

    # Trackpad: map bottom right corner to right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

    echo "Trackpad settings configured."
}

configure_mission_control() {
    echo "Configuring Mission Control settings..."

    # Group windows by application
    defaults write com.apple.dock "expose-group-apps" -bool "true"

    killall Dock

    echo "Mission Control settings configured."
}

configure_screensaver() {
    echo "Configuring screensaver settings..."

    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    echo "Screensaver settings configured."
}

# Main script execution
main() {
    echo "Starting macOS configuration..."

    configure_global
    configure_dock
    configure_finder
    configure_menu_bar
    configure_keyboard
    configure_mission_control
    configure_screensaver

    echo "✅ macOS configuration completed."
    echo "ℹ️ Some changes may require a restart to take effect."
}

# Run the main function
main
