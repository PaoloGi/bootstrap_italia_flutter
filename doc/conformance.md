# Conformance and verification status

This document states plainly what has been verified, how, and what has **not**.
It exists because a design system for Italian public administration is subject to
legal accessibility obligations, and "it looks right" is not evidence.

Nothing here claims official status: this is an unofficial community port. See
[NOTICE.md](../NOTICE.md).

## Normative references

| Reference | Role |
| --- | --- |
| [Bootstrap Italia](https://github.com/italia/bootstrap-italia) **2.18.0** (fetch with `tool/fetch_bootstrap_italia.sh`) | Normative source for all visual values. Every colour, spacing, radius, font-size and border in this package is read from its compiled CSS, not eyeballed. |
| [design-react-kit](https://italia.github.io/design-react-kit) Storybook | Rendering reference for automated comparison only. |
| Legge 4/2004 ("Stanca"), EU Directive 2016/2102 | Bind Italian PA services to accessibility obligations. |
| UNI CEI EN 301 549 | Harmonised standard; its web clauses are satisfied by **WCAG 2.1 level AA**. |

> **Forward notice.** With the scheduled EN 301 549 update the web reference
> moves to **WCAG 2.2 AA** (European enforcement expected late 2026). Work
> planned against this package should target 2.2, not 2.1.

## What is verified, and how

| Area | Method | Status |
| --- | --- | --- |
| Visual fidelity at rest | SSIM + flat-tile colour diff vs the upstream Storybook, 72 keys across 5 component groups | **71/72 ≥ 95%** |
| The similarity metric itself | `diff/metric_selftest.py` — proves it fails wrong colours (+4/channel), 4px padding, 10% size and wrong-component, while tolerating engine noise | **Passing, gates CI** |
| Design-token values | Read directly from `bootstrap-italia.min.css` | Verified per component |
| Documented variants | Each example page mirrors its docs page section by section; where a component could not express a section, the feature was added | Verified for the 25 components this package implements |
| Colour contrast (WCAG 1.4.3 / 1.4.11) | `test/a11y/contrast_audit_test.dart`, deterministic over tokens | **All checked pairs pass AA** |
| Interaction-state colour | Real browser input against both implementations, sampled per state | **All components** |
| Screen-reader semantics | Contracts on Flutter's own semantics tree (role, name, state, actions), in `test/a11y/` | Covered for every component |
| Keyboard operability (2.1.1 / 2.1.2) | `sendKeyEvent` tests: Space, Enter, arrows, Home/End, Esc, focus return | Covered |
| Focus visible (2.4.7) | Contracts assert nothing painted unfocused, indicator painted after Tab | Covered |
| Target size (2.5.8, new in 2.2) | Hit-region probes, not layout boxes | Covered |
| Static analysis / formatting | `flutter analyze --fatal-infos`, `dart format` | Clean, enforced in CI |
| Licence compliance | Font licences bundled, provenance recorded | See [NOTICE.md](../NOTICE.md) |
| Framework coupling | Migration off `flutter/material` per [ADR 0001](adr/0001-build-on-widgets-not-material.md) | In progress — buttons done |

### Why contrast is audited on tokens, not screenshots

axe-core **cannot** evaluate contrast on Flutter Web: the semantics tree is a
transparent overlay above a canvas, so axe returns `incomplete` rather than a
verdict. A screenshot-based check would therefore give false assurance. Auditing
the token layer is exhaustive, deterministic, offline, and fails CI on
regression.

## What is NOT verified — do not assume conformance

These are open. Each is a real gap, not a formality.

1. **No screen-reader testing with real assistive technology** (VoiceOver,
   TalkBack, NVDA). This is the largest remaining gap. Automated tooling detects
   a minority of accessibility defects: our contracts prove a role and state are
   *exposed*, not that the resulting announcement is intelligible. An expert
   audit with real AT is required before any conformance claim.
2. **Mobile/desktop targets are unverified.** All parity evidence is from Flutter
   Web. The semantics contracts are platform-independent (they assert Flutter's
   own tree, not the web DOM) so they do hold on mobile, but the pixel evidence
   does not.
3. **Coverage is not uniform.** A gap audit of the public widgets found the
   uncovered remainder to be mostly small primitives. `ItSpinner` was the
   notable exception — it had neither a parity capture nor a contract — and now
   has both (`spinner_default`, and the `ItSpinner` group in
   `test/a11y/content_semantics_test.dart`, which pins that it announces its
   loading state). `ItSkiplinks` was the last component with no parity capture, and that gap is not academic: it is why the component
   shipped rendering the *inverse* of the design system — a primary-filled bar
   with white text, where the stylesheet declares a pale band with blue links —
   until a token audit read the CSS. It now has one (`nav_skiplinks`, 99.61%),
   captured after a Tab press because `.visually-hidden-focusable` keeps the bar
   off-screen until focused. Re-run the audit after adding a component.
4. **Some callout variant icons are unverified.** `warning`, `danger`,
   `important` and `note` have no captured reference, so their glyphs are the
   closest same-set equivalents rather than observed values. `success` and the
   default are verified.

   A protocol for this pass is now in `doc/at-testing-protocol.md`, and
   `flutter test tool/a11y/preview` generates `doc/at-announcements.md` —
   what each component gives a screen reader, in tree order and in Tab
   order. Everything mechanical has been moved into automated tests so the
   manual pass is spent on the four questions only a person can answer.

## Known divergences from the kit

Each of these was found by reproducing the documentation's own examples, and
each is a deliberate decision with the evidence attached at the point of use in
the code. They are listed here because a divergence nobody can find is
indistinguishable from a bug.

### Where the kit and its own documentation disagree

| | |
|---|---|
| `.leverRight` | The Toggles page's *Inline* example uses it; v2.18.0's compiled CSS declares **zero** `.leverRight` rules, and `.lever` already floats right. Not implemented. |
| `.form-control-plaintext` | The prose says it removes the underline. `border-width: 0 0` (specificity 0,1,0) loses to `input[type=text] { border-bottom: 1px solid }` (0,1,1), so on an `<input>` it does not — on a `<textarea>` (0,0,1) it does. Implemented as the kit *renders*, both branches. |
| `.callout-big-text` | Sets `font-size: 1.125rem`, which is already the value of `.callout p`. No effect, so not exposed as a parameter. |
| `.alert-secondary` | The docs list five variants; the stylesheet declares no such rule. Kept as a pixel-identical `info` without a glyph, since removing it would break callers. |
| `.chip-disabled` | Declared *before* `.chip-primary` at equal specificity, so a browser paints a disabled coloured chip as an ordinary one. **Deliberately not reproduced**: an inoperable control that looks operable is a defect, not a style. |
| `.btn-sm` | v2.18.0 redeclares it to the default button's own padding and size. The docs show four size headings; only three renderings exist. |
| `.text-secondary` | `#30475F`, which is **not** `--bs-secondary` (`#5D7083`), despite the name. |

### Where the reference story and the documentation disagree

The visual-parity references are captured from the design-react-kit Storybook,
which is not always the same specimen as the documentation page.

- **`tab_icon_text`** renders *without* `.nav-tabs-icon-text`, so the captured
  baseline has no gap while the docs always apply the class.
  `ItTabLayout.standard` keeps the captured behaviour; `iconAndText` is the
  documented one.
- **List rows** are 1rem in the reference and `.list-item-title` is 1.125rem.
  Measured: forcing 18px moved all three list captures *away* from the
  reference (100% → ~96.8%). The 18px belongs to the
  `.list-item-title-icon-wrapper` shape, which `large: true` covers.
- **List dividers** are present in the reference; the docs' base navigation list
  has none. Measured: turning them off dropped a capture to 88.66%.

Where the two disagree, the **reference wins for the default** — it is what
parity is scored against — and the documented variant is exposed as an option.

### Accepted, and not yet resolved

- **`.form-check` labels are 18px above 576px** (`@media (min-width: 576px)`);
  ours are always 16px. This is the container-vs-viewport breakpoint divergence
  recorded in the ADR, and changing it would move four parity captures.
- **The dark breadcrumb's icon** uses `.icon-white` in the docs and an
  aquamarine in `.breadcrumb.dark .breadcrumb-item i`. Two competing
  declarations in one kit; we paint the latter.
- **Footer column headings are always underlined**, because the kit's link
  columns are anchors and that is the parity-verified rendering — but the
  contacts band's heading is not an anchor, so it reads as a link there.
- **`aria-labelledby` on a tab panel is not reproduced.** Flutter's `Semantics`
  has no `labelledBy`, and faking it with a `label` would make AT read the tab's
  name before the panel's content. `aria-controls` (tab → panel) *is*.

## Known environmental issue

Some widget tests fail locally with:

```
Asset 'shaders/ink_sparkle.frag' manifest could not be decoded:
INVALID_ARGUMENT: Unsupported runtime stages format version. Expected 2, got 0.
```

This is a corrupted Flutter engine artifact, **not** a defect in this package —
a test containing no package code reproduces it. Remedy: `flutter precache --force`.
CI provisions a clean SDK and is unaffected.

## Known defects and planned work

A clean-code/API review and an architecture assessment produced a ranked backlog
— remaining P0 defects, a public-API consistency pass that is cheap now and
expensive after adoption, and the standing guards that stop each class of defect
returning. See [quality-plan.md](quality-plan.md).

## A verification that was not verifying anything

Worth recording, because the failure mode is general. "No parity capture moved"
was checked with `git status tool/visual_parity/flutter_captures` — a directory
that is in `.gitignore`, so the command always printed nothing and could never
fail. Behind it, parity fell from 73/74 to 65/74 without a single red test.

Use `tool/visual_parity/capture_hashes.sh`, which compares content hashes, and
score with `diff/report.py`: a moved rendering is not automatically wrong, but
only the score says whether it moved toward the reference or away from it.

## Reproducing the evidence

```bash
flutter test                      # includes the WCAG contrast audit
tool/visual_parity/.venv/bin/python tool/visual_parity/diff/metric_selftest.py
tool/visual_parity/.venv/bin/python tool/visual_parity/diff/report.py --threshold 95
```

See [`tool/visual_parity/README.md`](../tool/visual_parity/README.md) for the
full harness, including the browser-driven interaction and breakpoint tooling.
