// The `.nav-tabs` variants the Bootstrap Italia docs page for Tab shows, and
// this widget did not have.
//
// `ItTabBar` arrived with four parameters — tabs, index, callback, style — and
// the docs page has some two dozen sections: full-width, icon-only, large-icon,
// icon-plus-text, vertical, vertical-with-background, bottom, right, dark,
// card and editable-card. None of the rest could be expressed at all, so the
// example app could not show what the docs show.
//
// Each group below asserts the value the stylesheet declares, that the variant
// is OFF unless asked for, and — where the value is a palette token — that it
// follows a retinted scheme rather than staying Blu Italia.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child,
    {BootstrapItaliaColorScheme? colors, double w = 800}) {
  final data = BootstrapItaliaThemeData(
      colors: colors ?? BootstrapItaliaColorScheme.standard);
  return BootstrapItaliaTheme(
    data: data,
    child: MaterialApp(
      theme: data.toThemeData(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: w, child: child),
        ),
      ),
    ),
  );
}

/// The decoration of the tab whose content is [of].
BoxDecoration _decoration(WidgetTester tester, Finder of) {
  final container = tester.widget<Container>(
      find.ancestor(of: of, matching: find.byType(Container)).first);
  return container.decoration! as BoxDecoration;
}

/// The four sides of the tab whose content is [of].
Border _border(WidgetTester tester, Finder of) =>
    _decoration(tester, of).border! as Border;

/// The padding of the tab whose content is [of].
EdgeInsets _padding(WidgetTester tester, Finder of) {
  final container = tester.widget<Container>(
      find.ancestor(of: of, matching: find.byType(Container)).first);
  return (container.padding! as EdgeInsetsDirectional)
      .resolve(TextDirection.ltr);
}

const _purple = Color(0xFF7A1FA2);

const _tabs = [
  ItTabItem(label: 'Uno'),
  ItTabItem(label: 'Due'),
  ItTabItem(label: 'Tre'),
];

const _iconTabs = [
  ItTabItem(label: 'Collegamenti', icon: BootstrapItaliaIcons.it_link),
  ItTabItem(label: 'Calendario', icon: BootstrapItaliaIcons.it_calendar),
];

void main() {
  _narrowIconBar();
  _fullWidthHeights();
  group('fullWidth — `.nav-tabs.auto`', () {
    testWidgets('every tab takes an equal share of the width', (t) async {
      await t.pumpWidget(_host(const ItTabBar(tabs: _tabs, fullWidth: true)));
      final widths = [
        for (final label in ['Uno', 'Due', 'Tre'])
          t
              .getSize(find
                  .ancestor(
                      of: find.text(label), matching: find.byType(Container))
                  .first)
              .width,
      ];
      expect(widths[0], moreOrLessEquals(800 / 3, epsilon: 1),
          reason: '`.nav-tabs.auto .nav-item { flex: 1 }` — a flex basis of 0, '
              'so the share is equal regardless of label length');
      expect(widths[1], moreOrLessEquals(widths[0], epsilon: 1));
      expect(widths[2], moreOrLessEquals(widths[0], epsilon: 1));
    });

    testWidgets('off by default: tabs are sized to their content', (t) async {
      await t.pumpWidget(_host(const ItTabBar(tabs: _tabs)));
      final uno = t.getSize(find
          .ancestor(of: find.text('Uno'), matching: find.byType(Container))
          .first);
      expect(uno.width, lessThan(800 / 3),
          reason:
              'without `.auto` the kit sizes each `.nav-item` to its label');
    });

    testWidgets('a bar wider than its container scrolls instead of throwing',
        (t) async {
      // `.nav-tabs { overflow-x: auto; flex-wrap: nowrap }`. Before this the
      // tabs were a bare Row: eight of them in a 300px box was a RenderFlex
      // overflow and a screen of debug stripes.
      await t.pumpWidget(_host(
        const ItTabBar(
          tabs: [
            ItTabItem(label: 'Anagrafe'),
            ItTabItem(label: 'Tributi'),
            ItTabItem(label: 'Edilizia'),
            ItTabItem(label: 'Ambiente'),
            ItTabItem(label: 'Cultura'),
            ItTabItem(label: 'Sport'),
          ],
        ),
        w: 300,
      ));
      expect(t.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('placement — where the bar sits, and which edge carries the rule', () {
    testWidgets('top: a 3px indicator on the bottom edge (the default)',
        (t) async {
      await t.pumpWidget(_host(const ItTabBar(tabs: _tabs)));
      final side = _border(t, find.text('Uno')).bottom;
      expect(side.width, 3,
          reason: '`.nav-tabs .nav-link { border-bottom: 3px solid … }`');
      expect(side.color, BootstrapItaliaColors.primary);
      expect(_border(t, find.text('Due')).bottom.color, const Color(0x00000000),
          reason: 'an inactive tab reserves the strip but does not paint it');
    });

    testWidgets('bottom: a 2px indicator on the top edge', (t) async {
      await t.pumpWidget(_host(
        const ItTabBar(tabs: _tabs, placement: ItTabPlacement.bottom),
      ));
      final border = _border(t, find.text('Uno'));
      expect(border.top.width, 2,
          reason: '`.flex-column-reverse .nav-tabs .nav-link '
              '{ border-top: 2px solid … }` — thinner than the 3px the '
              'top-placed bar uses');
      expect(border.top.color, BootstrapItaliaColors.primary);
      expect(border.bottom, BorderSide.none,
          reason: 'the same rule sets `border-bottom: none` — no strip is '
              'reserved on the edge the indicator has left');
    });

    testWidgets('start: a 2px indicator on the trailing edge', (t) async {
      await t.pumpWidget(_host(
        const ItTabBar(tabs: _tabs, placement: ItTabPlacement.start),
      ));
      final border = _border(t, find.text('Uno'));
      expect(border.right.width, 2,
          reason:
              '`.nav-tabs-vertical .nav-link { border-right: 2px solid … }`');
      expect(border.right.color, BootstrapItaliaColors.primary);

      // The tabs stack rather than sitting in a row.
      expect(t.getTopLeft(find.text('Due')).dy,
          greaterThan(t.getTopLeft(find.text('Uno')).dy));
      expect(
          t.getTopLeft(find.text('Due')).dx, t.getTopLeft(find.text('Uno')).dx);
    });

    testWidgets('end: a 2px indicator on the leading edge', (t) async {
      await t.pumpWidget(_host(
        const ItTabBar(tabs: _tabs, placement: ItTabPlacement.end),
      ));
      final border = _border(t, find.text('Uno'));
      expect(border.left.width, 2,
          reason: '`.flex-row-reverse .nav-tabs-vertical .nav-link '
              '{ border-left: 2px solid … }`');
      expect(border.left.color, BootstrapItaliaColors.primary);
      expect(border.right, BorderSide.none,
          reason: '`border-right: none` — the rule moves to the other edge');
    });

    testWidgets('a vertical bar puts the icon on the side the kit does',
        (t) async {
      // `.nav-tabs-vertical .nav-link { justify-content: space-between }` with
      // the markup `Tab 1 <svg>` — label first, icon at the trailing edge.
      // Flipped for the right-hand bar, whose markup is `<svg> Tab 1` under
      // `justify-content: flex-start`.
      await t.pumpWidget(_host(
        const ItTabBar(tabs: _iconTabs, placement: ItTabPlacement.start),
      ));
      expect(
        t.getCenter(find.byIcon(BootstrapItaliaIcons.it_link)).dx,
        greaterThan(t.getCenter(find.text('Collegamenti')).dx),
      );

      await t.pumpWidget(_host(
        const ItTabBar(tabs: _iconTabs, placement: ItTabPlacement.end),
      ));
      expect(
        t.getCenter(find.byIcon(BootstrapItaliaIcons.it_link)).dx,
        lessThan(t.getCenter(find.text('Collegamenti')).dx),
      );
    });

    testWidgets('the indicator re-themes on every placement', (t) async {
      for (final placement in ItTabPlacement.values) {
        await t.pumpWidget(_host(
          ItTabBar(tabs: _tabs, placement: placement),
          colors:
              BootstrapItaliaColorScheme.standard.copyWith(primary: _purple),
        ));
        final border = _border(t, find.text('Uno'));
        final side = switch (placement) {
          ItTabPlacement.top => border.bottom,
          ItTabPlacement.bottom => border.top,
          ItTabPlacement.start => border.right,
          ItTabPlacement.end => border.left,
        };
        expect(side.color, _purple,
            reason:
                'the indicator is `#06c`, the primary token, on $placement');
      }
    });
  });

  group('verticalBackground — `.nav-tabs-vertical-background`', () {
    testWidgets('fills the active tab with hsl(210,62%,97%)', (t) async {
      await t.pumpWidget(_host(const ItTabBar(
        tabs: _tabs,
        placement: ItTabPlacement.start,
        verticalBackground: true,
      )));
      expect(_decoration(t, find.text('Uno')).color, const Color(0xFFF3F7FC));
      expect(_decoration(t, find.text('Due')).color, isNull,
          reason: 'only `.nav-link.active` takes the fill');
    });

    testWidgets('off by default', (t) async {
      await t.pumpWidget(_host(const ItTabBar(
        tabs: _tabs,
        placement: ItTabPlacement.start,
      )));
      expect(_decoration(t, find.text('Uno')).color, isNull);
    });

    testWidgets('does not follow a retinted palette', (t) async {
      // Declared as `.lightgrey-bg-a3`, a near-white tint rather than any
      // semantic role. An administration retinting `primary` wants a blue
      // indicator, not a blue-tinted band behind every selected row.
      await t.pumpWidget(_host(
        const ItTabBar(
          tabs: _tabs,
          placement: ItTabPlacement.start,
          verticalBackground: true,
        ),
        colors: BootstrapItaliaColorScheme.standard.copyWith(primary: _purple),
      ));
      expect(_decoration(t, find.text('Uno')).color, const Color(0xFFF3F7FC));
    });

    testWidgets('setting it on a horizontal bar is a build error', (t) async {
      await t.pumpWidget(
          _host(const ItTabBar(tabs: _tabs, verticalBackground: true)));
      expect(
        t.takeException(),
        isA<AssertionError>().having((e) => e.message.toString(), 'message',
            contains('no effect on a horizontal bar')),
      );
    });
  });

  group('dark — `.nav-dark`', () {
    Color labelColour(WidgetTester t, String s) =>
        t.widget<Text>(find.text(s)).style!.color!;

    testWidgets('a dark band with light labels and a cyan indicator',
        (t) async {
      await t.pumpWidget(_host(const ItTabBar(
        tabs: [
          ItTabItem(label: 'Uno'),
          ItTabItem(label: 'Due'),
          ItTabItem(label: 'Tre', disabled: true),
        ],
        dark: true,
      )));

      final band = t.widget<ColoredBox>(find
          .ancestor(of: find.byType(Stack), matching: find.byType(ColoredBox))
          .first);
      expect(band.color, const Color(0xFF455B71),
          reason: '`.nav-tabs.nav-dark { background-color: '
              'rgb(69.021615, 90.9933075, 112.965) }`');

      expect(labelColour(t, 'Uno'), const Color(0xFF00FFF7),
          reason: '`.nav-dark .nav-link.active { color: rgb(0,255,246.5) }` — '
              '`--bs-cyan`');
      expect(labelColour(t, 'Due'), const Color(0xFFD9DADB),
          reason: '`.nav-dark .nav-link { color: rgb(217.107,…) }`');
      expect(labelColour(t, 'Tre'), const Color(0xFF768594),
          reason: '`.nav-dark .nav-link.disabled { color: rgb(118.32,…) }` — '
              'NOT the light bar\'s hsl(210,3%,85%), which would vanish here');

      expect(_border(t, find.text('Uno')).bottom.width, 2,
          reason: '`.nav-dark .nav-link.active { border-bottom: 2px }`');
    });

    testWidgets('the dark bar drops the container rule', (t) async {
      await t.pumpWidget(_host(const ItTabBar(tabs: _tabs, dark: true)));
      // `.nav-tabs.nav-dark { border-bottom: none }` — the hairline would be
      // invisible on the band anyway, and the kit removes it rather than
      // recolouring it.
      expect(
        find.descendant(
          of: find.byType(ItTabBar),
          matching: find.byWidgetPredicate(
              (w) => w is ColoredBox && w.color == const Color(0xFFC5C7C9)),
        ),
        findsNothing,
      );
    });

    testWidgets('stays the kit\'s chrome under a retinted palette', (t) async {
      // None of `.nav-dark`'s four colours is in BootstrapItaliaColorScheme,
      // and that is the honest answer rather than an oversight: the band is a
      // fixed dark surface, not a themed one. Recolouring the label to a
      // retinted primary while the band stayed rgb(69,91,113) is how this
      // variant would lose its contrast.
      await t.pumpWidget(_host(
        const ItTabBar(tabs: _tabs, dark: true),
        colors: BootstrapItaliaColorScheme.standard.copyWith(primary: _purple),
      ));
      expect(labelColour(t, 'Uno'), const Color(0xFF00FFF7));
      expect(
          _border(t, find.text('Uno')).bottom.color, const Color(0xFF00FFF7));
    });

    testWidgets('off by default', (t) async {
      await t.pumpWidget(_host(const ItTabBar(tabs: _tabs)));
      expect(labelColour(t, 'Due'), const Color(0xFF30475F));
    });
  });

  group('layout — icons', () {
    testWidgets('iconOnly hides the label and draws a 32px `.icon`', (t) async {
      await t.pumpWidget(_host(const ItTabBar(
        tabs: _iconTabs,
        layout: ItTabLayout.iconOnly,
      )));
      expect(find.text('Collegamenti'), findsNothing,
          reason: 'the kit puts the label in `<span class="visually-hidden">`; '
              'it is the accessible name, not painted text');
      expect(t.widget<Icon>(find.byIcon(BootstrapItaliaIcons.it_link)).size, 32,
          reason: '`.icon { width: 32px; height: 32px }`');
    });

    testWidgets('iconOnlyLarge draws a 48px icon in a wider tab', (t) async {
      await t.pumpWidget(_host(const ItTabBar(
        tabs: _iconTabs,
        layout: ItTabLayout.iconOnlyLarge,
      )));
      expect(t.widget<Icon>(find.byIcon(BootstrapItaliaIcons.it_link)).size, 48,
          reason: '`.icon.icon-lg { width: 48px; height: 48px }`');
      // The padding is a pair of flexible spacers, so it is read as the gap
      // between the tab's edge and the glyph.
      final icon = find.byIcon(BootstrapItaliaIcons.it_link);
      final tab =
          find.ancestor(of: icon, matching: find.byType(Container)).first;
      final padding = t.getTopLeft(icon).dx - t.getTopLeft(tab).dx;
      expect(padding, moreOrLessEquals(1.778 * 18, epsilon: 0.001),
          reason: '`.nav-tabs-icon-lg .nav-link { padding: .778rem 1.778em }` '
              'against the base 1.333em — the wider tab is what stops 48px '
              'glyphs colliding');
    });

    testWidgets('iconAndText opens .5rem between the icon and the label',
        (t) async {
      await t.pumpWidget(_host(const ItTabBar(
        tabs: _iconTabs,
        layout: ItTabLayout.iconAndText,
      )));
      final gap = t.getTopLeft(find.text('Collegamenti')).dx -
          t.getTopRight(find.byIcon(BootstrapItaliaIcons.it_link)).dx;
      expect(gap, moreOrLessEquals(8, epsilon: 0.01),
          reason: '`.nav-tabs-icon-text .icon { margin-right: .5rem }`');
    });

    testWidgets('the default layout sets icon and label flush', (t) async {
      // Only `.nav-tabs-icon-text` buys the gap. Plain `.nav-tabs` markup with
      // an icon and a label puts them side by side with nothing between, which
      // is what the design kit's own rendering shows.
      await t.pumpWidget(_host(const ItTabBar(tabs: _iconTabs)));
      final gap = t.getTopLeft(find.text('Collegamenti')).dx -
          t.getTopRight(find.byIcon(BootstrapItaliaIcons.it_link)).dx;
      expect(gap, moreOrLessEquals(0, epsilon: 0.01));
    });

    testWidgets('an icon-only tab with no icon is a build error', (t) async {
      await t.pumpWidget(_host(const ItTabBar(
        tabs: [ItTabItem(label: 'Senza icona')],
        layout: ItTabLayout.iconOnly,
      )));
      expect(
        t.takeException(),
        isA<AssertionError>().having((e) => e.message.toString(), 'message',
            contains('draws nothing at all')),
      );
    });

    testWidgets('the icon takes the resting grey, then the primary', (t) async {
      await t.pumpWidget(_host(const ItTabBar(tabs: _iconTabs)));
      expect(
        t.widget<Icon>(find.byIcon(BootstrapItaliaIcons.it_link)).color,
        BootstrapItaliaColors.primary,
        reason: '`.nav-tabs .nav-link.active .icon { fill: #06c }`',
      );
      expect(
        t.widget<Icon>(find.byIcon(BootstrapItaliaIcons.it_calendar)).color,
        BootstrapItaliaColors.secondary,
        reason: '`.nav-tabs .nav-link .icon { fill: hsl(210,17%,44%) }`',
      );
    });
  });

  group('editable — `.nav-tabs-editable`', () {
    testWidgets('a close control removes its own tab without selecting it',
        (t) async {
      // The kit makes the close a sibling `<a>` of the tab, not a child, and
      // the distinction is the whole behaviour: pressing it must remove the
      // tab, not switch to it.
      var closed = -1;
      var selected = -1;
      await t.pumpWidget(_host(ItTabBar(
        selectedIndex: 0,
        onChanged: (i) => selected = i,
        tabs: [
          const ItTabItem(label: 'Uno'),
          ItTabItem(
            label: 'Due',
            onClose: () => closed = 1,
            closeLabel: 'Chiudi la scheda Due',
          ),
        ],
      )));

      await t.tap(find.bySemanticsLabel('Chiudi la scheda Due'));
      await t.pumpAndSettle();
      expect(closed, 1);
      expect(selected, -1, reason: 'the close is not the tab');
    });

    testWidgets('the tab reserves 2.888em for the control', (t) async {
      await t.pumpWidget(_host(ItTabBar(
        tabs: [
          ItTabItem(label: 'Uno', onClose: () {}, closeLabel: 'Chiudi Uno'),
        ],
      )));
      final padding = _padding(t, find.text('Uno'));
      expect(padding.right, moreOrLessEquals(2.888 * 18, epsilon: 0.001),
          reason:
              '`.nav-tabs-editable .nav-link { padding-right: 2.888em }` — the '
              'close is absolutely positioned over this, so without the room '
              'it would sit on top of the label');
      expect(padding.left, moreOrLessEquals(1.333 * 18, epsilon: 0.001),
          reason: 'only the right side is widened');
    });

    testWidgets('a closable tab without a closeLabel is a compile-time error',
        (t) async {
      // The assert lives in the `const` constructor, so a const call site fails
      // to compile rather than to run. This exercises the non-const path.
      expect(
        () => ItTabItem(label: 'Uno', onClose: () {}),
        throwsA(isA<AssertionError>().having(
            (e) => e.message.toString(), 'message', contains('closeLabel'))),
      );
    });

    testWidgets('the add control is named, and is not one of the tabs',
        (t) async {
      var added = false;
      await t.pumpWidget(_host(ItTabBar(
        tabs: _tabs,
        style: ItTabStyle.card,
        onAddTab: () => added = true,
        addTabLabel: 'Aggiungi una scheda',
      )));
      await t.tap(find.bySemanticsLabel('Aggiungi una scheda'));
      await t.pumpAndSettle();
      expect(added, isTrue);
      expect(t.takeException(), isNull,
          reason: 'a `tablist` may contain nothing but tabs — Flutter asserts '
              'it, so the add control has to be a sibling of the tab bar node '
              'rather than a child of it');
    });

    testWidgets('onAddTab without a label is a build error', (t) async {
      expect(
        () => ItTabBar(tabs: _tabs, onAddTab: () {}),
        throwsA(isA<AssertionError>().having(
            (e) => e.message.toString(), 'message', contains('addTabLabel'))),
      );
    });
  });

  group('card — `.nav-tabs-cards`', () {
    testWidgets('the active card opens into the panel below it', (t) async {
      await t.pumpWidget(
          _host(const ItTabBar(tabs: _tabs, style: ItTabStyle.card)));
      final active = _border(t, find.text('Uno'));
      expect(active.top.color, const Color(0xFFC5C7C9));
      expect(active.bottom, BorderSide.none,
          reason: '`.nav-tabs-cards .nav-link.active '
              '{ border-bottom-color: transparent }` — the join with the '
              'panel. Declared as an absent side rather than a transparent '
              'one, because Border refuses a border radius unless every '
              'visible side shares a colour');
      expect(_padding(t, find.text('Uno')).bottom,
          _padding(t, find.text('Due')).bottom + 1,
          reason: 'the pixel the transparent bottom rule would have occupied '
              'is taken as padding instead, so the active card is exactly as '
              'tall as an inactive one carrying a 2px rule — otherwise the row '
              'of cards is 1px ragged');

      final inactive = _border(t, find.text('Due'));
      expect(inactive.bottom.width, 2);
      expect(inactive.bottom.color, const Color(0xFFC5C7C9));
    });

    testWidgets('cards are all the same height', (t) async {
      await t.pumpWidget(
          _host(const ItTabBar(tabs: _tabs, style: ItTabStyle.card)));
      final heights = [
        for (final label in ['Uno', 'Due', 'Tre'])
          t
              .getSize(find
                  .ancestor(
                      of: find.text(label), matching: find.byType(Container))
                  .first)
              .height,
      ];
      expect(heights.toSet(), hasLength(1));
    });
  });
}

void _fullWidthHeights() {
  testWidgets(
      'fullWidth tabs are all as tall as the tallest, so the '
      'indicators share one baseline', (tester) async {
    await tester.pumpWidget(_host(
      ItTabBar(
        fullWidth: true,
        tabs: const [
          ItTabItem(label: 'Attivo lungo lungo'),
          ItTabItem(label: 'Link'),
        ],
        selectedIndex: 1,
        onChanged: (_) {},
      ),
      w: 200,
    ));
    final a = tester.getSize(find
        .ancestor(
            of: find.text('Attivo lungo lungo'),
            matching: find.byType(Container))
        .first);
    final b = tester.getSize(find
        .ancestor(of: find.text('Link'), matching: find.byType(Container))
        .first);
    expect(a.height, greaterThan(60));
    expect(b.height, a.height);
  });
}

void _narrowIconBar() {
  testWidgets(
      'a narrow fullWidth icon-only bar gives padding back rather '
      'than overflowing', (tester) async {
    await tester.pumpWidget(_host(
      ItTabBar(
        layout: ItTabLayout.iconOnlyLarge,
        fullWidth: true,
        tabs: [
          for (var i = 0; i < 4; i++) ItTabItem(label: 'T$i', icon: Icons.star),
        ],
        selectedIndex: 0,
        onChanged: (_) {},
      ),
      w: 340,
    ));
    expect(tester.takeException(), isNull);
  });
}
