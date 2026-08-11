// Like capture_flutter_web.mjs, but the interaction point is given explicitly.
//
// capture_flutter_web.mjs drives the pointer to the component's centre, which is
// right for a single control and wrong for anything whose target is off-centre:
// a shrink-wrapped tab inside a wider bar, one link in a full-width header row.
// Aiming at the wrong pixel makes a working hover look broken, so the target is
// a parameter here.
//
// Usage:
//   node capture_flutter_point.mjs <key> <state> --at 0.1,0.5 [--out DIR]
//
// `--at` is a fraction of the component's own measured box.
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const BASE = process.env.PARITY_WEB_BASE ?? 'http://localhost:8777';
const ROOT = path.resolve(__dirname, '..');

const args = process.argv.slice(2);
const flag = (name, fallback) => {
  const i = args.indexOf(`--${name}`);
  return i === -1 ? fallback : args[i + 1];
};
const positional = args.filter((a, i) => !a.startsWith('--') && !args[i - 1]?.startsWith('--'));

const key = positional[0];
const state = positional[1] ?? 'default';
const [fx, fy] = (flag('at', '0.5,0.5')).split(',').map(Number);
const outDir = path.resolve(ROOT, flag('out', 'flutter_web_states'));
const viewportWidth = Number(flag('width', 1280));

mkdirSync(outDir, { recursive: true });

const browser = await chromium.launch();
const context = await browser.newContext({ deviceScaleFactor: 2 });
const page = await context.newPage();
await page.setViewportSize({ width: viewportWidth, height: 800 });

await page.goto(`${BASE}/?key=${encodeURIComponent(key)}`, {
  waitUntil: 'load',
  timeout: 60000,
});
await page.waitForFunction('window.parityReady === true', { timeout: 60000 });
const err = await page.evaluate('window.parityError ?? null');
if (err) throw new Error(err);

const size = () => page.evaluate(() => ({ w: window.parityWidth, h: window.parityHeight }));
let { w, h } = await size();
if (!w || !h) throw new Error('component reported no size');

if (state !== 'default') {
  const cx = w * fx;
  const cy = h * fy;
  if (state === 'hover') {
    await page.mouse.move(cx, cy);
  } else if (state === 'active') {
    await page.mouse.move(cx, cy);
    await page.mouse.down();
  } else if (state === 'focus') {
    await page.keyboard.press('Tab');
  }
  await page.waitForTimeout(350);
  ({ w, h } = await size());
}

const suffix = state === 'default' ? '' : `__${state}`;
await page.screenshot({
  path: path.join(outDir, `${key}${suffix}.png`),
  clip: { x: 0, y: 0, width: Math.max(1, Math.round(w)), height: Math.max(1, Math.round(h)) },
});
console.log(`OK   ${key}${suffix}  ${Math.round(w)}x${Math.round(h)}  at ${fx},${fy}`);

if (state === 'active') await page.mouse.up().catch(() => {});
await browser.close();
