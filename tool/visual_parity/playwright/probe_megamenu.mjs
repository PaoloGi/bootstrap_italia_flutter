// The megamenu story renders its panel with `aria-hidden` and no `.show`, so
// the items are not hoverable until the menu is opened. Force it open, then read
// the computed colours at rest and on hover.
import { chromium } from 'playwright';

const STORYBOOK_BASE = 'https://italia.github.io/design-react-kit';
const storyId = 'documentazione-menu-di-navigazione-megamenu--con-intestazione-e-link-more';

const browser = await chromium.launch();
const page = await browser.newPage();
await page.setViewportSize({ width: 1400, height: 1000 });
await page.goto(`${STORYBOOK_BASE}/iframe.html?id=${storyId}&viewMode=story`, {
  waitUntil: 'load',
  timeout: 90000,
});
await page.waitForTimeout(3000);

await page.evaluate(() => {
  const menu = document.querySelector('.dropdown-menu');
  menu.classList.add('show');
  menu.removeAttribute('aria-hidden');
  menu.style.display = 'block';
  menu.style.position = 'static';
  menu.parentElement?.classList.add('show');
});
await page.waitForTimeout(500);

const read = (sel) =>
  page.evaluate((s) => {
    const el = document.querySelector(s);
    if (!el) return { error: `missing ${s}` };
    const cs = getComputedStyle(el);
    const out = {
      color: cs.color,
      bg: cs.backgroundColor,
      deco: cs.textDecorationLine,
    };
    const span = el.querySelector('span');
    if (span) {
      const scs = getComputedStyle(span);
      out.spanColor = scs.color;
      out.spanDeco = scs.textDecorationLine;
    }
    const svg = el.querySelector('svg');
    if (svg) out.svgFill = getComputedStyle(svg).fill;
    return out;
  }, sel);

for (const sel of [
  '.dropdown-menu a.dropdown-item.list-item',
  '.dropdown-menu a.it-heading-link',
]) {
  const out = { selector: sel };
  out.default = await read(sel);
  await page.locator(sel).first().hover();
  await page.waitForTimeout(400);
  out.hover = await read(sel);
  const box = await page.locator(sel).first().boundingBox();
  await page.mouse.down();
  await page.waitForTimeout(300);
  out.active = await read(sel);
  await page.mouse.up();
  await page.mouse.move(box.x, box.y - 200);
  await page.waitForTimeout(200);
  console.log(JSON.stringify(out, null, 2));
}

await browser.close();
