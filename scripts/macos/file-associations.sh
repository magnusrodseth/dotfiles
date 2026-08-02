#!/bin/bash

# Default applications for developer file types.
#
# macOS remembers "right-click > Get Info > Change All" in
# ~/Library/Preferences/com.apple.launchservices.secure.plist, which is a poor
# thing to track in a dotfiles repo: it is a binary plist (useless in a diff),
# it is TCC-protected (a terminal without Full Disk Access cannot even read it),
# it is owned by the `lsd` daemon, which caches it in memory and will overwrite
# a hand-edited copy, and it commingles these bindings with browser, mail and
# URL-scheme defaults that are not code-related. So this does not back that file
# up. It declares the desired extensions in file-associations.txt and applies
# them through the LaunchServices API, the same call Finder makes.
#
# Bindings are per-UTI, not per-extension, which is why file-associations.txt
# has an exclusion list: several developer extensions are squatted on by an
# unrelated type (.key is a Keynote presentation, .pub an MS Publisher
# document), and binding those would steal the real type too.
#
# Applying is silent and needs no confirmation - see the note in
# file-associations.swift about why this must keep going through /usr/bin/swift.
#
# Usage:
#   bash scripts/macos/file-associations.sh status      # drift, exit 1 if any
#   bash scripts/macos/file-associations.sh apply       # converge
#   bash scripts/macos/file-associations.sh check <ext> # explain one extension

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST="$SCRIPT_DIR/file-associations.txt"
ENGINE="$SCRIPT_DIR/file-associations.swift"

# Overridable so this is not welded to one editor.
EDITOR_BUNDLE_ID="${EDITOR_BUNDLE_ID:-dev.zed.Zed}"

main() {
  local cmd="${1:-status}"

  if ! command -v swift >/dev/null 2>&1; then
    echo "swift not found - install the Xcode command line tools:" >&2
    echo "  xcode-select --install" >&2
    return 1
  fi
  for f in "$LIST" "$ENGINE"; do
    [ -f "$f" ] || { echo "missing $f" >&2; return 1; }
  done

  case "$cmd" in
    status) swift "$ENGINE" status "$LIST" "$EDITOR_BUNDLE_ID" ;;
    apply)  swift "$ENGINE" apply  "$LIST" "$EDITOR_BUNDLE_ID" ;;
    check)
      [ $# -ge 2 ] || { echo "usage: $0 check <ext>" >&2; return 2; }
      swift "$ENGINE" check "$2"
      ;;
    *)
      echo "usage: $0 {status|apply|check <ext>}" >&2
      return 2
      ;;
  esac
}

main "$@"
