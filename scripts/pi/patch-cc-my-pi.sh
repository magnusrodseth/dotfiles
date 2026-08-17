#!/usr/bin/env bash
#
# Re-apply local rendering patches to the cc-my-pi package.
#
# Two things in cc-my-pi's renderer are hardcoded with no setting behind them
# (checked against 1.4.1, and against upstream main):
#
#   1. Markdown code blocks are framed in a rounded box whose horizontal runs
#      are middle dots, `mutedDotFill()`. We want a continuous light line.
#   2. Edit/write diffs are laid out side by side whenever the terminal is at
#      least SPLIT_MIN_WIDTH (150) columns wide. We want Claude Code's inline
#      unified layout at every width.
#
# Why a script rather than just editing the file: the package is installed as a
# git checkout under ~/.pi/agent/git, and pi updates it with `git reset --hard`
# (see PackageManager.ensureGitRef). scripts/pi/update-extensions.sh runs
# `pi update --extensions` at login and once daily, so a hand-edit disappears
# the first time upstream publishes a commit, silently and at an unpredictable
# time. This script is idempotent and is called from that updater, so the
# patches are declared once and converge after every update.
#
# It is deliberately loud about drift. If a target string is neither present in
# its original nor its patched form, upstream has rewritten that code and the
# patch needs re-deriving; the script exits non-zero and says which one rather
# than leaving a half-patched file behind.
#
# Usage:
#   bash scripts/pi/patch-cc-my-pi.sh            # apply (idempotent)
#   bash scripts/pi/patch-cc-my-pi.sh --check    # report only, never write

set -uo pipefail

readonly TARGET_REL="extensions/index.ts"

mode="apply"
case "${1:-}" in
"") ;;
--check) mode="check" ;;
*)
	printf 'usage: %s [--check]\n' "$0" >&2
	exit 2
	;;
esac
readonly mode

# Same discovery the updater uses: the package name is stable, its path under
# ~/.pi/agent/git carries the forge and owner and is not worth hardcoding.
pkg=$(find "$HOME/.pi/agent/git" -maxdepth 6 -type d -name cc-my-pi -print -quit 2>/dev/null)
if [[ -z $pkg || ! -f "$pkg/$TARGET_REL" ]]; then
	printf 'cc-my-pi not installed (no %s under ~/.pi/agent/git); nothing to patch\n' "$TARGET_REL"
	exit 0
fi
readonly pkg

/usr/bin/python3 - "$pkg/$TARGET_REL" "$mode" <<'PY'
import sys

path, mode = sys.argv[1], sys.argv[2]

# (name, original, patched). Both forms must be unique in the file: the check
# below fails rather than guessing if a literal ever appears twice.
PATCHES = [
    (
        "code-fence-fill",
        '${BORDER_COLOR}${"·".repeat(count)}${TRANSPARENT_RESET}',
        '${BORDER_COLOR}${"─".repeat(count)}${TRANSPARENT_RESET}',
    ),
    (
        "code-fence-label-corner",
        "${BORDER_COLOR}╭· ${TRANSPARENT_RESET}",
        "${BORDER_COLOR}╭─ ${TRANSPARENT_RESET}",
    ),
    (
        "code-fence-label-close",
        "${BORDER_COLOR} ╮${TRANSPARENT_RESET}",
        "${BORDER_COLOR}─╮${TRANSPARENT_RESET}",
    ),
    (
        "diff-always-unified",
        "const SPLIT_MIN_WIDTH = 150;",
        "const SPLIT_MIN_WIDTH = Number.POSITIVE_INFINITY;",
    ),
]

text = original_text = open(path, encoding="utf-8").read()
drift = []

for name, old, new in PATCHES:
    if new in text:
        print(f"  already   {name}")
        continue
    count = text.count(old)
    if count == 1:
        if mode == "check":
            print(f"  missing   {name}")
            drift.append(name)
        else:
            text = text.replace(old, new)
            print(f"  applied   {name}")
        continue
    print(f"  DRIFTED   {name} (expected 1 occurrence of the original, found {count})")
    drift.append(name)

if mode != "check" and text != original_text:
    open(path, "w", encoding="utf-8").write(text)

if drift:
    if mode == "check":
        print(f"cc-my-pi patches not applied: {', '.join(drift)}", file=sys.stderr)
    else:
        print(
            "cc-my-pi renderer changed upstream; re-derive these patches: "
            + ", ".join(drift),
            file=sys.stderr,
        )
    sys.exit(1)
PY
status=$?

if ((status == 0)); then
	printf 'cc-my-pi patches in place (%s)\n' "$pkg"
fi
exit "$status"
