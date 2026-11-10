---
name: split-flap-departures
triggers: [departures, flap, split, split flap departures]
source: library/motion.json styles (generated; edit freely)
---
# Split Flap Departures

Every word lands on a mechanical departures board, flapping through letters before it settles. Rows update in waves. Amber marks what is new.

## Palette
`#111111` `#1E1E1E` `#F2F2F2` `#FFC107` `#4CAF50`

## Type
Display: Chivo Mono. Body: Overpass Mono.
Fetch: `node $S/fetch.mjs font chivo-mono --weights 400,700` and `node $S/fetch.mjs font overpass-mono --weights 400,600`.

## Texture
tile grid with center seam line, subtle vertical gradient per tile

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: snappy
- Transitions: grid-tile-flip, hard-cut
- Text: split-flap-board, ticker-marquee, slot-machine-roll
- Camera: push-in (slow)
- Background: dark tiles

## Sound
mechanical clatter SFX over minimal electronic, 100-115 BPM.
Score: `node $S/score.mjs --genre house --mood calm --bpm 107` (or fetch a matching track: `node $S/fetch.mjs music --mood calm`).

## Banned
script fonts, organic shapes, blur transitions.

## Brief fragment
> Every word lands on a mechanical departures board, flapping through letters before it settles. Rows update in waves. Amber marks what is new.
