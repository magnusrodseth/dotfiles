#!/usr/bin/env bash
set -euo pipefail

# md-to-pdf.sh -- Convert markdown to professional PDF via pandoc + eisvogel.
#
# Usage:
#   ./md-to-pdf.sh -o output.pdf [-t "Title"] [-s "Subtitle"] [-a "Author"] \
#     [--toc] [--mermaid] [--no-titlepage] file1.md [file2.md ...]
#
# Multiple input files are concatenated with page breaks between them.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
OUTPUT=""
TITLE="Untitled"
SUBTITLE=""
AUTHOR=""
DATE=$(date +"%d.%m.%Y")
TOC=false
HIGHLIGHT_STYLE="tango"
TITLE_COLOR="1e293b"
TEXT_COLOR="ffffff"
MAINFONT="Helvetica Neue"
MONOFONT="Menlo"
FONTSIZE="11pt"
MARGIN="1in"
MERMAID=false
NO_TITLEPAGE=false
FILES=()

usage() {
  echo "Usage: $0 -o OUTPUT [-t TITLE] [-s SUBTITLE] [-a AUTHOR] [--toc] [--mermaid] [--no-titlepage] FILE [FILE ...]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -o|--output) OUTPUT="$2"; shift 2 ;;
    -t|--title) TITLE="$2"; shift 2 ;;
    -s|--subtitle) SUBTITLE="$2"; shift 2 ;;
    -a|--author) AUTHOR="$2"; shift 2 ;;
    -d|--date) DATE="$2"; shift 2 ;;
    --toc) TOC=true; shift ;;
    --highlight-style) HIGHLIGHT_STYLE="$2"; shift 2 ;;
    --title-color) TITLE_COLOR="$2"; shift 2 ;;
    --text-color) TEXT_COLOR="$2"; shift 2 ;;
    --mainfont) MAINFONT="$2"; shift 2 ;;
    --monofont) MONOFONT="$2"; shift 2 ;;
    --fontsize) FONTSIZE="$2"; shift 2 ;;
    --margin) MARGIN="$2"; shift 2 ;;
    --mermaid) MERMAID=true; shift ;;
    --no-titlepage) NO_TITLEPAGE=true; shift ;;
    -h|--help) usage ;;
    -*) echo "Unknown flag: $1"; usage ;;
    *) FILES+=("$1"); shift ;;
  esac
done

[[ -z "$OUTPUT" ]] && { echo "Error: -o OUTPUT required"; usage; }
[[ ${#FILES[@]} -eq 0 ]] && { echo "Error: at least one input file required"; usage; }

# Create temp directory
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Assemble markdown with page breaks between files
ASSEMBLED="$TMPDIR/assembled.md"
FIRST=true

for f in "${FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "Warning: $f not found, skipping" >&2
    continue
  fi

  if [[ "$FIRST" == true ]]; then
    FIRST=false
  else
    printf '\n\\newpage\n\n' >> "$ASSEMBLED"
  fi

  cat "$f" >> "$ASSEMBLED"
done

[[ ! -f "$ASSEMBLED" ]] && { echo "Error: no files assembled"; exit 1; }

# Pre-render mermaid diagrams if requested
if [[ "$MERMAID" == true ]]; then
  MERMAID_OUT="$TMPDIR/mermaid-processed.md"
  bash "$SCRIPT_DIR/render-mermaid.sh" "$ASSEMBLED" "$MERMAID_OUT"
  ASSEMBLED="$MERMAID_OUT"
fi

# Build pandoc command
CMD=(pandoc "$ASSEMBLED" -o "$OUTPUT"
  --from="markdown+bracketed_spans"
  --template=eisvogel
  --pdf-engine=xelatex
  --lua-filter="$SCRIPT_DIR/color-spans.lua"
  -V "colorlinks=true"
  -V "linkcolor=blue"
  -V "urlcolor=blue"
  -V "mainfont=$MAINFONT"
  -V "monofont=$MONOFONT"
  -V "fontsize=$FONTSIZE"
  -V "geometry:margin=$MARGIN"
  -V "table-use-row-colors=true"
  -V "code-block-font-size=\\small"
  --metadata "title=$TITLE"
  --metadata "date=$DATE"
)

# Handle deprecated --highlight-style vs --syntax-highlighting
if pandoc --help 2>&1 | grep -q '\-\-syntax-highlighting'; then
  CMD+=(--syntax-highlighting="$HIGHLIGHT_STYLE")
else
  CMD+=(--highlight-style="$HIGHLIGHT_STYLE")
fi

if [[ "$NO_TITLEPAGE" == true ]]; then
  CMD+=(-V "titlepage=false")
else
  CMD+=(-V "titlepage=true"
    -V "titlepage-color=$TITLE_COLOR"
    -V "titlepage-text-color=$TEXT_COLOR"
    -V "titlepage-rule-color=$TEXT_COLOR"
    -V "titlepage-rule-height=2"
    -V "toc-own-page=true"
  )
fi

[[ -n "$SUBTITLE" ]] && CMD+=(--metadata "subtitle=$SUBTITLE")
[[ -n "$AUTHOR" ]] && CMD+=(--metadata "author=$AUTHOR")
[[ "$TOC" == true ]] && CMD+=(--toc --toc-depth=3)

"${CMD[@]}" 2>&1

echo "Exported: $OUTPUT"
