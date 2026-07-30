import { chromium } from 'playwright';
import { readFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const STORYBOOK_BASE = 'https://italia.github.io/design-react-kit';
const OUT_DIR = path.resolve(__dirname, '..', 'reference');

// components.json: { "<component_key>": { "storyId": "...", "width": 800, "note": "..." } }
const configPath = path.resolve(__dirname, 'components.json');
const components = JSON.parse(readFileSync(configPath, 'utf-8'));

const only = process.argv[2]; // optional: capture a single component key

mkdirSync(OUT_DIR, { recursive: true });

const browser = await chromium.launch();
const context = await browser.newContext({ deviceScaleFactor: 2 });

let failures = [];

for (const [key, cfg] of Object.entries(components)) {
  if (only && key !== only) continue;

  const page = await context.newPage();
  await page.setViewportSize({ width: cfg.width ?? 900, height: cfg.height ?? 700 });

  const argsParam = cfg.args
    ? `&args=${Object.entries(cfg.args).map(([k, v]) => `${k}:${v}`).join(';')}`
    : '';
  const url = `${STORYBOOK_BASE}/iframe.html?id=${cfg.storyId}&viewMode=story${argsParam}`;
  try {
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    // storybook renders the story into #storybook-root
    const root = page.locator(cfg.selector ?? '#storybook-root');
    await root.waitFor({ state: 'visible', timeout: 10000 });
    // let fonts/webfonts/icons settle
    await page.waitForTimeout(cfg.settleMs ?? 300);

    const target = cfg.selector ? root : root.locator(':scope > *').first();
    const outPath = path.join(OUT_DIR, `${key}.png`);
    await target.screenshot({ path: outPath });
    console.log(`OK   ${key} -> ${outPath}`);
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
