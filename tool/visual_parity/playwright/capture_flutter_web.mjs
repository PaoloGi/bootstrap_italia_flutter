// Captures the Flutter side from a real browser, so both sides of the
// comparison are driven by the same tool with the same event model.
//
// Prereqs (see tool/visual_parity/README.md):
//   cd example && flutter build web -t lib/parity_harness.dart --no-tree-shake-icons
//   (cd example/build/web && python3 -m http.server 8777)
//
// Usage:
//   node capture_flutter_web.mjs [key] [state] [--width N] [--out DIR]
//
// `state` is one of default|hover|focus|active. Flutter web paints to a canvas,
// so states are applied by driving real input at the component's centre rather
// than by toggling a CSS class — which is the point: it exercises the same code
// path a user would.
import { chromium } from 'playwright';
import { mkdirSync, readFileSync, readdirSync } from 'node:fs';
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

const onlyKey = positional[0];
const state = positional[1] ?? 'default';
const viewportWidth = Number(flag('width', 1280));
const outDir = path.resolve(ROOT, flag('out', 'flutter_web_captures'));

const stateConfigPath = path.join(__dirname, 'states.json');
const stateConfig = JSON.parse(readFileSync(stateConfigPath, 'utf-8'));
const keys = onlyKey ? [onlyKey] : Object.keys(stateConfig);

mkdirSync(outDir, { recursive: true });

const browser = await chromium.launch();
const context = await browser.newContext({ deviceScaleFactor: 2 });
const failures = [];

for (const key of keys) {
  const page = await context.newPage();
  await page.setViewportSize({ width: viewportWidth, height: 800 });
  try {
    await page.goto(`${BASE}/?key=${encodeURIComponent(key)}`, {
      waitUntil: 'load',
      timeout: 60000,
    });
    await page.waitForFunction('window.parityReady === true', { timeout: 60000 });

    const err = await page.evaluate('window.parityError ?? null');
    if (err) throw new Error(err);

    const size = () =>
      page.evaluate(() => ({ w: window.parityWidth, h: window.parityHeight }));

    let { w, h } = await size();
    if (!w || !h) throw new Error('component reported no size');

    // Apply the interaction state by driving real input at the component.
    if (state !== 'default') {
      const cx = w / 2;
      const cy = h / 2;
      if (state === 'hover') {
        await page.mouse.move(cx, cy);
      } else if (state === 'active') {
        await page.mouse.move(cx, cy);
        await page.mouse.down();
      } else if (state === 'focus') {
        // Tab rather than click: clicking a Flutter widget can leave it in a
        // pressed/hover state too, which would conflate three states into one.
        await page.keyboard.press('Tab');
      }
      await page.waitForTimeout(350); // let state transitions settle
      ({ w, h } = await size()); // state may resize (floating label, expansion)
    }

    const suffix = state === 'default' ? '' : `__${state}`;
    await page.screenshot({
      path: path.join(outDir, `${key}${suffix}.png`),
      clip: { x: 0, y: 0, width: Math.max(1, Math.round(w)), height: Math.max(1, Math.round(h)) },
    });
    console.log(`OK   ${key}${suffix}  ${Math.round(w)}x${Math.round(h)}`);
  } catch (e) {
    failures.push(`${key}: ${e.message}`);
    console.error(`FAIL ${key}: ${e.message}`);
  } finally {
    if (state === 'active') await page.mouse.up().catch(() => {});
    await page.close();
  }
}

await browser.close();
if (failures.length) process.exit(1);
