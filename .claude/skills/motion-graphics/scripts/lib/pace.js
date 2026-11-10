// pace.js: one choice sets the tempo of the whole film (BPM, shot length, text hold, spring speed, transition length).
// Presets come from library/motion.json "pace" (reading-speed research, platform specs, film shot-length studies;
// the social-video numbers are convention, not measurement).
//
//   import { PACE, usePace } from './pace.js';
//   const pace = usePace('energetic');   // scales every spring preset in motion.js
//   pace.hold('Se opp i kveld.')          // seconds the line must stay on screen
//   pace.shot(i)                          // start time of shot i on the bar grid
//
// Pair with score.mjs --bpm <pace.bpm>: the score and the picture share the same grid.

import { scaleSprings } from './motion.js';

export const PACE = {
  calm:       { bpm: 72,  barsPerShot: 3,   wps: 2.0, maxWords: 12, springMult: 0.5, transition: 1.1,  maxMoves: 1, transitions: ['crossfade-dissolve', 'blur-crossfade', 'ink-liquid-bleed', 'luma-fade', 'dip-to-color'], camera: 'slow push-in 4-8 s, ken-burns, parallax drift' },
  considered: { bpm: 90,  barsPerShot: 2.5, wps: 2.5, maxWords: 10, springMult: 0.7, transition: 0.65, maxMoves: 2, transitions: ['shared-axis', 'linear-wipe', 'push', 'clock-wipe'], camera: 'push-in, focus-zoom-to-rect, tilt' },
  standard:   { bpm: 120, barsPerShot: 1.5, wps: 3.0, maxWords: 8,  springMult: 1.0, transition: 0.45, maxMoves: 2, transitions: ['hard-cut', 'push', 'iris-circle-wipe', 'cut-on-action'], camera: 'focus-zoom-to-rect, snap-zoom for emphasis, follow-cursor' },
  energetic:  { bpm: 126, barsPerShot: 0.75, wps: 3.5, maxWords: 5, springMult: 1.5, transition: 0.3,  maxMoves: 3, transitions: ['hard-cut', 'whip-pan', 'swipe-up-social', 'stripes-wipe', 'zoom-blur-punch'], camera: 'snap-zoom, seeded-shake on hits, whip-pan' },
  hype:       { bpm: 140, barsPerShot: 0.4, wps: 4.0, maxWords: 3,  springMult: 2.0, transition: 0.15, maxMoves: 4, transitions: ['hard-cut', 'smash-cut', 'glitch-rgb-split', 'zoom-blur-punch', 'chromatic-slide'], camera: 'seeded-shake, snap-zoom every 2 bars, dutch-roll' },
  // trailer: three acts that accelerate. Springs are global, so usePace('trailer', act) sets one act for the whole page:
  // render each act as its own page, or call scaleSprings(Math.sqrt(PACE.trailer[act].springMult)) inside draw(t) per act.
  trailer: [
    { bpm: 84,  barsPerShot: 3,   wps: 2.0, maxWords: 4, springMult: 0.6, transition: 1.0, maxMoves: 1, transitions: ['dip-to-color', 'film-burn'], camera: 'slow push-in' },
    { bpm: 110, barsPerShot: 1.5, wps: 2.0, maxWords: 4, springMult: 1.0, transition: 0.4, maxMoves: 2, transitions: ['hard-cut', 'push'], camera: 'parallax trucks' },
    { bpm: 130, barsPerShot: 0.5, wps: 2.0, maxWords: 4, springMult: 1.8, transition: 0.0, maxMoves: 4, transitions: ['smash-cut', 'hard-cut', 'text-mask-reveal'], camera: 'snap zooms and shakes; hold the title 2-3 s' },
  ],
};

export function usePace(name, act = 0) {
  const p = Array.isArray(PACE[name]) ? PACE[name][act] : PACE[name];
  if (!p) throw new Error(`unknown pace ${name}. Known: ${Object.keys(PACE).join(', ')}`);
  scaleSprings(Math.sqrt(p.springMult));
  const beat = 60 / p.bpm, bar = beat * 4;
  return { ...p, name, beat, bar, shotLen: bar * p.barsPerShot,
    shot: (i, offset = 0) => offset + i * bar * p.barsPerShot,
    hold: (str) => Math.max(1.2, 0.5 + String(str).trim().split(/\s+/).length / p.wps),
    snap: (t) => Math.round(t / beat) * beat };
}
