import 'dart:io';
import 'dart:ui' as ui;

import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders [child] in isolation and writes a tightly-cropped PNG of just
/// that widget's own bounds to [outputPath], for comparison against a
/// Playwright element screenshot of the equivalent design-react-kit story.
Future<void> captureWidget(
  WidgetTester tester, {
  required Widget child,
  required String outputPath,
  Color background = Colors.white,
  double pixelRatio = 2.0,
  Size surfaceSize = const Size(900, 700),
}) async {
  final theme = BootstrapItaliaThemeData.standard();
  final key = GlobalKey();

  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    BootstrapItaliaTheme(
      data: theme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.toThemeData(),
        home: Material(
          color: background,
          child: Center(
            child: RepaintBoundary(key: key, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    final file = File(outputPath);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    image.dispose();
  });
}
