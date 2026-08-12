// `.large`, `.right-icon`, `.full-width` and `.dropdown-menu.dark`.
//
// All four come from the Bootstrap Italia docs page for Dropdown, which the
// example app mirrors. None existed here before, so the example could not show
// what the docs show.
//
// Every one of them is presentation: none adds, removes or changes a role, a
// name, a state or a key binding. That claim is the reason the a11y group at
// the bottom exists — a "purely visual" variant that quietly drops the button
// role is precisely the defect this package has been bitten by before.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => _wrap(SizedBox(width: 600, child: child));

/// A host that leaves the panel free to size itself.
///
/// [_host] hands its child a *tight* 600px width, which `Container(width:)`
/// cannot narrow — a tight parent constraint always wins. The `.full-width`
/// panel is exactly the case where its own width is the thing under test, so
/// those tests need loose constraints, which [Align] supplies.
Widget _looseHost(Widget child) =>
    _wrap(Align(alignment: Alignment.topLeft, child: child));

Widget _wrap(Widget child) {
  final data = BootstrapItaliaThemeData.standard();
  return BootstrapItaliaTheme(
    data: data,
    child: MaterialApp(
      theme: data.toThemeData(),
      home: Scaffold(body: child),
    ),
  );
}

/// The fill of the panel containing [label].
Color? _panelFill(WidgetTester tester, String label) {
  final container = tester.widget<Container>(
    find.ancestor(of: find.text(label), matching: find.byType(Container)).last,
  );
  return (container.decoration as BoxDecoration?)?.color;
}

TextStyle? _styleOf(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style;

/// The height of the row box that holds [label].
double _rowHeight(WidgetTester tester, String label) {
  final box = tester.widget<SizedBox>(
    find.ancestor(of: find.text(label), matching: find.byType(SizedBox)).first,
  );
  return box.height!;
}

void main() {
  group('large — `.link-list-wrapper ul li a.large`', () {
    testWidgets('the label grows to 1.125rem', (t) async {
      await t.pumpWidget(_host(ItDropdownMenu(items: [
        ItDropdownItem(label: 'Normale', onTap: () {}),
        ItDropdownItem(label: 'Grande', large: true, onTap: () {}),
      ])));

      expect(_styleOf(t, 'Normale')?.fontSize, 16,
          reason: '`.link-list-wrapper ul li a { font-size: 1rem }`');
      expect(_styleOf(t, 'Grande')?.fontSize, 18,
          reason: '`… a.large { font-size: 1.125rem }`');
    });

    testWidgets('the row gains 8px, not the line box', (t) async {
      await t.pumpWidget(_host(ItDropdownMenu(items: [
        ItDropdownItem(label: 'Normale', onTap: () {}),
        ItDropdownItem(label: 'Grande', large: true, onTap: () {}),
      ])));

      expect(_rowHeight(t, 'Normale'), 40,
          reason: '`a.list-item { padding: 4px 24px }` around a 2rem line box');
      expect(_rowHeight(t, 'Grande'), 48,
          reason: '`@media (min-width: 576px) { a.large { padding-top: .5rem; '
              'padding-bottom: .5rem } }` — the extra height is padding');
    });

    testWidgets('it is per item, not per menu', (t) async {
      // `.large` sits on the anchor in the kit, so a menu can mix the two.
      await t.pumpWidget(_host(ItDropdownMenu(items: [
        ItDropdownItem(label: 'A', large: true, onTap: () {}),
        ItDropdownItem(label: 'B', onTap: () {}),
      ])));

      expect(_rowHeight(t, 'A'), 48);
      expect(_rowHeight(t, 'B'), 40);
    });
  });

  group('rightIcon — `.link-list-wrapper ul li a.right-icon`', () {
    /// Whether the glyph is painted to the right of the label.
    bool _iconAfterLabel(WidgetTester tester) {
      final icon = tester.getCenter(find.byType(Icon));
      final label = tester.getCenter(find.text('Azione'));
      return icon.dx > label.dx;
    }

    testWidgets('the default puts the glyph before the label', (t) async {
      await t.pumpWidget(_host(ItDropdownMenu(items: [
        ItDropdownItem(
          label: 'Azione',
          icon: BootstrapItaliaIcons.it_star_outline,
          onTap: () {},
        ),
      ])));

      expect(_iconAfterLabel(t), isFalse,
          reason: '`.left-icon .icon { left: 0; margin-left: 0 }`');
    });

    testWidgets('rightIcon pushes it to the far edge of the row', (t) async {
      await t.pumpWidget(_host(ItDropdownMenu(items: [
        ItDropdownItem(
          label: 'Azione',
          icon: BootstrapItaliaIcons.it_star_outline,
          rightIcon: true,
          onTap: () {},
        ),
      ])));

      expect(_iconAfterLabel(t), isTrue,
          reason: '`.right-icon .list-item-title-icon-wrapper '
              '{ justify-content: space-between }`');

      // Not merely "after the label" — against the row's right padding edge.
      // A glyph sitting immediately after a short label would pass the check
      // above and still be the wrong layout.
      final icon = t.getCenter(find.byType(Icon));
      final row = t.getRect(find.byType(ItDropdownMenu));
      expect(icon.dx, greaterThan(row.center.dx));
    });
  });

  group('fullWidth — `.dropdown-menu.full-width`', () {
    testWidgets('the rows flow inline instead of stacking', (t) async {
      await t.pumpWidget(_looseHost(const ItDropdownMenu(
        fullWidth: true,
        width: 600,
        items: [
          ItDropdownItem(label: 'Azione 1'),
          ItDropdownItem(label: 'Azione 2'),
        ],
      )));

      final first = t.getCenter(find.text('Azione 1'));
      final second = t.getCenter(find.text('Azione 2'));
      expect(second.dx, greaterThan(first.dx),
          reason: '`.full-width .link-list li { display: inline-block; '
              'width: auto }`');
      expect(second.dy, first.dy,
          reason: 'two inline boxes that fit share a line');
    });

    testWidgets('a stacked menu still stacks', (t) async {
      await t.pumpWidget(_looseHost(const ItDropdownMenu(
        items: [
          ItDropdownItem(label: 'Azione 1'),
          ItDropdownItem(label: 'Azione 2'),
        ],
      )));

      final first = t.getCenter(find.text('Azione 1'));
      final second = t.getCenter(find.text('Azione 2'));
      expect(second.dy, greaterThan(first.dy));
      expect(second.dx, first.dx);
    });

    testWidgets('surplus rows wrap rather than overflow', (t) async {
      // A Row here would report a RenderFlex overflow — which is what a
      // three-item menu inside a 260px button actually is — and the test
      // binding fails the test on it, so reaching the assertions below is
      // itself half the contract.
      await t.pumpWidget(_looseHost(const ItDropdownMenu(
        fullWidth: true,
        width: 260,
        items: [
          ItDropdownItem(label: 'Azione lunga 1'),
          ItDropdownItem(label: 'Azione lunga 2'),
          ItDropdownItem(label: 'Azione lunga 3'),
        ],
      )));

      expect(t.getSize(find.byType(ItDropdownMenu)).width, 260,
          reason: '`.dropdown-menu.full-width { width: 100% }` of the trigger');
      final first = t.getCenter(find.text('Azione lunga 1'));
      final last = t.getCenter(find.text('Azione lunga 3'));
      expect(last.dy, greaterThan(first.dy), reason: 'it moved to a new line');
    });
  });

  group('dark — `.dropdown-menu.dark`', () {
    testWidgets('the panel takes the slate fill', (t) async {
      await t.pumpWidget(_host(const ItDropdownMenu(
        dark: true,
        items: [ItDropdownItem(label: 'Azione')],
      )));

      expect(_panelFill(t, 'Azione'), const Color(0xFF435A70),
          reason: '`.dropdown-menu.dark '
              '{ background-color: hsl(210,25%,35.2%) }`');
    });

    testWidgets('labels, headings and the active row reverse out', (t) async {
      await t.pumpWidget(_host(const ItDropdownMenu(
        dark: true,
        items: [
          ItDropdownHeader(label: 'Intestazione'),
          ItDropdownItem(label: 'Riposo'),
          ItDropdownItem(label: 'Attiva', active: true),
          ItDropdownItem(label: 'Disabilitata', disabled: true),
        ],
      )));

      expect(_styleOf(t, 'Intestazione')?.color, const Color(0xFFFFFFFF),
          reason: '`.dropdown-menu.dark … .link-list-heading { color: #fff }`');
      expect(_styleOf(t, 'Riposo')?.color, const Color(0xFFFFFFFF),
          reason: '`.dropdown-menu.dark … a span { color: #fff }`');
      expect(_styleOf(t, 'Attiva')?.color, const Color(0xFF00FFF7),
          reason: '`… a.active span { color: rgb(0,255,246.5) }` — a cyan, not '
              'the light story\'s navy, which would be about 1.4:1 here');
      expect(_styleOf(t, 'Disabilitata')?.color, const Color(0xFFADB2B8),
          reason: '`… a.disabled span '
              '{ color: rgb(172.584,178.092,183.6) }`');
    });

    testWidgets('the light panel is untouched', (t) async {
      // The dark story is additive: without the flag every colour is what it
      // was before the flag existed, which is what the parity captures hold.
      await t.pumpWidget(_host(const ItDropdownMenu(
        items: [
          ItDropdownItem(label: 'Riposo'),
          ItDropdownItem(label: 'Attiva', active: true),
        ],
      )));

      expect(_panelFill(t, 'Riposo'), const Color(0xFFFFFFFF));
      expect(_styleOf(t, 'Riposo')?.color, BootstrapItaliaColors.primary);
      expect(_styleOf(t, 'Attiva')?.color, const Color(0xFF00264D));
    });
  });

  group('a11y: the variants change presentation and nothing else', () {
    /// Every semantics node in the tree, flattened.
    List<SemanticsData> _all(WidgetTester tester) {
      final out = <SemanticsData>[];
      void walk(SemanticsNode node) {
        out.add(node.getSemanticsData());
        node.visitChildren((c) {
          walk(c);
          return true;
        });
      }

      walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
      return out;
    }

    SemanticsData _named(WidgetTester tester, String label) =>
        _all(tester).firstWhere((d) => d.label == label);

    testWidgets('4.1.2: a dark row keeps its role, name and state', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(const ItDropdownMenu(
        dark: true,
        items: [
          ItDropdownItem(label: 'Attiva', active: true),
          ItDropdownItem(label: 'Disabilitata', disabled: true),
        ],
      )));

      final active = _named(t, 'Attiva');
      expect(active.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(active.hasFlag(SemanticsFlag.isSelected), isTrue,
          reason: 'the cyan is the only other signal a sighted user gets');

      final disabled = _named(t, 'Disabilitata');
      expect(disabled.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(disabled.hasFlag(SemanticsFlag.isEnabled), isFalse);
      handle.dispose();
    });

    testWidgets('4.1.2: a large row keeps its role and name', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(const ItDropdownMenu(
        items: [ItDropdownItem(label: 'Grande', large: true)],
      )));

      expect(_named(t, 'Grande').hasFlag(SemanticsFlag.isButton), isTrue);
      handle.dispose();
    });

    testWidgets('4.1.2: an inline row keeps its role and name', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(const ItDropdownMenu(
        fullWidth: true,
        width: 400,
        items: [ItDropdownItem(label: 'Inline')],
      )));

      expect(_named(t, 'Inline').hasFlag(SemanticsFlag.isButton), isTrue);
      handle.dispose();
    });

    testWidgets('2.1.1: arrow keys still walk a dark menu', (t) async {
      // The keyboard walk lives on the panel, above every one of these flags —
      // but "above" is an implementation claim, and this is the assertion that
      // makes it one the variants cannot quietly break.
      await t.pumpWidget(_host(const ItDropdownMenu(
        dark: true,
        autofocus: true,
        items: [
          ItDropdownItem(label: 'Uno'),
          ItDropdownItem(label: 'Due'),
        ],
      )));
      await t.pumpAndSettle();

      final nodes = t
          .widgetList<Focus>(find.byType(Focus))
          .map((f) => f.focusNode)
          .whereType<FocusNode>()
          .where((n) => n.debugLabel?.startsWith('ItDropdownItem') ?? false)
          .toList();
      expect(nodes.first.hasFocus, isTrue, reason: 'autofocus enters the menu');

      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.pump();
      expect(nodes[1].hasFocus, isTrue);
    });
  });
}
