---
name: corporate-trust
triggers: [corporate, corporate trust, trust]
source: library/motion.json styles (generated; edit freely)
---
# Corporate Trust

Clean white and navy with one confident blue and a green for positive outcomes. Numbers count up, cards slide into place and people-first copy stays on screen long enough to read. Calm, clear and accountable, suited to insurance and banking.

## Palette
`#FFFFFF` `#0A2540` `#1F6FEB` `#E6EEF8` `#00A67E` `#F5A524`

## Type
Display: Source Sans 3. Body: Source Sans 3.
Fetch: `node $S/fetch.mjs font source-sans-3 --weights 400,700` and `node $S/fetch.mjs font source-sans-3 --weights 400,600`.

## Texture
none; soft card shadows (0 8 24 rgba(10,37,64,.08)), light dot-grid

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: ui, camera
- Transitions: shared-axis, container-morph, push
- Text: fade-up-stagger, counter-roll, lower-third
- Camera: focus-zoom-to-rect, push-in
- Background: light line-grid or flat

## Sound
warm corporate pop, piano + soft drums, 95-110 BPM.
Score: `node $S/score.mjs --genre corporate --mood calm --bpm 102` (or fetch a matching track: `node $S/fetch.mjs music --mood calm`).

## Banned
glitch, shake, neon, slang, more than one playful spring per scene.

## Brief fragment
> Clean white and navy with one confident blue and a green for positive outcomes. Numbers count up, cards slide into place and people-first copy stays on screen long enough to read. Calm, clear and accountable, suited to insurance and banking.
