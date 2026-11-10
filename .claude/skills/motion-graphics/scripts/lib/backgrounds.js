// backgrounds.js: generated backgrounds and frame post-effects, named after library/motion.json "backgrounds".
//
//   import { BG, POST, bg, post } from './backgrounds.js';
//   bg(g, 'dot-grid', t, { color: '#141413', ink: '#262C52' });   // paints the whole frame
//   ... draw the scene ...
//   post(g, 'vignette', t, { amount: 0.5 });                       // treats the finished frame
//
// All seeded and time-pure. Heavier ones carry a note; render cost matters at 60 fps x subframes.

import { clamp, lerp, rng, hash, noise2, makeGrain, grain, offscreen } from './motion.js';

const WH = (g) => [g.canvas.width, g.canvas.height];
const base = (g, col) => { if (!col) return; const [W, H] = WH(g); g.fillStyle = col; g.fillRect(0, 0, W, H); };
const U = (g) => Math.min(...WH(g)) / 100;
let GRAIN_TILES = null;

export const BG = {
  'dot-grid': (g, t, o) => { const [W, H] = WH(g), s = o.gap || 4 * U(g), r = o.dot || 0.18 * U(g); base(g, o.color); g.fillStyle = o.ink || 'rgba(255,255,255,0.18)'; const off = ((o.drift || 0) * t) % s;
    for (let y = s / 2 - off; y < H; y += s) for (let x = s / 2; x < W; x += s) { g.beginPath(); g.arc(x, y, r, 0, Math.PI * 2); g.fill(); } },
  'line-grid': (g, t, o) => { const [W, H] = WH(g), s = o.gap || 8 * U(g); base(g, o.color); g.strokeStyle = o.ink || 'rgba(255,255,255,0.08)'; g.lineWidth = o.width || 1; const off = ((o.drift || 0) * t) % s;
    g.beginPath(); for (let x = -off; x < W; x += s) { g.moveTo(x, 0); g.lineTo(x, H); } for (let y = 0; y < H; y += s) { g.moveTo(0, y); g.lineTo(W, y); } g.stroke(); },
  blueprint: (g, t, o) => { BG['line-grid'](g, t, { color: o.color || '#0E3A66', ink: 'rgba(200,230,255,0.10)', gap: 2 * U(g) }); BG['line-grid'](g, t, { ink: 'rgba(200,230,255,0.22)', gap: 10 * U(g), width: 1.5 }); },
  'isometric-grid': (g, t, o) => { const [W, H] = WH(g), s = o.gap || 6 * U(g); base(g, o.color); g.strokeStyle = o.ink || 'rgba(255,255,255,0.1)'; g.lineWidth = 1; const k = Math.tan(Math.PI / 6);
    g.beginPath(); for (let x = -H; x < W + H; x += s) { g.moveTo(x, 0); g.lineTo(x + H / k, H); g.moveTo(x, 0); g.lineTo(x - H / k, H); } for (let x = 0; x < W; x += s * k * 2) { g.moveTo(x, 0); g.lineTo(x, H); } g.stroke(); },
  'stripes-diagonal': (g, t, o) => { const [W, H] = WH(g), s = o.gap || 3 * U(g); base(g, o.color); g.fillStyle = o.ink || 'rgba(0,0,0,0.06)'; const off = ((o.speed ?? 20) * t) % (s * 2);
    g.save(); g.rotate(-Math.PI / 4); for (let x = -H * 2 + off; x < W * 2; x += s * 2) g.fillRect(x, -H * 2, s, H * 4); g.restore(); },
  'animated-gradient-mesh': (g, t, o) => { const [W, H] = WH(g), cols = o.colors || ['#5B5BD6', '#3b5bff', '#FFD84D', '#141413'], sp = o.speed ?? 0.15; base(g, o.color || cols[cols.length - 1]);
    g.save(); g.filter = `blur(${Math.round(W / 14)}px)`; cols.slice(0, -1).forEach((c, i) => { const x = W * (0.5 + 0.38 * noise2(i * 3.1, t * sp, 11)), y = H * (0.5 + 0.38 * noise2(i * 7.3, t * sp + 5, 13)), r = Math.max(W, H) * (0.28 + 0.08 * noise2(i, t * sp, 17));
      g.globalAlpha = o.alpha ?? 0.85; g.fillStyle = c; g.beginPath(); g.arc(x, y, r, 0, Math.PI * 2); g.fill(); }); g.restore(); },
  aurora: (g, t, o) => { const [W, H] = WH(g); base(g, o.color || '#05081c'); const cols = o.colors || ['#2de2a6', '#3b5bff', '#a64dff'];
    g.save(); g.globalCompositeOperation = 'lighter'; g.filter = `blur(${Math.round(H / 18)}px)`;
    cols.forEach((c, i) => { g.globalAlpha = 0.45; g.strokeStyle = c; g.lineWidth = H * 0.12; g.beginPath(); for (let x = -50; x <= W + 50; x += W / 40) { const y = H * (0.35 + i * 0.08) + noise2(x / W * 2 + i, t * 0.12, 30 + i) * H * 0.15; x < 0 ? g.moveTo(x, y) : g.lineTo(x, y); } g.stroke(); }); g.restore(); },
  'noise-flow-field': (g, t, o) => { const [W, H] = WH(g), s = o.gap || 3 * U(g), len = o.len || 2.2 * U(g); base(g, o.color); g.strokeStyle = o.ink || 'rgba(255,255,255,0.25)'; g.lineWidth = o.width || 1.4; g.lineCap = 'round';
    g.beginPath(); for (let y = s / 2; y < H; y += s) for (let x = s / 2; x < W; x += s) { const a = noise2(x / W * 3, y / H * 3 + t * (o.speed ?? 0.15), 4) * Math.PI * 2; g.moveTo(x, y); g.lineTo(x + Math.cos(a) * len, y + Math.sin(a) * len); } g.stroke(); },
  'topographic-contours': (g, t, o) => { // marching squares over seeded noise; cost: medium
    const [W, H] = WH(g), cs = o.cell || Math.round(W / 64), cols = Math.ceil(W / cs) + 1, rows = Math.ceil(H / cs) + 1, levels = o.levels || 9, sc = o.scale || 2.4, f = new Float32Array(cols * rows);
    base(g, o.color); for (let j = 0; j < rows; j++) for (let i = 0; i < cols; i++) f[j * cols + i] = noise2(i / cols * sc, j / rows * sc * (H / W) + t * (o.speed ?? 0.03), 7) * 0.6 + noise2(i / cols * sc * 2.3, j / rows * sc * 2.3, 9) * 0.25;
    g.strokeStyle = o.ink || 'rgba(255,255,255,0.22)'; g.lineWidth = o.width || 1.2; g.beginPath();
    for (let L = 0; L < levels; L++) { const lv = -0.75 + (1.5 * (L + 0.5)) / levels;
      for (let j = 0; j < rows - 1; j++) for (let i = 0; i < cols - 1; i++) { const a = f[j * cols + i], b = f[j * cols + i + 1], c = f[(j + 1) * cols + i + 1], d = f[(j + 1) * cols + i];
        const pts = []; const e = (v1, v2, x1, y1, x2, y2) => { if ((v1 < lv) !== (v2 < lv)) { const k = (lv - v1) / (v2 - v1); pts.push([lerp(x1, x2, k) * cs, lerp(y1, y2, k) * cs]); } };
        e(a, b, i, j, i + 1, j); e(b, c, i + 1, j, i + 1, j + 1); e(c, d, i + 1, j + 1, i, j + 1); e(d, a, i, j + 1, i, j);
        for (let k = 0; k + 1 < pts.length; k += 2) { g.moveTo(...pts[k]); g.lineTo(...pts[k + 1]); } } }
    g.stroke(); },
  halftone: (g, t, o) => { const [W, H] = WH(g), s = o.gap || 1.6 * U(g); base(g, o.color); g.fillStyle = o.ink || 'rgba(0,0,0,0.5)';
    for (let y = 0; y < H + s; y += s) for (let x = (Math.round(y / s) % 2) * s / 2; x < W + s; x += s) { const v = o.radial ? 1 - Math.hypot(x - W * (o.cx ?? 0.5), y - H * (o.cy ?? 0.5)) / Math.hypot(W, H) * 1.4 : (noise2(x / W * 2, y / H * 2 + t * 0.1, 3) + 1) / 2; const r = clamp(v) * s * 0.55; if (r > 0.3) { g.beginPath(); g.arc(x, y, r, 0, Math.PI * 2); g.fill(); } } },
  'paper-fibers': (g, t, o) => { const [W, H] = WH(g), key = `fibers-${W}x${H}-${o.color}`, c = offscreen(key, W, H), x = c.getContext('2d');
    // static texture: rebuilt each frame from the same seed (cheap enough at 600 strokes)
    x.fillStyle = o.color || '#F1E9DA'; x.fillRect(0, 0, W, H); const r = rng(o.seed || 5); x.strokeStyle = o.ink || 'rgba(120,90,60,0.07)'; x.lineWidth = 1;
    for (let i = 0; i < (o.count || 600); i++) { const x0 = r() * W, y0 = r() * H, a = r() * Math.PI * 2, l = (0.5 + r() * 2.5) * U(g); x.beginPath(); x.moveTo(x0, y0); x.quadraticCurveTo(x0 + Math.cos(a) * l, y0 + Math.sin(a + 1) * l, x0 + Math.cos(a) * l * 2, y0 + Math.sin(a) * l * 2); x.stroke(); }
    g.drawImage(c, 0, 0); },
  starfield: (g, t, o) => { const [W, H] = WH(g); base(g, o.color || '#04060f'); const r = rng(o.seed || 8), n = o.count || 400, sp = o.speed ?? 0.15;
    for (let i = 0; i < n; i++) { const x0 = r() - 0.5, y0 = r() - 0.5, z0 = r(), z = ((z0 - t * sp) % 1 + 1) % 1, k = 1 / (0.05 + z), x = W / 2 + x0 * W * k * 0.6, y = H / 2 + y0 * H * k * 0.6; if (x < 0 || x > W || y < 0 || y > H) continue;
      const s = o.pixel ? Math.ceil((1 - z) * 3) : (1 - z) * 2.4; g.fillStyle = `rgba(255,255,255,${0.3 + 0.7 * (1 - z)})`; o.pixel ? g.fillRect(Math.round(x), Math.round(y), s, s) : (g.beginPath(), g.arc(x, y, s, 0, Math.PI * 2), g.fill()); } },
  bokeh: (g, t, o) => { const [W, H] = WH(g); base(g, o.color); const r = rng(o.seed || 6), cols = o.colors || ['#ffd27a', '#ff9e7a', '#fff2c8']; g.save(); g.globalCompositeOperation = 'lighter';
    for (let i = 0; i < (o.count || 26); i++) { const x = r() * W + noise2(i, t * 0.1) * W * 0.05, y = r() * H + noise2(i + 50, t * 0.1) * H * 0.05, rr = (2 + r() * 7) * U(g); g.globalAlpha = 0.12 + r() * 0.18; g.fillStyle = cols[i % cols.length]; g.filter = `blur(${(r() * 6).toFixed(1)}px)`; g.beginPath(); g.arc(x, y, rr, 0, Math.PI * 2); g.fill(); } g.restore(); },
  'light-rays': (g, t, o) => { const [W, H] = WH(g); base(g, o.color); const cx = W * (o.x ?? 0.2), cy = H * (o.y ?? -0.1), n = o.count || 9; g.save(); g.globalCompositeOperation = 'screen'; g.filter = `blur(${Math.round(W / 120)}px)`;
    for (let i = 0; i < n; i++) { const a = 0.4 + (i / n) * 1.2 + noise2(i, t * 0.2) * 0.06, w = 0.03 + hash(i, 2) * 0.05; const gr = g.createLinearGradient(cx, cy, cx + Math.cos(a) * H * 1.6, cy + Math.sin(a) * H * 1.6); gr.addColorStop(0, o.ink || 'rgba(255,240,200,0.35)'); gr.addColorStop(1, 'rgba(255,240,200,0)');
      g.fillStyle = gr; g.beginPath(); g.moveTo(cx, cy); g.lineTo(cx + Math.cos(a - w) * H * 2, cy + Math.sin(a - w) * H * 2); g.lineTo(cx + Math.cos(a + w) * H * 2, cy + Math.sin(a + w) * H * 2); g.closePath(); g.fill(); } g.restore(); },
  'concentric-pulse': (g, t, o) => { const [W, H] = WH(g); base(g, o.color); const cx = W * (o.x ?? 0.5), cy = H * (o.y ?? 0.5), gap = o.gap || 8 * U(g), off = (t * (o.speed ?? 30)) % gap; g.strokeStyle = o.ink || 'rgba(255,255,255,0.1)'; g.lineWidth = o.width || 1.5;
    for (let r = off; r < Math.hypot(W, H); r += gap) { g.globalAlpha = clamp(1 - r / Math.hypot(W, H)); g.beginPath(); g.arc(cx, cy, r, 0, Math.PI * 2); g.stroke(); } g.globalAlpha = 1; },
  'bauhaus-shapes': (g, t, o) => { const [W, H] = WH(g); base(g, o.color || '#F2EBDD'); const cols = o.colors || ['#E63946', '#1D3557', '#F4C430', '#111111'], r = rng(o.seed || 3);
    for (let i = 0; i < (o.count || 7); i++) { const x = r() * W, y = r() * H, s = (6 + r() * 18) * U(g), kind = i % 3, rot = (r() - 0.5) + t * 0.05 * (i % 2 ? 1 : -1); g.save(); g.translate(x, y); g.rotate(rot); g.fillStyle = cols[i % cols.length]; g.globalAlpha = o.alpha ?? 1;
      if (kind === 0) { g.beginPath(); g.arc(0, 0, s / 2, 0, Math.PI * 2); g.fill(); } else if (kind === 1) g.fillRect(-s / 2, -s / 2, s, s); else { g.beginPath(); g.moveTo(0, -s / 2); g.lineTo(s / 2, s / 2); g.lineTo(-s / 2, s / 2); g.closePath(); g.fill(); } g.restore(); } },
  'rain-streaks': (g, t, o) => { const [W, H] = WH(g); base(g, o.color); const r = rng(o.seed || 21); g.save(); g.strokeStyle = o.ink || 'rgba(200,210,230,0.5)'; g.lineWidth = o.width || 0.22 * U(g); g.lineCap = 'round';
    for (let i = 0; i < (o.count || 90); i++) { const x0 = r() * W * 1.2, y0 = r() * H, s = (0.7 + r() * 0.5) * H * 1.1, len = (2.5 + r() * 3) * U(g), y = ((y0 + t * s) % (H + len)) - len, x = x0 - y * 0.18; g.beginPath(); g.moveTo(x, y); g.lineTo(x - len * 0.18, y + len); g.stroke(); } g.restore(); },
  snow: (g, t, o) => { const [W, H] = WH(g); base(g, o.color); const r = rng(o.seed || 31); g.fillStyle = o.ink || 'rgba(255,255,255,0.85)';
    for (let i = 0; i < (o.count || 160); i++) { const x0 = r() * W, y0 = r() * H, s = (0.04 + r() * 0.08) * H, rr = (0.15 + r() * 0.35) * U(g), y = (y0 + t * s) % H, x = x0 + Math.sin(t * (0.5 + r()) + i) * 2 * U(g); g.beginPath(); g.arc(x, y, rr, 0, Math.PI * 2); g.fill(); } },
  'confetti-burst': (g, t, o) => { // opt-in only: generic bursts are banned by default
    const [W, H] = WH(g), r = rng(o.seed || 41), cols = o.colors || ['#FFD84D', '#5B5BD6', '#ff5a64', '#2de2a6'], cx = W * (o.x ?? 0.5), cy = H * (o.y ?? 0.6), lt = t - (o.at ?? 0); if (lt < 0) return;
    for (let i = 0; i < (o.count || 120); i++) { const a = -Math.PI / 2 + (r() - 0.5) * 2.2, v = (0.6 + r()) * H * 1.2, x = cx + Math.cos(a) * v * lt, y = cy + Math.sin(a) * v * lt + 0.5 * H * 2.2 * lt * lt, rot = lt * (4 + r() * 8);
      g.save(); g.translate(x, y); g.rotate(rot); g.globalAlpha = clamp(1 - (lt - 1.6) / 0.6); g.fillStyle = cols[i % cols.length]; g.fillRect(-0.4 * U(g), -0.8 * U(g), 0.8 * U(g), 1.6 * U(g) * Math.abs(Math.cos(rot))); g.restore(); } },
  caustics: (g, t, o) => { const [W, H] = WH(g); base(g, o.color || '#0b4f6c'); g.save(); g.globalCompositeOperation = 'lighter'; g.strokeStyle = o.ink || 'rgba(160,240,255,0.18)'; g.lineWidth = 0.4 * U(g); g.filter = `blur(${(0.15 * U(g)).toFixed(1)}px)`;
    for (let k = 0; k < 2; k++) { g.beginPath(); for (let y = 0; y < H; y += 3 * U(g)) for (let x = 0; x <= W; x += W / 60) { const yy = y + noise2(x / W * 6 + k * 3, y / H * 6 + t * 0.4, 50 + k) * 2.5 * U(g); x === 0 ? g.moveTo(x, yy) : g.lineTo(x, yy); } g.stroke(); } g.restore(); },
};
BG['film-grain'] = (g, t, o) => POST['film-grain'](g, t, o);
BG.scanlines = (g, t, o) => POST.scanlines(g, t, o);

export const POST = {
  'film-grain': (g, t, o = {}) => { GRAIN_TILES ||= makeGrain(256, 8, o.seed || 3); grain(g, GRAIN_TILES, t, o.fps || 60, o.amount ?? 0.05); },
  vignette: (g, t, o = {}) => { const [W, H] = WH(g), gr = g.createRadialGradient(W / 2, H / 2, Math.min(W, H) * 0.35, W / 2, H / 2, Math.hypot(W, H) * 0.6); gr.addColorStop(0, 'rgba(0,0,0,0)'); gr.addColorStop(1, `rgba(0,0,0,${o.amount ?? 0.45})`); g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = gr; g.fillRect(0, 0, W, H); g.restore(); },
  scanlines: (g, t, o = {}) => { const [W, H] = WH(g), s = o.gap || 3; g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = `rgba(0,0,0,${o.amount ?? 0.18})`; for (let y = 0; y < H; y += s) g.fillRect(0, y, W, 1); g.restore(); },
  'chromatic-aberration': (g, t, o = {}) => { const [W, H] = WH(g), d = o.offset || W / 500, src = offscreen('ca-src', W, H); src.getContext('2d').drawImage(g.canvas, 0, 0);
    const out = offscreen('ca-out', W, H), x = out.getContext('2d'); x.fillStyle = '#000'; x.fillRect(0, 0, W, H);
    [['#f00', -d], ['#0f0', 0], ['#00f', d]].forEach(([col, dx]) => { const ch = offscreen('ca-ch', W, H), c = ch.getContext('2d'); c.drawImage(src, 0, 0); c.globalCompositeOperation = 'multiply'; c.fillStyle = col; c.fillRect(0, 0, W, H); x.globalCompositeOperation = 'lighter'; x.drawImage(ch, dx, 0); });
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.drawImage(out, 0, 0); g.restore(); },
  'vhs-tracking': (g, t, o = {}) => { const [W, H] = WH(g), src = offscreen('vhs', W, H); src.getContext('2d').drawImage(g.canvas, 0, 0); const f = Math.floor(t * 30), r = rng(f + 77);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); const bandY = ((t * 0.15) % 1.2 - 0.1) * H, bh = H * 0.06; for (let y = 0; y < H; y += 4) { const near = Math.abs(y - bandY) < bh, dx = near ? (r() - 0.5) * W * 0.03 : (r() - 0.5) * 1.5; g.drawImage(src, 0, y, W, 4, dx, y, W, 4); }
    g.fillStyle = 'rgba(255,255,255,0.08)'; g.fillRect(0, bandY, W, 2); POST.scanlines(g, t, { amount: 0.12, gap: 4 }); POST['chromatic-aberration'](g, t, { offset: W / 700 }); g.restore(); },
  crt: (g, t, o = {}) => { POST.scanlines(g, t, { amount: 0.22, gap: 3 }); POST['chromatic-aberration'](g, t, { offset: 1.5 }); POST.vignette(g, t, { amount: 0.6 });
    const [W, H] = WH(g); g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.globalAlpha = 0.04 + 0.02 * Math.sin(t * 120); g.fillStyle = '#fff'; g.fillRect(0, 0, W, H); g.restore(); },
  duotone: (g, t, o = {}) => { const [W, H] = WH(g), dark = o.dark || '#1D3557', light = o.light || '#F4C430', src = offscreen('duo', W, H), c = src.getContext('2d');
    c.filter = 'grayscale(1) contrast(1.15)'; c.drawImage(g.canvas, 0, 0); c.filter = 'none';
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.fillStyle = dark; g.fillRect(0, 0, W, H); g.globalCompositeOperation = 'screen'; g.drawImage(src, 0, 0); g.globalCompositeOperation = 'multiply'; g.fillStyle = light; g.fillRect(0, 0, W, H); g.restore(); },
  'ordered-dither': (g, t, o = {}) => { const [W, H] = WH(g), s = o.pixel || 3, w = Math.ceil(W / s), h = Math.ceil(H / s), sm = offscreen('od', w, h), x = sm.getContext('2d'); x.drawImage(g.canvas, 0, 0, w, h);
    const d = x.getImageData(0, 0, w, h), B = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5], ink = o.ink || [9, 12, 51], paper = o.paper || [238, 255, 118];
    for (let yy = 0; yy < h; yy++) for (let xx = 0; xx < w; xx++) { const i = (yy * w + xx) * 4, l = (0.2126 * d.data[i] + 0.7152 * d.data[i + 1] + 0.0722 * d.data[i + 2]) / 255, on = l > (B[(yy % 4) * 4 + (xx % 4)] + 0.5) / 16, c = on ? paper : ink; d.data[i] = c[0]; d.data[i + 1] = c[1]; d.data[i + 2] = c[2]; }
    x.putImageData(d, 0, 0); g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.imageSmoothingEnabled = false; g.drawImage(sm, 0, 0, W, H); g.restore(); },
  'risograph-misregistration': (g, t, o = {}) => { const [W, H] = WH(g), d = o.offset || W / 400, src = offscreen('riso', W, H); src.getContext('2d').drawImage(g.canvas, 0, 0);
    g.save(); g.setTransform(1, 0, 0, 1, 0, 0); g.globalCompositeOperation = 'multiply'; g.globalAlpha = 0.55; g.drawImage(src, d * Math.cos(t * 0.3), d * Math.sin(t * 0.2)); g.restore(); POST['film-grain'](g, t, { amount: 0.07 }); },
};
export const bg = (g, name, t, o = {}) => { const f = BG[name]; if (!f) throw new Error(`unknown background: ${name}. Known: ${Object.keys(BG).join(', ')}`); g.save(); f(g, t, o); g.restore(); };
export const post = (g, name, t, o = {}) => { const f = POST[name]; if (!f) throw new Error(`unknown post effect: ${name}. Known: ${Object.keys(POST).join(', ')}`); f(g, t, o); };
