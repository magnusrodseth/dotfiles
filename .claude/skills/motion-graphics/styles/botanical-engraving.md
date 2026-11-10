---
name: botanical-engraving
triggers: [botanical, botanical engraving, engraving]
source: library/motion.json styles (generated; edit freely)
---
# Botanical Engraving

Fine-line plant illustrations that draw themselves stroke by stroke on aged paper, with serif captions like a field guide. Slow pans across plates.

## Palette
`#F4EFE3` `#2F3E2E` `#7B8F5A` `#B5654A` `#1E1E1E`

## Type
Display: Cormorant. Body: EB Garamond.
Fetch: `node $S/fetch.mjs font cormorant --weights 400,700` and `node $S/fetch.mjs font eb-garamond --weights 400,600`.

## Texture
hatching via line patterns, paper-fibers, vignette

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: camera, ui
- Transitions: ink-liquid-bleed, page-turn, crossfade-dissolve
- Text: handwriting-stroke, line-by-line-wipe, quote-reveal
- Camera: ken-burns, pan
- Background: paper-fibers

## Sound
harp, woodwinds, field recordings, 64-84 BPM.
Score: `node $S/score.mjs --genre ambient --mood warm --bpm 74` (or fetch a matching track: `node $S/fetch.mjs music --mood warm`).

## Banned
neon, glitch, sans-serif display.

## Brief fragment
> Fine-line plant illustrations that draw themselves stroke by stroke on aged paper, with serif captions like a field guide. Slow pans across plates.
