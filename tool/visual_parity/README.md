# Parity & conformance harness

Automated evidence that this Flutter port matches Bootstrap Italia — visually,
behaviourally and in accessibility semantics. Nothing here is published with the
package; it exists to keep the port honest.

## Why the harness is shaped this way

The obvious approach — screenshot the React kit, screenshot Flutter, diff —
produces confident-looking numbers that are wrong in both directions. Several
non-obvious problems had to be solved before any score meant anything, and each
fix is load-bearing. If you are tempted to simplify one, read the comment above
it first; they are documented at the point of the code.

Two independent sources of truth are used:

1. **`bootstrap-italia.min.css` is normative.** Every colour, size, padding and
   border is read from the compiled CSS (or from `getComputedStyle` in a real
   browser), never eyeballed from a screenshot.
2. **The rendered Storybook is a regression net**, not a specification. It
   catches drift; it does not define correctness.

## Layout

```
tool/visual_parity/
  playwright/
    capture.mjs              upstream reference captures (supports args + click)
    capture_flutter_web.mjs  Flutter captures driven by REAL browser input
    components/<group>.json  what to capture, per group
  diff/
    compare.py               scoring: SSIM + flat-tile colour delta
    report.py                per-group pass/fail table
    metric_selftest.py       guards the metric itself — see below
tool/a11y/
  axe_audit.mjs              WCAG 2.2 axe run against BOTH implementations
```

## Scoring, and why it is not plain SSIM

`compare.py` combines two gates:

- **Structural**: SSIM at a shared scale, never upscaling, tolerant of ≤2px
  misalignment (compared over the overlapping region only), with a 0.75px blur.
  Chromium and Skia never agree at the sub-pixel level; without these, correct
  components scored ~85–90% and the metric reported rendering noise as defects.
- **Colour**: the largest mean colour difference over any 16px tile that is a
  flat fill in *both* images. SSIM is a whole-image average, so a wrong colour on
  a small element barely moves it — an 18/channel error on a 20×20 checkbox still
  scored 98%. Restricting to flat tiles excludes text/icon tiles, which differ
  legitimately between engines by up to ~27/channel.

**`metric_selftest.py` is the guard on all of that.** It asserts the metric still
fails wrong colours (down to +4/channel), 4px padding errors, 10% size errors and
wrong components, while passing real renders and 1px engine shifts. CI runs it
*before* the parity report, because a metric that has quietly become permissive
makes every number after it meaningless. Never loosen the metric without running
it.

Realistic passing range is **95–99%**. 100% is unreachable across rendering
engines; treat a claim of 100% as a bug in the measurement.

## Running it

```bash
# at-rest visual parity (offline for Flutter, network for the reference)
flutter test tool/visual_parity/capture
node tool/visual_parity/playwright/capture.mjs            # all groups
tool/visual_parity/.venv/bin/python tool/visual_parity/diff/metric_selftest.py
tool/visual_parity/.venv/bin/python tool/visual_parity/diff/report.py --threshold 95
```

```bash
# interaction states, breakpoints and accessibility (browser-driven)
cd example && flutter build web -t lib/parity_harness.dart --no-tree-shake-icons
(cd example/build/web && python3 -m http.server 8777 &)

node tool/visual_parity/playwright/capture_flutter_web.mjs button_primary hover
node tool/a11y/axe_audit.mjs
```

Setup (or to prepare a git worktree, which symlinks the venv/node_modules):

```bash
bash tool/visual_parity/setup.sh
```

## Why the Flutter side runs in a browser

For interaction and breakpoint parity, Flutter is driven through Playwright
rather than a Flutter test driver, so **one tool with one event model** drives
both implementations. Pairing Playwright against a separate driver would mean
comparing two different definitions of "hover" and "focus".

`example/lib/parity_harness.dart` renders one component by query string and
publishes its own bounds to JS (Flutter paints to a canvas — there is no DOM node
to measure, and interaction resizes things). `?a11y=1` forces the semantics tree
on; `?cw=` constrains the component's width without changing the viewport, which
is what distinguishes container-based from viewport-based responsiveness.

## Accessibility

See [`doc/conformance.md`](../../doc/conformance.md) for status. Three layers,
because no one of them is sufficient:

| Layer | Catches | Blind to |
| --- | --- | --- |
| `test/a11y/semantics_contract_test.dart` | wrong roles/states (a checkbox exposed as a button) | anything not asserted |
| `tool/a11y/axe_audit.mjs` | standard ARIA/WCAG violations, on both implementations | *valid but wrong* semantics; contrast on canvas |
| `test/a11y/contrast_audit_test.dart` | WCAG 1.4.3 / 1.4.11 contrast, deterministically | everything else |

axe **cannot** evaluate contrast on Flutter Web: the semantics tree is a
transparent overlay above a canvas, so it returns `incomplete`. That is why
contrast is audited from tokens and never from screenshots.

## CI

`.github/workflows/ci.yml` runs format, `analyze --fatal-infos`, tests and `pana`
hermetically. The parity job is separate and `continue-on-error`, because it
depends on a live third-party Storybook and upstream flakiness must never block
an unrelated PR.
