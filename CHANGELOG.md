# Changelog

## 0.1.2 — 2026-10-09

### Documentation

- **Minor syntax changes.** 

## 0.1.1 — 2026-10-09

### Fixed

- **An autocomplete's suggestions rendered in the platform font.** The panel is
  an `OverlayEntry`, so it has no Material and no page above it to inherit a
  family from, and it wraps itself in `ItDefaultTextStyle` for exactly that
  reason — but a highlighted row was a `RichText`, which does not read
  `DefaultTextStyle`. Every row matching the query, which is every row since
  `highlightMatch` defaults to true, came out in San Francisco or Roboto under
  a field in Titillium. It is a `Text.rich` now, and
  `test/autocomplete_overlay_font_test.dart` fails if it goes back.

  Found by rendering the README screenshot of an open autocomplete: on a test
  binding "no font family" draws filled boxes, so the suggestions came back
  redacted.

### Added

- **Screenshots**, rendered by the package at a phone's width and shown on
  pub.dev as well as in the README. `tool/screenshots/readme_shots_test.dart`
  regenerates them, so they cannot drift from the widgets they show.

### Documentation

- The README's own inaccuracies, found by rereading it against the code: the
  widget count said 56 where the barrel exports 60; the carousel was listed as
  not implemented two sections after being listed as implemented; a quoted test
  count had drifted; the examples used Material's `Icons.*` in a package whose
  premise is not depending on Material; two Italian strings had lost their
  accents; and the links to files the package deliberately does not ship were
  relative, so they resolved to nothing on pub.dev.

## 0.1.0 — 2026-10-02

First release. Everything below is what the package contains, written as it was
built: the breaking changes are breaks from earlier working versions of this
package, not from a published one.

### Changed — breaking

These are the four API calls Phase 2 recorded as open rather than guessing at.
They are breaking on purpose and they are landing now, before the package is
published: each costs a line or two at a call site today and a major version
after adoption.

- **`ItRadio` takes a `value` and a `groupValue`.** It was
  `ItRadio(value: bool, onChanged: ValueChanged<bool>)`, where `onChanged`
  always emitted `true` — the same value on every call, leaving the caller to
  work out *which* radio had been chosen from which closure had fired. It is
  now `ItRadio<T>(value:, groupValue:, onChanged: ValueChanged<T>)`, the shape
  of Flutter's own `Radio`, and it emits the value that was chosen.

  ```dart
  // before
  ItRadio(value: fase == Fase.preallarme, onChanged: (_) => pick(Fase.preallarme))
  // after
  ItRadio<Fase>(value: Fase.preallarme, groupValue: fase, onChanged: pick)
  ```

  `groupValue` is **required** and nullable: optional, it would let
  `ItRadio(value: true)` keep compiling as an `ItRadio<bool>` that is never
  selected, because nothing equals a `groupValue` of null. A compile error is
  the kinder failure. `ItRadioGroup` is unchanged — it already took
  `value`/`onChanged` of `T` — and `find.byType(ItRadio)` now needs its type
  argument, as `find.byType(Radio<int>)` does.

  `ItCheckbox` and `ItToggle` keep `ValueChanged<bool>`; for them the boolean
  is real.

- **`ItSelect.multiple` is now `ItMultiSelect`.** One widget held both shapes,
  so four of its fields were documented as "always null on the other
  constructor", and `.multiple(onChanged:)` landed on a field called
  `onValuesChanged` — two callbacks of different types cannot share a name.
  The API you read was not the API you wrote.

  ```dart
  // before
  ItSelect<String>.multiple(values: {'RM'}, onChanged: (values) {})
  // after
  ItMultiSelect<String>(values: {'RM'}, onChanged: (values) {})
  ```

  `values` + `onChanged` is exactly `ItCheckboxGroup`'s shape. The form hooks
  stay single-selection only, for the reason they always were: a
  `FormFieldValidator<T>` cannot say anything about a `Set<T>`.

### Fixed — accessibility and fidelity

- **`ItValidationState.warning` no longer tints a checkbox, radio or toggle.**
  `.form-check-input` declares `.is-valid` and `.is-invalid` only — border,
  checked fill, focus ring, label colour — and the single warning rule in the
  form family, `.warning-feedback`, styles the *message*, under a
  `.form-control` at that. The amber box was applied by analogy with the other
  two states and was the one validation colour in the package that no rule
  asked for. The message still carries it; `ItInput` is untouched, being a
  different family of rules.

- **A group announces its error once, instead of once per option.** With three
  radios and one message, a screen reader heard "non valido" four times: each
  option carried the invalid state as well as the group. The options keep the
  *tint*, because `.is-invalid` sits on each input in the markup; the state now
  stays on the group's node, which is where the message already was.

- **A group given only an `errorText` now tints its options.** It printed the
  message and drew every box as if nothing were wrong, because only an explicit
  `validationState` reached them. An error message is a validation state.

### Added

- **`ItDateField` — the datepicker and hourpicker.** Upstream's are plain form
  controls: read back from design-react-kit in Chromium, the whole of the
  markup is `<input type="date" class="form-control">`, with no panel and no
  rules of its own. The browser supplies the picker, and the browser's picker is
  the operating system's. So this is an `ItInput` whose value is chosen in the
  *platform's* picker — Cupertino's wheel on iOS and macOS, the OS's dialogs
  elsewhere — rather than a calendar this package draws, which would have no
  upstream to be faithful to and would be invented pixel by pixel.

  `mode` asks for a day, a time, or both. The field is read-only and opens on a
  tap; beside it sits a named calendar (or clock) button, because a picker
  reachable only by tapping a field is not reachable at all without a pointer —
  `test/a11y/date_field_semantics_test.dart` tabs to it and fails if it cannot.
  Values read `10/09/2026`, `18:57`, the format upstream shows in its own
  placeholder. The Material import is declared in the import-hygiene allow-list
  with its reason, as the one-Material-widget rule requires.

- **`ItDivider`.** `.divider { height:1px; background:hsl(210,4%,78%); margin:8px 0 }`
  — the stylesheet's rule, not Material's `Divider`, which is 16px tall and
  takes its colour from the Material theme, so a page mixing the two draws two
  different lines. Decorative, and excluded from the semantics tree.

- **`ItInput.onTap`.** How a read-only field opens something; mirrors
  `TextField.onTap`. `ItDateField` is built on it.

- **`chooseDate`, `chooseTime` and `confirmPick`** in `ItLocalizations`, in all
  four locales — the picker button's name and the iOS wheel's confirm button.

- **`validator` / `onSaved` / `autovalidateMode` on `ItInput`, `ItSelect`,
  `ItCheckbox`, `ItRadio` and `ItToggle`.** Each now participates in an
  enclosing `Form`, as `TextFormField` does.

  This closes a **silent** failure rather than adding a convenience. `ItInput`
  is not a `FormField`, so replacing a `TextFormField` with it compiled
  cleanly, passed analysis, and quietly stopped `Form.validate()` from ever
  calling the validator — the form just submitted. Trialling the kit in a real
  application hit it three times in one afternoon: a shared text-field wrapper,
  a description field, and a password field that lost `onSaved` too.

  The wrapper is opt-in: with no `validator` and no `onSaved` the widget tree
  is unchanged, so nothing about existing usage or the parity captures moves.
  An explicit `errorText` still wins over a validator message, so a
  server-side rejection is not overwritten by a local rule. The validator is
  handed the *controller's* text rather than the `FormField`'s own copy,
  because callers set `controller.text` directly and the two otherwise
  diverge.

  `ItSelect`'s hooks are single-selection only: a `FormFieldValidator<T>`
  cannot say anything useful about a `Set<T>`, so `ItSelect.multiple` does not
  accept them rather than accepting them and doing something arbitrary.

  Covered by `test/a11y/form_participation_test.dart` — 13 tests — and guarded
  per control in `tool/mutation_check.sh` (`formfield-input`,
  `formfield-select`, `formfield-checkbox`, `formfield-radio`,
  `formfield-toggle`). One guard each, not one for the group: they are five
  separate implementations of the same opt-in, and a single guard watching
  `ItInput` would let the other four rot silently.

- **`ItLocalizations.english`**, deliberately not registered: `en` stays out of
  `supportedLocales` because `MaterialApp` defaults to `en-US`, and bundling it
  would switch every unconfigured Italian app to English accessible names. Opt
  in through `ItLocalizationsDelegate.resolve`.

- **`ItLocalizations.radioUnselected`** (`Non selezionato` / `Nicht ausgewählt`
  / `Non sélectionné`), used by the fix below.

- **`ItNotification.show` now forwards `onDismissed`.** The widget has always
  carried the callback; `show` consumed it to remove the overlay entry and gave
  callers no way to learn the notification had gone — which is exactly what an
  app replacing `ScaffoldMessenger.showSnackBar(...).closed` needs, since that
  future is awaited.

- **`ItNavHeader` names its navigation landmark by default.** It passed a
  nullable `semanticsLabel` straight through, so a page carrying it plus any
  other navigation landmark — a breadcrumb, a bottom bar — ended up with
  landmarks a screen-reader user cannot tell apart, and Flutter asserts on it
  in debug: *"The navigation landmark role should have a unique label as it is
  used more than once."* The default is the new
  `ItLocalizations.mainNavigation`; passing `semanticsLabel` still overrides it.

  Only a debug build on a device could see this. A release web build compiles
  the assertion out, and no widget test could produce it, because they mount
  one component at a time and a single unnamed landmark is well-formed.

- **`ItLocalizations.mainNavigation`** (`Navigazione principale` /
  `Main navigation` / `Hauptnavigation` / `Navigation principale`).

- **`ItTabBar` tabs no longer contain a second, unnamed control.** Each tab's
  `ItActivatable` published its own focusable, tappable node inside the tab's
  `Semantics`, so assistive technology met an unnamed button in every tab
  (WCAG 4.1.2). Found by running the package in a real browser — axe reported
  `nested-interactive` and `aria-command-name` — and invisible to the widget
  tests, which all asserted the tab node's own properties.

- **`ItCenterHeader` is responsive.** `.it-header-center-wrapper`'s 120px band,
  82px logo and 1.75rem title all live inside `@media (min-width: 992px)`; the
  base rule is an 80px band with a 48px logo and a 1.25rem title. The component
  painted the desktop set at every width, so a phone got the desktop header in
  a phone-width box — overflowing by 19px at 390 and 360. Below `lg` the band
  is now a minimum rather than a fixed height, so a title that wraps has room;
  at `lg` and up it stays pinned, which is what the parity captures measure.

- **`ItCard.titleVisualLevel`** — how large the title is *drawn*, 1–6,
  mirroring Bootstrap Italia's `.h1`…`.h6`. Separate from
  [ItCard.titleHeadingLevel] because the kit separates them: `.it-card-title`
  declares **no** font-size at all, taking it from whichever heading the markup
  uses, and `.h1`…`.h6` exist so a level-3 heading can be drawn at h5's size.
  Defaults to 3, the 2rem/2.5rem the widget already painted, so nothing
  existing moves — but at h3 a card titled "Soluzioni Abitative di Emergenza
  attive" fills three lines of 32px type.

- **`ItCard.titleLeading`** — a widget at the start of the title row.
  `.it-card-title.it-card-title-icon` is `display:flex; flex-direction:row`,
  and Bootstrap Italia reorders its contents where it wants a glyph first
  (`.it-card-banner-icon-wrapper { order: -1 }`); the kit's card examples put
  the glyph trailing, which is `titleIcon`. This is the same row used the other
  way. A `Widget` rather than an `IconData`, because what needed it was a
  per-document-type raster.

- **`ItBottomNav`'s active rule is one sliding marker, not one per item.**
  Reported from a device: the rule measured 32px over "Crea" and 50.7px over
  "Da Evadere", because it spanned the item and an item is as wide as its
  label; and it shared a top edge with the icon, so it painted across the glyph
  instead of above it.

  Items are now equal width, the bar draws a single rule of
  [ItBottomNav.activeRuleWidth] (the icon box), [ItBottomNav.activeRuleGap]
  clear of the content, and it slides between destinations over
  [ItBottomNav.activeRuleDuration]. A per-item rule cannot animate between
  items, so the restructuring is what the animation required. The slide is
  skipped under `MediaQuery.disableAnimations` (WCAG 2.3.3).

- **`ItBottomNav` marks the active item with a rule as well as a colour.**
  Upstream the active state is `color: #06c` and nothing else, which is a WCAG
  1.4.1 weakness for any palette and a failure for a brand near the inactive
  colour — 1.18:1 against one real PA palette. The 3px rule, its transparent
  reservation on inactive items, and its placement on the top edge are all the
  kit's own `.nav-tabs` idiom. See doc/conformance.md.

- **Three components the kit was missing: `ItBottomNav`, `ItSidebar` and
  `ItOffcanvas`.** All three are ports, not inventions — `BottomNav` and
  `Sidebar` are exported by `design-react-kit`, and `offcanvas` is one of the
  distribution's plugins.

  `ItBottomNav` is `.bottom-nav`: a fixed row of destinations with an optional
  numeric badge or alert dot per item. Each entry is a button carrying
  `selected` and a position (`"2 di 4"`), so a screen-reader user is told both
  which destination they are on and how many there are.

  `ItSidebar` is `.sidebar-wrapper`, the panel a link list sits in. Its
  heading is uppercased for display only — upstream does it in CSS, so the
  accessible name keeps its original casing rather than being spelled out.

  `ItOffcanvas` is the sliding panel, and the replacement for Material's
  `Drawer`. It is imperative (`ItOffcanvas.show`) because the panel is a
  *route*: that is what supplies the focus trap, the Escape key and a back
  gesture that closes the panel rather than leaving the app. Placement is
  `start`/`end` rather than left/right, following Bootstrap, so it is correct
  under RTL. A non-dismissible panel with no close button and no declared
  close action is asserted against instead of shipped — it is a keyboard trap
  (WCAG 2.1.2) that is easier to write by accident than to notice.

- **`ItCarousel`** — a port of `design-react-kit`'s `Carousel`, which is itself
  a Splide wrapper. What belongs to Bootstrap Italia is the pagination and the
  track, so those are reproduced from the CSS; the arrows use the kit's own
  controls rather than an invented appearance for something the design system
  never styles.

  Callers pick one of the six upstream presets (`ItCarouselType`) instead of
  assembling a layout by hand, which is how upstream works — `CONFIGS` in
  `Carousel.tsx` supplies `perPage`, `gap`, `padding` and `arrows` per
  breakpoint. `ItCarousel.configFor` exposes that resolution so it can be
  tested without rendering: Splide breakpoints are **max-width**, and reading
  them the other way inverts every preset while still looking plausible.

  Autoplay is off by default, as upstream. Turning it on adds a pause control
  that is mandatory rather than optional — moving content lasting more than
  five seconds must be pausable (WCAG 2.2.2) — and any interaction stops it
  permanently rather than merely delaying the next jump.

- **Seven `ItLocalizations` strings for the carousel** (`carousel`,
  `previousSlide`, `nextSlide`, `goToSlide`, `playCarousel`, `pauseCarousel`,
  `slideLabel`), carried over verbatim from the React kit's own `i18n` block
  rather than re-translated.

- **`ItLocalizations.closePanel`** (`Chiudi pannello` / `Close panel` /
  `Bereich schließen` / `Fermer le panneau`), for the offcanvas header. Kept
  distinct from `closeModal`: a panel is not a dialog, and telling a
  screen-reader user they are closing a dialog they never opened is worse than
  saying nothing.

### Fixed

- **A tappable `ItListItem` no longer swallows what its `trailing` widget
  says.** The row named itself from `title` (plus `subtitle`) and then wrapped
  its whole subtree in `ExcludeSemantics`, so a `leading` or `trailing` widget
  with a name of its own was dropped. The case that found it: a menu entry
  reading "Messaggi" with a red `ItBadge` of unread messages beside it
  announced as "Messaggi" — the count the badge exists to convey was the one
  thing a screen reader never heard. In `.link-list` markup the badge sits
  *inside* the `<a>`, so it is part of the link's accessible name.

  The exclusion is now on the two text nodes the row already speaks for, where
  they sit, instead of on the row; `leading` and `trailing` reach the merge as
  they do in the markup. A decorative chevron still adds nothing, because it
  says nothing about itself — but a bare `Text('3')` there is now announced as
  a bare "3", so give a count a `semanticLabel`.
  (`test/a11y/list_semantics_test.dart`.)

- **Bottom notifications sit above `ItBottomNav`, not over it.** A
  notification lives in the root Overlay and cannot see the page's tab bar, so
  a bottom-placed one covered it for as long as it showed — in a real app, the
  six-second welcome message after login took the tab bar away, where the
  SnackBar it replaced had floated above it. `ItBottomNav` now reports its
  laid-out height (home-indicator inset included) while its page is the
  current route, and bottom placements sit on top of it; on a page pushed over
  it they go back to the screen's edge, and a card already showing moves when
  that happens. With no bar on screen nothing changes. Top placements are
  untouched. `test/notification_above_bottom_nav_test.dart`, which also taps
  the bar while a message is up; and on the device, the app's
  `patrol_test/notification_placement_test.dart`.

- **`ItNotification.show` works from the Navigator's own context.** An
  app-wide messenger has one context to hand — `navigatorKey.currentContext` —
  and it sits *above* the Overlay the Navigator builds, so `Overlay.of` could
  never find it. In a real app every success and error message went through it
  and threw "No Overlay widget found"; a save that had succeeded was reported as
  a failure. `show` now falls back to `Navigator.maybeOf(context)?.overlay`
  (Navigator recognises its own element) and throws a `FlutterError` that says
  what it needs when there is neither. Found by the app's mock-backend smoke
  tests; every test here had passed a context from inside a Scaffold.
  `test/notification_host_test.dart`.

- **Focused `ItInput` and `ItAutocomplete` now look as they do upstream.** The
  port painted `.form-control:focus { box-shadow: 0 0 0 .25rem
  rgba(0,102,204,.25) }` — at first through the whole field (a `BoxShadow`
  under a control with no fill of its own), then, once that was covered, as a
  grey-blue frame. Neither is right, because that rule never wins: Italia
  overrides it with `!important` for both ways focus can arrive, and the
  `track-focus.js` that design-react-kit loads tells them apart. Measured in
  Chromium on the docs' input story:

  | focus from   | box-shadow                         | border-bottom |
  | ------------ | ---------------------------------- | ------------- |
  | mouse, touch | none                               | `#1A1A1A`     |
  | keyboard     | `#fff 0 0 0 2px, #000 0 0 0 5px`   | `#000`        |

  A tapped field now only darkens its border to the text colour; a
  keyboard-focused one gets the kit-wide `ItFocusRing` and a black border.
  Both override the validation colours, which are not `!important`. A click
  with a mouse is treated as a tap, as the next entry describes.

  Reported from a real app, which also showed a thick underline on focus: the
  `TextField` set only `border: InputBorder.none`, which is merely the
  fallback, so `toThemeData()`'s `focusedBorder` was merged in and drawn inside
  the control. Every border state is now pinned.

  None of it was visible to an existing check. The parity captures are taken
  unfocused, and the theming contract asserted that the ring followed primary
  — which it did, faithfully painting a rule the stylesheet discards; that test
  is gone. `test/a11y/form_focus_rendering_test.dart` reads back the rasterised
  pixels at rest, after a tap and after Tab, under two palettes.

- **A control focused by a mouse click no longer shows the keyboard focus
  ring.** Italia's ring is for `:focus:not([data-focus-mouse=true])`, and
  `track-focus.js` sets that attribute on whatever gains focus after a
  `mousedown`. The kit approximated it with `FocusManager.highlightMode`, which
  a touch switches off the keyboard mode but a mouse does not — so on a
  desktop, and on Flutter web with a mouse, anything that takes focus on a
  click (a field clicked into, a select handed focus back after a pick) drew
  the black ring design-react-kit never shows.

  `ItFocusRing` now also classifies each focus as it arrives, by whether the
  last press was a mouse button, and keeps that until focus leaves — as the
  attribute is kept until `focusout`, so typing into a clicked field does not
  give it a ring later; Tab does. Every ring in the kit goes through
  `ItFocusRing`, so this covers them all; `ItInput` and `ItAutocomplete` use
  the same classification for their border colour. Touch and keyboard
  behaviour are unchanged. `test/a11y/focus_modality_test.dart`, run as macOS;
  and in Chromium on the Flutter web build, a real click or tap into a field
  leaves no ring and a `#1A1A1A` border while Tab gives the ring and `#000` —
  the values design-react-kit measures.

- **The focus ring's corners follow CSS.** A spread `box-shadow`'s corner
  radius grows by the spread, but a radius smaller than the spread grows by
  less — and a radius of 0 not at all. The painter stroked each band along a
  path of `radius + inset`, which rounded the ring of every square control
  (fields, selects, cards) to 5px at its outer edge; Chromium draws it square.
  The bands are now filled with the CSS radius and cut out at the control's
  edge. `test/focus_ring_geometry_test.dart` reads the corner pixels back.

- **`ItFormSpacing`** — the two numbers a caller laying out a form needs:
  `groupMarginBottom` (48, reserved automatically below every floating-label
  control) and `floatingLabelHeadroom` (33.15, which the caller must leave
  above the *first* field, because `.form-group` sets `margin-top: 0` and that
  space belongs to whatever is above it). `ItFormMetrics` records all 41 form
  measurements and stays internal; these two are the ones a caller cannot do
  without — a real form was found painting a label over its own section
  heading by 17.25px for want of the number.

- **Stacked form fields no longer overlap.** `.form-group` carries
  `margin-bottom: 3rem`, and that 48px is not decoration: a floating label is
  `position: absolute; top: 0` inside the group and rises 33.15px on activation
  — clear of its own box, unclipped. What stops it landing on the field above
  is the 48px the previous group leaves behind, and 48 > 33.15. The port had
  the label offset and not the margin, so `Specificare altro` was painted
  through the value of the select above it. Reported twice from the same real
  form.

  `ItInput`, `ItSelect` and `ItAutocomplete` now reserve it, controlled by a
  new `groupMargin` (default true). Turning it off is right for a field that is
  last in its container, or where the layout supplies its own spacing.

  Two consequences worth stating. The margin is part of the widget's box, so
  the widget's **centre is below the control** — anything targeting
  `find.byType(ItInput)` by centre must target the control instead. And the
  *first* field's label still rises above its own box: `.form-group` sets
  `margin-top: 0`, so upstream expects the page to provide that space.

  The visual-parity references cannot see this. They are Playwright element
  screenshots of `.form-group`, and an element's bounding box excludes its own
  margin by definition — rendering the Flutter side with it dropped parity
  73/74 to 62/74, every loss an input, select or autocomplete. The capture job
  now renders `groupMargin: false` so the two sides compare like with like, and
  the margin is covered by a test about the relationship BETWEEN two fields,
  which a single-element screenshot cannot express either.

- **Components anchored to a screen edge now clear the system furniture
  there.** Reported from a real iPhone: `ItBottomNav`'s labels rendered
  underneath the home indicator. The CSS insets these components carry are
  measured from the viewport edge, which on the web is where the page ends —
  on a phone a 34px strip at the bottom belongs to the system.

  `ItBottomNav` grows by `MediaQuery.padding.bottom` and pads only its
  content, so the background still reaches the screen edge while the labels sit
  above the indicator. `ItBackToTop` adds the inset to its `bottom: 16px`
  rather than replacing it, keeping the gap the CSS asks for. `ItNotification`'s
  `topFix`/`bottomFix` stay flush — the squared corners are the point of the
  modifier — but their content is padded clear; `bottomFix` was clearing an
  iPhone's indicator by 3px of incidental card padding.

  Nothing moves without insets, so the parity captures are untouched.

- **Every pushed route and overlay entry underlined its text.**
  `DefaultTextStyle.fallback` is not styleless — it carries
  `decoration: underline` with a yellow double rule, the framework's signal
  that text has no `Material` ancestor. `ItDefaultTextStyle` merges rather than
  replaces, and never set `decoration`, so the underline survived into the
  modal header, the offcanvas and the megamenu panel in every real app.

  It went unseen because the visual-parity harness renders each component
  inside a `Material`, where the fallback is never reached. Only rendering a
  real route showed it. Parity is unmoved.

- **`ItCarousel`'s pagination dots were invisible.** They were built from an
  icon-only button with `iconSize: 0`, on the assumption that the button paints
  its own background the way `.splide__pagination button` does. It does not.
  The dot is now the painted element it is upstream. Every semantic test passed
  throughout — they check the accessible name, not the paint.

- **A carousel with a single slide lost its pagination dot.** The component's
  `Semantics(container: true)` carried no `explicitChildNodes`, so the dot
  merged into the region's own "Carosello" node and stopped existing as a
  target (WCAG 4.1.2). Three slides kept their nodes because the scrollable
  between them broke the merge, so the defect appeared at one item count and
  not another.

- **`ItOffcanvas` renders its header.** `.offcanvas-header` is
  `display: flex` on a plain `.offcanvas` — it is hidden only inside
  `.navbar-expand*` and the responsive `.offcanvas-{bp}` variants. The panel
  was setting `title` as a route name only, so the heading was announced but
  never painted and there was no visible way out at all: a pointer user had to
  guess that tapping the dimmed area closed it. The body also now scrolls
  (`.offcanvas-body { overflow-y: auto }`), which is what keeps a panel usable
  once its content outgrows a short viewport.

  Found while adopting the component, not by the test suite — the assertion
  that a title is announced passed either way.

- **`ItRadio` now reports its selected state on iOS and macOS.** Those
  platforms give a mutually-exclusive node no value at all, so `checked:`
  reached nothing and VoiceOver never said which option was chosen. `selected:`
  is now set there — and only there, since Android already carries the state
  through `checked` and would announce it twice. Unselected options carry a
  hint, because the trait marks only the chosen one.

- **`ItCenterHeader` no longer clips its own tag line.** The band was pinned to
  a flat 120px (104 small); at 194% text — inside the range WCAG 2.2 §1.4.4
  requires — the subtitle was cut off. The height now scales with the ambient
  `TextScaler`, which resolves to exactly 120/104 at the default scale and so
  leaves the visual-parity captures untouched.

### Changed — internal

- `tool/visual_parity/playwright/states.json` named three design-react-kit
  stories that no longer exist (`checkbox`, `toggles` and `input`
  `--esempio-interattivo`). They now name the stories `components/forms.json`
  captures the same keys from; all 55 story ids the harness references are
  live. Nothing currently reads those two fields — `capture_flutter_web.mjs`
  drives the Flutter side only — so no capture changed.

- **The `.btn-close` control moved out of `ItModal`** into
  `src/components/common/it_close_button.dart`, so the modal and the offcanvas
  share one implementation rather than two. Its accessible name is now a
  required parameter instead of hard-coded to `closeModal`. Behaviour is
  unchanged; the modal's tests pass untouched.


## Unreleased

Not published. See `doc/conformance.md` for verification status.

### Fixed — accessibility (WCAG 2.2 AA)

Form controls had **no screen-reader support**. An earlier pass chasing pixel
fidelity replaced Material `Checkbox`/`Switch`/`Radio` and decorated `TextField`
with hand-painted `GestureDetector`s, silently dropping everything those widgets
provide: checked/toggled state, focus, keyboard activation and hit-target
expansion. A blind user could not tell whether a checkbox was checked.

- `ItCheckbox`, `ItToggle`, `ItRadio` — expose checked/toggled state and
  mutually-exclusive grouping (4.1.2); operable by Space, and by arrow keys
  within a radio group (2.1.1)
- `ItInput` — produced an *empty* semantics tree; label now programmatically
  associated, with error and required state exposed (1.3.1, 3.3.1, 3.3.2)
- `ItSelect`, `ItAutocomplete` — name, value and expanded state; full keyboard
  operation with focus restored on dismiss (2.1.1, 2.1.2)
- `ItModal` — dialog role and accessible name, focus moves in and returns to the
  trigger, background hidden from assistive tech (2.4.3, 4.1.2)
- `ItDropdown` — expanded state, arrow-key navigation, Esc/Tab close; disabled
  items previously vanished from the semantics tree entirely
- `ItNotification` — announced as a live region without stealing focus (4.1.3)
- Headers, footer, breadcrumb, megamenu — landmark roles, heading levels, link
  roles, current-page state (1.3.1, 2.4.4, 2.4.8)
- `ItAccordion`, `ItTabBar` — expanded state, tab/tabpanel roles, arrow-key
  navigation per ARIA authoring practices
- `ItCard`/`ItList` — a tappable card is now one focusable control with one
  accessible name instead of several separately focusable nodes (2.4.3)
- New `ItSkiplinks` (2.4.1). Note the CSS `left: -9999px` idiom does **not** port:
  Flutter culls semantics for off-screen render objects, so an off-screen
  skiplink is invisible *and* inert
- Focus indicators restored across all interactive components, using Bootstrap
  Italia's own `box-shadow: 0 0 0 2px #fff, 0 0 0 5px #000`
- Minimum 24x24 hit targets verified by hit-region probes (2.5.8, new in WCAG 2.2)

### Fixed — visual fidelity

- **Interaction states were inverted.** Material paints hover/pressed as a
  translucent overlay — lighter on a filled control, darker on a white one —
  while Bootstrap Italia shades toward black or, more often, leaves the fill
  alone and signals state on the text. Every interactive component corrected
  against the live design system's computed styles.
- **`letterSpacing` leaked into every `Text`.** `ThemeData(textTheme:)` merges
  onto Material's defaults, so `bodyMedium` inherited 0.25px of tracking —
  roughly 10px of phantom width on a 39-character line.
- **Custom `TextStyle`s dropped the font**, rendering text as missing-glyph
  boxes: `ButtonStyle.textStyle` and bare `DefaultTextStyle` both *replace*
  rather than merge the ambient style.
- `ItAlert` was a Bootstrap 5 tinted panel; Bootstrap Italia alerts are white
  with a 1px neutral border and an 8px coloured left border.
- `ItCallout` was a tinted panel with a 4px left border; it is a 2px bordered
  box with no fill and a Lora body.
- `ItChip`, `ItBadge`, `ItCard`, `ItAccordion`, `ItTabBar`, `ItList`, `ItSelect`,
  and the header/footer/breadcrumb/megamenu family corrected against the CSS.
- Removed Material's ripple (`splashFactory: NoSplash`) — not part of the design
  language, and it loaded a shader asset that broke unrelated tests.

### Fixed — correctness

- `ItInput` never listened to its `TextEditingController`, so anything driven by
  field content silently failed to update
- `ItAutocomplete`'s keyboard handling was dead code — its `FocusNode` was
  recreated every rebuild and never focused
- `ItHeader(sticky: true)` threw at runtime wherever it was placed (it returned a
  sliver from a box-context `build`). The flag is deprecated and ignored; new
  `ItSliverHeader` works inside a `CustomScrollView`.
- Disabled controls dimmed the whole row to 50% opacity; Bootstrap Italia sets
  `opacity: 1` and recolours only the control

### Changed — form API (breaking)

The six form controls did not agree with each other. Nobody depends on this
package yet, so these are straight renames with no deprecation shims.

- **One polarity: `enabled`.** `ItCheckbox`, `ItRadio`, `ItToggle` and
  `ItSelect` took `disabled: false` while `ItInput` and `ItAutocomplete` took
  `enabled: true` — so two text fields in the same form read in opposite
  directions. All six now take `enabled: true`, as do `ItCheckboxOption`,
  `ItRadioOption` and `ItSelectItem`.
- **`ItRadio` is driven like its siblings.** `selected:`/`onTap:
  VoidCallback` become `value:`/`onChanged: ValueChanged<bool>`, so one piece of
  caller code now works for the checkbox, the radio and the toggle. `onChanged`
  always emits `true`: activating a checked radio cannot clear it, exactly as
  HTML fires no `change` for that click.
- **`ItCheckbox.onChanged` is `ValueChanged<bool>`**, not `ValueChanged<bool?>`.
  The nullable form was left behind by the deleted `tristate` flag and forced
  every caller to handle a null that `value: bool` made impossible.
  `indeterminate` is unchanged — it is caller-driven `input.semi-checked`
  display state, not a third stop in a cycle.
- **`ItSelect(multiple: true)` is now `ItSelect.multiple(…)`.** The flag-gated
  version took `value`, `values`, `onChanged` and `onMultiChanged` together, so
  `ItSelect(multiple: true, onChanged: …)` compiled, ran, and **silently never
  fired** — the multi path only ever called `onMultiChanged`. Each constructor
  now exposes one selection and one `onChanged`, which makes that combination a
  compile error rather than a form that does nothing. Same shape as
  `ItCheckboxGroup`, which solved it first.
- **`ItAutocomplete.big` is now `large`**, matching `ItButtonSize.large`.

### Changed — component API (breaking)

One concept, one name. None of these change behaviour: all 73 visual-parity
captures are byte-identical across the rename.

- **Size steps are spelled out.** `ItButtonSize`, `ItIconSize`, `ItModalSize`
  and `ItSpinnerSize` moved from the CSS suffixes `xs`/`sm`/`md`/`lg`/`xl` to
  `extraSmall`/`small`/`medium`/`large`/`extraLarge`. `ItChip.large` and
  `ItAutocomplete.large` already spelled it out, so "one size up" had three
  spellings across the package; the enums were the odd ones out, not the
  booleans. The `.btn-lg` / `.modal-xl` class names remain in the doc comments
  beside the metrics they justify, which is where a CSS suffix is evidence
  rather than an identifier.

- **`onDismiss` means "please dismiss"; `onDismissed` means "it is gone".**
  The two were used interchangeably, which mattered because they are not the
  same event. The rule follows Bootstrap's own pairs — `hide.bs.*` fires before
  the fact, `hidden.bs.*` after.
  - `ItChip.onDismissed` is now **`onDismiss`**: the chip never removed itself,
    so this was always a request.
  - `ItNotification.onDismissed` is unchanged: it fires after the exit
    animation, when the widget has already gone.
  - `ItDropdownMenu.onDismiss` is unchanged: Escape asks the panel's owner to
    close it.
  - **`ItAlert` now has both.** Its single callback silently changed meaning
    depending on whether `visible` was passed — a notification when
    uncontrolled, a request when controlled. A controlled alert now takes
    `onDismiss`, an uncontrolled one `onDismissed`, and an assert catches the
    combination that would otherwise be a silent no-op.

- **The content slot beside a `title` is `body`.** `ItAlert.child`,
  `ItCallout.child`, `ItAccordionItem.child` and `ItNotification.message` are
  now `body`, matching `ItModal.body` and `ItCard.body`. Components whose whole
  output *is* their content keep Flutter's `child`/`children` — `ItButton`,
  `ItBadge`, `ItCollapse`, `ItTabView` and `ItCardBody` are unchanged, because a
  lone child is a different thing from a body that sits next to a title.

- **`ItFooterSocialLink` is deleted; use `ItSocialLink`.** They were
  field-identical. `ItSocialLink` now lives in its own file rather than inside
  `it_center_header.dart`, so neither the header nor the footer has to import
  the other to describe its own socials.

- **`ItNavItem.href` removed.** Never read by anything: the package owns no
  router, so a URL string had nothing to navigate. Callers wire navigation
  through `onTap`. Same reasoning as `ItBreadcrumbItem.href`, removed earlier.

### Added — form API

- **The same validation, help and focus surface on every control.**
  `helperText`, `errorText` and `validationState` now exist on all six (they
  were on one, two and one respectively), and `ItSelect` gained a `focusNode`,
  so a form can finally send the user to the field that failed validation
  (WCAG 3.3.1). `ItRadio` gained `required` and `semanticLabel`;
  `ItCheckboxGroup` and `ItRadioGroup` gained the supporting-text surface too.
  The chrome is factored into one `ItFieldSupport` widget rather than
  copy-pasted six times, and every control carries its instruction and its
  message on its own semantics node instead of leaving them as loose text
  (WCAG 3.3.1 / 3.3.2). Validation tints follow the stylesheet:
  `.form-check-input.is-invalid` for the check controls, `.form-select` and
  `.form-control` for the rest. The toggle's lever is deliberately left alone —
  the kit declares no invalid appearance for it.
- Fixed while adding the above: `ItSelect`'s option list was anchored to the
  control *plus* its feedback line, so an `errorText` pushed the open list a
  line too low.

### Changed

- **All component icons now come from `bootstrap_italia_icons`** rather than
  Material. The two sets were previously mixed — `ItModal` showed an Italia
  close glyph while `ItAlert` and `ItChip` showed a Material one — which was an
  artefact of how the work was split, not a decision. Public `IconData`
  parameters are unchanged, so callers can still pass any icon set.

- **`ItNotification.show` no longer auto-dismisses by default** (was 5 seconds).
  An auto-dismissing toast is a time limit set by content, and none of WCAG
  2.2.1's exceptions (real-time, essential, 20-hour) cover one. Pausing on
  hover/focus and disabling the timer under `accessibleNavigation` help but are
  not sufficient in general — pausing assumes the user notices in time, and the
  accessible-navigation check only helps people who have AT switched on, not
  someone who simply reads slowly. Callers who want auto-dismiss now pass
  `duration:` explicitly and take on the obligation.

- **`ItSpinnerSize` now matches the stylesheet — a breaking visual change.**
  Sizes were `sm(24px, 2px stroke)` / `md(48px, 3px)`; Bootstrap Italia declares
  32 / 48 / 64 / 80 px at a uniform **4px** border that never scales with the
  diameter. `small` is now 32px, `medium` keeps 48px with a 4px ring, and
  `large`/`extraLarge` are new. Verified against the reference: the spinner went
  from 79.65% to 99.99%.
- **A resting `ItSpinner` no longer animates.** `.progress-spinner` is a static
  ring; only `.progress-spinner-active` animates. Previously the controller ran
  unconditionally, so an idle spinner burned a frame every vsync and made
  `pumpAndSettle` hang in any test containing one. It also painted the coloured
  arc when inactive, which read as "mid-spin but frozen".

- Building on `flutter/widgets` rather than `flutter/material`. `ItButton` no
  longer wraps `ElevatedButton`/`OutlinedButton`.
- Removed `alertColorsForVariant` and `calloutColorsForVariant` from
  `BootstrapItaliaColorScheme`: both were unused and encoded the wrong design
- `publish_to: none`, and the `homepage`/`repository` entries removed — they
  pointed at an unrelated 404ing repository

### Added — verification infrastructure

- Visual parity harness comparing every component against the official
  `design-react-kit` Storybook (`tool/visual_parity/`), including a self-test
  that proves the similarity metric still fails real defects
- WCAG 2.2 audit running axe-core against both implementations (`tool/a11y/`)
- CI: format, `analyze --fatal-infos`, tests, `pana`, and the example app
- Font licence texts bundled as required by OFL 1.1 / Apache-2.0, with provenance
  in `NOTICE.md`

## 0.1.0

- Initial release
- 28 MVP components: Button, Badge, Alert, Spinner, Icon, Chip, Card, Accordion, Collapse, TabBar, TabView, List, Callout, Input, Select, Checkbox, CheckboxGroup, RadioGroup, Toggle, Autocomplete, Header (Slim/Center/Nav/Composed), Footer, Breadcrumb, BackToTop, Modal, Dropdown, Notification
- Complete theme system with customizable BootstrapItaliaColorScheme
- Design tokens: colors, typography, spacing, breakpoints, shadows, borders
- Responsive utilities: ItResponsiveBuilder, ItContainer, context extensions
- Bundled fonts: TitilliumWeb, Lora, RobotoMono
- Example catalog app with 23 component showcase pages
- 170+ widget tests
