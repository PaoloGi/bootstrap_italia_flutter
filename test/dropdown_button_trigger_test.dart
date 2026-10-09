// Tapping an ItButton trigger must open the menu: the button's own tap
// recogniser used to win the gesture arena over the dropdown's.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping an ItButton trigger opens and closes the menu',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: ItDropdown(
            trigger: ItButton(onPressed: () {}, child: const Text('Apri')),
            items: [ItDropdownItem(label: 'Azione 1', onTap: () {})],
          ),
        ),
      ),
    ));
    expect(find.text('Azione 1'), findsNothing);
    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
    expect(find.text('Azione 1'), findsOneWidget);
    // The open menu's dismiss barrier sits over the trigger and closes it.
    await tester.tap(find.text('Apri'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Azione 1'), findsNothing);
  });

  Future<Rect> openAt(
      WidgetTester tester, ItDropdownDirection d, Alignment where) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: where,
          child: ItDropdown(
            direction: d,
            trigger: ItButton(onPressed: () {}, child: const Text('Apri')),
            items: [ItDropdownItem(label: 'Azione 1', onTap: () {})],
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
    return tester.getRect(find.byType(ItDropdownMenu));
  }

  const screen = Rect.fromLTWH(0, 0, 400, 600);

  for (final (d, where) in [
    (ItDropdownDirection.left, Alignment.centerLeft),
    (ItDropdownDirection.right, Alignment.centerRight),
    (ItDropdownDirection.up, Alignment.topCenter),
    (ItDropdownDirection.down, Alignment.bottomCenter),
  ]) {
    testWidgets('$d with no room on that side flips and stays on screen',
        (tester) async {
      final menu = await openAt(tester, d, where);
      expect(screen.contains(menu.topLeft), isTrue);
      expect(screen.contains(menu.bottomRight), isTrue);
      final trigger = tester.getRect(find.text('Apri'));
      expect(menu.overlaps(trigger.deflate(1)), isFalse,
          reason: 'flipped beside the trigger, not over it');
    });
  }

  testWidgets('a menu with room keeps the side it was asked for',
      (tester) async {
    final menu =
        await openAt(tester, ItDropdownDirection.left, Alignment.centerRight);
    expect(
        menu.right, lessThanOrEqualTo(tester.getRect(find.text('Apri')).left));
  });
}
