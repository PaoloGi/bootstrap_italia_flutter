// Interaction-state contracts.
//
// Material renders hover/press by painting a translucent overlay derived from
// the *foreground* colour: on a white surface that darkens (measured
// rgb(245,245,245) hovered, rgb(222,222,222) pressed), on a coloured button it
// lightens. Bootstrap Italia does neither — most of its components keep the
// fill untouched and signal the state on the text, and the ones that do repaint
// name an explicit colour.
//
// These tests are the offline half of the proof. The browser harness
// (tool/visual_parity/capture_all_states.sh + diff/sample_state.py) measures the
// rendered pixel; this file pins the contract for widgets that live inside an
// overlay or a route and so cannot be driven from a static capture.
//
// The contract used to be "every ink surface declines the overlay"
// (`overlayColor: kItNoOverlay`). There is no longer an ink
// surface anywhere in the package: `Material`, `InkWell` and `IconButton` are
// gone, so the suppression has nothing left to suppress. Asserting their
// *absence* is the stronger form of the same contract — an overlay that cannot
// be constructed cannot be forgotten — and it is what these helpers now check.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_flutter/src/a11y/it_activatable.dart';
import 'package:bootstrap_italia_flutter/src/a11y/it_icon_action.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// No ink surface may exist anywhere the package builds.
///
/// The `InkWell` check is global — the `MaterialApp` + `Scaffold` host adds
/// none, so any hit is the package's. The `Material` check is scoped to [under]
/// because the `Scaffold` legitimately owns one.
///
/// Requiring at least one [ItActivatable] guards against the test passing on an
/// empty tree: the original helper proved the subtree had been built by
/// requiring at least one `InkWell`, and something has to take its place.
void expectNoInkOverlay(WidgetTester tester, {Finder? under}) {
  expect(
    find.byType(InkWell),
    findsNothing,
    reason: 'InkWell hosts a Material overlay this design system never wants; '
        'the migration off Material removed the last one',
  );
  expect(
    find.byType(ItActivatable),
    findsWidgets,
    reason: 'the interactive rows under test were never built, so asserting '
        'on what they do not contain proves nothing',
  );
  if (under != null) {
    expect(
      find.descendant(of: under, matching: find.byType(Material)),
      findsNothing,
      reason: 'a Material surface exists only to host ink effects Bootstrap '
          'Italia does not have — and it leaks a text theme besides',
    );
  }
}

/// Icon-only controls carry no Material button, and keep an accessible name.
void expectNoButtonOverlay(WidgetTester tester) {
  expect(
    find.byType(IconButton),
    findsNothing,
    reason: 'IconButton paints a Material overlay the kit does not have '
        '(`.custom-navbar-toggler { background: none }`)',
  );
  final actions = tester.widgetList<ItIconAction>(find.byType(ItIconAction));
  expect(actions, isNotEmpty, reason: 'expected at least one ItIconAction');
  for (final action in actions) {
    // WCAG 4.1.2: the name used to come from `IconButton.tooltip`. Losing it
    // silently is exactly the regression the migration off Material warns
    // about.
    expect(action.label, isNotEmpty,
        reason: 'an icon-only control with no accessible name is a 4.1.2 '
            'failure');
  }
}

Widget _host(Widget child, {Size size = const Size(1200, 800)}) {
  final theme = BootstrapItaliaThemeData.standard();
  return BootstrapItaliaTheme(
    data: theme,
    child: MaterialApp(
      theme: theme.toThemeData(),
      home: Scaffold(
        body: Center(child: SizedBox(width: size.width, child: child)),
      ),
    ),
  );
}

/// Moves a synthetic mouse over [finder] and leaves it there.
Future<TestGesture> hover(WidgetTester tester, Finder finder) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await tester.pump();
  await gesture.moveTo(tester.getCenter(finder));
  await tester.pumpAndSettle();
  return gesture;
}

Color? _boxColor(WidgetTester tester, Finder finder) {
  final container = tester.widget<Container>(finder);
  final decoration = container.decoration;
  if (decoration is BoxDecoration) return decoration.color;
  return container.color;
}

void main() {
  group('Material overlay suppressed', () {
    testWidgets('ItList rows', (tester) async {
      await tester.pumpWidget(
        _host(ItList(items: [ItListItem(title: 'Link', onTap: () {})])),
      );
      expectNoInkOverlay(tester, under: find.byType(ItList));
    });

    testWidgets('ItDropdownMenu items', (tester) async {
      await tester.pumpWidget(
        _host(
          const ItDropdownMenu(
            width: 300,
            items: [ItDropdownItem(label: 'Azione')],
          ),
        ),
      );
      expectNoInkOverlay(tester, under: find.byType(ItDropdownMenu));
    });

    testWidgets('ItAccordion headers', (tester) async {
      await tester.pumpWidget(
        _host(
          const ItAccordion(
            items: [
              ItAccordionItem(title: 'Sezione', body: SizedBox.shrink()),
            ],
          ),
        ),
      );
      expectNoInkOverlay(tester, under: find.byType(ItAccordion));
    });

    // The select's option list only exists inside an overlay entry, which no
    // static capture can reach — this is the only place its InkWell is checked.
    testWidgets('ItSelect option list', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: ItSelect<String>(
              groupMargin: false,
              label: 'Etichetta',
              items: const [
                ItSelectItem<String>(value: 'a', label: 'Opzione A')
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ItSelect<String>));
      await tester.pumpAndSettle();
      expectNoInkOverlay(tester);
    });

    // The megamenu's mobile tiles live behind a pushed route, so like the
    // select's option list they are unreachable from a static capture.
    testWidgets('ItMegamenu mobile overlay tiles and toggler', (tester) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          const ItMegamenu(
            sections: [
              ItMegamenuSection(
                label: 'Sezione',
                columns: [
                  ItMegamenuColumn(
                    links: [ItMegamenuLink(label: 'Link 1')],
                  ),
                ],
              ),
            ],
          ),
          size: const Size(600, 900),
        ),
      );
      expectNoButtonOverlay(tester);
      await tester.tap(find.byType(ItIconAction));
      await tester.pumpAndSettle();
      // The label appears twice once the overlay is up: on the collapsed bar
      // behind it and on the overlay's own section tile.
      await tester.tap(find.text('Sezione').last);
      await tester.pumpAndSettle();
      expectNoInkOverlay(tester);
    });

    testWidgets('ItNavHeader mobile menu and toggler', (tester) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          const ItNavHeader(items: [ItNavItem(label: 'Link 1')]),
          size: const Size(600, 900),
        ),
      );
      expectNoButtonOverlay(tester);
      await tester.tap(find.byType(ItIconAction));
      await tester.pumpAndSettle();
      expectNoInkOverlay(tester, under: find.byType(ItNavHeader));
    });
  });

  group('hover colours match the stylesheet', () {
    // `.chip:hover:not(.chip-disabled)
    //   { background: hsl(210,33%,28%); border-color: hsl(210,33%,28%) }`
    testWidgets('ItChip fills with rgb(48,71,95), not a lighter tint',
        (tester) async {
      await tester.pumpWidget(_host(ItChip(label: 'Label', onTap: () {})));
      final box = find.descendant(
        of: find.byType(ItChip),
        matching: find.byType(Container),
      );
      expect(_boxColor(tester, box), const Color(0xFFF5F5F5));
      await hover(tester, find.byType(ItChip));
      expect(_boxColor(tester, box), const Color(0xFF30475F));
    });

    // `.chip.chip-disabled { background: #fff; color: hsl(210,12%,44%) }` —
    // explicit colours, not `--bs-btn-disabled-opacity`.
    testWidgets('ItChip disabled uses declared colours and ignores hover',
        (tester) async {
      await tester.pumpWidget(
        _host(const ItChip(label: 'Label', disabled: true)),
      );
      final box = find.descendant(
        of: find.byType(ItChip),
        matching: find.byType(Container),
      );
      expect(_boxColor(tester, box), const Color(0xFFFFFFFF));
      await hover(tester, find.byType(ItChip));
      expect(_boxColor(tester, box), const Color(0xFFFFFFFF));
    });

    // `.back-to-top:hover { background: rgb(0, 91.8, 183.6) }` — a 10% shade,
    // not the button's 15%.
    testWidgets('ItBackToTopButton darkens to rgb(0,92,184)', (tester) async {
      await tester.pumpWidget(
        _host(ItBackToTopButton(small: true, onPressed: () {})),
      );
      final box = find.descendant(
        of: find.byType(ItBackToTopButton),
        matching: find.byType(Container),
      );
      expect(_boxColor(tester, box), const Color(0xFF0066CC));
      await hover(tester, find.byType(ItBackToTopButton));
      // Same fractional-channel story as the tab below: the hover is now
      // derived from the primary token so that a retinted circle darkens with
      // it, which reproduces `rgb(0, 91.8, 183.6)` exactly instead of the
      // rounded literal this used to assert.
      expectCloseTo(_boxColor(tester, box)!, const Color(0xFF005CB8));
    });

    // `.nav-tabs .nav-link:hover { color: rgb(0, 76.5, 153) }`
    testWidgets('ItTabBar inactive tab recolours to rgb(0,77,153)',
        (tester) async {
      await tester.pumpWidget(
        _host(
          // Two tabs with the FIRST selected, hovering the second. This used
          // `selectedIndex: -1` and a single tab to get an inactive one — but
          // -1 means no tab is selected, and `inTabOrder` follows the
          // selection, so the whole tablist dropped out of the tab order and
          // was unreachable by keyboard (WCAG 2.1.1). ItTabBar now asserts
          // against it. An inactive tab beside an active one is the real
          // configuration anyway.
          ItTabBar(
            selectedIndex: 0,
            onChanged: (_) {},
            tabs: const [
              ItTabItem(label: 'Attivo'),
              ItTabItem(label: 'Link'),
            ],
          ),
        ),
      );
      Color labelColour() =>
          tester.widget<Text>(find.text('Link')).style!.color!;
      expect(labelColour(), const Color(0xFF30475F));
      await hover(tester, find.text('Link'));
      // The stylesheet declares FRACTIONAL channels here. Deriving the colour
      // from the primary token preserves them exactly; the previous hardcoded
      // literal rounded to the nearest 1/255. Compared with a tolerance because
      // which of the two a browser paints is a rounding decision, not a design
      // one — and the visual parity report is unmoved either way.
      // `rgb(0, 76.5, 153)` = shade(primary, 25%).
      expectCloseTo(labelColour(), const Color(0xFF004D99));
    });

    // The active tab carries `cursor: inherit` and no hover rule: measured on
    // the React kit, hovering it repaints nothing.
    testWidgets('ItTabBar active tab does not react to hover', (tester) async {
      await tester.pumpWidget(
        _host(
          ItTabBar(
            selectedIndex: 0,
            onChanged: (_) {},
            tabs: const [ItTabItem(label: 'Attivo')],
          ),
        ),
      );
      Color labelColour() =>
          tester.widget<Text>(find.text('Attivo')).style!.color!;
      expect(labelColour(), const Color(0xFF0066CC));
      await hover(tester, find.text('Attivo'));
      expect(labelColour(), const Color(0xFF0066CC));
    });

    // `.link-list-wrapper ul li a:hover:not(.disabled) span
    //   { color: #06c; text-decoration: underline }` with no fill change.
    testWidgets('ItList row underlines and keeps its background',
        (tester) async {
      await tester.pumpWidget(
        _host(
          ItList(items: [ItListItem(title: 'Link list 1', onTap: () {})]),
        ),
      );
      TextStyle style() => tester.widget<Text>(find.text('Link list 1')).style!;
      expect(style().decoration, TextDecoration.none);
      await hover(tester, find.text('Link list 1'));
      expect(style().decoration, TextDecoration.underline);
      expect(style().color, const Color(0xFF0066CC));
    });

    // An `.active` row brightens to the plain link colour on hover rather than
    // darkening — the opposite of what a shade formula would do.
    testWidgets('ItList active row brightens to #06c on hover', (tester) async {
      await tester.pumpWidget(
        _host(
          ItList(
            items: [
              ItListItem(title: 'Link list 1', active: true, onTap: () {}),
            ],
          ),
        ),
      );
      Color colour() =>
          tester.widget<Text>(find.text('Link list 1')).style!.color!;
      // The stylesheet declares FRACTIONAL channels here. Deriving the colour
      // from the primary token preserves them exactly; the previous hardcoded
      // literal rounded to the nearest 1/255. Compared with a tolerance because
      // which of the two a browser paints is a rounding decision, not a design
      // one — and the visual parity report is unmoved either way.
      // `rgb(0, 38.25, 76.5)` = shade(primary, 62.5%).
      expectCloseTo(colour(), const Color(0xFF00264D));
      await hover(tester, find.text('Link list 1'));
      expect(colour(), const Color(0xFF0066CC));
    });

    // `.accordion-header .accordion-button:hover
    //   { background: none; text-decoration: underline }`
    testWidgets('ItAccordion header underlines only', (tester) async {
      await tester.pumpWidget(
        _host(
          const ItAccordion(
            items: [
              ItAccordionItem(title: 'Sezione', body: SizedBox.shrink()),
            ],
          ),
        ),
      );
      TextStyle style() => tester.widget<Text>(find.text('Sezione')).style!;
      expect(style().decoration, TextDecoration.none);
      await hover(tester, find.text('Sezione'));
      expect(style().decoration, TextDecoration.underline);
      expect(style().color, const Color(0xFF0066CC));
    });

    // Higher specificity than `a:hover`, so the breadcrumb link keeps its
    // colour: measured on the React kit, hover repaints nothing.
    testWidgets('ItBreadcrumb link does not change on hover', (tester) async {
      await tester.pumpWidget(
        _host(
          ItBreadcrumb(
            items: [
              ItBreadcrumbItem(label: 'Home', onTap: () {}),
              const ItBreadcrumbItem(label: 'Pagina'),
            ],
          ),
        ),
      );
      TextStyle style() => tester.widget<Text>(find.text('Home')).style!;
      final before = style();
      await hover(tester, find.text('Home'));
      expect(style().color, before.color);
      expect(style().decoration, before.decoration);
    });

    // `.it-footer a:hover { color: hsl(0, 0%, 90%) }`
    testWidgets('ItFooter link recolours to rgb(230,230,230)', (tester) async {
      await tester.pumpWidget(
        _host(
          ItFooterLinkColumns(
            sections: [
              ItFooterSection(
                title: 'Sezione',
                links: [ItFooterLink(label: 'Link 1', onTap: () {})],
              ),
            ],
          ),
        ),
      );
      Color colour() => tester.widget<Text>(find.text('Link 1')).style!.color!;
      expect(colour(), const Color(0xFFFFFFFF));
      await hover(tester, find.text('Link 1'));
      expect(colour(), const Color(0xFFE6E6E6));
    });

    // `.it-card .it-card-link:hover { color: hsl(210, 13%, 25.2%) }` applied to
    // the category link, measured as rgb(75,90,105).
    testWidgets('ItCardCategory link darkens to rgb(75,90,105)',
        (tester) async {
      await tester.pumpWidget(
        _host(ItCardCategory(label: 'Categoria', onTap: () {})),
      );
      Color colour() =>
          tester.widget<Text>(find.text('CATEGORIA')).style!.color!;
      expect(colour(), const Color(0xFF5D7083));
      await hover(tester, find.text('CATEGORIA'));
      expect(colour(), const Color(0xFF4B5A69));
    });
  });
}

/// Equality within one 1/255 step per channel.
void expectCloseTo(Color actual, Color expected) {
  int ch(double v) => (v * 255).round();
  for (final pair in [
    [ch(actual.r), ch(expected.r)],
    [ch(actual.g), ch(expected.g)],
    [ch(actual.b), ch(expected.b)],
  ]) {
    expect((pair[0] - pair[1]).abs(), lessThanOrEqualTo(1),
        reason:
            'channel differs by more than a rounding step: $actual vs $expected');
  }
}
