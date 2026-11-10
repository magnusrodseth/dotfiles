---
name: claymorphism-soft-3d
triggers: [claymorphism, claymorphism soft 3d, soft]
source: library/motion.json styles (generated; edit freely)
---
# Claymorphism Soft 3D

Soft, puffy rounded shapes with inner highlights, as if made of clay. Objects squash and stretch on landing. Pastel ground, chunky rounded type.

## Palette
`#F6F0FF` `#A78BFA` `#F9A8D4` `#86EFAC` `#FCD34D` `#3B3054`

## Type
Display: Baloo 2. Body: Nunito.
Fetch: `node $S/fetch.mjs font baloo-2 --weights 400,700` and `node $S/fetch.mjs font nunito --weights 400,600`.

## Texture
inner highlight (top-left white radial) + inner shadow (bottom-right) on rounded shapes

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: playful, ui
- Transitions: spin, iris-circle-wipe, container-morph
- Text: letter-scale-pop, elastic-stretch, bounce-drop
- Camera: orbit-2_5d
- Background: animated-gradient-mesh (pastel, slow)

## Sound
bubbly synth pop, pluck sounds, 105-120 BPM.
Score: `node $S/score.mjs --genre playful --mood bright --bpm 112` (or fetch a matching track: `node $S/fetch.mjs music --mood bright`).

## Banned
hard edges, dark backgrounds, serif type.

## Brief fragment
> Soft, puffy rounded shapes with inner highlights, as if made of clay. Objects squash and stretch on landing. Pastel ground, chunky rounded type.
