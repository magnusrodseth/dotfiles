---
name: lofi-space
triggers: [space, galaxy, planets, cosmos, universe, astronomy, lofi space, melkeveien, milky way, stars, journey through space]
---
# Lofi space

A slow, warm journey through real 3D space: raytraced planets, a particle galaxy seen from inside and above, soft bloom and film grain, set to a chill lofi track. Calm and wondrous; the camera never cuts, it travels. Built on `lib/space.js`.

## Palette
Deep space `#05060F` `#0B1020`, galaxy blue-white `#B8C8FF`, core amber `#FFD9A0`, nebula rose `#B05080` (sparingly), text cream `#FBF4EA`.

## Type
Display: Fraunces 600 (soft serif). Captions: JetBrains Mono 400 as a quiet ship's log ("LOGG 03 · MARS").
Fetch: `node $S/fetch.mjs font fraunces --weights 400,600` and `node $S/fetch.mjs font jetbrains-mono --weights 400`.

## Texture
Bloom from a downsampled blurred copy of the GL frame (`screen`, 0.5), `post(g, 'vignette', t, { amount: 0.55 })`, `post(g, 'film-grain', t, { amount: 0.07 })`. Fade in from and out to black.

## Components (names from COMPONENTS.md)
- Pace: `calm`
- 3D: `sp.solar` for planets (visit the lit side, subject right of centre, copy left), `sp.galaxy` for the galaxy (inside the disk turn on `band`, scale `pscale` and `gain` with distance)
- Transitions: none inside a scene (the camera travels); one `zoom-through` with a soft violet flash for the jump between scales
- Text: `typewriter-cursor` (log line), `blur-in` per word (title), `fade-up-stagger` (sub). Hold each card a full episode
- Camera: keyframes eased between visits with an arc lift on long travels; slow push while holding
- Overlays: `project()` a 3D point to draw a "you are here" ring and leader line

## Sound
A real CC0 lofi track with a beatless intro (`node $S/fetch.mjs music --genre lofi`), measured with `beats.py`; a CC0 ambient drone under it (`holiznacc0-cosmic-waves`, trimmed); soft whoosh on travels, shimmer on reveals, reverse swell into the scale jump. Synthesized alternative: `node $S/score.mjs --genre lofi --mood calm --bpm 72` plus `--genre ambient` underneath.

## Banned
Lens flares, warp-speed star streaks for every move, fast cuts, claims of scale (planet sizes and distances are stylised), unsourced figures, glow on text.

## Brief fragment
> A calm lofi journey through real 3D space. One travelling camera visits each subject's lit side, holds, then glides on; scale jumps happen once, through a soft zoom with a violet flash. Soft serif titles over a quiet monospace ship's log, bloom and grain, every figure sourced.
