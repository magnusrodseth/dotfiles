#!/usr/bin/env node
// voice.mjs: OPT-IN voiceover via ElevenLabs, with word timings so picture can sync to speech.
//
//   node voice.mjs --lang no --text "Se opp i kveld. Melkeveien venter." [--voice <id>] [--out audio/voice.mp3]
//   node voice.mjs --lang en --script docs/voice.json      # [{ "id": "hook", "text": "..." }, ...] stitched in order
//   node voice.mjs --list-voices
//
// Needs ELEVENLABS_API_KEY in the environment or in ./.env. Never paste the key into a prompt.
// Model: eleven_v3 (default; Norwegian and English, most expressive). eleven_flash_v2_5 is the fast fallback.
// eleven_multilingual_v2 has NO Norwegian: this script refuses --lang no with it.
// Writes the mp3 plus <out>.words.json: [{ word, start, end }] in seconds, for captions and cut timing.

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';

const argv = process.argv.slice(2);
const has = (k) => argv.includes('--' + k);
const arg = (k, d) => { const i = argv.indexOf('--' + k); return i >= 0 ? argv[i + 1] : d; };

let KEY = process.env.ELEVENLABS_API_KEY;
if (!KEY && existsSync('.env')) KEY = (readFileSync('.env', 'utf8').match(/^(?:export\s+)?ELEVENLABS_API_KEY=(.+)$/m) || [])[1]?.trim().replace(/^(['"])(.*)\1$/, '$2');
if (!KEY) { console.error('ELEVENLABS_API_KEY is not set (env or ./.env). Voiceover is opt-in; skip it or set the key.'); process.exit(1); }
const API = 'https://api.elevenlabs.io/v1';
const H = { 'xi-api-key': KEY, 'content-type': 'application/json' };

if (has('list-voices')) {
  const r = await fetch(`${API}/voices`, { headers: H });
  if (!r.ok) { console.error(r.status, await r.text()); process.exit(1); }
  for (const v of (await r.json()).voices) console.log(`${v.voice_id}  ${v.name}  ${v.labels ? Object.values(v.labels).join(', ') : ''}`);
  process.exit(0);
}

const LANG = arg('lang', 'en');
const MODEL = arg('model', 'eleven_v3');
if (MODEL.startsWith('eleven_multilingual_v2') && LANG === 'no') { console.error('eleven_multilingual_v2 does not support Norwegian. Use eleven_v3 or eleven_flash_v2_5.'); process.exit(1); }
const VOICE = arg('voice', process.env.ELEVENLABS_VOICE_ID || 'JBFqnCBsd6RMkjVDRZzb'); // default: "George", a premade multilingual voice
const OUT = arg('out', 'audio/voice.mp3');
if (!OUT.endsWith('.mp3')) { console.error('--out must end in .mp3 (the word timings go next to it as .words.json)'); process.exit(1); }
const parts = arg('script') ? JSON.parse(readFileSync(arg('script'), 'utf8')) : [{ id: 'vo', text: arg('text') }];
if (!parts.every((p) => p.text)) { console.error('need --text or --script with text on every part'); process.exit(1); }

const stability = Number(arg('stability', MODEL === 'eleven_v3' ? 0.5 : 0.45));
const files = [], words = [];
let offset = 0;
mkdirSync(path.dirname(OUT), { recursive: true });
for (let i = 0; i < parts.length; i++) {
  const p = parts[i];
  const body = { text: p.text, model_id: MODEL, voice_settings: { stability, similarity_boost: 0.8, style: Number(arg('style', 0.3)), use_speaker_boost: true } };
  if (!MODEL.startsWith('eleven_multilingual_v2')) body.language_code = LANG;
  if (MODEL !== 'eleven_v3') { // request stitching for prosody continuity across parts
    if (i > 0) body.previous_text = parts[i - 1].text;
    if (i < parts.length - 1) body.next_text = parts[i + 1].text;
  }
  if (arg('seed')) body.seed = Number(arg('seed'));
  const r = await fetch(`${API}/text-to-speech/${VOICE}/with-timestamps?output_format=mp3_44100_192`, { method: 'POST', headers: H, body: JSON.stringify(body) });
  if (!r.ok) { console.error(`ElevenLabs ${r.status}: ${await r.text()}`); process.exit(1); }
  const j = await r.json();
  const f = parts.length > 1 ? OUT.replace(/\.mp3$/, `-${p.id}.mp3`) : OUT;
  writeFileSync(f, Buffer.from(j.audio_base64, 'base64')); files.push(f);
  const a = j.alignment || j.normalized_alignment;
  let cur = null;
  a.characters.forEach((ch, k) => {
    if (/\s/.test(ch)) { if (cur) { words.push(cur); cur = null; } return; }
    if (!cur) cur = { part: p.id, word: '', start: +(offset + a.character_start_times_seconds[k]).toFixed(3) };
    cur.word += ch; cur.end = +(offset + a.character_end_times_seconds[k]).toFixed(3);
  });
  if (cur) words.push(cur);
  const d = Number(spawnSync('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', f]).stdout.toString());
  offset += d + Number(arg('gap', 0.25));
}

if (files.length > 1) { // concatenate parts with a short gap
  const gap = Number(arg('gap', 0.25));
  const inputs = files.flatMap((f) => ['-i', f]);
  const chain = files.map((_, k) => `[${k}:a]apad=pad_dur=${gap}[p${k}]`).join(';') + ';' + files.map((_, k) => `[p${k}]`).join('') + `concat=n=${files.length}:v=0:a=1[a]`;
  const r = spawnSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', ...inputs, '-filter_complex', chain, '-map', '[a]', '-b:a', '192k', OUT]);
  if (r.status) { console.error(String(r.stderr)); process.exit(1); }
}
writeFileSync(OUT.replace(/\.mp3$/, '.words.json'), JSON.stringify(words, null, 1));
console.log(`${path.resolve(OUT)}  ${MODEL} lang=${LANG} voice=${VOICE}  ${words.length} words, ${offset.toFixed(2)}s`);
