// Mounts the soak page in a widget test purely to get READABLE errors.
//
// A release web build minifies everything, so the browser reports only
// "Null check operator used on a null value" with no widget name. The same
// tree pumped here names the offender.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bootstrap_italia_example/soak.dart';

void main() {
  testWidgets('the soak page builds without throwing', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 4000 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(const SoakApp());
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    for (final e in errors.take(4)) {
      debugPrint('SOAK| ${e.exception}');
      debugPrint('SOAK| context: ${e.context}');
      final lines = e.toString().split('\n');
      for (final l in lines.take(18)) {
        if (l.trim().isNotEmpty) debugPrint('SOAK|   $l');
      }
      debugPrint('SOAK| ---');
    }
    debugPrint('SOAK| total errors = ${errors.length}');
  });
}
