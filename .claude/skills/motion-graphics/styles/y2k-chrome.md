---
name: y2k-chrome
triggers: [chrome, y2k chrome]
source: library/motion.json styles (generated; edit freely)
---
# Y2K Chrome

Liquid chrome type with sweeping highlights, star sparkles and electric blue-pink accents. Elements spin and zoom in with punchy springs. Everything shines.

## Palette
`#C0C0C8` `#E8E8F0` `#5B5BFF` `#FF4FD8` `#0A0A12`

## Type
Display: Michroma. Body: Exo 2.
Fetch: `node $S/fetch.mjs font michroma --weights 400,700` and `node $S/fetch.mjs font exo-2 --weights 400,600`.

## Texture
chrome via multi-stop linearGradient (#fff, #888, #222, #ddd, #fff) with gradient-sweep shine; starbursts

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: snappy, playful
- Transitions: zoom-blur-punch, chromatic-slide, spin
- Text: gradient-sweep, tracking-expand, elastic-stretch
- Camera: orbit-2_5d, snap-zoom
- Background: starfield + concentric-pulse

## Sound
trance-pop, bubbly synths, UK garage, 128-140 BPM.
Score: `node $S/score.mjs --genre house --mood bright --bpm 134` (or fetch a matching track: `node $S/fetch.mjs music --mood bright`).

## Banned
paper texture, muted colors, serif body text.

## Brief fragment
> Liquid chrome type with sweeping highlights, star sparkles and electric blue-pink accents. Elements spin and zoom in with punchy springs. Everything shines.
