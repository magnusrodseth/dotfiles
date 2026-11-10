#!/usr/bin/env node
// score.mjs: synthesize an original, deterministic score on the film's timeline, plus beats.json.
//
//   node score.mjs --genre house --mood bright --sections intro:2,build:2,drop:6,outro:2 [--bpm 124] [--key F]
//   node score.mjs --list
//
// GENRE sets rhythm and instruments (and a default BPM); MOOD sets harmony and brightness. Any genre x any mood.
//   genres: pop, house, lofi, cinematic, ambient, synthwave, hiphop, corporate, playful, piano
//   moods:  warm (I-V-vi-IV), bright (I-IV-vi-V), calm (I-vi-IV-V), tense (i-VI-III-VII), melancholic (vi-IV-I-V), heroic (I-bVII-IV-I)
// Sections are in bars (4 beats). Types: intro, build, drop, break, outro.
// Writes --out (default audio/score.wav, 48 kHz stereo) and --beats (default audio/beats.json):
// { bpm, genre, mood, key, dur, tail, beats, downbeats, sections:[{type,start,end}], hits, snares }.
// The film reads beats.json, so cuts land on the music, never the other way round.

import { writeFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';

const argv = process.argv.slice(2);
const arg = (k, d) => { const i = argv.indexOf('--' + k); return i >= 0 ? argv[i + 1] : d; };

// ---- Genres: 16-step patterns per bar (x = hit, o = accent hit), instruments, defaults ----
const GENRES = {
  pop:       { bpm: 120, swing: 0.5,  kick: 'x...x...x...x...', snare: '....x.......x...', hat: 'x.x.x.x.x.x.x.x.', ohat: '..............x.', bass: 'x.x.x.x.x.x.x.x.', bassOct: true, chords: 'pad', lead: 'pluck16', riser: 1, impact: 1, pump: 1 },
  house:     { bpm: 124, swing: 0.5,  kick: 'x...x...x...x...', clap: '....x.......x...', hat: 'x.x.x.x.x.x.x.x.', ohat: '..x...x...x...x.', bass: '..x...x...x...x.', chords: 'stab', stab: '...x..x....x..x.', lead: 'none', riser: 1, impact: 1, pump: 1.3 },
  lofi:      { bpm: 80,  swing: 0.6,  kick: 'x.......x.x.....', snare: '....x.......x...', hat: 'x.x.x.x.x.x.x.x.', bass: 'x.......x.x.....', chords: 'rhodes', lead: 'none', crackle: 1, cutoff: 0.6, riser: 0, impact: 0, soft: 0.6 },
  cinematic: { bpm: 90,  swing: 0.5,  toms: 'x.....x...x.....', bass: 'x.......x.......', chords: 'strings', lead: 'ostinato', riser: 1, impact: 1.2 },
  ambient:   { bpm: 70,  swing: 0.5,  bass: 'x...............', chords: 'strings', lead: 'bell', riser: 0, impact: 0, cutoff: 0.8 },
  synthwave: { bpm: 100, swing: 0.5,  kick: 'x.......x.......', snare: '....x.......x...', gated: 1, hat: 'x.x.x.x.x.x.x.x.', bass: 'xxxxxxxxxxxxxxxx', bassOct: true, chords: 'pad', lead: 'arp16', riser: 1, impact: 1, cutoff: 1.3 },
  hiphop:    { bpm: 90,  swing: 0.57, kick: 'x......x..x.....', snare: '....x.......x...', hat: 'x.x.x.x.x.x.x.x.', bass: 'x......x..x.....', chords: 'piano', lead: 'none', riser: 0, impact: 0.6, cutoff: 0.8 },
  corporate: { bpm: 110, swing: 0.5,  kick: 'x.......x.......', clap: '....x.......x...', shaker: 'xxxxxxxxxxxxxxxx', bass: 'x...x...x...x...', chords: 'pad', lead: 'pluck8', riser: 1, impact: 0.8 },
  playful:   { bpm: 116, swing: 0.55, kick: 'x.......x.......', clap: '....x.......x...', shaker: 'x.xxx.xxx.xxx.xx', bass: 'x...x.x.x...x...', staccato: 1, chords: 'none', lead: 'marimba', riser: 0, impact: 0.5 },
  piano:     { bpm: 84,  swing: 0.5,  bass: 'x.......x.......', chords: 'piano', lead: 'piano', riser: 0, impact: 0, soft: 0.8 },
};
const MOODS = {
  warm:        { scale: [0, 2, 4, 5, 7, 9, 11], prog: [0, 4, 5, 3], cutoff: 1500 },
  bright:      { scale: [0, 2, 4, 5, 7, 9, 11], prog: [0, 3, 5, 4], cutoff: 2300 },
  calm:        { scale: [0, 2, 4, 5, 7, 9, 11], prog: [0, 5, 3, 4], cutoff: 1100 },
  tense:       { scale: [0, 2, 3, 5, 7, 8, 10], prog: [0, 5, 2, 6], cutoff: 1300 },
  melancholic: { scale: [0, 2, 4, 5, 7, 9, 11], prog: [5, 3, 0, 4], cutoff: 1200 },
  heroic:      { scale: [0, 2, 4, 5, 7, 9, 10], prog: [0, 6, 3, 0], cutoff: 1900 },
};
if (argv.includes('--list')) { console.log('genres: ' + Object.entries(GENRES).map(([k, v]) => `${k} (${v.bpm} BPM)`).join(', ') + '\nmoods:  ' + Object.keys(MOODS).join(', ')); process.exit(0); }

const GN = arg('genre', 'pop'), G = GENRES[GN], MOOD = arg('mood', 'warm'), M = MOODS[MOOD];
if (!G) { console.error(`unknown genre ${GN}. Known: ${Object.keys(GENRES).join(', ')}`); process.exit(1); }
if (!M) { console.error(`unknown mood ${MOOD}. Known: ${Object.keys(MOODS).join(', ')}`); process.exit(1); }
const BPM = Number(arg('bpm', G.bpm)), KEY = arg('key', 'F'), SEED = Number(arg('seed', 7)), TAIL = Number(arg('tail', 1.5));
const OUT = arg('out', 'audio/score.wav'), BEATS = arg('beats', 'audio/beats.json');
const sections = arg('sections', 'intro:2,build:2,drop:6,outro:2').split(',').map((s) => { const [type, bars] = s.split(':'); return { type, bars: Number(bars) }; });

const NOTES_OK = ['C', 'C#', 'Db', 'D', 'D#', 'Eb', 'E', 'F', 'F#', 'Gb', 'G', 'G#', 'Ab', 'A', 'A#', 'Bb', 'B'];
if (!NOTES_OK.includes(KEY)) { console.error(`bad --key ${KEY}. Use one of ${NOTES_OK.join(' ')} (the mood sets major/minor)`); process.exit(1); }
if (!(BPM > 20 && BPM < 300)) { console.error(`bad --bpm ${BPM}`); process.exit(1); }
for (const s of sections) if (!['intro', 'build', 'drop', 'break', 'outro'].includes(s.type) || !(s.bars > 0)) { console.error(`bad section ${s.type}:${s.bars}. Types: intro, build, drop, break, outro; bars > 0`); process.exit(1); }
const SR = 48000, BEAT = 60 / BPM, BAR = BEAT * 4, STEP = BEAT / 4;
const totalBars = sections.reduce((a, s) => a + s.bars, 0), DUR = totalBars * BAR, N = Math.ceil((DUR + TAIL) * SR);
const L = new Float32Array(N), R = new Float32Array(N), SEND = new Float32Array(N);
const CUT = M.cutoff * (G.cutoff || 1), SOFT = G.soft || 1;

let seed = SEED;
const rnd = () => { seed |= 0; seed = (seed + 0x6D2B79F5) | 0; let t = Math.imul(seed ^ (seed >>> 15), 1 | seed); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
const noise = () => rnd() * 2 - 1;
const NOTE = { C: 0, 'C#': 1, Db: 1, D: 2, 'D#': 3, Eb: 3, E: 4, F: 5, 'F#': 6, Gb: 6, G: 7, 'G#': 8, Ab: 8, A: 9, 'A#': 10, Bb: 10, B: 11 };
const ROOT = 48 + NOTE[KEY];
const deg = (d) => ROOT + M.scale[((d % 7) + 7) % 7] + 12 * Math.floor(d / 7);
const chord = (d, n = 3) => Array.from({ length: n }, (_, i) => deg(d + 2 * i));
const hz = (m) => 440 * Math.pow(2, (m - 69) / 12);
const TAU = 2 * Math.PI;
// Swing: delay 8th offbeats (and odd 16ths by half as much).
const stepT = (barT, s) => barT + s * STEP + (s % 4 === 2 ? (G.swing - 0.5) * 2 * (BEAT / 2) : s % 2 === 1 ? (G.swing - 0.5) * STEP : 0);
const hits = (pat) => (pat ? [...pat].map((c, i) => (c === 'x' || c === 'o' ? i : -1)).filter((i) => i >= 0) : []);

function voice(t0, len, fn, gain = 1, pan = 0, send = 0, duck = null) {
  const s0 = Math.floor(t0 * SR), n = Math.floor(len * SR);
  const gl = gain * Math.cos((pan + 1) * Math.PI / 4), gr = gain * Math.sin((pan + 1) * Math.PI / 4);
  for (let i = 0; i < n && s0 + i < N; i++) {
    if (s0 + i < 0) continue;
    let v = fn(i / SR); if (duck) v *= duck((s0 + i) / SR);
    L[s0 + i] += v * gl; R[s0 + i] += v * gr; SEND[s0 + i] += v * gain * send;
  }
}
const lp = () => { let y = 0; return (x, fc) => { y += (1 - Math.exp(-TAU * fc / SR)) * (x - y); return y; }; };
const kicks = [];
const duckAt = (t) => { if (!G.pump) return 1; let g = 1; for (const k of kicks) { const d = t - k; if (d >= 0 && d < 0.4) g = Math.min(g, 1 - 0.5 * G.pump * Math.exp(-d * 9)); } return Math.max(0.2, g); };

// ---- Instruments ----
const pad = (notes, t0, len, level, cutoff, ducked, attack = 0.35, detune = 6) => notes.forEach((m, j) => {
  const f = hz(m + 12), f1 = f * Math.pow(2, detune / 1200), f2 = f * Math.pow(2, -detune / 1200), filt = lp(); let p1 = rnd(), p2 = rnd();
  voice(t0, len + 0.9, (t) => { p1 = (p1 + f1 / SR) % 1; p2 = (p2 + f2 / SR) % 1;
    const env = Math.min(1, t / attack) * (t > len ? Math.exp(-(t - len) * 5) : 1);
    return filt((2 * p1 - 1) + (2 * p2 - 1) + 0.6 * Math.sin(TAU * f * 2 * t), cutoff * (0.8 + 0.2 * Math.sin(t * 0.7 + j))) * env * 0.11; }, level, (j - 1) * 0.35, 0.5, ducked ? duckAt : null); });
const strings = (notes, t0, len, level) => pad([...notes, notes[0] - 12], t0, len, level * 1.1, CUT * 0.7, false, 0.9, 11);
const stab = (notes, t0, level) => notes.forEach((m, j) => { const f = hz(m + 12), filt = lp(); let p = rnd();
  voice(t0, 0.32, (t) => { p = (p + f / SR) % 1; return filt(2 * p - 1, 600 + 4000 * Math.exp(-t * 18)) * Math.exp(-t * 9) * 0.22; }, level, (j - 1) * 0.4, 0.45, duckAt); });
const rhodes = (notes, t0, len, level) => [...notes, notes[2] + (notes[1] - notes[0] === 4 ? 4 : 3)].forEach((m, j) => { const f = hz(m + 12);
  voice(t0 + j * 0.012, len + 1.2, (t) => { const env = Math.min(1, t / 0.01) * Math.exp(-t * 1.1) * (t > len ? Math.exp(-(t - len) * 4) : 1), trem = 1 + 0.18 * Math.sin(TAU * 4.5 * t);
    return (Math.sin(TAU * f * t + 0.6 * Math.exp(-t * 6) * Math.sin(TAU * f * t)) + 0.25 * Math.sin(TAU * 2 * f * t) * Math.exp(-t * 3)) * env * trem * 0.12; }, level, (j - 1.5) * 0.25, 0.4); });
const pianoNote = (m, t0, level, pan = 0, len = 2.5) => { const f = hz(m);
  voice(t0, len, (t) => { let s = 0; [[1, 1, 2.2], [2, 0.45, 3.2], [3, 0.22, 4.5], [4, 0.12, 6]].forEach(([h, a, d]) => { s += a * Math.sin(TAU * f * h * t * (1 + 0.0004 * h * h)) * Math.exp(-t * d); });
    return (s + (t < 0.004 ? noise() * 0.3 : 0)) * Math.min(1, t / 0.003) * Math.min(1, (len - t) / 0.2) * 0.18; }, level, pan, 0.35); };
const pianoChord = (notes, t0, len, level) => notes.forEach((m, j) => pianoNote(m + 12, t0 + j * 0.008, level * 0.8, (j - 1) * 0.3, len + 0.6));
const bass = (m, t0, len, level) => { const f = hz(m - 12), filt = lp(); let p = 0;
  voice(t0, len + 0.05, (t) => { p = (p + f / SR) % 1; const env = Math.min(1, t / 0.004) * (0.55 + 0.45 * Math.exp(-t * 9)) * (t > len ? Math.exp(-(t - len) * 60) : 1);
    return (Math.sin(TAU * p) * 0.8 + filt(2 * p - 1, 380) * 0.5) * env * 0.5; }, level, 0, 0); };
const kick = (t0, level) => { kicks.push(t0); let ph = 0; voice(t0, 0.5, (t) => { const f = 46 + 120 * Math.exp(-t * 32); ph += f / SR; return (Math.sin(TAU * ph) * Math.exp(-t * 6.5) + (t < 0.004 ? noise() * 0.4 : 0)) * 0.9; }, level, 0, 0); };
const snare = (t0, level) => { const hp = lp(), lo = lp(), gated = G.gated;
  voice(t0, gated ? 0.42 : 0.3, (t) => { const n = noise(), b = lo(n - hp(n, 900), 6500), env = gated ? (t < 0.32 ? Math.exp(-t * 4) : Math.exp(-(t - 0.32) * 80) * Math.exp(-0.32 * 4)) : Math.exp(-t * 20);
    return b * env * 0.7 + Math.sin(TAU * 185 * t) * Math.exp(-t * 32) * 0.45; }, level, 0.05, gated ? 0.9 : 0.35); };
const clap = (t0, level) => { const hp = lp(), lo = lp(); voice(t0, 0.35, (t) => { const n = noise(), b = lo(n - hp(n, 1100), 5000), e = [0, 0.011, 0.023].reduce((a, o) => a + (t >= o ? Math.exp(-(t - o) * (o === 0.023 ? 14 : 90)) : 0), 0); return b * e * 0.5; }, level, -0.05, 0.4); };
const hat = (t0, level, open, pan) => { const hp = lp(); voice(t0, open ? 0.32 : 0.07, (t) => { const n = noise(); return (n - hp(n, 7000)) * Math.exp(-t * (open ? 14 : 70)) * 0.35; }, level, pan, 0.05); };
const shaker = (t0, level, pan) => { const hp = lp(); voice(t0, 0.09, (t) => { const n = noise(); return (n - hp(n, 9000)) * Math.min(1, t / 0.012) * Math.exp(-t * 45) * 0.25; }, level, pan, 0.05); };
const tom = (t0, level, big = 1) => { let ph = 0; voice(t0, 0.9, (t) => { const f = (70 + 60 * Math.exp(-t * 14)) * (big > 1 ? 0.7 : 1); ph += f / SR; return Math.sin(TAU * ph) * Math.exp(-t * 4.5) * 0.85 + (t < 0.01 ? noise() * 0.3 : 0); }, level, 0, 0.45); };
const pluck = (m, t0, level, pan) => { const f = hz(m + 12), filt = lp();
  voice(t0, 0.9, (t) => filt(Math.sin(TAU * f * t) + 0.35 * Math.sin(2 * TAU * f * t) + 0.12 * Math.sin(3 * TAU * f * t), 900 + 5000 * Math.exp(-t * 14)) * Math.exp(-t * 7.5) * 0.22, level, pan, 0.45, duckAt); };
const marimba = (m, t0, level, pan) => { const f = hz(m + 12); voice(t0, 0.7, (t) => (Math.sin(TAU * f * t) + 0.35 * Math.sin(TAU * 3.99 * f * t) * Math.exp(-t * 30)) * Math.exp(-t * 9) * 0.25, level, pan, 0.3); };
const bell = (m, t0, level, pan) => { const f = hz(m + 24); voice(t0, 3, (t) => Math.sin(TAU * f * t + 2.2 * Math.exp(-t * 1.2) * Math.sin(TAU * 3.5 * f * t)) * Math.exp(-t * 1.6) * Math.min(1, t / 0.004) * 0.13, level, pan, 0.8); };
const saw = (m, t0, len, level, pan) => { const f = hz(m + 12), filt = lp(); let p = rnd(); voice(t0, len, (t) => { p = (p + f / SR) % 1; return filt(2 * p - 1, 700 + 3500 * Math.exp(-t * 12)) * Math.exp(-t * 4) * 0.16; }, level, pan, 0.4, duckAt); };
const riser = (t0, len, level) => { const filt = lp(); voice(t0, len, (t) => { const p = t / len; return filt(noise(), 300 + 7000 * p * p) * p * p * 0.5; }, level, 0, 0.4); };
const impact = (t0, level) => { const filt = lp(); voice(t0, 2.2, (t) => Math.sin(TAU * (52 + 30 * Math.exp(-t * 8)) * t) * Math.exp(-t * 2.6) * 0.8 + filt(noise(), 1800) * Math.exp(-t * 5) * 0.5, level, 0, 0.6); };
const crackle = (t0, len) => { const filt = lp(); let s = SEED * 13; const r = () => (s = (s * 1664525 + 1013904223) >>> 0) / 4294967296;
  voice(t0, len, (t) => filt(noise(), 3000) * 0.02 + (r() < 0.0009 ? (r() - 0.5) * 0.9 : 0), 1, 0, 0); };

// Chords and leads by genre.
function playChords(ch, t, len, level, ducked, section) {
  const c = G.chords; if (c === 'none') return;
  if (c === 'pad') pad(ch, t, len, level, CUT * (section === 'intro' ? 0.7 : 1), ducked);
  if (c === 'strings') strings(ch, t, len, level);
  if (c === 'rhodes') rhodes(ch, t, len, level);
  if (c === 'piano') pianoChord(ch, t, len, level);
  if (c === 'stab') { if (section === 'drop') hits(G.stab).forEach((s) => stab(ch, stepT(t, s), level * 0.9)); else pad(ch, t, len, level * 0.8, CUT * 0.8, false); }
}
function playLead(ch, t, density, level) { // density 0..1
  const l = G.lead, pan = (i) => (i % 2 ? 0.4 : -0.4);
  if (l === 'pluck16') for (let s = 0; s < 16; s++) { if (density < 1 && s % 2) continue; if (s % 4 === 3 && rnd() < 0.5) continue; pluck(ch[[0, 1, 2, 1][s % 4]] + 12 * (s >= 8 && s % 3 === 0 ? 1 : 0), stepT(t, s), level, pan(s)); }
  if (l === 'pluck8') for (let s = 0; s < 16; s += 2) { if (density < 1 && s % 4) continue; pluck(ch[[0, 2, 1, 2][(s / 2) % 4]] + (s % 8 === 6 ? 12 : 0), stepT(t, s), level, pan(s)); }
  if (l === 'arp16') for (let s = 0; s < 16; s++) { if (density < 1 && s % 2) continue; const seq = [0, 1, 2, 3, 2, 1]; saw(ch[seq[s % 6] % 3] + 12 * Math.floor(seq[s % 6] / 3) + 12, stepT(t, s), STEP * 1.6, level * 0.9, pan(s)); }
  if (l === 'marimba') { const pat = density < 1 ? [0, 6, 10] : [0, 3, 6, 8, 10, 13, 14]; pat.forEach((s, i) => marimba(ch[(i + (s > 8 ? 1 : 0)) % 3] + (i % 3 === 2 ? 12 : 0), stepT(t, s), level, pan(i))); }
  if (l === 'piano') { const pat = density < 1 ? [0, 8] : [0, 4, 6, 8, 12, 14]; pat.forEach((s, i) => pianoNote(ch[i % 3] + 24, stepT(t, s), level * 0.9, pan(i), 1.6)); }
  if (l === 'bell') { [0, 10].forEach((s, i) => { if (density < 1 && i) return; bell(ch[Math.floor(rnd() * 3)], stepT(t, s), level, pan(i)); }); }
  if (l === 'ostinato') for (let s = 0; s < 16; s += 2) pluck(ch[[0, 0, 2, 0, 1, 0, 2, 1][s / 2]] - 12, stepT(t, s), level * (density < 1 ? 0.6 : 1), 0);
}
function drums(t, density, D) { // density: 0 none, 0.5 build, 1 drop
  if (density <= 0) return;
  const k = hits(G.kick), sn = hits(G.snare), cl = hits(G.clap), hh = hits(G.hat), oh = hits(G.ohat), sh = hits(G.shaker), tm = hits(G.toms);
  for (const s of k) if (density >= 1 || s % 8 === 0) kick(stepT(t, s), 0.95 * D);
  for (const s of tm) if (density >= 1 || s === 0) tom(stepT(t, s), 0.9 * D, 2);
  if (density >= 1) { for (const s of sn) { snare(stepT(t, s), 0.7 * D); SNARES.push(+stepT(t, s).toFixed(3)); } for (const s of cl) clap(stepT(t, s), 0.75 * D); for (const s of oh) hat(stepT(t, s), 0.45 * D, true, 0.2); }
  for (const s of hh) if (density >= 1 || s % 4 === 0) hat(stepT(t, s), (s % 4 === 2 ? 0.5 : 0.32) * D * density, false, s % 4 === 2 ? 0.35 : -0.25);
  for (const s of sh) shaker(stepT(t, s), (s % 4 === 0 ? 0.5 : 0.3) * D * density, 0.3);
}
function bassline(ch, t, density) {
  const b = hits(G.bass); if (!b.length) return;
  b.forEach((s, i) => { if (density < 1 && s % 8) return; const len = G.staccato ? STEP * 0.8 : (b[i + 1] ?? 16) * STEP - s * STEP - 0.02; bass(G.bassOct && i % 2 ? ch[0] + 12 : ch[0], stepT(t, s), Math.max(STEP * 0.8, len), 0.8 * SOFT); });
}

// ---- Arrange ----
const beats = [], downbeats = [], sec = [], HITS = [], SNARES = [];
let bar = 0;
if (G.crackle) crackle(0, DUR + TAIL);
for (const s of sections) {
  const start = bar * BAR; sec.push({ type: s.type, start: +start.toFixed(3), end: +((bar + s.bars) * BAR).toFixed(3) });
  if ((s.type === 'drop' || s.type === 'outro') && G.impact) { HITS.push(+start.toFixed(3)); impact(start, (s.type === 'drop' ? 0.9 : 0.7) * G.impact); }
  else if (s.type === 'drop' || s.type === 'outro') HITS.push(+start.toFixed(3));
  if (s.type === 'build' && G.riser) riser(start, s.bars * BAR, 0.55);
  for (let b = 0; b < s.bars; b++, bar++) {
    const t = bar * BAR, ch = chord(M.prog[bar % M.prog.length]), D = SOFT;
    downbeats.push(+t.toFixed(3)); for (let q = 0; q < 4; q++) beats.push(+(t + q * BEAT).toFixed(3));
    if (s.type === 'intro') { playChords(ch, t, BAR, 0.8, false, 'intro'); if (b > 0 || s.bars === 1) playLead(ch, t, 0.5, 0.45); if (G.swing > 0.52) drums(t, 0.5, D * 0.6); }
    else if (s.type === 'build') { drums(t, 0.5, D * 0.8); playChords(ch, t, BAR, 0.85, false, 'build'); bassline(ch, t, 0.5); playLead(ch, t, 0.5, 0.45);
      if (b === s.bars - 1 && G.riser) for (let r = 0; r < 4; r++) { const tt = t + 3 * BEAT + (r * BEAT) / 4; (G.toms ? tom : snare)(tt, (0.3 + r * 0.15) * D); SNARES.push(+tt.toFixed(3)); } }
    else if (s.type === 'drop') { drums(t, 1, D); playChords(ch, t, BAR, 0.75, true, 'drop'); bassline(ch, t, 1); playLead(ch, t, 1, 0.5); }
    else if (s.type === 'break') { playChords(ch, t, BAR, 0.9, false, 'break'); playLead(ch, t, 0.5, 0.5); }
    else if (s.type === 'outro' && b === 0) { const c0 = chord(0); playChords(c0, t, s.bars * BAR, 0.9, false, 'outro'); bass(c0[0], t, s.bars * BAR * 0.6, 0.7); if (G.kick) kick(t, 0.9 * D); if (G.toms) tom(t, 0.9, 2);
      [0, 2, 4, 7].forEach((x, i) => (G.lead === 'marimba' ? marimba : G.lead === 'piano' || G.chords === 'piano' ? (m, tt, l, p) => pianoNote(m + 24, tt, l, p) : G.lead === 'bell' ? bell : pluck)(deg(x) + 12, t + i * BEAT / 2, 0.55, i % 2 ? 0.4 : -0.4)); }
  }
}

// ---- Reverb (Schroeder: 4 combs + 2 allpasses per channel) ----
function reverb(input, offset) {
  const out = new Float32Array(N), size = G.chords === 'strings' || G.lead === 'bell' ? 1.6 : 1;
  const combs = [1557, 1617, 1491, 1422].map((d) => ({ buf: new Float32Array(Math.round((d * size + offset) * SR / 44100)), i: 0, f: 0 }));
  const aps = [556, 225].map((d) => ({ buf: new Float32Array(Math.round((d + offset) * SR / 44100)), i: 0 }));
  const fb = size > 1 ? 0.86 : 0.82;
  for (let n = 0; n < N; n++) {
    let s = 0;
    for (const c of combs) { const y = c.buf[c.i]; c.f = y * 0.7 + c.f * 0.3; c.buf[c.i] = input[n] + c.f * fb; c.i = (c.i + 1) % c.buf.length; s += y; }
    s *= 0.25;
    for (const a of aps) { const b = a.buf[a.i]; const y = -s + b; a.buf[a.i] = s + b * 0.5; a.i = (a.i + 1) % a.buf.length; s = y; }
    out[n] = s;
  }
  return out;
}
const wl = reverb(SEND, 0), wr = reverb(SEND, 23);

// ---- Master: dry + wet, optional lo-fi tone, soft clip, peak normalize ----
let peak = 0; const tone = G.crackle ? [lp(), lp()] : null;
for (let n = 0; n < N; n++) {
  let l = L[n] + wl[n] * 0.35, r = R[n] + wr[n] * 0.35;
  if (tone) { l = tone[0](l, 5200); r = tone[1](r, 5200); }
  L[n] = Math.tanh(l * 1.1); R[n] = Math.tanh(r * 1.1); peak = Math.max(peak, Math.abs(L[n]), Math.abs(R[n]));
}
const norm = peak > 0 ? 0.89 / peak : 1, fadeN = Math.floor(0.3 * SR);
const data = Buffer.alloc(44 + N * 4);
data.write('RIFF', 0); data.writeUInt32LE(36 + N * 4, 4); data.write('WAVEfmt ', 8); data.writeUInt32LE(16, 16);
data.writeUInt16LE(1, 20); data.writeUInt16LE(2, 22); data.writeUInt32LE(SR, 24); data.writeUInt32LE(SR * 4, 28);
data.writeUInt16LE(4, 32); data.writeUInt16LE(16, 34); data.write('data', 36); data.writeUInt32LE(N * 4, 40);
for (let n = 0; n < N; n++) {
  const f = n > N - fadeN ? (N - n) / fadeN : 1;
  data.writeInt16LE(Math.round(Math.max(-1, Math.min(1, L[n] * norm * f)) * 32767), 44 + n * 4);
  data.writeInt16LE(Math.round(Math.max(-1, Math.min(1, R[n] * norm * f)) * 32767), 46 + n * 4);
}
mkdirSync(path.dirname(OUT), { recursive: true }); mkdirSync(path.dirname(BEATS), { recursive: true });
writeFileSync(OUT, data);
writeFileSync(BEATS, JSON.stringify({ bpm: BPM, genre: GN, mood: MOOD, key: KEY, dur: +DUR.toFixed(3), tail: TAIL, beats, downbeats, sections: sec, hits: HITS, snares: SNARES }, null, 1));
console.log(`${path.resolve(OUT)}  ${GN}/${MOOD} ${BPM} BPM in ${KEY}, ${totalBars} bars = ${DUR.toFixed(2)}s (+${TAIL}s tail)\n${path.resolve(BEATS)}  sections: ${sec.map((s) => `${s.type}@${s.start}`).join(' ')}`);
