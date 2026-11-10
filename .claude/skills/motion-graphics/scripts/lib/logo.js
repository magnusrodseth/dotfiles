// logo.js: logo reveals and end cards, named after library/motion.json "logo_reveals". Works on the REAL logo SVG.
//
//   import { loadLogo, LOGO } from './logo.js';
//   const logo = await loadLogo('assets/logo.svg');            // in window.ready
//   LOGO['stroke-draw-then-fill'](g, t - 20, logo, cx, cy, height, { stroke: '#fff' });
//
// loadLogo parses every <path>, <circle>, <rect>, <polygon> into Path2D with its fill, measures path lengths
// (for stroke draws) and keeps the viewBox. Reveals are pure functions of local time lt.

import { clamp, lerp, sp, spring, EASE, rng, hash, noise2, layerOf } from './motion.js';

export async function loadLogo(url) {
  const txt = await (await fetch(url)).text();
  const doc = new DOMParser().parseFromString(txt, 'image/svg+xml'), svg = doc.querySelector('svg');
  const vb = (svg.getAttribute('viewBox') || `0 0 ${svg.getAttribute('width')} ${svg.getAttribute('height')}`).split(/[\s,]+/).map(Number);
  const host = document.createElementNS('http://www.w3.org/2000/svg', 'svg'); host.style.position = 'absolute'; host.style.visibility = 'hidden'; document.body.appendChild(host);
  const css = [...doc.querySelectorAll('style')].map((s) => s.textContent).join('\n'); // class fills from <style> (light theme)
  const classFill = (el) => { const cls = el.getAttribute('class'); if (!cls) return null; const m = css.match(new RegExp(`\\.${cls}\\s*\\{[^}]*fill:\\s*([^;}]+)`)); return m ? m[1].trim() : null; };
  const parts = [];
  const live = document.importNode(svg, true); live.setAttribute('width', vb[2]); live.setAttribute('height', vb[3]); host.appendChild(live); // to read transforms
  const els = [...live.querySelectorAll('path, circle, rect, polygon, ellipse')].filter((el) => !el.closest('defs, clipPath, mask, symbol, pattern, marker'));
  const rootInv = live.getCTM()?.inverse();
  for (const el of els) {
    let d = el.getAttribute('d');
    if (el.tagName === 'circle') { const cx = +el.getAttribute('cx'), cy = +el.getAttribute('cy'), r = +el.getAttribute('r'); d = `M${cx - r},${cy}a${r},${r} 0 1,0 ${2 * r},0a${r},${r} 0 1,0 ${-2 * r},0`; }
    if (el.tagName === 'ellipse') { const cx = +el.getAttribute('cx'), cy = +el.getAttribute('cy'), rx = +el.getAttribute('rx'), ry = +el.getAttribute('ry'); d = `M${cx - rx},${cy}a${rx},${ry} 0 1,0 ${2 * rx},0a${rx},${ry} 0 1,0 ${-2 * rx},0`; }
    if (el.tagName === 'rect') { const x = +el.getAttribute('x') || 0, y = +el.getAttribute('y') || 0, w = +el.getAttribute('width'), h = +el.getAttribute('height'); d = `M${x},${y}h${w}v${h}h${-w}z`; }
    if (el.tagName === 'polygon') d = 'M' + el.getAttribute('points').trim().split(/\s+/).join('L') + 'Z';
    if (!d) continue;
    const pe = document.createElementNS('http://www.w3.org/2000/svg', 'path'); pe.setAttribute('d', d); host.appendChild(pe);
    const ctm = el.getCTM(), m = ctm && rootInv ? rootInv.multiply(ctm) : null; const path2 = new Path2D(); path2.addPath(new Path2D(d), m ? new DOMMatrix([m.a, m.b, m.c, m.d, m.e, m.f]) : undefined);
    const k = m ? Math.sqrt(Math.abs(m.a * m.d - m.b * m.c)) : 1;
    const fill = el.getAttribute('fill') || classFill(el) || (el.closest('[fill]')?.getAttribute('fill')) || '#000';
    const bb = pe.getBBox(), box = m ? (() => { const p0 = new DOMPoint(bb.x, bb.y).matrixTransform(m), p1 = new DOMPoint(bb.x + bb.width, bb.y + bb.height).matrixTransform(m); return { x: Math.min(p0.x, p1.x), y: Math.min(p0.y, p1.y), width: Math.abs(p1.x - p0.x), height: Math.abs(p1.y - p0.y) }; })() : bb;
    parts.push({ path: path2, d, fill: fill === 'none' ? null : fill, len: pe.getTotalLength() * k, box });
  }
  host.remove();
  return { vb, parts, aspect: vb[2] / vb[3] };
}
// Transform so the logo is drawn centred at (cx, cy) with height h.
function place(g, logo, cx, cy, h) { const s = h / logo.vb[3]; g.translate(cx - (logo.vb[2] * s) / 2, cy - h / 2); g.scale(s, s); g.translate(-logo.vb[0], -logo.vb[1]); return s; }
const fillAll = (g, logo, color, alpha = 1) => { g.globalAlpha = alpha; for (const p of logo.parts) if (p.fill) { g.fillStyle = color || p.fill; g.fill(p.path); } g.globalAlpha = 1; };

export const LOGO = {
  'stroke-draw-then-fill': (g, lt, logo, cx, cy, h, o = {}) => { g.save(); const s = place(g, logo, cx, cy, h), d = o.dur || 1.2;
    logo.parts.forEach((p, i) => { const e = EASE.inOutCubic(clamp((lt - i * 0.08) / d)); g.setLineDash([p.len, p.len]); g.lineDashOffset = p.len * (1 - e); g.strokeStyle = o.stroke || p.fill || '#000'; g.lineWidth = (o.width || 2) / s; g.stroke(p.path); });
    g.setLineDash([]); fillAll(g, logo, o.color, EASE.inOutCubic(clamp((lt - d * 0.8) / 0.5))); g.restore(); },
  'mask-slice-reveal': (g, lt, logo, cx, cy, h, o = {}) => { const n = o.slices || 5, W = (h * logo.aspect); g.save();
    for (let i = 0; i < n; i++) { const p = sp(lt - i * 0.06, 'heavy'); g.save(); g.beginPath(); g.rect(cx - W / 2, cy - h / 2 + (i * h) / n, W, h / n + 1); g.clip(); g.translate(0, (1 - p) * h * 0.6 * (i % 2 ? 1 : -1)); place(g, logo, cx, cy, h); fillAll(g, logo, o.color); g.restore(); } g.restore(); },
  'shape-assemble': (g, lt, logo, cx, cy, h, o = {}) => { const r = rng(o.seed || 5); g.save(); const s = place(g, logo, cx, cy, h);
    logo.parts.forEach((p, i) => { const pp = sp(lt - i * 0.07, 'playful'), dx = (r() - 0.5) * 600 / s, dy = (r() - 0.5) * 600 / s, rot = (r() - 0.5) * 2, bx = p.box.x + p.box.width / 2, by = p.box.y + p.box.height / 2;
      g.save(); g.translate(bx + dx * (1 - pp), by + dy * (1 - pp)); g.rotate(rot * (1 - pp)); g.scale(Math.max(0.001, pp), Math.max(0.001, pp)); g.translate(-bx, -by); g.globalAlpha = clamp(pp * 2); if (p.fill) { g.fillStyle = o.color || p.fill; g.fill(p.path); } g.restore(); }); g.restore(); },
  'dot-morph-to-logo': (g, lt, logo, cx, cy, h, o = {}) => { const p = sp(lt - 0.4, 'heavy'), dot = spring(lt, 300, 18) * h * 0.08; g.save();
    if (p < 0.999) { g.globalAlpha = 1 - p; g.fillStyle = o.dot || o.color || logo.parts[0]?.fill || '#000'; g.beginPath(); g.arc(cx, cy, dot * (1 + p * 4), 0, Math.PI * 2); g.fill(); }
    g.globalAlpha = clamp(p); g.translate(cx, cy); g.scale(lerp(0.4, 1, p), lerp(0.4, 1, p)); g.translate(-cx, -cy); place(g, logo, cx, cy, h); fillAll(g, logo, o.color, clamp(p)); g.restore(); },
  'ink-bleed-reveal': (g, lt, logo, cx, cy, h, o = {}) => { const W = h * logo.aspect, e = EASE.inOutSine(clamp(lt / (o.dur || 1.4))), r = rng(o.seed || 7); g.save(); g.beginPath();
    for (let i = 0; i < 24; i++) { const x = cx + (r() - 0.5) * W, y = cy + (r() - 0.5) * h, rr = e * (0.2 + r() * 0.5) * W * clamp((e - r() * 0.4) / 0.6); if (rr > 0) { g.moveTo(x + rr, y); g.arc(x, y, rr, 0, Math.PI * 2); } } g.clip(); place(g, logo, cx, cy, h); fillAll(g, logo, o.color); g.restore(); },
  'light-sweep-glint': (g, lt, logo, cx, cy, h, o = {}) => { g.save(); place(g, logo, cx, cy, h); fillAll(g, logo, o.color); g.restore(); const W = h * logo.aspect, p = clamp((lt - (o.at ?? 0.3)) / 0.7); if (p <= 0 || p >= 1) return;
    g.save(); place(g, logo, cx, cy, h); const all = new Path2D(); for (const pt of logo.parts) if (pt.fill) all.addPath(pt.path); g.clip(all); g.setTransform(1, 0, 0, 1, 0, 0); const x = lerp(cx - W, cx + W, p), gr = g.createLinearGradient(x - h * 0.3, 0, x + h * 0.3, 0);
    gr.addColorStop(0, 'rgba(255,255,255,0)'); gr.addColorStop(0.5, 'rgba(255,255,255,0.75)'); gr.addColorStop(1, 'rgba(255,255,255,0)'); g.fillStyle = gr; g.fillRect(cx - W, cy - h, W * 2, h * 2); g.restore(); },
  'glitch-resolve': (g, lt, logo, cx, cy, h, o = {}) => { const settle = o.dur || 0.8, k = clamp(1 - lt / settle), f = Math.floor(lt * 30), r = rng(f + 3); g.save();
    if (k > 0) { g.globalCompositeOperation = 'lighter'; [['#ff0050', -1], ['#00e0ff', 1]].forEach(([c, s]) => { g.save(); g.translate(s * k * h * 0.06 + (r() - 0.5) * k * h * 0.1, 0); place(g, logo, cx, cy, h); fillAll(g, logo, c, 0.8); g.restore(); }); g.globalCompositeOperation = 'source-over'; }
    g.save(); g.translate((r() - 0.5) * k * h * 0.05, 0); place(g, logo, cx, cy, h); fillAll(g, logo, o.color, lt < 0.05 ? 0 : 1); g.restore(); g.restore(); },
  'stamp-slam': (g, lt, logo, cx, cy, h, o = {}) => { const p = spring(lt, 420, 26), s = lerp(2.2, 1, p); if (lt < 0) return; g.save(); g.globalAlpha = clamp(lt / 0.05); g.translate(cx, cy); g.rotate((o.rot ?? -0.08) * (1 - p)); g.scale(s, s); g.translate(-cx, -cy); place(g, logo, cx, cy, h); fillAll(g, logo, o.color); g.restore(); },
  'macro-pull-out': (g, lt, logo, cx, cy, h, o = {}) => { const p = sp(lt, 'camera'), s = lerp(o.from || 8, 1, p); g.save(); g.translate(cx, cy); g.scale(s, s); g.translate(-cx, -cy); if (p < 0.6) g.filter = `blur(${((0.6 - p) * 12).toFixed(1)}px)`; place(g, logo, cx, cy, h); fillAll(g, logo, o.color); g.restore(); },
  'orbit-converge': (g, lt, logo, cx, cy, h, o = {}) => { const p = sp(lt - 0.2, 'heavy'), n = o.count || 6; g.save(); g.fillStyle = o.dot || logo.parts[0]?.fill || '#000';
    for (let i = 0; i < n; i++) { const a = (i / n) * Math.PI * 2 + lt * 4 * (1 - p), r = h * 1.4 * (1 - p); g.globalAlpha = 1 - p; g.beginPath(); g.arc(cx + Math.cos(a) * r, cy + Math.sin(a) * r, h * 0.05, 0, Math.PI * 2); g.fill(); }
    g.globalAlpha = 1; g.translate(cx, cy); g.scale(p, p); g.translate(-cx, -cy); place(g, logo, cx, cy, h); fillAll(g, logo, o.color, clamp(p)); g.restore(); },
  'underline-sign-off': (g, lt, logo, cx, cy, h, o = {}) => { g.save(); place(g, logo, cx, cy, h); fillAll(g, logo, o.color, clamp(lt / 0.3)); g.restore(); const W = h * logo.aspect, p = EASE.inOutCubic(clamp((lt - 0.4) / 0.6));
    g.save(); g.strokeStyle = o.accent || '#FFD84D'; g.lineWidth = h * 0.06; g.lineCap = 'round'; g.beginPath(); g.moveTo(cx - W / 2, cy + h * 0.7); g.quadraticCurveTo(cx, cy + h * 0.85, cx - W / 2 + W * p, cy + h * 0.68); g.stroke(); g.restore(); },
};
// End card helpers (text-level): three-beat = logo, then tagline, then CTA/URL, each on its own beat.
export function endCardThreeBeat(g, lt, logo, cx, cy, h, o = {}) {
  LOGO[o.reveal || 'dot-morph-to-logo'](g, lt, logo, cx, cy - h * 0.5, h, o);
  const font = o.font || `500 ${h * 0.32}px system-ui, sans-serif`, beat = o.beat || 0.5;
  [[o.tagline, 2], [o.cta, 4]].forEach(([s, b], i) => { if (!s) return; const p = sp(lt - beat * b, 'heavy'); g.save(); g.globalAlpha = clamp(p); g.font = i ? o.ctaFont || font : font; g.fillStyle = i ? o.accent || '#FFD84D' : o.ink || '#fff'; g.textAlign = 'center'; g.fillText(s, cx, cy + h * (0.6 + i * 0.55) + (1 - p) * h * 0.3); g.restore(); });
}
