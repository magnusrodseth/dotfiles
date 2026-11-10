---
name: hand-drawn-doodle
triggers: [doodle, drawn, hand, hand drawn doodle]
source: library/motion.json styles (generated; edit freely)
---
# Hand Drawn Doodle

Simple black-ink doodles on white, with a yellow marker for emphasis and lines that boil slightly like hand animation. Arrows and circles draw themselves around the key point. Friendly and plain.

## Palette
`#FFFFFF` `#1F1F1F` `#FFD43B` `#FF8787` `#74C0FC`

## Type
Display: Kalam. Body: Inter.
Fetch: `node $S/fetch.mjs font kalam --weights 400,700` and `node $S/fetch.mjs font inter --weights 400,600`.

## Texture
jittered strokes (each line drawn 2x with hash offsets ±1 px), boil at 8 fps

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: playful, ui
- Transitions: ink-liquid-bleed, linear-wipe, card-flip
- Text: handwriting-stroke, highlight-marker-sweep, underline-draw
- Camera: pan
- Background: none or dot-grid

## Sound
ukulele, whistling, light percussion, 95-115 BPM.
Score: `node $S/score.mjs --genre playful --mood warm --bpm 105` (or fetch a matching track: `node $S/fetch.mjs music --mood warm`).

## Banned
perfect geometry, dark mode, photographic backgrounds.

## Brief fragment
> Simple black-ink doodles on white, with a yellow marker for emphasis and lines that boil slightly like hand animation. Arrows and circles draw themselves around the key point. Friendly and plain.
