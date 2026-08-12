// Phase 4.1: apply the house assert style evenly.
//
// `ItModal.show` had the best error message in the package — it names the WCAG
// criterion and both fixes — while the six form widgets, which carry the most
// misuse-prone parameters, had none at all. `ItTabView` validated its index and
// `ItTabBar`, the widget that drives it, did not.
//
// What these have in common is that the misuse produces a widget that *renders*.
// Nothing throws, nothing looks wrong on screen, and the defect is visible only
// to someone using assistive technology. An assert is the only thing that turns
// that into feedback.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: SizedBox(width: 500, child: child)));

/// Pumps [child] and returns the assertion message, or null if none fired.
Future<String?> _assertionFrom(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(_host(child));
  final e = tester.takeException();
  if (e == null) return null;
  expect(e, isA<AssertionError>());
  return (e as AssertionError).message.toString();
}

void main() {
  group('ItTabBar validates what ItTabView already did', () {
    testWidgets('an out-of-range selectedIndex is named', (tester) async {
      final msg = await _assertionFrom(
        tester,
        const ItTabBar(
          selectedIndex: 5,
          tabs: [ItTabItem(label: 'Uno')],
        ),
      );
      expect(msg, contains('within the tabs range'),
          reason: 'an out-of-range index used to surface as a RangeError from '
              'inside the framework, naming neither widget');
    });

    testWidgets('an empty tab bar is rejected', (tester) async {
      final msg = await _assertionFrom(tester, const ItTabBar(tabs: []));
      expect(msg, contains('at least one tab'));
    });

    testWidgets('an all-disabled tab bar is rejected', (tester) async {
      // Traversal skips disabled tabs, so every tab disabled means the tablist
      // is reachable by no route at all (WCAG 2.1.1).
      final msg = await _assertionFrom(
        tester,
        const ItTabBar(tabs: [ItTabItem(label: 'Uno', disabled: true)]),
      );
      expect(msg, contains('disabled'));
    });
  });

  group('ItBackToTop enforces its documented ancestor', () {
    testWidgets('outside a Stack, the message names the widget and the fix',
        (tester) async {
      // The class doc said "must be placed inside a Stack" and nothing enforced
      // it. Positioned then threw from inside the framework with a message
      // about ParentDataWidget that names neither ItBackToTop nor the fix.
      final controller = ScrollController();
      addTearDown(controller.dispose);

      final msg = await _assertionFrom(
        tester,
        ItBackToTop(scrollController: controller),
      );
      expect(msg, contains('must be placed inside a Stack'));
      expect(msg, contains('ItBackToTopButton'),
          reason: 'the message should name the alternative, as ItModal does');
    });
  });

  group('form controls reject silently-broken configurations', () {
    testWidgets('required with no label', (tester) async {
      // "Required" is announced against the control name, so with no name AT
      // says "required" about nothing.
      final msg = await _assertionFrom(
        tester,
        const ItRadioGroup<String>(
          required: true,
          options: [ItRadioOption(value: 'a', label: 'A')],
        ),
      );
      expect(msg, contains('no label'));
    });

    testWidgets('no options at all', (tester) async {
      final msg = await _assertionFrom(
        tester,
        const ItCheckboxGroup<String>(
          label: 'Scegli',
          options: [],
          values: {},
        ),
      );
      expect(msg, contains('no options'));
    });

    testWidgets('duplicate option values', (tester) async {
      // Selection is matched by value, so duplicates select together: one
      // click visibly changes two rows.
      final msg = await _assertionFrom(
        tester,
        const ItRadioGroup<String>(
          label: 'Scegli',
          options: [
            ItRadioOption(value: 'a', label: 'Primo'),
            ItRadioOption(value: 'a', label: 'Secondo'),
          ],
        ),
      );
      expect(msg, contains('duplicate option values'));
    });

    testWidgets('a valid configuration asserts nothing', (tester) async {
      // The other half of the contract: these must not fire on correct use.
      expect(
        await _assertionFrom(
          tester,
          const ItRadioGroup<String>(
            label: 'Scegli',
            required: true,
            options: [
              ItRadioOption(value: 'a', label: 'Primo'),
              ItRadioOption(value: 'b', label: 'Secondo'),
            ],
          ),
        ),
        isNull,
      );
    });

    testWidgets('danger without errorText is NOT an assert', (tester) async {
      // Deliberately allowed. It looks like the same class of bug, but the
      // control still reports SemanticsValidationResult.invalid, so the state
      // reaches AT even when the description is rendered by a form-level error
      // summary elsewhere. Asserting it would reject a correct design.
      expect(
        await _assertionFrom(
          tester,
          const ItInput(
              label: 'Nome', validationState: ItValidationState.danger),
        ),
        isNull,
      );
    });
  });
}
