// transitions.js: scene-to-scene transitions, named after library/motion.json "transitions".
//
//   import { transition, TRANSITIONS } from './transitions.js';
//   transition(g, 'iris-circle-wipe', p, A, B, { x, y });
//
// p is raw progress 0..1 (use prog(t, t0, dur)); each transition applies its own easing unless o.ease is set.
// A and B are scene functions (ctx) => void that paint a full frame. Pure functions of time: no state.
// Editorial names (match-cut, cut-on-action, j-cut-l-cut) are hard cuts with intent; container-morph and
// morph-shape-to-shape are patterns (see modes/launch.md), not frame transitions.

import { clamp, lerp, EASE, rng, hash, noise2, layerOf, offscreen, rrect } from './motion.js';

const E = (o, def) => EASE[o.ease || def];
const size = (g) => [g.canvas.width, g.canvas.height];
const diag = (g) => Math.hypot(g.canvas.width, g.canvas.height);
const dirVec = (d = 'left') => ({ left: [-1, 0], right: [1, 0], up: [0, -1], down: [0, 1] }[d]);
const draw = (g, c, alpha = 1, filter = 'none') => { g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.globalAlpha = alpha; g.filter = filter; g.drawImage(c, 0, 0); g.restore(); };
const clipped = (g, path, fn) => { g.save(); g.beginPath(); path(g); g.clip(); fn(g); g.restore(); };
const masked = (g, B, maskDraw) => { // B painted where maskDraw paints (mask drawn on its own canvas, applied once)
  const cb = layerOf(g, 'tB', B), mk = layerOf(g, 'tMask', (m) => maskDraw(m)), x = cb.getContext('2d');
  x.globalCompositeOperation = 'destination-in'; x.drawImage(mk, 0, 0); x.globalCompositeOperation = 'source-over';
  draw(g, cb);
};

function star(g, cx, cy, r, n = 5, inner = 0.45, rot = -Math.PI / 2) {
  for (let i = 0; i < n * 2; i++) { const a = rot + (i * Math.PI) / n, rr = i % 2 ? r * inner : r; i ? g.lineTo(cx + Math.cos(a) * rr, cy + Math.sin(a) * rr) : g.moveTo(cx + Math.cos(a) * rr, cy + Math.sin(a) * rr); }
  g.closePath();
}
function shapePath(g, shape, cx, cy, r, rot = 0) {
  if (shape === 'circle') return g.arc(cx, cy, r, 0, Math.PI * 2);
  if (shape === 'star') return star(g, cx, cy, r, 5, 0.45, rot - Math.PI / 2);
  if (shape === 'starburst') return star(g, cx, cy, r, 12, 0.7, rot);
  const n = { triangle: 3, square: 4, diamond: 4, hexagon: 6 }[shape] || 4;
  const off = shape === 'square' ? Math.PI / 4 : shape === 'triangle' ? -Math.PI / 2 : 0;
  for (let i = 0; i < n; i++) { const a = rot + off + (i * 2 * Math.PI) / n; i ? g.lineTo(cx + Math.cos(a) * r, cy + Math.sin(a) * r) : g.moveTo(cx + Math.cos(a) * r, cy + Math.sin(a) * r); }
  g.closePath();
}

// Channel split: paint `src` (canvas) as separated R, G, B copies with offsets.
function rgbSplit(g, src, dx, dy = 0) {
  const [W, H] = size(g);
  const out = offscreen('rgb-out', W, H), o = out.getContext('2d');
  o.fillStyle = '#000'; o.fillRect(0, 0, W, H);
  [['#f00', -dx, -dy], ['#0f0', 0, 0], ['#00f', dx, dy]].forEach(([col, ox, oy], i) => {
    const ch = offscreen('rgb-ch', W, H), c = ch.getContext('2d');
    c.drawImage(src, 0, 0); c.globalCompositeOperation = 'multiply'; c.fillStyle = col; c.fillRect(0, 0, W, H);
    c.globalCompositeOperation = 'destination-in'; c.drawImage(src, 0, 0);
    o.globalCompositeOperation = 'lighter'; o.drawImage(ch, ox, oy);
  });
  draw(g, out);
}

export const TRANSITIONS = {
  'hard-cut': (g, p, A, B) => (p < 0.5 ? A(g) : B(g)),
  'smash-cut': (g, p, A, B, o) => { (p < 0.5 ? A : B)(g); const f = clamp(1 - Math.abs(p - 0.53) / 0.06); if (f > 0) { const [W, H] = size(g); g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.globalAlpha = f; g.fillStyle = o.color || '#fff'; g.fillRect(0, 0, W, H); g.restore(); } },
  'crossfade-dissolve': (g, p, A, B, o) => { A(g); draw(g, layerOf(g, 'tB', B), E(o, 'inOutSine')(p)); },
  'blur-crossfade': (g, p, A, B, o) => { const e = E(o, 'inOutCubic')(p), m = o.blur || 24; draw(g, layerOf(g, 'tA', A), 1, `blur(${(e * m).toFixed(1)}px)`); draw(g, layerOf(g, 'tB', B), e, `blur(${((1 - e) * m).toFixed(1)}px)`); },
  'dip-to-color': (g, p, A, B, o) => { const [W, H] = size(g); (p < 0.5 ? A : B)(g); g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.globalAlpha = EASE.inOutSine(p < 0.5 ? p * 2 : (1 - p) * 2); g.fillStyle = o.color || '#000'; g.fillRect(0, 0, W, H); g.restore(); },
  'fade-through': (g, p, A, B, o) => { const [W, H] = size(g); g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = o.color || '#fff'; g.fillRect(0, 0, W, H); g.restore();
    if (p < 0.35) draw(g, layerOf(g, 'tA', A), 1 - EASE.outCubic(p / 0.35));
    else { const e = EASE.outCubic((p - 0.35) / 0.65), cb = layerOf(g, 'tB', B), s = lerp(0.92, 1, e); g.save(); g.setTransform(s, 0, 0, s, (W * (1 - s)) / 2, (H * (1 - s)) / 2); g.globalAlpha = e; g.drawImage(cb, 0, 0); g.restore(); } },
  'luma-fade': (g, p, A, B, o) => { // B appears where A is darkest first (or brightest with o.invert)
    const [W, H] = size(g); const ca = layerOf(g, 'tA', A); draw(g, ca);
    const s = 8, w = Math.ceil(W / s), h = Math.ceil(H / s), small = offscreen('luma-s', w, h), sx = small.getContext('2d');
    sx.drawImage(ca, 0, 0, w, h); const d = sx.getImageData(0, 0, w, h), e = E(o, 'inOutSine')(p) * 1.1;
    for (let i = 0; i < d.data.length; i += 4) { let l = (0.2126 * d.data[i] + 0.7152 * d.data[i + 1] + 0.0722 * d.data[i + 2]) / 255; if (o.invert) l = 1 - l; const a = clamp((e - l) / 0.1); d.data[i + 3] = a * 255; }
    sx.putImageData(d, 0, 0);
    masked(g, B, (m) => { m.imageSmoothingEnabled = true; m.drawImage(small, 0, 0, W, H); }); },
  'shared-axis': (g, p, A, B, o) => { const [W, H] = size(g), ax = o.axis || 'x', d = (o.distance || 0.06) * (ax === 'y' ? H : W), e = E(o, 'outCubic')(p);
    const ca = layerOf(g, 'tA', A), cb = layerOf(g, 'tB', B);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0);
    if (ax === 'z') { const sa = lerp(1, 1.1, e), sb = lerp(0.8, 1, e); g.globalAlpha = EASE.outCubic(clamp(p / 0.6)); g.setTransform(sb, 0, 0, sb, (W * (1 - sb)) / 2, (H * (1 - sb)) / 2); g.drawImage(cb, 0, 0); g.globalAlpha = clamp(1 - p / 0.45); g.setTransform(sa, 0, 0, sa, (W * (1 - sa)) / 2, (H * (1 - sa)) / 2); g.drawImage(ca, 0, 0); }
    else { const vx = ax === 'x' ? 1 : 0, vy = 1 - vx; g.globalAlpha = EASE.outCubic(clamp(p / 0.6)); g.drawImage(cb, d * (1 - e) * vx, d * (1 - e) * vy); g.globalAlpha = clamp(1 - p / 0.45); g.drawImage(ca, -d * e * vx, -d * e * vy); }
    g.restore(); },
  push: (g, p, A, B, o) => { const [W, H] = size(g), [vx, vy] = dirVec(o.dir || 'left'), e = E(o, 'inOutCubic')(p);
    const ca = layerOf(g, 'tA', A), cb = layerOf(g, 'tB', B); g.save(); g.setTransform(1, 0, 0, 1, 0, 0);
    g.drawImage(ca, vx * W * e, vy * H * e); g.drawImage(cb, -vx * W * (1 - e), -vy * H * (1 - e)); g.restore(); },
  'slide-over': (g, p, A, B, o) => { const [W, H] = size(g), [vx, vy] = dirVec(o.dir || 'left'), e = E(o, 'outCubic')(p);
    A(g); g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = `rgba(0,0,0,${0.25 * e})`; g.fillRect(0, 0, W, H);
    g.shadowColor = 'rgba(0,0,0,0.35)'; g.shadowBlur = 40; g.drawImage(layerOf(g, 'tB', B), -vx * W * (1 - e), -vy * H * (1 - e)); g.restore(); },
  'linear-wipe': (g, p, A, B, o) => { const [W, H] = size(g), [vx, vy] = dirVec(o.dir || 'right'), e = E(o, 'inOutCubic')(p);
    A(g); clipped(g, (c) => (vx ? c.rect(vx > 0 ? 0 : W * (1 - e), 0, W * e, H) : c.rect(0, vy > 0 ? 0 : H * (1 - e), W, H * e)), B);
    if (o.bar) { g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = o.bar; const b = o.barWidth || 12; vx ? g.fillRect((vx > 0 ? W * e : W * (1 - e)) - b / 2, 0, b, H) : g.fillRect(0, (vy > 0 ? H * e : H * (1 - e)) - b / 2, W, b); g.restore(); } },
  'diagonal-wipe': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutCubic')(p), sk = (o.angle ?? 0.35) * H, x = lerp(-sk, W + sk, e);
    A(g); clipped(g, (c) => { c.moveTo(0, 0); c.lineTo(x + sk, 0); c.lineTo(x - sk, H); c.lineTo(0, H); c.closePath(); }, B); },
  'clock-wipe': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutCubic')(p), cx = o.x ?? W / 2, cy = o.y ?? H / 2;
    A(g); clipped(g, (c) => { c.moveTo(cx, cy); c.arc(cx, cy, diag(g), -Math.PI / 2, -Math.PI / 2 + e * Math.PI * 2); c.closePath(); }, B); },
  'iris-circle-wipe': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutCubic')(p), cx = o.x ?? W / 2, cy = o.y ?? H / 2;
    A(g); clipped(g, (c) => c.arc(cx, cy, e * diag(g), 0, Math.PI * 2), B);
    if (o.ring) { g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.strokeStyle = o.ring; g.lineWidth = o.ringWidth || 10; g.beginPath(); g.arc(cx, cy, e * diag(g), 0, Math.PI * 2); g.stroke(); g.restore(); } },
  'shape-wipe': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutCubic')(p), cx = o.x ?? W / 2, cy = o.y ?? H / 2, sh = o.shape || 'diamond';
    A(g); clipped(g, (c) => shapePath(c, sh, cx, cy, e * diag(g) * (sh === 'star' ? 1.9 : sh === 'triangle' ? 2.1 : 1.45), (o.spin ?? 0.6) * e), B); },
  'portal-shape': (g, p, A, B, o) => TRANSITIONS['shape-wipe'](g, p, A, B, { shape: 'circle', ...o, spin: 0 }),
  'blinds-venetian': (g, p, A, B, o) => { const [W, H] = size(g), n = o.count || 8, vert = o.vertical, st = o.stagger ?? 0.4;
    A(g); clipped(g, (c) => { for (let i = 0; i < n; i++) { const e = EASE.inOutCubic(clamp((p - (i / n) * st) / (1 - st))); vert ? c.rect((i * W) / n, 0, (W / n) * e, H) : c.rect(0, (i * H) / n, W, (H / n) * e); } }, B); },
  'stripes-wipe': (g, p, A, B, o) => { const [W, H] = size(g), n = o.count || 7, st = o.stagger ?? 0.35, sk = H * 0.4, sw = (W + sk) / n;
    A(g); clipped(g, (c) => { for (let i = 0; i < n; i++) { const e = EASE.inOutCubic(clamp((p - (i / n) * st) / (1 - st))), x0 = i * sw - sk, h = H * e;
      c.moveTo(x0 + sk, 0); c.lineTo(x0 + sk + sw, 0); c.lineTo(x0 + sk + sw - sk * (h / H), h); c.lineTo(x0 + sk - sk * (h / H), h); c.closePath(); } }, B); },
  'split-reveal': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutCubic')(p), ca = layerOf(g, 'tA', A); B(g);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0);
    if (o.vertical) { g.drawImage(ca, 0, 0, W / 2, H, -W / 2 * e, 0, W / 2, H); g.drawImage(ca, W / 2, 0, W / 2, H, W / 2 + (W / 2) * e, 0, W / 2, H); }
    else { g.drawImage(ca, 0, 0, W, H / 2, 0, -H / 2 * e, W, H / 2); g.drawImage(ca, 0, H / 2, W, H / 2, 0, H / 2 + (H / 2) * e, W, H / 2); }
    g.restore(); },
  'whip-pan': (g, p, A, B, o) => { const [W, H] = size(g), [vx] = dirVec(o.dir || 'left'), e = EASE.inOutExpo(p), speed = Math.sin(Math.PI * p);
    const ca = layerOf(g, 'tA', A), cb = layerOf(g, 'tB', B), n = 8, blur = speed * W * 0.08;
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0);
    for (let k = 0; k < n; k++) { const off = (k / (n - 1) - 0.5) * blur; g.globalAlpha = 1 / n * 1.6;
      g.drawImage(ca, vx * W * e + off, 0); g.drawImage(cb, -vx * W * (1 - e) + vx * 0 + off, 0); }
    g.restore(); },
  'zoom-through': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutCubic')(p), ca = layerOf(g, 'tA', A), cb = layerOf(g, 'tB', B), cx = o.x ?? W / 2, cy = o.y ?? H / 2;
    g.save(); const sa = lerp(1, 3, e), sb = lerp(0.6, 1, e);
    g.setTransform(sb, 0, 0, sb, cx * (1 - sb), cy * (1 - sb)); g.globalAlpha = clamp((p - 0.25) / 0.5); g.filter = `blur(${((1 - e) * 10).toFixed(1)}px)`; g.drawImage(cb, 0, 0);
    g.setTransform(sa, 0, 0, sa, cx * (1 - sa), cy * (1 - sa)); g.globalAlpha = clamp(1 - (p - 0.2) / 0.5); g.filter = `blur(${(e * 14).toFixed(1)}px)`; g.drawImage(ca, 0, 0); g.restore(); },
  'zoom-blur-punch': (g, p, A, B, o) => { const [W, H] = size(g), src = layerOf(g, 'tS', p < 0.5 ? A : B), k = Math.sin(Math.PI * p), n = 7, cx = o.x ?? W / 2, cy = o.y ?? H / 2;
    g.save(); for (let i = 0; i < n; i++) { const s = 1 + k * 0.35 * (i / (n - 1)); g.setTransform(s, 0, 0, s, cx * (1 - s), cy * (1 - s)); g.globalAlpha = i === 0 ? 1 : 0.22; g.drawImage(src, 0, 0); } g.restore(); },
  'text-mask-reveal': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutExpo')(p), text = o.text || 'GO', font = o.font || '900 200px sans-serif';
    A(g); if (e > 0.92) { draw(g, layerOf(g, 'tB', B), (e - 0.92) / 0.08); }
    masked(g, B, (m) => { m.save(); m.translate(o.x ?? W / 2, o.y ?? H / 2); const s = lerp(1, 40, e * e); m.scale(s, s); m.font = font; m.textAlign = 'center'; m.textBaseline = 'middle'; m.fillStyle = '#000'; m.fillText(text, 0, 0); m.restore(); }); },
  'ink-liquid-bleed': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutSine')(p), cx = o.x ?? W / 2, cy = o.y ?? H / 2, R = diag(g), r = rng(o.seed || 9);
    A(g); masked(g, B, (m) => { m.filter = `blur(${Math.max(2, W / 300)}px)`; m.fillStyle = '#000';
      for (let i = 0; i < 46; i++) { const a = r() * Math.PI * 2, dist = r() * 0.5 * R, delay = r() * 0.45, ee = clamp((e - delay) / (1 - delay));
        const rr = ee * (0.18 + r() * 0.3) * R + noise2(i, e * 3, 5) * 6; if (rr <= 0) continue; m.beginPath(); m.arc(cx + Math.cos(a) * dist * ee, cy + Math.sin(a) * dist * ee, rr, 0, Math.PI * 2); m.fill(); }
      if (e > 0.85) { m.globalAlpha = (e - 0.85) / 0.15; m.fillRect(0, 0, W, H); } }); },
  'page-turn': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutCubic')(p), x = W * (1 - e), ca = layerOf(g, 'tA', A), flap = Math.min(W - x, x) * 0.6;
    B(g); g.save(); g.setTransform(1, 0, 0, 1, 0, 0);
    g.drawImage(ca, 0, 0, x, H, 0, 0, x, H); // A left of the fold
    if (flap > 1) { g.save(); g.beginPath(); g.rect(x - flap, 0, flap, H); g.clip(); g.translate(2 * x, 0); g.scale(-1, 1); g.drawImage(ca, 0, 0); g.restore(); // mirrored back of the page
      const gr = g.createLinearGradient(x - flap, 0, x, 0); gr.addColorStop(0, 'rgba(255,255,255,0.35)'); gr.addColorStop(0.8, 'rgba(0,0,0,0.1)'); gr.addColorStop(1, 'rgba(0,0,0,0.35)'); g.fillStyle = gr; g.fillRect(x - flap, 0, flap, H);
      const sh = g.createLinearGradient(x, 0, x + 60, 0); sh.addColorStop(0, 'rgba(0,0,0,0.3)'); sh.addColorStop(1, 'rgba(0,0,0,0)'); g.fillStyle = sh; g.fillRect(x, 0, 60, H); }
    g.restore(); },
  'pixel-dissolve': (g, p, A, B, o) => { const [W, H] = size(g), cs = o.cell || Math.round(W / 40), cols = Math.ceil(W / cs), rows = Math.ceil(H / cs), e = E(o, 'linear')(p);
    A(g); clipped(g, (c) => { for (let j = 0; j < rows; j++) for (let i = 0; i < cols; i++) if (hash(j * cols + i, o.seed || 3) < e) c.rect(i * cs, j * cs, cs + 0.5, cs + 0.5); }, B); },
  'dither-dissolve': (g, p, A, B, o) => { const [W, H] = size(g), s = o.pixel || 4, w = Math.ceil(W / s), h = Math.ceil(H / s), e = p * 1.02;
    const BAY = [0, 32, 8, 40, 2, 34, 10, 42, 48, 16, 56, 24, 50, 18, 58, 26, 12, 44, 4, 36, 14, 46, 6, 38, 60, 28, 52, 20, 62, 30, 54, 22, 3, 35, 11, 43, 1, 33, 9, 41, 51, 19, 59, 27, 49, 17, 57, 25, 15, 47, 7, 39, 13, 45, 5, 37, 63, 31, 55, 23, 61, 29, 53, 21];
    const mc = offscreen('dither', w, h), mx = mc.getContext('2d'), d = mx.createImageData(w, h);
    for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) d.data[(y * w + x) * 4 + 3] = BAY[(y % 8) * 8 + (x % 8)] / 64 < e ? 255 : 0;
    mx.putImageData(d, 0, 0); A(g); masked(g, B, (m) => { m.imageSmoothingEnabled = false; m.drawImage(mc, 0, 0, W, H); }); },
  'mosaic-pixelate': (g, p, A, B, o) => { const [W, H] = size(g), k = Math.sin(Math.PI * p), bs = Math.max(1, Math.round(1 + k * (o.max || W / 24))), src = layerOf(g, 'tS', p < 0.5 ? A : B);
    const w = Math.max(1, Math.round(W / bs)), h = Math.max(1, Math.round(H / bs)), sm = offscreen('mosaic', w, h); sm.getContext('2d').drawImage(src, 0, 0, w, h);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.imageSmoothingEnabled = false; g.drawImage(sm, 0, 0, W, H); g.restore(); },
  'glitch-rgb-split': (g, p, A, B, o) => { const [W, H] = size(g), k = Math.sin(Math.PI * p), src = layerOf(g, 'tS', p < 0.5 ? A : B), f = Math.floor(p * 60), r = rng(1000 + f);
    const sl = offscreen('glitch', W, H), sx = sl.getContext('2d'); sx.drawImage(src, 0, 0);
    const n = Math.round(4 + k * 10); for (let i = 0; i < n; i++) { const y = r() * H, h = (0.01 + r() * 0.06) * H, dx = (r() - 0.5) * W * 0.12 * k; sx.drawImage(src, 0, y, W, h, dx, y, W, h); }
    rgbSplit(g, sl, k * W * 0.012, 0); },
  'chromatic-slide': (g, p, A, B, o) => { const [W, H] = size(g), [vx] = dirVec(o.dir || 'left'), e = EASE.inOutCubic(p), sp = Math.sin(Math.PI * p);
    const fr = offscreen('chroma', W, H), fx = fr.getContext('2d'); fx.drawImage(layerOf(g, 'tA', A), vx * W * e, 0); fx.drawImage(layerOf(g, 'tB', B), -vx * W * (1 - e), 0);
    rgbSplit(g, fr, sp * W * 0.02 * vx, 0); },
  'light-leak-flash': (g, p, A, B, o) => { const [W, H] = size(g), k = Math.sin(Math.PI * p);
    TRANSITIONS['crossfade-dissolve'](g, clamp((p - 0.3) / 0.4), A, B, {});
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.globalCompositeOperation = 'screen';
    [[0.2 + 0.6 * p, 0.3, '#ffb347'], [0.8 - 0.5 * p, 0.7, '#ff5e3a'], [0.5, 0.5, '#fff3c4']].forEach(([fx, fy, col], i) => {
      const gr = g.createRadialGradient(W * fx, H * fy, 0, W * fx, H * fy, W * (0.4 + 0.2 * i)); gr.addColorStop(0, col); gr.addColorStop(1, 'rgba(0,0,0,0)');
      g.globalAlpha = k * (i === 2 ? 0.8 : 0.9); g.fillStyle = gr; g.fillRect(0, 0, W, H); });
    g.restore(); },
  'film-burn': (g, p, A, B, o) => { const [W, H] = size(g); (p < 0.5 ? A : B)(g); const k = Math.sin(Math.PI * p), r = rng(o.seed || 4);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.globalCompositeOperation = 'screen'; g.filter = `blur(${W / 60}px)`;
    for (let i = 0; i < 9; i++) { const x = r() * W, y = r() * H, rr = (0.1 + r() * 0.35) * W * (0.3 + k); g.globalAlpha = k; g.fillStyle = i % 3 ? '#ff7a1a' : '#fff1c2'; g.beginPath(); g.arc(x + noise2(i, p * 2) * W * 0.05, y, rr, 0, Math.PI * 2); g.fill(); }
    g.restore(); },
  spin: (g, p, A, B, o) => { const [W, H] = size(g), half = p < 0.5, e = half ? EASE.inCubic(p * 2) : EASE.outCubic((p - 0.5) * 2), c = layerOf(g, 'tS', half ? A : B);
    const s = half ? 1 - e : e, a = (half ? e : e - 1) * Math.PI * (o.turns ?? 1);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = o.color || '#000'; g.fillRect(0, 0, W, H); g.translate(W / 2, H / 2); g.rotate(a); g.scale(Math.max(s, 0.001), Math.max(s, 0.001)); g.drawImage(c, -W / 2, -H / 2); g.restore(); },
  'card-flip': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutCubic')(p), sx = Math.abs(Math.cos(Math.PI * e)), c = layerOf(g, 'tS', e < 0.5 ? A : B);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = o.color || '#000'; g.fillRect(0, 0, W, H);
    const sc = 1 - 0.12 * Math.sin(Math.PI * e); g.translate(W / 2, H / 2); g.scale(sx * sc, sc); g.drawImage(c, -W / 2, -H / 2);
    g.fillStyle = `rgba(0,0,0,${0.5 * (1 - sx)})`; g.fillRect(-W / 2, -H / 2, W, H); g.restore(); },
  'deck-shuffle': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutCubic')(p), cb = layerOf(g, 'tB', B), ca = layerOf(g, 'tA', A), s = lerp(0.94, 1, e);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = o.color || '#000'; g.fillRect(0, 0, W, H);
    g.setTransform(s, 0, 0, s, (W * (1 - s)) / 2, (H * (1 - s)) / 2); g.drawImage(cb, 0, 0);
    g.setTransform(1, 0, 0, 1, 0, 0); g.translate(W / 2 - e * W * 1.1, H / 2 + e * H * 0.15); g.rotate(-e * 0.25); g.shadowColor = 'rgba(0,0,0,0.4)'; g.shadowBlur = 50; g.drawImage(ca, -W / 2, -H / 2); g.restore(); },
  'accordion-fold': (g, p, A, B, o) => { const [W, H] = size(g), n = o.count || 6, e = E(o, 'inOutCubic')(p), pw = W / n, ca = layerOf(g, 'tA', A);
    B(g); g.save(); g.setTransform(1, 0, 0, 1, 0, 0);
    for (let i = 0; i < n; i++) { const s = 1 - e, cx = (i + 0.5) * pw * (1 - e * 0.0); g.save(); g.translate(cx, 0); g.scale(Math.max(s, 0.001), 1); g.drawImage(ca, i * pw, 0, pw, H, -pw / 2, 0, pw, H);
      g.fillStyle = `rgba(0,0,0,${(i % 2 ? 0.45 : 0.15) * e})`; g.fillRect(-pw / 2, 0, pw, H); g.restore(); }
    g.restore(); },
  'grid-tile-flip': (g, p, A, B, o) => { const [W, H] = size(g), cols = o.cols || 8, rows = o.rows || Math.round(cols * H / W), tw = W / cols, th = H / rows, ca = layerOf(g, 'tA', A), cb = layerOf(g, 'tB', B);
    const ox = o.x ?? 0, oy = o.y ?? 0, maxd = Math.hypot(W, H);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = o.color || '#000'; g.fillRect(0, 0, W, H);
    for (let j = 0; j < rows; j++) for (let i = 0; i < cols; i++) { const d = Math.hypot(i * tw + tw / 2 - ox, j * th + th / 2 - oy) / maxd, e = EASE.inOutCubic(clamp((p - d * 0.5) / 0.5)), sy = Math.abs(Math.cos(Math.PI * e)), src = e < 0.5 ? ca : cb;
      g.save(); g.translate(i * tw + tw / 2, j * th + th / 2); g.scale(1, Math.max(sy, 0.001)); g.drawImage(src, i * tw, j * th, tw, th, -tw / 2 - 0.5, -th / 2 - 0.5, tw + 1, th + 1); g.restore(); }
    g.restore(); },
  'scale-through-object': (g, p, A, B, o) => { const [W, H] = size(g), r = o.rect || [W * 0.4, H * 0.4, W * 0.2, H * 0.2], e = E(o, 'inOutExpo')(p);
    const z = lerp(1, Math.min(W / r[2], H / r[3]), e), fx = lerp(W / 2, r[0] + r[2] / 2, e), fy = lerp(H / 2, r[1] + r[3] / 2, e);
    g.save(); g.setTransform(z, 0, 0, z, W / 2 - fx * z, H / 2 - fy * z); A(g); g.restore();
    if (p > 0.6) draw(g, layerOf(g, 'tB', B), (p - 0.6) / 0.4); },
  'swipe-up-social': (g, p, A, B, o) => { const [W, H] = size(g), e = E(o, 'inOutCubic')(p), k = Math.sin(Math.PI * p), ca = layerOf(g, 'tA', A), cb = layerOf(g, 'tB', B), r = 0.04 * W * k, s = 1 - 0.06 * k;
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = o.color || '#000'; g.fillRect(0, 0, W, H);
    [[ca, -H * e], [cb, H * (1 - e)]].forEach(([c, y]) => { g.save(); g.translate(W / 2, H / 2 + y); g.scale(s, s); rrect(g, -W / 2, -H / 2, W, H, r); g.clip(); g.drawImage(c, -W / 2, -H / 2); g.restore(); });
    g.restore(); },
  'radial-wipe-burst': (g, p, A, B, o) => { const [W, H] = size(g), n = o.count || 12, e = E(o, 'inOutCubic')(p), cx = o.x ?? W / 2, cy = o.y ?? H / 2, R = diag(g);
    A(g); clipped(g, (c) => { for (let i = 0; i < n; i++) { const a0 = (i / n) * Math.PI * 2 + e * 0.6, w = (Math.PI * 2 / n) * e; c.moveTo(cx, cy); c.arc(cx, cy, R, a0, a0 + w); c.closePath(); } }, B); },
  'slit-scan-stretch': (g, p, A, B, o) => { const [W, H] = size(g), n = o.slices || 24, sw = W / n, ca = layerOf(g, 'tA', A), cb = layerOf(g, 'tB', B);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0);
    for (let i = 0; i < n; i++) { const e = EASE.inOutCubic(clamp((p - (i / n) * 0.4) / 0.6)); g.drawImage(ca, i * sw, 0, sw, H, i * sw, -H * e, sw + 0.5, H); g.drawImage(cb, i * sw, 0, sw, H, i * sw, H * (1 - e), sw + 0.5, H); }
    g.restore(); },
};
// Editorial aliases: the cut is the transition; the intent lives in the edit.
TRANSITIONS['match-cut'] = TRANSITIONS['cut-on-action'] = TRANSITIONS['j-cut-l-cut'] = TRANSITIONS['hard-cut'];

export function transition(g, name, p, A, B, o = {}) {
  const fn = TRANSITIONS[name];
  if (!fn) throw new Error(`unknown transition: ${name}. Known: ${Object.keys(TRANSITIONS).join(', ')}`);
  p = clamp(p);
  if (p <= 0) return A(g);
  if (p >= 1) return B(g);
  fn(g, p, A, B, o);
}
