# bootstrap_italia_flutter

An **unofficial** Flutter port of [Bootstrap Italia](https://github.com/italia/bootstrap-italia)
v2.18.0, the design system for Italian public administration.

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter Platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://flutter.dev)

> **Not official, and not published.** This package is not produced, endorsed or
> maintained by [Developers Italia](https://developers.italia.it) or AgID. It is
> a community port offered as a possible contribution. `publish_to: none` is set,
> so it is not on pub.dev — and the package is deliberately named
> `bootstrap_italia_flutter`, leaving the official `bootstrap_italia` name there
> unclaimed. The suffix marks it as a derivative work rather than the design
> system itself.
>
> **It does not yet carry an accessibility conformance claim.** Accessibility is a
> legal requirement for Italian PA services (Legge 4/2004 and EU Directive
> 2016/2102, via EN 301 549 / WCAG AA). Substantial verification exists — see
> [Accessibility](#accessibility) — but real assistive-technology testing has not
> been done. Read [`doc/conformance.md`](https://github.com/PaoloGi/bootstrap_italia_flutter/blob/main/doc/conformance.md) before using this in
> a public service; it states plainly what is and is not verified.

## Features

- Components matching Bootstrap Italia v2.18.0, with every colour, size, padding
  and border read from its compiled CSS rather than eyeballed
- 56 exported widgets (buttons, alerts, badges, cards, forms, modals,
  dropdowns, notifications, carousels, headers, footers, bottom navigation,
  offcanvas panels, and more) — `grep -c 'extends State' on the barrel's
  exports if you want to check that number rather than trust it
- Theme system with a customisable `BootstrapItaliaColorScheme`
- Responsive utilities (`ItResponsiveBuilder`, `ItContainer`, breakpoint extensions)
- Design tokens (colours, typography, spacing, shadows, borders)
- Bundled fonts (Titillium Web, Lora, Roboto Mono) — offline, no third-party
  requests, which matters for GDPR in PA deployments
- Explicit `Semantics`, keyboard operability and focus indicators on interactive
  widgets, covered by automated contracts in `test/a11y/`
- Web, mobile and desktop

## Accessibility

Verification runs in layers, because no single one is sufficient — and the
device layers exist because the first three agree with each other while the
platform disagrees with all of them:

| Layer | What it catches |
| --- | --- |
| `test/a11y/semantics_contract_test.dart` | Wrong roles and states — e.g. a checkbox exposed as a button, which is *valid* ARIA and so invisible to generic tooling |
| `tool/a11y/axe_audit.mjs` | Standard WCAG violations, run against **both** this package and the official React kit, so an upstream issue is never reported as ours |
| `test/a11y/contrast_audit_test.dart`, `target_size_test.dart` | WCAG 1.4.3 / 1.4.11 contrast and 2.5.8 target size, computed deterministically from tokens |
| `example/android/app/src/androidTest/.../AccessibilityDumpTest.java` | What Android's bridge *actually* publishes, read from `AccessibilityNodeInfo` — the tree TalkBack reads, not the one Flutter believes it built |
| `tool/a11y/ios_ax_probe.sh` | The same for iOS, via `idb`. It is a separate layer because iOS drops state Android carries: tab role, accordion expansion and the mixed checkbox all reach Android and none reach iOS |
| `tool/a11y/ios_text_scale.sh`, `text_scale_probe.sh` | §1.4.4 at OS-driven text scale. This found a real overflow that no unit test could: a pinned width that stops fitting at 194% |

**None of the device layers run in CI**, so their results describe one build on
one day — the device sweeps in [`doc/conformance.md`](https://github.com/PaoloGi/bootstrap_italia_flutter/blob/main/doc/conformance.md)
name the build and the date they were taken on.

Contrast is audited from tokens rather than screenshots because axe-core
**cannot** evaluate contrast on Flutter Web at all — the semantics tree is a
transparent overlay above a canvas, so it returns `incomplete`. A
screenshot-based check would have given false assurance.

Targets WCAG **2.2** AA, since the scheduled EN 301 549 update moves the web
reference from 2.1 to 2.2.

## The example app

`example/` is a catalogue that mirrors the [Bootstrap Italia
documentation](https://italia.github.io/bootstrap-italia/docs/) page by page.
Each component's page follows its documentation page section by section, using
the same Italian headings, with the explanation adapted to this API and the Dart
that produced the example beside it.

That is deliberate: it makes the app a map into the documentation rather than a
gallery, so a developer reading the docs can find the same example here. Where
a section has no meaning in Flutter — hover, JavaScript initialisation — or the
documentation itself advises against the pattern, the page says so and why in a
closing *«Sezioni della documentazione non riprodotte»* section, rather than
leaving a reader to wonder whether it was missed.

```
cd example && flutter run          # or: flutter build web --release
```

Components the package does not implement at all — progress bars, donut
indicators, avatar, carousel, steppers, timeline, rating, pagination — are
recorded as *not implemented*, kept distinct from sections that were skipped.

## Localisation

The package speaks about 25 strings on your behalf, and nearly all of them are
**accessible names** — what a screen reader says instead of "button" for a
control that paints only a glyph. That makes them part of the conformance
surface: §3.1.2 Language of Parts asks that they be spoken in the language of
the page. In Alto Adige/Südtirol German is parified to Italian (D.P.R. 670/1972
art. 99) and in Valle d'Aosta French is (L. cost. 4/1948 art. 38), so for those
administrations this is statutory, not optional.

**Italian, German and French** ship in the package. Install the delegate:

```dart
MaterialApp(
  localizationsDelegates: const [
    ItLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,   // for Flutter's own strings
  ],
  supportedLocales: ItLocalizations.supportedLocales,
  home: MyApp(),
)
```

The delegate is **optional**. Without it every component renders in Italian —
this is an Italian government design system, so a missing delegate means Italian
and not English. Nothing here requires a `Localizations` ancestor, in keeping
with the rest of the kit.

To restyle one string, or to add a locale the package does not bundle:

```dart
ItLocalizationsDelegate(
  resolve: (locale) => switch (locale.languageCode) {
    'it' => ItLocalizations.italian.copyWith(backToTop: "Torna all'inizio"),
    'sl' => ItLocalizations(localeName: 'sl', /* every field is required */),
    _ => null,   // null = use the bundled translation
  },
)
```

Per-widget parameters such as `ItNotificationBadge.semanticLabel` still win over
the delegate. They are for what only the call site knows — *"3 messaggi non
letti"* rather than *"3 notifiche"* — which is the part that actually satisfies
WCAG 4.1.2.

## Shipping to Flutter Web

One caveat that is not the package's but is inherited by every app built on it:
**Flutter's web engine disables pinch-zoom.** It rewrites the viewport meta
after boot, appending `maximum-scale=1.0, user-scalable=no`, and does so even
when `index.html` declares its own. That is a WCAG 1.4.4 failure, and for an
Italian PA service a legal one.

Declaring the meta is not enough — the engine overwrites it. `example/web/index.html`
carries the `MutationObserver` that puts it back; copy it into any web build.

The components are also run **on a device** by
[`example/integration_test/device_soak_test.dart`](example/integration_test/device_soak_test.dart),
which asserts what only hardware can settle — that the package's fonts are
actually loaded, that nothing is drawn inside the system's bottom inset, and
that the whole set survives 200% text at the device's own width.

The components themselves are checked in a real browser by
[`tool/visual_parity/playwright/soak.mjs`](tool/visual_parity/playwright/SOAK.md),
which puts every widget on one page at three viewports plus 200% text and runs
axe over the result. It runs in CI. Its first pass found two defects the 971
widget tests could not see, because they only appear once components share a
document.

## Status

| | |
| --- | --- |
| Visual parity vs the official React kit | 73/74 keys at ≥95% |
| Known gaps | [`doc/conformance.md`](https://github.com/PaoloGi/bootstrap_italia_flutter/blob/main/doc/conformance.md) |

Run `tool/status.sh` for the current test and contract counts. They are
deliberately not quoted here: the same numbers were previously copied by hand
into four documents and all four disagreed with each other and with reality.
A count that cannot drift is worth more than one that is precise today.

## Getting Started

This package is not on pub.dev. Depend on it by path or git:

```yaml
dependencies:
  bootstrap_italia_flutter:
    path: ../bootstrap_italia_flutter
```

Then wrap your app with the Bootstrap Italia theme:

```dart
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';

void main() {
  final theme = BootstrapItaliaThemeData.standard();
  runApp(
    BootstrapItaliaTheme(
      data: theme,
      child: MaterialApp(
        theme: theme.toThemeData(),
        home: MyApp(),
      ),
    ),
  );
}
```

## Components Overview

### Core UI

`ItButton`, `ItBadge`, `ItAlert`, `ItSpinner`, `ItIcon`, `ItChip`

### Content

`ItCard`, `ItAccordion`, `ItCollapse`, `ItTabBar`, `ItTabView`, `ItList`, `ItCallout`

### Form

`ItInput`, `ItSelect`, `ItMultiSelect`, `ItCheckbox`, `ItCheckboxGroup`, `ItRadio`, `ItRadioGroup`, `ItToggle`, `ItAutocomplete`, `ItDateField`

### Navigation

`ItHeader`, `ItSlimHeader`, `ItCenterHeader`, `ItNavHeader`, `ItFooter`, `ItBreadcrumb`, `ItBackToTop`

### Overlays

`ItModal`, `ItDropdown`, `ItNotification`

## Usage Examples

### Button with variants

```dart
ItButton(
  variant: ItButtonVariant.primary,
  onPressed: () {},
  child: Text('Conferma'),
)

ItButton(
  variant: ItButtonVariant.danger,
  outline: true,
  icon: Icons.delete,
  onPressed: () {},
  child: Text('Elimina'),
)

ItButton(
  variant: ItButtonVariant.secondary,
  disabled: true,
  child: Text('Disabilitato'),
)
```

### Alert with icon

```dart
ItAlert(
  variant: ItAlertVariant.success,
  icon: Icons.check_circle,
  title: 'Operazione completata',
  body: Text('Il documento e stato salvato con successo.'),
)

ItAlert(
  variant: ItAlertVariant.danger,
  icon: Icons.error,
  dismissible: true,
  body: Text('Si e verificato un errore.'),
)
```

### Form input with validation

```dart
ItInput(
  label: 'Email',
  hint: 'Inserisci la tua email',
  icon: Icons.email,
  validationState: ItValidationState.success,
  helperText: 'Email valida',
  onChanged: (value) {},
)
```

### Modal dialog

```dart
ItModal.show(
  context: context,
  title: 'Conferma operazione',
  icon: Icons.warning,
  body: Text('Sei sicuro di voler procedere?'),
  actions: [
    ItButton(
      variant: ItButtonVariant.secondary,
      onPressed: () => Navigator.pop(context),
      child: Text('Annulla'),
    ),
    ItButton(
      variant: ItButtonVariant.primary,
      onPressed: () {
        // Handle confirmation
        Navigator.pop(context);
      },
      child: Text('Conferma'),
    ),
  ],
);
```

## Custom Theming

You can customize the color scheme to match your brand:

```dart
final customTheme = BootstrapItaliaThemeData(
  colors: BootstrapItaliaColorScheme.standard.copyWith(
    primary: Color(0xFF0066CC), // Your brand color
  ),
);
```

Then apply it the same way as the standard theme:

```dart
BootstrapItaliaTheme(
  data: customTheme,
  child: MaterialApp(
    theme: customTheme.toThemeData(),
    home: MyApp(),
  ),
)
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). It documents the verification harness and
a set of rules that each exist because this package shipped the corresponding bug.

## License

MIT. See [LICENSE](LICENSE) for details.

The three font families bundled in `fonts/` are not MIT and are not ours:
Titillium Web, Lora and Roboto Mono are all under the SIL Open Font License
1.1, whose notices and text travel with them in
[fonts/licenses/](fonts/licenses/). Using this package means redistributing
them, so that directory is part of what you ship.
