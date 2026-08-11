// Every activatable control must answer the same keys.
//
// ADR 0001 says "every control moved off Material keeps `ItActivatable`", which
// binds both `ActivateIntent` and `ButtonActivateIntent`. `ItButton` — the
// flagship — rolled its own `FocusableActionDetector` and bound only the first.
// Whether that is observable depends on which intent `WidgetsApp` dispatches on
// the platform under test, and that is exactly the problem: a difference that
// shows up on one platform and not another is the kind that ships.
//
// So this file does not assert an implementation. It drives each control the
// way a keyboard user does and requires them all to behave identically.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  /// Builds a control that calls `fired()` when activated.
  final controls = <String, Widget Function(VoidCallback fired)>{
    'ItButton': (fired) => ItButton(onPressed: fired, child: const Text('Ok')),
    'ItActivatable': (fired) =>
        ItActivatable(onPressed: fired, child: const Text('Ok')),
    'ItChip dismiss': (fired) =>
        ItChip(label: 'Tag', dismissible: true, onDismiss: fired),
    'ItCard': (fired) => ItCard(title: 'Titolo', onTap: fired),
    'ItListItem': (fired) => ItList(items: [
          ItListItem(title: 'Voce', onTap: fired),
        ]),
    'ItBackToTopButton': (fired) => ItBackToTopButton(onPressed: fired),
    'ItBreadcrumb link': (fired) => ItBreadcrumb(items: [
          ItBreadcrumbItem(label: 'Home', onTap: fired),
          const ItBreadcrumbItem(label: 'Pagina'),
        ]),
    'ItAlert dismiss': (fired) => ItAlert(
          dismissible: true,
          onDismissed: fired,
          body: const Text('Attenzione'),
        ),
  };

  for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
    group('${key.keyLabel} activates', () {
      controls.forEach((name, build) {
        testWidgets(name, (tester) async {
          var fired = 0;
          await _pump(tester, build(() => fired++));

          // Tab to it rather than requesting focus directly: traversal is part
          // of what is being asserted, and a control that cannot be reached is
          // not operable however well it handles the key (§2.1.1).
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          expect(primaryFocus?.hasPrimaryFocus, isTrue,
              reason: '$name must be reachable with Tab');

          await tester.sendKeyEvent(key);
          await tester.pumpAndSettle();

          expect(fired, 1,
              reason:
                  '$name did not activate on ${key.keyLabel}. Controls that '
                  'bind different intents answer different keys, and which '
                  'intent WidgetsApp dispatches varies by platform — so this '
                  'can pass on one target and fail on another (§2.1.1).');
        });
      });
    });
  }
}
