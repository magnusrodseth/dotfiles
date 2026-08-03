#!/usr/bin/env bash
#
# Keep Pi's installed packages current, out of band from interactive startup.
#
# Interactive Pi runs with PI_OFFLINE=1 (see zsh/functions/pi.sh), which makes
# launching instant but also means nothing checks for package updates in the
# startup path. This script is what keeps them fresh: it runs at login and once
# daily from com.magnusrodseth.pi-extension-update.
#
# Failures are deliberately left in the log rather than surfaced in the TUI, and
# are retried on the next scheduled run.
#
# Invoked by launchd, so it never inherits an interactive shell. Everything it
# needs is referenced by absolute path.

set -uo pipefail

readonly PI_BIN=/opt/homebrew/bin/pi
readonly LOG="$HOME/Library/Logs/pi-extension-update.log"
readonly LOCK="${TMPDIR:-/tmp}/pi-extension-update.lock"
readonly STATE="$HOME/.pi/cc-my-pi-update-check.json"
# The updater owns package freshness, so the bundle's own once-daily check is
# parked well past the next scheduled run rather than exactly on top of it.
readonly SUPPRESS_DAYS=7
readonly STALE_LOCK_MINUTES=60

log() {
	printf '%s %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >>"$LOG"
}

mkdir -p "$(dirname "$LOG")"

# mkdir is atomic, which is the portable way to lock on macOS (no flock).
if ! mkdir "$LOCK" 2>/dev/null; then
	if [[ -n $(find "$LOCK" -maxdepth 0 -mmin "+$STALE_LOCK_MINUTES" 2>/dev/null) ]]; then
		log "removing stale lock $LOCK (older than ${STALE_LOCK_MINUTES}m)"
		rmdir "$LOCK" 2>/dev/null
		mkdir "$LOCK" 2>/dev/null || {
			log "could not acquire lock after clearing stale one; skipping"
			exit 0
		}
	else
		log "another run holds $LOCK; skipping"
		exit 0
	fi
fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

if [[ ! -x $PI_BIN ]]; then
	log "pi not found at $PI_BIN; skipping"
	exit 1
fi

# Park cc-my-pi's own once-daily update check. It does not honour PI_OFFLINE, so
# without this the bundle raises its own startup banner even though this script
# is the thing actually keeping it current. A future checkedAt stops the fetch;
# caching latest as the installed version stops the "newer available" compare.
suppress_cc_my_pi_banner() {
	local pkg version now suppress_until
	pkg=$(find "$HOME/.pi/agent/git" -maxdepth 6 -type d -name cc-my-pi -print -quit 2>/dev/null)
	if [[ -z $pkg || ! -f $pkg/package.json ]]; then
		log "cc-my-pi not installed; leaving update-check state untouched"
		return 0
	fi
	version=$(/usr/bin/python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' \
		"$pkg/package.json" 2>/dev/null)
	if [[ -z $version ]]; then
		log "could not read cc-my-pi version; leaving update-check state untouched"
		return 0
	fi
	now=$(date +%s)
	# checkedAt is a JavaScript Date.now(), i.e. milliseconds.
	suppress_until=$(((now + SUPPRESS_DAYS * 86400) * 1000))
	printf '{"checkedAt":%s,"latest":"%s"}\n' "$suppress_until" "$version" >"$STATE"
	log "parked cc-my-pi update banner (latest=$version, next check +${SUPPRESS_DAYS}d)"
}

log "starting: $PI_BIN update --extensions"
if output=$("$PI_BIN" update --extensions 2>&1); then
	[[ -n $output ]] && printf '%s\n' "$output" >>"$LOG"
	log "update succeeded"
	suppress_cc_my_pi_banner
	exit 0
else
	status=$?
	[[ -n $output ]] && printf '%s\n' "$output" >>"$LOG"
	log "update FAILED (exit $status); retrying on next scheduled run"
	exit "$status"
fi
