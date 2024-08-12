#!/bin/bash

# Function to handle errors
handle_error() {
	echo "❌ An error occurred: $1" >&2
	exit 1
}

# Function to perform git operations
git_operations() {
	git add . || handle_error "Failed to git add"

	# Check if there are changes to commit
	if git diff-index --quiet HEAD --; then
		echo "No changes to commit"
	else
		git commit -m "Auto-update on $(date '+%Y-%m-%d')" || handle_error "Failed to git commit"
		git push || handle_error "Failed to git push"
		echo "Git operations completed successfully"
	fi
}

# Change to the dotfiles directory
cd ~/dotfiles || handle_error "Failed to change to dotfiles directory"

# Update brew packages
echo "Updating brew packages..."
brew update || handle_error "Failed to update brew"
brew upgrade || handle_error "Failed to upgrade brew packages"

# Check if there are any changes in the Brewfile
echo "Checking for changes in Brewfile..."
if brew bundle check --file=~/dotfiles/Brewfile &>/dev/null; then
	echo "No changes in Brewfile, skipping dump"
else
	echo "Changes detected, running brew bundle dump..."
	brew bundle dump --force --file=~/dotfiles/Brewfile || handle_error "Failed to run brew bundle dump"
	git_operations
fi

# Update Neovim Mason packages
echo "Updating Neovim Mason packages..."
nvim --headless -c "MasonUpdate" -c "qa" || handle_error "Failed to update Mason packages"
git_operations

# Update Neovim Lazy packages
echo "Updating Neovim Lazy packages..."
nvim --headless -c "Lazy! sync" -c "qa" || handle_error "Failed to update Lazy packages"
git_operations

# Upgrade Oh My Posh
echo "Upgrading Oh My Posh..."
if ! oh-my-posh upgrade; then
	echo "⚠️ Failed to upgrade Oh My Posh, but continuing..."
else
	git_operations
fi

echo "All tasks completed successfully!"
