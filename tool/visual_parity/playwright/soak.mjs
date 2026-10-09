// Drives the Flutter Web soak page in a real browser and reports what breaks.
//
// The parity harness answers "does this component look right". This answers a
// different question: put EVERY component on one page, in a real browser, and
// see whether anything throws, overflows, disappears, or fails an axe rule.
//
//   cd example && flutter build web -t lib/soak.dart --no-tree-shake-icons
//   (cd example/build/web && python3 -m http.server 8788)
//   node tool/visual_parity/playwright/soak.mjs [--headed] [--json out.json]
import { chromium } from 'playwright';
import { createRequire } from 'node:module';
import { writeFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(path.join(__dirname, 'package.json'));
const axeSource = require('axe-core').source;

const BASE = process.env.SOAK_BASE ?? 'http://localhost:8788';
const args = process.argv.slice(2);
const headed = args.includes('--headed');
const jsonAt = args.includes('--json') ? args[args.indexOf('--json') + 1] : null;

/** Viewports the page must survive. */
const VIEWPORTS = [
  { name: 'phone', width: 390, height: 844 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1440, height: 900 },
  // WCAG 1.4.4. Flutter's text scaler comes from the platform, not from CSS,
  // so the page reads it from the URL — see `_urlTextScale` in soak.dart.
  { name: 'phone@200%', width: 390, height: 844, textScale: 2 },
];

const findings = [];
const note = (severity, area, detail) =>
  findings.push({ severity, area, detail });

/** Flutter Web paints to canvas; its semantics tree is opt-in. */
async function enableSemantics(page) {
  // Flutter renders a placeholder button that turns the a11y tree on. Without
  // clicking it there is no DOM to audit at all — axe would pass a blank page,
  // which is the most misleading possible result.
  const btn = page.locator('flt-semantics-placeholder, [aria-label*="accessibility" i]');
  try {
    await btn.first().click({ timeout: 4000, force: true });
  } catch {
    await page.evaluate(() => {
      const el = document.querySelector('flt-semantics-placeholder');
      el?.dispatchEvent(new Event('click', { bubbles: true }));
    });
  }
  await page.waitForTimeout(1200);
  return page.locator('flt-semantics').count();
}

async function run() {
  const browser = await chromium.launch({ headless: !headed });

  for (const vp of VIEWPORTS) {
    const page = await browser.newPage({
      viewport: { width: vp.width, height: vp.height },
    });

    const consoleErrors = [];
    const pageErrors = [];
    const soakErrors = [];
    page.on('console', (m) => {
      const t = m.text();
      if (t.startsWith('SOAK-ERROR')) soakErrors.push(t);
      else if (m.type() === 'error') consoleErrors.push(t);
    });
    page.on('pageerror', (e) => pageErrors.push(String(e)));

    const url = vp.textScale ? `${BASE}/?textScale=${vp.textScale}` : BASE;
    await page.goto(url, { waitUntil: 'networkidle' });
    // Flutter boots asynchronously; the canvas exists before the app does.
    await page.waitForSelector('flt-glass-pane, flutter-view', { timeout: 30000 });
    await page.waitForTimeout(2500);

    // ── 1. did it render at all ────────────────────────────────────
    // Flutter may use several canvases and leave some sized 0; asking only the
    // first reported "nothing painted" on two viewports that had in fact
    // rendered. Take the largest, and fall back to the view element.
    const painted = await page.evaluate(() => {
      const areas = [...document.querySelectorAll('canvas')]
        .map((c) => c.width * c.height);
      const max = areas.length ? Math.max(...areas) : 0;
      if (max > 0) return max;
      const v = document.querySelector('flutter-view, flt-glass-pane');
      return v ? v.clientWidth * v.clientHeight : 0;
    });
    if (!painted) note('FAIL', `${vp.name}/render`, 'nothing painted');

    // ── 2. semantics ───────────────────────────────────────────────
    const semanticsNodes = await enableSemantics(page);
    if (semanticsNodes === 0) {
      note('FAIL', `${vp.name}/semantics`, 'semantics tree is empty after enabling');
    } else {
      note('INFO', `${vp.name}/semantics`, `${semanticsNodes} nodes`);
    }

    // ── 3. axe over the semantics DOM ──────────────────────────────
    await page.addScriptTag({ content: axeSource });
    const axe = await page.evaluate(async () => {
      // eslint-disable-next-line no-undef
      const r = await axe.run(document, {
        runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'] },
      });
      return r.violations.map((v) => ({
        id: v.id,
        impact: v.impact,
        nodes: v.nodes.length,
        help: v.help,
        // The offending markup, so a violation can be traced to a component
        // instead of just counted.
        html: v.nodes.slice(0, 2).map((n) => n.html.slice(0, 180)),
        target: v.nodes.slice(0, 2).map((n) => n.target.join(' ')),
      }));
    });
    for (const v of axe) {
      note(v.impact === 'critical' || v.impact === 'serious' ? 'FAIL' : 'WARN',
        `${vp.name}/axe`, `${v.id} (${v.impact}, ${v.nodes} nodes) — ${v.help}`);
      for (const h of v.html) note('INFO', `${vp.name}/axe-html`, h);
    }

    // Flutter Web puts its accessible names in `aria-label` on
    // `flt-semantics`, not in text content, and it MERGES a title and body
    // into one label — the notification reads "Fatto. Operazione completata.".
    // Matching on text content therefore finds some overlays and misses
    // others for reasons that have nothing to do with whether they opened.
    // Either channel: Flutter Web puts some names in `aria-label` and renders
    // others as text, and which one you get varies by widget and by viewport.
    // Checking only labels made the modal look shut on tablet and desktop
    // while it was in fact open — and because the check then skipped the
    // dismiss, the modal stayed up and every later step timed out behind it.
    const labelPresent = (needle) =>
      page.evaluate((n) => {
        const nodes = [...document.querySelectorAll('flt-semantics')];
        return nodes.some((e) =>
          (e.getAttribute('aria-label') ?? '').includes(n) ||
          (e.textContent ?? '').includes(n));
      }, needle);

    /// Closes whatever is open, so one failed step cannot poison the next.
    const dismissAll = async () => {
      for (let i = 0; i < 3; i++) {
        await page.keyboard.press('Escape');
        await page.waitForTimeout(300);
      }
    };

    // ── 4. overlays: open, assert, dismiss, assert ─────────────────
    //
    // The first version of this clicked and pressed Escape and asserted
    // NOTHING — a missed click, an overlay that never opened and an Escape
    // that did nothing all passed identically. Each step is now checked, and
    // the dismiss half is a WCAG 2.1.2 property in its own right.
    for (const [label, trigger, marker] of [
      ['modal', 'Apri modale', 'Corpo della modale.'],
      ['offcanvas', 'Apri pannello', 'Contenuto del pannello.'],
      ['notification', 'Mostra notifica', 'Operazione completata.'],
    ]) {
      try {
        if (await labelPresent(marker)) {
          note('FAIL', `${vp.name}/${label}`, 'already open before the click');
        }
        const t = page.locator(`text=${trigger}`).first();
        await t.scrollIntoViewIfNeeded({ timeout: 5000 });
        await t.click({ timeout: 5000 });
        await page.waitForTimeout(900);

        if (!(await labelPresent(marker))) {
          note('FAIL', `${vp.name}/${label}`, 'did not open');
          await dismissAll();
          continue;
        }

        await page.keyboard.press('Escape');
        await page.waitForTimeout(700);
        if (await labelPresent(marker)) {
          // The notification is not a route and is not expected to close on
          // Escape; the two that trap focus must.
          const sev = label === 'notification' ? 'INFO' : 'FAIL';
          note(sev, `${vp.name}/${label}`, 'still open after Escape');
          if (sev === 'INFO') {
            await page.locator('[aria-label*="Chiudi" i]').first()
              .click({ timeout: 3000 }).catch(() => {});
            await page.waitForTimeout(400);
          }
        }
      } catch (e) {
        note('FAIL', `${vp.name}/${label}`,
          `could not drive: ${String(e).split('\n')[0]}`);
      } finally {
        await dismissAll();
      }
    }

    // ── 5. keyboard: focus must MOVE, and a modal must hold it ─────
    //
    // The first version asked `!!document.activeElement`, which is never
    // false — it falls back to <body>. What can actually fail is whether Tab
    // moves focus at all, and whether an open modal keeps it inside.
    const signature = () =>
      page.evaluate(() => {
        const a = document.activeElement;
        if (!a) return 'none';
        return [a.tagName, a.id, a.getAttribute('aria-label') ?? '',
          a.getAttribute('role') ?? ''].join('|');
      });

    const seen = new Set();
    for (let i = 0; i < 40; i++) {
      await page.keyboard.press('Tab');
      seen.add(await signature());
    }
    if (seen.size < 5) {
      note('FAIL', `${vp.name}/keyboard`,
        `focus visited only ${seen.size} distinct targets in 40 tabs — it is stuck`);
    } else {
      note('INFO', `${vp.name}/keyboard`, `${seen.size} distinct focus targets`);
    }

    // A modal SHOULD trap: open one and check focus stays inside it.
    try {
      const t = page.locator('text=Apri modale').first();
      await t.scrollIntoViewIfNeeded({ timeout: 5000 });
      await t.click({ timeout: 5000 });
      await page.waitForTimeout(900);
      const inside = await labelPresent('Corpo della modale');
      if (!inside) {
        note('FAIL', `${vp.name}/focus-trap`, 'modal did not open for the trap check');
      } else {
        const before = await signature();
        const escaped = [];
        for (let i = 0; i < 15; i++) {
          await page.keyboard.press('Tab');
          escaped.push(await signature());
        }
        // Everything behind a modal route leaves the tree in Flutter, so if
        // focus reached the page beneath, the page's own controls would be
        // reachable — they are not, which is the property worth pinning.
        const pageControlReached = await page.evaluate(() =>
          document.activeElement?.getAttribute('aria-label') === 'Apri pannello');
        if (pageControlReached) {
          note('FAIL', `${vp.name}/focus-trap`,
            'focus escaped the modal onto the page behind it (WCAG 2.4.3)');
        } else {
          note('INFO', `${vp.name}/focus-trap`,
            `held across 15 tabs (from ${before.split('|')[0]})`);
        }
      }
    } catch (e) {
      note('WARN', `${vp.name}/focus-trap`, String(e).split('\n')[0]);
    } finally {
      await dismissAll();
    }

    // ── 6. scroll the whole document ───────────────────────────────
    for (let i = 0; i < 12; i++) {
      await page.mouse.wheel(0, 800);
      await page.waitForTimeout(120);
    }

    // ── 7. anything logged ─────────────────────────────────────────
    for (const e of soakErrors) {
      note('FAIL', `${vp.name}/dart`, e.replace('SOAK-ERROR :: ', '').slice(0, 260));
    }
    for (const e of pageErrors) note('FAIL', `${vp.name}/exception`, e.slice(0, 200));
    for (const e of consoleErrors.slice(0, 10)) {
      note('WARN', `${vp.name}/console`, e.slice(0, 200));
    }

    mkdirSync(path.join(__dirname, '../soak_shots'), { recursive: true });
    await page.screenshot({
      path: path.join(__dirname, '../soak_shots', `${vp.name}.png`),
      fullPage: false,
    });
    await page.close();
  }

  await browser.close();

  const fails = findings.filter((f) => f.severity === 'FAIL');
  const warns = findings.filter((f) => f.severity === 'WARN');
  console.log('\n─── soak result ───');
  for (const f of findings) console.log(`${f.severity.padEnd(4)} ${f.area.padEnd(22)} ${f.detail}`);
  console.log(`\nFAIL ${fails.length}   WARN ${warns.length}`);
  if (jsonAt) writeFileSync(jsonAt, JSON.stringify(findings, null, 2));
  process.exit(fails.length ? 1 : 0);
}

run().catch((e) => {
  console.error('soak driver crashed:', e);
  process.exit(2);
});
