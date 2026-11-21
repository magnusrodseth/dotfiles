#!/usr/bin/env bash
#
# Entry point for the security watch. Read-only: it reports, it never upgrades.
# Usage: bash ~/dotfiles/scripts/security-watch/run.sh [--weekly] [--no-news] [--no-macos] [--dry-run]
#
# Runs from T3 at 09:00 on weekdays; see CLAUDE.md ("Security watch").

set -euo pipefail

# Invoked from a non-interactive shell, so put the tools it needs on PATH.
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

export PYTHONDONTWRITEBYTECODE=1

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for tool in python3 osv-scanner git claude; do
	command -v "$tool" >/dev/null || { echo "security-watch: missing $tool" >&2; exit 1; }
done
if ! python3 -c 'import sys; sys.exit(sys.version_info < (3, 11))'; then
	echo "security-watch: needs python3 >= 3.11 (tomllib)" >&2
	exit 1
fi
exec python3 "$dir/security_watch.py" "$@"
