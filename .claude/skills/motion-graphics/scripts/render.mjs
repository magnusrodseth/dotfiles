#!/usr/bin/env node
// render.mjs: render a seek(t) page to MP4, or to stills and a labelled contact sheet.
// Deterministic: sample i paints t = i / (fps * sub). Run from the project root.
//
//   node render.mjs                                   # out/silent.mp4 at the page's W x H
//   node render.mjs --w 1080 --h 1920 --out out/silent-9x16.mp4
//   node render.mjs --fps 30 --sub 1 --scale 0.5      # fast animatic
//   node render.mjs --stills 0,0.5,2.25               # out/stills/*.png
//   node render.mjs --contact [--every 0.5]           # one still per beat (or every N s) -> out/contact.png
//
// Flags: --page index.html  --w --h  --fps 60  --sub 2 (subframes blended for motion blur)
//        --dur (default window.DUR)  --from 0  --to dur  --out  --outdir out/stills  --scale 1

import http from 'node:http';
import { createReadStream, existsSync, mkdirSync, readFileSync, writeFileSync, rmSync, statSync } from 'node:fs';
import { spawn, spawnSync } from 'node:child_process';
import { createRequire } from 'node:module';
import path from 'node:path';

const argv = process.argv.slice(2);
const has = (k) => argv.includes('--' + k);
const arg = (k, d) => { const i = argv.indexOf('--' + k); return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : d; };
const num = (k, d) => (arg(k) === undefined ? d : Number(arg(k)));

const ROOT = process.cwd();
const PAGE = arg('page', 'index.html');
const FPS = num('fps', 60), SUB = Math.max(1, num('sub', 2)), SCALE = num('scale', 1);


// Static server, so ES modules, fonts and images load (file:// blocks module imports).
const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.css': 'text/css', '.json': 'application/json',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.svg': 'image/svg+xml', '.gif': 'image/gif',
  '.ttf': 'font/ttf', '.otf': 'font/otf', '.woff': 'font/woff', '.woff2': 'font/woff2', '.wav': 'audio/wav', '.mp3': 'audio/mpeg', '.mp4': 'video/mp4' };
// Only files inside the project, never dotfiles (.env holds API keys), only for a localhost Host header.
const server = http.createServer((req, res) => {
  const no = (code) => { res.writeHead(code); res.end(); };
  if (!/^(127\.0\.0\.1|localhost)(:\d+)?$/.test(req.headers.host || '')) return no(403);
  let rel;
  try { rel = decodeURIComponent(new URL(req.url, 'http://x').pathname); } catch { return no(400); }
  const p = path.resolve(ROOT, '.' + rel), r = path.relative(ROOT, p);
  if (r.startsWith('..') || path.isAbsolute(r) || r.split(path.sep).some((seg) => seg.startsWith('.'))) return no(404);
  if (!existsSync(p) || statSync(p).isDirectory()) return no(404);
  res.writeHead(200, { 'content-type': MIME[path.extname(p).toLowerCase()] || 'application/octet-stream' });
  createReadStream(p).pipe(res);
});
await new Promise((r) => server.listen(has('serve') ? num('port', 4321) : 0, '127.0.0.1', r));
const port = server.address().port;
if (has('serve')) { // live preview server; runs until killed. Start it in the background.
  console.log(`preview: http://127.0.0.1:${port}/${PAGE}   (space pause, arrows scrub, click play with out/preview.wav)`);
  await new Promise(() => {});
}

let playwright;
try { playwright = createRequire(path.join(ROOT, 'package.json'))('playwright'); }
catch { console.error('playwright not found in this project. Run: npm i -D playwright && npx playwright install chromium'); process.exit(1); }

// GPU flags: WebGL scenes render on the GPU (ANGLE/Metal on macOS) instead of SwiftShader.
const browser = await playwright.chromium.launch({ args: ['--font-render-hinting=none', '--disable-lcd-text', '--force-color-profile=srgb', '--ignore-gpu-blocklist', '--enable-gpu-rasterization', ...(process.platform === 'darwin' ? ['--use-angle=metal'] : [])] });
const qs = new URLSearchParams({ render: '1' });
if (arg('w')) qs.set('w', arg('w'));
if (arg('h')) qs.set('h', arg('h'));
const probe = await browser.newPage();
const probeErrors = [];
probe.on('pageerror', (e) => probeErrors.push(e.message));
probe.on('console', (m) => { if (m.type() === 'error') probeErrors.push(m.text()); });
const URLP = `http://127.0.0.1:${port}/${PAGE}${PAGE.includes('?') ? '&' : '?'}${qs}`;
await probe.goto(URLP);
await probe.waitForFunction(() => typeof window.seek === 'function', null, { timeout: 15000 }).catch(() => { console.error('window.seek never appeared. Page errors:\n' + (probeErrors.join('\n') || '(none: check the module imports)')); process.exit(2); });
const meta = await probe.evaluate(async () => { await (window.ready ?? Promise.resolve()); await document.fonts.ready;
  const c = document.querySelector('canvas'); return { W: c.width, H: c.height, DUR: window.DUR }; });
await probe.close();

const W = meta.W, H = meta.H;
const OW = Math.round(W * SCALE / 2) * 2, OH = Math.round(H * SCALE / 2) * 2; // x264 needs even sizes
const DUR = num('dur', meta.DUR);
if (!DUR) { console.error('No duration: set window.DUR in the page or pass --dur'); process.exit(1); }
const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
const pageErrors = [];
page.on('pageerror', (e) => pageErrors.push(e.message));
page.on('console', (m) => { if (m.type() === 'error' && !/Failed to load resource/.test(m.text())) pageErrors.push(m.text()); }); // missing optional files (beats.json before the score exists) are not errors
page.on('requestfailed', () => {});
await page.goto(URLP);
await page.waitForFunction(() => typeof window.seek === 'function');
await page.evaluate(async () => { await (window.ready ?? Promise.resolve()); await document.fonts.ready; });

async function frame(t) {
  const b64 = await page.evaluate((t) => { window.seek(t); return document.querySelector('canvas').toDataURL('image/png').slice(22); }, t);
  return Buffer.from(b64, 'base64');
}

const fmt = (t) => t.toFixed(2).padStart(6, '0');
async function stills(times, outdir) {
  mkdirSync(outdir, { recursive: true });
  const files = [];
  for (const t of times) { const f = path.join(outdir, `t${fmt(t)}.png`); writeFileSync(f, await frame(t)); files.push(f); }
  return files;
}

function ff(args, input) {
  const r = spawnSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', ...args], { input, maxBuffer: 1 << 30 });
  if (r.status !== 0) { console.error(String(r.stderr)); process.exit(1); }
}

if (has('stills')) {
  const times = arg('stills').split(',').map(Number);
  const files = await stills(times, arg('outdir', 'out/stills'));
  files.forEach((f) => console.log(path.resolve(f)));
} else if (has('contact')) {
  const every = num('every', 0);
  let times;
  if (!every && existsSync('audio/beats.json')) {
    const bj = JSON.parse(readFileSync('audio/beats.json', 'utf8'));
    times = bj.beats.filter((b) => b < DUR).map((b) => Math.min(DUR - 0.001, b + 0.25)); // a beat after the hit, when motion has landed
  } else {
    const step = every || 0.5; times = [];
    for (let t = step / 2; t < DUR; t += step) times.push(t);
  }
  const dir = 'out/contact-stills';
  rmSync(dir, { recursive: true, force: true });
  const files = await stills(times, dir);
  const cols = W > H ? 6 : 8, rows = Math.ceil(files.length / cols), tw = W > H ? 480 : 270;
  const font = '/System/Library/Fonts/Supplemental/Arial Bold.ttf';
  const hasDrawtext = String(spawnSync('ffmpeg', ['-hide_banner', '-filters']).stdout).includes(' drawtext ');
  const label = existsSync(font) && hasDrawtext ? `,drawtext=fontfile='${font}':text='%{metadata\\:t}':x=8:y=8:fontsize=${Math.round(tw / 14)}:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=4` : '';
  // Label each tile with its timestamp, then tile.
  const labelled = files.map((f, i) => {
    const o = f.replace('.png', '-l.png');
    const vf = `scale=${tw}:-2` + (label ? label.replace('%{metadata\\:t}', `${times[i].toFixed(2)}s`) : '');
    ff(['-i', f, '-vf', vf, o]); return o;
  });
  writeFileSync(path.join(dir, 'list.txt'), labelled.map((f) => `file '${path.resolve(f)}'`).join('\n'));
  ff(['-f', 'concat', '-safe', '0', '-i', path.join(dir, 'list.txt'), '-vf', `tile=${cols}x${rows}:padding=4:color=0x222222`, '-frames:v', '1', 'out/contact.png']);
  console.log(path.resolve('out/contact.png'), `(${files.length} stills, ${times.length && times[0].toFixed(2)}s..${times.at(-1).toFixed(2)}s)`);
} else {
  const out = arg('out', 'out/silent.mp4');
  mkdirSync(path.dirname(out), { recursive: true });
  const from = num('from', 0), to = num('to', DUR);
  const vf = [SUB > 1 ? `tmix=frames=${SUB},select='eq(mod(n\\,${SUB})\\,${SUB - 1})',setpts=N/${FPS}/TB` : null,
    OW !== W || OH !== H ? `scale=${OW}:${OH}:flags=lanczos` : null].filter(Boolean).join(',') || 'null';
  const enc = spawn('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y', '-f', 'image2pipe', '-c:v', 'png', '-framerate', String(FPS * SUB), '-i', '-',
    '-vf', vf, '-r', String(FPS), '-c:v', 'libx264', '-preset', 'slow', '-crf', '16', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', out],
    { stdio: ['pipe', 'inherit', 'inherit'] });
  let encDied = false; enc.stdin.on('error', () => { encDied = true; }); enc.on('close', () => { encDied = true; });
  const total = Math.round((to - from) * FPS * SUB);
  const t0 = Date.now();
  for (let i = 0; i < total; i++) {
    if (encDied) break;
    const png = await frame(from + i / (FPS * SUB));
    if (!enc.stdin.write(png)) await new Promise((r) => enc.stdin.once('drain', r));
    if (i % (FPS * SUB) === 0) process.stdout.write(`\rrendered ${(i / (FPS * SUB)).toFixed(0)}s / ${(to - from).toFixed(1)}s`);
  }
  enc.stdin.end();
  const code = enc.exitCode ?? await new Promise((r) => enc.on('close', r));
  console.log(`\r${path.resolve(out)}  ${OW}x${OH} ${FPS}fps sub=${SUB}  ${(to - from).toFixed(2)}s in ${((Date.now() - t0) / 1000).toFixed(0)}s${code ? '  FFMPEG FAILED' : ''}`);
  if (code) process.exitCode = 1;
}

if (pageErrors.length) console.error('PAGE ERRORS:\n' + [...new Set(pageErrors)].join('\n'));
await browser.close();
server.close();
if (pageErrors.length) process.exit(2);
if (process.exitCode) process.exit(process.exitCode);
