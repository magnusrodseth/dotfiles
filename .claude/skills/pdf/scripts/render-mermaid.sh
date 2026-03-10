#!/usr/bin/env bash
set -euo pipefail

# render-mermaid.sh -- Pre-render mermaid code blocks in markdown to SVG images.
#
# Usage: ./render-mermaid.sh input.md output.md
#
# Finds ```mermaid ... ``` blocks, renders each to SVG via mmdc,
# and replaces the code block with an image reference.

INPUT="$1"
OUTPUT="$2"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

if ! command -v mmdc &>/dev/null; then
  echo "Error: mmdc (mermaid-cli) not found. Install with: npm install -g @mermaid-js/mermaid-cli" >&2
  exit 1
fi

OUTDIR=$(dirname "$(realpath "$OUTPUT")")
COUNT=0

# Process the file: extract mermaid blocks, render, replace with image refs
awk -v tmpdir="$TMPDIR" -v outdir="$OUTDIR" '
BEGIN { in_mermaid = 0; count = 0; block = "" }
/^```mermaid/ {
  in_mermaid = 1
  block = ""
  next
}
/^```$/ && in_mermaid {
  in_mermaid = 0
  count++
  fname = tmpdir "/mermaid-" count ".mmd"
  svgname = outdir "/mermaid-" count ".svg"
  print block > fname
  close(fname)
  system("mmdc -i " fname " -o " svgname " -b transparent 2>/dev/null")
  print "![](mermaid-" count ".svg)"
  next
}
in_mermaid { block = block $0 "\n"; next }
{ print }
' "$INPUT" > "$OUTPUT"

echo "Rendered mermaid diagrams in $OUTPUT" >&2
