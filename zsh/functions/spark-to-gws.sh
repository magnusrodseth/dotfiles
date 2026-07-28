#!/bin/zsh

# Bridge from Spark (the client I read email in) to gws (the one that can
# actually do things). Cmd+L in Spark copies a deep link; this turns it into a
# Gmail message id.
#
# The link carries Gmail's own message id as a decimal in its gID field, so it
# is a straight int -> hex conversion to get what the Gmail API wants. No
# search, no guessing. See scripts/spark/spark-to-gws.sh for the format.
#
#   sg          # read the link straight off the clipboard
#   sg --id     # just the id, for piping into other gws calls
#   sg "<link>" # or pass one explicitly

function sg() {
  local script="$HOME/dotfiles/scripts/spark/spark-to-gws.sh"
  if [[ ! -f "$script" ]]; then
    print -u2 "sg: $script not found"
    return 1
  fi
  bash "$script" "$@"
}

# Longer alias, for when `sg` is not obvious months from now.
function spark-to-gws() { sg "$@" }
