#!/bin/zsh

# Move a file or directory into its mirrored location in $HOME/dotfiles, then
# stow it back so the original path becomes a symlink into the repo.
#
# Three bugs this version fixes:
#   - A relative argument was never resolved, so `move-to-dotfiles foo.json` run
#     from ~/.config/zed wrote to ~/dotfiles/foo.json rather than
#     ~/dotfiles/.config/zed/foo.json, silently and with no error.
#   - A path outside $HOME produced a destination built from the full absolute
#     path, e.g. ~/dotfiles/etc/hosts.
#   - `mv` overwrote an existing destination without asking.
# It also no longer changes your current directory as a side effect.
move-to-dotfiles() {
  if [ $# -eq 0 ]; then
    echo "Usage: move-to-dotfiles <file_or_directory>"
    return 1
  fi

  local dest_dir="$HOME/dotfiles"
  local src_path abs_path relative_path dest_path

  src_path="$1"

  if [ ! -e "$src_path" ]; then
    echo "Error: $src_path does not exist." >&2
    return 1
  fi

  # Resolve to an absolute path without resolving the final component, so a
  # symlink argument is reported as such below rather than followed.
  abs_path="$(cd "$(dirname "$src_path")" && pwd)/$(basename "$src_path")"

  case "$abs_path" in
    "$dest_dir"/*)
      echo "Error: $abs_path is already inside $dest_dir." >&2
      return 1
      ;;
    "$HOME"/*)
      relative_path="${abs_path#$HOME/}"
      ;;
    *)
      echo "Error: $abs_path is outside \$HOME; stow can only mirror paths under it." >&2
      return 1
      ;;
  esac

  dest_path="$dest_dir/$relative_path"

  if [ -L "$abs_path" ]; then
    echo "Error: $abs_path is already a symlink (probably already stowed)." >&2
    return 1
  fi

  if [ -e "$dest_path" ]; then
    echo "Error: $dest_path already exists. Move or remove it first." >&2
    return 1
  fi

  mkdir -p "$(dirname "$dest_path")" || return 1
  mv "$abs_path" "$dest_path" || return 1
  echo "Moved to $dest_path"

  (cd "$dest_dir" && stow .) || {
    echo "Warning: stow failed; the file now exists only at $dest_path." >&2
    return 1
  }
  echo "Stowed. $abs_path is now a symlink."
}
