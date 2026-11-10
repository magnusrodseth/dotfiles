---
name: scandinavian-minimal
triggers: [minimal, scandinavian, scandinavian minimal]
source: library/motion.json styles (generated; edit freely)
---
# Scandinavian Minimal

Warm off-white, sage and terracotta, a calm serif headline and generous space. One element moves at a time, eased, with no overshoot. Honest and quiet.

## Palette
`#F7F5F2` `#2B2B2B` `#D9CBB8` `#7A8B7F` `#C26A4A`

## Type
Display: Instrument Serif. Body: Figtree.
Fetch: `node $S/fetch.mjs font instrument-serif --weights 400,700` and `node $S/fetch.mjs font figtree --weights 400,600`.

## Texture
subtle paper grain 3%, lots of negative space

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: ui, camera
- Transitions: crossfade-dissolve, shared-axis, linear-wipe
- Text: fade-up-stagger, rise-from-mask, underline-draw
- Camera: push-in, pan
- Background: flat warm off-white

## Sound
acoustic guitar, felt piano, 72-92 BPM.
Score: `node $S/score.mjs --genre piano --mood calm --bpm 82` (or fetch a matching track: `node $S/fetch.mjs music --mood calm`).

## Banned
saturated neon, glitch, shake, more than 2 type sizes per frame.

## Brief fragment
> Warm off-white, sage and terracotta, a calm serif headline and generous space. One element moves at a time, eased, with no overshoot. Honest and quiet.
