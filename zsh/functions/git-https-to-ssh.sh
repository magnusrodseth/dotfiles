#!/bin/zsh

git-https-to-ssh() {
  if [ ! -d .git ]; then
    echo "This is not a Git repository."
    return 1
  fi

  local remote_name="origin"
  local current_url=$(git remote get-url $remote_name)

  if [[ $current_url != https://* ]]; then
    echo "Current remote is not using HTTPS: $current_url"
    return 1
  fi

  # Extract the repository path
  local repo_path=$(echo $current_url | sed -e 's/^https:\/\/github.com\///')

  # Set the new SSH remote URL
  local ssh_url="git@github.com:${repo_path}"

  git remote set-url $remote_name $ssh_url

  echo "Remote URL updated to SSH: $ssh_url"
}
