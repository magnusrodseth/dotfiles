# Mode: director (long-form, characters, chapters, overnight)

Over 45 s, or anything with characters or chapters. You are hiring a crew, not describing a video. Treat it as a multi-session production; don't rush to a final render.

## Brief template
```
You are the director, animator, sound designer and render engineer for a <DURATION> film made in code.

## The film in one line
<logline; what the viewer should feel at the end>

## References and inputs
- refs/: <video / frames / image library>. Take the grammar, never the content.
- audio/track.wav: use unchanged; measure with beats.py first. (Or: synthesize with score.mjs.)
- Styles/brand: styles/<file>.md, BRANDS.md entry <brand>.
- APIs in .env: <ELEVENLABS_API_KEY, ...>. Budget: <$X>. Be economical.

## Character bible (if any)
Proportions, palette sampled from a sheet, expressions, an identity lock that survives every style change.
Generate the sheet first (image-generation skill), save to assets/characters/.

## Beat sheet
0:00-0:02 hook: <single most striking image>
...       a new visual payoff every 3-5 s
END       last frame sets up the first (loop)

## Text on screen
When lyrics or captions go huge, when they sit like subtitles. Composition leaves room for them.

## Workflow, with gates
1. docs/style_guide.md and docs/shotlist.md (every shot: frames, camera, text, SFX). Show the shot list.
2. Stills for every shot; contact sheet; critique.
3. Animatic at 960x540 (render.mjs --fps 30 --sub 1 --scale 0.5) with the score. Fix pacing before polish.
4. Full animation, polish pass, sound pass, final render.
5. Split chapters across subagents. Write docs/ANIMATION_GUIDE.md first (palette, springs, type, helpers)
   so every subagent codes in the same style; one file per chapter under src/ch/.

## Critique loop (every shot, at least 3 rounds)
Score 1-10 on hook, readability at phone size, motion, composition, depth, sound sync, polish, language.
Log scores and the 3 worst problems in docs/review_log.md. Fix. Repeat until all are 8+.

## Deliverables
out/final.mp4, out/review/loop.mp4, out/review/poster.png, out/contact.png, README.md
```

Generate-then-trace (optional, needs a video-model API): render base shots with a video model for motion that is hard to hand-code, then redraw the whole film in canvas on top so only the code-drawn layer is visible.
