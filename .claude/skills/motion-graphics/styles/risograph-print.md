---
name: risograph-print
triggers: [print, risograph, risograph print]
source: library/motion.json styles (generated; edit freely)
---
# Risograph Print

Two or three flat spot inks overprint and shift a few pixels between steps, like a print slightly out of register. Motion steps at 12 fps for shapes while the camera stays smooth. Grain sits on top of everything.

## Palette
`#F7F3EA` `#FF48B0` `#0078BF` `#FFE800` `#00A95C`

## Type
Display: Bricolage Grotesque. Body: IBM Plex Sans.
Fetch: `node $S/fetch.mjs font bricolage-grotesque --weights 400,700` and `node $S/fetch.mjs font ibm-plex-sans --weights 400,600`.

## Texture
risograph-misregistration + coarse grain; overlapping inks via multiply

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: ui, playful
- Transitions: dither-dissolve, linear-wipe, blinds-venetian
- Text: rise-from-mask, outline-to-fill, highlight-marker-sweep
- Camera: parallax-layers-drift
- Background: risograph-misregistration

## Sound
lo-fi beats, tape-saturated synths, 80-95 BPM.
Score: `node $S/score.mjs --genre lofi --mood warm --bpm 87` (or fetch a matching track: `node $S/fetch.mjs music --mood warm`).

## Banned
pure black, smooth gradients, glossy highlights.

## Brief fragment
> Two or three flat spot inks overprint and shift a few pixels between steps, like a print slightly out of register. Motion steps at 12 fps for shapes while the camera stays smooth. Grain sits on top of everything.
