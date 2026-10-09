// The screenshots in README.md and on pub.dev, rendered by the package itself.
//
// Not parity captures: those are tight crops of one component against a
// reference, with placeholder content ("Link lista 1") and no context. These
// are scenes — a form a citizen would meet, the mobile navigation panel, an
// autocomplete with its list open — which is what a reader of the README is
// trying to see.
//
// Every scene is rendered at a phone's logical width, because that is where
// this package is used: a 390pt viewport, the 16pt gutter Bootstrap Italia's
// `.container` has below `sm`, and the components in the arrangement a phone
// forces on them — block buttons, a full-width form, navigation in a panel
// rather than a bar.
//
// Regenerate with:
//   flutter test tool/screenshots/readme_shots_test.dart
//
// The boundary wraps the whole app rather than the widget, because two of
// these paint into the Overlay: ItAutocomplete's suggestion list is an
// OverlayEntry, so a boundary around the field alone captures a closed field
// and nothing else. The cost is that the scene owns its own padding.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _outDir = 'screenshots';

/// iPhone 14 / Pixel 7 class logical width. Bootstrap Italia's `.container`
/// is edge-to-edge below `sm`, with a 16pt gutter either side.
const double _phoneWidth = 390;
const double _gutter = 16;

/// Renders [child] and writes the whole surface, Overlay included.
Future<void> captureScene(
  WidgetTester tester, {
  required Widget child,
  required String name,
  Size size = const Size(_phoneWidth, 400),
  double pixelRatio = 2.0,
  Future<void> Function(WidgetTester tester)? after,
  // A scene holding a spinner never settles: `ItSpinner` and a loading
  // `ItButton` run an unbounded animation, and `pumpAndSettle` waits for the
  // frame after the last one, which never comes. Those scenes pump a fixed
  // number of frames and catch the spinner wherever it happens to be.
  bool settle = true,
  // Navigation and the mobile panel are full-bleed: they paint their own
  // chrome to the screen edge, so the scene's gutter would be a white margin
  // around something that has none.
  EdgeInsets padding = const EdgeInsets.all(_gutter),
}) async {
  final theme = BootstrapItaliaThemeData.standard();
  final key = GlobalKey();

  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  tester.view.physicalSize = size * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: BootstrapItaliaTheme(
        data: theme,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme.toThemeData(),
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: padding,
              child: Align(alignment: Alignment.topLeft, child: child),
            ),
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }
  if (after != null) await after(tester);

  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_outDir/$name.png');
    await file.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

/// The icon font, loaded the way the parity captures load it: from the pub
/// cache, because a test binary has no asset bundle for another package's
/// fonts and every glyph would render as a tofu box.
Future<void> _loadIconFont() async {
  final home = Platform.environment['HOME'];
  final path = '$home/.pub-cache/hosted/pub.dev/bootstrap_italia_icons-0.0.3'
      '/fonts/BootstrapItaliaIcons.ttf';
  final file = File(path);
  if (!file.existsSync()) return;
  final bytes = await file.readAsBytes();
  for (final family in [
    'BootstrapItaliaIcons',
    'packages/bootstrap_italia_icons/BootstrapItaliaIcons',
  ]) {
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
    await loader.load();
  }
}

void main() {
  setUpAll(_loadIconFont);

  // Block buttons, because that is what a phone gets: `.btn-block` is the
  // arrangement a 390pt viewport forces, with the inline pair below it for
  // the cases that fit.
  testWidgets('shot: buttons', (tester) async {
    await captureScene(
      tester,
      name: 'buttons',
      size: const Size(_phoneWidth, 272),
      settle: false, // the loading button spins
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ItButton(
            block: true,
            onPressed: () {},
            child: const Text('Invia richiesta'),
          ),
          const SizedBox(height: 12),
          ItButton(
            block: true,
            outline: true,
            icon: BootstrapItaliaIcons.it_download,
            onPressed: () {},
            child: const Text('Scarica il certificato'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ItButton(
                variant: ItButtonVariant.secondary,
                size: ItButtonSize.small,
                onPressed: () {},
                child: const Text('Dettagli'),
              ),
              const SizedBox(width: 12),
              const ItButton(
                size: ItButtonSize.small,
                disabled: true,
                child: Text('Non disponibile'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ItButton(
            block: true,
            loading: true,
            onPressed: () {},
            child: const Text('Invio in corso'),
          ),
        ],
      ),
    );
  });

  testWidgets('shot: form', (tester) async {
    await captureScene(
      tester,
      name: 'form',
      size: const Size(_phoneWidth, 436),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A filled field's label floats 33px above it, into whatever sits
          // overhead — here the top of the shot, which clipped it. The kit
          // exposes the exact amount for this reason.
          const SizedBox(height: ItFormSpacing.floatingLabelHeadroom),
          ItInput(
            label: 'Nome e cognome',
            controller: TextEditingController(text: 'Maria Rossi'),
          ),
          ItSelect<String>(
            label: 'Tipo di certificato',
            value: 'residenza',
            items: const [
              ItSelectItem(
                  value: 'residenza', label: 'Certificato di residenza'),
              ItSelectItem(value: 'nascita', label: 'Certificato di nascita'),
            ],
            onChanged: (_) {},
          ),
          ItInput(
            label: 'Indirizzo email',
            errorText: 'Inserire un indirizzo valido',
            controller: TextEditingController(text: 'maria.rossi@'),
          ),
          ItCheckbox(
            label: 'Acconsento al trattamento dei dati',
            value: true,
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          ItToggle(
            label: 'Ricevi aggiornamenti',
            value: true,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  });

  testWidgets('shot: autocomplete', (tester) async {
    const comuni = ['Ancona', 'Ancarano', 'Ancona Marittima', 'Ancignano'];
    await captureScene(
      tester,
      name: 'autocomplete',
      size: const Size(_phoneWidth, 224),
      child: ItAutocomplete<String>(
        label: 'Comune di residenza',
        icon: BootstrapItaliaIcons.it_search,
        displayStringForOption: (s) => s,
        onSearch: (q) async => comuni
            .where((c) => c.toLowerCase().startsWith(q.toLowerCase()))
            .toList(),
      ),
      after: (tester) async {
        await tester.enterText(find.byType(EditableText), 'Anc');
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
      },
    );
  });

  // The megamenu as a phone shows it: the burger opens the panel, each
  // section expanding in place. Driven through the public widget and the
  // route it pushes, so the shot is what a caller actually gets.
  testWidgets('shot: megamenu', (tester) async {
    await captureScene(
      tester,
      name: 'megamenu',
      size: const Size(_phoneWidth, 440),
      padding: EdgeInsets.zero,
      child: const ItMegamenu(
        sections: [
          ItMegamenuSection(
            label: 'Servizi',
            columns: [
              ItMegamenuColumn(
                links: [
                  ItMegamenuLink(label: 'Certificati anagrafici'),
                  ItMegamenuLink(label: 'Carta d\'identità elettronica'),
                  ItMegamenuLink(label: 'Cambio di residenza'),
                ],
              ),
            ],
          ),
          ItMegamenuSection(
            label: 'Tributi',
            columns: [
              ItMegamenuColumn(
                links: [
                  ItMegamenuLink(label: 'IMU e TASI'),
                  ItMegamenuLink(label: 'Pagamenti pagoPA'),
                ],
              ),
            ],
          ),
          ItMegamenuSection(
            label: 'Protezione civile',
            columns: [
              ItMegamenuColumn(
                links: [
                  ItMegamenuLink(label: 'Allerte meteo'),
                  ItMegamenuLink(label: 'Piano di emergenza'),
                ],
              ),
            ],
          ),
        ],
      ),
      after: (tester) async {
        await tester.tap(find.byIcon(BootstrapItaliaIcons.it_burger));
        await tester.pumpAndSettle();
        // Open the first section, so the shot shows the links rather than
        // three collapsed tiles. `.last`: the bar behind the panel still
        // carries its own 'Servizi' label.
        await tester.tap(find.text('Servizi').last);
        await tester.pumpAndSettle();
      },
    );
  });

  // Top and bottom chrome together, which is the shape of a phone screen:
  // the centre header above, the tab bar below.
  testWidgets('shot: navigation', (tester) async {
    await captureScene(
      tester,
      name: 'navigation',
      size: const Size(_phoneWidth, 420),
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: _phoneWidth,
        height: 420,
        child: Column(
          children: [
            const ItCenterHeader(
              // A placeholder name on purpose: a screenshot captioned with a
              // real comune reads as that comune using the package, which no
              // municipality has agreed to.
              title: 'Comune di Test',
              subtitle: 'Servizi al cittadino',
              showSearch: true,
            ),
            const Padding(
              padding: EdgeInsets.all(_gutter),
              child: ItBreadcrumb(
                items: [
                  ItBreadcrumbItem(label: 'Home'),
                  ItBreadcrumbItem(label: 'Servizi'),
                  ItBreadcrumbItem(label: 'Anagrafe'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: ItCard(
                category: const ItCardCategory(label: 'Anagrafe'),
                title: 'Certificato di residenza',
                body: const Text(
                    'Richiedilo online con SPID o CIE. Pronto in due giorni.'),
                date: '12 ottobre 2026',
                onTap: () {},
              ),
            ),
            const Spacer(),
            ItBottomNav(
              selectedIndex: 1,
              onSelected: (_) {},
              items: const [
                ItBottomNavItem(
                    label: 'Home', icon: BootstrapItaliaIcons.it_pa),
                ItBottomNavItem(
                    label: 'Servizi', icon: BootstrapItaliaIcons.it_list),
                ItBottomNavItem(
                    label: 'Messaggi',
                    icon: BootstrapItaliaIcons.it_mail,
                    badge: 3),
                ItBottomNavItem(
                    label: 'Profilo', icon: BootstrapItaliaIcons.it_user),
              ],
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('shot: feedback', (tester) async {
    await captureScene(
      tester,
      name: 'feedback',
      size: const Size(_phoneWidth, 430),
      settle: false, // ItSpinner spins
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ItAlert(
            variant: ItAlertVariant.success,
            title: 'Richiesta inviata',
            body: Text('Il certificato sarà pronto entro due giorni.'),
          ),
          const SizedBox(height: 16),
          const ItCallout(
            variant: ItCalloutVariant.warning,
            title: 'Documenti necessari',
            body: Text('Serve un documento di identità in corso di validità.'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const ItBadge(
                  variant: ItBadgeVariant.success, child: Text('Completato')),
              const ItBadge(
                  variant: ItBadgeVariant.danger, child: Text('Scaduto')),
              ItChip(
                label: 'Protezione civile',
                dismissible: true,
                onDismiss: () {},
              ),
              const ItSpinner(),
            ],
          ),
        ],
      ),
    );
  });
}
