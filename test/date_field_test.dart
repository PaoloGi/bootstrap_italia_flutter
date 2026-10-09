// ItDateField opens the platform's picker, because that is what upstream does.
//
// Bootstrap Italia's "Input Datepicker" and "Input Hourpicker" are plain
// `.form-control`s — read back from design-react-kit in Chromium, the markup is
// `<input type="date" class="form-control">` with no panel of its own. The
// browser supplies the picker, and the browser's picker is the operating
// system's: Cupertino's wheel on iOS and macOS, the OS's dialogs elsewhere.
// A calendar drawn by this package would have no upstream to be faithful to.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _android = TargetPlatformVariant.only(TargetPlatform.android);
final _ios = TargetPlatformVariant.only(TargetPlatform.iOS);

final _value = DateTime(2026, 9, 10, 18, 57);

Future<void> _pump(WidgetTester t, Widget field) async {
  t.view.physicalSize = const Size(1200, 2000);
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
  await t.pumpWidget(BootstrapItaliaTheme(
    data: BootstrapItaliaThemeData.standard(),
    child: MaterialApp(
      theme: BootstrapItaliaThemeData.standard().toThemeData(),
      home: Scaffold(body: Center(child: SizedBox(width: 400, child: field))),
    ),
  ));
}

Finder _pickButton(String name) =>
    find.byWidgetPredicate((w) => w is ItIconAction && w.label == name);

void main() {
  testWidgets('shows the value the way upstream writes it', (t) async {
    for (final (mode, text) in [
      (ItDateFieldMode.date, '10/09/2026'),
      (ItDateFieldMode.time, '18:57'),
      (ItDateFieldMode.dateAndTime, '10/09/2026 18:57'),
    ]) {
      await _pump(t, ItDateField(value: _value, mode: mode, onChanged: (_) {}));
      expect(find.text(text), findsOneWidget, reason: '$mode');
    }
  });

  testWidgets('empty when there is no value', (t) async {
    await _pump(t, ItDateField(onChanged: (_) {}));
    expect(
        t.widget<EditableText>(find.byType(EditableText)).controller.text, '');
  });

  testWidgets('the button that opens it has a name', (t) async {
    await _pump(t, ItDateField(value: _value, onChanged: (_) {}));
    expect(_pickButton('Scegli la data'), findsOneWidget,
        reason: 'without a name, the only pointer-free way in is unlabelled');
    await _pump(
        t,
        ItDateField(
            value: _value, mode: ItDateFieldMode.time, onChanged: (_) {}));
    expect(_pickButton("Scegli l'ora"), findsOneWidget);
  });

  testWidgets('a tap opens the OS dialog, and the pick comes back', (t) async {
    DateTime? picked;
    await _pump(t, ItDateField(value: _value, onChanged: (v) => picked = v));
    await t.tap(find.byType(TextField));
    await t.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget,
        reason: 'off iOS the OS dialog is the picker');

    await t.tap(find.text('OK'));
    await t.pumpAndSettle();
    expect(picked, isNotNull);
    expect((picked!.year, picked!.month, picked!.day), (2026, 9, 10));
  }, variant: _android);

  testWidgets('the button opens it too', (t) async {
    DateTime? picked;
    await _pump(t, ItDateField(value: _value, onChanged: (v) => picked = v));
    await t.tap(_pickButton('Scegli la data'));
    await t.pumpAndSettle();
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();
    expect(picked, isNotNull);
  }, variant: _android);

  testWidgets('dateAndTime asks for the day, then the time', (t) async {
    DateTime? picked;
    await _pump(
        t,
        ItDateField(
          value: _value,
          mode: ItDateFieldMode.dateAndTime,
          onChanged: (v) => picked = v,
        ));
    await t.tap(find.byType(TextField));
    await t.pumpAndSettle();
    await t.tap(find.text('OK')); // the day
    await t.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget,
        reason: 'the second half of the value needs asking for');
    await t.tap(find.text('OK')); // the time
    await t.pumpAndSettle();
    expect(picked, DateTime(2026, 9, 10, 18, 57));
  }, variant: _android);

  testWidgets('on iOS it is the wheel, confirmed by a button', (t) async {
    DateTime? picked;
    await _pump(t, ItDateField(value: _value, onChanged: (v) => picked = v));
    await t.tap(find.byType(TextField));
    await t.pumpAndSettle();
    expect(find.byType(CupertinoDatePicker), findsOneWidget,
        reason: 'iOS shows a wheel for a date input, not a Material dialog');
    expect(find.byType(DatePickerDialog), findsNothing);

    await t.tap(find.text('Fatto'));
    await t.pumpAndSettle();
    expect(picked, isNotNull);
  }, variant: _ios);

  testWidgets('disabled: nothing opens', (t) async {
    var calls = 0;
    await _pump(
        t,
        ItDateField(
          value: _value,
          enabled: false,
          onChanged: (_) => calls++,
        ));
    await t.tap(find.byType(TextField), warnIfMissed: false);
    await t.pumpAndSettle();
    // The button too: a disabled field's text field swallows taps on its own,
    // so the button is the half that has to refuse for itself.
    await t.tap(_pickButton('Scegli la data'), warnIfMissed: false);
    await t.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(find.byType(CupertinoDatePicker), findsNothing);
    expect(calls, 0);
  }, variant: _android);
}
