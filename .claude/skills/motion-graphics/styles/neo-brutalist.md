---
name: neo-brutalist
triggers: [brutalist, neo brutalist]
source: library/motion.json styles (generated; edit freely)
---
# Neo Brutalist

Thick black borders, flat loud colors and hard offset shadows. Boxes slam in on snappy springs and stop dead. Copy is short and set big.

## Palette
`#FFFFFF` `#000000` `#FF5C00` `#C6FF00` `#3D5AFE`

## Type
Display: Archivo Black. Body: Space Grotesk.
Fetch: `node $S/fetch.mjs font archivo-black --weights 400,700` and `node $S/fetch.mjs font space-grotesk --weights 400,600`.

## Texture
none; hard 4-8 px black offset shadows on every box

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: snappy
- Transitions: hard-cut, push, stripes-wipe, smash-cut
- Text: big-number-slam, kinetic-stack-push, highlight-marker-sweep
- Camera: snap-zoom, seeded-shake
- Background: line-grid

## Sound
punchy drum loops, distorted bass, 120-135 BPM.
Score: `node $S/score.mjs --genre hiphop --mood tense --bpm 127` (or fetch a matching track: `node $S/fetch.mjs music --mood tense`).

## Banned
soft shadows, blur, rounded corners > 4 px, pastels.

## Brief fragment
> Thick black borders, flat loud colors and hard offset shadows. Boxes slam in on snappy springs and stop dead. Copy is short and set big.
