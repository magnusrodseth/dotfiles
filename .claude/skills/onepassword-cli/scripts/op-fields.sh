#!/usr/bin/env bash
# op-fields.sh — show an item's field labels, types, and op:// references with every
# value MASKED (length only). Safe to display: no secret values reach the terminal.
#
# Usage:
#   bash op-fields.sh "<item title or id>" [vault]
#   OP_ACCOUNT=my.1password.eu bash op-fields.sh "Cargo API Token" Private
#
# Defaults to the personal account if OP_ACCOUNT is unset.

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "usage: op-fields.sh \"<item>\" [vault]" >&2
  exit 2
fi

item="$1"
vault="${2:-}"
account="${OP_ACCOUNT:-my.1password.eu}"

args=(item get "$item" --account "$account" --format json)
[ -n "$vault" ] && args+=(--vault "$vault")

# One retry: the desktop-app Touch ID prompt frequently times out on first call.
json=""
for attempt in 1 2; do
  if json="$(op "${args[@]}" 2>/tmp/op-fields.err)"; then
    break
  fi
  if grep -qi 'authorization timeout' /tmp/op-fields.err && [ "$attempt" -eq 1 ]; then
    echo "Touch ID timed out, retrying — approve the prompt..." >&2
    continue
  fi
  echo "op failed:" >&2
  cat /tmp/op-fields.err >&2
  rm -f /tmp/op-fields.err
  exit 1
done
rm -f /tmp/op-fields.err

printf '%s' "$json" | python3 - <<'PY'
import json, sys
d = json.load(sys.stdin)
print(f"title:    {d.get('title')}")
print(f"category: {d.get('category')}   vault: {d.get('vault', {}).get('name')}   id: {d.get('id')}")
print("fields (values masked):")
for f in d.get("fields", []):
    v = f.get("value")
    mask = f"<{len(v)} chars>" if v else "(empty)"
    label = str(f.get("label"))
    ftype = str(f.get("type"))
    ref = f.get("reference", "")
    print(f"  {label:<22} {ftype:<10} {mask:<12} {ref}")
PY
