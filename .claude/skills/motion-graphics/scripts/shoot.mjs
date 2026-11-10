#!/usr/bin/env node
// shoot.mjs: capture real product UI as crisp PNGs for a film (run from the project root).
//
//   node shoot.mjs shots.json            # [{ "name": "dashboard", "url": "...", "w": 1440, "h": 900, "selector": "#storybook-root", "wait": 1500 }]
//   node shoot.mjs --storybook http://127.0.0.1:6006 app-dashboard--populated chat=app-chat-page--completed
//
// Defaults: 1440x900 viewport, deviceScaleFactor 2, waits for network idle + 1200 ms (play functions, fonts),
// clips to `selector` when given (Storybook: #storybook-root), light color scheme, reduced motion.
// Output: assets/shots/<name>.png. Prefer Storybook or seeded mock data: never capture personal data.

import { createRequire } from 'node:module';
import { readFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';

const argv = process.argv.slice(2);
const opt = (k, d) => { const i = argv.indexOf('--' + k); if (i < 0) return d; const v = argv[i + 1]; argv.splice(i, 2); return v; };
const OUT = opt('out', 'assets/shots'), DPR = Number(opt('dpr', 2)), SCHEME = opt('scheme', 'light');
const SB = opt('storybook');
const W = Number(opt('w', 1440)), H = Number(opt('h', 900)), WAIT = Number(opt('wait', 1200));
let jobs;
if (SB) jobs = argv.map((a) => { const [name, id] = a.includes('=') ? a.split('=') : [a.split('--').pop(), a];
  return { name, url: `${SB.replace(/\/$/, '')}/iframe.html?id=${id}&viewMode=story`, selector: '#storybook-root' }; });
else jobs = JSON.parse(readFileSync(argv[0], 'utf8'));

const { chromium } = createRequire(path.join(process.cwd(), 'package.json'))('playwright');
const browser = await chromium.launch();
mkdirSync(OUT, { recursive: true });
for (const j of jobs) {
  const page = await browser.newPage({ viewport: { width: j.w || W, height: j.h || H }, deviceScaleFactor: j.dpr || DPR, colorScheme: j.scheme || SCHEME, reducedMotion: 'reduce' });
  await page.goto(j.url, { waitUntil: 'networkidle' }).catch(() => page.goto(j.url));
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(j.wait ?? WAIT);
  const file = path.join(OUT, `${j.name}.png`);
  const target = j.selector ? page.locator(j.selector).first() : page;
  await target.screenshot({ path: file, ...(j.selector ? {} : { fullPage: !!j.full }), animations: 'disabled' });
  const box = j.selector ? await target.boundingBox() : { width: j.w || W, height: j.h || H };
  console.log(`${path.resolve(file)}  ${Math.round(box.width * (j.dpr || DPR))}x${Math.round(box.height * (j.dpr || DPR))}`);
  await page.close();
}
await browser.close();
