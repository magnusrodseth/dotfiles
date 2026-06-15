#!/usr/bin/env bash
# Validate a dotfiles config file, auto-detecting format by path/extension.
# Best-effort lint: validates known formats, warns (does not fail) on unknown ones.
# Usage: bash validate-config.sh <path-to-config-file>
set -uo pipefail

file="${1:-}"
if [[ -z "$file" ]]; then
  echo "usage: validate-config.sh <config-file>" >&2
  exit 2
fi
if [[ ! -f "$file" ]]; then
  echo "✗ not a file: $file" >&2
  exit 2
fi

base="$(basename "$file")"
ext="${file##*.}"

fail() { echo "✗ $1"; exit 1; }
ok()   { echo "✓ $1"; exit 0; }
skip() { echo "• $1 (no validator available — verify manually)"; exit 0; }

case "$file/$base/$ext" in
  # ---- JSONC: Zed and any .json under a config dir (comments + trailing commas allowed)
  *.json/*/*)
    command -v node >/dev/null 2>&1 || skip "JSONC ($base): node not found"
    node -e '
      const fs = require("fs");
      let s = fs.readFileSync(process.argv[1], "utf8");
      s = s.replace(/\/\*[\s\S]*?\*\//g, "");   // block comments
      s = s.replace(/(^|[^:])\/\/.*$/gm, "$1");  // line comments (keep http://)
      s = s.replace(/,(\s*[}\]])/g, "$1");       // trailing commas
      try { JSON.parse(s); }
      catch (e) { console.error(e.message); process.exit(1); }
    ' "$file" && ok "JSONC valid: $base" || fail "JSONC parse error: $base"
    ;;

  # ---- TOML: Yazi etc.
  *.toml/*/*)
    command -v python3 >/dev/null 2>&1 || skip "TOML ($base): python3 not found"
    python3 -c 'import tomllib,sys; tomllib.load(open(sys.argv[1],"rb"))' "$file" \
      && ok "TOML valid: $base" || fail "TOML parse error: $base"
    ;;

  # ---- Lua: Neovim
  *.lua/*/*)
    if command -v luac >/dev/null 2>&1; then
      luac -p "$file" && ok "Lua parses: $base" || fail "Lua syntax error: $base"
    elif command -v luacheck >/dev/null 2>&1; then
      luacheck --no-color "$file" && ok "Lua OK: $base" || fail "Lua lint error: $base"
    else
      skip "Lua ($base): no luac/luacheck"
    fi
    ;;

  # ---- YAML: lazygit etc.
  *.yml/*/*|*.yaml/*/*)
    if command -v python3 >/dev/null 2>&1; then
      python3 -c 'import yaml,sys; yaml.safe_load(open(sys.argv[1]))' "$file" 2>/dev/null \
        && ok "YAML valid: $base" || skip "YAML ($base): pyyaml not available"
    else
      skip "YAML ($base): no validator"
    fi
    ;;

  # ---- Ghostty: custom key=value; validate via ghostty if present
  */config/config|*/ghostty/*)
    if command -v ghostty >/dev/null 2>&1; then
      # ghostty exits non-zero and prints diagnostics on a bad config
      ghostty +show-config --config-file="$file" >/dev/null 2>&1 \
        && ok "Ghostty config loads: $base" || fail "Ghostty config error: $base"
    else
      skip "Ghostty ($base): ghostty CLI not found"
    fi
    ;;

  *)
    skip "unknown format: $base"
    ;;
esac
