// WCAG 2.2 AA audit of BOTH implementations with the same ruleset.
//
// Why both sides: an isolated Flutter result is hard to act on — a violation
// that the reference also has is an upstream/design-system issue, while one only
// we have is ours. Running identical rules against both turns a raw finding into
// a decision.
//
// Prereqs:
//   cd example && flutter build web -t lib/parity_harness.dart --no-tree-shake-icons
//   (cd example/build/web && python3 -m http.server 8777)
//
// Usage:
//   node tool/a11y/axe_audit.mjs                 # audit everything, write report
//   node tool/a11y/axe_audit.mjs button_primary  # single key
//   node tool/a11y/axe_audit.mjs --json out.json
//
// Exit code is 1 if any Flutter-side violation is not also present upstream.
import { chromium } from 'playwright';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(__dirname, '..', '..');
const AXE_SRC = readFileSync(require.resolve('axe-core'), 'utf8');

const FLUTTER_BASE = process.env.PARITY_WEB_BASE ?? 'http://localhost:8777';
const STORYBOOK = 'https://italia.github.io/design-react-kit';

// WCAG 2.2 AA. EN 301 549's web clauses are satisfied by WCAG AA, and the
// standard's scheduled update moves the reference from 2.1 to 2.2 — so we audit
// against 2.2 now rather than retrofitting later.
const WCAG_TAGS = [
  'wcag2a', 'wcag2aa',
  'wcag21a', 'wcag21aa',
  'wcag22a', 'wcag22aa',
];

// Rules that cannot produce a meaningful verdict on a Flutter canvas, with the
// reason. Suppressed honestly rather than silently: each is reported as
// "not-assessable" in the output so it cannot be mistaken for a pass.
const NOT_ASSESSABLE_ON_CANVAS = {
  'color-contrast':
    'Flutter Web paints to a canvas; the semantics tree is a transparent ' +
    'overlay, so axe cannot sample pixels. Audited deterministically instead ' +
    'in test/a11y/contrast_audit_test.dart.',
};

// Page-level rules that describe the harness document, not the component.
const HARNESS_LEVEL_RULES = new Set([
  'document-title', 'html-has-lang', 'landmark-one-main', 'page-has-heading-one',
  'region', 'meta-viewport', 'bypass',
]);

const args = process.argv.slice(2);
const jsonFlag = args.indexOf('--json');
const jsonOut = jsonFlag === -1 ? path.join(REPO, 'tool/a11y/report.json') : args[jsonFlag + 1];
const onlyKey = args.find((a) => !a.startsWith('--') && a !== jsonOut);

const registry = JSON.parse(
  readFileSync(path.join(__dirname, 'components.json'), 'utf-8'),
);
const keys = onlyKey ? [onlyKey] : Object.keys(registry);

async function runAxe(page) {
  await page.addScriptTag({ content: AXE_SRC });
  return page.evaluate(
    async (tags) =>
      window.axe.run(document, { runOnly: { type: 'tag', values: tags } }),
    WCAG_TAGS,
  );
}

/** Flatten axe output to `{ruleId: {impact, help, nodes}}`, dropping harness noise. */
function summarise(result) {
  const out = {};
  for (const v of result.violations) {
    if (HARNESS_LEVEL_RULES.has(v.id)) continue;
    out[v.id] = { impact: v.impact, help: v.help, nodes: v.nodes.length };
  }
  return out;
}

const browser = await chromium.launch();
const context = await browser.newContext({ deviceScaleFactor: 1 });
const report = { generated: null, wcag: '2.2 AA', keys: {} };

for (const key of keys) {
  const cfg = registry[key];
  const entry = { flutter: {}, react: {}, notAssessable: NOT_ASSESSABLE_ON_CANVAS };

  // ── Flutter ──────────────────────────────────────────────────────
  const fp = await context.newPage();
  await fp.setViewportSize({ width: cfg.width ?? 1280, height: cfg.height ?? 800 });
  try {
    await fp.goto(`${FLUTTER_BASE}/?key=${encodeURIComponent(key)}&a11y=1`, {
      waitUntil: 'load', timeout: 60000,
    });
    await fp.waitForFunction('window.parityReady === true', { timeout: 60000 });
    await fp.waitForTimeout(600); // let the semantics tree settle
    entry.flutter = summarise(await runAxe(fp));
    entry.flutterSemantics = await fp.evaluate(() =>
      [...document.querySelectorAll('flt-semantics[role]')].map((e) => ({
        role: e.getAttribute('role'),
        name: e.getAttribute('aria-label') || e.textContent.trim() || null,
        tabindex: e.getAttribute('tabindex'),
        disabled: e.getAttribute('aria-disabled'),
        checked: e.getAttribute('aria-checked'),
      })),
    );
  } catch (e) {
    entry.flutter = { _error: e.message };
  } finally {
    await fp.close();
  }

  // ── React reference ──────────────────────────────────────────────
  if (cfg.storyId) {
    const rp = await context.newPage();
    await rp.setViewportSize({ width: cfg.width ?? 1280, height: cfg.height ?? 800 });
    try {
      const argsParam = cfg.args
        ? `&args=${Object.entries(cfg.args).map(([k, v]) => `${k}:${v}`).join(';')}`
        : '';
      await rp.goto(`${STORYBOOK}/iframe.html?id=${cfg.storyId}&viewMode=story${argsParam}`, {
        waitUntil: 'networkidle', timeout: 60000,
      });
      await rp.waitForTimeout(400);
      entry.react = summarise(await runAxe(rp));
    } catch (e) {
      entry.react = { _error: e.message };
    } finally {
      await rp.close();
    }
  }

  // Ours-only violations are the actionable set.
  entry.oursOnly = Object.keys(entry.flutter).filter(
    (id) => !(id in entry.react) && id !== '_error',
  );
  entry.sharedWithUpstream = Object.keys(entry.flutter).filter((id) => id in entry.react);

  report.keys[key] = entry;

  const mark = entry.oursOnly.length === 0 ? 'OK  ' : 'FAIL';
  console.log(
    `${mark} ${key.padEnd(26)} ours-only: ${entry.oursOnly.length}` +
      (entry.sharedWithUpstream.length
        ? `  (also upstream: ${entry.sharedWithUpstream.join(', ')})`
        : ''),
  );
  for (const id of entry.oursOnly) {
    console.log(`       ${id}: ${entry.flutter[id].help} [${entry.flutter[id].impact}]`);
  }
}

await browser.close();

mkdirSync(path.dirname(jsonOut), { recursive: true });
writeFileSync(jsonOut, JSON.stringify(report, null, 2));
console.log(`\nreport -> ${jsonOut}`);

const failing = Object.values(report.keys).filter((e) => e.oursOnly.length > 0);
if (failing.length) process.exit(1);
