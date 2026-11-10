---
name: monochrome-luxury
triggers: [luxury, monochrome, monochrome luxury]
source: library/motion.json styles (generated; edit freely)
---
# Monochrome Luxury

Black and ivory with one muted gold, wide-tracked serif capitals and long holds. Everything moves slowly and arrives without overshoot. Silence is part of the rhythm.

## Palette
`#0B0B0B` `#F5F3EE` `#8C8C8C` `#C9B37E`

## Type
Display: Cormorant Garamond. Body: Tenor Sans.
Fetch: `node $S/fetch.mjs font cormorant-garamond --weights 400,700` and `node $S/fetch.mjs font tenor-sans --weights 400,600`.

## Texture
fine grain 4%, vignette, occasional light-rays

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: camera, heavy
- Transitions: dip-to-color, luma-fade, linear-wipe (slow)
- Text: tracking-expand, blur-in, line-by-line-wipe
- Camera: push-in (slow), rack-focus
- Background: vignette + grain

## Sound
solo cello or piano, sparse, 60-76 BPM.
Score: `node $S/score.mjs --genre piano --mood melancholic --bpm 68` (or fetch a matching track: `node $S/fetch.mjs music --mood melancholic`).

## Banned
bright colors, bouncy springs, busy layouts, more than 6 words on screen.

## Brief fragment
> Black and ivory with one muted gold, wide-tracked serif capitals and long holds. Everything moves slowly and arrives without overshoot. Silence is part of the rhythm.
