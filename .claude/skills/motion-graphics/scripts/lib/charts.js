// charts.js: data-viz animations, named after library/motion.json "dataviz". Data is drawn, never screenshotted.
// Every figure must come from a named source in docs/brief.md. Never invent a number.
//
//   import { CHART } from './charts.js';
//   CHART['bar-grow'](g, t - 4, [x, y, w, h], [{ label: '2024', value: 12 }, ...], { color: '#5B5BD6' });
//
// Signature: (g, lt, box=[x, y, w, h], data, o). lt = local time. o: color(s), font, ink, max, format, stagger.

import { clamp, lerp, sp, spring, EASE, rrect, hash } from './motion.js';

const F = (o, px, w = 500) => `${w} ${px}px ${o.family || 'system-ui, sans-serif'}`;
const fmt = (o) => o.format || ((v) => Math.round(v).toLocaleString('nb-NO'));
const PAL = ['#5B5BD6', '#3b5bff', '#1FA971', '#F5A524', '#E5484D', '#909ABD'];
const col = (o, i) => (o.colors || PAL)[i % (o.colors || PAL).length];

export const CHART = {
  'axis-gridline-intro': (g, lt, [x, y, w, h], data, o = {}) => { const n = o.lines || 4; g.save(); g.strokeStyle = o.grid || 'rgba(0,0,0,0.12)'; g.lineWidth = 1;
    for (let i = 0; i <= n; i++) { const p = EASE.outCubic(clamp((lt - i * 0.06) / 0.5)), yy = y + h - (h * i) / n; g.beginPath(); g.moveTo(x, yy); g.lineTo(x + w * p, yy); g.stroke(); } g.restore(); },
  'bar-grow': (g, lt, [x, y, w, h], data, o = {}) => { const max = o.max ?? Math.max(...data.map((d) => d.value)), n = data.length, gap = w * 0.25 / n, bw = (w - gap * (n - 1)) / n, fs = o.size || Math.max(14, bw * 0.22);
    g.save(); data.forEach((d, i) => { const p = sp(lt - i * (o.stagger ?? 0.08), 'ui'), bh = (h - fs * 2.6) * (d.value / max) * clamp(p, 0, 1.03), bx = x + i * (bw + gap), by = y + h - fs * 1.5 - bh;
      g.fillStyle = d.color || col(o, o.single ? 0 : i); rrect(g, bx, by, bw, bh, Math.min(8, bw * 0.15)); g.fill(); g.fillStyle = o.ink || '#141413'; g.textAlign = 'center';
      g.font = F(o, fs, 600); g.globalAlpha = clamp((p - 0.6) / 0.4); g.fillText(fmt(o)(d.value * Math.min(1, p)), bx + bw / 2, by - fs * 0.4); g.globalAlpha = 1; g.font = F(o, fs * 0.8); g.fillText(d.label, bx + bw / 2, y + h - fs * 0.2); }); g.restore(); },
  'stacked-bar-build': (g, lt, [x, y, w, h], data, o = {}) => { // data: [{ label, parts: [v1, v2, ...] }]
    const max = o.max ?? Math.max(...data.map((d) => d.parts.reduce((a, b) => a + b, 0))), n = data.length, gap = w * 0.25 / n, bw = (w - gap * (n - 1)) / n; g.save();
    data.forEach((d, i) => { let acc = 0; d.parts.forEach((v, j) => { const p = sp(lt - j * 0.35 - i * 0.05, 'ui'), bh = h * 0.88 * (v / max) * clamp(p); g.fillStyle = col(o, j); g.fillRect(x + i * (bw + gap), y + h * 0.88 - acc - bh, bw, bh); acc += h * 0.88 * (v / max) * clamp(p); }); }); g.restore(); },
  'bar-chart-race': (g, lt, [x, y, w, h], frames, o = {}) => { // frames: [{ t, values: { name: v } }]; ranks re-sort smoothly
    const i = frames.findIndex((f, k) => k === frames.length - 1 || lt < frames[k + 1].t), a = frames[Math.max(0, i)], b = frames[Math.min(frames.length - 1, i + 1)], p = b === a ? 1 : EASE.inOutCubic(clamp((lt - a.t) / (b.t - a.t)));
    const names = Object.keys(a.values), vals = names.map((n) => lerp(a.values[n], b.values[n] ?? a.values[n], p)), max = Math.max(...vals), top = o.top || names.length, bh = h / top * 0.8;
    const rankA = [...names].sort((m, n) => b.values[n] - b.values[m]); const rankOf = (n, vs) => [...names].sort((m, k) => vs[k] - vs[m]).indexOf(n);
    g.save(); names.forEach((n, k) => { const ra = rankOf(n, a.values), rb = rankOf(n, b.values), r = lerp(ra, rb, p); if (r >= top) return; const by = y + r * (h / top), bw = (w * 0.8) * (vals[k] / max);
      g.fillStyle = col(o, k); rrect(g, x, by, bw, bh, 6); g.fill(); g.fillStyle = o.ink || '#141413'; g.font = F(o, bh * 0.45, 600); g.textAlign = 'left'; g.fillText(`${n}  ${fmt(o)(vals[k])}`, x + bw + 12, by + bh * 0.66); }); g.restore(); },
  'line-draw-dot': (g, lt, [x, y, w, h], data, o = {}) => { const vs = data.map((d) => d.value), min = o.min ?? Math.min(...vs), max = o.max ?? Math.max(...vs), n = data.length, p = EASE.inOutCubic(clamp(lt / (o.dur || 1.6)));
    const px = (i) => x + (w * i) / (n - 1), py = (v) => y + h - ((v - min) / (max - min || 1)) * h; const upto = p * (n - 1), k = Math.floor(upto), f = upto - k;
    g.save(); g.strokeStyle = o.color || PAL[0]; g.lineWidth = o.width || 5; g.lineJoin = 'round'; g.lineCap = 'round'; g.beginPath(); for (let i = 0; i <= k; i++) i ? g.lineTo(px(i), py(vs[i])) : g.moveTo(px(i), py(vs[i]));
    const ex = k < n - 1 ? lerp(px(k), px(k + 1), f) : px(k), ey = k < n - 1 ? lerp(py(vs[k]), py(vs[k + 1]), f) : py(vs[k]); g.lineTo(ex, ey); g.stroke();
    g.fillStyle = o.color || PAL[0]; g.beginPath(); g.arc(ex, ey, (o.width || 5) * 2, 0, Math.PI * 2); g.fill();
    if (o.label !== false) { const right = ex > x + w * 0.75; g.font = F(o, o.size || 26, 700); g.fillStyle = o.ink || '#141413'; g.textAlign = right ? 'right' : 'left'; g.fillText(fmt(o)(k < n - 1 ? lerp(vs[k], vs[k + 1], f) : vs[k]), ex + (right ? -18 : 16), ey + (right ? 34 : -12)); } g.restore(); },
  'area-fill': (g, lt, box, data, o = {}) => { const [x, y, w, h] = box, vs = data.map((d) => d.value), min = o.min ?? 0, max = o.max ?? Math.max(...vs), n = vs.length, p = EASE.inOutCubic(clamp((lt - 0.3) / 1.2));
    g.save(); g.beginPath(); g.moveTo(x, y + h); vs.forEach((v, i) => g.lineTo(x + (w * i) / (n - 1), y + h - ((v - min) / (max - min)) * h * p)); g.lineTo(x + w, y + h); g.closePath(); const gr = g.createLinearGradient(0, y, 0, y + h); gr.addColorStop(0, (o.color || PAL[0]) + '88'); gr.addColorStop(1, (o.color || PAL[0]) + '00'); g.fillStyle = gr; g.fill(); g.restore();
    CHART['line-draw-dot'](g, lt, box, data, { ...o, min, max, label: false }); },
  sparkline: (g, lt, box, data, o = {}) => CHART['line-draw-dot'](g, lt, box, data, { width: 3, label: false, dur: 0.9, ...o }),
  'slope-chart': (g, lt, [x, y, w, h], data, o = {}) => { // data: [{ label, a, b }]
    const vs = data.flatMap((d) => [d.a, d.b]), min = Math.min(...vs), max = Math.max(...vs), py = (v) => y + h - ((v - min) / (max - min || 1)) * h; g.save(); g.lineWidth = 4;
    data.forEach((d, i) => { const p = EASE.outCubic(clamp((lt - i * 0.15) / 0.8)); g.strokeStyle = col(o, i); g.fillStyle = col(o, i); g.beginPath(); g.moveTo(x, py(d.a)); g.lineTo(lerp(x, x + w, p), lerp(py(d.a), py(d.b), p)); g.stroke(); g.beginPath(); g.arc(x, py(d.a), 7, 0, Math.PI * 2); g.fill(); if (p >= 1) { g.beginPath(); g.arc(x + w, py(d.b), 7, 0, Math.PI * 2); g.fill(); g.font = F(o, o.size || 22, 600); g.textAlign = 'left'; g.fillText(`${d.label} ${fmt(o)(d.b)}`, x + w + 14, py(d.b) + 8); } }); g.restore(); },
  'donut-sweep': (g, lt, [x, y, w, h], data, o = {}) => { const total = data.reduce((a, d) => a + d.value, 0), cx = x + w / 2, cy = y + h / 2, r = Math.min(w, h) / 2 * 0.9, th = r * (o.thickness ?? 0.28), p = EASE.inOutCubic(clamp(lt / (o.dur || 1.2)));
    g.save(); let a = -Math.PI / 2; data.forEach((d, i) => { const span = (d.value / total) * Math.PI * 2 * p; g.strokeStyle = d.color || col(o, i); g.lineWidth = th; g.beginPath(); g.arc(cx, cy, r - th / 2, a, a + Math.max(0, span - 0.02)); g.stroke(); a += span; });
    if (o.center != null) { g.fillStyle = o.ink || '#141413'; g.font = F(o, r * 0.42, 700); g.textAlign = 'center'; g.fillText(typeof o.center === 'number' ? fmt(o)(o.center * p) : o.center, cx, cy + r * 0.12); if (o.caption) { g.font = F(o, r * 0.14); g.fillText(o.caption, cx, cy + r * 0.36); } } g.restore(); },
  'pie-explode': (g, lt, [x, y, w, h], data, o = {}) => { const total = data.reduce((a, d) => a + d.value, 0), cx = x + w / 2, cy = y + h / 2, r = Math.min(w, h) / 2 * 0.85, p = EASE.inOutCubic(clamp(lt / 1)), ex = sp(lt - 1.1, 'playful') * r * 0.12, hi = o.highlight ?? 0;
    g.save(); let a = -Math.PI / 2; data.forEach((d, i) => { const span = (d.value / total) * Math.PI * 2 * p, mid = a + span / 2, off = i === hi ? ex : 0; g.fillStyle = d.color || col(o, i); g.beginPath(); g.moveTo(cx + Math.cos(mid) * off, cy + Math.sin(mid) * off); g.arc(cx + Math.cos(mid) * off, cy + Math.sin(mid) * off, r, a, a + span); g.closePath(); g.fill(); a += span; }); g.restore(); },
  'progress-ring': (g, lt, [x, y, w, h], value, o = {}) => { const cx = x + w / 2, cy = y + h / 2, r = Math.min(w, h) / 2 * 0.9, th = r * 0.16, p = EASE.outCubic(clamp(lt / (o.dur || 1.3))) * value;
    g.save(); g.lineCap = 'round'; g.lineWidth = th; g.strokeStyle = o.track || 'rgba(0,0,0,0.1)'; g.beginPath(); g.arc(cx, cy, r - th / 2, 0, Math.PI * 2); g.stroke(); g.strokeStyle = o.color || PAL[0]; g.beginPath(); g.arc(cx, cy, r - th / 2, -Math.PI / 2, -Math.PI / 2 + p * Math.PI * 2); g.stroke();
    g.fillStyle = o.ink || '#141413'; g.font = F(o, r * 0.45, 700); g.textAlign = 'center'; g.fillText(`${Math.round(p * 100)}%`, cx, cy + r * 0.15); g.restore(); },
  'big-counter': (g, lt, [x, y, w, h], value, o = {}) => { const p = EASE.outExpo(clamp(lt / (o.dur || 1.4))); g.save(); g.fillStyle = o.color || '#141413'; g.font = F(o, o.size || h * 0.6, 800); g.textAlign = o.align || 'center';
    if ('fontVariantNumeric' in g) g.fontVariantNumeric = 'tabular-nums'; g.fillText((o.prefix || '') + fmt(o)(lerp(o.from || 0, value, p)) + (o.suffix || ''), o.align === 'left' ? x : x + w / 2, y + h * 0.7); if (o.caption) { g.font = F(o, (o.size || h * 0.6) * 0.22); g.globalAlpha = clamp((lt - 0.8) / 0.4); g.fillText(o.caption, o.align === 'left' ? x : x + w / 2, y + h * 0.95); } g.restore(); },
  'waffle-unit-chart': (g, lt, [x, y, w, h], value, o = {}) => { const n = o.units || 100, cols = o.cols || 10, rows = Math.ceil(n / cols), cs = Math.min(w / cols, h / rows), on = Math.round(value * n); g.save();
    for (let i = 0; i < n; i++) { const p = sp(lt - i * 0.008, 'snappy'), cx = x + (i % cols) * cs + cs / 2, cy = y + Math.floor(i / cols) * cs + cs / 2, s = cs * 0.38 * p; g.fillStyle = i < on ? o.color || PAL[0] : o.off || 'rgba(0,0,0,0.1)'; rrect(g, cx - s, cy - s, 2 * s, 2 * s, s * 0.3); g.fill(); } g.restore(); },
  'heatmap-fill': (g, lt, [x, y, w, h], grid, o = {}) => { const rows = grid.length, cols = grid[0].length, cw = w / cols, ch = h / rows, max = Math.max(...grid.flat()); g.save();
    grid.forEach((row, j) => row.forEach((v, i) => { const p = EASE.outCubic(clamp((lt - (i + j) * 0.03) / 0.4)); g.globalAlpha = p * (0.12 + 0.88 * (v / max)); g.fillStyle = o.color || PAL[0]; rrect(g, x + i * cw + 2, y + j * ch + 2, cw - 4, ch - 4, 4); g.fill(); })); g.restore(); },
  'scatter-bloom': (g, lt, [x, y, w, h], pts, o = {}) => { const xs = pts.map((p) => p.x), ys = pts.map((p) => p.y), [x0, x1, y0, y1] = [Math.min(...xs), Math.max(...xs), Math.min(...ys), Math.max(...ys)]; g.save();
    pts.forEach((pt, i) => { const p = spring(lt - hash(i, 4) * 0.8, 260, 16), r = (pt.r || 8) * p; if (r <= 0) return; g.fillStyle = pt.color || col(o, pt.group || 0); g.globalAlpha = 0.85; g.beginPath(); g.arc(x + ((pt.x - x0) / (x1 - x0 || 1)) * w, y + h - ((pt.y - y0) / (y1 - y0 || 1)) * h, r, 0, Math.PI * 2); g.fill(); }); g.restore(); },
  'comparison-split': (g, lt, [x, y, w, h], data, o = {}) => { // data: [{ label, value, color }] two items
    const p = sp(lt, 'ui'), tot = data[0].value + data[1].value, split = lerp(0.5, data[0].value / tot, p); g.save(); g.fillStyle = data[0].color || PAL[0]; g.fillRect(x, y, w * split, h); g.fillStyle = data[1].color || PAL[4]; g.fillRect(x + w * split, y, w * (1 - split), h);
    g.fillStyle = '#fff'; g.font = F(o, h * 0.22, 700); g.textAlign = 'left'; g.fillText(`${data[0].label} ${fmt(o)(data[0].value * p)}`, x + h * 0.2, y + h * 0.6); g.textAlign = 'right'; g.fillText(`${fmt(o)(data[1].value * p)} ${data[1].label}`, x + w - h * 0.2, y + h * 0.6); g.restore(); },
  'timeline-scrub': (g, lt, [x, y, w, h], events, o = {}) => { // events: [{ at: 0..1, label }]; playhead sweeps
    const p = EASE.inOutSine(clamp(lt / (o.dur || 3))); g.save(); g.strokeStyle = o.track || 'rgba(0,0,0,0.2)'; g.lineWidth = 4; g.beginPath(); g.moveTo(x, y + h / 2); g.lineTo(x + w, y + h / 2); g.stroke(); g.strokeStyle = o.color || PAL[0]; g.beginPath(); g.moveTo(x, y + h / 2); g.lineTo(x + w * p, y + h / 2); g.stroke();
    events.forEach((e, i) => { const on = p >= e.at, s = on ? spring(lt - e.at * (o.dur || 3), 260, 16) : 0.6; g.fillStyle = on ? o.color || PAL[0] : o.track || 'rgba(0,0,0,0.25)'; g.beginPath(); g.arc(x + w * e.at, y + h / 2, 10 * s, 0, Math.PI * 2); g.fill(); g.fillStyle = o.ink || '#141413'; g.globalAlpha = on ? 1 : 0.4; g.font = F(o, o.size || 20, 600); g.textAlign = 'center'; g.fillText(e.label, x + w * e.at, y + h / 2 + (i % 2 ? 44 : -26)); g.globalAlpha = 1; });
    g.fillStyle = o.color || PAL[0]; g.fillRect(x + w * p - 2, y, 4, h); g.restore(); },
  'map-pin-drop': (g, lt, x, y, o = {}) => { const p = spring(lt, 300, 14), drop = (1 - clamp(lt / 0.35)) * 120; if (lt < 0) return; g.save(); g.globalAlpha = 0.25 * clamp(lt / 0.35); g.fillStyle = '#000'; g.beginPath(); g.ellipse(x, y, 14 * p, 5 * p, 0, 0, Math.PI * 2); g.fill(); g.globalAlpha = 1;
    g.translate(x, y - drop); g.scale(p, p); g.fillStyle = o.color || PAL[4]; g.beginPath(); g.moveTo(0, 0); g.bezierCurveTo(-6, -14, -20, -22, -20, -38); g.arc(0, -38, 20, Math.PI, 0); g.bezierCurveTo(20, -22, 6, -14, 0, 0); g.fill(); g.fillStyle = '#fff'; g.beginPath(); g.arc(0, -38, 7, 0, Math.PI * 2); g.fill(); g.restore();
    if (o.label) { g.save(); g.globalAlpha = clamp((lt - 0.4) / 0.3); g.font = F(o, o.size || 22, 600); g.fillStyle = o.ink || '#141413'; g.textAlign = 'left'; g.fillText(o.label, x + 26, y - 30); g.restore(); } },
  'flow-sankey-draw': (g, lt, [x, y, w, h], flows, o = {}) => { // flows: [{ from: 0..1 (y), to: 0..1, width }] drawn as ribbons left to right
    g.save(); flows.forEach((f, i) => { const p = EASE.inOutCubic(clamp((lt - i * 0.12) / 1)), y0 = y + f.from * h, y1 = y + f.to * h, bw = f.width || 20; g.save(); g.beginPath(); g.rect(x, y - h, w * p, h * 3); g.clip(); g.strokeStyle = (f.color || col(o, i)) + 'aa'; g.lineWidth = bw;
      g.beginPath(); g.moveTo(x, y0); g.bezierCurveTo(x + w / 2, y0, x + w / 2, y1, x + w, y1); g.stroke(); g.restore(); }); g.restore(); },
  'annotation-on-chart': (g, lt, x, y, text, o = {}) => { const p = sp(lt, 'snappy'); if (p <= 0) return; g.save(); g.globalAlpha = clamp(p); g.strokeStyle = o.color || '#141413'; g.lineWidth = 2; g.setLineDash([6, 6]); g.beginPath(); g.moveTo(x, y); g.lineTo(x, y - (o.len || 80) * p); g.stroke(); g.setLineDash([]);
    g.font = F(o, o.size || 22, 600); g.fillStyle = o.color || '#141413'; g.textAlign = 'center'; g.fillText(text, x, y - (o.len || 80) * p - 12); g.restore(); },
  'number-to-chart-morph': (g, lt, box, data, o = {}) => { // a big number holds, then shrinks into the last bar of a bar chart
    const [x, y, w, h] = box, m = sp(lt - (o.at ?? 1.2), 'ui'); if (m < 0.999) { g.save(); g.globalAlpha = 1 - clamp(m); const s = lerp(1, 0.3, m); g.translate(x + w / 2, y + h / 2); g.scale(s, s); g.fillStyle = o.color || PAL[0]; g.font = F(o, h * 0.5, 800); g.textAlign = 'center'; g.fillText(fmt(o)(data[data.length - 1].value), 0, h * 0.18); g.restore(); }
    if (m > 0.05) CHART['bar-grow'](g, lt - (o.at ?? 1.2), box, data, { ...o, single: true }); },
};
