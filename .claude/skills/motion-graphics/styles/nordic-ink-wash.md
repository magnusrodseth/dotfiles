---
name: nordic-ink-wash
triggers: [nordic, watercolor, watercolour, ink and wash, soft, calm, cozy, scandinavian illustration]
inspired_by: image-generation/styles/nordic-watercolor.md
---
# Nordic ink and wash

Line-and-wash illustration that draws itself. Fine ink lines trace the forms, then wet washes bloom underneath. Calm, cozy, Scandinavian. For personal stories, travel, seasonal greetings, gentle product stories.

## Palette
Off-white paper `#F7F4EE`, slate blue `#6E8299`, dusty lavender `#A59DB8`, warm grey `#9A948C`, and one golden-yellow accent `#E9B949` carrying the focal point or a glow.

## Type
A soft serif (Fraunces 400 with SOFT axis, or Newsreader) and a light humanist sans for captions. Lowercase-friendly, airy line height.

## Texture
Paper grain 0.05. Washes: draw shapes into an offscreen canvas, `ctx.filter = 'blur(1.2u)'`, composite with `multiply` at 60-80%; add a darker edge by stroking the same path at 20% with blur 0.3u (pigment settling at the edge).

## Motion
- Ink first: paths drawn with `lineDash`/`lineDashOffset` on `camera` springs, 0.8-1.5 s per object.
- Then the wash blooms: radius grows on `heavy`, alpha 0 -> 0.8.
- Camera: very slow push (2-4 % over a shot). Transitions: a wash wipe (large blurred blob growing) in the next shot's main color.
- One shot per 2-3 bars; nothing snaps.

## Components (names from COMPONENTS.md)
- Pace: `calm`
- Transitions: ink-liquid-bleed, blur-crossfade, crossfade-dissolve
- Text: blur-in, handwriting-stroke, fade-up-stagger
- Camera: push-in, ken-burns
- Background: paper-fibers
- UI: none
- Logo reveal: ink-bleed-reveal

## Sound
`score.mjs --mood calm --bpm 84 --sections intro:2,break:4,outro:2`. SFX: shimmer on the accent glow, soft pops only.

## Banned
Hard digital edges on washes, saturated colors, fast cuts, glossy UI unless placed on a paper card.

## Brief fragment
> Nordic line-and-wash: fine ink lines draw each form, then soft watercolor washes bloom underneath on paper grain. Desaturated slate, lavender and warm grey with one golden accent. Slow push, wash-wipe transitions, calm and airy.
