// Guards a blind spot in the visual-parity harness.
//
// `captureWidget` wraps every capture in a `MaterialApp` + `Material`, so the
// parity numbers are computed with an ambient Material in the tree. That makes
// them structurally incapable of detecting a component that depends on Material
// for its text style — the harness supplies one, so the capture looks perfect
// while the same widget renders wrongly in a real overlay, dialog or route that
// has none.
//
// This was not hypothetical. Removing Material ancestors during the widgets-layer
// migration (doc/adr/0001) revealed that Material had been silently supplying the
// FONT FAMILY, not just the line height: a 16px label measured 111.3x25.0 with an
// ancestor and 256.0x16.0 without, because `DefaultTextStyle.fallback()` carries
// no `fontFamily` at all. Parity stayed at 71/72 throughout.
//
// So these tests deliberately render WITHOUT MaterialApp/Material. They are the
// only tests in the suite that do.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A host with NO Material anywhere — the situation a route-level overlay,
/// a custom dialog, or an app not built on MaterialApp actually presents.
Widget _bare(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(1280, 800)),
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );

/// The resolved style of the first [Text] under [finder].
TextStyle _resolvedStyle(WidgetTester tester) {
  final richText = tester.widget<RichText>(find.byType(RichText).first);
  return (richText.text as TextSpan).style!;
}

/// The resolved style of the [RichText] rendering [text].
///
/// `_resolvedStyle` takes whichever RichText paints first, which is fine while a
/// component's first painted glyph is a letter. It stops being fine the moment
/// one paints an icon first — an [Icon] is a RichText too, in the icon font, so
/// the assertion silently starts checking that the icon font is the icon font.
/// `ItAlert` now draws its variant glyph before the body, so it needs the
/// stricter finder.
TextStyle _resolvedStyleOf(WidgetTester tester, String text) {
  final richText = tester.widget<RichText>(
    find.descendant(of: find.text(text), matching: find.byType(RichText)),
  );
  return (richText.text as TextSpan).style!;
}

void main() {
  // `ItModal.show` was the one component this file could not have caught,
  // because it never rendered here: it called `MaterialLocalizations.of`, which
  // ASSERTS rather than returning null when no ancestor provides it. So the
  // modal did not merely look wrong outside a MaterialApp — it threw. The
  // package's own README says a Scaffold is not required.
  //
  // It now uses `Localizations.of<MaterialLocalizations>`, which returns null
  // instead of asserting, with an Italian fallback. The cases below assert the
  // *outcome* — Italian, and no exception — rather than which class supplied
  // it, so they keep holding if the mechanism changes.
  group('ItModal does not require MaterialApp', () {
    testWidgets('opens, names its route and closes with no Material ancestor',
        (tester) async {
      final handle = tester.ensureSemantics();
      late BuildContext ctx;

      await tester.pumpWidget(_bare(
        // A bare Navigator: enough to push a route, with no MaterialApp and so
        // no MaterialLocalizations.
        Navigator(
          onGenerateRoute: (settings) => PageRouteBuilder(
            pageBuilder: (context, _, __) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ));

      ItModal.show<void>(
        context: ctx,
        title: 'Conferma',
        body: const Text('Procedere?'),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'MaterialLocalizations.of asserted here before it was looked '
              'up nullably');
      expect(find.text('Procedere?'), findsOneWidget);
      // No Localizations ancestor of any kind here, so both names come from
      // the hardcoded Italian fallback — which for an Italian government
      // design system is the right default.
      expect(find.bySemanticsLabel('Chiudi finestra modale'), findsOneWidget);
      expect(find.bySemanticsLabel('Conferma'), findsWidgets,
          reason: 'the route is named after the title when there is one');
      handle.dispose();
    });

    testWidgets('an untitled modal still names its route, in Italian',
        (tester) async {
      final handle = tester.ensureSemantics();
      late BuildContext ctx;

      await tester.pumpWidget(_bare(
        Navigator(
          onGenerateRoute: (settings) => PageRouteBuilder(
            pageBuilder: (context, _, __) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ));

      ItModal.show<void>(context: ctx, body: const Text('Procedere?'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // `dialogLabel` in Flutter's own material_it.arb, so a screen-reader
      // user hears the same word here as in every other Italian dialog.
      expect(find.bySemanticsLabel('Finestra di dialogo'), findsOneWidget);
      handle.dispose();
    });
  });

  // Accessible names have to survive the same conditions. Nothing here has a
  // `Localizations` ancestor of any kind, which is what a route-level overlay
  // or a non-MaterialApp host actually presents.
  group('glyph-only controls are named with no Localizations', () {
    testWidgets('glyph-only controls are still named', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_bare(
        SizedBox(
          width: 600,
          child: ItChip(
            dismissible: true,
            onDismiss: () {},
            label: 'Etichetta',
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel(RegExp('Rimuovi')), findsWidgets);
      handle.dispose();
    });
  });

  group('components do not depend on an ambient Material for their font', () {
    testWidgets('ItDefaultTextStyle supplies the package font family',
        (tester) async {
      await tester.pumpWidget(_bare(
        const ItDefaultTextStyle(child: Text('Testo')),
      ));

      final style = _resolvedStyle(tester);
      expect(
        style.fontFamily,
        // Equality, not contains(): 'packages/bootstrap_italia/TitilliumWeb'
        // also *contains* 'TitilliumWeb', so a contains() check passed happily
        // while every bundled font was falling back to the platform default.
        'packages/${BootstrapItaliaFontFamily.package}/'
        '${BootstrapItaliaFontFamily.sansSerif}',
        reason: 'without this, DefaultTextStyle.fallback() applies and has NO '
            'fontFamily — text renders in the wrong face or as missing-glyph '
            'boxes, and the parity harness cannot see it because it supplies '
            'its own Material',
      );
      expect(style.letterSpacing, 0,
          reason: 'Bootstrap Italia body copy has no tracking');
    });

    testWidgets(
        'ItButton renders its label in the package font with no Material',
        (tester) async {
      await tester.pumpWidget(_bare(
        ItButton(onPressed: () {}, child: const Text('Conferma')),
      ));

      final style = _resolvedStyle(tester);
      expect(
        style.fontFamily,
        'packages/${BootstrapItaliaFontFamily.package}/'
        '${BootstrapItaliaFontFamily.sansSerif}',
      );
      expect(style.fontSize, 16);
    });

    testWidgets('ItAlert renders with no Material ancestor', (tester) async {
      await tester.pumpWidget(_bare(
        const SizedBox(
          width: 600,
          child: ItAlert(
            variant: ItAlertVariant.success,
            body: Text('Operazione completata'),
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(
        _resolvedStyleOf(tester, 'Operazione completata').fontFamily,
        'packages/${BootstrapItaliaFontFamily.package}/'
        '${BootstrapItaliaFontFamily.sansSerif}',
      );
    });

    testWidgets('ItBadge renders with no Material ancestor', (tester) async {
      await tester.pumpWidget(_bare(
        const ItBadge(child: Text('Nuovo')),
      ));

      expect(tester.takeException(), isNull);
      expect(
        _resolvedStyle(tester).fontFamily,
        'packages/${BootstrapItaliaFontFamily.package}/'
        '${BootstrapItaliaFontFamily.sansSerif}',
      );
    });

    testWidgets('ItChip renders with no Material ancestor', (tester) async {
      await tester.pumpWidget(_bare(
        const ItChip(label: 'Etichetta'),
      ));

      expect(tester.takeException(), isNull);
      expect(
        _resolvedStyle(tester).fontFamily,
        'packages/${BootstrapItaliaFontFamily.package}/'
        '${BootstrapItaliaFontFamily.sansSerif}',
      );
    });
  });

  // ── Every text-bearing component, rendered with no Material at all ────────
  //
  // The three hand-written cases above were the whole of this file's coverage
  // for a long time, and the bug they were written for — an ambient `Material`
  // silently supplying the font family — is not specific to them. It applies to
  // every component that draws a glyph, and the parity harness cannot see any
  // of it, because `captureWidget` wraps each capture in a `Material` of its
  // own. So the check is data-driven rather than hand-picked: adding a
  // component to the package means adding it here, and `a11y_coverage_test`
  // enforces the equivalent for contracts.
  group('every text-bearing component renders bare, in the package font', () {
    final cases = <String, Widget>{
      'ItAlert': const ItAlert(body: Text('Avviso')),
      'ItBadge': const ItBadge(child: Text('Nuovo')),
      'ItButton': ItButton(onPressed: () {}, child: const Text('Conferma')),
      'ItCallout': const ItCallout(title: 'Nota', body: Text('Testo')),
      'ItCard': const ItCard(title: 'Titolo', body: Text('Corpo')),
      'ItChip': const ItChip(label: 'Etichetta'),
      'ItAccordion': const ItAccordion(
        items: [ItAccordionItem(title: 'Sezione', body: Text('Corpo'))],
      ),
      'ItList': const ItList(items: [ItListItem(title: 'Voce')]),
      'ItBreadcrumb': const ItBreadcrumb(items: [
        ItBreadcrumbItem(label: 'Home'),
        ItBreadcrumbItem(label: 'Pagina'),
      ]),
      'ItTabBar': const ItTabBar(tabs: [ItTabItem(label: 'Uno')]),
      'ItNotification': const ItNotification(title: 'Titolo', body: 'Corpo'),
      'ItSkiplinks': const ItSkiplinks(
        hideUntilFocused: false,
        links: [ItSkiplink(label: 'Salta al contenuto')],
      ),
    };

    cases.forEach((name, widget) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(_bare(SizedBox(width: 600, child: widget)));

        expect(tester.takeException(), isNull,
            reason: '$name threw with no Material ancestor — which is what a '
                'route-level overlay, a custom dialog, or an app not built on '
                'MaterialApp actually presents');

        // `DefaultTextStyle.fallback()` carries NO fontFamily, so a component
        // that leans on an ambient Material renders in the platform font here
        // while looking perfect in the parity capture.
        //
        // Icons are `RichText` too, in the icon font — that is correct, not a
        // leak, so they are filtered out rather than asserted against.
        final prose = find.byType(RichText).evaluate().map((e) {
          return ((e.widget as RichText).text as TextSpan).style;
        }).where((style) =>
            !(style?.fontFamily ?? '').contains('BootstrapItaliaIcons'));

        expect(prose, isNotEmpty, reason: '$name should draw some prose');
        for (final style in prose) {
          expect(
            style?.fontFamily,
            startsWith('packages/${BootstrapItaliaFontFamily.package}/'),
            reason: '$name renders text in a font it did not choose. With no '
                'ambient Material there is nothing to fall back to, so this is '
                'the platform font — and the parity captures cannot see it, '
                'because they supply a Material of their own.',
          );
        }
      });
    });
  });
}
