// `.bg-dark` inverts the focus ring, and nothing here did.
//
// The two bands are the same 2px + 3px, in the opposite order:
//
//   light   box-shadow: 0 0 0 2px #fff, 0 0 0 5px #000
//   .bg-dark box-shadow: 0 0 0 2px #000, 0 0 0 5px #fff
//
// That is not decoration. §2.4.11 Focus Appearance measures the *indicator's
// own* contrast against what surrounds it, so a white-then-black ring on a dark
// band puts its black outer band against near-black and the indicator loses the
// contrast it exists to have.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the painter swaps the bands, and repaints when it changes', () {
    const light = ItFocusRingPainter(radius: 4);
    const dark = ItFocusRingPainter(radius: 4, onDark: true);
    expect(light.onDark, isFalse, reason: 'the light order is the default');
    expect(dark.shouldRepaint(light), isTrue,
        reason: 'a ring that changed surface must repaint, or a button toggled '
            'onto a dark band keeps the wrong order until something else '
            'invalidates it');
  });

  testWidgets('an onDark button asks for the inverted ring', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: ItButton(
            onDark: true,
            onPressed: () {},
            child: const Text('Conferma'),
          ),
        ),
      ),
    ));

    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();

    final ring = t.widget<ItFocusRing>(find.byType(ItFocusRing));
    expect(ring.visible, isTrue, reason: 'focused, so the ring paints');
    expect(ring.onDark, isTrue,
        reason: 'ItButton must forward onDark to the ring; it painted the '
            'light order on dark bands until this was threaded through');
  });

  testWidgets('an ordinary button keeps the light ring', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: ItButton(onPressed: () {}, child: const Text('Conferma')),
        ),
      ),
    ));
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();
    expect(t.widget<ItFocusRing>(find.byType(ItFocusRing)).onDark, isFalse);
  });
}
