---
name: zine-photocopy
triggers: [photocopy, zine, zine photocopy]
source: library/motion.json styles (generated; edit freely)
---
# Zine Photocopy

Photocopied black and white with toner speckle, taped-on cutouts and one hot accent. Layout is crooked on purpose; elements stutter in at 8-12 fps. Loud and handmade.

## Palette
`#F0F0F0` `#0A0A0A` `#FF2E63` `#FFF200`

## Type
Display: Rubik Mono One. Body: Courier Prime.
Fetch: `node $S/fetch.mjs font rubik-mono-one --weights 400,700` and `node $S/fetch.mjs font courier-prime --weights 400,600`.

## Texture
high-contrast threshold, toner speckle (seeded dots), tape strips, misaligned crops

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: snappy
- Transitions: hard-cut, stripes-wipe, pixel-dissolve
- Text: strike-through, kinetic-stack-push, glitch-text
- Camera: seeded-shake, dutch-roll
- Background: toner speckle

## Sound
garage punk, lo-fi drum machine, 130-160 BPM.
Score: `node $S/score.mjs --genre pop --mood tense --bpm 145` (or fetch a matching track: `node $S/fetch.mjs music --mood tense`).

## Banned
smooth gradients, soft shadows, centered symmetric layouts.

## Brief fragment
> Photocopied black and white with toner speckle, taped-on cutouts and one hot accent. Layout is crooked on purpose; elements stutter in at 8-12 fps. Loud and handmade.
