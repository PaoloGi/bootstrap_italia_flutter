// Batch version of probe_reference.mjs: reads the computed colours of a set of
// reference elements at rest / hover / press / keyboard-focus in one browser.
//
// Usage: node probe_batch.mjs targets.json
import { chromium } from 'playwright';
import { readFileSync } from 'node:fs';

const STORYBOOK_BASE = 'https://italia.github.io/design-react-kit';
const targets = JSON.parse(readFileSync(process.argv[2], 'utf-8'));

const PROPS = [
  'color',
  'background-color',
  'border-color',
  'border-bottom-color',
  'text-decoration-line',
  'opacity',
  'box-shadow',
  'fill',
];

const browser = await chromium.launch();
const context = await browser.newContext({ deviceScaleFactor: 2 });
const results = {};

for (const t of targets) {
  const page = await context.newPage();
  await page.setViewportSize({ width: t.width ?? 1280, height: t.height ?? 900 });
  const argsParam = t.args ? `&args=${t.args}` : '';
  try {
    await page.goto(`${STORYBOOK_BASE}/iframe.html?id=${t.storyId}&viewMode=story${argsParam}`, {
      waitUntil: 'networkidle',
      timeout: 60000,
    });
    await page.waitForTimeout(500);
    if (t.click) {
      await page.locator(t.click).first().click();
      await page.waitForTimeout(500);
    }

    const read = async () =>
      page.evaluate(
        ([sel, props, childSels]) => {
          const el = document.querySelector(sel);
          if (!el) return { error: `no element for ${sel}` };
          const cs = getComputedStyle(el);
          const out = {};
          for (const p of props) out[p] = cs.getPropertyValue(p);
          for (const cSel of childSels) {
            const c = el.matches(cSel) ? el : el.querySelector(cSel);
            if (!c) continue;
            const ccs = getComputedStyle(c);
            out[`${cSel}|color`] = ccs.color;
            out[`${cSel}|bg`] = ccs.backgroundColor;
            out[`${cSel}|deco`] = ccs.textDecorationLine;
            out[`${cSel}|fill`] = ccs.fill;
            out[`${cSel}|border`] = ccs.borderColor;
          }
          return out;
        },
        [t.selector, PROPS, t.children ?? []],
      );

    const target = page.locator(t.hover ?? t.selector).first();
    await target.waitFor({ state: 'visible', timeout: 20000 });

    const r = {};
    r.default = await read();

    await target.hover();
    await page.waitForTimeout(400);
    r.hover = await read();

    const box = await target.boundingBox();
    await page.mouse.down();
    await page.waitForTimeout(300);
    r.active = await read();
    await page.mouse.up();

    await page.mouse.move(box.x + box.width + 400, 5);
    await page.waitForTimeout(200);
    for (let i = 0; i < 25; i++) {
      await page.keyboard.press('Tab');
      await page.waitForTimeout(60);
      const focused = await page.evaluate(
        (sel) => {
          const el = document.querySelector(sel);
          if (!el) return false;
          return el === document.activeElement || el.contains(document.activeElement);
        },
        t.selector,
      );
      if (focused) break;
    }
    r.focus = await read();

    results[t.key] = r;
    console.error(`OK   ${t.key}`);
  } catch (e) {
    results[t.key] = { error: e.message };
    console.error(`FAIL ${t.key}: ${e.message}`);
  } finally {
    await page.close();
  }
}

console.log(JSON.stringify(results, null, 2));
await browser.close();
