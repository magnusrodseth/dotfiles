#!/usr/bin/env bash
set -euo pipefail

# build-resume.sh -- compile a typst resume to PDF.
#
# Usage: build-resume.sh SOURCE.typ OUTPUT.pdf
#
# Auto-handles the header photo path:
#   - absolute path  (#image("/Users/...")) -> compiles with `--root /`
#   - relative path  (#image("photo.jpeg")) -> compiles from the .typ's folder
# After a successful build it greps for em dashes and warns if any remain.

SRC="${1:?usage: build-resume.sh SOURCE.typ OUTPUT.pdf}"
OUT="${2:?usage: build-resume.sh SOURCE.typ OUTPUT.pdf}"

command -v typst >/dev/null 2>&1 || { echo "Error: typst not found. Install with: brew install typst"; exit 1; }
[[ -f "$SRC" ]] || { echo "Error: source not found: $SRC"; exit 1; }

if grep -qE '#image\("/' "$SRC"; then
  # absolute photo path -> allow filesystem-root access
  typst compile --root / "$SRC" "$OUT"
else
  # relative photo path -> root defaults to the source file's directory
  typst compile "$SRC" "$OUT"
fi

echo "Built: $OUT"

if grep -q "—" "$SRC"; then
  echo "WARNING: em dashes (—) found in $SRC -- replace with comma / colon / '·' per house rules:"
  grep -n "—" "$SRC" || true
fi
