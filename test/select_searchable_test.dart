// `ItSelect(searchable: true)` threw on open.
//
// Its search `TextField` is built inside an `OverlayEntry`, which mounts in the
// Overlay's subtree — a *sibling* of the host `Scaffold`, not a descendant. So
// nothing above it satisfied `debugCheckHasMaterial` and opening the dropdown
// asserted. Nothing caught it: no test and no parity capture had ever opened a
// searchable select.
//
// The fix is the smallest ancestor the assert accepts, a
// `Material(type: MaterialType.transparency)`, with `ItDefaultTextStyle`
// re-applied *inside* it — Material wraps its child in an
// `AnimatedDefaultTextStyle` carrying `ThemeData.textTheme.bodyMedium`, which
// would otherwise re-leak the typography that ItDefaultTextStyle exists to stop.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSelect(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            child: ItSelect<String>(
              label: 'Regione',
              searchable: true,
              items: const [
                ItSelectItem(value: 'lazio', label: 'Lazio'),
                ItSelectItem(value: 'lombardia', label: 'Lombardia'),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a searchable select opens without asserting', (tester) async {
    await pumpSelect(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull,
        reason:
            'the search field is inside an OverlayEntry, which is a sibling '
            'of the host Scaffold — so debugCheckHasMaterial found no Material '
            'above it and the dropdown asserted on open');
    expect(find.byType(TextField), findsOneWidget,
        reason: 'the search field renders');
  });

  testWidgets('the search field filters the options', (tester) async {
    await pumpSelect(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'lomb');
    await tester.pumpAndSettle();

    expect(find.text('Lombardia'), findsOneWidget);
    expect(find.text('Lazio'), findsNothing,
        reason: 'opening without asserting is not enough — the field has to '
            'actually drive the filter');
  });

  testWidgets('the search field does not inherit Material typography',
      (tester) async {
    // The Material added to satisfy the assert brings an
    // AnimatedDefaultTextStyle with it. ItDefaultTextStyle goes back on inside
    // it for that reason; without it the search field renders in Roboto at
    // Material's letter spacing while the rest of the control is Titillium.
    await pumpSelect(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    final resolved = field.style ??
        DefaultTextStyle.of(tester.element(find.byType(TextField))).style;
    expect(resolved.letterSpacing, 0,
        reason: 'Bootstrap Italia body copy has no tracking; Material leaks '
            '0.25px through bodyMedium');
  });
}
