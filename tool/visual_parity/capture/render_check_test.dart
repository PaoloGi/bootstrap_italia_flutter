// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
// ignore_for_file: prefer_const_literals_to_create_immutables
//
// A capture job, not shipped code: it exists to produce PNGs a human can
// look at. The const-ness of a throwaway placeholder is not worth the noise.
// Renders the components added in this session to PNGs, so they can be LOOKED
// AT rather than merely asserted about. Not a parity job: there is no React
// reference for these, and the point is to see them.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_helpers.dart';

const _out = '/tmp/render_check';

Future<void> _loadIconFont() async {
  final packageConfig =
      File('.dart_tool/package_config.json').readAsStringSync();
  final match = RegExp(
    r'"name"\s*:\s*"bootstrap_italia_icons"\s*,\s*"rootUri"\s*:\s*"([^"]+)"',
  ).firstMatch(packageConfig);
  if (match == null) return;
  var root = match.group(1)!;
  if (root.startsWith('file://')) root = Uri.parse(root).toFilePath();
  final fontFile = File('$root/fonts/BootstrapItaliaIcons.ttf');
  if (!fontFile.existsSync()) return;
  final bytes =
      ByteData.sublistView(Uint8List.fromList(await fontFile.readAsBytes()));
  for (final family in [
    'BootstrapItaliaIcons',
    'packages/bootstrap_italia_icons/BootstrapItaliaIcons',
  ]) {
    await (FontLoader(family)..addFont(Future.value(bytes))).load();
  }
}

/// Captures the whole surface after [act] has run — for anything that lives in
/// a route (the offcanvas) rather than inline in the tree.
///
/// The boundary is an explicit key around the whole app rather than a search
/// for the first RenderRepaintBoundary: a route renders inside the Navigator,
/// which is inside MaterialApp, so wrapping the app catches it.
Future<void> captureScreen(
  WidgetTester tester, {
  required Widget home,
  required Future<void> Function(BuildContext context) act,
  required String outputPath,
  Size surfaceSize = const Size(420, 780),
  double pixelRatio = 2.0,
}) async {
  final theme = BootstrapItaliaThemeData.standard();
  final key = GlobalKey();
  await tester.binding.setSurfaceSize(surfaceSize);
  tester.view.physicalSize = surfaceSize * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(() {
    tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  late BuildContext ctx;
  await tester.pumpWidget(RepaintBoundary(
    key: key,
    child: BootstrapItaliaTheme(
      data: theme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.toThemeData(),
        home: Builder(builder: (c) {
          ctx = c;
          return home;
        }),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  // Not awaited: `show` completes only when the panel is popped.
  unawaited(act(ctx));
  await tester.pumpAndSettle();

  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await (File(outputPath)..createSync(recursive: true))
        .writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(_loadIconFont);

  testWidgets('bottom nav', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_out/01_bottom_nav.png',
      surfaceSize: const Size(420, 120),
      child: SizedBox(
        width: 420,
        child: ItBottomNav(
          selectedIndex: 1,
          onSelected: (_) {},
          items: const [
            ItBottomNavItem(label: 'Crea', icon: BootstrapItaliaIcons.it_file),
            ItBottomNavItem(
                label: 'Da Evadere', icon: BootstrapItaliaIcons.it_pencil),
            ItBottomNavItem(
                label: 'Storico', icon: BootstrapItaliaIcons.it_clock),
            ItBottomNavItem(
                label: 'Report',
                icon: BootstrapItaliaIcons.it_chart_line,
                badge: 3),
          ],
        ),
      ),
    );
  });

  testWidgets('sidebar', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_out/02_sidebar.png',
      surfaceSize: const Size(360, 320),
      child: SizedBox(
        width: 320,
        child: ItSidebar(
          title: 'Navigazione',
          lineRight: true,
          child: ItList(items: const [
            ItListItem(title: 'Panoramica', active: true),
            ItListItem(title: 'Documenti'),
            ItListItem(title: 'Impostazioni'),
          ]),
        ),
      ),
    );
  });

  testWidgets('carousel', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_out/03_carousel.png',
      surfaceSize: const Size(420, 340),
      child: SizedBox(
        width: 400,
        height: 300,
        child: ItCarousel(
          height: 200,
          items: [
            const ColoredBox(
                color: Color(0xFFE8F0FA),
                child: Center(child: Text('Allegato 1'))),
            const ColoredBox(
                color: Color(0xFFF0E8FA),
                child: Center(child: Text('Allegato 2'))),
            const ColoredBox(
                color: Color(0xFFE8FAF0),
                child: Center(child: Text('Allegato 3'))),
          ],
        ),
      ),
    );
  });

  testWidgets('carousel with autoplay (pause control visible)', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_out/04_carousel_autoplay.png',
      surfaceSize: const Size(420, 380),
      child: SizedBox(
        width: 400,
        height: 340,
        child: ItCarousel(
          height: 200,
          autoPlay: true,
          autoPlayInterval: const Duration(hours: 1),
          items: [
            const ColoredBox(
                color: Color(0xFFE8F0FA),
                child: Center(child: Text('Allegato 1'))),
            const ColoredBox(
                color: Color(0xFFF0E8FA),
                child: Center(child: Text('Allegato 2'))),
          ],
        ),
      ),
    );
  });

  testWidgets('offcanvas', (tester) async {
    await captureScreen(
      tester,
      outputPath: '$_out/05_offcanvas.png',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Contenuto della pagina dietro il pannello'),
            ],
          ),
        ),
      ),
      act: (context) => ItOffcanvas.show<void>(
        context: context,
        title: 'Menù',
        body: ItSidebar(
          child: ItList(items: const [
            ItListItem(title: 'Panoramica', active: true),
            ItListItem(title: 'Documenti'),
            ItListItem(title: 'Impostazioni'),
          ]),
        ),
      ),
    );
  });

  testWidgets('modal as a real route', (tester) async {
    await captureScreen(
      tester,
      outputPath: '$_out/06_modal_route.png',
      surfaceSize: const Size(420, 500),
      home: const Scaffold(body: Center(child: Text('Pagina'))),
      act: (context) => ItModal.show<void>(
        context: context,
        title: 'Titolo della modale',
        body: const Text('Woohoo, stai leggendo questo testo in una modale!'),
        actions: [
          ItButton(onPressed: () {}, child: const Text('Salva modifiche')),
        ],
      ),
    );
  });

  testWidgets('the PC03 overlap', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_out/07_form_overlap.png',
      surfaceSize: const Size(360, 300),
      child: SizedBox(
        width: 320,
        // The FIRST field's own floating label still rises 33px above its box —
        // `.form-group { margin-top: 0 }` upstream, so the page is expected to
        // provide that space. Reproduced here so the label is in frame.
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItSelect<int>(
                label: 'Evento o manifestazione',
                value: 1,
                items: const [ItSelectItem<int>(value: 1, label: 'Altro')],
                onChanged: (_) {},
              ),
              ItInput(
                label: 'Specificare altro',
                controller: TextEditingController(text: 'test'),
              ),
            ],
          ),
        ),
      ),
    );
  });
}
