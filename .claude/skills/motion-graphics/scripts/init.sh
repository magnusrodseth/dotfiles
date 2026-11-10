#!/usr/bin/env bash
# init.sh: scaffold a motion-graphics project (one directory per film or per brand).
#
#   bash init.sh <dir> [--w 1920 --h 1080] [--dur 20]
#
# Creates index.html (seek(t) starter), lib/motion.js, CLAUDE.md (the house rules, copied from SKILL.md),
# docs/, assets/, audio/, out/, a .gitignore, and installs Playwright + Chromium locally.
# Idempotent: existing files are kept, never overwritten.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"; skill="$(dirname "$here")"
dir="$1"; shift; w=1920; h=1080; dur=20
while [ $# -gt 0 ]; do case "$1" in --w) w="$2"; shift 2;; --h) h="$2"; shift 2;; --dur) dur="$2"; shift 2;; *) echo "unknown flag $1" >&2; exit 1;; esac; done
num() { [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]] || { echo "invalid number: $1" >&2; exit 1; }; }; num "$w"; num "$h"; num "$dur"
mkdir -p "$dir"/{lib,docs,assets/fonts,assets/shots,audio,out,refs}
cd "$dir"
put() { if [ -e "$1" ]; then cat >/dev/null; echo "kept   $1"; else cat > "$1"; echo "wrote  $1"; fi; }
sed -e "s/__W__/$w/g" -e "s/__H__/$h/g" -e "s/__DUR__/$dur/g" "$skill/templates/index.html" | put index.html
put lib/motion.js < "$here/motion.js"
for f in "$here"/lib/*.js; do put "lib/$(basename "$f")" < "$f"; done
# House rules: single source is the <!-- rules --> block in SKILL.md.
sed -n '/<!-- rules -->/,/<!-- \/rules -->/p' "$skill/SKILL.md" | sed '1d;$d' | { echo "# Motion studio rules"; echo; cat; } | put CLAUDE.md
printf 'node_modules/\nout/\n.env\n' | put .gitignore
printf '{ "name": "film", "private": true, "type": "module" }\n' | put package.json
PLAYWRIGHT_VERSION=1.65.0 # pinned; bump deliberately
[ -d node_modules/playwright ] || npm i -D "playwright@$PLAYWRIGHT_VERSION" >/dev/null 2>npm-error.log || { echo "npm i playwright failed, see $(pwd)/npm-error.log" >&2; exit 1; }
rm -f npm-error.log
npx playwright install chromium >/dev/null 2>&1 || echo "WARN: npx playwright install chromium failed; run it by hand"
echo "ready: $(pwd)  ${w}x${h}, ${dur}s.  Preview: open index.html via 'npx serve' or render stills with render.mjs --stills 0"
