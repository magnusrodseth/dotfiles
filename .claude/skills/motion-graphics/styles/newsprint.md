---
name: newsprint
triggers: [newsprint]
source: library/motion.json styles (generated; edit freely)
---
# Newsprint

Columns, rules and halftone photos on aged paper. Headlines set in a high-contrast serif; the camera reads across the page and zooms into the key line. One red ink for emphasis.

## Palette
`#F2EEE3` `#1A1A1A` `#8B0000` `#BDB6A6` `#5A5A5A`

## Type
Display: Playfair Display. Body: Old Standard TT.
Fetch: `node $S/fetch.mjs font playfair-display --weights 400,700` and `node $S/fetch.mjs font old-standard-tt --weights 400,600`.

## Texture
halftone images, paper-fibers, ink spread (blur 0.6px), column rules

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: heavy, ui
- Transitions: page-turn, spin (newspaper spin, opt-in), linear-wipe
- Text: quote-reveal, line-by-line-wipe, strike-through
- Camera: ken-burns, focus-zoom-to-rect
- Background: paper-fibers + halftone

## Sound
ragtime piano, typewriter, newsroom ambience, 90-110 BPM.
Score: `node $S/score.mjs --genre piano --mood bright --bpm 100` (or fetch a matching track: `node $S/fetch.mjs music --mood bright`).

## Banned
neon, rounded UI, saturated color beyond one red.

## Brief fragment
> Columns, rules and halftone photos on aged paper. Headlines set in a high-contrast serif; the camera reads across the page and zooms into the key line. One red ink for emphasis.
