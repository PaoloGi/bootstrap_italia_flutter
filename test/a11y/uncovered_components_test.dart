// Contracts for components the coverage guard found untested.
//
// `test/a11y_coverage_test.dart` requires every exported component to appear
// somewhere in this directory. Adding it flagged sixteen, and the flags were
// not noise: among them was **`ItActivatable`** — the widget that supplies
// focus, keyboard activation and the focus ring to most of the package, and the
// thing ADR 0001 is built around. It had been driven indirectly by dozens of
// tests and asserted directly by none, which is exactly the state a coverage
// check exists to surface.
//
// The rest of the flags split cleanly into "genuinely untested" (here) and
// "paints pixels, carries no semantics" (exempted in the guard, with reasons).
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
        home: Scaffold(body: Center(child: child)),
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

void main() {
  group('ItActivatable — the keyboard foundation', () {
    testWidgets('4.1.2: it does not invent a role', (tester) async {
      // Deliberately NOT a button. ItActivatable supplies operability, and the
      // caller supplies the role — ItCard is a button, ItCardCategory a link,
      // ItBreadcrumb a link. Baking `button: true` in here would mislabel every
      // one of them, so the contract is that it stays silent about role.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItActivatable(onPressed: () {}, child: const Text('Voce')),
      ));

      expect(_find(tester, (d) => d.hasFlag(SemanticsFlag.isButton)), isNull,
          reason:
              'the wrapper must not assert a role its caller has not chosen');
      handle.dispose();
    });

    testWidgets('2.1.1: Enter and Space both activate', (tester) async {
      var fired = 0;
      await tester.pumpWidget(_host(
        ItActivatable(onPressed: () => fired++, child: const Text('Voce')),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(fired, 1, reason: 'Enter activates');

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(fired, 2, reason: 'Space activates');
    });

    testWidgets('2.4.7: the ring paints only after keyboard focus',
        (tester) async {
      await tester.pumpWidget(_host(
        ItActivatable(onPressed: () {}, child: const Text('Voce')),
      ));
      expect(
        tester.widget<ItFocusRing>(find.byType(ItFocusRing)).visible,
        isFalse,
        reason: 'nothing is painted before focus arrives',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        tester.widget<ItFocusRing>(find.byType(ItFocusRing)).visible,
        isTrue,
        reason: 'a keyboard user must be able to see where they are',
      );
    });

    testWidgets('2.1.1: a disabled control leaves the tab order',
        (tester) async {
      await tester.pumpWidget(_host(
        const ItActivatable(onPressed: null, child: Text('Inerte')),
      ));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final focused = primaryFocus;
      var insideControl = false;
      focused?.context?.visitAncestorElements((e) {
        if (e.widget is ItActivatable) insideControl = true;
        return true;
      });
      expect(insideControl, isFalse,
          reason: 'a control that cannot be activated must not be a tab stop, '
              'or keyboard users pay for it on every traversal');
    });
  });

  group('ItIconAction — label is required on principle', () {
    testWidgets('4.1.2: the glyph-only button is named', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItIconAction(
          icon: BootstrapItaliaIcons.it_close,
          color: const Color(0xFF0066CC),
          label: 'Chiudi il pannello',
          onPressed: () {},
        ),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isButton));
      expect(node, isNotNull);
      expect(node!.getSemanticsData().label, 'Chiudi il pannello',
          reason: 'an icon carries no text, so the name is the only thing a '
              'screen-reader user gets — which is why `label` is required here '
              'rather than optional');
      handle.dispose();
    });
  });

  group('ItBadge — its content must reach AT', () {
    testWidgets('1.1.1: the badge text is announced', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const ItBadge(child: Text('Nuovo'))));

      expect(_find(tester, (d) => d.label.contains('Nuovo')), isNotNull,
          reason: 'a badge that is only painted tells a screen-reader user '
              'nothing, and a badge exists to say something');
      handle.dispose();
    });
  });

  group('ItBackToTop — the positioned wrapper, not just its button', () {
    testWidgets('4.1.2: it is a named control inside a Stack', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_host(
        Stack(
          children: [
            ListView(
                controller: controller,
                children: const [SizedBox(height: 2000)]),
            ItBackToTop(scrollController: controller),
          ],
        ),
      ));

      // It stays hidden until the page has scrolled past `showAfter`, so the
      // control only exists to assert once scrolling has happened — which is
      // also the only state in which a user ever meets it.
      controller.jumpTo(600);
      await tester.pumpAndSettle();

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isButton));
      expect(node, isNotNull, reason: 'the control is a button once revealed');
      expect(node!.getSemanticsData().label, isNotEmpty,
          reason: 'an unnamed icon button is announced as just "button"');
      handle.dispose();
    });
  });
}
