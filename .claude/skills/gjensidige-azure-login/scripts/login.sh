#!/usr/bin/env bash

set -euo pipefail

tenant_id="80184e22-072c-440e-a8a9-22f52b82646d"
edge_app="/Applications/Microsoft Edge.app"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This login helper requires macOS." >&2
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI is not installed or is not on PATH." >&2
  exit 1
fi

if [[ ! -d "$edge_app" ]]; then
  echo "Microsoft Edge is not installed at $edge_app." >&2
  exit 1
fi

login_args=(login --tenant "$tenant_id")
if [[ -n "${1:-}" ]]; then
  login_args+=(--subscription "$1")
fi

export BROWSER='open -a "Microsoft Edge" %s'
exec az "${login_args[@]}"
