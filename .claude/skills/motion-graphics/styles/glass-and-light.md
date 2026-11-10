---
name: glass-and-light
triggers: [glass, glass and light, light]
source: library/motion.json styles (generated; edit freely)
---
# Glass And Light

Frosted translucent panels float over slow colored light, and focus shifts between them. Moves are slow and soft. Opt-in only.

## Palette
`#0A0F1F` `#1E2A4A` `#8EC5FF` `#E0C3FC` `#FFFFFF`

## Type
Display: Manrope. Body: Inter.
Fetch: `node $S/fetch.mjs font manrope --weights 400,700` and `node $S/fetch.mjs font inter --weights 400,600`.

## Texture
frosted panels (blur(24px) of background clipped to roundRect), 1 px white 20% borders, bokeh behind. Opt-in: expensive and overused.

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: ui, camera
- Transitions: blur-crossfade, container-morph, luma-fade
- Text: blur-in, gradient-sweep
- Camera: parallax-layers-drift, rack-focus
- Background: bokeh + animated-gradient-mesh

## Sound
airy pads, soft piano, 75-95 BPM.
Score: `node $S/score.mjs --genre ambient --mood calm --bpm 85` (or fetch a matching track: `node $S/fetch.mjs music --mood calm`).

## Banned
more than 3 glass panels on screen, neon outlines, grain over glass.

## Brief fragment
> Frosted translucent panels float over slow colored light, and focus shifts between them. Moves are slow and soft. Opt-in only.
