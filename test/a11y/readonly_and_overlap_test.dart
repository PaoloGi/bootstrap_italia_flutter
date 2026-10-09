// Two defects found by running the kit inside a real application, on a real
// device, against real data. Neither showed up in 921 unit tests, the visual
// parity harness, or the accessibility sweeps — both need a filled-in form on
// a narrow screen to appear at all.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
// Not exported by the barrel — the metrics are the kit's internal record of
// the CSS, not public API. Reached directly because this test is about the
// relationship between two of those numbers.
import 'package:bootstrap_italia_flutter/src/form/it_form_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: SizedBox(width: 393, child: child)),
    );

void main() {
  // `onChanged: null` is Flutter's convention for a disabled control — how
  // DropdownButton, TextField and Checkbox all express read-only. ItSelect
  // honoured only `enabled`, so a view-only document still had an operable
  // dropdown: the user could open it and change the value.
  group('a select with no callback is not operable', () {
    testWidgets('onChanged: null does not open the list', (tester) async {
      await tester.pumpWidget(_host(
        const ItSelect<int>(
          hint: 'Evento o manifestazione',
          items: [
            ItSelectItem<int>(value: 1, label: 'Altro'),
            ItSelectItem<int>(value: 2, label: 'Incendio'),
          ],
          onChanged: null,
        ),
      ));

      await tester.tap(find.byType(ItSelect<int>), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Incendio'), findsNothing,
          reason: 'the option list opened on a read-only select — the caller '
              'disabled it the ordinary Flutter way and was ignored');
    });

    testWidgets('a callback still opens it', (tester) async {
      await tester.pumpWidget(_host(
        ItSelect<int>(
          hint: 'Evento o manifestazione',
          items: const [
            ItSelectItem<int>(value: 1, label: 'Altro'),
            ItSelectItem<int>(value: 2, label: 'Incendio'),
          ],
          onChanged: (_) {},
        ),
      ));

      // The hint, not `find.byType(ItSelect)`. The widget's box now includes
      // `.form-group`'s 48px bottom margin, so its CENTRE is in the empty
      // space below the control rather than on it — a real consequence of the
      // margin worth stating: anything targeting the widget's centre, test or
      // caller, has to target the control instead.
      await tester.tap(find.text('Evento o manifestazione'));
      await tester.pumpAndSettle();
      expect(find.text('Incendio'), findsOneWidget,
          reason: 'the fix must not disable every select');
    });

    testWidgets('it matches ItCheckbox, ItRadio and ItToggle', (tester) async {
      // The three of them already read `enabled && onChanged != null`. A kit
      // where one control out of four disagrees is worse than one where none
      // of them do, because the odd one out is the one nobody checks.
      await tester.pumpWidget(_host(Column(children: const [
        ItCheckbox(label: 'a', value: false, onChanged: null),
        ItRadio<int>(label: 'b', value: 1, groupValue: 0, onChanged: null),
        ItToggle(label: 'c', value: false, onChanged: null),
      ])));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // `activeLabelOffset` is -0.85 * 39px = -33.15px: when the label floats it
  // is drawn ABOVE the field, outside the widget's own bounds, and nothing
  // reserves that space. Stack two fields and the upper one is painted over.
  //
  // Bootstrap Italia does the same thing in CSS (`translateY(-85%)`), but the
  // surrounding `.form-group` margin absorbs it there. Nothing absorbs it here.
  group('a floating label stays inside its own field', () {
    testWidgets('it does not paint over the widget above it', (tester) async {
      await tester.pumpWidget(_host(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ItSelect<int>(
            label: 'Evento o manifestazione',
            value: 1,
            items: const [ItSelectItem<int>(value: 1, label: 'Altro')],
            onChanged: (_) {},
          ),
          ItInput(
            label: 'Specificare altro',
            controller: TextEditingController(text: 'test'),
          ),
        ],
      )));
      await tester.pump();

      final selectRect = tester.getRect(find.byType(ItSelect<int>));
      final labelRect = tester.getRect(find.text('Specificare altro'));

      // The label is ALLOWED into the previous group's margin — that is what
      // `.form-group { margin-bottom: 3rem }` reserves it for. What it must
      // not touch is the previous control's painted box, which ends where its
      // margin begins.
      final selectPaintedBottom =
          selectRect.bottom - ItFormMetrics.groupMarginBottom;

      expect(labelRect.top, greaterThanOrEqualTo(selectPaintedBottom),
          reason: 'the floating label of the field BELOW is drawn at '
              'y=${labelRect.top}, over the select whose painted box ends at '
              'y=$selectPaintedBottom — exactly as seen in PC03 where '
              '"Specificare altro" was painted through "Altro"');

      // And the value the user is reading stays clear of it.
      expect(labelRect.top,
          greaterThanOrEqualTo(tester.getRect(find.text('Altro')).bottom),
          reason: 'the label must not cross the selected value either');
    });

    testWidgets('the clearance survives every text scale', (tester) async {
      // The margin is a fixed 48px; the label and the control both grow with
      // the text scaler, so it is not obvious the 48 keeps winning. Measured:
      // the gap narrows from 22.85 at 1.0 to 14.85 at 2.0 and then PLATEAUS —
      // the label's rise is a fixed -33.15 while the control grows underneath
      // it, so the two stop diverging. It never runs out between 1.0 and 3.0.
      //
      // 2.35 is iOS accessibility-extra-large, the smallest category clearing
      // WCAG 1.4.4's 200%.
      for (final scale in [1.0, 1.3, 1.6, 2.0, 2.35, 3.0]) {
        await tester.pumpWidget(_host(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ItSelect<int>(
                  label: 'Evento o manifestazione',
                  value: 1,
                  items: const [ItSelectItem<int>(value: 1, label: 'Altro')],
                  onChanged: (_) {},
                ),
                ItInput(
                  label: 'Specificare altro',
                  controller: TextEditingController(text: 'test'),
                ),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final valore = tester.getRect(find.text('Altro'));
        final etichetta = tester.getRect(find.text('Specificare altro'));
        expect(etichetta.top, greaterThanOrEqualTo(valore.bottom),
            reason: 'at textScale $scale the label overlaps the value above '
                'it — the fixed 48px margin has stopped covering the rise');
      }
    });

    test('the reserved margin is larger than the label rises', () {
      // The whole mechanism in one line. If either number is ever changed
      // without the other, the overlap comes straight back — and it comes back
      // silently, because nothing clips the label.
      expect(ItFormMetrics.groupMarginBottom,
          greaterThan(-ItFormMetrics.activeLabelOffset),
          reason: '.form-group margin-bottom (48) must exceed the '
              'translateY(-85%) of a 39px label line box (33.15)');
    });
  });
}
