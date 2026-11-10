---
name: festive-seasonal
triggers: [festive, festive seasonal, seasonal]
source: library/motion.json styles (generated; edit freely)
---
# Festive Seasonal

Deep red, pine green and gold on cream, with slow snow and warm bokeh. Greetings write themselves in script and settle with a soft sparkle. Swap the palette for other seasons.

## Palette
`#7A0019` `#0B3D2E` `#F5E6C8` `#D4AF37` `#FFFFFF`

## Type
Display: Playfair Display. Body: Lora.
Fetch: `node $S/fetch.mjs font playfair-display --weights 400,700` and `node $S/fetch.mjs font lora --weights 400,600`.

## Texture
snow, bokeh in warm gold, paper-fibers

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: ui, playful
- Transitions: iris-circle-wipe, radial-wipe-burst, crossfade-dissolve
- Text: handwriting-stroke, tracking-expand, letter-scale-pop
- Camera: push-in, parallax-layers-drift
- Background: snow + bokeh

## Sound
sleigh bells, celesta, strings, 90-120 BPM.
Score: `node $S/score.mjs --genre playful --mood bright --bpm 105` (or fetch a matching track: `node $S/fetch.mjs music --mood bright`).

## Banned
generic confetti bursts (unless opt-in), clip-art santas, neon.

## Brief fragment
> Deep red, pine green and gold on cream, with slow snow and warm bokeh. Greetings write themselves in script and settle with a soft sparkle. Swap the palette for other seasons.
