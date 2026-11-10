// text.js: text animations, named after library/motion.json "text".
//
//   import { TEXT, textFx } from './text.js';
//   textFx(g, 'scramble-decode', t - 2.0, 'Hei, verden!', x, y, { font: '700 96px Inter', size: 96, color: '#fff' });
//
// t is LOCAL time (0 = the effect starts). Common options: font, size (px, used for masks and offsets), color,
// align ('left'|'center'|'right'), unit ('char'|'word'|'line'), stagger (s), out (local time the text leaves),
// accent (second color), seed. Returns the drawn width where meaningful. Pure functions of t.

import { clamp, lerp, sp, spring, rng, hash, EASE } from './motion.js';

function setup(g, o) { g.font = o.font; g.textBaseline = 'alphabetic'; g.textAlign = 'left'; if ('letterSpacing' in g) g.letterSpacing = `${o.tracking || 0}px`; }
// Split into positioned units. Lines split on \n.
export function units(g, str, o) {
  setup(g, o);
  const unit = o.unit || 'word', lh = (o.lineHeight || 1.15) * o.size, out = [];
  const lines = String(str).split('\n');
  lines.forEach((line, li) => {
    const lw = g.measureText(line).width;
    let x0 = o.align === 'center' ? -lw / 2 : o.align === 'right' ? -lw : 0;
    if (unit === 'line') { out.push({ s: line, x: x0, y: li * lh, w: lw, line: li }); return; }
    const parts = unit === 'char' ? [...line] : line.split(/(\s+)/);
    for (const s of parts) { const w = g.measureText(s).width; if (s.trim()) out.push({ s, x: x0, y: li * lh, w, line: li }); x0 += w; }
  });
  out.forEach((u, i) => (u.i = i));
  return out;
}
const opts = (o) => ({ size: 64, color: '#fff', stagger: 0.04, out: Infinity, ...o, font: o.font || `700 ${o.size || 64}px sans-serif` });
const maskRect = (g, u, size) => { g.beginPath(); g.rect(u.x - size * 0.15, u.y - size * 1.05, u.w + size * 0.3, size * 1.4); g.clip(); };
// Generic per-unit animator: fn(g, u, p, q) draws unit with entry progress p (spring) and exit progress q.
function perUnit(g, t, str, x, y, o, fn, springName = 'heavy') {
  o = opts(o); const us = units(g, str, o);
  g.save(); g.translate(x, y); setup(g, o); g.fillStyle = o.color;
  for (const u of us) {
    const d = u.i * o.stagger, p = sp(t - d, springName), q = sp(t - o.out - d * 0.5, 'snappy');
    if (q > 0.999 || t - d < 0) continue;
    g.save(); fn(g, u, p, q, t - d, o); g.restore();
  }
  g.restore();
  return us.length ? Math.max(...us.map((u) => u.x + u.w)) - Math.min(...us.map((u) => u.x)) : 0;
}
const fill = (g, u, o, dx = 0, dy = 0) => g.fillText(u.s, u.x + dx, u.y + dy);
const GLYPHS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅ0123456789#%&*+=<>/';

export const TEXT = {
  'rise-from-mask': (g, t, s, x, y, o) => perUnit(g, t, s, x, y, o, (g, u, p, q, lt, o) => { maskRect(g, u, o.size); fill(g, u, o, 0, (1 - p) * o.size * 1.1 - q * o.size * 1.3); }),
  'fade-up-stagger': (g, t, s, x, y, o) => perUnit(g, t, s, x, y, o, (g, u, p, q) => { g.globalAlpha = clamp(p) * (1 - q); fill(g, u, o, 0, (1 - p) * o.size * 0.35 - q * o.size * 0.3); }, 'ui'),
  'blur-in': (g, t, s, x, y, o) => perUnit(g, t, s, x, y, o, (g, u, p, q) => { g.globalAlpha = clamp(p) * (1 - q); const b = (1 - clamp(p)) * o.size * 0.25 + q * o.size * 0.2; if (b > 0.3) g.filter = `blur(${b.toFixed(1)}px)`; fill(g, u, o); }, 'camera'),
  'letter-scale-pop': (g, t, s, x, y, o) => perUnit(g, t, s, x, y, { unit: 'char', stagger: 0.03, ...o }, (g, u, p, q) => { const sc = p * (1 - q); g.translate(u.x + u.w / 2, u.y - o.size * 0.35); g.scale(sc, sc); g.fillText(u.s, -u.w / 2, o.size * 0.35); }, 'playful'),
  'bounce-drop': (g, t, s, x, y, o) => perUnit(g, t, s, x, y, { unit: 'char', stagger: 0.035, ...o }, (g, u, p, q) => { g.globalAlpha = clamp(p * 3); fill(g, u, o, 0, -(1 - p) * o.size * 2 + q * o.size); }, 'playful'),
  'elastic-stretch': (g, t, s, x, y, o) => perUnit(g, t, s, x, y, { unit: 'char', stagger: 0.03, ...o }, (g, u, p, q) => { const sy = Math.max(0.001, p * (1 - q)), sx = 1 + (1 - Math.min(p, 1)) * 0.4; g.translate(u.x + u.w / 2, u.y); g.scale(sx, sy); g.fillText(u.s, -u.w / 2, 0); }, 'playful'),
  'char-cascade-3d': (g, t, s, x, y, o) => perUnit(g, t, s, x, y, { unit: 'char', stagger: 0.025, ...o }, (g, u, p, q) => { const e = clamp(p), sy = Math.max(0.001, Math.sin((e * Math.PI) / 2)); g.globalAlpha = e * (1 - q); g.translate(u.x, u.y - o.size * 0.35); g.transform(1, 0, -0.35 * (1 - e), sy, 0, 0); g.fillText(u.s, 0, o.size * 0.35); }, 'ui'),
  'tracking-expand': (g, t, s, x, y, o) => { o = opts(o); const p = sp(t, 'camera'), tr = lerp(o.size * 0.5, o.tracking || 0, p); g.save(); g.globalAlpha = clamp(p * 1.5); g.font = o.font; g.fillStyle = o.color; g.textAlign = o.align || 'left'; if ('letterSpacing' in g) g.letterSpacing = `${tr}px`; g.fillText(s, x, y); const w = g.measureText(s).width; g.restore(); return w; },
  'wave-sine': (g, t, s, x, y, o) => perUnit(g, t, s, x, y, { unit: 'char', stagger: 0.02, ...o }, (g, u, p, q, lt) => { g.globalAlpha = clamp(p) * (1 - q); fill(g, u, o, 0, Math.sin(lt * (o.speed || 6) - u.i * 0.5) * o.size * (o.amp ?? 0.12)); }, 'ui'),
  'line-by-line-wipe': (g, t, s, x, y, o) => perUnit(g, t, s, x, y, { unit: 'line', stagger: 0.18, ...o }, (g, u, p, q) => { g.beginPath(); g.rect(u.x - 4, u.y - o.size * 1.05, (u.w + 8) * clamp(p), o.size * 1.4); g.clip(); g.globalAlpha = 1 - q; fill(g, u, o); }, 'ui'),
  'kinetic-stack-push': (g, t, s, x, y, o) => { // s: lines separated by \n; each new line enters at the bottom and pushes the stack up
    o = opts(o); const lines = s.split('\n'), every = o.every || 0.6, lh = (o.lineHeight || 1.05) * o.size; g.save(); g.font = o.font; g.fillStyle = o.color; g.textAlign = o.align || 'left';
    const keys = lines.map((_, i) => i * every); let shift = 0; keys.forEach((k, i) => { if (i) shift += lh * sp(t - k, 'snappy'); });
    lines.forEach((l, i) => { const p = sp(t - keys[i], 'snappy'); if (p <= 0) return; g.save(); g.beginPath(); g.rect(x - o.size * 20, y - shift - o.size * 1.1 + i * lh - lh * (lines.length - 1) * 0, o.size * 40, o.size * 1.4); g.globalAlpha = clamp(p * 2); g.fillStyle = i === lines.length - 1 && o.accent ? o.accent : o.color; g.fillText(l, x, y + i * lh - shift + (1 - p) * lh); g.restore(); });
    g.restore(); },
  'typewriter-cursor': (g, t, s, x, y, o) => { o = opts(o); const cps = o.cps || 22, n = Math.max(0, Math.floor(t * cps)), str = s.slice(0, n); g.save(); g.font = o.font; g.fillStyle = o.color; g.textAlign = 'left'; g.fillText(str, x, y);
    const w = g.measureText(str).width, blink = n < s.length || Math.floor(t * 2) % 2 === 0; if (blink && t < (o.out ?? Infinity)) g.fillRect(x + w + o.size * 0.06, y - o.size * 0.8, Math.max(2, o.size * 0.07), o.size * 0.95); g.restore(); return w; },
  'typewriter-delete-retype': (g, t, s, x, y, o) => { // o.words: ['first', 'second', ...]; s is the fixed prefix
    o = opts(o); const words = o.words || [s], cps = o.cps || 18, hold = o.hold || 1.2; let tt = t, cur = '';
    for (let i = 0; i < words.length; i++) { const w = words[i], tType = w.length / cps, tDel = i < words.length - 1 ? w.length / (cps * 2) : Infinity;
      if (tt < tType) { cur = w.slice(0, Math.floor(tt * cps)); break; } tt -= tType; if (tt < hold) { cur = w; break; } tt -= hold; if (tt < tDel) { cur = w.slice(0, w.length - Math.floor(tt * cps * 2)); break; } tt -= tDel; }
    g.save(); g.font = o.font; g.textAlign = 'left'; g.fillStyle = o.color; const pre = words === o.words && s !== words[0] ? s : ''; g.fillText(pre, x, y); const pw = g.measureText(pre).width;
    g.fillStyle = o.accent || o.color; g.fillText(cur, x + pw, y); const w = g.measureText(cur).width; if (Math.floor(t * 2.2) % 2 === 0) g.fillRect(x + pw + w + 4, y - o.size * 0.8, Math.max(2, o.size * 0.07), o.size * 0.95); g.restore(); return pw + w; },
  'scramble-decode': (g, t, s, x, y, o) => { o = opts(o); const dur = o.dur || 1.0, r = rng((o.seed || 7) + Math.floor(t * 30)); const chars = [...s];
    const out = chars.map((c, i) => { const lock = (i / chars.length) * dur * 0.7 + dur * 0.3; return c === ' ' || t >= lock ? c : GLYPHS[Math.floor(r() * GLYPHS.length)]; }).join('');
    g.save(); g.font = o.font; g.fillStyle = o.color; g.textAlign = o.align || 'left'; g.globalAlpha = clamp(t / 0.1); g.fillText(out, x, y); const w = g.measureText(out).width; g.restore(); return w; },
  'counter-roll': (g, t, s, x, y, o) => { o = opts(o); const from = o.from ?? 0, to = o.to ?? Number(s), p = EASE.outExpo(clamp(t / (o.dur || 1.4))), v = lerp(from, to, p);
    const str = (o.format || ((n) => Math.round(n).toLocaleString('nb-NO')))(v); g.save(); g.font = o.font; g.fillStyle = o.color; g.textAlign = o.align || 'left'; if ('fontVariantNumeric' in g) g.fontVariantNumeric = 'tabular-nums'; g.fillText((o.prefix || '') + str + (o.suffix || ''), x, y); g.restore(); },
  'big-number-slam': (g, t, s, x, y, o) => { o = opts(o); const p = sp(t, 'snappy'), sc = lerp(1.8, 1, p), sh = t < 0.25 ? (hash(Math.floor(t * 60)) - 0.5) * o.size * 0.08 * (1 - t / 0.25) : 0;
    g.save(); g.globalAlpha = clamp(t / 0.06); g.translate(x + sh, y); g.scale(sc, sc); g.font = o.font; g.fillStyle = o.color; g.textAlign = o.align || 'center'; g.fillText(s, 0, 0); g.restore(); },
  'slot-machine-roll': (g, t, s, x, y, o) => { o = opts(o); const chars = [...s]; g.save(); g.font = o.font; g.fillStyle = o.color; g.textAlign = 'left'; const cw = g.measureText('0').width; let cx = x;
    chars.forEach((c, i) => { const w = /\d/.test(c) ? cw : g.measureText(c).width; if (/\d/.test(c)) { const target = Number(c), stop = (o.dur || 1.2) + i * 0.12, p = clamp(t / stop), pos = EASE.outCubic(p) * (target + 10 * (2 + i)); g.save(); g.beginPath(); g.rect(cx - 2, y - o.size * 0.95, w + 4, o.size * 1.15); g.clip();
        for (let k = -1; k <= 1; k++) { const d = Math.floor(pos) + k, off = (pos - Math.floor(pos) - k) * o.size * 1.05; g.fillText(String(((d % 10) + 10) % 10), cx, y - off); } g.restore(); } else g.fillText(c, cx, y); cx += w; });
    g.restore(); return cx - x; },
  'countdown-flip': (g, t, s, x, y, o) => { o = opts(o); const from = o.from ?? 3, step = o.every || 1, n = Math.max(0, from - Math.floor(t / step)), lt = t % step, p = clamp(lt / 0.25), sy = Math.abs(Math.cos((Math.PI / 2) * (1 - p)));
    g.save(); g.font = o.font; g.textAlign = 'center'; g.translate(x, y - o.size * 0.35); g.scale(1, Math.max(0.001, p < 1 ? sy : 1)); g.fillStyle = o.color; g.fillText(String(n), 0, o.size * 0.35); g.restore(); },
  'split-flap-board': (g, t, s, x, y, o) => { o = opts(o); const chars = [...s.toUpperCase()]; g.save(); g.font = o.font; const cw = o.cell || g.measureText('W').width * 1.15, ch = o.size * 1.25;
    chars.forEach((c, i) => { const settle = 0.25 + i * (o.stagger ?? 0.06) + hash(i, 3) * 0.4, flips = Math.floor(clamp(t / settle) * 12), done = t >= settle, show = done ? c : GLYPHS[(hash(i * 31 + flips, 5) * GLYPHS.length) | 0];
      const cx = x + i * (cw + 4), ph = done ? 1 : (t * 20) % 1; g.fillStyle = o.tile || '#1b1b1b'; g.fillRect(cx, y - ch * 0.8, cw, ch); g.fillStyle = o.color; g.textAlign = 'center';
      g.save(); g.beginPath(); g.rect(cx, y - ch * 0.8, cw, ch); g.clip(); g.translate(cx + cw / 2, y - ch * 0.3); g.scale(1, done ? 1 : Math.max(0.15, Math.abs(Math.cos(ph * Math.PI)))); g.fillText(show, 0, o.size * 0.35); g.restore();
      g.fillStyle = 'rgba(0,0,0,0.5)'; g.fillRect(cx, y - ch * 0.8 + ch / 2 - 1, cw, 2); });
    g.restore(); },
  'highlight-marker-sweep': (g, t, s, x, y, o) => { o = opts(o); g.save(); g.font = o.font; g.textAlign = 'left'; const w = g.measureText(s).width, p = sp(t - (o.delay ?? 0.2), 'ui');
    g.fillStyle = o.marker || '#FFD84D'; g.globalAlpha = o.markerAlpha ?? 1; g.beginPath(); g.moveTo(x - 6, y + o.size * 0.18); g.lineTo(x - 6 + (w + 12) * p, y + o.size * 0.12); g.lineTo(x - 6 + (w + 12) * p, y - o.size * 0.62); g.lineTo(x - 6, y - o.size * 0.58); g.fill();
    g.globalAlpha = 1; g.fillStyle = o.color; g.fillText(s, x, y); g.restore(); return w; },
  'underline-draw': (g, t, s, x, y, o) => { o = opts(o); g.save(); g.font = o.font; g.textAlign = 'left'; g.fillStyle = o.color; g.fillText(s, x, y); const w = g.measureText(s).width, p = sp(t - (o.delay ?? 0.2), 'ui');
    g.strokeStyle = o.accent || o.color; g.lineWidth = Math.max(2, o.size * 0.06); g.lineCap = 'round'; g.beginPath(); g.moveTo(x, y + o.size * 0.16); g.quadraticCurveTo(x + w * 0.5 * p, y + o.size * 0.24, x + w * p, y + o.size * 0.14); g.stroke(); g.restore(); return w; },
  'strike-through': (g, t, s, x, y, o) => { o = opts(o); g.save(); g.font = o.font; g.textAlign = 'left'; const p = sp(t - (o.delay ?? 0.3), 'snappy'); g.fillStyle = o.color; g.globalAlpha = 1 - 0.45 * p; g.fillText(s, x, y); g.globalAlpha = 1; const w = g.measureText(s).width;
    g.strokeStyle = o.accent || '#E5371B'; g.lineWidth = Math.max(3, o.size * 0.08); g.lineCap = 'round'; g.beginPath(); g.moveTo(x - 4, y - o.size * 0.3); g.lineTo(x - 4 + (w + 8) * p, y - o.size * 0.34); g.stroke(); g.restore(); return w; },
  'outline-to-fill': (g, t, s, x, y, o) => { o = opts(o); g.save(); g.font = o.font; g.textAlign = o.align || 'left'; const p = clamp((t - (o.delay ?? 0.5)) / 0.6);
    g.lineWidth = Math.max(1.5, o.size * 0.03); g.strokeStyle = o.color; g.setLineDash([o.size * 4, o.size * 4]); g.lineDashOffset = o.size * 4 * (1 - clamp(t / 0.8)); g.strokeText(s, x, y); g.setLineDash([]);
    g.globalAlpha = EASE.inOutCubic(p); g.fillStyle = o.color; g.fillText(s, x, y); g.restore(); },
  'gradient-sweep': (g, t, s, x, y, o) => { o = opts(o); g.save(); g.font = o.font; g.textAlign = 'left'; const w = g.measureText(s).width, p = ((t * (o.speed || 0.6)) % 1.6) - 0.3;
    const gr = g.createLinearGradient(x, 0, x + w, 0); gr.addColorStop(0, o.color); gr.addColorStop(clamp(p - 0.15), o.color); gr.addColorStop(clamp(p), o.accent || '#fff'); gr.addColorStop(clamp(p + 0.15), o.color); gr.addColorStop(1, o.color);
    g.fillStyle = gr; g.fillText(s, x, y); g.restore(); return w; },
  'mask-wipe-color-swap': (g, t, s, x, y, o) => { o = opts(o); g.save(); g.font = o.font; g.textAlign = 'left'; const w = g.measureText(s).width, p = EASE.inOutCubic(clamp((t - (o.delay ?? 0.3)) / 0.5));
    g.fillStyle = o.color; g.fillText(s, x, y); g.beginPath(); g.rect(x - 4, y - o.size, (w + 8) * p, o.size * 1.4); g.clip(); g.fillStyle = o.accent || '#E5371B'; g.fillText(s, x, y); g.restore(); return w; },
  'handwriting-stroke': (g, t, s, x, y, o) => { o = opts(o); g.save(); g.font = o.font; g.textAlign = 'left'; const w = g.measureText(s).width, p = clamp(t / (o.dur || 1.4));
    g.beginPath(); g.rect(x - o.size * 0.3, y - o.size * 1.2, (w + o.size * 0.6) * p, o.size * 1.8); g.clip(); g.fillStyle = o.color; g.fillText(s, x, y); g.restore();
    if (p < 1) { g.save(); g.fillStyle = o.accent || o.color; g.beginPath(); g.arc(x + w * p, y - o.size * 0.3 + Math.sin(t * 40) * o.size * 0.15, Math.max(2, o.size * 0.04), 0, Math.PI * 2); g.fill(); g.restore(); } return w; },
  'glitch-text': (g, t, s, x, y, o) => { o = opts(o); const f = Math.floor(t * 24), r = rng((o.seed || 1) + f), on = o.always || (t < 0.5 || r() < 0.12);
    g.save(); g.font = o.font; g.textAlign = o.align || 'left';
    if (on) { g.globalCompositeOperation = 'lighter'; g.fillStyle = 'rgba(255,0,80,0.9)'; g.fillText(s, x - o.size * 0.04, y); g.fillStyle = 'rgba(0,220,255,0.9)'; g.fillText(s, x + o.size * 0.04, y); g.globalCompositeOperation = 'source-over'; }
    g.fillStyle = o.color; g.fillText(s, x, y);
    if (on) for (let i = 0; i < 3; i++) { const yy = y - o.size * r(), hh = o.size * 0.12, dx = (r() - 0.5) * o.size * 0.5; g.save(); g.beginPath(); g.rect(x - o.size, yy, o.size * 40, hh); g.clip(); g.fillStyle = o.color; g.fillText(s, x + dx, y); g.restore(); }
    g.restore(); },
  'weight-morph': (g, t, s, x, y, o) => { o = opts(o); const p = sp(t, 'camera'), w = Math.round(clamp(lerp(o.from ?? 100, o.to ?? 900, o.loop ? (Math.sin(t * 2) + 1) / 2 : p), 1, 1000));
    g.save(); g.font = `${w} ${o.size}px ${o.family || 'sans-serif'}`; g.fillStyle = o.color; g.textAlign = o.align || 'left'; g.fillText(s, x, y); g.restore(); },
  'word-swap-carousel': (g, t, s, x, y, o) => { // s: fixed prefix; o.words: rotating words
    o = opts(o); const words = o.words || ['A', 'B'], every = o.every || 1.2, i = Math.floor(t / every), lt = t - i * every;
    g.save(); g.font = o.font; g.textAlign = 'left'; g.fillStyle = o.color; g.fillText(s, x, y); const pw = g.measureText(s).width;
    g.beginPath(); g.rect(x + pw - 4, y - o.size * 1.05, o.size * 30, o.size * 1.4); g.clip(); g.fillStyle = o.accent || o.color;
    const pin = sp(lt, 'snappy'), cur = words[i % words.length], prev = words[(i - 1 + words.length) % words.length];
    if (i > 0) g.fillText(prev, x + pw, y - pin * o.size * 1.2); g.fillText(cur, x + pw, y + (1 - pin) * o.size * 1.2); g.restore(); },
  'caption-karaoke': (g, t, s, x, y, o) => { // o.words: [{ word, start, end }] in local seconds (voice.mjs words.json shifted)
    o = opts(o); const words = o.words || s.split(' ').map((w, i) => ({ word: w, start: i * 0.35, end: i * 0.35 + 0.35 })); g.save(); g.font = o.font; g.textAlign = 'left';
    const sp1 = g.measureText(' ').width; const total = words.reduce((a, w) => a + g.measureText(w.word).width + sp1, -sp1); let cx = o.align === 'center' ? x - total / 2 : x;
    for (const w of words) { const ww = g.measureText(w.word).width, active = t >= w.start && t < w.end + 0.05, done = t >= w.end; if (active && o.box) { g.fillStyle = o.box; g.fillRect(cx - 6, y - o.size * 0.85, ww + 12, o.size * 1.1); }
      g.fillStyle = active ? o.accent || '#FFD84D' : done ? o.color : o.dim || 'rgba(255,255,255,0.45)'; g.fillText(w.word, cx, y); cx += ww + sp1; }
    g.restore(); },
  'quote-reveal': (g, t, s, x, y, o) => { o = opts(o); const p = sp(t, 'playful'); g.save(); g.font = `700 ${o.size * 2.4}px Georgia, serif`; g.fillStyle = o.accent || o.color; g.globalAlpha = clamp(p); g.translate(x - o.size * 0.2, y - o.size * 0.4); g.scale(p, p); g.fillText('“', -o.size * 0.9, o.size * 0.9); g.restore();
    TEXT['rise-from-mask'](g, t - 0.25, s, x + o.size * 0.4, y, { ...o, unit: 'word', stagger: 0.05 }); if (o.by) TEXT['fade-up-stagger'](g, t - 0.9, o.by, x + o.size * 0.4, y + o.size * ((s.split('\n').length) * (o.lineHeight || 1.15)) + o.size * 0.4, { ...o, font: o.byFont || o.font, size: o.size * 0.45, color: o.dim || o.color }); },
  'lower-third': (g, t, s, x, y, o) => { o = opts(o); const p = sp(t, 'ui'), q = sp(t - o.out, 'snappy'), bw = (o.width || o.size * 10) * p * (1 - q);
    g.save(); g.fillStyle = o.bar || o.accent || '#FFD84D'; g.fillRect(x, y - o.size * 1.3, Math.max(0, o.size * 0.12), o.size * 2.1 * clamp(p * 2) * (1 - q)); g.fillStyle = o.panel || 'rgba(20,20,19,0.85)'; g.fillRect(x + o.size * 0.2, y - o.size * 1.3, bw, o.size * 2.1);
    g.beginPath(); g.rect(x + o.size * 0.2, y - o.size * 1.3, bw, o.size * 2.1); g.clip(); g.font = o.font; g.fillStyle = o.color; g.fillText(s, x + o.size * 0.55, y - o.size * 0.25 + (1 - p) * o.size); if (o.sub) { g.font = o.subFont || `400 ${o.size * 0.55}px sans-serif`; g.globalAlpha = 0.8; g.fillText(o.sub, x + o.size * 0.55, y + o.size * 0.5 + (1 - p) * o.size); } g.restore(); },
  'ticker-marquee': (g, t, s, x, y, o) => { o = opts(o); g.save(); g.font = o.font; g.textAlign = 'left'; g.fillStyle = o.color; const sep = o.sep || '   •   ', unit = s + sep, w = g.measureText(unit).width, W = o.width || g.canvas.width, off = (t * (o.speed || 160)) % w;
    if (o.band) { g.fillStyle = o.band; g.fillRect(x, y - o.size * 1.0, W, o.size * 1.4); g.fillStyle = o.color; } for (let cx = x - off; cx < x + W; cx += w) g.fillText(unit, cx, y); g.restore(); },
  'text-on-path': (g, t, s, x, y, o) => { o = opts(o); const r = o.radius || o.size * 3, p = clamp(t / (o.dur || 1)), chars = [...s]; g.save(); g.font = o.font; g.fillStyle = o.color; g.textAlign = 'center'; g.translate(x, y);
    let a = (o.start ?? -Math.PI * 0.75) + (o.spin || 0) * t; const n = Math.floor(chars.length * p); for (let i = 0; i < n; i++) { const w = g.measureText(chars[i]).width; a += w / 2 / r; g.save(); g.rotate(a); g.fillText(chars[i], 0, -r); g.restore(); a += w / 2 / r; } g.restore(); },
  'word-cloud-assemble': (g, t, s, x, y, o) => { o = opts(o); const us = units(g, s, { ...o, unit: 'word' }), r = rng(o.seed || 12), W = g.canvas.width, H = g.canvas.height; g.save(); g.translate(x, y); setup(g, o); g.fillStyle = o.color;
    for (const u of us) { const fx = (r() - 0.5) * W * 0.9 - x + W / 2 - u.x, fy = (r() - 0.5) * H * 0.9 - y + H / 2 - u.y, rot = (r() - 0.5) * 1.2, p = sp(t - u.i * (o.stagger ?? 0.05), 'camera');
      g.save(); g.globalAlpha = clamp(t * 4); g.translate(u.x + fx * (1 - p), u.y + fy * (1 - p)); g.rotate(rot * (1 - p)); g.fillText(u.s, 0, 0); g.restore(); }
    g.restore(); },
  'emoji-react-pop': (g, t, s, x, y, o) => { o = opts(o); const em = [...(o.emoji || s)], r = rng(o.seed || 21); g.save(); g.textAlign = 'center'; g.font = `${o.size}px "Apple Color Emoji","Noto Color Emoji",sans-serif`;
    em.forEach((e, i) => { const t0 = i * (o.stagger ?? 0.15), lt = t - t0; if (lt < 0) return; const p = spring(lt, 260, 14), dx = (r() - 0.5) * o.size * 3, rise = lt * o.size * 1.6; g.save(); g.globalAlpha = clamp(1 - (lt - 1.2) / 0.5); g.translate(x + dx, y - rise); g.scale(p, p); g.fillText(e, 0, 0); g.restore(); });
    g.restore(); },
};
export function textFx(g, name, t, str, x, y, o = {}) {
  const fn = TEXT[name]; if (!fn) throw new Error(`unknown text effect: ${name}. Known: ${Object.keys(TEXT).join(', ')}`);
  return fn(g, t, str, x, y, o);
}
// Reading-time hold for on-screen text (pace presets set wps): 0.5 s + words / wps, at least 1.2 s.
export const holdFor = (str, wps = 3) => Math.max(1.2, 0.5 + String(str).trim().split(/\s+/).length / wps);
