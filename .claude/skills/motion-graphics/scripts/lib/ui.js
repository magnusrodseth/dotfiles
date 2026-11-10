// ui.js: UI and annotation components, named after library/motion.json "ui". Drawn in code with tokens you pass in.
// Use them for frames, callouts and generic UI; for a real product, crop and animate real screenshots instead.
//
//   import { UI } from './ui.js';
//   UI['browser-chrome-frame'](g, x, y, w, h, { url: 'example.no', theme: 'light' }, (cx, cy, cw, ch) => imageBox(g, img.dash, cx, cy, cw, ch));
//   UI['spotlight-dim-hole'](g, t - 3, [x, y, w, h], { radius: 16 });
//
// Signatures vary per component; every one is a pure function of the local time it receives.

import { clamp, lerp, sp, spring, rrect, EASE, typed, hash, cursor as arrowCursor, ripple } from './motion.js';

const C0 = { ink: '#141413', paper: '#FFFFFF', muted: '#8A877D', line: '#E4E1DA', accent: '#5B5BD6', ok: '#1FA971', warn: '#F5A524', bad: '#E5484D', font: 'system-ui, sans-serif', mono: 'ui-monospace, Menlo, monospace' };
const tok = (o) => ({ ...C0, ...o });
const shadow = (g, b, y, c = 'rgba(0,0,0,0.18)') => { g.shadowColor = c; g.shadowBlur = b; g.shadowOffsetY = y; };
const noShadow = (g) => { g.shadowColor = 'transparent'; };

export const UI = {
  // ---- pointers ----
  'cursor-arrow': (g, x, y, s = 1, press = 0, o = {}) => arrowCursor(g, x, y, s, press, o.fill || '#111', o.stroke || '#fff'),
  'cursor-hand': (g, x, y, s = 1, press = 0, o = {}) => { g.save(); g.translate(x, y); g.scale(s * (1 - 0.1 * press), s * (1 - 0.1 * press)); g.fillStyle = o.fill || '#fff'; g.strokeStyle = o.stroke || '#111'; g.lineWidth = 2; g.lineJoin = 'round';
    g.beginPath(); g.moveTo(0, 0); g.lineTo(0, -2); g.arcTo(0, -6, 4, -6, 4); g.arcTo(8, -6, 8, -2, 4); g.lineTo(8, 14); g.lineTo(10, 10); g.arcTo(13, 8, 16, 10, 3); g.lineTo(16, 12); g.arcTo(19, 10, 22, 12, 3); g.lineTo(22, 14); g.arcTo(25, 12, 28, 15, 3); g.lineTo(28, 30); g.quadraticCurveTo(28, 40, 18, 40); g.lineTo(10, 40); g.quadraticCurveTo(4, 40, 0, 32); g.lineTo(-8, 20); g.quadraticCurveTo(-10, 15, -4, 15); g.lineTo(0, 20); g.closePath(); g.fill(); g.stroke(); g.restore(); },
  'touch-dot': (g, x, y, s = 1, press = 0, o = {}) => { g.save(); g.fillStyle = o.fill || 'rgba(255,255,255,0.55)'; g.strokeStyle = o.stroke || 'rgba(0,0,0,0.25)'; g.lineWidth = 2; g.beginPath(); g.arc(x, y, 22 * s * (1 - 0.2 * press), 0, Math.PI * 2); g.fill(); g.stroke(); g.restore(); },
  'cursor-ring': (g, x, y, s = 1, press = 0, o = {}) => { g.save(); g.strokeStyle = o.stroke || '#111'; g.lineWidth = 3 * s; g.beginPath(); g.arc(x, y, 18 * s * (1 - 0.3 * press), 0, Math.PI * 2); g.stroke(); g.fillStyle = o.stroke || '#111'; g.beginPath(); g.arc(x, y, 3 * s, 0, Math.PI * 2); g.fill(); g.restore(); },
  'click-ripple': (g, x, y, lt, o = {}) => ripple(g, x, y, lt, o.color || C0.accent, o.radius || 60),
  'tap-indicator': (g, x, y, lt, o = {}) => { if (lt < 0 || lt > 0.7) return; const p = EASE.outCubic(clamp(lt / 0.7)); g.save(); g.globalAlpha = (1 - p) * 0.8; g.fillStyle = o.color || 'rgba(255,255,255,0.8)'; g.beginPath(); g.arc(x, y, 14 + p * (o.radius || 46), 0, Math.PI * 2); g.fill(); g.restore(); },
  // ---- attention ----
  'spotlight-dim-hole': (g, lt, rect, o = {}) => { const W = g.canvas.width, H = g.canvas.height, p = sp(lt, 'ui') * (1 - sp(lt - (o.out ?? Infinity), 'ui')); if (p <= 0.001) return; const [x, y, w, h] = rect, m = (o.pad ?? 12);
    g.save(); g.globalAlpha = p * (o.dim ?? 0.6); g.fillStyle = o.color || '#000'; g.beginPath(); g.rect(0, 0, W, H); rrect(g, x - m, y - m, w + 2 * m, h + 2 * m, o.radius ?? 14); g.fill('evenodd'); g.restore(); },
  'highlight-ring': (g, lt, rect, o = {}) => { const p = sp(lt, 'snappy'); if (p <= 0) return; const [x, y, w, h] = rect, m = (o.pad ?? 8) + (1 - p) * 20; g.save(); g.globalAlpha = clamp(p); g.strokeStyle = o.color || C0.accent; g.lineWidth = o.width || 4; rrect(g, x - m, y - m, w + 2 * m, h + 2 * m, o.radius ?? 12); g.stroke(); g.restore(); },
  'arrow-callout-drawn': (g, lt, from, to, o = {}) => { const p = clamp(lt / (o.dur || 0.6)), e = EASE.outCubic(p), [x0, y0] = from, [x1, y1] = to, mx = (x0 + x1) / 2 + (o.bend ?? 0.25) * (y1 - y0), my = (y0 + y1) / 2 - (o.bend ?? 0.25) * (x1 - x0);
    g.save(); g.strokeStyle = o.color || C0.accent; g.lineWidth = o.width || 4; g.lineCap = 'round'; g.beginPath(); const N = 30; for (let i = 0; i <= N * e; i++) { const s = i / N, x = (1 - s) ** 2 * x0 + 2 * (1 - s) * s * mx + s * s * x1, y = (1 - s) ** 2 * y0 + 2 * (1 - s) * s * my + s * s * y1; i ? g.lineTo(x, y) : g.moveTo(x, y); } g.stroke();
    if (p >= 1) { const a = Math.atan2(y1 - my, x1 - mx), L = (o.head || 18) * EASE.outBack(clamp((lt - (o.dur || 0.6)) / 0.2)); g.beginPath(); g.moveTo(x1 - Math.cos(a - 0.5) * L, y1 - Math.sin(a - 0.5) * L); g.lineTo(x1, y1); g.lineTo(x1 - Math.cos(a + 0.5) * L, y1 - Math.sin(a + 0.5) * L); g.stroke(); }
    if (o.label && p >= 1) { g.font = o.font || `600 24px ${C0.font}`; g.fillStyle = o.color || C0.accent; g.textAlign = 'center'; g.globalAlpha = clamp((lt - o.dur - 0.1) / 0.2); g.fillText(o.label, x0, y0 - 14); } g.restore(); },
  'tooltip-pop': (g, lt, x, y, text, o = {}) => { const k = tok(o), p = spring(lt, 260, 18); if (p <= 0) return; g.save(); g.font = o.font || `500 22px ${k.font}`; const w = g.measureText(text).width + 28, h = 44;
    g.translate(x, y); g.scale(p, p); g.fillStyle = k.ink; rrect(g, -w / 2, -h - 12, w, h, 10); g.fill(); g.beginPath(); g.moveTo(-8, -12); g.lineTo(0, -2); g.lineTo(8, -12); g.fill(); g.fillStyle = k.paper; g.textAlign = 'center'; g.fillText(text, 0, -h / 2 - 12 + 8); g.restore(); },
  'sticky-note': (g, lt, x, y, text, o = {}) => { const p = spring(lt, 240, 16), s = o.size || 220; if (p <= 0) return; g.save(); g.translate(x, y); g.rotate((o.rot ?? -0.05) * p); g.scale(p, p); shadow(g, 18, 8); g.fillStyle = o.color || '#FFE58A'; g.fillRect(-s / 2, -s / 2, s, s); noShadow(g);
    g.fillStyle = o.ink || '#3a3000'; g.font = o.font || `500 ${s / 9}px "Shantell Sans", ${C0.font}`; g.textAlign = 'left'; String(text).split('\n').forEach((l, i) => g.fillText(l, -s / 2 + s * 0.1, -s / 2 + s * 0.22 + i * s * 0.14)); g.restore(); },
  'magnifier-loupe': (g, lt, src, cx, cy, o = {}) => { // src: canvas or image of the scene; zooms around (cx, cy)
    const p = sp(lt, 'playful'), r = (o.radius || 120) * p, z = o.zoom || 2; if (r <= 1) return; g.save(); g.beginPath(); g.arc(cx, cy, r, 0, Math.PI * 2); g.clip(); g.drawImage(src, cx - cx * z, cy - cy * z, src.width * z, src.height * z); g.restore();
    g.save(); g.strokeStyle = o.ring || '#fff'; g.lineWidth = 6; shadow(g, 20, 6); g.beginPath(); g.arc(cx, cy, r, 0, Math.PI * 2); g.stroke(); g.restore(); },
  // ---- frames: fn(cx, cy, cw, ch) draws the content area ----
  'browser-chrome-frame': (g, x, y, w, h, o = {}, fn) => { const k = tok(o), dark = o.theme === 'dark', bar = o.bar || Math.max(36, h * 0.06); g.save(); shadow(g, 40, 16, 'rgba(0,0,0,0.25)'); g.fillStyle = dark ? '#1f1f22' : '#f3f3f4'; rrect(g, x, y, w, h, 14); g.fill(); noShadow(g);
    ['#ff5f57', '#febc2e', '#28c840'].forEach((c, i) => { g.fillStyle = c; g.beginPath(); g.arc(x + 22 + i * 20, y + bar / 2, 6, 0, Math.PI * 2); g.fill(); });
    g.fillStyle = dark ? '#2c2c30' : '#fff'; rrect(g, x + w * 0.25, y + bar * 0.2, w * 0.5, bar * 0.6, bar * 0.3); g.fill(); g.fillStyle = dark ? '#aaa' : '#666'; g.font = `400 ${bar * 0.32}px ${k.font}`; g.textAlign = 'center'; g.fillText(o.url || '', x + w / 2, y + bar * 0.62);
    g.beginPath(); rrect(g, x, y + bar, w, h - bar, 0); g.save(); g.clip(); fn?.(x, y + bar, w, h - bar); g.restore(); g.restore(); },
  'phone-frame': (g, x, y, w, h, o = {}, fn) => { const r = w * 0.14, b = w * 0.035; g.save(); shadow(g, 40, 16, 'rgba(0,0,0,0.3)'); g.fillStyle = o.body || '#111'; rrect(g, x, y, w, h, r); g.fill(); noShadow(g);
    g.save(); rrect(g, x + b, y + b, w - 2 * b, h - 2 * b, r - b); g.clip(); fn?.(x + b, y + b, w - 2 * b, h - 2 * b); g.restore(); g.fillStyle = o.body || '#111'; rrect(g, x + w * 0.36, y + b + w * 0.025, w * 0.28, w * 0.075, w * 0.04); g.fill(); g.restore(); },
  'laptop-frame': (g, x, y, w, h, o = {}, fn) => { const sh = h * 0.92, b = w * 0.02; g.save(); shadow(g, 40, 16, 'rgba(0,0,0,0.25)'); g.fillStyle = o.body || '#1c1c1e'; rrect(g, x + w * 0.06, y, w * 0.88, sh, 16); g.fill(); noShadow(g);
    g.save(); g.beginPath(); g.rect(x + w * 0.06 + b, y + b, w * 0.88 - 2 * b, sh - 2 * b); g.clip(); fn?.(x + w * 0.06 + b, y + b, w * 0.88 - 2 * b, sh - 2 * b); g.restore();
    g.fillStyle = o.base || '#c9c9cc'; g.beginPath(); g.moveTo(x, y + sh); g.lineTo(x + w, y + sh); g.lineTo(x + w * 0.97, y + h); g.lineTo(x + w * 0.03, y + h); g.closePath(); g.fill(); g.restore(); },
  'terminal-window': (g, lt, x, y, w, h, lines, o = {}) => { UI['browser-chrome-frame'](g, x, y, w, h, { theme: 'dark', url: o.title || 'zsh' }, (cx, cy, cw, ch) => { g.fillStyle = o.bg || '#0d0d10'; g.fillRect(cx, cy, cw, ch); const fs = o.size || 22, cps = o.cps || 40; let tt = lt;
    g.font = `400 ${fs}px ${C0.mono}`; g.textAlign = 'left'; lines.forEach((l, i) => { const isCmd = l.startsWith('$'), dur = isCmd ? l.length / cps : 0.05; if (tt < 0) return; const s = isCmd ? typed(l, tt, cps) : l; g.fillStyle = isCmd ? (o.cmd || '#e8e8e8') : (o.out || '#7fdc8a'); g.fillText(s, cx + fs, cy + fs * 1.6 + i * fs * 1.45); tt -= dur + (isCmd ? 0.25 : 0.08); }); }); },
  'code-block-typing': (g, lt, x, y, w, h, code, o = {}) => { const fs = o.size || 22, cps = o.cps || 45, kw = /\b(const|let|function|return|import|from|export|async|await|if|else|for|new|class|def|type)\b/g;
    g.save(); g.fillStyle = o.bg || '#16161d'; shadow(g, 30, 12, 'rgba(0,0,0,0.3)'); rrect(g, x, y, w, h, 14); g.fill(); noShadow(g); g.font = `400 ${fs}px ${C0.mono}`; g.textAlign = 'left';
    const shown = typed(code, lt, cps); shown.split('\n').forEach((line, i) => { let cx = x + fs * 1.2; const ly = y + fs * 2 + i * fs * 1.5; const parts = line.split(/(\/\/.*$|'[^']*'?|"[^"]*"?|`[^`]*`?|\b\d+\b|\s+|[^\w\s])/);
      for (const p of parts) { if (!p) continue; g.fillStyle = p.startsWith('//') ? '#6a7380' : /^['"`]/.test(p) ? '#a5e07f' : /^\d+$/.test(p) ? '#f5a97f' : kw.test(p) ? '#c792ea' : /^[^\w\s]$/.test(p) ? '#89ddff' : '#e8e8e8'; kw.lastIndex = 0; g.fillText(p, cx, ly); cx += g.measureText(p).width; } });
    if (Math.floor(lt * 2) % 2 === 0) { const ls = shown.split('\n'), last = ls[ls.length - 1]; g.fillStyle = '#e8e8e8'; g.fillRect(x + fs * 1.2 + g.measureText(last).width + 2, y + fs * 2 + (ls.length - 1) * fs * 1.5 - fs * 0.8, fs * 0.55, fs); } g.restore(); },
  // ---- feedback ----
  'notification-toast': (g, lt, x, y, w, title, body, o = {}) => { const k = tok(o), p = sp(lt, 'ui'), q = sp(lt - (o.out ?? Infinity), 'snappy'), h = o.h || 96, yy = y - (1 - p) * (h + 40) - q * (h + 40); if (p <= 0) return;
    g.save(); g.globalAlpha = clamp(p * 2) * (1 - q); shadow(g, 30, 10); g.fillStyle = k.paper; rrect(g, x, yy, w, h, 18); g.fill(); noShadow(g);
    g.fillStyle = k.accent; rrect(g, x + 18, yy + 18, h - 36, h - 36, 12); g.fill(); if (o.icon) g.drawImage(o.icon, x + 26, yy + 26, h - 52, h - 52);
    g.textAlign = 'left'; g.fillStyle = k.ink; g.font = `600 ${h * 0.24}px ${k.font}`; g.fillText(title, x + h, yy + h * 0.42); g.fillStyle = k.muted; g.font = `400 ${h * 0.2}px ${k.font}`; g.fillText(body, x + h, yy + h * 0.72); g.restore(); },
  'progress-bar': (g, lt, x, y, w, h, o = {}) => { const k = tok(o), p = o.value != null ? o.value : EASE.inOutCubic(clamp(lt / (o.dur || 1.5))); g.save(); g.fillStyle = o.track || k.line; rrect(g, x, y, w, h, h / 2); g.fill(); g.fillStyle = k.accent; rrect(g, x, y, Math.max(h, w * p), h, h / 2); g.fill(); g.restore(); },
  'spinner-arc': (g, lt, x, y, r, o = {}) => { const a = lt * 6, len = 1 + Math.sin(lt * 4) * 0.8; g.save(); g.strokeStyle = o.color || C0.accent; g.lineWidth = r * 0.22; g.lineCap = 'round'; g.beginPath(); g.arc(x, y, r, a, a + len + 0.6); g.stroke(); g.restore(); },
  'spinner-dots': (g, lt, x, y, r, o = {}) => { g.save(); g.fillStyle = o.color || C0.accent; for (let i = 0; i < 3; i++) { const s = 0.6 + 0.4 * Math.max(0, Math.sin(lt * 7 - i * 0.9)); g.beginPath(); g.arc(x + (i - 1) * r * 1.2, y, r * 0.4 * s, 0, Math.PI * 2); g.fill(); } g.restore(); },
  'chat-bubbles': (g, lt, x, y, w, msgs, o = {}) => { // msgs: [{ from: 'me'|'them', text, at }]; bubbles pop in at `at` and stack upward
    const k = tok(o), fs = o.size || 26; g.save(); g.font = `400 ${fs}px ${k.font}`; let yy = y;
    const vis = msgs.filter((m) => lt >= m.at); vis.slice().reverse().forEach((m) => { const p = spring(lt - m.at, 260, 20), me = m.from === 'me', maxw = w * 0.72;
      const words = m.text.split(' '), lines = []; let cur = ''; for (const wd of words) { const tst = cur ? cur + ' ' + wd : wd; if (g.measureText(tst).width > maxw - fs * 1.4 && cur) { lines.push(cur); cur = wd; } else cur = tst; } lines.push(cur);
      const bw = Math.max(...lines.map((l) => g.measureText(l).width)) + fs * 1.4, bh = lines.length * fs * 1.35 + fs * 0.9; yy -= bh + 12;
      const bx = me ? x + w - bw : x; g.save(); g.translate(bx + (me ? bw : 0), yy + bh); g.scale(p, p); g.translate(-(bx + (me ? bw : 0)), -(yy + bh));
      g.fillStyle = me ? (o.me || k.accent) : (o.them || '#E9E9EE'); rrect(g, bx, yy, bw, bh, fs * 0.9); g.fill(); g.fillStyle = me ? '#fff' : k.ink; lines.forEach((l, i) => g.fillText(l, bx + fs * 0.7, yy + fs * 1.25 + i * fs * 1.35)); g.restore(); });
    if (o.typing != null && lt >= o.typing) { const bx = x, by = y - 12 - fs * 2.2; g.fillStyle = o.them || '#E9E9EE'; rrect(g, bx, by, fs * 3.4, fs * 2.2, fs); g.fill(); UI['spinner-dots'](g, lt, bx + fs * 1.7, by + fs * 1.1, fs * 0.5, { color: '#8a8a95' }); }
    g.restore(); },
  keycaps: (g, lt, x, y, keys, o = {}) => { const s = o.size || 64; let cx = x; g.save(); g.font = `600 ${s * 0.38}px ${C0.font}`; g.textAlign = 'center';
    keys.forEach((kk, i) => { const press = clamp(1 - Math.abs(lt - (o.at ?? 0.3) - i * 0.08) / 0.12), w = Math.max(s, g.measureText(kk).width + s * 0.6), dy = press * s * 0.08;
      g.fillStyle = '#b9b9c2'; rrect(g, cx, y + s * 0.1, w, s, s * 0.18); g.fill(); g.fillStyle = '#f4f4f7'; rrect(g, cx, y + dy, w, s * 0.92, s * 0.18); g.fill(); g.fillStyle = '#222'; g.fillText(kk, cx + w / 2, y + dy + s * 0.58); cx += w + s * 0.18;
      if (i < keys.length - 1 && o.plus !== false) { g.fillStyle = o.plusColor || '#888'; g.fillText('+', cx + s * 0.05, y + s * 0.58); cx += s * 0.4; } });
    g.restore(); },
  'before-after-slider': (g, lt, x, y, w, h, before, after, o = {}) => { const p = o.value != null ? o.value : 0.5 + 0.35 * Math.sin(lt * 1.2), sx = x + w * p; g.save(); rrect(g, x, y, w, h, o.radius ?? 16); g.clip(); g.drawImage(after, x, y, w, h); g.beginPath(); g.rect(x, y, sx - x, h); g.clip(); g.drawImage(before, x, y, w, h); g.restore();
    g.save(); g.fillStyle = '#fff'; g.fillRect(sx - 2, y, 4, h); shadow(g, 12, 2); g.beginPath(); g.arc(sx, y + h / 2, 22, 0, Math.PI * 2); g.fill(); noShadow(g); g.fillStyle = '#333'; g.font = `700 20px ${C0.font}`; g.textAlign = 'center'; g.fillText('⇆', sx, y + h / 2 + 7); g.restore(); },
  'checklist-ticking': (g, lt, x, y, items, o = {}) => { const k = tok(o), fs = o.size || 30, gap = o.every || 0.45; g.save(); g.font = `500 ${fs}px ${k.font}`; g.textAlign = 'left';
    items.forEach((it, i) => { const tt = lt - i * gap, p = sp(tt, 'snappy'), yy = y + i * fs * 1.8, bx = x, bs = fs * 1.05; g.strokeStyle = k.line; g.lineWidth = 2.5; rrect(g, bx, yy - bs * 0.85, bs, bs, bs * 0.25); g.stroke();
      if (p > 0) { g.fillStyle = k.ok; g.save(); g.translate(bx + bs / 2, yy - bs * 0.35); g.scale(p, p); rrect(g, -bs / 2, -bs / 2, bs, bs, bs * 0.25); g.fill(); g.restore(); const d = clamp((tt - 0.05) / 0.25); g.strokeStyle = '#fff'; g.lineWidth = 3.5; g.lineCap = 'round'; g.beginPath(); g.moveTo(bx + bs * 0.25, yy - bs * 0.35); g.lineTo(bx + bs * 0.25 + bs * 0.18 * clamp(d * 2), yy - bs * 0.35 + bs * 0.18 * clamp(d * 2)); if (d > 0.5) g.lineTo(bx + bs * 0.43 + bs * 0.35 * clamp((d - 0.5) * 2), yy - bs * 0.17 - bs * 0.38 * clamp((d - 0.5) * 2)); g.stroke(); }
      g.fillStyle = p > 0.5 && o.strike ? k.muted : k.ink; g.fillText(it, bx + bs * 1.6, yy); });
    g.restore(); },
  'toggle-switch': (g, lt, x, y, o = {}) => { const k = tok(o), w = o.w || 90, h = w * 0.55, p = sp(lt - (o.at ?? 0.3), 'snappy'), on = o.on ?? true, v = on ? p : 1 - p;
    g.save(); g.fillStyle = v > 0.5 ? k.accent : k.line; rrect(g, x, y, w, h, h / 2); g.fill(); shadow(g, 6, 2); g.fillStyle = '#fff'; g.beginPath(); g.arc(x + h / 2 + (w - h) * v, y + h / 2, h * 0.42, 0, Math.PI * 2); g.fill(); g.restore(); },
  'step-indicator': (g, lt, x, y, w, n, o = {}) => { const k = tok(o), cur = o.step != null ? o.step : Math.min(n - 1, Math.floor(lt / (o.every || 0.8))), r = o.r || 18, gap = (w - 2 * r) / (n - 1); g.save();
    g.strokeStyle = k.line; g.lineWidth = 4; g.beginPath(); g.moveTo(x + r, y); g.lineTo(x + w - r, y); g.stroke(); g.strokeStyle = k.accent; g.beginPath(); g.moveTo(x + r, y); g.lineTo(x + r + gap * (cur + clamp((lt % (o.every || 0.8)) / 0.3) * 0), y); g.stroke();
    for (let i = 0; i < n; i++) { const done = i <= cur; g.fillStyle = done ? k.accent : k.paper; g.strokeStyle = done ? k.accent : k.line; g.beginPath(); g.arc(x + r + i * gap, y, r, 0, Math.PI * 2); g.fill(); g.stroke(); g.fillStyle = done ? '#fff' : k.muted; g.font = `600 ${r}px ${k.font}`; g.textAlign = 'center'; g.fillText(String(i + 1), x + r + i * gap, y + r * 0.36); } g.restore(); },
  'form-fill': (g, lt, x, y, w, fields, o = {}) => { const k = tok(o), fs = o.size || 26, cps = o.cps || 16; let tt = lt; g.save();
    fields.forEach((f, i) => { const yy = y + i * fs * 3.6, dur = f.value.length / cps + 0.3, active = tt >= 0 && tt < dur; g.fillStyle = k.muted; g.font = `500 ${fs * 0.7}px ${k.font}`; g.textAlign = 'left'; g.fillText(f.label, x, yy);
      g.strokeStyle = active ? k.accent : k.line; g.lineWidth = active ? 3 : 2; g.fillStyle = k.paper; rrect(g, x, yy + 10, w, fs * 1.9, 10); g.fill(); g.stroke(); g.fillStyle = k.ink; g.font = `400 ${fs}px ${k.font}`; g.fillText(tt > 0 ? typed(f.value, tt, cps) : '', x + fs * 0.6, yy + 10 + fs * 1.3); tt -= dur; });
    g.restore(); },
  'modal-dialog': (g, lt, x, y, w, h, title, body, o = {}) => { const k = tok(o), W = g.canvas.width, H = g.canvas.height, p = sp(lt, 'ui'), q = sp(lt - (o.out ?? Infinity), 'snappy'), v = p * (1 - q); if (v <= 0.001) return;
    g.save(); g.fillStyle = `rgba(0,0,0,${0.45 * v})`; g.fillRect(0, 0, W, H); g.translate(x + w / 2, y + h / 2); const s = lerp(0.92, 1, v); g.scale(s, s); g.globalAlpha = clamp(v * 1.5); shadow(g, 50, 20, 'rgba(0,0,0,0.3)'); g.fillStyle = k.paper; rrect(g, -w / 2, -h / 2, w, h, 20); g.fill(); noShadow(g);
    g.fillStyle = k.ink; g.font = `700 ${h * 0.09}px ${k.font}`; g.textAlign = 'left'; g.fillText(title, -w / 2 + w * 0.07, -h / 2 + h * 0.2); g.fillStyle = k.muted; g.font = `400 ${h * 0.06}px ${k.font}`; g.fillText(body, -w / 2 + w * 0.07, -h / 2 + h * 0.36);
    g.fillStyle = k.accent; rrect(g, w / 2 - w * 0.38, h / 2 - h * 0.22, w * 0.31, h * 0.13, 10); g.fill(); g.fillStyle = '#fff'; g.font = `600 ${h * 0.055}px ${k.font}`; g.textAlign = 'center'; g.fillText(o.cta || 'OK', w / 2 - w * 0.225, h / 2 - h * 0.135); g.restore(); },
  'badge-counter': (g, lt, x, y, n, o = {}) => { const p = spring(lt, 300, 16), r = o.r || 18; if (p <= 0) return; g.save(); g.translate(x, y); g.scale(p, p); g.fillStyle = o.color || C0.bad; g.beginPath(); g.arc(0, 0, r, 0, Math.PI * 2); g.fill(); g.fillStyle = '#fff'; g.font = `700 ${r * 1.1}px ${C0.font}`; g.textAlign = 'center'; g.fillText(String(n), 0, r * 0.4); g.restore(); },
  'drag-and-drop': (g, lt, from, to, drawItem, o = {}) => { // cursor grabs an item at `from`, carries it to `to`, drops with a settle
    const tp = sp(lt - 0.3, 'camera'), x = lerp(from[0], to[0], tp), y = lerp(from[1], to[1], tp), lift = clamp(lt / 0.2) * (1 - sp(lt - 1.4, 'snappy'));
    g.save(); g.translate(x, y - lift * 10); g.rotate(lift * -0.04); g.scale(1 + lift * 0.05, 1 + lift * 0.05); shadow(g, 10 + lift * 20, 4 + lift * 10); drawItem(g); g.restore(); arrowCursor(g, x + 10, y + 10, o.cursorScale || 1.2, clamp(lt / 0.15) * (1 - clamp((lt - 1.4) / 0.1))); },
};
