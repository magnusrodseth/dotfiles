#!/bin/bash
#
# Install Mac App Store apps declared below.
#
# Two things here are deliberate, both learned the hard way:
#
# 1. App IDs are pinned, not scraped. The previous version derived the ID with
#    `mas search "$name" | awk '{print $1; exit}'`, which yields the first word
#    of whatever mas printed. On a failed search (offline, not signed in, app
#    renamed) that is "No", so the script ran `mas install No` and reported
#    success.
#
# 2. Idempotency is decided by the app bundle, not by `mas list`. On current
#    macOS `mas list` reports "No installed apps found" even with 64 apps in
#    /Applications, and `mas install` on an already-installed app fails with
#    "Download failed: The installation could not be started". Gating on either
#    of those turns a fully-provisioned machine into a failing step.
#
# Honest by contract: install.sh's run_step needs a real exit status, so a
# genuine failure is collected and the script exits non-zero listing what failed.

set -uo pipefail

# "<app-store-id>|<app bundle name in /Applications>|<human name>"
APPS=(
  "1355679052|Dropover.app|Dropover - Easier Drag & Drop"
)

if ! command -v mas >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "mas is not installed. Installing with Homebrew..."
    brew install mas || { echo "Error: failed to install mas." >&2; exit 1; }
  else
    echo "Error: neither mas nor Homebrew is installed." >&2
    exit 1
  fi
fi

failures=()
installed=0
skipped=0

for entry in "${APPS[@]}"; do
  app_id="${entry%%|*}"
  rest="${entry#*|}"
  bundle="${rest%%|*}"
  app_name="${rest#*|}"

  case "$app_id" in
    '' | *[!0-9]*)
      echo "Skipping '$app_name': '$app_id' is not a numeric App Store id." >&2
      failures+=("$app_name (bad id)")
      continue
      ;;
  esac

  if [ -d "/Applications/$bundle" ]; then
    echo "==> $app_name: already installed"
    skipped=$((skipped + 1))
    continue
  fi

  echo "==> $app_name ($app_id)"
  if mas install "$app_id"; then
    installed=$((installed + 1))
  else
    echo "    failed: $app_name" >&2
    failures+=("$app_name")
  fi
done

if ((${#failures[@]} > 0)); then
  echo >&2
  echo "App Store install completed with ${#failures[@]} failure(s):" >&2
  printf '  - %s\n' "${failures[@]}" >&2
  echo "If these are purchase/sign-in errors, open App Store, sign in, retry." >&2
  exit 1
fi

echo "App Store apps: $installed installed, $skipped already present."
