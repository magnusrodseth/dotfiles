#!/usr/bin/env bash
#
# mcp-servers.sh - declare Claude Code's user-scoped MCP servers.
#
# `claude mcp add --scope user` writes to ~/.claude.json, which is machine
# state (sessions, project trust, OAuth caches) and is not tracked. Without this
# script the servers existed only on the machine they were added on.
#
# Idempotent: a server that already exists is left alone. Pass --force to
# remove and re-add every server, for example after the Exa key rotates.
#
# Secrets are read from the personal 1Password account at run time and never
# written to this repo. OAuth servers (vercel, askable-labs) still need one
# sign-in per machine through /mcp in an interactive session. linkedin keeps
# its own browser session in ~/.linkedin-mcp and asks for a login on first use.
#
# Usage: mcp-servers.sh [--force] [--dry-run]

set -uo pipefail

OP_ACCOUNT="${OP_ACCOUNT:-my.1password.eu}"
EXA_KEY_REF="op://Private/Exa API Key/credential"

force=0
dry=0
for arg in "$@"; do
  case "$arg" in
    --force) force=1 ;;
    --dry-run) dry=1 ;;
    *) sed -n 's/^# Usage: //p' "$0"; exit 2 ;;
  esac
done

if ! command -v claude >/dev/null 2>&1; then
  echo "claude is not installed; skipping MCP servers." >&2
  exit 1
fi

failed=()

exists() { claude mcp get "$1" >/dev/null 2>&1; }

# ensure <name> <claude mcp add arguments after the scope>...
ensure() {
  local name="$1"; shift
  if exists "$name"; then
    if [ "$force" -eq 0 ]; then
      echo "ok      $name (already configured)"
      return 0
    fi
    [ "$dry" -eq 1 ] || claude mcp remove --scope user "$name" >/dev/null 2>&1
  fi
  if [ "$dry" -eq 1 ]; then
    echo "would   add $name"
    return 0
  fi
  if claude mcp add --scope user "$@" >/dev/null; then
    echo "added   $name"
  else
    echo "FAILED  $name" >&2
    failed+=("$name")
  fi
}

ensure vercel --transport http vercel https://mcp.vercel.com
ensure askable-labs --transport http askable-labs https://spark.platform.askable.com/mcp/participant
ensure linkedin linkedin -- uvx mcp-server-linkedin@latest

if exists exa && [ "$force" -eq 0 ]; then
  echo "ok      exa (already configured)"
elif [ "$dry" -eq 1 ]; then
  echo "would   add exa (key from $EXA_KEY_REF)"
elif exa_key="$(op read "$EXA_KEY_REF" --account "$OP_ACCOUNT" 2>/dev/null)" && [ -n "$exa_key" ]; then
  ensure exa --transport http exa https://mcp.exa.ai/mcp --header "x-api-key: $exa_key"
  unset exa_key
else
  echo "FAILED  exa: could not read $EXA_KEY_REF (sign in with: op signin --account $OP_ACCOUNT)" >&2
  failed+=("exa")
fi

if [ ${#failed[@]} -gt 0 ]; then
  echo "MCP servers not configured: ${failed[*]}" >&2
  exit 1
fi
