#!/usr/bin/env bash

# Codex Stop hooks must return JSON to affect control flow. Block the first stop
# once so the agent checks completion, then allow the second stop to avoid a
# loop. Sound playback is best-effort and never delays the hook response.

set -uo pipefail

payload="$(cat)"
(afplay /System/Library/Sounds/Bottle.aiff >/dev/null 2>&1 &) || true

if jq -e '.stop_hook_active == true' <<<"$payload" >/dev/null 2>&1; then
  printf '%s\n' '{"continue":true}'
  exit 0
fi

jq -cn '{
  decision: "block",
  reason: "Before ending, verify that the original request is complete, every relevant check passes, and no todo remains. Continue working if any part is incomplete."
}'
