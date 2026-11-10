---
name: isometric-tech
triggers: [isometric, isometric tech, tech]
source: library/motion.json styles (generated; edit freely)
---
# Isometric Tech

Systems drawn as isometric blocks: servers, pipes and data packets moving along iso axes. Blocks rise from the grid on heavy springs. The camera trucks across the diagram.

## Palette
`#0F172A` `#1E293B` `#38BDF8` `#A78BFA` `#F8FAFC` `#22C55E`

## Type
Display: Sora. Body: Inter.
Fetch: `node $S/fetch.mjs font sora --weights 400,700` and `node $S/fetch.mjs font inter --weights 400,600`.

## Texture
isometric-grid at 6% alpha; flat shaded faces (top light, left mid, right dark)

## Motion (names map to lib/ registries; see COMPONENTS.md)
- Springs: ui, heavy
- Transitions: zoom-through, shared-axis, scale-through-object
- Text: fade-up-stagger, typewriter-cursor
- Camera: truck-parallax, orbit-2_5d
- Background: isometric-grid

## Sound
clean electronic, pulsing bass, 110-124 BPM.
Score: `node $S/score.mjs --genre house --mood warm --bpm 117` (or fetch a matching track: `node $S/fetch.mjs music --mood warm`).

## Banned
perspective 3D, photo textures, drop shadows not on the iso axis.

## Brief fragment
> Systems drawn as isometric blocks: servers, pipes and data packets moving along iso axes. Blocks rise from the grid on heavy springs. The camera trucks across the diagram.
