---
name: swiss-grid-minimal-dark
triggers: [dark, grid, minimal, swiss, swiss grid minimal dark]
source: library/motion.json styles (generated; edit freely)
---
# Swiss Grid Minimal Dark

Near-black canvas, crisp grey type, hairline borders and one blue accent. UI pieces assemble with quick, damped motion and focus shifts by blur. Precise and quiet.

## Palette
`#0A0A0A` `#171717` `#EDEDED` `#A1A1A1` `#3B82F6`

## Type
Display: Geist. Body: Inter.
Fetch: `node $S/fetch.mjs font geist --weights 400,700` and `node $S/fetch.mjs font inter --weights 400,600`.

## Texture
thin 1 px borders at 8% white; subtle dot-grid; radial glow behind hero at 6%

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: ui, camera
- Transitions: container-morph, blur-crossfade, shared-axis
- Text: blur-in, rise-from-mask, counter-roll
- Camera: focus-zoom-to-rect, push-in
- Background: dot-grid + vignette

## Sound
minimal techno, soft kicks, glassy plucks, 110-122 BPM.
Score: `node $S/score.mjs --genre house --mood calm --bpm 116` (or fetch a matching track: `node $S/fetch.mjs music --mood calm`).

## Banned
bounce easing, more than one accent color, emoji, skeuomorphic shadows.

## Brief fragment
> Near-black canvas, crisp grey type, hairline borders and one blue accent. UI pieces assemble with quick, damped motion and focus shifts by blur. Precise and quiet.
