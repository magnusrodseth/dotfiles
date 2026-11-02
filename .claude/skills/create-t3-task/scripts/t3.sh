#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${T3_CLI_BIN:-}" ]]; then
  t3_cli="$T3_CLI_BIN"
elif [[ -x "${T3CODE_HOME:-$HOME/.t3}/bin/t3" ]]; then
  t3_cli="${T3CODE_HOME:-$HOME/.t3}/bin/t3"
elif command -v t3 >/dev/null 2>&1; then
  t3_cli="$(command -v t3)"
else
  echo "T3 CLI not found. Open T3 Code once or install its official CLI." >&2
  exit 127
fi

if [[ ! -x "$t3_cli" ]]; then
  echo "Selected T3 CLI is not executable: $t3_cli" >&2
  exit 127
fi

exec "$t3_cli" "$@"
