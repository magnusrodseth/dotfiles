#!/bin/zsh

# Converts a human-readable query into a shell command using SGPT, shows the command, and prompts for execution confirmation.
function cmdfinder() {
  local query="$*"
  # Use sgpt to generate a shell command based on the human-readable query
  local generated_command=$(sgpt sh -m "gpt-4o" "$query")

  # Print the generated command and ask for confirmation before running it
  echo "Suggested command: $generated_command"
  echo -n "Do you want to execute this command? (Y/n) "
  read confirmation

  if [[ "$confirmation" =~ ^[Yy]$ ]]; then
    # Execute the generated command
    eval "$generated_command"
  else
    echo "Command execution canceled."
  fi
}
