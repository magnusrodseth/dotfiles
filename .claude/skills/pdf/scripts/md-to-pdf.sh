#!/usr/bin/env bash
set -euo pipefail

# md-to-pdf.sh -- Convert markdown to a professional PDF.
#
# Default engine: typst (no LaTeX install needed, fast, full Unicode incl. æ/ø/å).
# Optional engine: xelatex + eisvogel template (branded colored title page;
#   requires a LaTeX toolchain -- see SKILL.md). Select with --engine xelatex.
#
# Usage:
#   ./md-to-pdf.sh -o output.pdf [-t "Title"] [-s "Subtitle"] [-a "Author"] \
#     [--engine typst|xelatex] [--toc] [--mermaid] [--no-titlepage] \
#     file1.md [file2.md ...]
#
# Multiple input files are concatenated with page breaks between them.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
OUTPUT=""
TITLE="Untitled"
SUBTITLE=""
AUTHOR=""
DATE=$(date +"%d.%m.%Y")
ENGINE="typst"            # typst (default) | xelatex
LANG_CODE="en"           # document language, e.g. nb for Norwegian Bokmål
TOC=false
HIGHLIGHT_STYLE="tango"
TITLE_COLOR="1e293b"      # xelatex/eisvogel title-page background only
TEXT_COLOR="ffffff"       # xelatex/eisvogel title-page text only
MAINFONT=""              # empty => engine default font
MONOFONT=""              # empty => engine default mono font
FONTSIZE="11pt"
MARGIN="1in"
MERMAID=false
NO_TITLEPAGE=false
FILES=()

usage() {
  echo "Usage: $0 -o OUTPUT [-t TITLE] [-s SUBTITLE] [-a AUTHOR] [-d DATE]"
  echo "          [--engine typst|xelatex] [--lang CODE] [--toc] [--mermaid]"
  echo "          [--no-titlepage] [--mainfont NAME] [--monofont NAME]"
  echo "          [--fontsize 11pt] [--margin 1in] [--highlight-style tango]"
  echo "          FILE [FILE ...]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -o|--output) OUTPUT="$2"; shift 2 ;;
    -t|--title) TITLE="$2"; shift 2 ;;
    -s|--subtitle) SUBTITLE="$2"; shift 2 ;;
    -a|--author) AUTHOR="$2"; shift 2 ;;
    -d|--date) DATE="$2"; shift 2 ;;
    --engine) ENGINE="$2"; shift 2 ;;
    --lang) LANG_CODE="$2"; shift 2 ;;
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

command -v pandoc >/dev/null 2>&1 || { echo "Error: pandoc not found. Install with: brew install pandoc"; exit 1; }

# Engine availability checks with actionable hints.
if [[ "$ENGINE" == "typst" ]] && ! command -v typst >/dev/null 2>&1; then
  echo "Error: typst not found. Install with: brew install typst"
  echo "       (or run with --engine xelatex if you have a LaTeX toolchain)"
  exit 1
fi
if [[ "$ENGINE" == "xelatex" ]] && ! command -v xelatex >/dev/null 2>&1; then
  echo "Error: xelatex not found. Install with: brew install --cask basictex"
  echo "       (or use the default typst engine: drop --engine, or --engine typst)"
  exit 1
fi

# Create temp directory
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

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

# Common pandoc arguments
CMD=(pandoc "$ASSEMBLED" -o "$OUTPUT"
  --from="markdown+bracketed_spans"
  --lua-filter="$SCRIPT_DIR/color-spans.lua"
  --metadata "title=$TITLE"
  --metadata "date=$DATE"
  --metadata "lang=$LANG_CODE"
)
[[ -n "$SUBTITLE" ]] && CMD+=(--metadata "subtitle=$SUBTITLE")
[[ -n "$AUTHOR" ]] && CMD+=(--metadata "author=$AUTHOR")
[[ "$TOC" == true ]] && CMD+=(--toc --toc-depth=3)

# Syntax highlighting flag name differs across pandoc versions
if pandoc --help 2>&1 | grep -q '\-\-syntax-highlighting'; then
  CMD+=(--syntax-highlighting="$HIGHLIGHT_STYLE")
else
  CMD+=(--highlight-style="$HIGHLIGHT_STYLE")
fi

if [[ "$ENGINE" == "typst" ]]; then
  # --- Default path: pandoc's built-in typst template ---
  CMD+=(--pdf-engine=typst
    -V "margin-x=$MARGIN"
    -V "margin-y=$MARGIN"
    -V "fontsize=$FONTSIZE"
    -V "header-includes=#show link: set text(fill: blue)"
  )
  [[ -n "$MAINFONT" ]] && CMD+=(-V "mainfont=$MAINFONT")
  [[ -n "$MONOFONT" ]] && CMD+=(-V "monofont=$MONOFONT")
  # The typst template renders title/subtitle/author/date as a heading block.
  # --no-titlepage is a no-op here (there is no separate colored title page).
else
  # --- Optional path: eisvogel + xelatex (branded title page) ---
  CMD+=(--template=eisvogel
    --pdf-engine=xelatex
    -V "colorlinks=true"
    -V "linkcolor=blue"
    -V "urlcolor=blue"
    -V "fontsize=$FONTSIZE"
    -V "geometry:margin=$MARGIN"
    -V "table-use-row-colors=true"
    -V "code-block-font-size=\\small"
  )
  [[ -n "$MAINFONT" ]] && CMD+=(-V "mainfont=$MAINFONT")
  [[ -n "$MONOFONT" ]] && CMD+=(-V "monofont=$MONOFONT")
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
fi

"${CMD[@]}" 2>&1

echo "Exported: $OUTPUT  (engine: $ENGINE)"
