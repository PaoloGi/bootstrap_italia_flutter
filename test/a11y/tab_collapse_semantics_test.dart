// Accessibility contracts for the Tab and Collapse variants added while
// mirroring the official docs pages.
//
// A repainted variant is checked in `test/tab_variants_test.dart`; anything
// that can be *operated* is checked here, because this package has already been
// burned once by the other order — a pixel-parity pass replaced working
// controls with hand-painted ones and destroyed their semantics wholesale, and
// axe-core passed the broken result. Only Dart contracts caught it.
//
// Three of these variants introduce genuinely new operable surfaces rather than
// restyling an existing one: the icon-only tab (whose entire accessible name is
// a `.visually-hidden` span), the editable card's close and add controls, and
// `ItCollapseToggle`.
import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 700, child: child),
          ),
        ),
      ),
    );

SemanticsNode? _find(WidgetTester tester, bool Function(SemanticsData) test) {
  SemanticsNode? found;
  void walk(SemanticsNode node) {
    if (found != null) return;
    if (test(node.getSemanticsData())) found = node;
    node.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

List<SemanticsNode> _findAll(
    WidgetTester tester, bool Function(SemanticsData) test) {
  final out = <SemanticsNode>[];
  void walk(SemanticsNode node) {
    if (test(node.getSemanticsData())) out.add(node);
    node.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return out;
}

/// Contrast ratio per WCAG 2.1 §1.4.3.
double _contrast(Color a, Color b) {
  double luminance(Color c) {
    double channel(double v) {
      final s = v / 255.0;
      return s <= 0.03928
          ? s / 12.92
          : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * channel((c.r * 255).roundToDouble()) +
        0.7152 * channel((c.g * 255).roundToDouble()) +
        0.0722 * channel((c.b * 255).roundToDouble());
  }

  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

const _iconTabs = [
  ItTabItem(label: 'Collegamenti', icon: BootstrapItaliaIcons.it_link),
  ItTabItem(label: 'Calendario', icon: BootstrapItaliaIcons.it_calendar),
  ItTabItem(label: 'Commenti', icon: BootstrapItaliaIcons.it_comment),
];

void main() {
  group('icon-only tabs keep their name', () {
    for (final layout in [ItTabLayout.iconOnly, ItTabLayout.iconOnlyLarge]) {
      testWidgets('4.1.2: $layout announces the hidden label', (t) async {
        // The kit writes `<span class="visually-hidden">Tab titolo 1</span>`
        // beside every icon. That span is not decoration — it is the whole of
        // what a screen reader has for a tab that paints only a glyph, which is
        // why `ItTabItem.label` stays required in a layout that never draws it.
        final handle = t.ensureSemantics();
        await t.pumpWidget(_host(ItTabBar(
          tabs: _iconTabs,
          layout: layout,
          onChanged: (_) {},
        )));

        expect(find.text('Collegamenti'), findsNothing,
            reason: 'nothing is painted…');
        final tabs = _findAll(t, (d) => d.role == SemanticsRole.tab);
        expect(tabs.map((n) => n.getSemanticsData().label),
            ['Collegamenti', 'Calendario', 'Commenti'],
            reason: '…but every tab is still named');
        expect(tabs.first.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
            isTrue);
        handle.dispose();
      });
    }
  });

  group('the tab/panel relationship', () {
    testWidgets('1.3.1: a tab controls the panel it reveals', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(Column(
        children: [
          ItTabBar(
            tabs: const [ItTabItem(label: 'Uno'), ItTabItem(label: 'Due')],
            panelId: 'pannello-servizi',
            onChanged: (_) {},
          ),
          const ItTabView(
            selectedIndex: 0,
            animated: false,
            identifier: 'pannello-servizi',
            children: [Text('Contenuto 1'), Text('Contenuto 2')],
          ),
        ],
      )));

      final tabs = _findAll(t, (d) => d.role == SemanticsRole.tab);
      expect(tabs.first.getSemanticsData().controlsNodes,
          contains('pannello-servizi'),
          reason: 'the kit pairs every `role="tab"` with the `id` of its '
              '`role="tabpanel"`, and screen readers use the pairing to jump '
              'from a tab straight to its content');

      expect(
        _find(t, (d) => d.role == SemanticsRole.tabPanel)!
            .getSemanticsData()
            .identifier,
        'pannello-servizi',
        reason: 'the other half of the pair — without it `aria-controls` names '
            'nothing',
      );
      handle.dispose();
    });

    testWidgets('a bar with no panelId claims to control nothing', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(ItTabBar(
        tabs: const [ItTabItem(label: 'Uno'), ItTabItem(label: 'Due')],
        onChanged: (_) {},
      )));
      final tabs = _findAll(t, (d) => d.role == SemanticsRole.tab);
      expect(tabs.first.getSemanticsData().controlsNodes, isNull,
          reason: 'a dangling `aria-controls` is worse than none: it offers a '
              'shortcut that leads nowhere');
      handle.dispose();
    });
  });

  group('2.1.1: the arrow keys follow the bar\'s own axis', () {
    /// Pumps a three-tab bar that actually rebuilds on selection.
    ///
    /// The state has to be real: `_move` reads `widget.selectedIndex`, so a bar
    /// whose callback only writes to a local variable answers every arrow press
    /// from tab 0 and the test measures nothing.
    Future<ValueNotifier<int>> pumpBar(
        WidgetTester t, ItTabPlacement placement) async {
      final selected = ValueNotifier<int>(0);
      addTearDown(selected.dispose);
      await t.pumpWidget(_host(ValueListenableBuilder<int>(
        valueListenable: selected,
        builder: (context, index, _) => ItTabBar(
          tabs: const [
            ItTabItem(label: 'Uno'),
            ItTabItem(label: 'Due'),
            ItTabItem(label: 'Tre'),
          ],
          placement: placement,
          selectedIndex: index,
          onChanged: (i) => selected.value = i,
        ),
      )));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      return selected;
    }

    testWidgets('a vertical bar answers Up and Down', (t) async {
      // The kit marks a vertical tablist `aria-orientation="vertical"`, and the
      // ARIA authoring practices bind that axis' arrows. A vertical bar wired
      // to Left/Right asks a keyboard user to move sideways through a column.
      final selected = await pumpBar(t, ItTabPlacement.start);

      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.pumpAndSettle();
      expect(selected.value, 1);

      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      expect(selected.value, 1, reason: 'the cross-axis arrows are not bound');

      await t.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await t.pumpAndSettle();
      expect(selected.value, 0);
    });

    testWidgets('a horizontal bar keeps Left and Right', (t) async {
      final selected = await pumpBar(t, ItTabPlacement.top);

      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      expect(selected.value, 1);

      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.pumpAndSettle();
      expect(selected.value, 1, reason: 'the cross-axis arrows are not bound');

      await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await t.pumpAndSettle();
      expect(selected.value, 0);
    });

    // One test per placement rather than a loop inside one: pumping a second
    // bar into the same test reuses the first one's State, and with it the
    // focus nodes, so the Tab press that should enter the new bar leaves the
    // old one instead and every subsequent key goes nowhere.
    for (final placement in ItTabPlacement.values) {
      testWidgets('Home and End jump to the ends on $placement', (t) async {
        final selected = await pumpBar(t, placement);
        await t.sendKeyEvent(LogicalKeyboardKey.end);
        await t.pumpAndSettle();
        expect(selected.value, 2);
        await t.sendKeyEvent(LogicalKeyboardKey.home);
        await t.pumpAndSettle();
        expect(selected.value, 0);
      });
    }
  });

  group('the editable card\'s two extra controls', () {
    testWidgets('4.1.2: the close control is a named button inside its tab',
        (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(ItTabBar(
        selectedIndex: 0,
        onChanged: (_) {},
        style: ItTabStyle.card,
        tabs: [
          ItTabItem(
            label: 'Anagrafe',
            onClose: () {},
            closeLabel: 'Chiudi la scheda Anagrafe',
          ),
          ItTabItem(
            label: 'Tributi',
            onClose: () {},
            closeLabel: 'Chiudi la scheda Tributi',
          ),
        ],
      )));

      final closes = _findAll(
          t,
          (d) =>
              d.hasFlag(SemanticsFlag.isButton) &&
              d.label.startsWith('Chiudi la scheda'));
      expect(closes.map((n) => n.getSemanticsData().label),
          ['Chiudi la scheda Anagrafe', 'Chiudi la scheda Tributi'],
          reason: 'named after the tab each one closes. Two buttons both '
              'called «Chiudi» are indistinguishable in an element list, and a '
              'user picking between them is guessing');

      // A `tablist` may contain nothing but tabs — Flutter asserts it. The
      // close control is therefore a descendant of its tab's node, matching the
      // kit's own `<li>` grouping, and never a sibling of it.
      expect(t.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('the tab is still operable with a close control on it',
        (t) async {
      // Regression: adding the close gave the tab two operable descendants, so
      // their configurations stopped merging upward and the tab node lost its
      // tap action entirely — which Flutter reports as "A tab must have a tap
      // action" and which leaves AT unable to select the tab at all.
      final handle = t.ensureSemantics();
      var selected = 0;
      await t.pumpWidget(_host(ItTabBar(
        selectedIndex: 0,
        onChanged: (i) => selected = i,
        tabs: [
          const ItTabItem(label: 'Anagrafe'),
          ItTabItem(
            label: 'Tributi',
            onClose: () {},
            closeLabel: 'Chiudi la scheda Tributi',
          ),
        ],
      )));

      final tab = _findAll(t, (d) => d.role == SemanticsRole.tab).last;
      expect(tab.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      t.binding.pipelineOwner.semanticsOwner!
          .performAction(tab.id, SemanticsAction.tap);
      await t.pumpAndSettle();
      expect(selected, 1);
      handle.dispose();
    });

    testWidgets('a disabled tab disables its close control too', (t) async {
      final handle = t.ensureSemantics();
      var closed = false;
      await t.pumpWidget(_host(ItTabBar(
        selectedIndex: 0,
        onChanged: (_) {},
        tabs: [
          const ItTabItem(label: 'Anagrafe'),
          ItTabItem(
            label: 'Tributi',
            disabled: true,
            onClose: () => closed = true,
            closeLabel: 'Chiudi la scheda Tributi',
          ),
        ],
      )));
      await t.tap(find.bySemanticsLabel('Chiudi la scheda Tributi'));
      await t.pumpAndSettle();
      expect(closed, isFalse,
          reason: '`.nav-link-close.disabled` — a tab a user cannot reach is '
              'not one they can close either');
      handle.dispose();
    });

    testWidgets('4.1.2: the add control is named and reachable by keyboard',
        (t) async {
      final handle = t.ensureSemantics();
      var added = 0;
      await t.pumpWidget(_host(ItTabBar(
        selectedIndex: 0,
        onChanged: (_) {},
        style: ItTabStyle.card,
        tabs: const [ItTabItem(label: 'Anagrafe')],
        onAddTab: () => added++,
        addTabLabel: 'Aggiungi una scheda',
      )));

      final add = _find(
          t,
          (d) =>
              d.hasFlag(SemanticsFlag.isButton) &&
              d.label == 'Aggiungi una scheda');
      expect(add, isNotNull,
          reason: 'the kit draws the `+` from two rectangles — there is no '
              'text in the control at all');

      // §2.1.1: two Tab presses — into the tab list, then on to the add
      // control, which is outside it.
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(added, 1);
      handle.dispose();
    });
  });

  group('1.4.3: the dark bar', () {
    // `.nav-dark` swaps in a fixed palette that no scheme retints, so the
    // ratios are decided here once and for all rather than per application.
    const band = Color(0xFF455B71);

    test('resting labels reach 4.5:1 on the band', () {
      expect(
          _contrast(const Color(0xFFD9DADB), band), greaterThanOrEqualTo(4.5),
          reason: '`.nav-dark .nav-link { color: rgb(217.107,…) }`');
    });

    test('the active label reaches 4.5:1 on the band', () {
      expect(
          _contrast(const Color(0xFF00FFF7), band), greaterThanOrEqualTo(4.5),
          reason: '`.nav-dark .nav-link.active { color: rgb(0,255,246.5) }`');
    });

    test('the light bar\'s resting label would NOT survive the band', () {
      // Which is the reason `.nav-dark` restates all four colours instead of
      // reusing the light ramp on a dark surface.
      expect(_contrast(const Color(0xFF30475F), band), lessThan(3.0));
    });
  });

  group('ItCollapseToggle', () {
    testWidgets('4.1.2: one node carrying role, name and expanded state',
        (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(StatefulBuilder(
        builder: (context, setState) {
          var open = false;
          return StatefulBuilder(
            builder: (context, setInner) => Column(
              children: [
                ItCollapseToggle(
                  expanded: open,
                  controls: const {'dettagli'},
                  child: ItButton(
                    onPressed: () => setInner(() => open = !open),
                    child: const Text('Mostra i dettagli'),
                  ),
                ),
                ItCollapse(
                  isExpanded: open,
                  semanticsIdentifier: 'dettagli',
                  child: const Text('Contenuto'),
                ),
              ],
            ),
          );
        },
      )));

      // The name and the state have to land on the SAME node. Unmerged they do
      // not: `expanded` sits on a parent with no label and the label sits on a
      // child with no state, so AT reads a container and then a button and
      // never says what the control does. Nothing combines them, which is
      // exactly what this counts.
      final nodes = _findAll(
          t,
          (d) =>
              d.label == 'Mostra i dettagli' &&
              d.hasFlag(SemanticsFlag.hasExpandedState));
      expect(nodes, hasLength(1));

      final data = nodes.single.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(data.hasFlag(SemanticsFlag.isExpanded), isFalse,
          reason: 'the docs are explicit that a closed panel means '
              '`aria-expanded="false"` on the control, not an absent attribute');
      expect(data.controlsNodes, contains('dettagli'));
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('the expanded state follows the panel', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(const _Disclosure()));

      bool expanded() => _find(
              t,
              (d) =>
                  d.label == 'Mostra' &&
                  d.hasFlag(SemanticsFlag.hasExpandedState))!
          .getSemanticsData()
          .hasFlag(SemanticsFlag.isExpanded);

      expect(expanded(), isFalse);
      await t.tap(find.text('Mostra'));
      await t.pumpAndSettle();
      expect(expanded(), isTrue);
      handle.dispose();
    });

    testWidgets('one control may open several panels', (t) async {
      // `aria-controls="multiCollapseExample1 multiCollapseExample2"` — the
      // docs' «Attiva/disattiva entrambi gli elementi».
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(ItCollapseToggle(
        expanded: true,
        controls: const {'uno', 'due'},
        child: ItButton(onPressed: () {}, child: const Text('Entrambi')),
      )));
      expect(
        _find(t, (d) => d.label == 'Entrambi' && d.controlsNodes != null)!
            .getSemanticsData()
            .controlsNodes,
        {'uno', 'due'},
      );
      handle.dispose();
    });

    testWidgets('a toggle controlling nothing is a build error', (t) async {
      await t.pumpWidget(_host(ItCollapseToggle(
        expanded: false,
        controls: const {},
        child: ItButton(onPressed: () {}, child: const Text('Vuoto')),
      )));
      expect(
        t.takeException(),
        isA<AssertionError>().having(
            (e) => e.message.toString(), 'message', contains('aria-controls')),
      );
    });
  });
}

/// A disclosure wired exactly as the docs' «Come funziona» example is.
class _Disclosure extends StatefulWidget {
  const _Disclosure();

  @override
  State<_Disclosure> createState() => _DisclosureState();
}

class _DisclosureState extends State<_Disclosure> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ItCollapseToggle(
          expanded: _open,
          controls: const {'esempio'},
          child: ItButton(
            onPressed: () => setState(() => _open = !_open),
            child: const Text('Mostra'),
          ),
        ),
        ItCollapse(
          isExpanded: _open,
          semanticsIdentifier: 'esempio',
          child: const Text('Contenuto'),
        ),
      ],
    );
  }
}
