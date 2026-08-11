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

void main() {
  // `ItModal.show` was the one component this file could not have caught,
  // because it never rendered here: it called `MaterialLocalizations.of`, which
  // ASSERTS rather than returning null when no ancestor provides it. So the
  // modal did not merely look wrong outside a MaterialApp — it threw. The
  // package's own README says a Scaffold is not required.
  //
  // It no longer looks anything up from Material: ADR 0002 moved both strings
  // onto `ItLocalizations`, whose `of` cannot assert and cannot return null.
  // The cases below therefore assert the *outcome* — Italian, and no
  // exception — rather than which localisations class supplied it, so they
  // keep holding if the mechanism changes again.
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
      // The close button and the route name both come from ItLocalizations,
      // which has no delegate here. Italian is what a missing delegate means:
      // this is an Italian government design system, so the fallback is the
      // language of the country, not English (ADR 0002).
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

  // Every localised string has to survive the same conditions. Nothing here
  // has a `Localizations` ancestor of any kind, which is what a route-level
  // overlay or a non-MaterialApp host actually presents.
  group('localised names fall back to Italian with no Localizations', () {
    testWidgets('ItLocalizations.of never returns null and never asserts',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_bare(Builder(builder: (context) {
        ctx = context;
        return const SizedBox.shrink();
      })));

      expect(tester.takeException(), isNull);
      expect(ItLocalizations.of(ctx), same(ItLocalizations.italian));
    });

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
        _resolvedStyle(tester).fontFamily,
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
}
