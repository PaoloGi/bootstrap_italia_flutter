// The package's own on-device evidence.
//
// `doc/conformance.md` records, as gap 2, that every pixel measurement in this
// repo comes from Flutter Web. The semantics contracts are platform-independent
// — they assert Flutter's own tree — but layout is not, and three of the last
// four defects found in this package appeared only on real hardware:
//
//   * the bottom navigation drew its labels under the home indicator, because
//     nothing in a widget test has a safe-area inset;
//   * a floating label painted through the field above it, at a size that
//     depends on real font metrics;
//   * a document card's icon measured zero-width, because `Image.asset`
//     resolves nothing in the test harness.
//
// So this runs the same page the web soak runs, on the device, and asserts what
// only the device can settle: real fonts, real text metrics, real insets.
//
//   cd example
//   flutter test integration_test/device_soak_test.dart -d <device-id>
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bootstrap_italia_example/soak.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Runs [body] with layout errors collected, and restores the handler
  /// **before returning**.
  ///
  /// Not `addTearDown`: the binding asserts that `FlutterError.onError` is back
  /// to normal by the time `expect` runs, because an error raised after the
  /// assertion has nowhere left to go. Restoring in a tear-down fails the whole
  /// suite with "A test overrode FlutterError.onError but either failed to
  /// return it to its original state…".
  Future<List<String>> collectingErrors(
    Future<void> Function() body,
  ) async {
    final errors = <String>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (d) => errors.add(d.exception.toString());
    try {
      await body();
    } finally {
      FlutterError.onError = previous;
    }
    return errors;
  }

  Future<void> pumpSoak(WidgetTester tester, {Widget? app}) async {
    await tester.pumpWidget(app ?? const SoakApp());
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('every component lays out on the device', (tester) async {
    final errors = await collectingErrors(() => pumpSoak(tester));
    expect(errors, isEmpty,
        reason: 'a layout error here is one no widget test can produce: this '
            'is the device\'s own fonts and metrics');
  });

  testWidgets('the whole page scrolls end to end', (tester) async {
    // Scrolling is where a laid-out-but-unreachable component shows up, and
    // where an overflow that only appears at one offset appears.
    final errors = await collectingErrors(() async {
      await pumpSoak(tester);
      final scrollable = find.byType(Scrollable).first;
      for (var i = 0; i < 25; i++) {
        await tester.drag(scrollable, const Offset(0, -320));
        await tester.pump(const Duration(milliseconds: 60));
      }
    });
    expect(errors, isEmpty, reason: 'something broke while scrolling');
  });

  testWidgets('the fonts are the package\'s, not a fallback', (tester) async {
    // The single most useful thing a device run proves. In a widget test with
    // no registered fonts every glyph is square, and any width measured is
    // fiction — a report card "overflowed by 36px" that way, and did not.
    await pumpSoak(tester);

    final text = tester.widget<Text>(find.text('buttons').first);
    expect(text, isNotNull);

    // A real face has proportional glyphs: 'iii' must be narrower than 'WWW'.
    final narrow = _measure(tester, 'iii');
    final wide = _measure(tester, 'WWW');
    expect(wide, greaterThan(narrow * 1.5),
        reason: 'glyphs are the same width — the platform is rendering a '
            'fallback face, and every width measured here is meaningless');
  });

  // There is deliberately NO "nothing is drawn under the home indicator" test
  // here, and the reason is worth keeping.
  //
  // One was written, and it passed with `ItBottomNav`'s inset handling deleted
  // — twice, through two different fixes. First it read
  // `tester.view.viewPadding.bottom`, got zero, and compared against zero.
  // Reading `MediaQuery.paddingOf` instead gave a real number and it STILL
  // passed, because `Scaffold` positions `bottomNavigationBar` clear of the
  // system inset on its own: inside a Scaffold the property is never
  // exercised, whatever the component does.
  //
  // The property is real and it is covered — by
  // `test/a11y/safe_area_contract_test.dart`, which mounts the bar with an
  // explicit inset and goes red when the handling is removed. A second copy
  // here that cannot fail would be worse than nothing: it would read as device
  // evidence for something it never checked.

  testWidgets('it survives 200% text on the device', (tester) async {
    final errors = await collectingErrors(() async {
      await pumpSoak(
        tester,
        app: MediaQuery(
          data: MediaQueryData(
            textScaler: const TextScaler.linear(2.0),
            size: tester.view.physicalSize / tester.view.devicePixelRatio,
            padding: EdgeInsets.fromViewPadding(
              tester.view.viewPadding,
              tester.view.devicePixelRatio,
            ),
          ),
          child: const SoakApp(),
        ),
      );
    });
    expect(errors, isEmpty, reason: 'WCAG 1.4.4 at the device\'s own width');
  });
}

/// Width of [s] as the device actually rasterises it.
double _measure(WidgetTester tester, String s) {
  final painter = TextPainter(
    text: TextSpan(
      text: s,
      style: const TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        fontSize: 40,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}
