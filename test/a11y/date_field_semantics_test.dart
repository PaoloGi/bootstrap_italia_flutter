// What a date field tells assistive technology.
//
// The control is a read-only text field that opens the platform's picker, so
// two things have to hold: the field itself still reads as a named field with
// a value, and the way in without a pointer — the calendar button — is a named
// focus stop. A picker you can only reach by tapping a field is not reachable
// at all for a keyboard or switch user.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _value = DateTime(2026, 9, 10, 18, 57);

Future<void> _pump(WidgetTester t, Widget field) async {
  await t.pumpWidget(BootstrapItaliaTheme(
    data: BootstrapItaliaThemeData.standard(),
    child: MaterialApp(
      theme: BootstrapItaliaThemeData.standard().toThemeData(),
      home: Scaffold(body: Center(child: SizedBox(width: 400, child: field))),
    ),
  ));
}

/// The first semantics node satisfying [test].
SemanticsData? _find(WidgetTester t, bool Function(SemanticsData) test) {
  SemanticsData? found;
  void walk(SemanticsNode n) {
    if (found != null) return;
    final d = n.getSemanticsData();
    if (test(d)) found = d;
    n.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(t.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

void main() {
  testWidgets('the field carries its name and its value', (t) async {
    final handle = t.ensureSemantics();
    await _pump(
        t,
        ItDateField(
          label: 'Data inizio',
          value: _value,
          onChanged: (_) {},
        ));

    final field = _find(t, (d) => d.hasFlag(SemanticsFlag.isTextField));
    expect(field, isNotNull, reason: 'it is still a field, read-only or not');
    expect(field!.label, contains('Data inizio'),
        reason: 'the floating label is painted as a sibling, so it has to be '
            're-attached to the control');
    expect(field.value, '10/09/2026',
        reason: 'what the field holds is what AT must read');
    handle.dispose();
  });

  testWidgets('the button that opens the picker is named, and is a button',
      (t) async {
    final handle = t.ensureSemantics();
    await _pump(t, ItDateField(value: _value, onChanged: (_) {}));

    final button = _find(
        t, (d) => d.hasFlag(SemanticsFlag.isButton) && d.label.isNotEmpty);
    expect(button, isNotNull);
    expect(button!.label, 'Scegli la data');
    expect(button.hasAction(SemanticsAction.tap), isTrue);
    handle.dispose();
  });

  testWidgets('a required field announces the constraint', (t) async {
    final handle = t.ensureSemantics();
    await _pump(
        t,
        ItDateField(
          label: 'Data inizio',
          value: _value,
          required: true,
          onChanged: (_) {},
        ));
    final field = _find(t, (d) => d.hasFlag(SemanticsFlag.isTextField));
    expect(field!.hasFlag(SemanticsFlag.isRequired), isTrue,
        reason: 'WCAG 3.3.2: the asterisk is paint; AT needs the flag');
    handle.dispose();
  });

  testWidgets('a disabled field says so, and offers no way in', (t) async {
    final handle = t.ensureSemantics();
    await _pump(
        t,
        ItDateField(
          label: 'Data inizio',
          value: _value,
          enabled: false,
          onChanged: (_) {},
        ));
    final field = _find(t, (d) => d.hasFlag(SemanticsFlag.isTextField));
    expect(field!.hasFlag(SemanticsFlag.isEnabled), isFalse);

    final button = _find(
        t, (d) => d.hasFlag(SemanticsFlag.isButton) && d.label.isNotEmpty);
    expect(button == null || !button.hasAction(SemanticsAction.tap), isTrue,
        reason: 'a disabled control must not keep an action AT can fire');
    handle.dispose();
  });

  testWidgets('the picker is reachable without a pointer', (t) async {
    await _pump(t, ItDateField(value: _value, onChanged: (_) {}));
    final button = find.byWidgetPredicate(
        (w) => w is ItIconAction && w.label == 'Scegli la data');

    // Tab until focus is *inside* the button: a user who cannot tap must still
    // be able to open the picker.
    var reached = false;
    for (var i = 0; i < 6 && !reached; i++) {
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      reached = _focusInside(button);
    }
    expect(reached, isTrue, reason: 'Tab never reached the picker button');
  });
}

/// Whether the primary focus lies within [ancestor]'s subtree.
bool _focusInside(Finder ancestor) {
  final focused = FocusManager.instance.primaryFocus?.context;
  if (focused == null) return false;
  final target = ancestor.evaluate().single;
  var inside = false;
  focused.visitAncestorElements((e) {
    if (e == target) inside = true;
    return !inside;
  });
  return inside;
}
