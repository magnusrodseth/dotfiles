#!/usr/bin/env node
// sfx.mjs: synthesize UI sound effects from a cue list, on the film's timeline.
//
//   node sfx.mjs audio/cues.json audio/sfx.wav [--dur 24]
//
// cues.json: [{ "t": 0.5, "type": "click", "gain": 1, "pan": 0 }, ...]
// Types: click, tick, pop, thump, whoosh, swish, rise, chime, type, shimmer, drop, snap, ding, coin, shutter, error,
// success, notify, swipe, heartbeat, page, beep, glitch, scratch, boom, reverse-swell, bubble.
// Recorded sounds mix in the same list: { "t": 3.0, "file": "audio/sfx/fs-whoosh-123.mp3", "gain": 0.8, "rate": 1 }
// (download them with fetch.mjs get/pack; any format ffmpeg reads).
// Put cue times on beats.json values (beats, downbeats, hits), not on guesses.

import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const [cuesPath, outPath = 'audio/sfx.wav'] = process.argv.slice(2).filter((a, i, all) => !a.startsWith('--') && all[i - 1] !== '--dur');
const di = process.argv.indexOf('--dur');
const cues = JSON.parse(readFileSync(cuesPath, 'utf8'));
const SR = 48000;
const DUR = di > 0 ? Number(process.argv[di + 1]) : Math.max(...cues.map((c) => c.t)) + 2;
const N = Math.ceil(DUR * SR);
const L = new Float32Array(N), R = new Float32Array(N);

let s = 42; const noise = () => (s = (s * 1664525 + 1013904223) >>> 0) / 2147483648 - 1;
const lp = () => { let y = 0; return (x, fc) => { y += (1 - Math.exp(-2 * Math.PI * fc / SR)) * (x - y); return y; }; };
const TAU = 2 * Math.PI;

const VOICES = {
  click: () => [0.05, (t) => Math.sin(TAU * 1900 * t) * Math.exp(-t * 110) * 0.5 + (t < 0.002 ? noise() * 0.3 : 0)],
  tick: () => [0.03, (t) => Math.sin(TAU * 3200 * t) * Math.exp(-t * 180) * 0.3],
  pop: () => [0.16, (t) => Math.sin(TAU * (500 + 1100 * t) * t) * Math.exp(-t * 28) * 0.45],
  thump: () => [0.6, (t) => Math.sin(TAU * (85 - 45 * t) * t) * Math.exp(-t * 8) * 0.9],
  whoosh: () => { const f = lp(); return [0.42, (t) => f(noise(), 600 + 3000 * Math.sin(Math.PI * t / 0.42)) * Math.sin(Math.PI * Math.min(1, t / 0.42)) * 0.6]; },
  swish: () => { const f = lp(); return [0.22, (t) => f(noise(), 2500 + 6000 * t / 0.22) * Math.sin(Math.PI * t / 0.22) * 0.35]; },
  rise: () => { const f = lp(); return [0.9, (t) => f(noise(), 300 + 5000 * (t / 0.9) ** 2) * (t / 0.9) ** 2 * 0.5]; },
  chime: () => [1.2, (t) => (Math.sin(TAU * 1046.5 * t) + 0.6 * Math.sin(TAU * 1568 * t) * (t > 0.09 ? 1 : 0) + 0.25 * Math.sin(TAU * 2093 * t)) * Math.exp(-t * 4.5) * 0.22],
  type: () => { const f = lp(); return [0.035, (t) => f(noise(), 4000) * Math.exp(-t * 160) * 0.5 + Math.sin(TAU * 260 * t) * Math.exp(-t * 200) * 0.2]; },
  shimmer: () => [1.0, (t) => [1318.5, 1760, 2637].reduce((a, f, i) => a + Math.sin(TAU * f * t + i) * Math.exp(-t * (3 + i)), 0) * Math.min(1, t / 0.03) * 0.12],
  drop: () => { const f = lp(); return [1.6, (t) => Math.sin(TAU * (48 + 40 * Math.exp(-t * 7)) * t) * Math.exp(-t * 2.4) * 0.85 + f(noise(), 1500) * Math.exp(-t * 6) * 0.35]; },
  snap: () => { const f = lp(); return [0.08, (t) => (noise() - f(noise(), 2500)) * Math.exp(-t * 120) * 0.8]; },
  ding: () => [1.6, (t) => (Math.sin(TAU * 1318.5 * t) + 0.4 * Math.sin(TAU * 2637 * t) * Math.exp(-t * 6)) * Math.exp(-t * 3) * Math.min(1, t / 0.002) * 0.3],
  coin: () => [0.5, (t) => Math.sin(TAU * (t < 0.07 ? 988 : 1319) * t) * Math.exp(-t * 7) * 0.3],
  shutter: () => { const f = lp(); return [0.18, (t) => f(noise(), 4000) * (Math.exp(-t * 80) + (t > 0.07 ? Math.exp(-(t - 0.07) * 90) : 0)) * 0.7]; },
  error: () => [0.32, (t) => Math.sign(Math.sin(TAU * 140 * t)) * (t < 0.13 || (t > 0.17 && t < 0.3) ? 1 : 0) * 0.15],
  success: () => [0.9, (t) => [523.25, 659.25, 783.99, 1046.5].reduce((a, f, i) => a + (t > i * 0.07 ? Math.sin(TAU * f * (t - i * 0.07)) * Math.exp(-(t - i * 0.07) * 6) : 0), 0) * 0.16],
  notify: () => [0.7, (t) => (Math.sin(TAU * 880 * t) * Math.exp(-t * 10) + (t > 0.12 ? Math.sin(TAU * 1174.7 * (t - 0.12)) * Math.exp(-(t - 0.12) * 7) : 0)) * 0.25],
  swipe: () => { const f = lp(); return [0.18, (t) => f(noise(), 1500 + 8000 * (t / 0.18)) * Math.sin(Math.PI * t / 0.18) * 0.4]; },
  heartbeat: () => [0.8, (t) => [0, 0.22].reduce((a, o) => a + (t > o ? Math.sin(TAU * 55 * (t - o)) * Math.exp(-(t - o) * 18) : 0), 0) * 0.9],
  page: () => { const f = lp(), h = lp(); return [0.45, (t) => { const n = noise(); return (f(n, 3000) - h(n, 600)) * Math.sin(Math.PI * Math.min(1, t / 0.45)) * (0.6 + 0.4 * Math.sin(TAU * 23 * t)) * 0.5; }]; },
  beep: () => [0.12, (t) => Math.sin(TAU * 1500 * t) * (t < 0.1 ? 1 : 0) * Math.min(1, t / 0.003) * 0.22],
  glitch: () => [0.3, (t) => { const k = Math.floor(t * 60) % 3; return (k === 0 ? Math.sign(Math.sin(TAU * 220 * t)) : k === 1 ? noise() : Math.sin(TAU * 3300 * t)) * 0.18 * (t < 0.28 ? 1 : 0); }],
  scratch: () => { const f = lp(); return [0.35, (t) => f(noise(), 600 + 2500 * Math.abs(Math.sin(TAU * 5 * t))) * Math.sin(Math.PI * t / 0.35) * 0.6]; },
  boom: () => { const f = lp(); return [2.4, (t) => Math.sin(TAU * (38 + 25 * Math.exp(-t * 5)) * t) * Math.exp(-t * 1.8) * 0.95 + f(noise(), 900) * Math.exp(-t * 3) * 0.4]; },
  'reverse-swell': () => { const f = lp(); return [1.2, (t) => f(noise(), 400 + 4000 * (t / 1.2) ** 3) * (t / 1.2) ** 3 * 0.6 * (t < 1.18 ? 1 : 0)]; },
  bubble: () => [0.12, (t) => Math.sin(TAU * (400 + 1400 * (t / 0.12)) * t) * Math.sin(Math.PI * t / 0.12) * 0.35],
};

const decoded = new Map();
function decode(file, rate = 1) { // stereo float32 at 48 kHz (rate != 1 pitches the sample up/down)
  const key = file + '@' + rate; if (decoded.has(key)) return decoded.get(key);
  const r = spawnSync('ffmpeg', ['-v', 'error', '-i', file, '-af', rate !== 1 ? `aresample=48000,asetrate=${48000 * rate},aresample=48000` : 'anull', '-f', 'f32le', '-ac', '2', '-ar', '48000', '-'], { maxBuffer: 1 << 30 });
  if (r.status) { console.error(`cannot decode ${file}: ${r.stderr}`); process.exit(1); }
  const buf = new Float32Array(r.stdout.buffer, r.stdout.byteOffset, r.stdout.length / 4); decoded.set(key, buf); return buf;
}
for (const c of cues) {
  if (c.file) { const b = decode(c.file, c.rate || 1), g = c.gain ?? 1, pan = c.pan ?? 0, gl = g * Math.min(1, 1 - pan), gr = g * Math.min(1, 1 + pan), start = Math.floor(c.t * SR);
    for (let i = 0; i * 2 < b.length && start + i < N; i++) { if (start + i < 0) continue; L[start + i] += b[i * 2] * gl; R[start + i] += b[i * 2 + 1] * gr; } continue; }
  if (!VOICES[c.type]) { console.error(`unknown sfx type: ${c.type}`); process.exit(1); }
  const [len, fn] = VOICES[c.type]();
  const g = c.gain ?? 1, pan = c.pan ?? 0, gl = g * Math.cos((pan + 1) * Math.PI / 4), gr = g * Math.sin((pan + 1) * Math.PI / 4);
  const start = Math.floor(c.t * SR);
  for (let i = 0; i < len * SR && start + i < N; i++) { if (start + i < 0) continue; const v = fn(i / SR); L[start + i] += v * gl; R[start + i] += v * gr; }
}

const b = Buffer.alloc(44 + N * 4);
b.write('RIFF', 0); b.writeUInt32LE(36 + N * 4, 4); b.write('WAVEfmt ', 8); b.writeUInt32LE(16, 16); b.writeUInt16LE(1, 20); b.writeUInt16LE(2, 22);
b.writeUInt32LE(SR, 24); b.writeUInt32LE(SR * 4, 28); b.writeUInt16LE(4, 32); b.writeUInt16LE(16, 34); b.write('data', 36); b.writeUInt32LE(N * 4, 40);
for (let n = 0; n < N; n++) {
  b.writeInt16LE(Math.round(Math.tanh(L[n]) * 32767 * 0.9), 44 + n * 4);
  b.writeInt16LE(Math.round(Math.tanh(R[n]) * 32767 * 0.9), 46 + n * 4);
}
mkdirSync(path.dirname(outPath), { recursive: true });
writeFileSync(outPath, b);
console.log(`${path.resolve(outPath)}  ${cues.length} cues, ${DUR.toFixed(2)}s`);
