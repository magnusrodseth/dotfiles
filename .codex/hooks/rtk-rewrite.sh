#!/usr/bin/env bash

# Adapt Codex's PreToolUse protocol to RTK's command rewriter. RTK's
# `hook claude` subcommand speaks Claude Code's hook protocol and cannot return
# a usable Codex updatedInput response.

set -uo pipefail

payload="$(cat)"
command="$(jq -r '.tool_input.command // empty' <<<"$payload" 2>/dev/null)"

[ -n "$command" ] || exit 0
command -v rtk >/dev/null 2>&1 || exit 0

# RTK 0.44 uses a non-zero status to signal that it produced a rewrite, even
# though its help text still documents zero. The output is the source of truth.
rewritten="$(rtk rewrite "$command" 2>/dev/null)" || true
[ -n "$rewritten" ] || exit 0
[ "$rewritten" != "$command" ] || exit 0

jq -cn \
  --argjson input "$(jq -c '.tool_input' <<<"$payload")" \
  --arg command "$rewritten" \
  '{hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      updatedInput: ($input + {command: $command})
  }}'
