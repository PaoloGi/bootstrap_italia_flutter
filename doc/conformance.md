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

## Reproducing the evidence

```bash
flutter test                      # includes the WCAG contrast audit
tool/visual_parity/.venv/bin/python tool/visual_parity/diff/metric_selftest.py
tool/visual_parity/.venv/bin/python tool/visual_parity/diff/report.py --threshold 95
```

See [`tool/visual_parity/README.md`](../tool/visual_parity/README.md) for the
full harness, including the browser-driven interaction and breakpoint tooling.
