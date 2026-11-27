#!/usr/bin/env bash
#
# install.sh - CLIs that no package list in this repo declares.
#
# Each one ships its own installer, or comes from `uv tool`. A tool that is
# already on PATH is left alone, so the script is idempotent; pass --force to
# reinstall all of them. The curl installers write to ~/.local/bin, which
# .zshenv and install.sh's bootstrap_env() put first on PATH.
#
#   claude        Claude Code CLI, native installer. The Brewfile's
#                 `cask "claude"` is the desktop app, not this CLI.
#   ntn           Notion CLI (ntn.dev).
#   basedpyright  Python LSP, as a uv tool.
#
# beautify-screenshot is not here: scripts/npm/npm_packages.txt installs it.
#
# Usage: install.sh [--force]

set -uo pipefail

force=0
case "${1-}" in
  "") ;;
  --force) force=1 ;;
  *) sed -n 's/^# Usage: //p' "$0"; exit 2 ;;
esac

export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.local/bin"
failed=()

have() { [ "$force" -eq 0 ] && command -v "$1" >/dev/null 2>&1; }

# curl_install <command> <url> [env assignment...]
curl_install() {
  local cmd="$1" url="$2"; shift 2
  if have "$cmd"; then
    echo "ok      $cmd"
    return 0
  fi
  if curl -fsSL "$url" | env "$@" bash; then
    echo "added   $cmd"
  else
    echo "FAILED  $cmd" >&2
    failed+=("$cmd")
  fi
}

curl_install claude https://claude.ai/install.sh
curl_install ntn https://ntn.dev NTN_INSTALL_DIR="$HOME/.local/bin"

UV_TOOLS=(basedpyright)
uv_flags=()
[ "$force" -eq 1 ] && uv_flags=(--force)
if ! command -v uv >/dev/null 2>&1; then
  echo "FAILED  uv tools: uv is not installed (it comes from the Brewfile)" >&2
  failed+=("uv tools")
else
  installed="$(uv tool list 2>/dev/null | awk '/^[^ -]/ {print $1}')"
  for t in "${UV_TOOLS[@]}"; do
    if [ "$force" -eq 0 ] && printf '%s\n' "$installed" | grep -qx "$t"; then
      echo "ok      $t (uv tool)"
    elif uv tool install ${uv_flags[@]+"${uv_flags[@]}"} "$t" >/dev/null; then
      echo "added   $t (uv tool)"
    else
      echo "FAILED  $t (uv tool)" >&2
      failed+=("$t")
    fi
  done
fi

if [ ${#failed[@]} -gt 0 ]; then
  echo "Standalone CLIs not installed: ${failed[*]}" >&2
  exit 1
fi
