---
name: pdf
description: "Export markdown as professional PDF using pandoc + eisvogel + xelatex. Use when the user asks to: create a PDF, export markdown to PDF, generate a report/handout/document as PDF, or when they mention PDF, pandoc, print-ready, or document export."
---

# Markdown to PDF

Export markdown files as professional PDFs using pandoc, xelatex, and the eisvogel template.

## Prerequisites

- `pandoc` (3.0+): `brew install pandoc`
- LaTeX with xelatex: `brew install --cask basictex`
- LaTeX packages: `tlmgr --usermode install adjustbox babel-german background bidi collectbox csquotes everypage filehook footmisc footnotebackref framed fvextra letltxmacro ly1 mdframed mweights needspace pagecolor sourcecodepro sourcesanspro titling ucharcat ulem unicode-math upquote xecjk xurl zref`
- Eisvogel template: Download from https://github.com/Wandmalfarbe/pandoc-latex-template/releases and place `eisvogel.latex` in `~/.local/share/pandoc/templates/`
- Mermaid diagrams (optional): `npm install -g @mermaid-js/mermaid-cli`

## Quick Export

```bash
bash ~/.claude/skills/pdf/scripts/md-to-pdf.sh \
  -o report.pdf \
  -t "Report Title" \
  -s "Subtitle" \
  -a "Author Name" \
  --toc \
  input.md
```

### Script Flags

| Flag | Default | Description |
|------|---------|-------------|
| `-o, --output` | (required) | Output PDF path |
| `-t, --title` | "Untitled" | Document title |
| `-s, --subtitle` | "" | Subtitle |
| `-a, --author` | "" | Author name |
| `-d, --date` | today | Date (DD.MM.YYYY) |
| `--toc` | off | Include table of contents |
| `--highlight-style` | tango | Code syntax theme |
| `--title-color` | 1e293b (slate-800) | Title page background hex |
| `--text-color` | ffffff | Title page text hex |
| `--mainfont` | Helvetica Neue | Body font |
| `--monofont` | Menlo | Code font |
| `--fontsize` | 11pt | Font size |
| `--margin` | 1in | Page margins |
| `--mermaid` | off | Pre-render mermaid diagrams (requires mmdc) |
| `--no-titlepage` | off | Skip title page |

Multiple input files are concatenated with page breaks between them.

## Custom Export Workflow

When assembling a document from multiple sources or needing fine control:

### Step 1: Write or Assemble Markdown

Create a clean markdown file. Use standard markdown features:

- `#` for major sections, `##` for subsections
- Standard markdown tables
- Fenced code blocks with language ID for syntax highlighting
- `\newpage` for page breaks
- `[colored text]{color="red"}` for colored text (uses color-spans.lua)
- `\textcolor{blue}{text}` for inline color (raw LaTeX)

### Step 2: Run Pandoc

Full command with all features:

```bash
pandoc input.md -o output.pdf \
  --from=markdown+bracketed_spans \
  --template=eisvogel \
  --pdf-engine=xelatex \
  --syntax-highlighting=tango \
  --toc --toc-depth=3 \
  --lua-filter=~/.claude/skills/pdf/scripts/color-spans.lua \
  -V titlepage=true \
  -V titlepage-color="1e293b" \
  -V titlepage-text-color="ffffff" \
  -V titlepage-rule-color="ffffff" \
  -V titlepage-rule-height=2 \
  -V toc-own-page=true \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V urlcolor=blue \
  -V mainfont="Helvetica Neue" \
  -V monofont="Menlo" \
  -V fontsize=11pt \
  -V geometry:margin=1in \
  -V table-use-row-colors=true \
  -V code-block-font-size='\small' \
  --metadata title="Title" \
  --metadata author="Author"
```

## Mermaid Diagrams

If the markdown contains mermaid code blocks, use the `--mermaid` flag with `md-to-pdf.sh`. This pre-processes mermaid blocks into SVG images before PDF generation.

Requires `mmdc` (mermaid-cli): `npm install -g @mermaid-js/mermaid-cli`

## Eisvogel Template Variables

### Title Page
```
-V titlepage=true
-V titlepage-color="1e293b"       # hex without #
-V titlepage-text-color="ffffff"
-V titlepage-rule-color="ffffff"
-V titlepage-rule-height=2
-V titlepage-logo="logo.png"
```

### Typography
```
-V mainfont="Helvetica Neue"
-V monofont="Menlo"
-V fontsize=11pt                   # 10pt, 11pt, 12pt
-V geometry:margin=1in
```

### Links
```
-V colorlinks=true
-V linkcolor=blue
-V urlcolor=blue
```

### Code Blocks
```
-V code-block-font-size=\small
```

### Tables
```
-V table-use-row-colors=true
```

### Headers/Footers
```
-V header-left="Title"
-V header-right="\\today"
-V footer-left="Author"
-V footer-right="Page \\thepage"
```

## Highlight Styles

Available syntax themes: `pygments`, `tango`, `espresso`, `zenburn`, `kate`, `monochrome`, `breezedark`, `haddock`.

## Bundled Scripts

| File | Purpose |
|------|---------|
| `scripts/md-to-pdf.sh` | One-command markdown to PDF export |
| `scripts/color-spans.lua` | Enables `[text]{color="red"}` syntax |
| `scripts/render-mermaid.sh` | Pre-renders mermaid blocks to SVG |
