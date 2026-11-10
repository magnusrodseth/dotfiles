---
name: comic-halftone
triggers: [comic, comic halftone, halftone]
source: library/motion.json styles (generated; edit freely)
---
# Comic Halftone

Panels with thick ink outlines, halftone shading and starburst sound-effect words. Hits come with snap zooms and shakes. Primary colors only.

## Palette
`#FFFFFF` `#111111` `#FFDD00` `#E3170A` `#00A6ED`

## Type
Display: Bangers. Body: Comic Neue.
Fetch: `node $S/fetch.mjs font bangers --weights 400,700` and `node $S/fetch.mjs font comic-neue --weights 400,600`.

## Texture
halftone dots in shading, thick ink outlines, speed lines

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: playful, snappy
- Transitions: shape-wipe (starburst), smash-cut, card-flip
- Text: big-number-slam, letter-scale-pop, bounce-drop
- Camera: snap-zoom, seeded-shake
- Background: halftone + radial speed lines

## Sound
brass stabs, cartoon SFX, 115-135 BPM.
Score: `node $S/score.mjs --genre playful --mood bright --bpm 125` (or fetch a matching track: `node $S/fetch.mjs music --mood bright`).

## Banned
gradients, photo, thin type.

## Brief fragment
> Panels with thick ink outlines, halftone shading and starburst sound-effect words. Hits come with snap zooms and shakes. Primary colors only.
