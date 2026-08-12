// The dark megamenu themes and the two call-to-action groups.
//
// From the Bootstrap Italia docs page for Megamenu, which the example app
// mirrors. `.theme-light-desk` (dark panel, light bar), `.theme-dark-mobile`
// (dark overlay), `.it-footer-link-wrapper` (CTAs in a row) and
// `.it-footer-link-wrapper-vertical` (CTAs in a right-hand column) had no
// expression here before.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

const _purple = Color(0xFF7A1FA2);

Widget _host(
  Widget child, {
  double width = 1200,
  BootstrapItaliaColorScheme? colors,
}) {
  final data = BootstrapItaliaThemeData(
    colors: colors ?? BootstrapItaliaColorScheme.standard,
  );
  return BootstrapItaliaTheme(
    data: data,
    child: MaterialApp(
      theme: data.toThemeData(),
      home: Scaffold(body: SizedBox(width: width, child: child)),
    ),
  );
}

Future<void> _pumpAt(
  WidgetTester tester,
  Widget child, {
  required double width,
  BootstrapItaliaColorScheme? colors,
}) async {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(_host(child, width: width, colors: colors));
}

TextStyle? _styleOf(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style;

/// The panel's own fill.
Color? _panelFill(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(ItMegamenuPanel),
          matching: find.byType(Container),
        )
        .first,
  );
  return (container.decoration! as BoxDecoration).color;
}

ItMegamenuSection _section({
  String? description,
  ItMegamenuCta? headerCta,
  ItMegamenuCta? footerCta,
  List<ItMegamenuCta> footerCtas = const [],
  List<ItMegamenuCta> sideCtas = const [],
}) =>
    ItMegamenuSection(
      label: 'Megamenu',
      active: true,
      description: description,
      headerCta: headerCta,
      footerCta: footerCta,
      footerCtas: footerCtas,
      sideCtas: sideCtas,
      columns: const [
        ItMegamenuColumn(
          heading: 'Intestazione colonna',
          links: [ItMegamenuLink(label: 'Link lista 1')],
        ),
      ],
    );

void main() {
  group('ItMegamenuPanel.dark — the panel under `.theme-light-desk`', () {
    testWidgets('the panel takes the primary fill', (t) async {
      await t
          .pumpWidget(_host(ItMegamenuPanel(section: _section(), dark: true)));

      expect(_panelFill(t), BootstrapItaliaColors.primary,
          reason: '`.theme-light-desk .navbar .dropdown-menu '
              '{ background: #06c }`');
    });

    testWidgets('every foreground reverses out', (t) async {
      await t.pumpWidget(_host(ItMegamenuPanel(
        dark: true,
        section: _section(
          description: 'Testo utile',
          headerCta: const ItMegamenuCta(label: 'Esplora la sezione'),
          footerCta: const ItMegamenuCta(label: 'Esplora tutti'),
        ),
      )));

      const white = BootstrapItaliaColors.white;
      expect(_styleOf(t, 'Link lista 1')?.color, white,
          reason: '`.theme-light-desk … ul li a span { color: #fff }`');
      expect(_styleOf(t, 'Esplora la sezione')?.color, white,
          reason: '`… a.it-heading-link { color: #fff }`');
      expect(_styleOf(t, 'Esplora tutti')?.color, white,
          reason: '`… a.it-footer-link { color: #fff }`');
      expect(_styleOf(t, 'Testo utile')?.color, white,
          reason: '`… .it-description p { color: #fff }`');
      expect(_styleOf(t, 'Intestazione colonna')?.color, white,
          reason: 'the panel restates every foreground as #fff; a '
              'hsl(0,0%,10%) heading on #06c would sit at about 1.9:1');
    });

    testWidgets('the light panel is untouched', (t) async {
      // Additive: `nav_megamenu_heading.png` is captured from the default
      // panel, so nothing about it may move.
      await t.pumpWidget(_host(ItMegamenuPanel(
        section: _section(
          headerCta: const ItMegamenuCta(label: 'Esplora la sezione'),
        ),
      )));

      expect(_panelFill(t), BootstrapItaliaColors.white);
      expect(_styleOf(t, 'Esplora la sezione')?.color,
          BootstrapItaliaColors.primary);
      expect(_styleOf(t, 'Link lista 1')?.color, BootstrapItaliaColors.dark);
    });

    testWidgets('the dark panel re-themes with the scheme', (t) async {
      // Both halves of the pairing are tokens — `#06c` is the fill and `#fff`
      // the content — so a retinted primary has to carry the panel with it.
      await t.pumpWidget(_host(
        ItMegamenuPanel(section: _section(), dark: true),
        colors: BootstrapItaliaColorScheme.standard.copyWith(primary: _purple),
      ));

      expect(_panelFill(t), _purple);
    });
  });

  group('ItMegamenu.lightDesk — the bar and the panel invert together', () {
    testWidgets('the bar goes white with primary labels', (t) async {
      await _pumpAt(
        t,
        ItMegamenu(lightDesk: true, sections: [_section()]),
        width: 1280,
      );

      expect(_styleOf(t, 'Megamenu')?.color, BootstrapItaliaColors.primary,
          reason: '`.theme-light-desk … li.megamenu > button.nav-link '
              '{ color: #06c }`');
    });

    testWidgets('opening a section gives a dark panel', (t) async {
      await _pumpAt(
        t,
        ItMegamenu(lightDesk: true, sections: [_section()]),
        width: 1280,
      );
      await t.tap(find.text('Megamenu'));
      await t.pumpAndSettle();

      expect(_panelFill(t), BootstrapItaliaColors.primary,
          reason: 'one flag sets both halves — the class name describes the '
              'bar, and configuring them apart would allow combinations the '
              'kit does not have');
    });

    testWidgets('the default bar is unchanged', (t) async {
      await _pumpAt(t, ItMegamenu(sections: [_section()]), width: 1280);
      expect(_styleOf(t, 'Megamenu')?.color, BootstrapItaliaColors.white);
    });
  });

  group('ItMegamenu.darkMobile — `.theme-dark-mobile`', () {
    Future<void> _openOverlay(WidgetTester tester, {required bool dark}) async {
      await _pumpAt(
        tester,
        ItMegamenu(darkMobile: dark, sections: [_section()]),
        width: 375,
      );
      await tester.tap(find.byType(ItIconAction));
      await tester.pumpAndSettle();
    }

    /// The overlay's own painted ground.
    ///
    /// Scoped through the close button rather than taken as "the first
    /// ColoredBox": the bar that pushed the route is still mounted underneath,
    /// and it paints a `#06c` box of its own, so an unscoped finder answers
    /// with the bar in both themes and the test passes for the wrong reason.
    Finder _overlayGround() => find
        .ancestor(
          of: find.byIcon(BootstrapItaliaIcons.it_close),
          matching: find.byType(ColoredBox),
        )
        .first;

    TextStyle? _tileStyle(WidgetTester tester) => tester
        .widget<Text>(
          find.descendant(
            of: _overlayGround(),
            matching: find.text('Megamenu'),
          ),
        )
        .style;

    testWidgets('the overlay takes the primary fill', (t) async {
      await _openOverlay(t, dark: true);

      expect(t.widget<ColoredBox>(_overlayGround()).color,
          BootstrapItaliaColors.primary,
          reason: '`.theme-dark-mobile … .menu-wrapper { background: #06c }`');
    });

    testWidgets('the section tile reverses out', (t) async {
      await _openOverlay(t, dark: true);

      expect(_tileStyle(t)?.color, BootstrapItaliaColors.white,
          reason: '`.theme-dark-mobile … li > button.nav-link '
              '{ color: #fff }`');
    });

    testWidgets('the default overlay is white with body-coloured tiles',
        (t) async {
      await _openOverlay(t, dark: false);

      expect(t.widget<ColoredBox>(_overlayGround()).color,
          BootstrapItaliaColors.white,
          reason: '`.navbar .navbar-collapsable .menu-wrapper '
              '{ background: #fff }`');
      expect(_tileStyle(t)?.color, BootstrapItaliaColors.bodyColor);
    });
  });

  group('footerCtas — `.it-footer-link-wrapper`', () {
    testWidgets('they run left to right beneath the columns', (t) async {
      await t.pumpWidget(_host(ItMegamenuPanel(
        section: _section(footerCtas: const [
          ItMegamenuCta(label: 'Call to action 1'),
          ItMegamenuCta(label: 'Call to action 2'),
        ]),
      )));

      final first = t.getCenter(find.text('Call to action 1'));
      final second = t.getCenter(find.text('Call to action 2'));
      expect(second.dx, greaterThan(first.dx));
      expect(second.dy, first.dy,
          reason: '`.it-footer-link-wrapper a.it-footer-link '
              '{ margin-right: 16px }` — a row, not a stack');

      expect(first.dy, greaterThan(t.getCenter(find.text('Link lista 1')).dy),
          reason: '`{ margin: 24px 0 0 0; padding-top: 24px }` puts them below '
              'the lists');
    });

    testWidgets('they are distinct from the single footerCta', (t) async {
      // `footerCta` is the right-aligned "Esplora tutti"; `footerCtas` are
      // peers laid out from the left. Both can be present.
      await t.pumpWidget(_host(ItMegamenuPanel(
        section: _section(
          footerCta: const ItMegamenuCta(label: 'Esplora tutti'),
          footerCtas: const [ItMegamenuCta(label: 'Call to action 1')],
        ),
      )));

      expect(find.text('Esplora tutti'), findsOneWidget);
      expect(find.text('Call to action 1'), findsOneWidget);
      expect(t.getCenter(find.text('Esplora tutti')).dx,
          greaterThan(t.getCenter(find.text('Call to action 1')).dx));
    });
  });

  group('sideCtas — `.it-footer-link-wrapper-vertical`', () {
    testWidgets('they stack in a column right of the lists', (t) async {
      await t.pumpWidget(_host(ItMegamenuPanel(
        section: _section(sideCtas: const [
          ItMegamenuCta(label: 'Call to action 1'),
          ItMegamenuCta(label: 'Call to action 2'),
        ]),
      )));

      final first = t.getCenter(find.text('Call to action 1'));
      final second = t.getCenter(find.text('Call to action 2'));
      expect(second.dy, greaterThan(first.dy),
          reason: 'the vertical wrapper stacks them');
      expect(first.dx, greaterThan(t.getCenter(find.text('Link lista 1')).dx),
          reason: '`{ padding-left: 24px; border-left: 1px solid #d9dadb }`');
    });

    testWidgets('the column rule is the kit\'s own odd grey', (t) async {
      // `#d9dadb`, not the `hsl(210,4%,78%)` (`#c5c7c9`) every other wrapper in
      // the panel uses. Bootstrap Italia states it that way; reproducing it
      // rather than unifying it is the point.
      await t.pumpWidget(_host(ItMegamenuPanel(
        section: _section(
          sideCtas: const [ItMegamenuCta(label: 'Call to action 1')],
        ),
      )));

      final borders = t
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.border)
          .whereType<Border>()
          .map((b) => b.left.color)
          .toSet();
      expect(borders, contains(const Color(0xFFD9DADB)));
    });
  });

  group('a11y: the CTA groups are links, named individually', () {
    testWidgets('4.1.2: each CTA carries the link role and its own name',
        (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(ItMegamenuPanel(
        section: _section(
          footerCtas: const [
            ItMegamenuCta(label: 'Esplora tutti i contenuti del megamenu 1'),
            ItMegamenuCta(label: 'Esplora tutti i contenuti del megamenu 2'),
          ],
        ),
      )));

      final data = <SemanticsData>[];
      void walk(SemanticsNode node) {
        data.add(node.getSemanticsData());
        node.visitChildren((c) {
          walk(c);
          return true;
        });
      }

      walk(t.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);

      // The docs warn about exactly this: several "Esplora tutti" links in one
      // menu are indistinguishable in a screen reader's link list, so each has
      // to say what it opens. The widget cannot enforce that, but it must at
      // least carry whatever name it is given onto a real link node.
      for (final label in const [
        'Esplora tutti i contenuti del megamenu 1',
        'Esplora tutti i contenuti del megamenu 2',
      ]) {
        final node = data.firstWhere((d) => d.label == label);
        expect(node.hasFlag(SemanticsFlag.isLink), isTrue);
      }
      handle.dispose();
    });
  });
}
