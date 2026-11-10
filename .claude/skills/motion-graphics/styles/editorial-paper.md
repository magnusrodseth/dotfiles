---
name: editorial-paper
triggers: [editorial, magazine style, economist style, op-ed, conceptual, the post 35 look, symbolic, explainer illustration]
inspired_by: image-generation/styles/magazine-editorial.md
---
# Editorial paper

The magazine-editorial image style, set in motion: flat color blocks, paper grain, one symbolic concept per shot. Motion is slow and considered, like a page being composed. For explainers, strategy and pitch narratives, blog-post trailers.

## Palette
3-5 muted colors: warm cream `#F1E9DA`, dusty pink `#D9A5A0`, soft brown `#8C6B5A`, slate `#4E5D6C`, one warm yellow accent `#E8B64C`. Low saturation everywhere else.

## Type
Serif display (Fraunces 600, Source Serif 4) for headlines, a humanist sans (Inter, Source Sans 3) for captions. Captions sit outside the illustration, never inside it.

## Texture
Paper grain at 0.06-0.08 (`grain(..., 0.07)`). Shapes are flat polygons with slightly rounded joins; no gradients, no outlines.

## Motion
- Shapes are built on screen: rectangles grow from an edge, circles from their centre, on `heavy`.
- One metaphor per shot (iceberg, dominoes, a ladder, a figure with ghost echoes) assembled in 3-5 moves, then held.
- Camera: slow lateral drift (`camera`), never zooms. Transitions: a paper-colored panel slides across like a turned page.
- Pace: one shot per 2 bars. Generous negative space; the concept occupies at most half the frame.

## Components (names from COMPONENTS.md)
- Pace: `considered`
- Transitions: linear-wipe, page-turn, dip-to-color
- Text: fade-up-stagger, underline-draw, quote-reveal
- Camera: pan, ken-burns
- Background: paper-fibers + film-grain
- UI: arrow-callout-drawn, sticky-note
- Logo reveal: shape-assemble

## Sound
`score.mjs --mood calm --bpm 96`. SFX: soft pop on each shape, swish on page turns. No thumps.

## Banned
3D, photorealism, glossy UI, labels and arrows inside the illustration, busy multi-character scenes.

## Brief fragment
> Flat editorial illustration in motion: paper grain, 3-5 muted colors with one warm yellow accent, one symbolic concept per shot, assembled shape by shape and then held. Serif headlines outside the picture. Slow lateral drift, page-turn transitions.
