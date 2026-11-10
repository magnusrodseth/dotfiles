// motion.js: deterministic motion primitives for seek(t) films.
// Every function is a pure function of time. No timers, no state between frames.

export const clamp = (x, a = 0, b = 1) => Math.min(b, Math.max(a, x));
export const lerp = (a, b, p) => a + (b - a) * p;
export const inv = (a, b, x) => clamp((x - a) / (b - a)); // 0..1 progress of x through [a, b]

// Closed-form damped spring, 0 -> 1, starting at t = 0.
export function spring(t, k = 170, d = 26) {
  if (t <= 0) return 0;
  const w0 = Math.sqrt(k), z = d / (2 * w0);
  if (z < 1) {
    const wd = w0 * Math.sqrt(1 - z * z);
    return 1 - Math.exp(-z * w0 * t) * (Math.cos(wd * t) + (z * w0 / wd) * Math.sin(wd * t));
  }
  return 1 - Math.exp(-w0 * t) * (1 + w0 * t); // z >= 1 treated as critical
}

// Spring vocabulary. Pick by role, never invent a new curve per shot.
export const SPRINGS = {
  snappy: [320, 30],   // buttons, toggles, leading edges
  ui: [220, 28],       // cards, containers, panels
  camera: [90, 19],    // camera moves, big pans
  heavy: [120, 22],    // big type, logo lockups (no overshoot)
  playful: [260, 14],  // mascots, stickers (visible overshoot)
};
export const sp = (t, name = 'ui') => spring(t, ...SPRINGS[name]);

// A value with several targets: one spring per change, summed. Never restart a spring.
// keys: [[time, value], ...] sorted by time.
export function track(t, keys, name = 'ui') {
  let v = keys[0][1];
  for (let i = 1; i < keys.length; i++) v += (keys[i][1] - keys[i - 1][1]) * sp(t - keys[i][0], name);
  return v;
}

// Stretching indicator: leading edge stiffer than trailing edge.
export function indicator(t, stops, width) {
  const lead = track(t, stops, 'snappy');
  const trail = track(t, stops, 'camera');
  return { left: Math.min(lead, trail), right: Math.max(lead, trail) + width };
}

// Text inside a morphing container: in after the morph starts, out before the next one.
export const swapAlpha = (t, tIn, tOut) => Math.min(clamp((t - tIn - 0.08) / 0.12), clamp((tOut - 0.1 - t) / 0.1));

export const loopT = (t, dur) => ((t % dur) + dur) % dur;

// Seeded PRNG (mulberry32). Never Math.random.
export function rng(seed) {
  return () => {
    seed |= 0; seed = (seed + 0x6D2B79F5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Beat grid. Read audio/beats.json when it exists; otherwise derive from bpm.
export function grid(bpm = 120, offset = 0) {
  const b = 60 / bpm;
  return { bpm, beat: (n) => offset + n * b, bar: (n) => offset + n * 4 * b, len: b };
}

// Layout for any aspect ratio. Scenes are written in units, never fixed pixels.
// u = 1/100 of the short edge. Safe area keeps 6% margins.
export function layout(W, H) {
  const u = Math.min(W, H) / 100;
  const portrait = H > W, square = Math.abs(W - H) < 2;
  return { W, H, u, cx: W / 2, cy: H / 2, portrait, square, landscape: !portrait && !square,
    safe: { x: W * 0.06, y: H * 0.06, w: W * 0.88, h: H * 0.88 } };
}

// ---- Canvas helpers ----

export function rrect(g, x, y, w, h, r) {
  r = Math.max(0, Math.min(r, w / 2, h / 2));
  g.beginPath();
  g.moveTo(x + r, y); g.arcTo(x + w, y, x + w, y + h, r); g.arcTo(x + w, y + h, x, y + h, r);
  g.arcTo(x, y + h, x, y, r); g.arcTo(x, y, x + w, y, r); g.closePath();
}

// Draw an image into a rounded box, cover-fit, with optional focal point (fx, fy in 0..1).
export function imageBox(g, img, x, y, w, h, r = 0, fx = 0.5, fy = 0.5, zoom = 1) {
  const s = Math.max(w / img.width, h / img.height) * zoom;
  const iw = img.width * s, ih = img.height * s;
  g.save(); rrect(g, x, y, w, h, r); g.clip();
  g.drawImage(img, x + (w - iw) * fx, y + (h - ih) * fy, iw, ih);
  g.restore();
}

// Draw a crop of a source image (sx, sy, sw, sh in source pixels) into a box, contain-fit.
export function crop(g, img, [sx, sy, sw, sh], x, y, w, h, r = 0) {
  g.save(); rrect(g, x, y, w, h, r); g.clip();
  g.drawImage(img, sx, sy, sw, sh, x, y, w, h);
  g.restore();
}

// Text with letter-spacing (canvas has ctx.letterSpacing in Chromium; fall back to manual).
export function text(g, str, x, y, { font, color = '#fff', align = 'left', base = 'alphabetic', tracking = 0, alpha = 1 } = {}) {
  g.save(); g.globalAlpha *= alpha; g.font = font; g.fillStyle = color; g.textAlign = align; g.textBaseline = base;
  if ('letterSpacing' in g) g.letterSpacing = `${tracking}px`;
  g.fillText(str, x, y); g.restore();
}

// Kinetic type: reveal a line word by word, each word rising on its own spring from a mask.
// t is local time (0 = first word starts). out: local time the words leave upward, same mask.
// Returns the drawn width.
export function wordsUp(g, t, str, x, y, { font, color, size, gap = 0.06, spring: name = 'heavy', align = 'left', tracking = 0, out = Infinity } = {}) {
  g.save(); g.font = font; if ('letterSpacing' in g) g.letterSpacing = `${tracking}px`;
  const words = str.split(' ');
  const space = g.measureText(' ').width;
  const widths = words.map((w) => g.measureText(w).width);
  const total = widths.reduce((a, b) => a + b, 0) + space * (words.length - 1);
  let cx = align === 'center' ? x - total / 2 : align === 'right' ? x - total : x;
  words.forEach((w, i) => {
    const p = sp(t - i * gap, name), q = sp(t - out - i * gap * 0.5, 'snappy');
    if (q > 0.999) { cx += widths[i] + space; return; }
    g.save();
    g.beginPath(); g.rect(cx - size * 0.1, y - size * 1.05, widths[i] + size * 0.2, size * 1.35); g.clip();
    g.fillStyle = color; g.textBaseline = 'alphabetic'; g.textAlign = 'left';
    g.fillText(w, cx, y + (1 - p) * size * 1.1 - q * size * 1.3);
    g.restore();
    cx += widths[i] + space;
  });
  g.restore();
  return total;
}

// Typewriter: n characters of str visible at time t (chars per second).
export const typed = (str, t, cps = 28) => str.slice(0, Math.max(0, Math.floor(t * cps)));

// Film grain from pre-rendered seeded tiles. Call makeGrain once, then grain(g, frameIndex).
export function makeGrain(size = 256, tiles = 8, seed = 11) {
  const r = rng(seed), out = [];
  for (let k = 0; k < tiles; k++) {
    const c = document.createElement('canvas'); c.width = c.height = size;
    const x = c.getContext('2d'), d = x.createImageData(size, size);
    for (let i = 0; i < d.data.length; i += 4) {
      const v = 128 + (r() - 0.5) * 255;
      d.data[i] = d.data[i + 1] = d.data[i + 2] = v; d.data[i + 3] = 255;
    }
    x.putImageData(d, 0, 0); out.push(c);
  }
  return out;
}
export function grain(g, tilesArr, t, fps = 60, amount = 0.06) {
  const tile = tilesArr[Math.floor(t * fps / 2) % tilesArr.length];
  g.save(); g.globalAlpha = amount; g.globalCompositeOperation = 'overlay';
  g.fillStyle = g.createPattern(tile, 'repeat'); g.fillRect(0, 0, g.canvas.width, g.canvas.height);
  g.restore();
}

// Soft drop shadow for floating UI cards.
export function shadow(g, blur, oy, color = 'rgba(9,12,51,0.25)') {
  g.shadowColor = color; g.shadowBlur = blur; g.shadowOffsetY = oy; g.shadowOffsetX = 0;
}

// Cursor arrow at (x, y), with press depth p (0..1) shrinking it slightly.
export function cursor(g, x, y, scale = 1, p = 0, fill = '#141413', stroke = '#fff') {
  g.save(); g.translate(x, y); g.scale(scale * (1 - 0.12 * p), scale * (1 - 0.12 * p));
  g.beginPath(); g.moveTo(0, 0); g.lineTo(0, 34); g.lineTo(9, 26); g.lineTo(15, 40); g.lineTo(21, 37);
  g.lineTo(15, 24); g.lineTo(27, 24); g.closePath();
  g.fillStyle = fill; g.strokeStyle = stroke; g.lineWidth = 2.5; g.lineJoin = 'round'; g.stroke(); g.fill();
  g.restore();
}

// Click ripple: ring expanding from (x, y), t seconds after the click.
export function ripple(g, x, y, t, color, maxR = 60) {
  if (t < 0 || t > 0.6) return;
  const p = spring(t, 120, 20);
  g.save(); g.globalAlpha = (1 - t / 0.6) * 0.6; g.strokeStyle = color; g.lineWidth = 4;
  g.beginPath(); g.arc(x, y, p * maxR, 0, Math.PI * 2); g.stroke(); g.restore();
}

// ---- Easing (for progress-driven pieces such as transitions; prefer springs for motion with mass) ----
export const EASE = {
  linear: (p) => p,
  inCubic: (p) => p * p * p,
  outCubic: (p) => 1 - Math.pow(1 - p, 3),
  inOutCubic: (p) => (p < 0.5 ? 4 * p * p * p : 1 - Math.pow(-2 * p + 2, 3) / 2),
  outExpo: (p) => (p >= 1 ? 1 : 1 - Math.pow(2, -10 * p)),
  inOutExpo: (p) => (p <= 0 ? 0 : p >= 1 ? 1 : p < 0.5 ? Math.pow(2, 20 * p - 10) / 2 : (2 - Math.pow(2, -20 * p + 10)) / 2),
  outBack: (p) => { const c1 = 1.70158, c3 = c1 + 1; return 1 + c3 * Math.pow(p - 1, 3) + c1 * Math.pow(p - 1, 2); },
  inOutSine: (p) => -(Math.cos(Math.PI * p) - 1) / 2,
};
// Local progress of t through [t0, t0 + dur], optionally eased.
export const prog = (t, t0, dur, ease = 'linear') => EASE[ease](clamp((t - t0) / Math.max(1e-6, dur)));

// ---- Seeded value noise (smooth, time-pure: sample noise2(x, t * speed)) ----
export function hash(i, seed = 0) {
  let h = Math.imul((i | 0) ^ Math.imul(seed | 0, 0x9E3779B1), 0x85EBCA6B);
  h ^= h >>> 13; h = Math.imul(h, 0xC2B2AE35); h ^= h >>> 16;
  return (h >>> 0) / 4294967296;
}
const fade = (x) => x * x * (3 - 2 * x);
export function noise1(x, seed = 0) { const i = Math.floor(x), f = x - i; return lerp(hash(i, seed), hash(i + 1, seed), fade(f)) * 2 - 1; }
export function noise2(x, y, seed = 0) {
  const xi = Math.floor(x), yi = Math.floor(y), xf = x - xi, yf = y - yi;
  const h = (a, b) => hash(a * 73856093 ^ b * 19349663, seed);
  const u = fade(xf), v = fade(yf);
  return lerp(lerp(h(xi, yi), h(xi + 1, yi), u), lerp(h(xi, yi + 1), h(xi + 1, yi + 1), u), v) * 2 - 1;
}

// Scale every spring preset in place (pace presets use this). k * s^2 and d * s keep the overshoot character.
const BASE_SPRINGS = Object.fromEntries(Object.entries(SPRINGS).map(([k, v]) => [k, [...v]]));
export function scaleSprings(s) { for (const [k, [kk, dd]] of Object.entries(BASE_SPRINGS)) SPRINGS[k] = [kk * s * s, dd * s]; }

// Offscreen canvas pool: one canvas per key, cleared on every request.
const POOL = new Map();
export function offscreen(key, W, H) {
  let c = POOL.get(key);
  if (!c || c.width !== W || c.height !== H) { c = document.createElement('canvas'); c.width = W; c.height = H; POOL.set(key, c); }
  const x = c.getContext('2d');
  x.setTransform(1, 0, 0, 1, 0, 0); x.globalAlpha = 1; x.globalCompositeOperation = 'source-over'; x.filter = 'none'; x.clearRect(0, 0, W, H);
  return c;
}
// Render a scene function into a pooled offscreen canvas the size of g's canvas.
export function layerOf(g, key, draw) { const c = offscreen(key, g.canvas.width, g.canvas.height); draw(c.getContext('2d')); return c; }
