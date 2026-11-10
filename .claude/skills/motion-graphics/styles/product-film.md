---
name: product-film
triggers: [product film, ui motion, launch video, saas reel, app promo, clean product, apple-style product]
---
# Product film

Calm, expensive UI motion. Real product screens on a quiet canvas, one white container that never cuts, a cursor that does real things. The default for launches and demo showcases when the brand gives colors but no motion language.

## Palette
Warm neutral canvas `#F4F2EE` (or the brand's lightest surface), ink `#141413`, one accent from the brand. Dark bookends optional: brand's darkest color for hook and lockup.

## Type
One display face (brand headline font, else Fraunces or Inter Display 600), one UI face (brand body, else Inter). Headline 7-9u, sub 2.6-3.4u. Copy top-left, card below: identical structure in every format.

## Texture
None, or grain at 0.02-0.03. Soft drop shadows on cards (`shadow(g, 6u, 2u, ink @ 16%)`).

## Motion
- Springs: `ui` for the container, `snappy` for buttons and the cursor press, `camera` for push-ins and wipes, `heavy` for headlines. Tiny overshoot on UI, none on type.
- One container morphs between states (`track()` on cx, cy, w, h, r); content swaps behind a 0.2 s blur.
- A camera push-in toward each click target, sized so the card never climbs into the copy or past the safe area.
- Circle wipes from the logo or the card centre on downbeats. Outro: the card shrinks into the logo mark.

## Components (names from COMPONENTS.md)
- Pace: `standard`
- Transitions: container-morph (pattern), shared-axis, iris-circle-wipe, push
- Text: rise-from-mask, fade-up-stagger, counter-roll
- Camera: focus-zoom-to-rect, follow-cursor, push-in
- Background: none or dot-grid
- UI: cursor-arrow, click-ripple, highlight-ring, spotlight-dim-hole, browser-chrome-frame
- Logo reveal: dot-morph-to-logo

## Sound
`score.mjs --mood warm --bpm 120 --sections intro:2,build:2,drop:6,outro:2`. SFX: click on presses, whoosh on morphs, pop on card entries, thump on the logo, chime on the final lockup.

## Banned
Gradient backgrounds, glows on UI, device mockups with reflections, isometric tilts, confetti.

## Brief fragment
> Product-film UI motion. Real screenshots only. One white container that never cuts: it changes size and radius between states while content swaps behind a short blur. A cursor drives every change, clicks land on beats. Quiet canvas, one accent, springs with at most a tiny overshoot.
