# Brands

Brand facts live in the presentations repo, not here. Resolve its path with `where-is presentations` (normally `~/dev/personal/presentations`), then read, in this order:

1. `.agents/skills/<brand>-brand-guidelines/SKILL.md` (+ `references/`, `assets/` logo files) when it exists. List them: `ls <repo>/.agents/skills | grep brand-guidelines`.
2. `src/styles/themes/tokens/<brand>.ts` for exact hex values and font stacks. It covers more brands than the skills.
3. A company design system skill (for example `<company>-ui-patterns` with `colours.md`, `motion.md`, `typography.md`) when one exists. Its motion rules apply on top of any style: if it says one animation at a time, endings like sentences, no decorative motion, the film obeys.

## Turning a brand into the film's look
- Colors: map the brand palette to roles: dark surface, light surface, ink, accent (one), click target (sparingly).
- Fonts: canvas needs real font files in `assets/fonts/` loaded with `FontFace`. Use the brand's own files when available locally (design systems often ship them in a font package inside any of the company's web projects' `node_modules`); otherwise the documented substitute (for example a geometric Google Font standing in for a licensed grotesk), downloaded from Google Fonts.
- Logo: the real SVG. For a dark background use the brand's own dark-mode colors (many SVGs carry a `prefers-color-scheme` block; bake it into a `-on-dark.svg` copy). Never redraw a logo.
- **Licensing:** brand font files and logos go into the film's own `assets/`, never into a public repo (dotfiles is public).
- When a product UI is shown, the product's own design system wins over the corporate deck theme (a product built on a corporate design system uses that system, not the slide-deck theme for the same project).

## Brand + style
Brand supplies colors, fonts and logo; the style file supplies motion, texture and sound. When they conflict, the brand wins on color and type, the style wins on motion vocabulary, and the brand's motion rules (if any) cap the energy.
