#!/bin/zsh

# Executes when the current directory is changed.
function chpwd() {
  clear
  l
}

# Custom function to convert markdown files to PDFs
md-to-pdf() {
  if [ $# -ne 2 ]; then
    echo "Usage: md-to-pdf <input_markdown_file> <output_pdf_file>"
    return 1
  fi

  local input_file="$1"
  local output_file="$2"

  pandoc --pdf-engine=xelatex \
          -V geometry:margin=1in \
          -V colorlinks=true \
          -V linkcolor=blue \
          -o "$output_file" "$input_file"
}


# yy shell wrapper that provides the ability to change the current working directory when exiting Yazi
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
