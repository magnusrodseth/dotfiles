---
name: organic-blob-liquid
triggers: [blob, liquid, organic, organic blob liquid]
source: library/motion.json styles (generated; edit freely)
---
# Organic Blob Liquid

Shapes are soft blobs that breathe and merge, and scenes change by flowing color. Type is a friendly serif with gentle waves. Warm and calm.

## Palette
`#FFF7ED` `#FB923C` `#F472B6` `#34D399` `#1E1B4B`

## Type
Display: DM Serif Display. Body: DM Sans.
Fetch: `node $S/fetch.mjs font dm-serif-display --weights 400,700` and `node $S/fetch.mjs font dm-sans --weights 400,600`.

## Texture
smooth noise-deformed blobs, soft inner gradients

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: playful, camera
- Transitions: ink-liquid-bleed, morph-shape-to-shape, iris-circle-wipe
- Text: wave-sine, blur-in, elastic-stretch
- Camera: parallax-layers-drift
- Background: animated-gradient-mesh

## Sound
warm neo-soul, rhodes, gentle groove, 85-100 BPM.
Score: `node $S/score.mjs --genre lofi --mood warm --bpm 92` (or fetch a matching track: `node $S/fetch.mjs music --mood warm`).

## Banned
sharp corners, grids, glitch.

## Brief fragment
> Shapes are soft blobs that breathe and merge, and scenes change by flowing color. Type is a friendly serif with gentle waves. Warm and calm.
