// camera.js: camera moves, named after library/motion.json "camera". Moves compose: offsets add, zooms multiply.
//
//   import { camera, withCamera, CAM, parallax } from './camera.js';
//   const c = camera(t, CAM['push-in'](t, 8, 3, 1.12, [x, y]), CAM['seeded-shake'](t, 10.5, 0.4, 8));
//   withCamera(g, c, () => drawScene(g));
//
// Every move is a pure function of t returning { dx, dy, z, rot, fx, fy, blur }:
// dx/dy pan in px, z zoom factor, rot radians, (fx, fy) the zoom focus in scene px, blur px for rack focus.

import { clamp, lerp, sp, spring, prog, EASE, noise1, track } from './motion.js';

const M = (o = {}) => ({ dx: 0, dy: 0, z: 1, rot: 0, fx: null, fy: null, blur: 0, ...o });

export function camera(t, ...moves) {
  const c = M();
  for (const m of moves.filter(Boolean)) { c.dx += m.dx; c.dy += m.dy; c.z *= m.z; c.rot += m.rot; c.blur = Math.max(c.blur, m.blur); if (m.fx != null) { c.fx = m.fx; c.fy = m.fy; } }
  return c;
}
// Apply a camera around its focus (default: canvas centre). Draw the scene inside fn.
export function withCamera(g, c, fn) {
  const W = g.canvas.width, H = g.canvas.height, fx = c.fx ?? W / 2, fy = c.fy ?? H / 2;
  g.save(); g.translate(fx, fy); g.rotate(c.rot); g.scale(c.z, c.z); g.translate(-fx - c.dx, -fy - c.dy);
  if (c.blur > 0.3) g.filter = `blur(${c.blur.toFixed(1)}px)`;
  fn(); g.restore();
}

export const CAM = {
  // (t, t0, dur, amount, [fx, fy]) style signatures; springs give mass, eases give constant-rate drifts.
  'push-in': (t, t0, dur, amount = 1.1, at) => M({ z: lerp(1, amount, prog(t, t0, dur, 'inOutSine')), fx: at?.[0] ?? null, fy: at?.[1] ?? null }),
  'pull-out': (t, t0, dur, amount = 1.1, at) => M({ z: lerp(amount, 1, prog(t, t0, dur, 'inOutSine')), fx: at?.[0] ?? null, fy: at?.[1] ?? null }),
  pan: (t, t0, dur, dist = 200) => M({ dx: dist * prog(t, t0, dur, 'inOutSine') }),
  tilt: (t, t0, dur, dist = 150) => M({ dy: dist * prog(t, t0, dur, 'inOutSine') }),
  'crane-pedestal': (t, t0, dur, dist = -200) => M({ dy: dist * sp(t - t0, 'camera') }),
  'snap-zoom': (t, t0, amount = 1.25, at) => M({ z: lerp(1, amount, sp(t - t0, 'snappy')), fx: at?.[0] ?? null, fy: at?.[1] ?? null }),
  'whip-pan-camera': (t, t0, dist = 1920) => { const p = EASE.inOutExpo(clamp((t - t0) / 0.35)); return M({ dx: dist * p, blur: Math.sin(Math.PI * clamp((t - t0) / 0.35)) * 18 }); },
  'seeded-shake': (t, t0, dur, amp = 10, freq = 18, seed = 1) => { const k = clamp(1 - (t - t0) / dur) * (t >= t0 ? 1 : 0); return M({ dx: noise1(t * freq, seed) * amp * k, dy: noise1(t * freq, seed + 9) * amp * k, rot: noise1(t * freq, seed + 3) * 0.004 * amp * k }); },
  'handheld-drift': (t, amp = 6, seed = 2) => M({ dx: noise1(t * 0.6, seed) * amp, dy: noise1(t * 0.5, seed + 4) * amp, rot: noise1(t * 0.4, seed + 7) * 0.002 * amp }),
  'dutch-roll': (t, t0, angle = 0.08) => M({ rot: angle * sp(t - t0, 'camera') }),
  'ken-burns': (t, t0, dur, from = [1, 0, 0], to = [1.12, 40, -20]) => { const p = prog(t, t0, dur, 'linear'); return M({ z: lerp(from[0], to[0], p), dx: lerp(from[1], to[1], p), dy: lerp(from[2], to[2], p) }); },
  // Zoom so rect [x, y, w, h] fills `fill` of the frame, centred. Spring-driven.
  'focus-zoom-to-rect': (t, t0, rect, W, H, fill = 0.8, release) => { const z = Math.min((W * fill) / rect[2], (H * fill) / rect[3]), p = sp(t - t0, 'camera') - (release != null ? sp(t - release, 'camera') : 0);
    const cx = rect[0] + rect[2] / 2, cy = rect[1] + rect[3] / 2; return M({ z: lerp(1, z, p), dx: (cx - W / 2) * p, dy: (cy - H / 2) * p }); },
  // Follow a cursor path given as spring tracks: keysX/keysY = [[t, v], ...]. Lags slightly behind for weight.
  'follow-cursor': (t, keysX, keysY, W, H, amount = 0.35) => M({ dx: (track(t - 0.12, keysX, 'camera') - W / 2) * amount, dy: (track(t - 0.12, keysY, 'camera') - H / 2) * amount }),
  'rack-focus': (t, t0, dur, maxBlur = 12) => M({ blur: maxBlur * (1 - prog(t, t0, dur, 'inOutCubic')) }),
  'orbit-2_5d': (t, t0, dur, angle = 0.35) => { const a = lerp(-angle, angle, prog(t, t0, dur, 'inOutSine')); return M({ dx: Math.sin(a) * 120, z: 1 + Math.abs(Math.sin(a)) * 0.03 }); },
};

// Parallax: layers [{ depth, draw }], depth 0 = far (moves least), 1 = camera plane. camX/camY are camera pans in px.
export function parallax(g, layers, camX = 0, camY = 0, zoom = 1) {
  const W = g.canvas.width, H = g.canvas.height;
  for (const L of layers) { const k = L.depth ?? 1, z = 1 + (zoom - 1) * k; g.save(); g.translate(W / 2, H / 2); g.scale(z, z); g.translate(-W / 2 - camX * k, -H / 2 - camY * k); if (L.blur) g.filter = `blur(${L.blur}px)`; L.draw(g); g.restore(); }
}
CAM['truck-parallax'] = (t, t0, dur, dist = 300) => M({ dx: dist * prog(t, t0, dur, 'inOutSine') }); // feed dx into parallax()
CAM['parallax-layers-drift'] = (t, speed = 20) => M({ dx: t * speed });
// Dolly zoom: background scales up while the subject stays the same size. Returns the two scales.
export const dollyZoom = (t, t0, dur, amount = 0.35) => { const p = prog(t, t0, dur, 'inOutSine'); return { bg: 1 + amount * p, fg: 1 }; };
CAM['dolly-zoom'] = (t, t0, dur, amount = 0.35) => M({ z: 1 + amount * prog(t, t0, dur, 'inOutSine') }); // apply to the background layer only
