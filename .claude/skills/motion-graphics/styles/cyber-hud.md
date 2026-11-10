---
name: cyber-hud
triggers: [cyber, cyber hud]
source: library/motion.json styles (generated; edit freely)
---
# Cyber Hud

A heads-up display: corner brackets lock onto targets, readouts decode and rings scan outward. Cyan lines on near-black with a red alert accent. Precise and tense.

## Palette
`#020B12` `#00E5FF` `#FF3864` `#B4FF39` `#E0F7FA`

## Type
Display: Orbitron. Body: Rajdhani.
Fetch: `node $S/fetch.mjs font orbitron --weights 400,700` and `node $S/fetch.mjs font rajdhani --weights 400,600`.

## Texture
line-grid, scanlines 6%, thin corner brackets, glow (shadowBlur 12 cyan)

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: snappy, ui
- Transitions: glitch-rgb-split, grid-tile-flip, iris-circle-wipe
- Text: scramble-decode, typewriter-cursor, counter-roll
- Camera: focus-zoom-to-rect, handheld-drift
- Background: line-grid + concentric-pulse

## Sound
dark synth, pulsing sub bass, 110-128 BPM.
Score: `node $S/score.mjs --genre synthwave --mood tense --bpm 119` (or fetch a matching track: `node $S/fetch.mjs music --mood tense`).

## Banned
warm colors as base, serif type, paper texture.

## Brief fragment
> A heads-up display: corner brackets lock onto targets, readouts decode and rings scan outward. Cyan lines on near-black with a red alert accent. Precise and tense.
