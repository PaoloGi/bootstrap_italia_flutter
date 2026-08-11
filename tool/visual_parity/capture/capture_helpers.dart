import 'dart:io';
import 'dart:ui' as ui;

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
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

  // `setSurfaceSize` resizes the render surface but does NOT update the view's
  // physical size, so `MediaQuery.sizeOf` keeps reporting the 800x600 default.
  // Any viewport-aware component therefore saw a size unrelated to the capture
  // it was being rendered for — a 1248px-wide header band was told the viewport
  // was 800 and collapsed to its mobile layout. Setting both keeps the capture
  // consistent with what a real device presents.
  tester.view.physicalSize = surfaceSize * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    BootstrapItaliaTheme(
      data: theme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.toThemeData(),
        home: Material(
          color: background,
          child: Center(
            // The background must be painted INSIDE the boundary. A
            // RepaintBoundary captures only what its subtree paints, so for a
            // widget that is itself transparent (a footer region whose colour
            // lives on its parent, say) the Material behind it is never in the
            // image: the capture comes out transparent, composites to white,
            // and scores ~45% against a correctly-coloured reference.
            child: RepaintBoundary(
              key: key,
              child: ColoredBox(color: background, child: child),
            ),
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
