---
name: mascot-pop
triggers: [mascot, playful, sticker, cute, app mascot, friendly character, cartoon promo]
inspired_by: image-generation/styles/app-mascot-branding.md
---
# Mascot pop

One friendly character with a bold silhouette carries the film: it reacts, points at features, celebrates. Sticker-like shapes, visible overshoot, bright but limited colors. For consumer apps, personal projects, community events.

## Palette
2-4 body colors from the brand plus one accent, on a soft tinted background (`#FFF6E8` or brand tint). Thick outlines in a dark brand color (never pure black).

## Type
A rounded sans (Nunito 800, Baloo 2) for headlines, a friendly sans for body. Words can bounce in on `playful`.

## Texture
Flat with soft cel shading (one darker tone per shape, hard edge). Optional halftone dots at 5% in backgrounds.

## Motion
- The mascot is built from primitives in code (circles, rounded rects, bezier limbs) or from a supplied PNG/SVG cut into parts. Generate a character sheet first with `image-generation` (app-mascot-branding style) when none exists, then trace or cut it.
- `playful` springs everywhere: squash and stretch on landings (scaleY 0.85 -> 1.05 -> 1), anticipation before jumps.
- Eyes do the acting: blinks every 2-4 s (seeded), pupils track the cursor or the feature being shown.
- Stickers pop onto product screenshots with overshoot and a slight rotation.

## Components (names from COMPONENTS.md)
- Pace: `energetic`
- Transitions: iris-circle-wipe, shape-wipe (star), swipe-up-social, card-flip
- Text: bounce-drop, letter-scale-pop, elastic-stretch, emoji-react-pop
- Camera: snap-zoom, handheld-drift
- Background: bauhaus-shapes or stripes-diagonal
- UI: tooltip-pop, badge-counter, chat-bubbles
- Logo reveal: stamp-slam

## Sound
`score.mjs --mood bright --bpm 124`. SFX: pop on stickers, swish on jumps, chime on celebrations.

## Banned
More than one character, realistic rendering, thin outlines, gradients, the mascot covering the product UI.

## Brief fragment
> One friendly mascot with a bold sticker-like silhouette carries the film: it points at features, reacts, celebrates. Flat colors with soft cel shading and thick outlines, playful springs with squash and stretch, stickers popping onto real product screens.
