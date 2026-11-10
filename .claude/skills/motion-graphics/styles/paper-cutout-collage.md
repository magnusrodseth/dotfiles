---
name: paper-cutout-collage
triggers: [collage, cutout, paper, paper cutout collage]
source: library/motion.json styles (generated; edit freely)
---
# Paper Cutout Collage

Shapes look cut from colored paper with torn edges and small shadows, layered on a craft-paper ground. Pieces hop in on playful springs and wobble a little at rest, at 12 fps steps. The camera trucks across layers to show depth.

## Palette
`#F3E9DC` `#C8553D` `#588B8B` `#F2D0A4` `#2D2A32`

## Type
Display: Fraunces. Body: Work Sans.
Fetch: `node $S/fetch.mjs font fraunces --weights 400,700` and `node $S/fetch.mjs font work-sans --weights 400,600`.

## Texture
paper-fibers, torn edges (jittered polygon outlines), soft drop shadows offset 3 px

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: playful, heavy
- Transitions: page-turn, slide-over, deck-shuffle
- Text: bounce-drop, letter-scale-pop, handwriting-stroke
- Camera: truck-parallax
- Background: paper-fibers

## Sound
acoustic guitar, claps, glockenspiel, 95-115 BPM.
Score: `node $S/score.mjs --genre playful --mood bright --bpm 105` (or fetch a matching track: `node $S/fetch.mjs music --mood bright`).

## Banned
vector perfection, glow, chrome.

## Brief fragment
> Shapes look cut from colored paper with torn edges and small shadows, layered on a craft-paper ground. Pieces hop in on playful springs and wobble a little at rest, at 12 fps steps. The camera trucks across layers to show depth.
