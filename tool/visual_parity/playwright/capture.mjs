import { chromium } from 'playwright';
import { readFileSync, readdirSync, mkdirSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const STORYBOOK_BASE = 'https://italia.github.io/design-react-kit';
const OUT_DIR = path.resolve(__dirname, '..', 'reference');
const CONFIG_DIR = path.resolve(__dirname, 'components');

// Usage:
//   node capture.mjs              -> capture every group
//   node capture.mjs core         -> capture only components/core.json
//   node capture.mjs core button_primary -> capture a single key in that group
const groupArg = process.argv[2];
const keyArg = process.argv[3];

const groupFiles = readdirSync(CONFIG_DIR)
  .filter((f) => f.endsWith('.json'))
  .filter((f) => !groupArg || f === `${groupArg}.json`);

if (groupFiles.length === 0) {
  console.error(`No config found for group "${groupArg}" in ${CONFIG_DIR}`);
  process.exit(2);
}

const components = {};
for (const file of groupFiles) {
  const group = JSON.parse(readFileSync(path.join(CONFIG_DIR, file), 'utf-8'));
  Object.assign(components, group);
}

mkdirSync(OUT_DIR, { recursive: true });

const browser = await chromium.launch();
const context = await browser.newContext({ deviceScaleFactor: 2 });

const failures = [];

for (const [key, cfg] of Object.entries(components)) {
  if (keyArg && key !== keyArg) continue;

  const page = await context.newPage();
  await page.setViewportSize({ width: cfg.width ?? 900, height: cfg.height ?? 700 });

  const argsParam = cfg.args
    ? `&args=${Object.entries(cfg.args).map(([k, v]) => `${k}:${v}`).join(';')}`
    : '';
  const url = `${STORYBOOK_BASE}/iframe.html?id=${cfg.storyId}&viewMode=story${argsParam}`;

  try {
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    const root = page.locator('#storybook-root');
    // A component that is hidden until focused makes the story root itself
    // invisible, so waiting for it times out. `pressKeys` is applied first for
    // exactly that case: Skiplinks is `.visually-hidden-focusable` and only
    // exists on screen after a Tab. Without this it could not be captured at
    // all — which is why it was the one component with no reference, and why it
    // shipped rendering the inverse of the design system for so long.
    if (cfg.pressKeys) {
      for (const k of cfg.pressKeys) await page.keyboard.press(k);
      await page.waitForTimeout(cfg.focusSettleMs ?? 200);
    }
    await root.waitFor({ state: 'visible', timeout: 10000 });
    await page.waitForTimeout(cfg.settleMs ?? 300);

    // Some components only exist after interaction — the Modale stories render
    // just a trigger button, and no `args` override can open them. `click` is a
    // selector to press first (default: the story's first button), so those
    // references stay reproducible from this script instead of a one-off.
    if (cfg.click) {
      const trigger =
        cfg.click === true ? root.locator('button').first() : page.locator(cfg.click).first();
      await trigger.click();
      await page.waitForTimeout(cfg.clickSettleMs ?? 500);
    }

    // `selector` targets a specific element inside the story (e.g. ".btn").
    // Default: the story's first rendered child, which for single-component
    // stories is exactly the component.
    const target = cfg.selector
      ? page.locator(cfg.selector).first()
      : root.locator(':scope > *').first();
    await target.waitFor({ state: 'visible', timeout: 10000 });

    const outPath = path.join(OUT_DIR, `${key}.png`);
    // Elements often sit at fractional CSS coordinates, and element.screenshot()
    // rounds that box outward — a 54.48x21 badge comes back as 56x22, i.e. up to
    // 2 device px of stray margin that no Flutter capture can ever match. Clip
    // to the rounded box explicitly so both sides frame the same region.
    const box = await target.boundingBox();
    if (box) {
      await page.screenshot({
        path: outPath,
        clip: {
          x: Math.round(box.x),
          y: Math.round(box.y),
          width: Math.max(1, Math.round(box.width)),
          height: Math.max(1, Math.round(box.height)),
        },
      });
    } else {
      await target.screenshot({ path: outPath });
    }
    console.log(`OK   ${key}`);
  } catch (err) {
    failures.push(key);
    console.error(`FAIL ${key}: ${err.message}`);
  } finally {
    await page.close();
  }
}

await browser.close();

if (failures.length) {
  console.error(`\n${failures.length} capture(s) failed: ${failures.join(', ')}`);
  process.exit(1);
}
