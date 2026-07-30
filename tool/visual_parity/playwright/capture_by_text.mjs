import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUT_DIR = path.resolve(__dirname, '..', 'reference');
mkdirSync(OUT_DIR, { recursive: true });

// argv: <storyId> <width> <height> <exactText> <outKey>
const [storyId, width, height, exactText, outKey] = process.argv.slice(2);

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: Number(width), height: Number(height) }, deviceScaleFactor: 2 });
const url = `https://italia.github.io/design-react-kit/iframe.html?id=${storyId}&viewMode=story`;
await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
await page.waitForTimeout(300);

const el = page.locator('button, a, input[type=submit], input[type=reset]', { hasText: exactText }).first();
await el.waitFor({ state: 'visible', timeout: 10000 });
const outPath = path.join(OUT_DIR, `${outKey}.png`);
await el.screenshot({ path: outPath });
console.log(`OK -> ${outPath}`);

await browser.close();
