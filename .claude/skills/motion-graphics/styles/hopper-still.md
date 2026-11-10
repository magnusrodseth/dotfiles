---
name: hopper-still
triggers: [hopper, quiet oil, figurative oil, contemplative, surreal, melancholic, the vermilion accent]
inspired_by: image-generation/styles/quiet-figurative-oil.md
---
# Hopper still

Quiet figurative painting in motion: big flat planes, late-afternoon light, and long hard-edged shadows that move slowly as the sun moves. One small vermilion object, one deadpan surreal element. Motion is almost still. For reflective essays, talk openers, "the state of X" pieces.

## Palette
Petrol `#2F5D62`, slate `#556270`, dusty cream `#E8DCC2`, butter `#E9D38C`, sage `#9DAE8A`, putty `#BFAE95`, and exactly one vermilion accent `#E0472B` (small, off-centre).

## Type
A classic serif (Libre Caslon, EB Garamond) set small and late; the picture carries the film. Text appears only in held frames, lower third, generous margins.

## Texture
Canvas grain 0.08 plus a brush-stroke texture: an offscreen canvas of seeded short strokes (`rng`) at 6% overlay. Edges of planes slightly irregular (jitter path points by ±0.2u, seeded, static).

## Motion
- The light moves: shadow polygons rotate a few degrees over a shot (pure function of t), sunlight plane slides.
- Camera: imperceptible push. Objects do not animate except the one surreal element, which moves once.
- Transitions: slow dissolve through the cream color, 1 bar long. 3-4 shots per 20 s.

## Components (names from COMPONENTS.md)
- Pace: `calm`
- Transitions: luma-fade, dip-to-color, crossfade-dissolve
- Text: fade-up-stagger, blur-in
- Camera: push-in (slow), ken-burns
- Background: paper-fibers + film-grain
- UI: none
- Logo reveal: macro-pull-out

## Sound
`score.mjs --mood calm --bpm 72 --sections intro:2,break:6,outro:2`, quieter mix (`--music-gain 0.65`). No UI SFX; one chime on the surreal reveal.

## Banned
Saturated colors beyond the one accent, fast motion, kinetic type, UI, faces with likeness.

## Brief fragment
> Quiet figurative painting in motion: flat planes, Hopper late-afternoon light, hard shadow shapes that rotate slowly as the sun moves. Muted petrol, cream and sage; exactly one small vermilion object off-centre and one deadpan surreal element that moves once. Near-still, dissolves through cream.
