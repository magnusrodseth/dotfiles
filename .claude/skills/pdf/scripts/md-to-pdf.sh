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
MAINFONT=""              # empty => DEFAULT_TYPST_MAINFONT if present, else engine default
MONOFONT=""              # empty => engine default mono font
FONTSIZE="10pt"
MARGIN="0.8in"
MERMAID=false
NO_TITLEPAGE=false
FILES=()

# House style (typst engine). Override per-run with the matching flags.
DEFAULT_TYPST_MAINFONT="Helvetica Neue"  # used only when actually installed
HEADING_COLOR="123a5c"    # dark slate blue for headings
LINK_COLOR="0b57d0"       # readable blue for links
TABLE_FONTSIZE="8.8pt"    # tables step down so wide ones fit the text block
TYPOGRAPHY=true           # table alignment + non-breaking numbers lua filter

usage() {
  echo "Usage: $0 -o OUTPUT [-t TITLE] [-s SUBTITLE] [-a AUTHOR] [-d DATE]"
  echo "          [--engine typst|xelatex] [--lang CODE] [--toc] [--mermaid]"
  echo "          [--no-titlepage] [--mainfont NAME] [--monofont NAME]"
  echo "          [--fontsize 10pt] [--margin 0.8in] [--highlight-style tango]"
  echo "          [--heading-color HEX] [--link-color HEX] [--table-fontsize SIZE]"
  echo "          [--no-typography] FILE [FILE ...]"
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
    --heading-color) HEADING_COLOR="${2#\#}"; shift 2 ;;
    --link-color) LINK_COLOR="${2#\#}"; shift 2 ;;
    --table-fontsize) TABLE_FONTSIZE="$2"; shift 2 ;;
    --no-typography) TYPOGRAPHY=false; shift ;;
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
[[ "$TYPOGRAPHY" == true ]] && CMD+=(--lua-filter="$SCRIPT_DIR/table-typography.lua")
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
  #
  # House style. The table rule is the important one: pandoc's typst template
  # justifies every paragraph, and justification inside a narrow table cell
  # produces stretched word spacing and hyphenation like "Torremoli-nos".
  # Turning justification and hyphenation off inside tables (only) fixes it.
  read -r -d '' TYPST_HEADER <<EOF || true
#show link: set text(fill: rgb("#${LINK_COLOR}"))
#show heading: set text(fill: rgb("#${HEADING_COLOR}"))
#show heading.where(level: 1): set block(above: 1.7em, below: 0.9em)
#show table: it => {
  set par(justify: false, leading: 0.55em)
  set text(hyphenate: false, size: ${TABLE_FONTSIZE})
  it
}
#show table.cell.where(y: 0): set text(weight: "bold")
EOF

  CMD+=(--pdf-engine=typst
    -V "margin-x=$MARGIN"
    -V "margin-y=$MARGIN"
    -V "fontsize=$FONTSIZE"
    -V "header-includes=$TYPST_HEADER"
  )

  # Prefer the house sans, but only when it is actually installed, so this
  # still renders on a machine without it instead of failing.
  # Note: a here-string, not a pipe. Under `set -o pipefail`, `grep -q` closes
  # the pipe on its first match and the producer dies with SIGPIPE (141), so a
  # piped version reports "not found" precisely when the font IS installed.
  TYPST_FONT="$MAINFONT"
  if [[ -z "$TYPST_FONT" ]]; then
    AVAILABLE_FONTS="$(typst fonts 2>/dev/null || true)"
    if grep -qxF "$DEFAULT_TYPST_MAINFONT" <<<"$AVAILABLE_FONTS"; then
      TYPST_FONT="$DEFAULT_TYPST_MAINFONT"
    fi
  fi
  [[ -n "$TYPST_FONT" ]] && CMD+=(-V "mainfont=$TYPST_FONT")
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
