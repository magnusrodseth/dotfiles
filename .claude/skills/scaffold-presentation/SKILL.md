---
name: scaffold-presentation
description: Scaffold a new slide deck in the user's central presentations repo (~/dev/personal/presentations), sourcing content from the current code repo, the current conversation, or material in the Obsidian vault, and matching or creating a brand theme. Works from any directory. Use when the user says "make a presentation about X", "scaffold a deck", "turn this into slides", "lag en presentasjon om X", "create a talk from this repo/conversation", or wants to present something they have been working on.
---

# Scaffold Presentation

Create a new presentation in the central presentations repo. All decks live in **one** repo:

```
PRES="$HOME/dev/personal/presentations"
```

This skill is a thin orchestrator. The repo's own `AGENTS.md` and project skills are the source of truth for structure, components, themes, and deployment. Your job here: gather the content, pick the brand, then follow the repo's instructions.

## Workflow

### 1. Read the repo's instructions first

Read `$PRES/AGENTS.md` before anything else. It defines the route scaffold, the `presentations.ts` manifest, available themes, slide variants, and key rules (bun not npm, lucide-react not emojis, "Magnus Rødseth" with ø, Norwegian content by default, no scrolling within slides).

The repo also has project skills under `$PRES/.claude/skills/` that activate when working inside it:
- `presentation-theming`: full workflow for adding a new token-driven theme
- `brand-designer`: deriving a brand identity from scratch
- `<company>-brand-guidelines` (capra, reitan, multiconsult, eden-stack, wispr-flow, ...): existing brand systems
- `deploy-presentation`: shipping to Vercel

### 2. Gather content (pick the source the user implies)

**From the current code repo** (e.g. "make a deck about this project"):
- Read README, docs/, architecture notes, CONTEXT.md if present
- Skim recent git history for the narrative arc (what was built, in what order, what was hard)
- Note the project's brand signals: design tokens, Tailwind config, logo assets, existing brand guideline files

**From the current conversation** (e.g. "turn this into slides"):
- Distill the conversation into its load-bearing points: the problem, the journey, the insights, the punchlines
- Confirm the intended audience and duration with the user if not obvious

**From the vault** (e.g. "a talk about agentic coding from my notes"):
- Use the `read-up-on` skill's discovery approach against `$HOME/dev/personal/vault`: filename find + full-text grep (Norwegian and English variants), rank, read top notes
- Learnings, brags, and project notes are the richest slide material

Whatever the source, produce a slide outline (10-20 bullets) and confirm it with the user before writing code, unless they asked you to just go ahead.

### 3. Pick or create the brand theme

1. Check the themes table in `$PRES/AGENTS.md` and `$PRES/src/styles/themes/tokens/`. If the audience or company matches an existing theme (capra, gjensidige, reitan, anthropic, ...), reuse it.
2. If the deck needs a new brand (e.g. derived from the code repo's design system or a client's visual identity), follow the repo's `presentation-theming` skill: add the `Theme` union member, create the token file (single source of truth; OG palette, background palette, and contract CSS are derived), register it, add bespoke CSS and fonts only if needed.
3. When deriving a brand from a code repo: pull primary/accent colors, font choices, and logo from the repo's actual design tokens, not from memory.

### 4. Scaffold the deck

Follow the "Creating a New Presentation" section of `AGENTS.md` exactly:
1. `src/routes/presentations/<name>.tsx` with `ssr: false`, `head()` via `generateHead`, and a `slides` array passed to `<Deck>`
2. Register in `src/data/presentations.ts` (title, description, date, lang, theme)
3. Static assets to `public/presentations/<name>/assets/`
4. Content in Norwegian unless the audience is international

### 5. Verify

- `cd $PRES && bunx tsc --noEmit` must exit 0
- The dev server is assumed already running (port 3000); do not start it
- Sanity-check the deck at `http://localhost:3000/presentations/<name>` (agent-browser or playwright skills) if the user wants visual confirmation

## Heuristics

- Don't duplicate `AGENTS.md` knowledge from memory; it changes, this skill doesn't. Always re-read it.
- One idea per slide. Overflowing content splits into more slides, never scrolls.
- Match an existing deck's tone: skim one recent route file in `src/routes/presentations/` as a style reference before writing slides.
- Deployment is a separate, explicit step (`deploy-presentation` skill). Never deploy unless asked.
