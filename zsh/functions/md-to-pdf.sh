#!/bin/zsh

# Convert a markdown file to PDF.
#
# Uses typst as the pandoc PDF engine, not xelatex. The xelatex version could
# never run on this machine: no TeX distribution is installed and none is
# declared in any manifest, so every call died with "xelatex not found". typst
# is in the Brewfile, is what the `pdf` skill already uses, and needs no TeX.
md-to-pdf() {
  if [ $# -ne 2 ]; then
    echo "Usage: md-to-pdf <input_markdown_file> <output_pdf_file>"
    return 1
  fi

  local input_file="$1"
  local output_file="$2"

  if [ ! -f "$input_file" ]; then
    echo "Error: $input_file does not exist." >&2
    return 1
  fi
  if ! command -v pandoc >/dev/null 2>&1; then
    echo "Error: pandoc not installed (declared in Brewfile)." >&2
    return 1
  fi
  if ! command -v typst >/dev/null 2>&1; then
    echo "Error: typst not installed (declared in Brewfile)." >&2
    return 1
  fi

  pandoc --pdf-engine=typst \
    -V margin-x=1in \
    -V margin-y=1in \
    -o "$output_file" "$input_file"
}
