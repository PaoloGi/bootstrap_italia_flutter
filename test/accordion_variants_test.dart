// `.accordion-background-active` and `.accordion-left-icon`.
//
// Both come from the Bootstrap Italia docs page for Accordion, which the
// example app mirrors. Neither existed here before, so the example could not
// show what the docs show.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {BootstrapItaliaColorScheme? colors}) {
  final data = BootstrapItaliaThemeData(
      colors: colors ?? BootstrapItaliaColorScheme.standard);
  return BootstrapItaliaTheme(
    data: data,
    child: MaterialApp(
      theme: data.toThemeData(),
      home: Scaffold(body: SizedBox(width: 600, child: child)),
    ),
  );
}

/// The fill of the header containing [title].
Color? _headerFill(WidgetTester tester, String title) {
  final container = tester.widget<Container>(find
      .ancestor(of: find.text(title), matching: find.byType(Container))
      .first);
  return (container.decoration as BoxDecoration?)?.color;
}

void main() {
  group('backgroundActive — `.accordion-background-active`', () {
    testWidgets('an expanded header takes the primary fill', (t) async {
      await t.pumpWidget(_host(const ItAccordion(
        backgroundActive: true,
        items: [
          ItAccordionItem(
              title: 'Aperta', body: Text('x'), initiallyExpanded: true),
          ItAccordionItem(title: 'Chiusa', body: Text('y')),
        ],
      )));
      await t.pumpAndSettle();

      expect(_headerFill(t, 'Aperta'), BootstrapItaliaColors.primary,
          reason: '`[aria-expanded=true] { background-color: #06c }`');
      expect(_headerFill(t, 'Chiusa'), const Color(0xFFFFFFFF),
          reason: 'a collapsed header keeps the card surface');
    });

    testWidgets('the label reverses out in white', (t) async {
      await t.pumpWidget(_host(const ItAccordion(
        backgroundActive: true,
        items: [
          ItAccordionItem(
              title: 'Aperta', body: Text('x'), initiallyExpanded: true),
        ],
      )));
      await t.pumpAndSettle();

      expect(t.widget<Text>(find.text('Aperta')).style?.color,
          const Color(0xFFFFFFFF),
          reason: '`color: #fff` — without it the secondary grey-blue sits on '
              'the primary fill at about 1.9:1');
    });

    testWidgets('the band and its label re-theme together', (t) async {
      // The band IS the primary token here, so its foreground has to follow.
      // Retinting one without the other is how this variant loses its contrast.
      const purple = Color(0xFF7A1FA2);
      const paper = Color(0xFFFFF8E1);
      await t.pumpWidget(_host(
        const ItAccordion(
          backgroundActive: true,
          items: [
            ItAccordionItem(
                title: 'Aperta', body: Text('x'), initiallyExpanded: true),
          ],
        ),
        colors: BootstrapItaliaColorScheme.standard
            .copyWith(primary: purple, white: paper),
      ));
      await t.pumpAndSettle();

      expect(_headerFill(t, 'Aperta'), purple);
      expect(t.widget<Text>(find.text('Aperta')).style?.color, paper);
    });

    testWidgets('off by default', (t) async {
      await t.pumpWidget(_host(const ItAccordion(items: [
        ItAccordionItem(
            title: 'Aperta', body: Text('x'), initiallyExpanded: true),
      ])));
      await t.pumpAndSettle();
      expect(_headerFill(t, 'Aperta'), const Color(0xFFFFFFFF));
    });
  });

  group('leftIcon — `.accordion-left-icon`', () {
    testWidgets('shows + collapsed and − expanded, and no chevron', (t) async {
      await t.pumpWidget(_host(const ItAccordion(
        leftIcon: true,
        items: [ItAccordionItem(title: 'Sezione', body: Text('x'))],
      )));
      await t.pumpAndSettle();

      expect(find.text('+'), findsOneWidget,
          reason: '`:before { content: "+" }`');
      expect(find.byIcon(BootstrapItaliaIcons.it_expand), findsNothing,
          reason: '`:after { content: none }` — the two are alternatives, and '
              'showing both would give one control two indicators');

      await t.tap(find.text('Sezione'));
      await t.pumpAndSettle();
      expect(find.text('-'), findsOneWidget);
      expect(find.text('+'), findsNothing);
    });

    testWidgets('the glyph box is fixed so the title never shifts', (t) async {
      // `+` and `−` have different advance widths, so without a fixed box the
      // title would jog sideways on every toggle.
      await t.pumpWidget(_host(const ItAccordion(
        leftIcon: true,
        items: [ItAccordionItem(title: 'Sezione', body: Text('x'))],
      )));
      await t.pumpAndSettle();
      final collapsed = t.getTopLeft(find.text('Sezione'));

      await t.tap(find.text('Sezione'));
      await t.pumpAndSettle();
      expect(t.getTopLeft(find.text('Sezione')), collapsed);
    });

    testWidgets('the chevron is the default', (t) async {
      await t.pumpWidget(_host(const ItAccordion(
        items: [ItAccordionItem(title: 'Sezione', body: Text('x'))],
      )));
      await t.pumpAndSettle();
      expect(find.byIcon(BootstrapItaliaIcons.it_expand), findsOneWidget);
      expect(find.text('+'), findsNothing);
    });
  });

  testWidgets('§4.1.2: neither variant changes what is announced', (t) async {
    // The indicator is decoration in both cases — `expanded` is what carries
    // the state, and it must not start depending on which variant is in use.
    final handle = t.ensureSemantics();
    await t.pumpWidget(_host(const ItAccordion(
      leftIcon: true,
      backgroundActive: true,
      items: [ItAccordionItem(title: 'Sezione', body: Text('x'))],
    )));
    await t.pumpAndSettle();

    final data =
        t.getSemantics(find.bySemanticsLabel('Sezione')).getSemanticsData();
    expect(data.label, 'Sezione');
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasFlag(SemanticsFlag.isHeader), isTrue);
    expect(data.hasFlag(SemanticsFlag.hasExpandedState), isTrue,
        reason: 'the state is carried by `expanded`, not by which indicator '
            'happens to be drawn');
    expect(data.hasFlag(SemanticsFlag.isExpanded), isFalse);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    handle.dispose();
  });

  _keyboard();
}

// ── Keyboard navigation ─────────────────────────────────────────────────────
//
// The kit's docs describe Up/Down/Home/End movement between headers under
// *Attivazione tramite codice*. This accordion implemented none of it: Tab
// reached a header, and from there a keyboard user had no idiomatic way to move
// between them. Found while mirroring the docs page in the example app.
void _keyboard() {
  Widget host(Widget child) => MaterialApp(
        home: Scaffold(body: SizedBox(width: 600, child: child)),
      );

  const items = [
    ItAccordionItem(title: 'Prima', body: Text('a')),
    ItAccordionItem(title: 'Seconda', body: Text('b')),
    ItAccordionItem(title: 'Terza', body: Text('c')),
  ];

  /// The title of the header that currently has focus.
  ///
  /// Matched by geometry. The header focuses through `ItActivatable`'s
  /// `FocusableActionDetector`, whose node is created internally, so neither
  /// matching `Focus` widgets by node nor walking the element tree finds it —
  /// but `primaryFocus.rect` is the focused node's box, and the header that
  /// contains it is the one with focus.
  String? focusedTitle(WidgetTester tester) {
    final rect = primaryFocus?.rect;
    if (rect == null) return null;
    for (final title in ['Prima', 'Seconda', 'Terza']) {
      final label = find.text(title);
      if (label.evaluate().isEmpty) continue;
      if (rect.contains(tester.getCenter(label))) return title;
    }
    return null;
  }

  group('keyboard navigation between headers', () {
    testWidgets('Down and Up move focus, wrapping', (t) async {
      await t.pumpWidget(host(const ItAccordion(items: items)));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(focusedTitle(t), 'Prima');

      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.pumpAndSettle();
      expect(focusedTitle(t), 'Seconda');

      await t.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await t.pumpAndSettle();
      expect(focusedTitle(t), 'Prima');

      await t.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await t.pumpAndSettle();
      expect(focusedTitle(t), 'Terza', reason: 'wraps at the top');
    });

    testWidgets('Home and End jump to the ends', (t) async {
      await t.pumpWidget(host(const ItAccordion(items: items)));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();

      await t.sendKeyEvent(LogicalKeyboardKey.end);
      await t.pumpAndSettle();
      expect(focusedTitle(t), 'Terza');

      await t.sendKeyEvent(LogicalKeyboardKey.home);
      await t.pumpAndSettle();
      expect(focusedTitle(t), 'Prima');
    });

    testWidgets('arrowing does NOT open a panel', (t) async {
      // The difference from the tab pattern, and the reason they are not the
      // same code: tabs change selection as focus moves, an accordion header is
      // a disclosure button. Conflating them would expand panels the user never
      // asked for.
      await t.pumpWidget(host(const ItAccordion(items: items)));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.pumpAndSettle();

      final handle = t.ensureSemantics();
      final data =
          t.getSemantics(find.bySemanticsLabel('Seconda')).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isExpanded), isFalse,
          reason: 'focus moved onto it; nothing opened it');
      handle.dispose();
    });
  });
}
