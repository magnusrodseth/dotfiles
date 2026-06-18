#!/bin/zsh
# .zshenv: env vars + PATH for ALL shells (interactive, non-interactive, scripts).
# Keep this fast: no subprocess spawns beyond brew shellenv.

# Homebrew (must come first so subsequent which lookups work)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Locale & XDG
export LC_ALL=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"

# Default editor (used by git, scripts, etc.)
export EDITOR="zed -w"
export VISUAL="$EDITOR"

# Java
export JAVA_HOME="/opt/homebrew/opt/openjdk@21"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"

# 1Password / SpareBank1 CLI: default to the personal account (two accounts registered)
export OP_ACCOUNT=my.1password.eu
export SB1_STORE=op
export SB1_OP_ACCOUNT=my.1password.eu

# Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Local bin env (uv installer, etc.)
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# PATH (single consolidated assignment; later entries win on collision via case check)
typeset -U path PATH  # dedupe
path=(
  "$HOME/.local/bin"
  "$HOME/.codeium/windsurf/bin"
  "$HOME/.antigravity/antigravity/bin"
  "$PNPM_HOME"
  "$HOME/.bun/bin"
  "$HOME/.deno/bin"
  "$HOME/.cargo/bin"
  "$HOME/.dotnet/tools"
  "$JAVA_HOME/bin"
  "$ANDROID_HOME/platform-tools"
  "/Library/TeX/texbin"
  "$HOME/.cache/lm-studio/bin"
  $path
)
export PATH
