#!/usr/bin/env bash
# op-open.sh — open an item in the 1Password desktop app (macOS) via deep link.
# Resolves UUIDs only; no secret values are read or printed. Useful when the user
# must view/edit an item in the GUI themselves (e.g. paste a secret you must not handle).
#
# Usage:
#   bash op-open.sh "<item title or id>" [vault] [view|edit]
#   OP_ACCOUNT=my.1password.eu bash op-open.sh "github-readme-stats PAT" Development edit
#
# Defaults: personal account (OP_ACCOUNT or my.1password.eu), action "view".

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "usage: op-open.sh \"<item>\" [vault] [view|edit]" >&2
  exit 2
fi

item="$1"
vault="${2:-}"
action="${3:-view}"
account="${OP_ACCOUNT:-my.1password.eu}"

case "$action" in
  view) verb="view-item" ;;
  edit) verb="edit-item" ;;
  *) echo "action must be 'view' or 'edit'" >&2; exit 2 ;;
esac

# Account UUID for the deep link's a= param (match by sign-in address).
account_uuid="$(op account list --format=json | python3 -c "
import sys, json
addr = '$account'
for a in json.load(sys.stdin):
    if a.get('url') == addr:
        print(a['account_uuid']); break
")"
if [ -z "$account_uuid" ]; then
  echo "no account matching $account" >&2; exit 1
fi

# Item + vault UUIDs (one Touch ID retry, like op-fields.sh).
args=(item get "$item" --account "$account" --format json)
[ -n "$vault" ] && args+=(--vault "$vault")
json=""
for attempt in 1 2; do
  if json="$(op "${args[@]}" 2>/tmp/op-open.err)"; then break; fi
  if grep -qi 'authorization timeout' /tmp/op-open.err && [ "$attempt" -eq 1 ]; then
    echo "Touch ID timed out, retrying — approve the prompt..." >&2; continue
  fi
  cat /tmp/op-open.err >&2; rm -f /tmp/op-open.err; exit 1
done
rm -f /tmp/op-open.err

read -r vault_uuid item_uuid < <(printf '%s' "$json" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d['vault']['id'], d['id'])
")

deeplink="onepassword://${verb}/?a=${account_uuid}&v=${vault_uuid}&i=${item_uuid}"
echo "$deeplink"
open "$deeplink"
