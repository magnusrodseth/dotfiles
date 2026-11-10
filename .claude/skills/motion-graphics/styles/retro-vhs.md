---
name: retro-vhs
triggers: [retro, retro vhs]
source: library/motion.json styles (generated; edit freely)
---
# Retro Vhs

The whole frame reads as a worn tape: tracking bands roll, colors bleed, a REC timestamp ticks in the corner. Cuts glitch, and titles type on in a blocky display face.

## Palette
`#1A1423` `#F72585` `#4CC9F0` `#FFD60A` `#EDEDED`

## Type
Display: Bungee. Body: VT323.
Fetch: `node $S/fetch.mjs font bungee --weights 400,700` and `node $S/fetch.mjs font vt323 --weights 400,600`.

## Texture
vhs-tracking + crt + chromatic-aberration + timestamp overlay

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: snappy
- Transitions: glitch-rgb-split, mosaic-pixelate, dip-to-color
- Text: glitch-text, typewriter-cursor, ticker-marquee
- Camera: handheld-drift, snap-zoom
- Background: vhs-tracking

## Sound
synthwave, tape-wobbled drums, 95-115 BPM.
Score: `node $S/score.mjs --genre synthwave --mood melancholic --bpm 105` (or fetch a matching track: `node $S/fetch.mjs music --mood melancholic`).

## Banned
clean flat UI, 4K crispness, modern glassmorphism.

## Brief fragment
> The whole frame reads as a worn tape: tracking bands roll, colors bleed, a REC timestamp ticks in the corner. Cuts glitch, and titles type on in a blocky display face.
