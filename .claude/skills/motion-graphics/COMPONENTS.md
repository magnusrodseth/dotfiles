# Components

The code library a film composes from. Every piece is a pure function of time, named after `library/motion.json`
(which also holds the design notes and canvas sketches for each name). `init.sh` copies these into `lib/`.
**See them before choosing:** `bash $S/gallery.sh` renders every component in a labelled tile to
`~/Movies/motion-studio/_gallery/<group>.png` (pass `--logo assets/logo.svg` to preview logo reveals on the real logo).

Generated from the source registries; 198 components.

## Pace: `lib/pace.js`
`usePace(name)` sets BPM, shot length, text hold time (`pace.hold(str)`), transition length, max simultaneous moves,
and scales every spring. Pick it first; pass the same BPM to `score.mjs`.
`calm`, `considered`, `standard`, `energetic`, `hype`, `trailer` (trailer takes an act index 0-2).

## Transitions: `lib/transitions.js` (44)
`transition(g, name, p, A, B, o)`; `p` = `prog(t, t0, dur)`; A/B paint a full frame into the context they get.
Options: `dir` (left/right/up/down), `x`,`y` (origin), `color`, `shape` (circle/square/diamond/triangle/hexagon/star/starburst),
`count`, `text`/`font` (text-mask-reveal), `bar` (wipe edge color), `ease`.
`hard-cut`, `smash-cut`, `crossfade-dissolve`, `blur-crossfade`, `dip-to-color`, `fade-through`, `luma-fade`, `shared-axis`, `push`, `slide-over`, `linear-wipe`, `diagonal-wipe`, `clock-wipe`, `iris-circle-wipe`, `shape-wipe`, `portal-shape`, `blinds-venetian`, `stripes-wipe`, `split-reveal`, `whip-pan`, `zoom-through`, `zoom-blur-punch`, `text-mask-reveal`, `ink-liquid-bleed`, `page-turn`, `pixel-dissolve`, `dither-dissolve`, `mosaic-pixelate`, `glitch-rgb-split`, `chromatic-slide`, `light-leak-flash`, `film-burn`, `spin`, `card-flip`, `deck-shuffle`, `accordion-fold`, `grid-tile-flip`, `scale-through-object`, `swipe-up-social`, `radial-wipe-burst`, `slit-scan-stretch`, `j-cut-l-cut`, `cut-on-action`, `match-cut`.
Patterns that are not frame transitions: container-morph (one card that never cuts, see modes/launch.md), morph-shape-to-shape.

## Text: `lib/text.js` (36)
`textFx(g, name, lt, str, x, y, o)` with LOCAL time `lt`. Options: `font`, `size`, `color`, `accent`, `align`, `unit`
(char/word/line), `stagger`, `out` (local exit time), `words` (carousel, retype, karaoke `[{word,start,end}]` from voice.mjs).
`holdFor(str, wps)` gives reading time.
`rise-from-mask`, `fade-up-stagger`, `blur-in`, `letter-scale-pop`, `bounce-drop`, `elastic-stretch`, `char-cascade-3d`, `tracking-expand`, `wave-sine`, `line-by-line-wipe`, `kinetic-stack-push`, `typewriter-cursor`, `typewriter-delete-retype`, `scramble-decode`, `counter-roll`, `big-number-slam`, `slot-machine-roll`, `countdown-flip`, `split-flap-board`, `highlight-marker-sweep`, `underline-draw`, `strike-through`, `outline-to-fill`, `gradient-sweep`, `mask-wipe-color-swap`, `handwriting-stroke`, `glitch-text`, `weight-morph`, `word-swap-carousel`, `caption-karaoke`, `quote-reveal`, `lower-third`, `ticker-marquee`, `text-on-path`, `word-cloud-assemble`, `emoji-react-pop`.

## Backgrounds and post: `lib/backgrounds.js` (22 + 9)
`bg(g, name, t, o)` paints the frame first; `post(g, name, t, o)` treats the finished frame last.
Backgrounds: `dot-grid`, `line-grid`, `blueprint`, `isometric-grid`, `stripes-diagonal`, `animated-gradient-mesh`, `aurora`, `noise-flow-field`, `topographic-contours`, `halftone`, `paper-fibers`, `starfield`, `bokeh`, `light-rays`, `concentric-pulse`, `bauhaus-shapes`, `rain-streaks`, `snow`, `confetti-burst`, `caustics`, `film-grain`, `scanlines`.
Post: `film-grain`, `vignette`, `scanlines`, `chromatic-aberration`, `vhs-tracking`, `crt`, `duotone`, `ordered-dither`, `risograph-misregistration`.
`confetti-burst` is opt-in only (generic bursts are banned by default).

## Camera: `lib/camera.js` (18)
`withCamera(g, camera(t, ...moves), () => drawScene(g))`; moves compose (offsets add, zooms multiply).
`parallax(g, layers, camX, camY, zoom)` for depth; `dollyZoom()` for the background/foreground pair.
Pans and trucks reveal the scene edge: draw the scene larger than the frame (overscan) when the camera travels.
`push-in`, `pull-out`, `pan`, `tilt`, `crane-pedestal`, `snap-zoom`, `whip-pan-camera`, `seeded-shake`, `handheld-drift`, `dutch-roll`, `ken-burns`, `focus-zoom-to-rect`, `follow-cursor`, `rack-focus`, `orbit-2_5d`, `truck-parallax`, `parallax-layers-drift`, `dolly-zoom`.

## UI and annotation: `lib/ui.js` (31)
Frames take a callback `(x, y, w, h) => ...` that draws the content (crop a real screenshot into it).
Tokens via `o`: `ink`, `paper`, `muted`, `line`, `accent`, `ok`, `warn`, `bad`, `font`, `mono`.
For a real product, crop and animate real screenshots; use these for frames, callouts, cursors and generic UI.
`cursor-arrow`, `cursor-hand`, `touch-dot`, `cursor-ring`, `click-ripple`, `tap-indicator`, `spotlight-dim-hole`, `highlight-ring`, `arrow-callout-drawn`, `tooltip-pop`, `sticky-note`, `magnifier-loupe`, `browser-chrome-frame`, `phone-frame`, `laptop-frame`, `terminal-window`, `code-block-typing`, `notification-toast`, `progress-bar`, `spinner-arc`, `spinner-dots`, `chat-bubbles`, `keycaps`, `before-after-slider`, `checklist-ticking`, `toggle-switch`, `step-indicator`, `form-fill`, `modal-dialog`, `badge-counter`, `drag-and-drop`.

## Charts: `lib/charts.js` (21)
`CHART[name](g, lt, [x, y, w, h], data, o)`. Exceptions: `map-pin-drop(g, lt, x, y, o)` and
`annotation-on-chart(g, lt, x, y, text, o)`. Every number on screen needs a named source in the brief.
Options: `colors`, `color`, `ink`, `family`, `format` (default nb-NO thousands), `max`, `stagger`.
`axis-gridline-intro`, `bar-grow`, `stacked-bar-build`, `bar-chart-race`, `line-draw-dot`, `area-fill`, `sparkline`, `slope-chart`, `donut-sweep`, `pie-explode`, `progress-ring`, `big-counter`, `waffle-unit-chart`, `heatmap-fill`, `scatter-bloom`, `comparison-split`, `timeline-scrub`, `map-pin-drop`, `flow-sankey-draw`, `annotation-on-chart`, `number-to-chart-morph`.

## Logo reveals: `lib/logo.js` (11)
`const logo = await loadLogo('assets/logo.svg')` (in `window.ready`) parses the real SVG into paths with fills and lengths.
`LOGO[name](g, lt, logo, cx, cy, height, o)`; `endCardThreeBeat(g, lt, logo, cx, cy, h, { tagline, cta })`.
`stroke-draw-then-fill`, `mask-slice-reveal`, `shape-assemble`, `dot-morph-to-logo`, `ink-bleed-reveal`, `light-sweep-glint`, `glitch-resolve`, `stamp-slam`, `macro-pull-out`, `orbit-converge`, `underline-sign-off`.

## 3D space: `lib/space.js` (WebGL2, GPU)
`const sp = createSpace(W, H, { tubePath })` once in `window.ready`; each frame render one scene into `sp.canvas`, then
`g.drawImage(sp.canvas, 0, 0)` (add a downsampled blurred copy with `screen` for bloom).
- `sp.solar({ ro, target, fov, t, planets, orbitR, orbitAlpha, band })`: raytraced Sun, Earth (oceans, land, clouds,
  atmosphere), Moon, Mars, Jupiter (bands, spot), Saturn (C/B/A rings, Cassini division, ring shadow), ecliptic orbits,
  star sky with a Milky Way band. Planets: `[x, y, z, radius]` in order sun, earth, moon, mars, jupiter, saturn.
- `sp.galaxy({ ro, target, fov, t, phase, pscale, maxSize, gain, band, sgr, andromeda, tube })`: ~300k-particle barred
  spiral (1 unit = 1000 ly): four log-spiral arms, bulge, bar, dust lanes, HII regions, diffuse arm glow, differential
  rotation via `phase`, Sagittarius A* accretion billboard (`sgr` size), a second galaxy via `andromeda: { model, boost }`,
  local stars along `tubePath` for parallax while travelling. Scale `pscale` and `gain` with camera distance.
- Helpers: `basis`, `project(p, ro, target, fov, W, H)` for 2D overlays on 3D points, `armTheta`, `model.translateRotate`, `V3`.
Renders on the GPU (render.mjs launches Chromium with ANGLE/Metal). Example film: a 79 s lofi journey Earth -> planets ->
galaxy -> Sagittarius A* -> Andromeda. Not to scale; never claim scale on screen.

## Audio
- `score.mjs`: genres `pop, house, lofi, cinematic, ambient, synthwave, hiphop, corporate, playful, piano` x moods
  `warm, bright, calm, tense, melancholic, heroic` (`node $S/score.mjs --list`).
- `sfx.mjs`: 27 synthesized voices (click, tick, pop, thump, whoosh, swish, rise, chime, type, shimmer, drop, snap, ding,
  coin, shutter, error, success, notify, swipe, heartbeat, page, beep, glitch, scratch, boom, reverse-swell, bubble) and any
  recorded file in the same cue list (`{ "t": 3, "file": "audio/sfx/x.ogg" }`).
- Recorded music, SFX and packs: see LIBRARY.md.
