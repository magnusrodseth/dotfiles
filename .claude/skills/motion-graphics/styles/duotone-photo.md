---
name: duotone-photo
triggers: [duotone, duotone photo, photo]
source: library/motion.json styles (generated; edit freely)
---
# Duotone Photo

Photos reduced to two strong colors, with tall condensed type cutting across them. Images slowly push in while words slam over the top. Bold and poster-like.

## Palette
`#1B1B3A` `#FF6B6B` `#FFE66D` `#F7FFF7`

## Type
Display: Anton. Body: Work Sans.
Fetch: `node $S/fetch.mjs font anton --weights 400,700` and `node $S/fetch.mjs font work-sans --weights 400,600`.

## Texture
duotone mapping + grain 6%

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: snappy, camera
- Transitions: text-mask-reveal, hard-cut, split-reveal
- Text: rise-from-mask, tracking-expand, big-number-slam
- Camera: ken-burns, push-in
- Background: duotone

## Sound
indie rock, driving drums, 110-128 BPM.
Score: `node $S/score.mjs --genre pop --mood heroic --bpm 119` (or fetch a matching track: `node $S/fetch.mjs music --mood heroic`).

## Banned
full-color photos, more than 2 photo tones, thin type.

## Brief fragment
> Photos reduced to two strong colors, with tall condensed type cutting across them. Images slowly push in while words slam over the top. Bold and poster-like.
