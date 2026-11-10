---
name: neon-night
triggers: [neo-tokyo, 80s anime, cyberpunk, night city, cel anime, retro anime, light trails, akira style]
inspired_by: image-generation/styles/akira-neo-tokyo.md
---
# Neon night

Late-80s cel-animation energy: a dark city built from layered flat silhouettes, isolated light sources, red tail-light trails tearing across the frame on kinetic diagonals. Never name the source film in on-screen text. For hype reels, event openers, "launch day" energy.

## Palette
Darkness made of color: `#0B1426` night blue, `#1E2A3A` slate, `#2B1E24` bruised brown. Light: brick red `#D8432E` (signature), teal `#3BB7B0`, sodium amber `#F2A33A`, cyan-white `#DDF6F3`. Red against teal; avoid magenta and purple.

## Type
Condensed bold sans (Oswald 700, Bebas Neue) for hits, a mono (JetBrains Mono) for small data captions. Type can be set in red on dark, never with neon glow on letters.

## Texture
Film grain 0.08, faint vignette, cel dust: a few seeded specks per frame. Light sources use `globalCompositeOperation = 'lighter'` with blurred copies (glow is allowed on light sources only).

## Motion
- Speed lines and light trails on diagonals: polylines whose head moves on `snappy`, tail decays.
- Parallax: 3-5 silhouette layers (seeded skylines) moving at different rates; the camera trucks sideways.
- Smash cuts on downbeats, a white flash frame (1-2 frames) on the drop. Shake: seeded noise offset ±0.4u for 0.3 s on impacts.

## Components (names from COMPONENTS.md)
- Pace: `hype`
- Transitions: smash-cut, whip-pan, glitch-rgb-split, chromatic-slide, zoom-blur-punch
- Text: glitch-text, scramble-decode, big-number-slam
- Camera: seeded-shake, snap-zoom, dutch-roll, truck-parallax
- Background: starfield (pixel) + post vhs-tracking or crt
- UI: none
- Logo reveal: glitch-resolve

## Sound
`score.mjs --mood tense --bpm 128 --sections intro:1,build:2,drop:8,outro:1`. SFX: rise into the drop, drop on impacts, swish on every trail.

## Banned
Magenta/purple synthwave grids, chrome text, glow on UI or type, smooth CG gradients, named-source references in text.

## Brief fragment
> Late-80s cel-animation night city: layered flat silhouettes, darkness built from deep blues and browns, isolated light sources, brick-red light trails against teal on kinetic diagonals. Film grain, parallax trucking, smash cuts and a flash frame on the drop.
