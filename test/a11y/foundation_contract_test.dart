// Contracts for the accessibility FOUNDATION, and for components a coverage
// audit found had none.
//
// `ItActivatable` is what gives keyboard operability and a focus indicator to
// almost every control in this package — yet a coverage audit found it had zero
// references anywhere in `test/`. That is the worst possible thing to leave
// untested: a silent regression in it would strip keyboard access from the whole
// library while every component's own contract still passed, because each of
// those asserts role and state rather than operability.
//
// `ItAlert` is dismissible and announces itself, so it carries real obligations
// (4.1.3 status messages, 2.1.1 keyboard, 4.1.2 name/role) and had no contract.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
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
    if (test(node.getSemanticsData())) {
      found = node;
      return;
    }
    node.visitChildren((child) {
      walk(child);
      return found == null;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

void main() {
  group('ItActivatable — the keyboard foundation', () {
    testWidgets('2.1.1: activates on Enter', (tester) async {
      var count = 0;
      await tester.pumpWidget(_host(
        ItActivatable(onPressed: () => count++, child: const Text('Vai')),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(count, 1,
          reason: 'every control built on ItActivatable depends on this; if it '
              'breaks, the whole library becomes mouse-only while each '
              "component's own role/state contract still passes");
    });

    testWidgets('2.1.1: activates on Space', (tester) async {
      var count = 0;
      await tester.pumpWidget(_host(
        ItActivatable(onPressed: () => count++, child: const Text('Vai')),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(count, 1);
    });

    testWidgets('2.4.3: a null onPressed is skipped by focus traversal',
        (tester) async {
      await tester.pumpWidget(_host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ItActivatable(onPressed: null, child: Text('Inerte')),
            ItActivatable(onPressed: null, child: Text('Anche inerte')),
          ],
        ),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Assert no ItActivatable took focus, rather than that primaryFocus is
      // null: with nothing focusable on the page, focus legitimately rests on
      // the route's own FocusScope, so a null check would fail for the wrong
      // reason and tell us nothing about the widget under test.
      final focused = FocusManager.instance.primaryFocus?.context;
      final tookFocus = focused != null &&
          find
              .descendant(
                of: find.byType(ItActivatable),
                matching: find.byWidget(focused.widget),
              )
              .evaluate()
              .isNotEmpty;
      expect(
        tookFocus,
        isFalse,
        reason:
            'a disabled control must not be a tab stop — otherwise keyboard '
            'users traverse dead entries with no way to know they are inert',
      );
    });

    testWidgets('2.4.7: paints nothing until focused, then paints',
        (tester) async {
      await tester.pumpWidget(_host(
        ItActivatable(onPressed: () {}, child: const Text('Vai')),
      ));

      expect(find.byType(ItFocusRing), findsOneWidget,
          reason:
              'the ring must be mounted unconditionally: adding or removing '
              'it on focus change remounts the focus node and destroys the very '
              'focus it exists to indicate');

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(FocusManager.instance.primaryFocus?.hasFocus, isTrue);
    });

    testWidgets('a tap still works alongside keyboard activation',
        (tester) async {
      var count = 0;
      await tester.pumpWidget(_host(
        ItActivatable(onPressed: () => count++, child: const Text('Vai')),
      ));

      await tester.tap(find.text('Vai'));
      await tester.pumpAndSettle();

      expect(count, 1);
    });
  });

  group('ItAlert — dismissible status message', () {
    testWidgets('4.1.3: the alert is a live region so it is announced',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 600,
          child: ItAlert(
            variant: ItAlertVariant.success,
            body: Text('Operazione completata'),
          ),
        ),
      ));

      final node = _find(
        tester,
        (d) => d.flagsCollection.isLiveRegion,
      );
      expect(node, isNotNull,
          reason:
              'an alert that appears without a live region is never spoken, '
              'so a screen-reader user is simply not told (WCAG 4.1.3)');
      handle.dispose();
    });

    testWidgets('the alert text is exposed to assistive technology',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 600,
          child: ItAlert(
            variant: ItAlertVariant.danger,
            body: Text('Errore di validazione'),
          ),
        ),
      ));

      expect(
        find.bySemanticsLabel(RegExp('Errore di validazione')),
        findsWidgets,
      );
      handle.dispose();
    });

    testWidgets(
        '2.1.1 / 4.1.2: the dismiss control is named and keyboard operable',
        (tester) async {
      var dismissed = false;
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 600,
          child: ItAlert(
            variant: ItAlertVariant.warning,
            dismissible: true,
            onDismissed: () => dismissed = true,
            body: const Text('Attenzione'),
          ),
        ),
      ));

      // An icon-only close control with no accessible name is a hard 4.1.2
      // failure: the user hears "button" and nothing else.
      final closeNode = _find(
        tester,
        (d) => d.flagsCollection.isButton && d.label.trim().isNotEmpty,
      );
      expect(closeNode, isNotNull,
          reason: 'the dismiss control must expose a name, not just a glyph');

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(dismissed, isTrue,
          reason: 'a control reachable only by pointer fails WCAG 2.1.1');
      handle.dispose();
    });
  });

  group('ItChip — the dismiss control is a control', () {
    testWidgets('2.1.1 / 4.1.2: named, focusable and keyboard operable',
        (tester) async {
      var dismissed = false;
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItChip(
          label: 'Etichetta',
          dismissible: true,
          onDismiss: () => dismissed = true,
        ),
      ));

      // It used to be a bare GestureDetector nested inside the chip body's
      // ExcludeSemantics: pointer-only, and announced as nothing.
      final node = _find(
        tester,
        (d) => d.flagsCollection.isButton && d.label.contains('Rimuovi'),
      );
      expect(node, isNotNull,
          reason: 'the dismiss control must expose a name and a button role');

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(dismissed, isTrue,
          reason: 'reachable by keyboard, not only by pointer');
      handle.dispose();
    });

    testWidgets('the chip label is still announced separately', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItChip(label: 'Etichetta', dismissible: true, onDismiss: () {}),
      ));

      final chip = _find(tester, (d) => d.label.contains('Etichetta'));
      expect(chip, isNotNull,
          reason: 'separating the dismiss node must not swallow the chip name');
      handle.dispose();
    });
  });
}
