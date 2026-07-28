#!/bin/bash
#
# macOS system defaults.
#
# install.sh's run_step reports whatever this script exits with, and until
# 28.07.2026 that was always the status of the last `echo`, so a rejected
# `defaults write` (wrong type, renamed key, missing TCC permission) was
# reported as "ok". The wrapper below shadows the `defaults` builtin lookup for
# all 22 call sites at once, counts real failures, and main() exits non-zero.
# Do not rename it, and do not call /usr/bin/defaults directly below.

DEFAULTS_FAILURES=()

defaults() {
  if ! /usr/bin/defaults "$@"; then
    DEFAULTS_FAILURES+=("defaults $*")
    return 1
  fi
}

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

    echo "Global settings configured."
}

# Function to apply Dock settings
configure_dock() {
    echo "Configuring Dock settings..."

    # Put the Dock on the bottom of the screen
    defaults write com.apple.dock "orientation" -string "bottom"

    # Set Dock tile size and magnification
    defaults write com.apple.dock tilesize -int 42
    defaults write com.apple.dock largesize -int 52

    # Auto-hide the Dock
    defaults write com.apple.dock autohide -bool true

    # Remove the autohide delay, the Dock appears instantly
    defaults write com.apple.dock "autohide-delay" -float "0"

    # Do not display recent apps in the Dock
    defaults write com.apple.dock "show-recents" -bool "false"

    # Set animation effect to 'scale'
    defaults write com.apple.dock "mineffect" -string "scale"

    # Apply the changes
    killall Dock

    echo "Dock settings configured."
}

configure_window_manager() {
    echo "Configuring window manager settings..."

    # Do nothing when clicking wallpaper in desktop
    defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

    killall WindowManager

    echo "Window manager settings configured."
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

configure_mouse() {
    echo "Configuring mouse settings..."

    # Set mouse speed to the 4th slowest
    defaults write NSGlobalDomain com.apple.mouse.scaling -float "0.6875"

    echo "Mouse settings configured."
}

configure_keyboard() {
    echo "Configuring keyboard settings..."

    # Repeats the key as long as it is held down, and quickly
    defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool "false"
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

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
    configure_mouse
    configure_window_manager
    configure_keyboard
    configure_mission_control
    configure_screensaver

    if [ "${#DEFAULTS_FAILURES[@]}" -gt 0 ]; then
        echo "" >&2
        echo "❌ ${#DEFAULTS_FAILURES[@]} setting(s) failed to apply:" >&2
        printf '  - %s\n' "${DEFAULTS_FAILURES[@]}" >&2
        return 1
    fi

    echo "✅ macOS configuration completed."
    echo "ℹ️ Some changes may require a restart to take effect."
}

# Run the main function
main
