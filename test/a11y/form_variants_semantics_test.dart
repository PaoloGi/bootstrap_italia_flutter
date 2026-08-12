// Accessibility contracts for the form variants added to mirror the docs.
//
// `.form-check-group` ("Raggruppati visivamente"), per-option descriptions,
// `<optgroup>` captions in the select, and `ItToggleGroup` — the `<fieldset>`
// + `<legend>` the Toggles docs page uses in two of its four sections.
//
// The reason these exist as *semantics* tests rather than layout ones is on
// the record in this repository: a previous rewrite of these same six controls
// reached pixel parity and silently destroyed their screen-reader semantics,
// and axe-core passed the broken checkbox, because a named button is valid
// ARIA. Only Dart contracts caught it. `visuallyGrouped` moves an indicator
// from one side of a row to the other; the whole risk of that change is that
// something on the way past drops the checked state.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        home: Scaffold(
          body: Center(child: SizedBox(width: 400, child: child)),
        ),
      ),
    );

SemanticsData _data(WidgetTester tester, String label) =>
    tester.getSemantics(find.bySemanticsLabel(label)).getSemanticsData();

void main() {
  group('ItToggleGroup — <fieldset> + <legend>', () {
    testWidgets('1.3.1: the legend names the group, once', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItToggleGroup<String>(
        label: 'Gruppo di toggle',
        options: const [
          ItToggleOption(value: 'a', label: 'Toggle acceso'),
          ItToggleOption(value: 'b', label: 'Toggle spento'),
        ],
        values: const {'a'},
        onChanged: (_) {},
      )));

      // The caption reaches AT as the container's name. The painted copy is
      // excluded, so it must not turn up a second time as loose text.
      expect(find.bySemanticsLabel('Gruppo di toggle'), findsOneWidget);
      expect(_data(tester, 'Gruppo di toggle').label, 'Gruppo di toggle');
      handle.dispose();
    });

    testWidgets('4.1.2: each row is a switch reporting its own position',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItToggleGroup<String>(
        label: 'Gruppo di toggle',
        options: const [
          ItToggleOption(value: 'a', label: 'Toggle acceso'),
          ItToggleOption(value: 'b', label: 'Toggle spento'),
        ],
        values: const {'a'},
        onChanged: (_) {},
      )));

      final on = _data(tester, 'Toggle acceso');
      expect(on.hasFlag(SemanticsFlag.hasToggledState), isTrue,
          reason: 'a switch must report a toggled state, not merely a name — '
              'this is the exact defect that once made every one of these '
              'controls announce as a plain button');
      expect(on.hasFlag(SemanticsFlag.isToggled), isTrue);
      expect(on.hasAction(SemanticsAction.tap), isTrue);

      final off = _data(tester, 'Toggle spento');
      expect(off.hasFlag(SemanticsFlag.hasToggledState), isTrue);
      expect(off.hasFlag(SemanticsFlag.isToggled), isFalse);
      handle.dispose();
    });

    testWidgets('the switches are independent, not mutually exclusive',
        (tester) async {
      // The difference from ItRadioGroup, asserted rather than assumed: a set
      // of toggles is a set of separate answers that share a caption.
      var values = <String>{'a'};
      await tester.pumpWidget(_host(StatefulBuilder(
        builder: (context, setState) => ItToggleGroup<String>(
          label: 'Gruppo di toggle',
          options: const [
            ItToggleOption(value: 'a', label: 'Primo'),
            ItToggleOption(value: 'b', label: 'Secondo'),
          ],
          values: values,
          onChanged: (v) => setState(() => values = v),
        ),
      )));

      await tester.tap(find.text('Secondo'));
      await tester.pumpAndSettle();
      expect(values, {'a', 'b'},
          reason: 'turning the second on must leave the first alone');

      await tester.tap(find.text('Primo'));
      await tester.pumpAndSettle();
      expect(values, {'b'});
    });

    testWidgets('a disabled option is inert but still announced',
        (tester) async {
      final handle = tester.ensureSemantics();
      var fired = false;
      await tester.pumpWidget(_host(ItToggleGroup<String>(
        label: 'Gruppo di toggle',
        options: const [
          ItToggleOption(value: 'a', label: 'Disabilitato', enabled: false),
        ],
        values: const {'a'},
        onChanged: (_) => fired = true,
      )));

      final data = _data(tester, 'Disabilitato');
      expect(data.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(data.hasFlag(SemanticsFlag.isEnabled), isFalse);
      expect(data.hasFlag(SemanticsFlag.isToggled), isTrue,
          reason: 'inert is not absent: the user still has to be able to learn '
              'whether the setting is on');

      await tester.tap(find.text('Disabilitato'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(fired, isFalse);
      handle.dispose();
    });

    testWidgets('3.3.1/3.3.2: required and the message sit on the group node',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItToggleGroup<String>(
        label: 'Consensi',
        options: const [ItToggleOption(value: 'a', label: 'Primo')],
        values: const {},
        required: true,
        errorText: 'Attiva almeno un consenso',
        onChanged: (_) {},
      )));

      final group = _data(tester, 'Consensi');
      expect(group.hasFlag(SemanticsFlag.isRequired), isTrue);
      expect(group.hint, 'Attiva almeno un consenso');
      expect(group.validationResult, SemanticsValidationResult.invalid,
          reason: 'the set is what failed, so the invalid state belongs to it '
              'and not to any one switch');
      handle.dispose();
    });
  });

  group('visuallyGrouped — the indicator moves, the semantics do not', () {
    testWidgets('ItCheckbox keeps its role, state and action', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItCheckbox(
        value: true,
        label: 'Checkbox selezionato',
        visuallyGrouped: true,
        onChanged: (_) {},
      )));

      final data = _data(tester, 'Checkbox selezionato');
      expect(data.hasFlag(SemanticsFlag.hasCheckedState), isTrue);
      expect(data.hasFlag(SemanticsFlag.isChecked), isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('ItRadio stays mutually exclusive', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItRadioGroup<String>(
        label: 'Gruppo di radio',
        visuallyGrouped: true,
        options: const [
          ItRadioOption(value: 'a', label: 'Opzione 1'),
          ItRadioOption(value: 'b', label: 'Opzione 2'),
        ],
        value: 'a',
        onChanged: (_) {},
      )));

      final data = _data(tester, 'Opzione 1');
      expect(data.hasFlag(SemanticsFlag.isInMutuallyExclusiveGroup), isTrue,
          reason: 'without it a screen reader calls this a checkbox, and the '
              'user is never told that choosing one clears the others');
      expect(data.hasFlag(SemanticsFlag.isChecked), isTrue);
      expect(data.value, '1 di 2');
      handle.dispose();
    });

    testWidgets('ItToggle keeps its toggled state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItToggle(
        value: true,
        label: 'Toggle acceso',
        visuallyGrouped: true,
        onChanged: (_) {},
      )));

      final data = _data(tester, 'Toggle acceso');
      expect(data.hasFlag(SemanticsFlag.hasToggledState), isTrue);
      expect(data.hasFlag(SemanticsFlag.isToggled), isTrue);
      handle.dispose();
    });

    testWidgets('2.1.1: the grouped row is still operable from the keyboard',
        (tester) async {
      var value = false;
      await tester.pumpWidget(_host(StatefulBuilder(
        builder: (context, setState) => ItCheckbox(
          value: value,
          label: 'Checkbox di esempio',
          visuallyGrouped: true,
          onChanged: (v) => setState(() => value = v),
        ),
      )));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });
  });

  group('per-option descriptions', () {
    testWidgets('3.3.2: the description is the row\'s hint, not loose text',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItCheckboxGroup<String>(
        label: 'Gruppo di checkbox',
        visuallyGrouped: true,
        options: const [
          ItCheckboxOption(
            value: 'a',
            label: 'Checkbox selezionato',
            helperText: 'Lorem ipsum dolor sit amet',
          ),
        ],
        values: const {'a'},
        onChanged: (_) {},
      )));

      expect(_data(tester, 'Checkbox selezionato').hint,
          'Lorem ipsum dolor sit amet',
          reason: 'the docs put an aria-describedby on each input; a painted '
              'line with no association is what that attribute exists to '
              'prevent');
      // And it is not *also* announced on its own.
      expect(find.bySemanticsLabel('Lorem ipsum dolor sit amet'), findsNothing);
      handle.dispose();
    });

    testWidgets('ItRadioOption carries one too', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItRadioGroup<String>(
        label: 'Gruppo di radio',
        visuallyGrouped: true,
        options: const [
          ItRadioOption(
            value: 'a',
            label: 'Opzione 1',
            helperText: 'Descrizione della prima opzione',
          ),
        ],
        value: 'a',
        onChanged: (_) {},
      )));

      expect(
          _data(tester, 'Opzione 1').hint, 'Descrizione della prima opzione');
      handle.dispose();
    });

    testWidgets('ItToggleOption carries one too', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItToggleGroup<String>(
        label: 'Gruppo di toggle',
        visuallyGrouped: true,
        options: const [
          ItToggleOption(
            value: 'a',
            label: 'Toggle acceso',
            helperText: 'Descrizione del primo interruttore',
          ),
        ],
        values: const {'a'},
        onChanged: (_) {},
      )));

      expect(_data(tester, 'Toggle acceso').hint,
          'Descrizione del primo interruttore');
      handle.dispose();
    });

    testWidgets('the description is read only in the grouped layout',
        (tester) async {
      // `.form-check-group .form-text { display:block }` is the rule that gives
      // it a line of its own. Outside that layout the kit paints no per-row
      // description at all, so neither does this.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItCheckboxGroup<String>(
        label: 'Gruppo di checkbox',
        options: const [
          ItCheckboxOption(
            value: 'a',
            label: 'Checkbox selezionato',
            helperText: 'Lorem ipsum dolor sit amet',
          ),
        ],
        values: const {'a'},
        onChanged: (_) {},
      )));

      expect(_data(tester, 'Checkbox selezionato').hint, '');
      expect(find.text('Lorem ipsum dolor sit amet'), findsNothing);
      handle.dispose();
    });
  });

  group('ItSelect — <optgroup> captions', () {
    testWidgets('1.3.1: a caption is a heading, not an unchoosable option',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItSelect<String>(
        label: 'Etichetta',
        hint: "Scegli un'opzione",
        items: const [
          ItSelectItem(value: '1', label: 'Opzione 1', group: 'Gruppo 1'),
          ItSelectItem(value: '2', label: 'Opzione 2', group: 'Gruppo 2'),
        ],
        onChanged: (_) {},
      )));

      await tester.tap(find.text("Scegli un'opzione"));
      await tester.pumpAndSettle();

      final caption = _data(tester, 'GRUPPO 1');
      expect(caption.hasFlag(SemanticsFlag.isHeader), isTrue);
      expect(caption.hasAction(SemanticsAction.tap), isFalse,
          reason: 'offering the caption as a choice would put a stop in the '
              'list that does nothing when activated');

      // The options themselves are unaffected.
      final option = _data(tester, 'Opzione 1');
      expect(option.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('an ungrouped select produces no captions', (tester) async {
      await tester.pumpWidget(_host(ItSelect<String>(
        label: 'Etichetta',
        hint: "Scegli un'opzione",
        items: const [
          ItSelectItem(value: '1', label: 'Opzione 1'),
          ItSelectItem(value: '2', label: 'Opzione 2'),
        ],
        onChanged: (_) {},
      )));

      await tester.tap(find.text("Scegli un'opzione"));
      await tester.pumpAndSettle();

      expect(find.text('Opzione 1'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      // Two options, and nothing between them.
      final list = tester.widget<ListView>(find.byType(ListView));
      expect(
          (list.childrenDelegate as SliverChildBuilderDelegate).childCount, 2);
    });
  });
}
