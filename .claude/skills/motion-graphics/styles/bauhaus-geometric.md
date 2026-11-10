---
name: bauhaus-geometric
triggers: [bauhaus, bauhaus geometric, geometric]
source: library/motion.json styles (generated; edit freely)
---
# Bauhaus Geometric

Primary shapes are the actors: circles, squares and triangles assemble into layouts, then dissolve into the next idea. Type is set heavy and geometric on a strict grid. Every move is a straight line or a perfect arc.

## Palette
`#F2EBDD` `#E63946` `#1D3557` `#F4C430` `#111111`

## Type
Display: League Spartan. Body: Jost.
Fetch: `node $S/fetch.mjs font league-spartan --weights 400,700` and `node $S/fetch.mjs font jost --weights 400,600`.

## Texture
flat fills, no gradients; optional paper-fibers at 4% alpha

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: snappy, heavy
- Transitions: shape-wipe, iris-circle-wipe, split-reveal, morph-shape-to-shape
- Text: rise-from-mask, letter-scale-pop, mask-wipe-color-swap
- Camera: truck-parallax
- Background: bauhaus-shapes

## Sound
minimal percussive, marimba, woodblocks, 100-118 BPM.
Score: `node $S/score.mjs --genre playful --mood calm --bpm 109` (or fetch a matching track: `node $S/fetch.mjs music --mood calm`).

## Banned
gradients, drop shadows, photo realism, script fonts.

## Brief fragment
> Primary shapes are the actors: circles, squares and triangles assemble into layouts, then dissolve into the next idea. Type is set heavy and geometric on a strict grid. Every move is a straight line or a perfect arc.
