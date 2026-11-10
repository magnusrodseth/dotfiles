---
name: terminal-mono
triggers: [mono, terminal, terminal mono]
source: library/motion.json styles (generated; edit freely)
---
# Terminal Mono

One monospace font, a blinking cursor and output that streams line by line. Transitions are hard cuts or dithered dissolves. Color is used only for prompts, success and warnings.

## Palette
`#0D0D0D` `#E6E6E6` `#39FF14` `#FFB000` `#5C6370`

## Type
Display: JetBrains Mono. Body: JetBrains Mono.
Fetch: `node $S/fetch.mjs font jetbrains-mono --weights 400,700` and `node $S/fetch.mjs font jetbrains-mono --weights 400,600`.

## Texture
scanlines at 8% optional, slight glow

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: snappy
- Transitions: hard-cut, dither-dissolve, pixel-dissolve
- Text: typewriter-cursor, scramble-decode, typewriter-delete-retype
- Camera: tilt
- Background: scanlines

## Sound
minimal synth arps, keyboard clicks, 100-120 BPM.
Score: `node $S/score.mjs --genre synthwave --mood calm --bpm 110` (or fetch a matching track: `node $S/fetch.mjs music --mood calm`).

## Banned
proportional fonts, springs with overshoot, gradients.

## Brief fragment
> One monospace font, a blinking cursor and output that streams line by line. Transitions are hard cuts or dithered dissolves. Color is used only for prompts, success and warnings.
