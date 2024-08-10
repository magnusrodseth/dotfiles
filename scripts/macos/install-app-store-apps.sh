#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install mas using Homebrew
install_mas() {
    if command_exists brew; then
        echo "Installing mas using Homebrew..."
        brew install mas
    else
        echo "Error: Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
}

# Function to search for an app and get its ID
get_app_id() {
    local app_name="$1"
    local search_result=$(mas search "$app_name")
    local app_id=$(echo "$search_result" | awk '{print $1; exit}')
    echo "$app_id"
}

# Function to install an app given its ID
install_app() {
    local app_id="$1"
    local app_name="$2"
    if [ -n "$app_id" ]; then
        echo "Installing $app_name (ID: $app_id)"
        mas install "$app_id"
    else
        echo "No app ID found for $app_name. Installation aborted."
    fi
}

# Check if mas is installed, if not, install it
if ! command_exists mas; then
    echo "mas is not installed. Attempting to install..."
    install_mas

    # Check again if mas was successfully installed
    if ! command_exists mas; then
        echo "Failed to install mas. Please install it manually and run this script again."
        exit 1
    fi
fi

# Array of app names to install
APP_NAMES=(
    "Dropover - Easier Drag & Drop"
    # Add more app names here
)

# Main script
for APP_NAME in "${APP_NAMES[@]}"; do
    echo "Processing: $APP_NAME"
    APP_ID=$(get_app_id "$APP_NAME")
    if [ -n "$APP_ID" ]; then
        echo "Found app ID '$APP_ID' with name '$APP_NAME'"
        install_app "$APP_ID" "$APP_NAME"
    else
        echo "Could not find the app: $APP_NAME"
    fi
    echo "-----------------------------------"
done
