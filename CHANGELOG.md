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

- Building on `flutter/widgets` rather than `flutter/material` — see
  [ADR 0001](doc/adr/0001-build-on-widgets-not-material.md). `ItButton` no longer
  wraps `ElevatedButton`/`OutlinedButton`.
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
