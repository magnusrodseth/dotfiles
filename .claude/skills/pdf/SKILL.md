---
name: pdf
description: "Export markdown as professional PDF using pandoc + typst (no LaTeX needed). Use when the user asks to: create a PDF, export markdown to PDF, generate a report/handout/document as PDF, or when they mention PDF, pandoc, print-ready, or document export."
---

# Markdown to PDF

Export markdown files as professional PDFs using **pandoc + typst**. Typst is the
default engine: it needs no LaTeX toolchain, is fast, and handles full Unicode
(including æ/ø/å) out of the box. An optional eisvogel + xelatex path is available
for a branded colored title page when a LaTeX install is present.

## Prerequisites

- `pandoc` (3.0+): `brew install pandoc`
- `typst` (0.11+): `brew install typst`

That's it for the default path. Everything below works with just pandoc + typst.

**Optional** (only for the branded `--engine xelatex` title-page path):

- LaTeX with xelatex: `brew install --cask basictex`
- Eisvogel template: download `eisvogel.latex` from
  https://github.com/Wandmalfarbe/pandoc-latex-template/releases into
  `~/.local/share/pandoc/templates/`
- LaTeX packages: `tlmgr --usermode install adjustbox babel-german background bidi collectbox csquotes everypage filehook footmisc footnotebackref framed fvextra letltxmacro ly1 mdframed mweights needspace pagecolor sourcecodepro sourcesanspro titling ucharcat ulem unicode-math upquote xecjk xurl zref`

Mermaid diagrams (optional): `npm install -g @mermaid-js/mermaid-cli`

## Quick Export

```bash
bash ~/.claude/skills/pdf/scripts/md-to-pdf.sh \
  -o report.pdf \
  -t "Report Title" \
  -s "Subtitle" \
  -a "Author Name" \
  --lang nb \
  --toc \
  input.md
```

Defaults to the typst engine. Hyperlinks render blue automatically. For the
branded colored title page instead, add `--engine xelatex` (requires the optional
LaTeX install above).

### Script Flags

| Flag | Default | Description |
|------|---------|-------------|
| `-o, --output` | (required) | Output PDF path |
| `-t, --title` | "Untitled" | Document title |
| `-s, --subtitle` | "" | Subtitle |
| `-a, --author` | "" | Author name |
| `-d, --date` | today | Date (DD.MM.YYYY) |
| `--engine` | typst | `typst` (default) or `xelatex` (branded title page) |
| `--lang` | en | Document language code (e.g. `nb` for Norwegian Bokmål) |
| `--toc` | off | Include table of contents |
| `--highlight-style` | tango | Code syntax theme |
| `--mainfont` | engine default | Body font (e.g. "Helvetica Neue") |
| `--monofont` | engine default | Code font (e.g. "Menlo") |
| `--fontsize` | 11pt | Font size |
| `--margin` | 1in | Page margins |
| `--mermaid` | off | Pre-render mermaid diagrams (requires mmdc) |
| `--title-color` | 1e293b | Title-page background hex (**xelatex only**) |
| `--text-color` | ffffff | Title-page text hex (**xelatex only**) |
| `--no-titlepage` | off | Skip title page (**xelatex only**; typst has no separate title page) |

Multiple input files are concatenated with page breaks between them.

## Custom Export Workflow (typst)

When assembling a document by hand or needing fine control, call pandoc directly.

### Step 1: Write or Assemble Markdown

Standard markdown features:

- `#` for major sections, `##` for subsections
- Standard markdown tables
- Fenced code blocks with a language ID for syntax highlighting
- `[colored text]{color="red"}` for colored text (via `color-spans.lua`; works in typst)
- Markdown links render blue automatically

### Step 2: Run Pandoc with the typst engine

```bash
pandoc input.md -o output.pdf \
  --from=markdown+bracketed_spans \
  --pdf-engine=typst \
  --syntax-highlighting=tango \
  --toc --toc-depth=3 \
  --lua-filter=~/.claude/skills/pdf/scripts/color-spans.lua \
  -V margin-x=2cm \
  -V margin-y=2.2cm \
  -V fontsize=11pt \
  -V 'header-includes=#show link: set text(fill: blue)' \
  --metadata title="Title" \
  --metadata subtitle="Subtitle" \
  --metadata author="Author" \
  --metadata date="19.06.2026" \
  --metadata lang=nb
```

The `header-includes` show rule is what makes links blue under typst. Drop it for
default black links.

### typst variables (via `-V`)

| Variable | Example | Notes |
|----------|---------|-------|
| `margin-x` / `margin-y` | `2cm` | Horizontal / vertical page margins |
| `papersize` | `a4` | Defaults to a4 |
| `fontsize` | `11pt` | Body font size |
| `mainfont` | `Helvetica Neue` | System font name (macOS resolves these) |
| `monofont` | `Menlo` | Code font |
| `section-numbering` | `1.1.1` | Numbered headings |
| `header-includes` | `#show link: set text(fill: blue)` | Raw typst injected into the preamble |

Title, subtitle, author, and date come from `--metadata`; the typst template
renders them as a centered heading block at the top of page one.

## Optional: Branded Title Page (eisvogel + xelatex)

Only when you specifically want the colored full-page title and a LaTeX toolchain
is installed (see optional Prerequisites). Add `--engine xelatex` to the script, or
run pandoc directly:

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
  -V colorlinks=true -V linkcolor=blue -V urlcolor=blue \
  -V mainfont="Helvetica Neue" -V monofont="Menlo" \
  -V fontsize=11pt -V geometry:margin=1in \
  --metadata title="Title" --metadata author="Author"
```

If xelatex is not installed this path fails with `xelatex not found` — use the
default typst engine instead.

## Mermaid Diagrams

If the markdown contains mermaid code blocks, use the `--mermaid` flag with
`md-to-pdf.sh`. It pre-processes mermaid blocks into SVG before PDF generation.
Requires `mmdc` (mermaid-cli): `npm install -g @mermaid-js/mermaid-cli`.

## Highlight Styles

Available syntax themes: `pygments`, `tango`, `espresso`, `zenburn`, `kate`,
`monochrome`, `breezedark`, `haddock`.

## Bundled Scripts

| File | Purpose |
|------|---------|
| `scripts/md-to-pdf.sh` | One-command markdown to PDF export (typst default, `--engine xelatex` optional) |
| `scripts/color-spans.lua` | Enables `[text]{color="red"}` syntax (typst + LaTeX + HTML) |
| `scripts/render-mermaid.sh` | Pre-renders mermaid blocks to SVG |
