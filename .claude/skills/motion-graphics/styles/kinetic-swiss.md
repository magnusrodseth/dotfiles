---
name: kinetic-swiss
triggers: [kinetic type, kinetic typography, swiss, bold type, typographic, text-only video, manifesto, quote video, linkedin text video]
---
# Kinetic Swiss

Typography is the picture. Big grotesk type on a strict grid, hard cuts on the beat, one accent color slamming in on the key word. For manifestos, quotes, LinkedIn insight clips and deck openers.

## Palette
Paper `#F2F0EB` / ink `#111111` / one accent (signal red `#E5371B` or the brand accent). Invert to ink background for emphasis beats.

## Type
One grotesk family in two weights (Inter Tight, Neue Haas substitutes, Space Grotesk): 900 for hits, 400 for context. Sizes jump between 4u, 12u and 28u; nothing in between. Tight tracking (-2 to -4 % of size) on big sizes.

## Texture
Flat. Optional 1px grid lines at 6% opacity that appear on the first beat.

## Motion
- Words enter with `wordsUp` (`heavy`), lines stack and push each other with `track()`.
- Hard cuts on downbeats, no crossfades. Scale slams (1.15 -> 1 on `snappy`) on the accent word.
- Masks: type revealed by a rectangle sliding along the grid. Counters roll (number ticks on beats).
- One idea per bar. Text holds two bars when it carries the claim.

## Components (names from COMPONENTS.md)
- Pace: `energetic`
- Transitions: hard-cut, stripes-wipe, push, split-reveal, text-mask-reveal
- Text: rise-from-mask, big-number-slam, kinetic-stack-push, slot-machine-roll, mask-wipe-color-swap
- Camera: snap-zoom, seeded-shake
- Background: line-grid
- UI: keycaps
- Logo reveal: mask-slice-reveal

## Sound
`score.mjs --mood tense --bpm 124` or `bright`. SFX: tick on every word, thump on the accent word, swish on mask slides.

## Banned
Script fonts, drop shadows, centered everything, more than one accent, words flying in from random directions.

## Brief fragment
> Kinetic Swiss typography on a strict 12-column grid. One grotesk in two weights, three sizes only. Hard cuts on downbeats, the key word slams in the accent color. Flat paper and ink, no shadows.
