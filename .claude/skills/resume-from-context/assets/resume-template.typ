// ============================================================================
// Personal resume template (typst). Copy this file, fill in the placeholders,
// then compile with scripts/build-resume.sh.
//
// Design: single-column with a header band, photo top-right, one accent color.
// House rule: NO em dashes (—). Use commas, colons, parentheses, or "·".
// ============================================================================

#set document(title: "FULL NAME CV", author: "FULL NAME")
#set page(paper: "a4", margin: (x: 1.6cm, top: 1.4cm, bottom: 1.3cm))
#set text(font: "Helvetica Neue", size: 9.6pt, fill: rgb("#1f1f1f"))
#set par(justify: true, leading: 0.6em)

// ---- Accent: navy default. Alternatives: petrol #0f6b6b, burgundy #7b2d3a,
//      monochrome #1f1f1f. -----------------------------------------------------
#let accent = rgb("#1e3a5f")
#let grey = rgb("#5b6470")
#let lightrule = rgb("#c9d2dc")
#show link: set text(fill: accent)

// Section heading: small-caps-style label + rule
#let section(title) = {
  v(8pt)
  text(fill: accent, weight: "bold", size: 10.5pt, tracking: 0.8pt)[#upper(title)]
  v(2pt)
  line(length: 100%, stroke: 0.7pt + accent)
  v(4pt)
}

// One experience entry. `body` is a [content] block; `tech` a plain string.
#let entry(org, title, dates, body, tech) = {
  block(breakable: false, width: 100%, {
    grid(
      columns: (1fr, auto),
      align: (left + bottom, right + bottom),
      text(weight: "bold", size: 10pt, fill: rgb("#101820"))[#org],
      text(fill: grey, size: 8.8pt)[#dates],
    )
    v(0.5pt)
    text(fill: accent, style: "italic", size: 9.4pt)[#title]
    v(2pt)
    body
    v(2.5pt)
    text(size: 8.5pt, fill: grey)[#text(weight: "bold")[Tech ] #tech]
  })
  v(7pt)
}

// ===== Header =====
#grid(
  columns: (1fr, auto),
  column-gutter: 14pt,
  align: (left + top, right + top),
  [
    #text(size: 24pt, weight: "bold", fill: accent)[FULL NAME]
    #v(1pt)
    #text(size: 11.5pt, fill: rgb("#101820"))[TITLE LINE, e.g. Full-Stack Web Developer]
    #v(-1pt)
    #text(size: 8.8pt, fill: accent, tracking: 0.5pt)[OPTIONAL TAGLINE IN CAPS]
    #v(5pt)
    #text(size: 8.9pt)[
      City, Country  ·  #link("mailto:EMAIL")[EMAIL]  ·  PHONE \
      #link("https://www.linkedin.com/in/HANDLE/")[linkedin.com/in/HANDLE]  ·  #link("https://github.com/HANDLE")[github.com/HANDLE]
    ]
  ],
  // Photo: set the path. Relative (filename beside this .typ) is best for a
  // portable bundle; an absolute path requires compiling with `--root /`.
  box(clip: true, radius: 5pt, stroke: 0.5pt + lightrule)[
    #image("PHOTO.jpeg", height: 3.3cm)
  ],
)
#v(5pt)
#line(length: 100%, stroke: 1.1pt + accent)

// ===== Profile ===== (keep the subject's own wording)
#section("Profile")
PROFILE PARAGRAPH(S) IN THE SUBJECT'S OWN WORDS.

// ===== Skills =====
#section("Skills")
#grid(
  columns: (auto, 1fr),
  row-gutter: 7.5pt,
  column-gutter: 10pt,
  text(weight: "bold", fill: accent)[Technology], [COMMA, SEPARATED, LIST],
  text(weight: "bold", fill: accent)[Tools], [COMMA, SEPARATED, LIST],
  text(weight: "bold", fill: accent)[Methods], [COMMA, SEPARATED, LIST],
  text(weight: "bold", fill: accent)[Roles], [COMMA, SEPARATED, LIST],
)

// ===== Experience ===== (most recent first; one entry() per role)
#section("Experience")

#entry(
  "EMPLOYER · CLIENT, Project",          // org (real names; debranded)
  "ROLE",                                  // role/title
  "MM.YYYY – present",                     // dates (en dash ok, not em dash)
  [ONE TIGHT PARAGRAPH: what the project was + what the subject did, in their words.],
  "Tech, Stack, Comma, Separated",
)

// ... repeat #entry(...) for each role ...

// ===== Education / Certifications / Languages =====
#section("Education")
#grid(
  columns: (1fr, auto),
  row-gutter: 3pt,
  [*DEGREE*, Institution], text(fill: grey)[YYYY – YYYY],
)

#section("Certifications")
#grid(
  columns: (1fr, auto),
  row-gutter: 3pt,
  [*CERTIFICATION*, Issuer], text(fill: grey)[MM.YYYY],
)

#section("Languages")
#grid(
  columns: (auto, auto),
  column-gutter: 24pt,
  row-gutter: 3pt,
  [*Language*: level], [*Language*: level],
)
