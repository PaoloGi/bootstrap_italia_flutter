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
| Focus visible (2.4.7) | Contracts assert nothing painted unfocused, indicator painted after Tab; text fields: rasterised pixels show the black ring after Tab and none after a tap, as measured on design-react-kit (`test/a11y/form_focus_rendering_test.dart`); focus from a mouse click shows none anywhere, as `track-focus.js` does (`test/a11y/focus_modality_test.dart`) | Covered |
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
2. **Desktop targets are unverified, and mobile only partly.** All *parity*
   evidence is from Flutter Web. The semantics contracts are
   platform-independent — they assert Flutter's own tree, not the web DOM — so
   they hold everywhere, but the pixel evidence does not.

   `example/integration_test/device_soak_test.dart` now runs the whole
   component set on a real device and asserts what only a device can settle:
   that the package's fonts are actually loaded (a fallback face makes every
   width measured meaningless), that the page scrolls end to end without a
   layout error, and that it survives 200% text at the device's own width. It
   is a **debug** build, so framework assertions are live — which is how the
   duplicate navigation-landmark defect was found, one a release web build
   compiles out.

   It deliberately does not test the safe-area inset. Two attempts to do so
   both passed with the handling removed, because `Scaffold` positions a bottom
   bar clear of the inset by itself; that property is covered by
   `test/a11y/safe_area_contract_test.dart`, which does go red. That is not pixel
   parity — there is no reference to compare against off the web — but it
   closes the class of defect that produced three of the last four bugs found
   in this package, all of which appeared only on hardware.

   Desktop (macOS/Windows/Linux) remains entirely unverified.
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

### Flutter Web disables pinch-zoom, and the app has to put it back

`§1.4.4 Resize Text` requires that content be resizable to 200%. Flutter's web
engine rewrites the viewport meta **after boot**, appending
`maximum-scale=1.0, user-scalable=no` — and it does so even when the document
declares its own viewport. Pinch-zoom is off by default in every Flutter Web
app, which for an Italian PA service is a legal failure, not a preference.

Declaring the meta in `index.html` is not enough; the engine overwrites it. The
fix that works is a `MutationObserver` that restores the value whenever the
engine touches it — see `example/web/index.html`. Copy it into any app built on
this package that ships to the web.

This is the engine's behaviour, not the package's, and no widget test can see
it: it only exists in a real browser. It was found by running axe against a
built Flutter Web page (`tool/visual_parity/playwright/soak.mjs`).

### A tab was two controls, one of them unnamed

`ItTabBar` wrapped each tab's painted content in `ItActivatable`, which
publishes its own focusable, tappable semantics node. The tab's own `Semantics`
already carried the role, the name, the selected state and the tap action — so
every tab contained a second interactive node with **no accessible name**
(§4.1.2), which axe reports as `nested-interactive` and `aria-command-name`.

No widget test saw it, because every assertion was about the tab node's own
properties and those were correct. The defect was the node beneath it. Fixed by
excluding the whole activatable rather than only the box it paints; focus
traversal is unaffected, since it does not run through the semantics tree.

### Decorative icons are not held to §1.4.11

`1.4.11 Non-text Contrast` requires 3:1 for «parts of graphics **required to
understand the content**». An icon that merely repeats a visible text label is
not one of those, and holding it to 3:1 costs colour for nothing.

Worked through on a real case. A module tile carried a gold glyph
(`#EDC500`, white symbol) above the words «Attivazione COC», with
`excludeFromSemantics: true`. Someone had darkened it to `#CAA800` with a
`#D9D9D9` symbol, presumably for contrast. Measured:

| | ratio | |
|---|---|---|
| original symbol on tile | 1.67:1 | fails 3:1 |
| darkened symbol on tile | **1.63:1** | fails, and *worse* |
| original tile on white card | 1.67:1 | fails |
| darkened tile on white card | 2.30:1 | fails |

The darkening improved only the tile-against-card figure, 1.67 → 2.30, and
still did not reach 3:1 — while making the symbol-inside-tile figure slightly
worse. It bought no conformance and cost the colour.

The criterion does not apply here: the text beside the glyph carries the
meaning, and the glyph is excluded from the accessibility tree. The original
was restored. **Contrast that is required is worth the colour; contrast that is
not required is just a duller interface.**

### `ItBottomNav` marks the active item with a rule, not only a colour

`.bottom-nav a.active { color: #06c }` is the whole of the active state
upstream — a colour change and nothing else. That is a WCAG 1.4.1 (Use of
Color) weakness whatever palette is applied, and an outright failure once an
administration's brand sits near the inactive colour: measured against one real
PA palette (`#2C546B`) the active and inactive labels differ by **1.18:1**, the
same colour to a sighted user.

`ItBottomNav` therefore also paints a 3px rule above the active item. The width
and the mechanism are the kit's own: `.nav-tabs .nav-link` reserves
`border-bottom: 3px solid transparent` and colours it when active, and
`.flex-column-reverse .nav-tabs .nav-link.active` moves that marker to
`border-top-color` for precisely this case — a row of tabs below its content.
Inactive items reserve the same 3px transparently, so nothing shifts, and the
rule is positioned rather than laid out so the 64px band is unaffected.

State is carried by the rule's presence, so it survives greyscale and any
palette. Screen-reader users were never affected: the entry already sets
`selected:`.

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

## Phase 6 evidence so far — Android platform layer

Partial, and worth being precise about what it does and does not establish.

`AccessibilityDumpTest` (instrumented, in `example/android/app/src/androidTest/`)
reads `AccessibilityNodeInfo` for the example app on a connected device — **the
tree TalkBack actually reads**, after Flutter's Android bridge has translated its
own semantics. That is the layer `tool/a11y/preview` cannot see: the preview
reads Flutter's `SemanticsNode` tree, and the two can disagree. Where they do,
the Android one is what a screen-reader user gets.

It does **not** establish that announcements are intelligible, correctly
ordered, or bearable to listen to. Nothing here can; that still needs a person
with the screen reader on.

Verified on a CPH1979, Android 11:

- Roles, names and states cross the bridge correctly in general. Buttons arrive
  as `Button` with `clickable`, headings and body copy carry their text, and
  expansion state arrives appended to the name (`"Theme, Expanded"`), which is
  the Android idiom.
- `ItChip`'s dismiss controls announce **`"Rimuovi Testo e chiusura"`,
  `"Rimuovi Icona"`, `"Rimuovi Avatar"`** — the per-chip naming, confirmed on
  hardware rather than only in a unit test. Before that change every one of them
  was `"Rimuovi"`, indistinguishable in a rotor list.

### Device sweep: Android accessibility tree

Swept on a CPH1979, Android 11, August 2026. **No accessible-name failures
found.**

Three were reported and all three retracted. `ItInput`, `ItTabBar` and `ItAlert`
are correctly named — verified by reading `AccessibilityNodeInfo` directly, where
`ItInput` shows `hint="Campo di tipo testuale"`, the tabs `"Attivo"`/`"Link"`/
`"Disattivo"`, and every alert its own text.

The false positives came from `uiautomator dump`, twice over: its schema has no
`hint` (where Android carries an editable field's name — the device's own
Settings search box also reads `desc=null hint="Cerca"`) and no
`stateDescription`; and reporting unnamed *leaves* discards the container that
Flutter's bridge actually puts the name on.

Use `example/android/app/src/androidTest/.../AccessibilityDumpTest.java`, which
reads the node info directly and navigates by accessibility actions rather than
injected touches. The `uiautomator`-based scripts that produced the false
positives have been deleted rather than annotated.

**Verified working on hardware:** interactive state (`ItCheckbox`, `ItToggle`,
`ItRadio` all flip `checked`; radio names carry position), modal isolation (the
page behind an open `ItModal` leaves the tree entirely, and barrier and close
button announce differently), §1.4.4 at 200% text with no overflow on any page,
and §2.5.8 target sizes.

**Still unverified on Android:** whether announcements are intelligible,
correctly ordered or bearable; §4.1.3 status messages.

### Device sweep: iOS accessibility tree

Swept on an iPhone 16 **simulator**, iOS 18.5, 16 August 2026, reading the tree
through `idb ui describe-all`. **No accessible-name failures found — 27 of 27
pages, zero unnamed interactive elements.** The probe was verified by planting
`label: null` on `ItChip`'s dismiss button and confirming it reported 16 unnamed
buttons, then 0 once restored.

Better than Android in one respect: text fields are named directly in `AXLabel`,
so the `setHintText()` indirection that produced three false Android findings
does not arise. Modal isolation holds identically — an open `ItModal` leaves 7
nodes and the page behind it is gone.

**Three states the iOS engine drops**, all verified against the engine source
shipped with Flutter 3.44.4 rather than inferred, and none of them defects in
this package — the Dart side sets all three correctly:

| State | Why it is lost |
|---|---|
| Tab role | `SemanticsRole` appears **zero** times in the iOS embedder (Android's bridge refers to roles in four places). Tabs arrive as `AXGenericElement` with an empty role description |
| Accordion expansion | The iOS embedder has no expansion handling at all; Android's calls `setExpandedState()`. A header announces the same open or shut |
| Mixed checkbox | Checked/toggled nodes are backed by a real `UISwitch` whose `on` is `isChecked == kTrue`, so `kMixed` collapses to **off** and reads as unchecked |

**One finding that was ours, since fixed:** `ItRadio` set `checked:` but never
`selected:`, and on iOS mutually-exclusive nodes get no value by design
(`SemanticsObject.mm:622`, *"iOS does not announce values of native radio
buttons"*), which left `UIAccessibilityTraitSelected` as the only channel for
which option is chosen and nothing setting it.

Now set on iOS and macOS only — Android maps the flag to `setSelected` *and*
fires `TYPE_VIEW_SELECTED` on top of the checked state it already carries, and
the web engine skips `aria-selected` on checkables by design. The unselected
options additionally carry `ItLocalizations.radioUnselected`, because the trait
marks only the chosen one and without it an unselected radio is announced
exactly like one whose state is missing. This mirrors Flutter's own `RawRadio`.

Confirmed on the simulator: unselected radios now report
`help="Non selezionato"` and the chosen one reports none, so the two are
distinguishable in the tree, which they were not before. The trait itself is
still unobservable with `idb` and **wants a VoiceOver ear** to judge whether the
result is pleasant to listen to.

**§1.4.4 found one real failure, since fixed.** Driving the scale from iOS
itself — which the Android device's ROM refuses to allow — the Tab page
overflowed at **194%**, inside the range the criterion requires: a vertical tab
bar pinned to `SizedBox(width: 220)` in the example. Re-verified `hazard=0` at
both 194% and 235% after the fix, reading the page to its end.

Worth recording that both *obvious* fixes were wrong, in opposite directions.
Releasing the header's pinned height to a `minHeight` let the band size to its
child and dropped `nav_header_center` from 100% to 66.59% against the React kit;
scaling it with the ambient `TextScaler` is parity-safe because it resolves to
exactly 120 at the default scale. Scaling the *tab* widths — the fix the header
needed — made those six times worse, since 220 at 1.94× is 427pt on a 393pt
screen. Only measuring settled either one.

Swept afterwards across **all 27 pages, each read to its end at 235% (741
screens)**. One overflow remains, on a horizontal text-and-icon tab bar: 10px
per tab at 235%, clean at 194%, so outside the required range. It is in the
component rather than the example, and tab sizing is scored by the visual-parity
harness, so it is recorded as a decision rather than repaired.

The header fix is now a standing test — `test/a11y/text_scale_overflow_test.dart`,
in `tool/mutation_check.sh` — so this defect class is checked on every commit
rather than only when someone runs a simulator.

**Still unverified on iOS:** real Apple hardware; VoiceOver's spoken output;
anything requiring `UIAccessibilityTraits`.

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

A clean-code/API review and an architecture assessment produced a ranked
backlog: remaining defects, a public-API consistency pass, and the standing
guards that stop each class of defect returning. The guards are in the
repository and run in CI — import hygiene, accessibility coverage, the public
API snapshot, the parity hashes and the semantics contracts — and what they
each refuse to let back in is written at the top of the test that enforces it.

The backlog itself is a working document and is not published; what it has
produced so far is in [CHANGELOG.md](../CHANGELOG.md), and what remains
unverified is in this file, above.

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
