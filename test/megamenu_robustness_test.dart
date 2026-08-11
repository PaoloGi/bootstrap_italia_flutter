// Defects found while splitting `it_megamenu.dart` into five files.
//
// The split itself was a pure move — all 74 parity captures came out
// byte-identical — but reading 1262 lines closely surfaced these. They are
// filed together because they share a cause: the desktop and mobile paths grew
// separately, so each one's fix was never applied to the other.
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

List<ItMegamenuSection> _sections(int n) => [
      for (var i = 0; i < n; i++)
        ItMegamenuSection(
          label: 'Sezione $i',
          columns: [
            ItMegamenuColumn(
              links: [ItMegamenuLink(label: 'Link $i', onTap: () {})],
            ),
          ],
        ),
    ];

/// Sets the render surface AND the view, then hosts [child].
///
/// Both are needed: `MediaQuery(size:)` alone tells the widget it has 1280px
/// while the surface stays at Flutter's 800x600 default, so a desktop bar
/// laid out for 1280 overflows a real 800 and the test fails on a RenderFlex
/// assertion rather than on what it meant to check. The same mismatch once
/// made every parity capture render its mobile layout.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(1280, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an empty megamenu does not crash on mobile', (t) async {
    // The desktop path degraded silently via List.generate(0); the mobile path
    // called `firstWhere(orElse: () => sections.first)`, and `.first` on an
    // empty list throws StateError. Same input, two behaviours, one a crash.
    await _pump(t, const ItMegamenu(sections: []), size: const Size(480, 800));
    expect(t.takeException(), isNull);
  });

  testWidgets('shrinking sections while a panel is open does not RangeError',
      (t) async {
    await _pump(t, ItMegamenu(sections: _sections(3)));
    await t.tap(find.text('Sezione 2'));
    await t.pumpAndSettle();
    expect(find.text('Link 2'), findsOneWidget, reason: 'panel 2 is open');

    // `_openSectionIndex` is an index; a shorter list leaves it past the end.
    await _pump(t, ItMegamenu(sections: _sections(1)));
    expect(t.takeException(), isNull,
        reason: 'sections[_openSectionIndex!] would throw RangeError on the '
            'next build — while a panel is open, i.e. exactly when someone is '
            'using it');
  });

  testWidgets('the desktop chevron flips when its section opens', (t) async {
    // `a.dropdown-toggle[aria-expanded=true] > .icon { transform: scaleY(-1) }`.
    // The mobile tile already rotated; the desktop button painted a static
    // glyph, so for a sighted mouse user the only signal a section was open was
    // the panel itself.
    await _pump(t, ItMegamenu(sections: _sections(2)));

    double turnsFor(String label) {
      final rotation = t.widget<AnimatedRotation>(find
          .ancestor(
              of: find.byIcon(BootstrapItaliaIcons.it_expand),
              matching: find.byType(AnimatedRotation))
          .first);
      return rotation.turns;
    }

    expect(turnsFor('Sezione 0'), 0.0, reason: 'closed');
    await t.tap(find.text('Sezione 0'));
    await t.pumpAndSettle();
    expect(turnsFor('Sezione 0'), 0.5, reason: 'open — scaleY(-1)');
  });

  testWidgets('§2.4.3: Tab leaves an open toggle for its own panel', (t) async {
    // The panel is a sibling *after* the whole bar, because that is what stacks
    // it below on screen. In the kit it is a child of its own `li`, so Tab goes
    // toggle -> that panel's links. Here it went toggle -> every remaining
    // toggle -> the panel: with six sections, five unrelated controls between
    // you and the thing you just opened.
    await _pump(t, ItMegamenu(sections: _sections(4)));

    await t.tap(find.text('Sezione 0'));
    await t.pumpAndSettle();
    expect(find.text('Link 0'), findsOneWidget);

    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();

    // Ask the focused node's own context whether it sits inside the panel.
    // Matching `Focus` widgets by node does not work here: the panel's links
    // focus through ItActivatable's FocusableActionDetector, whose node is
    // created internally and is not the one on any Focus widget in the tree.
    var inPanel = false;
    primaryFocus?.context?.visitAncestorElements((e) {
      if (e.widget is ItMegamenuPanel) {
        inPanel = true;
        return false;
      }
      return true;
    });

    expect(inPanel, isTrue,
        reason: 'after the open toggle, focus must reach that panel before the '
            'other section toggles (WCAG 2.1 SC 2.4.3 Focus Order)');
  });
}
