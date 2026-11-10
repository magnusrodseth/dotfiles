---
name: pixel-8bit
triggers: [8bit, pixel, pixel 8bit]
source: library/motion.json styles (generated; edit freely)
---
# Pixel 8Bit

Low-res canvas scaled up with crisp pixels and a tight palette. Motion moves in whole pixels at stepped frame rates. Dialogue boxes type out with blips.

## Palette
`#0F0F1B` `#29ADFF` `#FF004D` `#FFEC27` `#00E436` `#FFF1E8`

## Type
Display: Press Start 2P. Body: Pixelify Sans.
Fetch: `node $S/fetch.mjs font press-start-2p --weights 400,700` and `node $S/fetch.mjs font pixelify-sans --weights 400,600`.

## Texture
render at 1/4 or 1/6 res with imageSmoothingEnabled=false, upscale; limited palette

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: snappy (quantized to 12 fps)
- Transitions: pixel-dissolve, dither-dissolve, iris-circle-wipe (stepped)
- Text: typewriter-cursor, bounce-drop (stepped), countdown-flip
- Camera: pan (integer pixels)
- Background: starfield (pixel stars)

## Sound
chiptune square waves, 120-150 BPM.
Score: `node $S/score.mjs --genre synthwave --mood bright --bpm 135` (or fetch a matching track: `node $S/fetch.mjs music --mood bright`).

## Banned
anti-aliasing, blur, gradients, sub-pixel motion.

## Brief fragment
> Low-res canvas scaled up with crisp pixels and a tight palette. Motion moves in whole pixels at stepped frame rates. Dialogue boxes type out with blips.
