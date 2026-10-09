# Soak

The same page, `example/lib/soak.dart`, driven by two harnesses that see
different things:

| | runs | sees |
|---|---|---|
| `tool/visual_parity/playwright/soak.mjs` | a real browser | axe rules, the accessibility DOM, keyboard behaviour |
| `example/integration_test/device_soak_test.dart` | a real device | the platform's fonts, text metrics and safe-area insets |

Neither replaces the other. The browser can run axe and cannot tell you that
the bottom navigation sits under a home indicator; the device knows its insets
and has no accessibility DOM to audit.

## Web

Puts **every** component the package exports on one Flutter Web page and drives
it from a real browser. The parity harness mounts one component per page on
purpose — a pixel comparison needs isolation. This asks the opposite question:
does anything throw, overflow, lose its name or fail an axe rule when it all
runs together?

```bash
cd example && flutter build web -t lib/soak.dart --no-tree-shake-icons
(cd example/build/web && python3 -m http.server 8788 &)
node tool/visual_parity/playwright/soak.mjs          # add --headed to watch
```

Runs in CI as the `soak` job, which uploads the report and the screenshots.

Checks, per viewport (390 / 768 / 1440, plus 390 at 200% text):

| | |
|---|---|
| render | something was actually painted |
| semantics | the tree is non-empty once enabled — Flutter's is opt-in, and axe against a blank page passes |
| axe | wcag2a + wcag2aa + wcag21a + wcag21aa, with the offending markup printed |
| overlays | each is asserted absent, opened, asserted present, dismissed with Escape, asserted gone |
| keyboard | 40 tabs must reach 5+ distinct targets, and a modal must hold focus across 15 |
| Dart errors | `SOAK-ERROR` lines from the page's own `FlutterError.onError` |
| third-party fonts | no request to `fonts.gstatic.com` — CanvasKit downloads Roboto for its default face unless the app declares a family named exactly `Roboto` (see `example/pubspec.yaml`) |

Two of those started out unable to fail. The overlay block clicked and pressed
Escape and asserted **nothing** — a missed click and a dead Escape passed
identically. The keyboard check asked `!!document.activeElement`, which is
never false, because it falls back to `<body>`. Both now assert outcomes, and
both were verified by planting defects: a `dismissible: false` modal trips the
Escape assertion, and an overlay wired to `() {}` trips "did not open".

A third lesson is baked into the harness: every overlay step dismisses in a
`finally`. Without that, one wrong assertion left a modal open and every later
step timed out behind it — 4 real failures reported as 16.

That last one matters: a release web build minifies the stack, so an
uncaught Dart error reaches the console as `Null check operator used on a null
value` and nothing else. `soak.dart` installs a handler that prints the
library, the context and the offending widget as plain strings.

## What it found the first time

- **`ItTabBar`**: every tab contained a second, unnamed interactive node
  (`nested-interactive`, `aria-command-name` — WCAG 4.1.2).
- **`ItCenterHeader`**: painted the `≥992px` layout at every width, overflowing
  by 19px on a phone.
- **Flutter Web disables pinch-zoom** by rewriting the viewport meta after
  boot, even when the document declares its own (WCAG 1.4.4). Not the
  package's, and not fixable from it — see `example/web/index.html`.

Two of the three are invisible to a widget test, and the third was invisible to
the parity harness, which renders each component alone inside a `Material` at
desktop width.

## Device

```bash
cd example
flutter test integration_test/device_soak_test.dart -d <device-id>
```

Asserts the things a headless engine cannot produce:

| | |
|---|---|
| fonts | `iii` must be narrower than `WWW` — equal widths mean a fallback face, and then every width measured anywhere is fiction |
| scrolling | 25 drags end to end with no layout error |
| text | 200% at the device's own width |

There is no inset check here, deliberately. One was written and it passed with
`ItBottomNav`'s inset handling deleted — twice, through two different attempted
fixes — because `Scaffold` positions `bottomNavigationBar` clear of the system
inset by itself, so inside a Scaffold the property is never exercised. It is
covered instead by `test/a11y/safe_area_contract_test.dart`, which mounts the
bar with an explicit inset and does go red. A copy here that cannot fail would
read as device evidence for something it never checked.

It exists because three of the last four defects found in this package appeared
**only** on hardware: labels under the home indicator, a floating label
painting through the field above it, and a card icon that measures zero-width
in the test harness because `Image.asset` resolves nothing there.

Not run in CI: it needs a booted simulator or a device, which a Linux runner
does not have. Run it before a release, and after touching layout.
