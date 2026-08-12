// `.theme-light` on the slim band, `.btn-full`, `.theme-light-desk`,
// `.theme-dark-mobile` and `.navbar-nav.navbar-secondary`.
//
// All five come from the Bootstrap Italia docs page for Header, which the
// example app mirrors. None existed here before.
//
// The theme flags are also where the tokens question bites hardest. The default
// slim band is `hsl(210,100%,35%)`, which matches no palette entry, so its white
// content stays a literal. `.theme-light` is `#fff` carrying `#06c` — both
// tokens, both in the roles those tokens name — so it has to travel with a
// retinted scheme, and the group at the bottom is what holds that apart from
// the band above it.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
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

/// Pumps [child] at a viewport of [width] logical pixels.
///
/// The nav band reads the *viewport*, not its own constraints — CSS media
/// queries are viewport-based — so a mobile test has to shrink the view and not
/// merely the box.
Future<void> _pumpAt(
  WidgetTester tester,
  Widget child, {
  required double width,
  BootstrapItaliaColorScheme? colors,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(_host(child, width: width, colors: colors));
}

TextStyle? _styleOf(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style;

/// The fill of the outermost painted box inside [of].
Color? _bandFill(WidgetTester tester, Finder of) {
  for (final element in tester.elementList(
    find.descendant(of: of, matching: find.byType(Container)),
  )) {
    final container = element.widget as Container;
    final color = container.color ??
        (container.decoration is BoxDecoration
            ? (container.decoration! as BoxDecoration).color
            : null);
    if (color != null) return color;
  }
  return null;
}

List<ItNavItem> _navItems() => [
      const ItNavItem(label: 'Link 1', active: true),
      const ItNavItem(label: 'Link 2'),
    ];

void main() {
  group('ItSlimHeader.light — `.it-header-slim-wrapper.theme-light`', () {
    testWidgets('the band inverts', (t) async {
      await t.pumpWidget(_host(const ItSlimHeader(
        institutionName: 'Ente appartenenza',
        light: true,
      )));

      expect(
          _bandFill(t, find.byType(ItSlimHeader)), BootstrapItaliaColors.white,
          reason: '`.theme-light { background: #fff }`');
      expect(_styleOf(t, 'Ente appartenenza')?.color,
          BootstrapItaliaColors.primary,
          reason: '`.theme-light … .navbar-brand { color: #06c }`');
    });

    testWidgets('the default band is untouched', (t) async {
      await t.pumpWidget(_host(const ItSlimHeader(
        institutionName: 'Ente appartenenza',
      )));

      expect(_bandFill(t, find.byType(ItSlimHeader)), const Color(0xFF0059B3),
          reason: '`background: hsl(210,100%,35%)` — a literal, matching no '
              'palette entry');
      expect(_styleOf(t, 'Ente appartenenza')?.color, const Color(0xFFFFFFFF));
    });

    testWidgets('the light band and its content re-theme together', (t) async {
      // Retinting the fill without the label is how a themed header loses its
      // contrast; here it is the label that must follow, since the fill is the
      // neutral one.
      await t.pumpWidget(_host(
        const ItSlimHeader(institutionName: 'Ente', light: true),
        colors: BootstrapItaliaColorScheme.standard.copyWith(primary: _purple),
      ));

      expect(_styleOf(t, 'Ente')?.color, _purple);
    });

    testWidgets('the dark band does NOT re-theme', (t) async {
      await t.pumpWidget(_host(
        const ItSlimHeader(institutionName: 'Ente'),
        colors: BootstrapItaliaColorScheme.standard.copyWith(primary: _purple),
      ));

      expect(_bandFill(t, find.byType(ItSlimHeader)), const Color(0xFF0059B3),
          reason: 'the default band is a literal in the stylesheet too, so it '
              'has nothing to follow');
    });
  });

  group('ItSlimHeader.accessButtonFull — `.btn-full`', () {
    /// The access button's painted box.
    Rect _button(WidgetTester tester) => tester.getRect(find
        .ancestor(
          of: find.text('Accedi'),
          matching: find.byType(Container),
        )
        .first);

    testWidgets('it stretches to the band height and squares off', (t) async {
      await t.pumpWidget(_host(const ItSlimHeader(
        institutionName: 'Ente',
        accessLabel: 'Accedi',
        accessButtonFull: true,
      )));

      expect(_button(t).height, 48,
          reason: '`.btn-full { align-self: stretch }` against the 48px band');

      final decoration = tester_decoration(t, 'Accedi');
      expect(decoration.borderRadius, BorderRadius.zero,
          reason: '`.btn-full { border-radius: 0 }`');
    });

    testWidgets('the default button keeps its pill and its inset', (t) async {
      await t.pumpWidget(_host(const ItSlimHeader(
        institutionName: 'Ente',
        accessLabel: 'Accedi',
      )));

      expect(_button(t).height, lessThan(48));
      expect(tester_decoration(t, 'Accedi').borderRadius,
          BorderRadius.circular(4));
    });
  });

  group('ItNavHeader.lightDesk — `.theme-light-desk`', () {
    testWidgets('the desktop band inverts and gains its shadow', (t) async {
      await _pumpAt(t, ItNavHeader(lightDesk: true, items: _navItems()),
          width: 1280);

      final decorated = t.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(ItNavHeader),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = decorated.decoration as BoxDecoration;
      expect(decoration.color, BootstrapItaliaColors.white,
          reason: '`@media (min-width: 992px) { .theme-light-desk '
              '{ background: #fff } }`');
      expect(decoration.boxShadow, hasLength(1),
          reason: '`.theme-light-desk { box-shadow: 0 20px 30px 5px '
              'rgba(0,0,0,.05) }` — a white band on a white page has no other '
              'edge');
      expect(_styleOf(t, 'Link 1')?.color, BootstrapItaliaColors.primary,
          reason: '`.theme-light-desk … li a.nav-link { color: #06c }`');
    });

    testWidgets('the default desktop band is untouched', (t) async {
      await _pumpAt(t, ItNavHeader(items: _navItems()), width: 1280);

      final decorated = t.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(ItNavHeader),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = decorated.decoration as BoxDecoration;
      expect(decoration.color, BootstrapItaliaColors.primary);
      expect(decoration.boxShadow, isNull);
      expect(_styleOf(t, 'Link 1')?.color, BootstrapItaliaColors.white);
    });
  });

  group('ItNavHeader.darkMobile — `.theme-dark-mobile`', () {
    testWidgets('the default is the kit default: white panel', (t) async {
      // This package painted the DARK panel by default for a long time, which
      // inverted the kit. `.theme-dark-mobile` is a modifier class, so the
      // variant you opt into cannot also be the default — and the docs say as
      // much: "su mobile lo stile di default ha un background bianco e testi e
      // link di colore primario". Corrected rather than preserved: there are no
      // published users, no capture covers the mobile panel, and ItMegamenu's
      // equivalent flag already defaulted to false, so the two siblings
      // disagreed with each other as well as with the kit.
      await _pumpAt(t, ItNavHeader(items: _navItems()), width: 375);

      expect(
          _bandFill(t, find.byType(ItNavHeader)), BootstrapItaliaColors.white,
          reason: '`.navbar .navbar-collapsable .menu-wrapper '
              '{ background: #fff }`');
      expect(_styleOf(t, 'Link 1')?.color, BootstrapItaliaColors.primary);
    });

    testWidgets('true opts into the dark panel', (t) async {
      await _pumpAt(t, ItNavHeader(darkMobile: true, items: _navItems()),
          width: 375);

      expect(_bandFill(t, find.byType(ItNavHeader)),
          BootstrapItaliaColors.primary);
      expect(_styleOf(t, 'Link 1')?.color, BootstrapItaliaColors.white);
    });

    testWidgets('false is explicit about the same default', (t) async {
      await _pumpAt(t, ItNavHeader(darkMobile: false, items: _navItems()),
          width: 375);

      expect(
          _bandFill(t, find.byType(ItNavHeader)), BootstrapItaliaColors.white,
          reason: '`.navbar .navbar-collapsable .menu-wrapper '
              '{ background: #fff }`');
      expect(_styleOf(t, 'Link 1')?.color, BootstrapItaliaColors.primary,
          reason: '*"su mobile lo stile di default ha un background bianco e '
              'testi e link di colore primario"*');
    });

    testWidgets('it does not reach the desktop band', (t) async {
      // Two independent CSS classes on two sides of one breakpoint.
      await _pumpAt(t, ItNavHeader(darkMobile: false, items: _navItems()),
          width: 1280);

      expect(_styleOf(t, 'Link 1')?.color, BootstrapItaliaColors.white);
    });
  });

  group('ItNavHeader.secondaryItems — `.navbar-nav.navbar-secondary`', () {
    testWidgets('it sits to the right, in smaller type', (t) async {
      await _pumpAt(
        t,
        ItNavHeader(
          items: _navItems(),
          secondaryItems: const [ItNavItem(label: 'Link 5')],
        ),
        width: 1280,
      );

      expect(_styleOf(t, 'Link 5')?.fontSize, 14,
          reason: '`.navbar-secondary a { font-size: .875rem }`');
      expect(_styleOf(t, 'Link 1')?.fontSize, 18,
          reason:
              'the primary list keeps `a.nav-link { font-size: 1.125rem }`');

      expect(t.getCenter(find.text('Link 5')).dx,
          greaterThan(t.getCenter(find.text('Link 2')).dx),
          reason: '`.menu-wrapper { justify-content: space-between }`');
    });

    testWidgets('on mobile both lists share the panel', (t) async {
      await _pumpAt(
        t,
        ItNavHeader(
          items: _navItems(),
          secondaryItems: const [ItNavItem(label: 'Link 5')],
        ),
        width: 375,
      );

      // Open the panel: the collapsed bar shows only the current section.
      await t.tap(find.byType(ItIconAction));
      await t.pumpAndSettle();

      expect(find.text('Link 5'), findsOneWidget,
          reason: 'the kit puts both `ul`s inside the same `.menu-wrapper`');
    });

    testWidgets('an empty secondary list changes nothing', (t) async {
      await _pumpAt(t, ItNavHeader(items: _navItems()), width: 1280);
      final before = t.getCenter(find.text('Link 1'));

      await _pumpAt(
        t,
        ItNavHeader(items: _navItems(), secondaryItems: const []),
        width: 1280,
      );
      expect(t.getCenter(find.text('Link 1')), before,
          reason: 'additive: the default rendering the parity captures hold '
              'must not move');
    });
  });
}

/// The decoration of the box painted directly around [label].
BoxDecoration tester_decoration(WidgetTester tester, String label) {
  final container = tester.widget<Container>(
    find.ancestor(of: find.text(label), matching: find.byType(Container)).first,
  );
  return container.decoration! as BoxDecoration;
}
