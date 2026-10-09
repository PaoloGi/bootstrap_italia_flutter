// The catalogue is the worked example of installing the package, so what it
// demonstrates has to be true. This pins the part that is easy to believe and
// easy to get wrong: the device's language setting drives the strings, and
// nothing in the app reads the platform locale by hand.
//
// It also pins the boundary. `en` is NOT in `supportedLocales` and never
// auto-resolves — it is served through the delegate's opt-in hook, which is the
// same distinction `it_localizations.dart` draws and the reason an unconfigured
// Italian app cannot end up speaking English.
import 'package:bootstrap_italia_example/app.dart';
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boots the catalogue with [locales] as the device's language preference and
/// returns the strings it resolves to.
Future<ItLocalizations> _bootWith(
  WidgetTester tester,
  List<Locale> locales,
) async {
  tester.platformDispatcher.localesTestValue = locales;
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(const BootstrapItaliaCatalog());
  await tester.pump();

  return ItLocalizations.of(tester.element(find.byType(Scaffold).first));
}

void main() {
  group('the device language chooses the strings', () {
    testWidgets('Italian', (tester) async {
      final l = await _bootWith(tester, const [Locale('it', 'IT')]);
      expect(l.localeName, 'it');
      expect(l.remove, 'Rimuovi');
    });

    testWidgets('German — Alto Adige', (tester) async {
      final l = await _bootWith(tester, const [Locale('de', 'IT')]);
      expect(l.localeName, 'de',
          reason: 'a device in Bolzano set to German must get German, and the '
              'region subtag must not defeat the match');
      expect(l.radioUnselected, 'Nicht ausgewählt');
    });

    testWidgets('French — Valle d\'Aosta', (tester) async {
      final l = await _bootWith(tester, const [Locale('fr', 'IT')]);
      expect(l.localeName, 'fr');
      expect(l.radioUnselected, 'Non sélectionné');
    });

    testWidgets('an unbundled language falls back to Italian', (tester) async {
      // Slovene is statutory in parts of Friuli and is not bundled. The
      // fallback must be Italian, not the first entry of some other list.
      final l = await _bootWith(tester, const [Locale('sl')]);
      expect(l.localeName, 'it');
    });
  });

  group('English is opt-in, not automatic', () {
    testWidgets('an English device gets English here, because this app asked',
        (tester) async {
      final l = await _bootWith(tester, const [Locale('en', 'GB')]);
      expect(l.localeName, 'en');
      expect(l.radioUnselected, 'Not selected');
    });

    test('but the package still never resolves English by itself', () {
      expect(ItLocalizations.forLocale(const Locale('en')).localeName, 'it');
      expect(ItLocalizations.supportedLocales.map((l) => l.languageCode),
          isNot(contains('en')));
    });
  });
}
