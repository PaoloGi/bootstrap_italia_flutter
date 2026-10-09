// WCAG 1.4.4 Resize Text — a standing guard for a defect class that no other
// test in this repo could see.
//
// `ItCenterHeader` pinned its band to a flat 120px, so at large text the
// institution tag line was sliced off and Flutter painted an overflow stripe
// across it. Nothing caught it: the unit tests render at the default scale, the
// visual-parity harness captures at the default scale, and the Android device
// sweep could not reach that phone's text-size setting (its ROM refuses
// `WRITE_SETTINGS`). It took an iOS simulator, where the scale can be driven
// from the OS, to make it visible — 16 August 2026.
//
// So the check is brought back here, where it runs on every commit. A pinned
// dimension around text that can grow is the bug; this pumps the components at
// the scales the criterion cares about and fails on any overflow.
//
// SCALES. iOS offers no exact 200%: `accessibility-large` is 33/17 = 1.94 and
// `accessibility-extra-large` is 40/17 = 2.35 (the engine computes the factor
// as body-point-size over 17). 1.94 is tested because it is *inside* the range
// §1.4.4 requires, and 2.0 because that is the number in the criterion.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A phone-width host at [scale], deliberately narrow — 393pt is the iPhone 16
/// logical width, where these defects actually appeared.
Widget _host(Widget child, double scale) => MediaQuery(
      data: MediaQueryData(
        size: const Size(393, 852),
        textScaler: TextScaler.linear(scale),
      ),
      child: BootstrapItaliaTheme(
        data: BootstrapItaliaThemeData.standard(),
        child: MaterialApp(
          theme: BootstrapItaliaThemeData.standard().toThemeData(),
          home: Scaffold(
            body: SizedBox(width: 393, child: child),
          ),
        ),
      ),
    );

/// Pumps [build] at [scale] and fails if anything overflowed.
///
/// `takeException` is what makes this work: a RenderBox that paints the
/// yellow-and-black stripe also throws in a debug build, and an uncaught
/// exception would otherwise be swallowed as an unrelated test failure.
Future<void> expectNoOverflow(
  WidgetTester tester,
  Widget Function() build,
  double scale,
  String what,
) async {
  await tester.pumpWidget(_host(build(), scale));
  await tester.pump();
  final error = tester.takeException();
  expect(
    error,
    isNull,
    reason: '$what overflowed at ${(scale * 100).round()}% text. WCAG 1.4.4 '
        'requires content up to 200% without loss — a pinned width or height '
        'around scalable text is the usual cause. Scale the dimension with '
        '`MediaQuery.textScalerOf(context)` rather than releasing it, which '
        'changes the layout at the default scale and breaks visual parity.',
  );
}

void main() {
  // 1.94 is the iOS category just inside the required range; 2.0 is the
  // criterion's own number.
  for (final scale in <double>[1.94, 2.0]) {
    final pct = (scale * 100).round();

    group('§1.4.4 at $pct% text', () {
      testWidgets('ItCenterHeader does not overflow its band', (tester) async {
        await expectNoOverflow(
          tester,
          () => const ItCenterHeader(
            title: 'Nome dell\'Ente',
            subtitle: 'Tag line dell\'Istituzione',
          ),
          scale,
          'ItCenterHeader',
        );
      });

      testWidgets('ItCenterHeader small does not overflow its band',
          (tester) async {
        await expectNoOverflow(
          tester,
          () => const ItCenterHeader(
            title: 'Nome dell\'Ente',
            subtitle: 'Tag line dell\'Istituzione',
            small: true,
          ),
          scale,
          'ItCenterHeader(small: true)',
        );
      });

      testWidgets('ItSlimHeader does not overflow its band', (tester) async {
        await expectNoOverflow(
          tester,
          () => const ItSlimHeader(institutionName: 'Ente appartenenza'),
          scale,
          'ItSlimHeader',
        );
      });
    });
  }
}
