// capture.js — capture one inspiration site as a full-page screenshot.
//
// Run via playwriter's -f after setting inputs on `state`:
//   playwriter -s <SID> -e 'state.captureUrl="https://example.com/"; state.outPath="/abs/out.png"'
//   playwriter -s <SID> -f ~/.claude/skills/capture-inspo/scripts/capture.js
//
// Inputs (on state):
//   state.captureUrl     (required) URL of the live site to capture
//   state.outPath        (required) ABSOLUTE path for the PNG (Playwright writes via real fs)
//   state.viewportWidth  (optional) default 1440
//
// Output: logs JSON { url, outPath, mode } where mode is "fullPage" or "viewport".
// Handles: viewport pin, cookie/consent dismissal, lazy-load scroll, WebGL fullPage fallback.

const url = state.captureUrl;
const outPath = state.outPath;
const width = state.viewportWidth || 1440;
if (!url || !outPath) throw new Error('Set state.captureUrl and state.outPath before running capture.js');

if (!state.page || state.page.isClosed()) {
  state.page = context.pages().find((p) => p.url() === 'about:blank') ?? (await context.newPage());
}

await state.page.setViewportSize({ width, height: 900 });
await state.page.goto(url, { waitUntil: 'domcontentloaded' });
await waitForPageLoad({ page: state.page, timeout: 8000 });

// Dismiss common cookie / consent overlays so they don't poison the screenshot.
for (const re of [/accept all/i, /accept cookies/i, /accept/i, /agree/i, /allow all/i, /got it/i]) {
  try {
    const btn = state.page.getByRole('button', { name: re }).first();
    if (await btn.isVisible({ timeout: 400 }).catch(() => false)) {
      await btn.click({ timeout: 1500 }).catch(() => {});
      break;
    }
  } catch {}
}

// Scroll to the bottom to trigger lazy-loaded sections, then return to the top.
await state.page.evaluate(async () => {
  await new Promise((resolve) => {
    let y = 0;
    const step = () => {
      window.scrollBy(0, window.innerHeight);
      y += window.innerHeight;
      // Cap at ~40k px so pathological infinite-scroll pages still terminate.
      if (y < document.body.scrollHeight && y < 40000) setTimeout(step, 200);
      else {
        window.scrollTo(0, 0);
        resolve();
      }
    };
    step();
  });
});
await state.page.waitForTimeout(1000);

// Try full-page; WebGL/canvas-heavy or extremely tall pages can fail → fall back to viewport.
let mode = 'fullPage';
try {
  await state.page.screenshot({ path: outPath, fullPage: true, scale: 'css' });
} catch (e) {
  mode = 'viewport';
  await state.page.screenshot({ path: outPath, scale: 'css' });
}

console.log(JSON.stringify({ url, outPath, mode }));
