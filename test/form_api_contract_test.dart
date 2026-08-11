// Guards for doc/quality-plan.md Phase 2 — the public shape of the six form
// controls.
//
// Everything here exists because the defect it pins was invisible: a polarity
// flip that disables a whole form still renders, a callback that is never
// invoked still compiles, and a `helperText` that is painted but not announced
// still looks right in a screenshot. None of these can be caught by the parity
// captures, and only one of them (2.3) would even show up in manual testing —
// as "the multi-select does nothing", with no error anywhere.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        home: Scaffold(
          body: Center(child: SizedBox(width: 320, child: child)),
        ),
      ),
    );

/// The first semantics node satisfying [test].
SemanticsNode? _find(WidgetTester tester, bool Function(SemanticsData) test) {
  SemanticsNode? found;
  void visit(SemanticsNode node) {
    if (found != null) return;
    if (test(node.getSemanticsData())) {
      found = node;
      return;
    }
    node.visitChildren((child) {
      visit(child);
      return found == null;
    });
  }

  visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

/// Whether [ancestor] is at or above [descendant] in the element tree.
bool _isAtOrAbove(Element ancestor, Element descendant) {
  if (identical(ancestor, descendant)) return true;
  var found = false;
  descendant.visitAncestorElements((e) {
    if (e == ancestor) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

/// Whether a Tab press from a sentinel *before* [control] lands inside it.
///
/// Two sentinels bracket the control so the answer is unambiguous: focus either
/// enters the control or jumps past it to the far sentinel. Asserting "focus is
/// not on the control" alone would also pass if nothing were focusable at all,
/// which would hide the opposite bug.
Future<bool> _tabReaches(WidgetTester tester, Widget control) async {
  final before = FocusNode(debugLabel: 'before');
  final after = FocusNode(debugLabel: 'after');
  addTearDown(before.dispose);
  addTearDown(after.dispose);

  final key = GlobalKey();
  await tester.pumpWidget(_host(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Focus(focusNode: before, child: const SizedBox(width: 10, height: 10)),
        KeyedSubtree(key: key, child: control),
        Focus(focusNode: after, child: const SizedBox(width: 10, height: 10)),
      ],
    ),
  ));

  before.requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();

  final focused = FocusManager.instance.primaryFocus?.context;
  if (focused == null) return false;
  if (after.hasFocus) return false;
  return _isAtOrAbove(key.currentContext! as Element, focused as Element);
}

void main() {
  // ══════════════════════════════════════════════════════════════════
  // 2.1 — one polarity: `enabled`
  //
  // The flip inverted a default and every conditional in four files. The
  // failure mode is silent and total: a form whose controls all read
  // `enabled` as `false` renders exactly as before but answers nothing. Each
  // control is therefore checked three ways — the default is operable, an
  // explicitly disabled one is not, and a disabled one is skipped by Tab
  // (WCAG 2.1.1: a control a keyboard cannot reach is not merely inert, it is
  // unreachable, and one that IS reachable but does nothing is worse).
  // ══════════════════════════════════════════════════════════════════
  group('2.1 polarity — `enabled` defaults to true and is not inverted', () {
    testWidgets('ItCheckbox', (tester) async {
      var changes = 0;
      await tester.pumpWidget(_host(
        ItCheckbox(label: 'Accetto', value: false, onChanged: (_) => changes++),
      ));
      await tester.tap(find.byType(ItCheckbox));
      await tester.pump();
      expect(changes, 1,
          reason: 'a checkbox with no `enabled` argument must '
              'be operable — the default is the value most callers never pass');

      await tester.pumpWidget(_host(
        ItCheckbox(
          label: 'Accetto',
          value: false,
          enabled: false,
          onChanged: (_) => changes++,
        ),
      ));
      await tester.tap(find.byType(ItCheckbox), warnIfMissed: false);
      await tester.pump();
      expect(changes, 1, reason: 'enabled: false must not fire onChanged');
    });

    testWidgets('ItRadio', (tester) async {
      var changes = 0;
      await tester.pumpWidget(_host(
        ItRadio(label: 'Uno', value: false, onChanged: (_) => changes++),
      ));
      await tester.tap(find.byType(ItRadio));
      await tester.pump();
      expect(changes, 1);

      await tester.pumpWidget(_host(
        ItRadio(
          label: 'Uno',
          value: false,
          enabled: false,
          onChanged: (_) => changes++,
        ),
      ));
      await tester.tap(find.byType(ItRadio), warnIfMissed: false);
      await tester.pump();
      expect(changes, 1);
    });

    testWidgets('ItToggle', (tester) async {
      var changes = 0;
      await tester.pumpWidget(_host(
        ItToggle(label: 'Notifiche', value: false, onChanged: (_) => changes++),
      ));
      await tester.tap(find.byType(ItToggle));
      await tester.pump();
      expect(changes, 1);

      await tester.pumpWidget(_host(
        ItToggle(
          label: 'Notifiche',
          value: false,
          enabled: false,
          onChanged: (_) => changes++,
        ),
      ));
      await tester.tap(find.byType(ItToggle), warnIfMissed: false);
      await tester.pump();
      expect(changes, 1);
    });

    testWidgets('ItSelect', (tester) async {
      await tester.pumpWidget(_host(
        ItSelect<String>(
          label: 'Provincia',
          items: const [ItSelectItem(value: 'RM', label: 'Roma')],
          onChanged: (_) {},
        ),
      ));
      await tester.tap(find.byType(ItSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('Roma'), findsOneWidget,
          reason: 'a select with no `enabled` argument must open');

      await tester.pumpWidget(_host(
        ItSelect<String>(
          label: 'Provincia',
          items: const [ItSelectItem(value: 'RM', label: 'Roma')],
          enabled: false,
          onChanged: (_) {},
        ),
      ));
      await tester.tap(find.byType(ItSelect<String>), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Roma'), findsNothing,
          reason: 'enabled: false must not open the list');
    });

    testWidgets('ItInput', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(_host(ItInput(label: 'Nome', focusNode: node)));
      await tester.tap(find.byType(ItInput));
      await tester.pump();
      expect(node.hasFocus, isTrue);

      await tester.pumpWidget(
        _host(ItInput(label: 'Nome', enabled: false, focusNode: node)),
      );
      await tester.tap(find.byType(ItInput), warnIfMissed: false);
      await tester.pump();
      expect(node.hasFocus, isFalse,
          reason: 'a disabled text field must not take focus on tap');
    });

    testWidgets('ItAutocomplete', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(_host(
        ItAutocomplete<String>(
          label: 'Comune',
          focusNode: node,
          onSearch: (q) async => const <String>[],
          displayStringForOption: (s) => s,
        ),
      ));
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(node.hasFocus, isTrue);

      await tester.pumpWidget(_host(
        ItAutocomplete<String>(
          label: 'Comune',
          enabled: false,
          focusNode: node,
          onSearch: (q) async => const <String>[],
          displayStringForOption: (s) => s,
        ),
      ));
      await tester.tap(find.byType(TextField), warnIfMissed: false);
      await tester.pump();
      expect(node.hasFocus, isFalse);

      // Losing focus schedules the 150ms grace period that lets a tap on an
      // overlay item land before the list closes; let it elapse so the test
      // does not tear the tree down with a timer still pending.
      await tester.pump(const Duration(milliseconds: 200));
    });
  });

  group('2.1 polarity — a disabled control is skipped by Tab (§2.1.1)', () {
    testWidgets('every form control', (tester) async {
      final enabled = <String, Widget>{
        'ItCheckbox':
            ItCheckbox(label: 'Accetto', value: false, onChanged: (_) {}),
        'ItRadio': ItRadio(label: 'Uno', value: false, onChanged: (_) {}),
        'ItToggle':
            ItToggle(label: 'Notifiche', value: false, onChanged: (_) {}),
        'ItSelect': ItSelect<String>(
          label: 'Provincia',
          items: const [ItSelectItem(value: 'RM', label: 'Roma')],
          onChanged: (_) {},
        ),
        'ItInput': const ItInput(label: 'Nome'),
        'ItAutocomplete': ItAutocomplete<String>(
          label: 'Comune',
          onSearch: (q) async => const <String>[],
          displayStringForOption: (s) => s,
        ),
      };
      final disabled = <String, Widget>{
        'ItCheckbox': ItCheckbox(
            label: 'Accetto', value: false, enabled: false, onChanged: (_) {}),
        'ItRadio': ItRadio(
            label: 'Uno', value: false, enabled: false, onChanged: (_) {}),
        'ItToggle': ItToggle(
            label: 'Notifiche',
            value: false,
            enabled: false,
            onChanged: (_) {}),
        'ItSelect': ItSelect<String>(
          label: 'Provincia',
          items: const [ItSelectItem(value: 'RM', label: 'Roma')],
          enabled: false,
          onChanged: (_) {},
        ),
        'ItInput': const ItInput(label: 'Nome', enabled: false),
        'ItAutocomplete': ItAutocomplete<String>(
          label: 'Comune',
          enabled: false,
          onSearch: (q) async => const <String>[],
          displayStringForOption: (s) => s,
        ),
      };

      for (final name in enabled.keys) {
        expect(await _tabReaches(tester, enabled[name]!), isTrue,
            reason: '$name: an enabled control must be reachable with Tab '
                '(WCAG 2.1.1). If this fails the polarity is inverted.');
        expect(await _tabReaches(tester, disabled[name]!), isFalse,
            reason: '$name: a disabled control must be skipped by Tab. '
                'Landing on a control that cannot be operated strands the '
                'keyboard user with no feedback about why.');
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // 2.2 — the three check controls agree
  //
  // `ItRadio` used to take `selected:` + `onTap: VoidCallback`, so it was the
  // one control of the three that could not be driven by the same code as its
  // siblings. The proof that they now agree is a single generic driver that
  // builds all three from one `(value, onChanged)` pair: if any of them
  // diverges again, this stops compiling.
  // ══════════════════════════════════════════════════════════════════
  group('2.2 — value/onChanged is the same shape on all three controls', () {
    final builders = <String, Widget Function(bool, ValueChanged<bool>)>{
      'ItCheckbox': (value, onChanged) =>
          ItCheckbox(label: 'Uno', value: value, onChanged: onChanged),
      'ItRadio': (value, onChanged) =>
          ItRadio(label: 'Uno', value: value, onChanged: onChanged),
      'ItToggle': (value, onChanged) =>
          ItToggle(label: 'Uno', value: value, onChanged: onChanged),
    };

    for (final entry in builders.entries) {
      testWidgets('${entry.key} is driven by one (value, onChanged) pair',
          (tester) async {
        var value = false;
        await tester.pumpWidget(_host(
          StatefulBuilder(
            builder: (context, setState) => entry.value(
              value,
              (next) => setState(() => value = next),
            ),
          ),
        ));

        await tester.tap(find.text('Uno'));
        await tester.pump();
        expect(value, isTrue,
            reason: '${entry.key} must drive its state through onChanged, so '
                'one piece of caller code works for all three controls');
      });
    }

    testWidgets('ItCheckbox.onChanged emits a non-nullable bool',
        (tester) async {
      // The parameter type is `ValueChanged<bool>`, so this closure could not
      // be written at all if the nullable form came back — but the runtime
      // check also pins that no null slips through a dynamic path.
      bool? received;
      await tester.pumpWidget(_host(
        ItCheckbox(
          label: 'Accetto',
          value: false,
          onChanged: (bool v) => received = v,
        ),
      ));
      await tester.tap(find.byType(ItCheckbox));
      await tester.pump();
      expect(received, isNotNull,
          reason: 'the deleted `tristate` left `ValueChanged<bool?>` behind, '
              'forcing every caller to handle a null that `value: bool` made '
              'impossible');
      expect(received, isTrue);
    });

    testWidgets('ItRadio emits true and never deselects itself',
        (tester) async {
      final emitted = <bool>[];
      await tester.pumpWidget(_host(
        ItRadio(label: 'Uno', value: true, onChanged: emitted.add),
      ));
      await tester.tap(find.byType(ItRadio));
      await tester.pump();
      expect(emitted, [true],
          reason: 'activating a checked radio must not turn it off — HTML '
              'fires no change at all, and emitting false would let a group '
              'reach a state with nothing selected');
    });

    testWidgets('ItRadioGroup still drives its options', (tester) async {
      String? value = 'M';
      await tester.pumpWidget(_host(
        StatefulBuilder(
          builder: (context, setState) => ItRadioGroup<String>(
            label: 'Genere',
            value: value,
            options: const [
              ItRadioOption(value: 'M', label: 'Maschio'),
              ItRadioOption(value: 'F', label: 'Femmina'),
            ],
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ));

      await tester.tap(find.text('Femmina'));
      await tester.pump();
      expect(value, 'F',
          reason: 'the group translates a radio\'s bool onChanged back into '
              'its own T; if that wiring breaks the group goes inert');
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // 2.3 — ItSelect's coupled parameters
  //
  // `ItSelect(multiple: true, onChanged: …)` compiled, ran, and silently never
  // fired: the multi path only ever called `onMultiChanged`. That exact call
  // is now a compile error — `multiple` is not a parameter and the two
  // constructors expose one callback each — which no runtime test can assert.
  // What these tests pin is the half that CAN regress: that each constructor
  // routes its `onChanged:` to the code path its selection actually uses.
  // ══════════════════════════════════════════════════════════════════
  group('2.3 — ItSelect cannot silently drop its callback', () {
    testWidgets('multi-select fires onChanged when an option is tapped',
        (tester) async {
      var selection = <String>{};
      var calls = 0;
      await tester.pumpWidget(_host(
        StatefulBuilder(
          builder: (context, setState) => ItSelect<String>.multiple(
            label: 'Province',
            items: const [
              ItSelectItem(value: 'RM', label: 'Roma'),
              ItSelectItem(value: 'MI', label: 'Milano'),
            ],
            values: selection,
            onChanged: (values) => setState(() {
              calls++;
              selection = values;
            }),
          ),
        ),
      ));

      await tester.tap(find.byType(ItSelect<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Roma').last);
      await tester.pumpAndSettle();

      expect(calls, 1,
          reason: 'THE Phase 2.3 defect: the multi-select accepted a callback '
              'and never called it. Clicking an option produced no event of '
              'any kind — no error, no warning, just a form that did nothing.');
      expect(selection, {'RM'});

      await tester.tap(find.text('Milano').last);
      await tester.pumpAndSettle();
      expect(selection, {'RM', 'MI'},
          reason: 'the list stays open and accumulates');

      await tester.tap(find.text('Roma').last);
      await tester.pumpAndSettle();
      expect(selection, {'MI'}, reason: 'tapping a chosen option removes it');
    });

    testWidgets('single-select fires onChanged and closes', (tester) async {
      String? chosen;
      await tester.pumpWidget(_host(
        ItSelect<String>(
          label: 'Provincia',
          items: const [
            ItSelectItem(value: 'RM', label: 'Roma'),
            ItSelectItem(value: 'MI', label: 'Milano'),
          ],
          onChanged: (v) => chosen = v,
        ),
      ));

      await tester.tap(find.byType(ItSelect<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Milano').last);
      await tester.pumpAndSettle();

      expect(chosen, 'MI');
      expect(find.text('Roma'), findsNothing,
          reason: 'a single-select closes once a choice is made');
    });

    test('each constructor exposes exactly the callback it uses', () {
      const items = <ItSelectItem<String>>[
        ItSelectItem(value: 'RM', label: 'Roma'),
      ];

      final single = ItSelect<String>(items: items, onChanged: (_) {});
      expect(single.multiple, isFalse);
      expect(single.onChanged, isNotNull);
      expect(single.onValuesChanged, isNull);
      expect(single.values, isNull);

      final multi = ItSelect<String>.multiple(items: items, onChanged: (_) {});
      expect(multi.multiple, isTrue);
      expect(multi.onValuesChanged, isNotNull,
          reason: '`.multiple`\'s onChanged: argument must land on the '
              'set-valued field, which is the one _selectItem calls. Routing '
              'it anywhere else reproduces the original silent no-op.');
      expect(multi.onChanged, isNull);
      expect(multi.value, isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // 2.4 — one name per concept
  // ══════════════════════════════════════════════════════════════════
  group('2.4 — ItAutocomplete uses `large`, matching ItButtonSize.large', () {
    testWidgets('the enlarged variant scales the field', (tester) async {
      await tester.pumpWidget(_host(
        ItAutocomplete<String>(
          label: 'Comune',
          large: true,
          onSearch: (q) async => const <String>[],
          displayStringForOption: (s) => s,
        ),
      ));

      // .autocomplete-wrapper-big — 20px type in a 56px control.
      expect(
        tester.widget<TextField>(find.byType(TextField)).style!.fontSize,
        20.0,
      );
      expect(tester.getSize(find.byType(ItAutocomplete<String>)).height, 56);
    });

    testWidgets('the default variant is the plain .form-control',
        (tester) async {
      await tester.pumpWidget(_host(
        ItAutocomplete<String>(
          label: 'Comune',
          onSearch: (q) async => const <String>[],
          displayStringForOption: (s) => s,
        ),
      ));
      expect(
        tester.widget<TextField>(find.byType(TextField)).style!.fontSize,
        16.0,
      );
      expect(tester.getSize(find.byType(ItAutocomplete<String>)).height, 40);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // 2.5 — the same validation/help/focus surface on all six
  //
  // A form library whose controls cannot render validation consistently has
  // failed at its main job. These are WCAG 3.3.1 / 3.3.2 contracts as much as
  // API ones: painting the message below the control is not enough, it has to
  // be *on* the control, or a screen-reader user who tabs to a rejected field
  // is never told why it was rejected.
  // ══════════════════════════════════════════════════════════════════
  group('2.5 — every control renders helper text and validation', () {
    Widget checkbox({String? helperText, String? errorText}) => ItCheckbox(
          label: 'Accetto',
          value: false,
          helperText: helperText,
          errorText: errorText,
          onChanged: (_) {},
        );
    Widget radio({String? helperText, String? errorText}) => ItRadio(
          label: 'Uno',
          value: false,
          helperText: helperText,
          errorText: errorText,
          onChanged: (_) {},
        );
    Widget toggle({String? helperText, String? errorText}) => ItToggle(
          label: 'Notifiche',
          value: false,
          helperText: helperText,
          errorText: errorText,
          onChanged: (_) {},
        );
    Widget select({String? helperText, String? errorText}) => ItSelect<String>(
          label: 'Provincia',
          items: const [ItSelectItem(value: 'RM', label: 'Roma')],
          helperText: helperText,
          errorText: errorText,
          onChanged: (_) {},
        );
    Widget input({String? helperText, String? errorText}) => ItInput(
          label: 'Nome',
          helperText: helperText,
          errorText: errorText,
        );
    Widget autocomplete({String? helperText, String? errorText}) =>
        ItAutocomplete<String>(
          label: 'Comune',
          helperText: helperText,
          errorText: errorText,
          onSearch: (q) async => const <String>[],
          displayStringForOption: (s) => s,
        );

    final controls =
        <String, Widget Function({String? helperText, String? errorText})>{
      'ItCheckbox': checkbox,
      'ItRadio': radio,
      'ItToggle': toggle,
      'ItSelect': select,
      'ItInput': input,
      'ItAutocomplete': autocomplete,
    };

    for (final entry in controls.entries) {
      testWidgets('${entry.key} paints and announces its helper text',
          (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(
          entry.value(helperText: 'Come da documento'),
        ));

        expect(find.text('Come da documento'), findsOneWidget,
            reason: '${entry.key} must paint `.form-text`');

        final node = _find(
          tester,
          (d) => d.hint.contains('Come da documento'),
        );
        expect(node, isNotNull,
            reason: 'WCAG 3.3.2: ${entry.key} must carry the instruction on '
                'its own node. Painted as a sibling paragraph it is loose '
                'text a screen reader cannot connect to the control.');

        // And nothing announces it a second time as free-standing text.
        final stray = _find(
          tester,
          (d) => d.label.contains('Come da documento'),
        );
        expect(stray, isNull,
            reason: '${entry.key}: a second unassociated copy makes a screen '
                'reader say it twice');
        handle.dispose();
      });

      testWidgets('${entry.key} paints and announces its validation message',
          (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(
          entry.value(errorText: 'Questo campo è obbligatorio'),
        ));

        expect(find.text('Questo campo è obbligatorio'), findsOneWidget,
            reason: '${entry.key} must paint `.form-feedback`');

        final node = _find(
          tester,
          (d) => d.hint.contains('Questo campo è obbligatorio'),
        );
        expect(node, isNotNull,
            reason: 'WCAG 3.3.1: ${entry.key} must carry the message itself');
        expect(
          node!.getSemanticsData().validationResult,
          SemanticsValidationResult.invalid,
          reason: 'WCAG 3.3.1: ${entry.key} must also report the invalid '
              'state, so AT announces it on focus and not only when the page '
              'is read in order',
        );
        handle.dispose();
      });

      testWidgets('${entry.key} shows the message instead of the helper',
          (tester) async {
        await tester.pumpWidget(_host(entry.value(
          helperText: 'Come da documento',
          errorText: 'Questo campo è obbligatorio',
        )));

        expect(find.text('Questo campo è obbligatorio'), findsOneWidget);
        expect(find.text('Come da documento'), findsNothing,
            reason: '`.is-invalid~.invalid-feedback { display:block }` is what '
                'reveals the message; the kit shows one supporting line at a '
                'time, and stacking both is a layout the stylesheet has no '
                'rule for');
      });
    }

    for (final entry in controls.entries) {
      testWidgets('${entry.key} announces a message that appears later',
          (tester) async {
        // WCAG 4.1.3 Status Messages: a message that arrives after submission
        // takes no focus, so unless it is pushed to the screen reader nothing
        // tells the user the field was rejected. Carrying it as the field's
        // hint (above) only helps someone who navigates back to the field.
        final announced = <String>[];
        tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler(
          SystemChannels.accessibility,
          (message) async {
            final data = (message as Map<Object?, Object?>?)?['data'];
            final text = (data as Map<Object?, Object?>?)?['message'];
            if (text is String) announced.add(text);
            return null;
          },
        );
        addTearDown(() => tester.binding.defaultBinaryMessenger
            .setMockDecodedMessageHandler(SystemChannels.accessibility, null));

        await tester.pumpWidget(_host(entry.value()));
        expect(announced, isEmpty);

        await tester.pumpWidget(_host(
          entry.value(errorText: 'Questo campo è obbligatorio'),
        ));
        await tester.pump();

        expect(announced, contains('Questo campo è obbligatorio'),
            reason: 'WCAG 4.1.3: ${entry.key} must announce a validation '
                'message that appears without taking focus');

        // Let ItAutocomplete's focus-loss grace timer elapse.
        await tester.pump(const Duration(milliseconds: 200));
      });
    }

    testWidgets('a control with neither adds no box of its own',
        (tester) async {
      // The shared chrome must be inert when unused, or every resting parity
      // capture in the package shifts by a line box.
      await tester.pumpWidget(_host(
        ItToggle(label: 'Notifiche', value: false, onChanged: (_) {}),
      ));
      expect(tester.getSize(find.byType(ItToggle)).height, 32,
          reason: '.toggles label { height: 32px } — unchanged when no '
              'supporting text is supplied');
    });
  });

  group('2.5 — every control accepts an external focus node', () {
    testWidgets('and can be focused programmatically', (tester) async {
      // WCAG 3.3.1: moving focus to the first field that failed validation is
      // how a form reports errors. `ItSelect` had no `focusNode` at all, so it
      // was the one control a form could not do this for.
      final nodes = <String, FocusNode>{
        for (final name in const [
          'ItCheckbox',
          'ItRadio',
          'ItToggle',
          'ItSelect',
          'ItInput',
          'ItAutocomplete',
        ])
          name: FocusNode(debugLabel: name),
      };
      for (final node in nodes.values) {
        addTearDown(node.dispose);
      }

      final controls = <String, Widget>{
        'ItCheckbox': ItCheckbox(
            label: 'Accetto',
            value: false,
            focusNode: nodes['ItCheckbox'],
            onChanged: (_) {}),
        'ItRadio': ItRadio(
            label: 'Uno',
            value: false,
            focusNode: nodes['ItRadio'],
            onChanged: (_) {}),
        'ItToggle': ItToggle(
            label: 'Notifiche',
            value: false,
            focusNode: nodes['ItToggle'],
            onChanged: (_) {}),
        'ItSelect': ItSelect<String>(
          label: 'Provincia',
          items: const [ItSelectItem(value: 'RM', label: 'Roma')],
          focusNode: nodes['ItSelect'],
          onChanged: (_) {},
        ),
        'ItInput': ItInput(label: 'Nome', focusNode: nodes['ItInput']),
        'ItAutocomplete': ItAutocomplete<String>(
          label: 'Comune',
          focusNode: nodes['ItAutocomplete'],
          onSearch: (q) async => const <String>[],
          displayStringForOption: (s) => s,
        ),
      };

      for (final entry in controls.entries) {
        await tester.pumpWidget(_host(entry.value));
        nodes[entry.key]!.requestFocus();
        await tester.pump();
        expect(nodes[entry.key]!.hasFocus, isTrue,
            reason: '${entry.key} must honour an external focus node, or a '
                'form cannot send the user to the field that failed');
      }
    });

    testWidgets('ItSelect disposes only the node it created', (tester) async {
      final node = FocusNode(debugLabel: 'caller-owned');
      addTearDown(node.dispose);

      await tester.pumpWidget(_host(
        ItSelect<String>(
          label: 'Provincia',
          items: const [ItSelectItem(value: 'RM', label: 'Roma')],
          focusNode: node,
          onChanged: (_) {},
        ),
      ));
      await tester.pumpWidget(_host(const SizedBox.shrink()));

      // Touching a disposed FocusNode throws; the caller still owns this one.
      expect(node.hasFocus, isFalse);
      expect(() => node.debugLabel, returnsNormally);
    });
  });
}
