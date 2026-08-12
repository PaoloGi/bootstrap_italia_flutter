// The theming contract: a custom BootstrapItaliaColorScheme must actually reach
// every component.
//
// `BootstrapItaliaColorScheme` exists so an administration can apply its own
// palette. That promise is only kept if components resolve their colours from
// the scheme instead of hardcoding the standard values. Several did not: the
// brand blue `#0066CC` was written literally in a dozen component files, so
// `copyWith(primary: ...)` retinted buttons and alerts while navigation and
// content silently stayed Blu Italia.
//
// IMPORTANT — the distinction this file encodes:
//
//   * A colour that IS a theme token (primary, secondary, success, danger,
//     warning) must come from the scheme. Hardcoding it is a defect.
//   * A colour the stylesheet declares in its own right is NOT a token and must
//     stay constant. `.chip:hover { background: hsl(210,33%,28%) }` is a
//     literal declaration, not a shade of primary; routing it through the scheme
//     would be a fresh bug, and re-theming would not change it upstream either.
//
// So this file asserts themability only where Bootstrap Italia itself derives
// the colour from a semantic token.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deliberately garish so a match cannot be coincidental.
const _primary = Color(0xFFFF0000);
const _secondary = Color(0xFF00FF00);
const _dark = Color(0xFF4A2B00);
const _bodyColor = Color(0xFF33006B);
const _white = Color(0xFFFFF8E1);
const _black = Color(0xFF2B0000);
const _danger = Color(0xFFFF00FF);

final _scheme = BootstrapItaliaColorScheme.standard.copyWith(
  primary: _primary,
  secondary: _secondary,
  dark: _dark,
  bodyColor: _bodyColor,
  white: _white,
  black: _black,
  danger: _danger,
);

Widget _themed(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData(colors: _scheme),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData(colors: _scheme).toThemeData(),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

/// Renders [child] and reports every colour actually rasterised, by pixel.
///
/// The widget-tree walk in [_paints] cannot see through a [CustomPainter]: the
/// header glyphs and the megamenu bullets hand their colour to a private
/// painter, so from outside the tree they are opaque. Reading the pixels covers
/// them, and answers the stronger question anyway — not "was the right colour
/// passed" but "did the right colour reach the screen".
Future<Set<int>> _rasterise(WidgetTester tester, Widget child) async {
  final key = GlobalKey();
  await tester.pumpWidget(_themed(
    RepaintBoundary(key: key, child: child),
  ));
  await tester.pump();

  late final ByteData data;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    image.dispose();
  });

  final seen = <int>{};
  for (var i = 0; i + 3 < data.lengthInBytes; i += 4) {
    if (data.getUint8(i + 3) == 0) continue; // fully transparent
    seen.add((0xFF << 24) |
        (data.getUint8(i) << 16) |
        (data.getUint8(i + 1) << 8) |
        data.getUint8(i + 2));
  }
  return seen;
}

/// True when [colour] survives rasterisation as an exact pixel value.
///
/// Exact, not near: antialiased edges blend, but any solid fill or glyph core
/// lands on the precise value, and a tolerance here would let a genuinely
/// wrong-but-close colour pass.
Future<bool> _rendersExactly(
  WidgetTester tester,
  Widget child,
  Color colour,
) async =>
    (await _rasterise(tester, child)).contains(colour.toARGB32());

/// True when [colour] is painted anywhere in the rendered subtree — as text, a
/// box fill, a border, or an icon.
bool _paints(WidgetTester tester, Color colour) {
  for (final e in find.byType(Text).evaluate()) {
    if ((e.widget as Text).style?.color == colour) return true;
  }
  for (final e in find.byType(Icon).evaluate()) {
    if ((e.widget as Icon).color == colour) return true;
  }
  for (final e in find.byType(Container).evaluate()) {
    final d = (e.widget as Container).decoration;
    if (d is BoxDecoration) {
      if (d.color == colour) return true;
      final b = d.border;
      if (b is Border &&
          (b.top.color == colour ||
              b.left.color == colour ||
              b.bottom.color == colour)) {
        return true;
      }
    }
    if ((e.widget as Container).color == colour) return true;
  }
  for (final e in find.byType(DecoratedBox).evaluate()) {
    final d = (e.widget as DecoratedBox).decoration;
    if (d is BoxDecoration && d.color == colour) return true;
  }
  for (final e in find.byType(ColoredBox).evaluate()) {
    if ((e.widget as ColoredBox).color == colour) return true;
  }
  // The form focus ring is `box-shadow: 0 0 0 .25rem rgba(0,102,204,.25)`, so
  // it lives in a BoxShadow and no branch above would ever see it.
  for (final e in find.byType(DecoratedBox).evaluate()) {
    final d = (e.widget as DecoratedBox).decoration;
    if (d is BoxDecoration &&
        d.boxShadow != null &&
        d.boxShadow!.any((sh) => sh.color == colour)) {
      return true;
    }
  }
  // Colours handed to a CustomPainter are invisible to the checks above. Without
  // this, ItSpinner reads as "not themed" when it demonstrably is — a false
  // failure that would have led to "fixing" a working component.
  for (final e in find.byType(ItProgressSpinner).evaluate()) {
    if ((e.widget as ItProgressSpinner).color == colour) return true;
  }
  return false;
}

void main() {
  group('components resolve their accent from the theme', () {
    Future<void> expectThemed(
      WidgetTester tester,
      Widget child, {
      Color colour = _primary,
      required String what,
    }) async {
      await tester.pumpWidget(_themed(child));
      await tester.pump();
      expect(_paints(tester, colour), isTrue,
          reason: '$what does not use the themed colour — it is hardcoded, so '
              'an administration applying its own palette would see this '
              'component stay Blu Italia while the rest of the page changed');
    }

    testWidgets('ItButton', (t) async {
      await expectThemed(t, ItButton(onPressed: () {}, child: const Text('Ok')),
          what: 'ItButton fill');
    });

    testWidgets('ItBadge', (t) async {
      await expectThemed(t, const ItBadge(child: Text('New')),
          what: 'ItBadge fill');
    });

    testWidgets('ItAlert accent border', (t) async {
      await expectThemed(
          t, const ItAlert(variant: ItAlertVariant.primary, body: Text('a')),
          what: 'ItAlert accent border');
    });

    testWidgets('ItList item title', (t) async {
      await expectThemed(t, const ItList(items: [ItListItem(title: 'Voce')]),
          what: 'ItList title');
    });

    testWidgets('ItAccordion header', (t) async {
      await expectThemed(
        t,
        const ItAccordion(
            items: [ItAccordionItem(title: 'Sezione', body: Text('x'))]),
        what: 'ItAccordion header',
      );
    });

    testWidgets('ItTabBar active tab', (t) async {
      await expectThemed(
        t,
        const SizedBox(
          width: 600,
          child: ItTabBar(
              tabs: [ItTabItem(label: 'Uno'), ItTabItem(label: 'Due')]),
        ),
        what: 'ItTabBar active tab',
      );
    });

    testWidgets('ItBreadcrumb link', (t) async {
      await expectThemed(
        t,
        const ItBreadcrumb(items: [
          ItBreadcrumbItem(label: 'Home'),
          ItBreadcrumbItem(label: 'Pagina'),
        ]),
        colour: _secondary,
        what: 'ItBreadcrumb separator',
      );
    });

    testWidgets('ItCallout accent border', (t) async {
      await expectThemed(
        t,
        const ItCallout(variant: ItCalloutVariant.note, body: Text('x')),
        what: 'ItCallout note accent',
      );
    });

    testWidgets('ItCard tappable title', (t) async {
      await expectThemed(t, ItCard(title: 'Titolo', onTap: () {}),
          what: 'ItCard tappable title link');
    });

    // The other side of the same rule, and the one a find-and-replace on
    // #0066CC would have broken: a card's category and date are byte-identical
    // to --bs-secondary, and must NOT follow it. `hsl(210, 17%, 44%)` is also
    // declared as --bs-gray-secondary, and on metadata it is the neutral grey
    // that is meant. Routing it through the scheme would be a fresh bug.
    testWidgets('ItCard metadata does NOT follow the theme', (t) async {
      await t.pumpWidget(_themed(const ItCard(
        title: 'Titolo',
        date: '22 aprile 2025',
      )));
      await t.pump();
      expect(_paints(t, _secondary), isFalse,
          reason: 'the card date is the neutral grey, not the brand secondary; '
              'an administration retinting secondary wants its buttons '
              'recoloured, not its publication dates');
    });

    testWidgets('ItBackToTopButton fill', (t) async {
      await expectThemed(t, ItBackToTopButton(onPressed: () {}),
          what: 'ItBackToTopButton fill');
    });

    testWidgets('ItSkiplinks link', (t) async {
      // The token is on the LINK, not the band — upstream paints
      // `.skiplinks { background: hsl(210,62%,97%) }` and
      // `.skiplinks a { color: #06c }`. This port had the two inverted until
      // the token audit; the band assertion below pins the other half.
      await expectThemed(
        t,
        const ItSkiplinks(
          hideUntilFocused: false,
          links: [ItSkiplink(label: 'Salta al contenuto')],
        ),
        what: 'ItSkiplinks link text',
      );
    });

    testWidgets('ItProgressSpinner arc defaults to secondary', (t) async {
      // `color` is nullable now and left null here on purpose: the default is
      // the thing under test. That makes the widget-tree walk useless — the
      // field really is null — so read the pixels the painter produced.
      final painted = await _rasterise(
          t, const ItProgressSpinner(diameter: 32, strokeWidth: 4));
      expect(painted.contains(_secondary.toARGB32()), isTrue,
          reason: 'an unconfigured ItProgressSpinner must draw its arc in the '
              'themed secondary; a hardcoded arc stays grey-blue while the '
              'rest of the page is retinted');
      await unmount(t);
    });

    testWidgets('ItNavHeader band', (t) async {
      await expectThemed(
          t, const ItNavHeader(items: [ItNavItem(label: 'Home')]),
          what: 'ItNavHeader band');
    });

    testWidgets('ItCenterHeader band', (t) async {
      await expectThemed(t, const ItCenterHeader(title: 'Comune di Roma'),
          what: 'ItCenterHeader band');
    });

    testWidgets('ItInput label follows bodyColor', (t) async {
      // The hint is load-bearing: `.form-group label` is the grey until it
      // floats, and only `label.active` carries `hsl(0,0%,10%)` = bodyColor.
      // Without a hint (or a value) the label never floats and this would be
      // asserting the wrong colour.
      await expectThemed(t, const ItInput(label: 'Nome', hint: 'Mario'),
          colour: _bodyColor, what: 'ItInput floating label');
    });

    testWidgets('ItSelect display follows bodyColor', (t) async {
      await expectThemed(
        t,
        const ItSelect<String>(
          label: 'Regione',
          value: 'a',
          items: [ItSelectItem(value: 'a', label: 'Lazio')],
        ),
        colour: _bodyColor,
        what: 'ItSelect display text',
      );
    });

    testWidgets('ItInput focus ring follows primary', (t) async {
      // `.form-control:focus { box-shadow: 0 0 0 .25rem rgba(0,102,204,.25) }`
      // — the alpha is part of the CSS, so the themed colour must carry it.
      await t.pumpWidget(_themed(const ItInput(label: 'Nome')));
      await t.pump();
      await t.tap(find.byType(ItInput));
      await t.pumpAndSettle();
      expect(_paints(t, _primary.withAlpha(0x40)), isTrue,
          reason: 'a focused field draws its ring in the un-themed brand blue');
    });

    testWidgets('ItSpinner arc follows secondary', (t) async {
      // `secondary`, not `primary`: `.progress-spinner-active:not(
      // .progress-spinner-double) { border-color: hsl(210,17%,44%) }`, and the
      // double form declares the same value. This asserted `primary` because
      // the widget defaulted to it — matching neither the stylesheet nor
      // ItProgressSpinner, which does the painting and always resolved
      // secondary.
      await expectThemed(t, const ItSpinner(doubleRing: true),
          colour: _secondary, what: 'ItSpinner arc');
      await unmount(t);
    });
  });

  // ───────────────────────────────────────────────────────────────────────
  // The other half of the rule. Every assertion above says a colour MUST
  // follow the theme; these say a colour must NOT. Both directions are real
  // defects, and a find-and-replace on the palette hex values would introduce
  // the second while fixing the first.
  //
  // v2.18.0 resolves its semantic tokens to literals at build time —
  // `var(--bs-primary)` appears zero times in the whole stylesheet — so
  // "is it derived from a token?" answers no for every colour in the file and
  // cannot be the test. What is used instead: a colour re-themes when it is
  // byte-identical to a declared token AND sits in a role where that token is
  // what is meant.
  group('literals stay literal under a retinted scheme', () {
    Future<void> expectFixed(
      WidgetTester tester,
      Widget child, {
      required Color literal,
      required String what,
      required String why,
    }) async {
      await tester.pumpWidget(_themed(child));
      await tester.pump();
      expect(_paints(tester, literal), isTrue,
          reason:
              '$what must stay $literal even under a retinted scheme: $why');
    }

    testWidgets('the form error message is NOT --bs-danger', (t) async {
      // The sharpest case in the package, and one I got wrong on first pass.
      // `--bs-danger` is hsl(350,60%,50%) = #CC334D, which is what Bootstrap's
      // own `.invalid-feedback` carries. Italia overrides the *message* with a
      // standalone `.form-feedback.just-validate-error-label { color: #d9364f }`
      // that backs no custom property anywhere in the sheet. Routing it through
      // `danger` would be the inverse defect — and note the field *chrome*
      // `.form-control.is-invalid { border-color: rgb(204,51,76.5) }` IS the
      // token, so the two live side by side in one component.
      await expectFixed(
        t,
        const ItInput(
          label: 'Codice fiscale',
          errorText: 'Codice non valido',
          validationState: ItValidationState.danger,
        ),
        literal: const Color(0xFFD9364F),
        what: 'the validation message',
        why: 'it is a standalone declaration, 1.5% off --bs-danger and backed '
            'by no custom property',
      );
      // Both must be true at once, and that is the whole point: one invalid
      // field paints the themed danger on its border and the fixed #D9364F on
      // its message. A first attempt at this test asserted the themed colour
      // was absent and failed — because the border legitimately carries it.
      expect(_paints(t, _danger), isTrue,
          reason:
              '`.form-control.is-invalid { border-color: rgb(204,51,76.5) }`'
              ' IS --bs-danger, so the field chrome must follow the theme even '
              'though the message beside it must not');
    });

    testWidgets('the skiplinks band is NOT primary', (t) async {
      await expectFixed(
        t,
        const ItSkiplinks(
          hideUntilFocused: false,
          links: [ItSkiplink(label: 'Salta al contenuto')],
        ),
        literal: const Color(0xFFF3F7FC),
        what: 'the skiplinks band',
        why: '`hsl(210,62%,97%)` appears 17 times as a standalone declaration '
            'and matches nothing in the palette',
      );
    });

    testWidgets('form chrome greys are NOT secondary', (t) async {
      await expectFixed(
        t,
        const ItInput(label: 'Nome'),
        literal: const Color(0xFF5D7083),
        what: 'the resting field border',
        why: 'hsl(210,17%,44%) is declared as --bs-secondary, --bs-info AND '
            '--bs-gray-secondary; on resting chrome it is the grey that is '
            'meant, so retinting secondary must not move it',
      );
    });
  });
}

/// The active spinner animates; unmount it so the binding does not stay busy.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}
