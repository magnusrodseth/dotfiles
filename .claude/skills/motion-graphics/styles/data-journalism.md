---
name: data-journalism
triggers: [data, data journalism, journalism]
source: library/motion.json styles (generated; edit freely)
---
# Data Journalism

Serif headlines over white, charts that build axis first, then data, then a single annotated takeaway. One accent color marks the story; everything else is grey. The camera moves only to point at the evidence.

## Palette
`#FFFFFF` `#121212` `#D7263D` `#1B998B` `#E8E8E8` `#F4A259`

## Type
Display: Source Serif 4. Body: Libre Franklin.
Fetch: `node $S/fetch.mjs font source-serif-4 --weights 400,700` and `node $S/fetch.mjs font libre-franklin --weights 400,600`.

## Texture
none; hairline rules and annotations

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: ui, camera
- Transitions: shared-axis, crossfade-dissolve, container-morph
- Text: fade-up-stagger, highlight-marker-sweep, counter-roll
- Camera: focus-zoom-to-rect, pan
- Background: none (white)

## Sound
understated piano/strings, ticking, 80-100 BPM.
Score: `node $S/score.mjs --genre piano --mood calm --bpm 90` (or fetch a matching track: `node $S/fetch.mjs music --mood calm`).

## Banned
3D charts, neon, decorative particles, truncated axes.

## Brief fragment
> Serif headlines over white, charts that build axis first, then data, then a single annotated takeaway. One accent color marks the story; everything else is grey. The camera moves only to point at the evidence.
