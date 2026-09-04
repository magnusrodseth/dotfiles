#!/usr/bin/env bash

# Keep machine and app state in ~/.codex/config.toml, while applying the tracked,
# secret-free settings shared by Codex CLI and ChatGPT Desktop. Codex 0.153.2
# removed the legacy global profile selector, and Desktop cannot pass
# `--profile`, so the tracked file is merged into the shared base config.

set -euo pipefail

config="$HOME/.codex/config.toml"
profile="$HOME/.codex/personal.config.toml"

if [ ! -e "$profile" ]; then
  echo "$profile is missing. Run 'stow --restow .' first." >&2
  exit 1
fi

mkdir -p "$HOME/.codex"
touch "$config"
chmod 600 "$config"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

awk '/^\[/ { exit } { print }' "$profile" >"$tmp"

awk '
BEGIN { skip = 0; in_section = 0; managed = 0 }

/^# BEGIN dotfiles Codex settings$/ { managed = 1; next }
/^# END dotfiles Codex settings$/ { managed = 0; next }
managed { next }

/^\[/ {
  in_section = 1
  section = $0
  skip = 0

  if (section == "[features]" ||
      section ~ /^\[shell_environment_policy([.]|\])/) {
    skip = 1
  }

  if (section ~ /^\[mcp_servers[.](app-insight-mcp|aso-mcp|mcp-domain-availability|atlassian|context7|1password|exa|grep_app|kokoro-tts|linkedin|nano-banana|posthog|stitch)([.]|\])/) {
    skip = 1
  }
}

!in_section && /^[[:space:]]*(profile|model|model_reasoning_effort|model_context_window|model_auto_compact_token_limit)[[:space:]]*=/ { next }
skip { next }
{ print }
' "$config" >>"$tmp"

printf '\n# BEGIN dotfiles Codex settings\n' >>"$tmp"
awk 'seen || /^\[/ { seen = 1; print }' "$profile" >>"$tmp"
printf '# END dotfiles Codex settings\n' >>"$tmp"

chmod 600 "$tmp"
mv "$tmp" "$config"
trap - EXIT

echo "Tracked Codex settings applied and base config sanitized: $config"
