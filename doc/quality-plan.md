# Quality plan

Consolidates a clean-code/API review, an architecture assessment, and defects
found while building the verification harness. Ordered so that each phase makes
the next one safe, not by severity alone.

Two rules run through it:

1. **Every fix lands with a guard.** A defect that can silently return is not
   fixed. Several bugs here survived precisely because a test existed and was
   too weak — the font-family guard used `contains()` where it needed equality,
   and the parity captures render inside a `Material` that masks font loss.
2. **Breaking changes go early.** Nobody depends on this package yet. Renaming
   `ItRadio.selected` today costs nothing; after adoption it costs everyone.

---

## What is already sound

Worth stating, because it constrains what should change.

- **Layering is clean.** `tokens/`, `theme/`, `a11y/`, `utilities/` contain zero
  imports of `components/` or `form/`. No cycles, no upward dependencies. The
  layering problem in this package is *bypass* (components hardcoding values),
  never *inversion*.
- **The accessibility contracts are real tests**, asserting behaviour (activates
  on Space, traversal skips a disabled control, the ring paints only after focus)
  rather than tree shape.
- **Comments explain WHY and cite the stylesheet**, frequently with measurements.
  This is the codebase's strongest asset and should not be diluted.
- **`ItInput`'s controller/focus-node ownership** is correct: it re-listens on
  swap and disposes only what it created.

---

## Phase 0 — done

- `BootstrapItaliaFontFamily.package` corrected after the package rename. Every
  bundled font was falling back to the platform font in consuming apps.
- The two tests that masked it: the test harness registered fonts under the same
  stale name, and the guard used `contains()`.
- Theming contract restored for `ItList`, `ItAccordion`, `ItTabBar`,
  `ItBreadcrumb`, with `test/theming_contract_test.dart` as the guard.

---

## Phase 1 — Correctness — **done**

All five items landed with guards. Test count 475 → 499; parity held at 72/73.

| # | What shipped | Guard |
|---|---|---|
| 1.1 | `ItSpinner.active` split into `animating` (default true) and `doubleRing`. The ordinary animating single spinner was previously unreachable through the public API. | Two contracts: the default spins; a resting spinner schedules no frames. |
| 1.2 | `ItChip`'s dismiss control moved out of the body's `ExcludeSemantics` into a sibling node with `Semantics(button:, label:)` + `ItActivatable` + `dismissLabel`. | Two contracts: named, focusable, Enter-activates. |
| 1.3 | `ItCard` could render a focusable button with an empty name (`body:` + `onTap:` is legal and the body was excluded). Now: `semanticLabel` override, else the string slots, else the merged descendants; and an assert for the one case that provably cannot be named — an image-only tappable card. | Eight contracts, one per constructor shape, plus the assert. |
| 1.4 | `ItCheckbox.tristate` **deleted**. It never emitted `null` and could not: the branch was identical to the two-state one and `value` is non-nullable. It also modelled a behaviour Bootstrap Italia does not specify — `input.semi-checked` is a *computed* parent state, which the existing `indeterminate` parameter already covers correctly. The example app's fake tristate was replaced with the real "seleziona tutto" pattern. | The example now demonstrates the supported model; `indeterminate` keeps its `Semantics(mixed:)` contract. |
| 1.5 | Nine files de-hardcoded, plus `card`. | `theming_contract_test.dart` grew from 9 to 22, and now asserts **both** directions. |

### What 1.5 actually turned on

The plan said to check whether the CSS *derives* a value from a token. That test
does not work here, and finding out why changed the job:

    grep -c "var(--bs-primary)"   bootstrap-italia.min.css   ->  0
    grep -c "var(--bs-secondary)" bootstrap-italia.min.css   ->  0

**v2.18.0 resolves every semantic token to a literal at build time.** Component
rules write `hsl(210,100%,40%)` directly and never reference the palette
variable. Applied literally, the original test concludes that nothing is
themable — which would have made `BootstrapItaliaColorScheme` a lie.

The test used instead: **a colour re-themes when it is byte-identical to a
declared palette token AND sits in a role where that token is what is meant.**

The second clause does the real work. `hsl(210,17%,44%)` is declared three times
over — as `--bs-secondary`, `--bs-info` *and* `--bs-gray-secondary`. On a card
date or a resting field border it is the grey; an administration retinting
`secondary` wants its buttons recoloured, not its publication dates. On a
spinner arc, which is the figure's only chromatic element, it is the accent.
Same hex, opposite verdicts.

Three sharper cases worth keeping:

- **`--bs-it-card-link-color` is a decoy.** It resolves to `hsl(210,33%,28%)` and
  governs `.it-card-link` — the *footer* links, not the title anchor, which is
  `#0066CC`. Settled by sampling the reference PNG: 12,974 pixels of exactly
  `rgb(0,102,204)` in the title band.
- **The form error message is not `--bs-danger`.** `--bs-danger` is `#CC334D`;
  Italia overrides the message with a standalone `#D9364F` backing no custom
  property. The field *chrome* beside it **is** the token, so one invalid input
  carries a themed border and a fixed message. Both are now asserted together.
- **`#435A70` is not a shade of `--bs-secondary`.** The compiler emits shades as
  `hsl(H, S, L×k)` *preserving saturation*, and the real `shade(secondary, 20%)`
  = `hsl(210,17%,35.2%)` exists separately in the file. A near-miss on
  saturation is not a shade.

Provenance can also be read off `bootstrap-italia.min.css.map`, which attributes
each declaration to its `.scss` origin. Note dart-sass preserves the *authored*
format, so `hsl()` vs `#06c` distinguishes nothing about token-ness — but a
fractional `rgb(0, 91.8, 183.6)` does mark a *computed* value, which is how the
shade factors were pinned exactly.

### Two fidelity defects the audit exposed (not token questions)

Both were invisible because parity does not cover them.

1. **`ItSkiplinks` rendered the inverse of the design system** — a primary-filled
   bar with the label reversed out in white, where upstream declares
   `.skiplinks { background: hsl(210,62%,97%) }` and `.skiplinks a { color: #06c }`.
   White appears nowhere in the upstream rules. **Fixed**, contrast re-checked at
   5.17:1. It survived because **skiplinks is the only component with no parity
   capture at all** — that capture is still owed.
   Still open: upstream's `ul > li > a { display: block }` stacks multiple links
   vertically and centres them; this port uses a `Row`. Identical for the single
   link real usage has, different for several. Needs the capture, not a guess.
2. **The megamenu link description renders `#1A1A1A`** where
   `.link-list-wrapper ul li a p { color: hsl(210,33%,28%) }` says `#30475F` —
   the same rule `ItList` already implements correctly. Only the megamenu
   *heading* is captured, so the description was never compared. Open.

---

## Phase 1 — original statement

Do these first: they are user-visible defects, and none require an API argument
except `ItSpinner`, which cannot be fixed without one.

| # | Defect | Fix | Guard |
|---|---|---|---|
| 1.1 | `ItSpinner.active` drives **two orthogonal** CSS modifiers (`-active` = animate, `-double` = two rings). So `ItSpinner()` renders a *static* loading indicator, and the ordinary animating single spinner is **unreachable** through the public API. | Split into `animating` and `doubleRing` (or a variant enum). Breaking. | Assert the default animates; assert single+animating is expressible. |
| 1.2 | `ItChip`'s dismiss button is a bare `GestureDetector` inside an `ExcludeSemantics` — pointer-only, announced as nothing. `ItAlert` gets the identical case right three files away. | `Semantics(button:, label:)` + `ItActivatable`, mirroring `ItAlert`. | Extend the a11y contracts: named, focusable, Enter-activates. |
| 1.3 | `ItCard(body: …, onTap: …)` produces a focusable button with an **empty accessible name**; `body`/`category`/`footer` are excluded from both the name and the semantics tree. Same shape in `ItListItem`. | Include text-bearing slots in the name, or assert when it would be empty. | Contract asserting a non-empty name for each constructor shape. |
| 1.4 | `ItCheckbox.tristate` never emits `null` — the branch is identical to the two-state one, and `value` is non-nullable so it could not work. A second parameter, `indeterminate`, is what actually paints the mixed glyph. | Delete `tristate`, or implement it properly with `bool?`. Zero tests today. | Whichever is chosen, test it. |
| 1.5 | Nine files still hardcode theme tokens: `card`, `back_to_top`, `skiplinks`, `progress_spinner`, `megamenu`, `center_header`, `header_glyphs`, `nav_header`, `form_metrics`. | Same treatment as Phase 0 — **and the same discipline**: only values Bootstrap Italia *derives* from a token move to the scheme; values the stylesheet declares in its own right stay literal. | Extend `theming_contract_test.dart` to every component. |

**On 1.5, the trap that matters:** of 16 constants examined in Phase 0, 10 were
tokens and 6 were CSS literals. A find-and-replace on `Color(0xFF0066CC)` would
have been wrong in both directions. Each constant needs its CSS origin checked.

---

## Phase 2 — Public API consistency (breaking; free now)

This is the phase with a deadline. Everything here becomes expensive the moment
someone builds a service on this package.

**2.1 Pick one polarity.** `ItInput`/`ItAutocomplete` take `enabled: true`;
eight other components take `disabled: false`. Two text fields in one form take
opposite polarity. Flutter's convention is `enabled`.

**2.2 Make the three form controls agree.**

| | state | change callback |
|---|---|---|
| `ItToggle` | `value: bool` | `onChanged: ValueChanged<bool>` |
| `ItCheckbox` | `value: bool` | `onChanged: ValueChanged<bool?>` |
| `ItRadio` | `selected: bool` | `onTap: VoidCallback?` |

`ItRadio` cannot be driven like its siblings. Align on `value`/`onChanged`.

**2.3 Fix `ItSelect`'s four coupled parameters.** `value`/`values`/`onChanged`/
`onMultiChanged` gated by `multiple`. `ItSelect(multiple: true, onChanged: …)`
compiles, runs, and silently never fires. `ItCheckboxGroup` already solves the
same problem with one `ValueChanged<Set<T>>` — the package contradicts itself.

**2.4 Name one concept one way — done.** "One size up" is `large` everywhere:
the four size enums moved off the CSS suffixes to
`extraSmall`/`small`/`medium`/`large`/`extraLarge`, joining the booleans that
already spelled it out. `onDismiss` is now reserved for a request and
`onDismissed` for a notification, after Bootstrap's own `hide.bs.*` /
`hidden.bs.*` pairing — which meant splitting `ItAlert`'s single callback, since
its meaning flipped depending on whether `visible` was passed. The content slot
that sits beside a `title` is `body` (`ItAlert`, `ItCallout`, `ItAccordionItem`,
`ItNotification`); a component whose whole output *is* its content keeps
`child`/`children`, because that is a genuinely different slot.
`ItFooterSocialLink` is deleted in favour of `ItSocialLink`, which moved to its
own file so neither the header nor the footer imports the other. Original text:

**2.4 Name one concept one way.** `big`/`large`/`lg`; `onDismiss`/`onDismissed`
(which also differ in *meaning* — `ItAlert`'s fires after removal, `ItChip`'s is
a request); `child`/`body`/`message`/`children`; `ItSocialLink` and
`ItFooterSocialLink` are field-identical duplicates.

**2.5 Give the form controls the same capabilities.** Only `ItInput` has
`helperText`/`validationState`; `ItSelect` has no `focusNode` and cannot be
programmatically focused; `errorText` is on two of six. A form library whose
controls cannot render validation consistently has failed at its main job.

**2.6 Delete dead API — done.** Removed: `ItBreadcrumbItem.href`,
`ItNavItem.href`, `ItModal.barrierColor` (the *widget* field — it was stored,
passed down and never painted with; the barrier belongs to the route, which
`show()` still colours), `ItFocusRing.inflate`,
`ItButton._buildContent(fontSize:)`, `ItButton._shade` (its CSS derivation
comment moved to the call sites that use the 0.15/0.20/0.30 factors),
`kItNoOverlay`, and the `bootstrap_icons` dependency. Original text:

**2.6 Delete dead API.** `ItBreadcrumbItem.href`, `ItNavItem.href` (zero reads),
`ItModal.barrierColor` (accepted and ignored), `ItFocusRing.inflate` (never
passed), `ItButton._buildContent(fontSize:)` (never read), `ItButton._shade`
(byte-identical duplicate of exported `itShade`), the `bootstrap_icons`
dependency (never imported, forced on every consumer), and the dead `'warning'`
branch in `foregroundForVariant`. Also decide `kItNoOverlay`: zero call sites,
and it commits the public API to a Material shape the package otherwise rejects.

**2.7 Replace stringly-typed dispatch — done.** `forVariant`/`foregroundForVariant`
now take an `ItVariantColor` enum instead of `variant.name`. Each component enum
translates via an exhaustive `.variantColor` extension, so a new variant that
has no colour is a **compile error** rather than a silent primary. The
`_ => primary` fallback is gone, and with it the test that pinned it.
`foregroundForVariant` is likewise exhaustive rather than defaulting to white,
backed by a new test that every variant clears 4.5:1 against its own fill.
Original text:

**2.7 Replace stringly-typed dispatch.** `forVariant(String)` is fed
`variant.name` from four unrelated enums with `_ => primary` swallowing typos, so
a new enum value silently renders as primary.

---

## Phase 2 — what landed, and four calls left open

**2.1 / 2.2 / 2.3 / 2.5 done.** `enabled` is now the single polarity across the
form directory (and on `ItCheckboxOption`, `ItRadioOption`, `ItSelectItem`, which
would otherwise let `ItSelect(enabled: false, items: [ItSelectItem(disabled:
true)])` contradict itself inside one call). `ItRadio` moved to
`value`/`onChanged` so all three controls take the same driver. `ItSelect` split
into `ItSelect(...)` and `ItSelect.multiple(...)`, which makes
`ItSelect(multiple: true, onChanged: ...)` — previously compiling, running, and
silently never firing — a **compile error**, with no assert needed. Validation,
helper text and focus nodes were factored into `it_field_support.dart` rather
than copy-pasted six times; it returns its child untouched when unused, which is
why all 73 captures stayed byte-identical.

A real bug surfaced on the way: `ItSelect` measured its dropdown anchor from the
State's render object, which with `errorText` set includes the feedback line — so
an invalid select opened its option list a line too low.

**Four decisions deliberately left open**, each recorded rather than guessed:

1. **`ItRadio.onChanged` always emits `true`.** Symmetric with its siblings and
   faithful to HTML, where a checked radio fires no `change` — but an unusual
   `ValueChanged<bool>`. The alternative is Flutter's own
   `Radio<T>(value:, groupValue:, onChanged: ValueChanged<T?>)`, which would
   break the three-control symmetry 2.2 asked for. Symmetry won; worth revisiting
   with real users.
2. **`ItValidationState.warning` on the check controls has no CSS basis.**
   Bootstrap declares only `.is-valid`/`.is-invalid` for `.form-check-input`;
   `.warning-feedback` exists for the *message* only. The warning token was
   applied to the chrome by analogy — the one validation colour in the package
   not read directly off a rule.
3. **Groups push `validationState` to every option**, so N option nodes plus the
   group node all report invalid. That matches the markup, where `is-invalid`
   goes on each input, but it is chattier than one message on the group. This is
   exactly the kind of question the contracts cannot answer — see Phase 6.
4. **`ItSelect.multiple`'s field is `onValuesChanged` while its parameter is
   `onChanged`.** Two callbacks cannot share a field because they cannot share a
   type. Call sites read consistently; the field list does not.

Also left alone with reasons, which is the right outcome: `ItInput`'s signature
and `ItToggle`'s `value`/`onChanged` were already correct, `ItCheckbox.indeterminate`
is correct as caller-driven `input.semi-checked`, and the toggle's lever has no
invalid appearance because `.lever` is declared only for `:checked` and
`[disabled]` — inventing one would put a value on screen that no rule asks for.

---

## Phase 3 — Structure — done except 3.5

**3.1 `it_megamenu.dart` split** — 1262 lines into five files (root, panel,
mobile, models, tokens). Five rather than four because
`$megamenu-heading-text-size` sizes both the panel's column headings and the
mobile CTA labels, and Dart privacy gives no way for two libraries to share a
private constant without either duplicating it or routing an import through the
barrel-exported root, which would leak the tokens into the public API. Public
surface unchanged; `nav_megamenu_heading.png` byte-identical.

Reading it closely turned up seven defects, none of them fixed in the move —
a behavioural change hidden inside a move diff is unreviewable. Fixed after:

- **Empty `sections` crashed on mobile only.** `firstWhere(orElse: () =>
  sections.first)` throws `StateError` on an empty list; the desktop path
  degraded silently via `List.generate(0)`. Same input, two behaviours, one a
  crash.
- **No `didUpdateWidget`** — `_openSectionIndex` is an index, so a shorter list
  left it pointing past the end and `sections[_openSectionIndex!]` threw
  `RangeError` on the next build, *while a panel was open*. Same defect class as
  `ItAccordion`'s.
- **The desktop chevron never flipped**, though the kit declares
  `a.dropdown-toggle[aria-expanded=true] > .icon { transform: scaleY(-1) }` and
  the mobile tile already rotated its copy. For a sighted mouse user the only
  signal a section was open was the panel appearing.
- **§2.4.3 focus order** — the panel is a sibling *after* the whole bar, so Tab
  went toggle → every remaining toggle → panel. In the kit the panel is a child
  of its own `li`. Fixed by ordering traversal (`OrderedTraversalPolicy`, the
  panel at `index + 0.5`) rather than by moving the widget, so not a pixel
  changed.
- A dead `colors` parameter, a duplicated comment paragraph, and a separator
  painting `gray200` where the CSS says `hsl(210,4%,78%)` — a documented
  substitution, but the value it substituted matches no palette token, so the
  swap only moved it away from the stylesheet.

Guard: `test/megamenu_robustness_test.dart`. Writing it exposed a *test* bug
worth remembering — setting `MediaQuery(size:)` without `tester.view.physicalSize`
lays the widget out for 1280 on an 800px surface, so the test fails on a
`RenderFlex` overflow rather than on what it meant to check. The same mismatch
once made every parity capture render its mobile layout.

**3.2 Converge on `ItActivatable` — done, and the ADR amended.** The teeth were
real: `ItButton` bound only `ActivateIntent` where `ItActivatable` binds that and
`ButtonActivateIntent`, and which one `WidgetsApp` dispatches varies by platform.
`ItButton` now delegates; `ItActivatable` grew `onHoverChanged` and
`onPressedChanged`, which is what it had been missing and why `ItButton` rolled
its own in the first place. All 74 captures byte-identical.

The remaining nine `FocusableActionDetector` users are now *documented*
exemptions rather than drift — text fields own their own key handling, the check
controls declare explicit `shortcuts:`, the dropdown does arrow-key roving, the
modal owns Escape and the focus trap. The guard,
`test/keyboard_activation_parity_test.dart`, drives every button-like control
with Tab-then-key and asserts **behaviour, not implementation**: a control may
keep its own detector as long as a keyboard user cannot tell.

**3.3 Duplicate colour accessor — done.** `context.itColors` had zero usages and
**threw** where `resolveColorScheme` falls back, so a component rendered outside
the theme worked while a consumer's identical-looking call crashed. It now
delegates to the same function.

**3.4 done** (see below). **3.5** — the scheme did not need to grow during 1.5;
one colour moved into it and no new field was required, so the 17-field shape
stays until something actually forces it.

---

## Phase 3 — original statement

**3.1 Split `it_megamenu.dart` (1262 lines, 2× the next largest).** The seams are
already visible: data models (`ItMegamenuLink`/`Column`/`Cta`/`Section`), the
desktop bar, the panel, the mobile overlay. Four files, no behaviour change.

**3.2 Converge on `ItActivatable`.** ADR 0001 states *"Every control moved off
Material keeps `ItActivatable`"*; eleven files roll their own
`FocusableActionDetector`. **This has teeth:** `ItActivatable` binds both
`ActivateIntent` and `ButtonActivateIntent`; `ItButton` binds only the former, so
keyboard activation differs between the flagship button and every other control.
Either converge, or amend the ADR to say why not.

**3.3 Resolve the duplicate colour accessor.** `resolveColorScheme()` is used in
17 files; the `context.itColors` extension has **zero** usages and throws where
the function falls back. Keep one.

**3.4 Move `test/golden/` to `tool/` — done.** Now
`tool/visual_parity/capture/`, run explicitly with
`flutter test tool/visual_parity/capture`. `flutter test` drops from 558 to 485
and is now entirely assertions; the working tree stays clean unless captures are
asked for. All 73 PNGs verified byte-identical after the move.

Two things the move required. The capture jobs lost `test/`'s
`flutter_test_config.dart`, and with it the **font registration** — without
which every glyph rasterises as a tofu box and every capture scores against the
wrong pixels. Rather than duplicate the font list (it has broken twice already,
once masked by the harness registering a stale package name), it is extracted to
`test/support/parity_fonts.dart` and imported by both configs. And `tool/` is
now covered by `dart format` and `flutter analyze --fatal-infos` in CI, which
immediately surfaced a pre-existing `unnecessary_import` that had never been
analysed.

Original text:

**3.4 Move `test/golden/` to `tool/`.** 73 `testWidgets` with **zero
assertions** — they are capture jobs for the out-of-band SSIM comparison, which
is itself rigorous. But as filed they are ~16% of the suite, cannot fail on a
visual regression, and write into the working tree as a side effect of
`flutter test`.

**3.5 Reconsider `BootstrapItaliaColorScheme`'s shape.** 17 fields, each needing
constructor + `copyWith` + `standard` to extend. Adding a token is a four-place
edit. Only worth doing if Phase 1.5 shows the scheme needs to grow.

---

## Phase 4 — Robustness and developer experience

**4.1 Apply the house assert style evenly — done.** `ItModal.show`'s assert
names the criterion and both fixes; nothing else matched it. Now:

- `ItTabBar` validates what `ItTabView` already did — an out-of-range index used
  to surface as a `RangeError` from inside the framework, naming neither widget
  — plus an empty bar and an all-disabled bar. The last is a §2.1.1 failure:
  traversal skips disabled tabs, so every tab disabled means the tablist is
  reachable by no route at all.
- `ItBackToTop` enforces the `Stack` its own doc comment required. Without one,
  `Positioned` threw a `ParentDataWidget` error naming neither the widget nor
  the fix.
- The six form widgets had **zero** asserts while carrying the most
  misuse-prone parameters. One shared `ItFieldValidation.debugCheckConfig`
  covers the three cases where the widget *renders* and is silently wrong:
  `required` with no label (the state is announced against a name that does not
  exist), no options at all (a group role with nothing operable), and duplicate
  option values (selection matches by value, so one click changes two rows).

Deliberately **not** asserted: `validationState: danger` without `errorText`. It
looks like the same class of bug, but the control still reports
`SemanticsValidationResult.invalid`, so the state reaches AT even when the
description is rendered by a form-level error summary elsewhere. Asserting it
would reject a correct design — `test/misuse_asserts_test.dart` pins that it
does not fire.

Writing the guard also found a test reaching a hover colour through an invalid
state: `ItTabBar(selectedIndex: -1)`. `inTabOrder` follows the selection, so -1
put no tab in the tab order and made the whole tablist keyboard-unreachable. The
test now uses two tabs and hovers the inactive one, which is the real
configuration anyway.

### Original statement

**4.1 Apply the house assert style evenly.** `ItModal.show`'s assert is the best
error message in the package — it names the WCAG criterion and the two fixes.
But there are **zero asserts in any of the six form widgets**, which have the
most misuse-prone parameters. `ItTabView` validates its index; `ItTabBar` does
not. `ItBackToTop` documents "must be inside a Stack" with no assert, so misuse
yields a generic Flutter error that never names the widget.

**4.2 Document or remove two hidden ancestor requirements.** `ItModal.show` calls
`MaterialLocalizations.of` and `ItMegamenu` calls `Navigator.of`, both unguarded
— contradicting the claim that components work without a `Scaffold`. Note that
`no_ambient_material_test.dart` does not currently exercise `ItModal`.

**4.3 Fix two controlled-state bugs.** `ItAlert` sets `_visible = false`
internally with no way for a parent to reset it — the state renders
`SizedBox.shrink()` forever. `ItAccordion` computes expansion in `initState`
with no `didUpdateWidget`, so index-based state goes stale when `items` changes.

**4.4 Decide the localisation strategy — done.** Both shapes, layered: an
`ItLocalizations` delegate carries all 25 strings, and the per-widget parameters
stay, now falling through to it. Reasoning and rejected alternatives in
[ADR 0002](adr/0002-localisation-delegate-with-overrides.md).

It was built, deliberately reverted, and then re-landed on request. The revert is
worth recording rather than erasing, because of what it demonstrated: with the
layer removed, **eleven** accessible names had no override at all — `Apri menu`,
`Chiudi menu`, `Chiudi notifica`, `Menu di navigazione`, `Breadcrumb`,
`Cerca...`, `Chiudi finestra modale`, `Ignora`, `Finestra di dialogo`,
`Ricerca in corso`, `Suggerimenti` — while nine others were overridable per call
site. A German-language service in Bolzano could translate about half of what a
screen reader says and none of the rest. That is the "half-done is the worst
option" case, measured rather than asserted.

- Italian, German and French bundled. **English deliberately is not** —
  `MaterialApp.supportedLocales` defaults to `[Locale('en','US')]`, so bundling
  it would give an unconfigured *Italian* app English accessible names. For the
  same reason `ItLocalizations.of` does not resolve from `Localizations.localeOf`
  when no delegate is installed: no delegate means Italian, full stop.
- `ItModal` no longer touches `MaterialLocalizations`, so it leaves the Material
  allowlist — that was the last *behavioural* Material dependency in the package
  and the 4.2 hidden ancestor requirement. Material imports: **4**, all of them
  text fields plus the theme bridge.
- `breadcrumb` is `'Breadcrumb'` in all three locales, Italian included. Not an
  omission: Bootstrap Italia's own markup is `<nav aria-label="breadcrumb">` on
  an Italian page, as is Bootstrap 5's. Diverging would mean guessing the
  PA-standard German and French wording for a landmark name, in a string that is
  legally binding. It is routed through the table anyway, so an administration
  whose style guide says *"Percorso di navigazione"* can say so.
- Guards: `test/l10n_test.dart` — 33 of them — drives every string through its
  real component under a German delegate, pins the no-ancestor Italian fallback,
  and reads the source to fail on a German or French field that still equals the
  Italian.

Three fixes found while building it were kept through the revert, because none
of them depends on the layer: the `ItSelect(searchable: true)` crash (its search
field sits in an `OverlayEntry`, a sibling of the host `Scaffold`, so nothing
satisfied `debugCheckHasMaterial`), the modal barrier and close button no longer
sharing one name, and the mobile megamenu agreeing with the header toggles.

### Original statement

**4.4 Decide the localisation strategy.** Eight strings are overridable; twelve
are hardcoded Italian with no escape (`'Torna su'`, `'Chiudi finestra modale'`,
`'Apri menu'`, `'%d di %d'`, …). For Italian PA this is not cosmetic: Alto
Adige and Valle d'Aosta carry statutory German and French obligations. Either
add a delegate or make every string overridable — half-done is the worst option.

**4.5 Give `ItNotificationBadge` semantics.** It has none, so `count: 5`
announces a bare "5". In a package where `ItIconAction` makes `label` *required*
on principle, this is the component that most needs a name.

---

## Phase 5 — Documentation truth — **mostly done**

- `ItIcon`'s doc example now names an icon that exists (`it_file`); all 179 are
  `it_`-prefixed and `BootstrapItaliaIcons.document` never was.
- Five Material-icon doc examples migrated to `bootstrap_italia_icons`
  (`it_alert`, `it_chip`, `it_tab_bar`, `it_button`, `it_list`). One remains in
  `it_autocomplete`, in the form directory.
- **Thirteen files** imported `material.dart` while using nothing from it —
  including `it_activatable.dart`, whose own doc explains that it exists to get
  off Material. All now import `widgets.dart`. Switching them surfaced a real
  Material dependency the audit had missed: a `VerticalDivider` in the megamenu.
  It is replaced by its own expansion, deliberately *not* by a `ColoredBox` —
  a childless `Container` grows to its maximum constraint, which under the
  enclosing `IntrinsicHeight` is the row height, whereas a childless
  `ColoredBox` collapses to zero and would have silently vanished.
- Deleting `kItNoOverlay` in 2.6 orphaned its thirteen-line doc comment onto
  `itShade`. Removed. (Found by reading the file, not by any tool — nothing
  flags a doc comment attached to the wrong declaration.)
- `trackDescendants`' doc no longer cites `InkWell` as a live case. The two
  remaining `InkWell` mentions are past-tense rationale explaining why the
  current code is shaped as it is, and were left alone.
- **Counts are no longer quoted anywhere.** README, `conformance.md` and ADR
  0001 disagreed with each other and with reality. A static `testWidgets(` count
  reads ~131 where the runner reports ~167, because this suite generates tests
  in loops — so any hand-copied number is wrong by construction. `tool/status.sh`
  reports them from the runner instead.
- `conformance.md` no longer claims `ItSpinner` lacks captures and contracts; it
  now records `ItSkiplinks` as the component with no capture, and why that
  mattered.

### Original statement

- **`ItIcon`'s flagship doc example does not compile** —
  `BootstrapItaliaIcons.document` does not exist (all 179 icons are `it_`-prefixed).
- **Seven doc examples still use Material icons** after the migration, while the
  CHANGELOG announces that all component icons now come from
  `bootstrap_italia_icons`.
- **Stale comments** about `trackDescendants` existing "because of `InkWell`"
  (there are none left), and an `it_input` comment describing an optimisation
  that was never implemented.
- **Ten files import `package:flutter/material.dart` without using a Material
  symbol** — including `it_activatable.dart`, whose own doc explains that it
  exists to get off Material.
- **Test counts disagree in four documents** (README 427/135, conformance 152,
  ADR 123; actual 471/157). Stop quoting counts, or generate them — a number
  copied by hand into four files will drift again.
- `doc/conformance.md` still lists `ItSpinner` as having no parity captures and
  no a11y contracts; both now exist.

---

## De-Materialisation — finished

ADR 0001's target was `flutter/widgets`. The package is at **four** Material
imports — three text fields and the theme bridge — all of them justified and each named with its reason in
`import_hygiene_test.dart`: three text fields (`TextField` owns IME composition,
selection handles, autofill and the platform text-input channel — reimplementing
it is a worse accessibility outcome than the visual cost) and
`bootstrap_italia_theme_data.dart`, which exists to *be* the Material bridge.
`ItModal` left the list when ADR 0002 replaced its `MaterialLocalizations`
lookup: that was the last *behavioural* Material dependency in the package.

The last eight fell to a question worth recording, because the obvious answer was
wrong. Each held a Material import for `Colors.white` alone, and `--bs-white` is
a real declared token that the scheme exposes — so routing them through
`colors.white` looked like the tidy fix.

It would have been the inverse defect. **The bands those whites sit on are
literals**: the footer is `#004D99`, the slim header `#0059B3`, the dark
breadcrumb `hsl(210,25%,35.2%)` — none of them tokens. A themed foreground on an
unthemed surface is worse than two literals, because retinting would move one
and not the other. So they became `Color(0xFFFFFFFF)`, and the Material import
went with them.

Where the band *is* themed the whites already follow it: `ItNavHeader` and
`ItCenterHeader` sit on `colors.primary`, so their labels resolve
`colors.white` — retinting a band without its foreground is how a themed header
loses its contrast. Same value, opposite verdicts, decided by what the value sits
on rather than what it is.

---

## Phase 6 — The part automation cannot cover

**Real assistive-technology testing** with VoiceOver, TalkBack and NVDA. The
contracts prove a role and a state are *exposed*; they cannot prove the
resulting announcement is intelligible, correctly ordered, or bearable to listen
to. No conformance claim should be made before this pass exists.

That has not changed. What has changed is the cost of doing it.

**`doc/at-testing-protocol.md`** — what to test, on which platforms, what to
record, and what claim may be made afterwards. It also lists what is *already*
checked automatically, so a session is not spent rediscovering unnamed buttons.

**`flutter test tool/a11y/preview`** → `doc/at-announcements.md`, which dumps
every semantics node with a name or role per component, in tree order, plus the
Tab order. Knowing what *should* be said is what makes it possible to notice
what *is*. Tree order and Tab order are computed separately, so a disagreement
between the two lines is a §2.4.3 finding before a screen reader is involved.

**`test/a11y/announcement_quality_test.dart`** takes the mechanical subset off
the reviewer entirely: on realistic *compositions* rather than single widgets,
every interactive node must be named, no two controls on one screen may share a
name, and a named wrapper must not repeat its child.

Writing it found two defects immediately, neither visible to any per-component
contract:

1. **`ItCheckbox`, `ItRadio` and `ItToggle` each emitted an unnamed tappable
   node** nested inside the named control — same rect, no label. Their inner
   `GestureDetector` contributed semantics the enclosing `Semantics(onTap:)`
   already supplied, so a screen reader offered a second, meaningless stop on
   every one of them. Fixed with `excludeFromSemantics: true`; hit testing and
   behaviour unchanged.
2. **Every `ItChip` dismiss button was called "Rimuovi".** A filter bar with
   five chips gave five identically-named buttons, indistinguishable in an
   element list — a user choosing between them is guessing. Now
   `ItLocalizations.removeNamed(label)`, a template rather than a
   concatenation, because German puts the verb last (`"Lazio entfernen"`) and
   joining strings in code would hard-code Italian word order into every other
   language.

Both are the *kind* of defect a screen-reader session finds on its first
minute — which is the argument for the automated subset: a reviewer's time
should go on the four questions in the protocol that only a person can answer.

## Standing guards — all five in place

Fixes decay; guards do not. Each of these turns a class of defect into a test
failure rather than a code review. Every one was verified to fail without the
fix it guards — a guard that has never been seen red is a guess.

1. **No hardcoded theme tokens** — `test/token_hygiene_test.dart`. Reads the
   palette from the tokens themselves so it cannot drift from what it guards.
   The allowlist demands a CSS rule per entry, and a second test fails any entry
   that no longer matches a real literal: a stale exemption silently permits a
   future one.
2. **Import hygiene** — `test/import_hygiene_test.dart`. The analyzer cannot do
   this, because `material.dart` re-exports all of `widgets.dart`, so a file
   using only `Widget` is never an "unused import". Each remaining Material
   import must name the symbol that justifies it.
3. **Public API snapshot** — `test/public_api_snapshot_test.dart` against
   `test/api_snapshot.txt`. Restricted to the 51 files the barrel exports, not
   all 56 in `lib/` — scanning everything listed internal classes no consumer
   can name, 1,635 lines in which a real change would be invisible. A removed
   line is a breaking change; an added line is a new promise.
   `UPDATE_API_SNAPSHOT=1` accepts a change deliberately.
4. **Bare-host rendering** — `test/no_ambient_material_test.dart`, now
   data-driven over twelve text-bearing components rather than three hand-picked
   ones. It asserts the resolved font family, because
   `DefaultTextStyle.fallback()` carries none: a component leaning on an ambient
   `Material` renders in the platform font while looking perfect in the parity
   capture, which supplies a `Material` of its own. Verified by deleting
   `ItChip`'s font family and watching it go red.
5. **A11y contract per component** — `test/a11y_coverage_test.dart`. Adding it
   flagged sixteen components, and the flags were not noise: **`ItActivatable`**
   — the widget supplying focus, keyboard activation and the focus ring to most
   of the package, and the thing ADR 0001 is built around — had been driven
   indirectly by dozens of tests and asserted directly by none. It now has
   contracts, along with `ItIconAction`, `ItBadge` and `ItBackToTop`, in
   `test/a11y/uncovered_components_test.dart`. The rest are exempt with stated
   reasons, and a second test fails any exemption naming a widget that no longer
   exists.

Being named in `test/a11y/` does not prove a component is accessible. But a
component named nowhere has certainly never been checked, and that is worth
failing over.

## Sequencing rationale

Phase 1 before 2 because a broken control should not be renamed while broken.
Phase 2 before 3 because structural moves are cheaper once the surface is
settled. Phase 3 before 4 because asserts should be written against the final
shape. Phase 5 last among code phases because docs describe what the code
finally is. Phase 6 is independent and can start any time — it needs a person,
not a change.

The guards should be added *with* their phase, not afterwards, or they will be
written to pass rather than to catch.
