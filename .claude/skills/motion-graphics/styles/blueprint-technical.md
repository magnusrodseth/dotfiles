---
name: blueprint-technical
triggers: [blueprint, blueprint technical, technical]
source: library/motion.json styles (generated; edit freely)
---
# Blueprint Technical

Everything is drawn in thin white lines on deep blue and builds stroke by stroke, with dimension lines and callouts. The camera glides between details like a drafter's eye. Labels type in monospace.

## Palette
`#0B3A6E` `#134E8E` `#E8F1FF` `#7FD1FF` `#FFD166`

## Type
Display: Barlow Condensed. Body: IBM Plex Mono.
Fetch: `node $S/fetch.mjs font barlow-condensed --weights 400,700` and `node $S/fetch.mjs font ibm-plex-mono --weights 400,600`.

## Texture
blueprint grid + faint paper noise

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: ui, camera
- Transitions: linear-wipe, zoom-through, shared-axis
- Text: typewriter-cursor, underline-draw, line-by-line-wipe
- Camera: pan, focus-zoom-to-rect
- Background: blueprint

## Sound
ambient electronic, ticking clocks, 90-105 BPM.
Score: `node $S/score.mjs --genre ambient --mood calm --bpm 97` (or fetch a matching track: `node $S/fetch.mjs music --mood calm`).

## Banned
filled photo imagery, playful bounces, emoji.

## Brief fragment
> Everything is drawn in thin white lines on deep blue and builds stroke by stroke, with dimension lines and callouts. The camera glides between details like a drafter's eye. Labels type in monospace.
