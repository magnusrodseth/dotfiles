# Mode: ui-morph (one element morphing through states)

One shape that never cuts: button -> field -> loader -> check -> card -> chart -> palette -> toast -> logo, driven by a cursor, looping seamlessly. 8 bars at 120 BPM (16 s). Style default: `product-film`.

## Spec (fill in, then show the state list on the beat grid before any code)
```
<inputs>
Ask for: product + URL, 8-12 UI states that tell its story, the real data shown in each state,
brand colors + fonts + one accent, a track near 120 BPM or "synthesize", formats.
</inputs>
<direction>
Product-film UI motion. One container never cuts: every state is the same element changing size,
radius and fill while its content swaps behind a short blur. A cursor drives every change.
Quiet canvas, one accent. Springs with at most a tiny overshoot.
Banned: bouncy easing, glows, gradients on UI chrome, particle bursts, dead time.
</direction>
<structure>
120 BPM, 8 bars, something happens on every beat.
logo -> CTA button -> email field (typed) -> loader -> success check -> dashboard card
-> chart draws itself -> tooltip on hover -> command palette -> toast -> logo.
</structure>
<build>
1. index.html, one canvas, window.seek(t). No CSS transitions, no timers, no carried state.
2. Closed-form springs. A value with many targets = track() (one spring per change).
3. Text inside a morphing container enters after the morph starts, leaves before the next (swapAlpha).
4. Tab indicators: indicator() (leading and trailing edges on different springs).
5. Start on a downbeat. UI sounds on beats.
6. 60 fps, 2-4 subframes blended.
</build>
<gotchas>
Never scale text bitmaps up; draw text at final size. The last frame equals the first, cursor position
included (loopT). Check the seam with review.sh --loop.
</gotchas>
```
Here, drawing the UI in code is the point (the states are the product's own components re-set in code with real tokens and copy). Match the real component exactly: tokens, radius, type. When a real screen exists, crop it instead.
