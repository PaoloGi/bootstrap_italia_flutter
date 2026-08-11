// Standing guard: ADR 0002 — one delegate, per-widget overrides on top.
//
// Nearly every string in `ItLocalizations` is an accessible name: what a screen
// reader says instead of "button". So the failure modes here are silent by
// construction — nothing renders differently, nothing throws, and the defect is
// audible only to the users least able to work around it. Three of them matter:
//
//   1. A string goes back to being a literal, so a locale cannot reach it.
//      Guarded by `every localised string is reachable`, which drives the real
//      components under a German delegate.
//   2. A component throws, or announces the wrong thing, with no localisations
//      ancestor. That is not hypothetical: `ItModal.show` called
//      `MaterialLocalizations.of`, which ASSERTS, so the modal did not merely
//      look wrong outside a MaterialApp — it threw. Guarded here and in
//      test/no_ambient_material_test.dart.
//   3. A translation is added by copying the Italian, or drops the `{count}`
//      placeholder so the badge announces "notifiche" with no number. The
//      compiler cannot see either; `bundled translations` reads the source and
//      can.
import 'dart:io';

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoLocalizations, DefaultCupertinoLocalizations;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';

/// Serves Flutter's built-in English Material strings for *any* locale.
///
/// `flutter_localizations` is deliberately not a dependency of this package,
/// not even a dev one — `ItLocalizations` is 25 const strings and needs no
/// `intl`. But `TextField` asserts `debugCheckHasMaterialLocalizations`, and
/// `MaterialApp` reports an error when its locale has no Material delegate, so
/// a test that pumps a German app has to supply *something*. What it says does
/// not matter: every assertion below is about a string this package owns.
class _AnyLocaleMaterial extends LocalizationsDelegate<MaterialLocalizations> {
  const _AnyLocaleMaterial();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
          const DefaultMaterialLocalizations());
  @override
  bool shouldReload(_AnyLocaleMaterial old) => false;
}

/// As [_AnyLocaleMaterial]; `MaterialApp` checks for both.
class _AnyLocaleCupertino
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _AnyLocaleCupertino();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
          const DefaultCupertinoLocalizations());
  @override
  bool shouldReload(_AnyLocaleCupertino old) => false;
}

/// A host with an [ItLocalizations] delegate and an explicit locale.
Widget _localised(Widget child, {required Locale locale}) =>
    BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        locale: locale,
        localizationsDelegates: const [
          ItLocalizations.delegate,
          _AnyLocaleMaterial(),
          _AnyLocaleCupertino(),
        ],
        // Deliberately wide: `ItLocalizationsDelegate.isSupported` is always
        // true, so the app's own resolution decides the locale and this test
        // is asserting what the delegate does with it.
        supportedLocales: const [Locale('it'), Locale('de'), Locale('fr')],
        home: Scaffold(body: Center(child: child)),
      ),
    );

/// A host with NO `Localizations` at all — the situation this package promises
/// to survive, since it claims to need neither MaterialApp nor Scaffold.
Widget _bare(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: widgets.Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(1280, 800)),
          child: widgets.Overlay(
            initialEntries: [
              widgets.OverlayEntry(
                builder: (_) =>
                    Align(alignment: Alignment.topLeft, child: child),
              ),
            ],
          ),
        ),
      ),
    );

void main() {
  group('resolution never throws and never returns null', () {
    testWidgets('no Localizations ancestor at all resolves to Italian',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_bare(Builder(builder: (context) {
        ctx = context;
        return const SizedBox.shrink();
      })));

      expect(ItLocalizations.of(ctx).localeName, 'it');
      expect(ItLocalizations.of(ctx).closeModal, 'Chiudi finestra modale');
    });

    testWidgets('a MaterialApp with no delegate resolves to Italian, not '
        'English', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        // The default. `MaterialApp.supportedLocales` is `[Locale('en','US')]`
        // unless the app says otherwise, so an Italian PA that has not
        // configured localisation at all reports an ENGLISH ambient locale.
        // Resolving from `Localizations.localeOf` would therefore hand it
        // English accessible names for the commonest misconfiguration there is.
        // ADR 0002 rejects that fallback on exactly this evidence.
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox.shrink();
        }),
      ));

      expect(Localizations.localeOf(ctx).languageCode, 'en',
          reason: 'if this stops being true the test below proves nothing');
      expect(ItLocalizations.of(ctx).localeName, 'it');
    });

    testWidgets('an unbundled locale falls back to Italian', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('sl'), // Slovenian: statutory in Friuli, unbundled
        localizationsDelegates: const [
          ItLocalizations.delegate,
          _AnyLocaleMaterial(),
          _AnyLocaleCupertino(),
        ],
        supportedLocales: const [Locale('sl')],
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox.shrink();
        }),
      ));

      expect(ItLocalizations.of(ctx).localeName, 'it');
    });

    testWidgets('ItModal.show does not throw with no localisations ancestor',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_bare(widgets.Navigator(
        onGenerateRoute: (_) => widgets.PageRouteBuilder(
          pageBuilder: (context, __, ___) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
      )));

      ItModal.show<void>(
          context: ctx, title: 'Conferma', body: const Text('Corpo'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'MaterialLocalizations.of asserted here before ADR 0002 '
              'moved these two strings onto ItLocalizations');
      // Italian, from the fallback — not the delegate, because there is none.
      expect(find.bySemanticsLabel('Chiudi finestra modale'), findsOneWidget);
    });
  });

  group('every localised string is reachable', () {
    // Drives the real components under a German delegate. A string that goes
    // back to a literal fails here and nowhere else — `flutter analyze` is
    // perfectly happy with a hardcoded accessible name.
    const de = ItLocalizations.german;

    /// Pumps [child] in German and asserts each of [labels] is announced.
    ///
    /// Matches as a *substring*: some components fold their controls into one
    /// semantics node, so `ItAlert`'s dismiss button is announced inside
    /// `"Korpus\nSchließen"` rather than on a node of its own. What is under
    /// test here is that the German string reaches the tree at all; which node
    /// carries it is the a11y contracts' business (test/a11y/).
    Future<void> announces(
      WidgetTester tester,
      Widget child,
      List<String> labels,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_localised(child, locale: const Locale('de')));
      // `pump`, not `pumpAndSettle`: ItSpinner animates forever, so settling
      // never returns for it.
      await tester.pump(const Duration(milliseconds: 400));
      for (final label in labels) {
        expect(find.bySemanticsLabel(RegExp(RegExp.escape(label))),
            findsWidgets,
            reason: label);
      }
      handle.dispose();
    }

    testWidgets('ItBackToTopButton', (tester) async {
      await announces(
          tester, ItBackToTopButton(onPressed: () {}), [de.backToTop]);
    });

    testWidgets('ItAlert dismiss', (tester) async {
      await announces(
        tester,
        SizedBox(
          width: 600,
          child: ItAlert(
            dismissible: true,
            onDismissed: () {},
            body: const Text('Korpus'),
          ),
        ),
        [de.close],
      );
    });

    testWidgets('ItChip dismiss', (tester) async {
      await announces(
        tester,
        ItChip(dismissible: true, onDismiss: () {}, label: 'Etikett'),
        [de.remove],
      );
    });

    testWidgets('ItSpinner', (tester) async {
      await announces(tester, const ItSpinner(), [de.loading]);
    });

    testWidgets('ItBreadcrumb landmark', (tester) async {
      await announces(
        tester,
        ItBreadcrumb(items: [
          ItBreadcrumbItem(label: 'Start', onTap: () {}),
          const ItBreadcrumbItem(label: 'Dienste'),
        ]),
        [de.breadcrumb],
      );
    });

    testWidgets('the notification badge substitutes {count}', (tester) async {
      // Plural selection, not interpolation into one template.
      await announces(
        tester,
        const ItNotificationBadge(count: 3, child: Text('Post')),
        ['3 Benachrichtigungen'],
      );
    });

    testWidgets('the notification badge picks the singular', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        const ItNotificationBadge(count: 1, child: Text('Post')),
      ));

      expect(find.bySemanticsLabel('1 Benachrichtigung'), findsOneWidget,
          reason: 'German inflects the noun; so does Italian, which is why '
              'the old single template said "1 notifiche"');
      handle.dispose();
    });

    testWidgets('the notification badge announces the CAPPED count',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        const ItNotificationBadge(count: 250, max: 99, child: Text('Post')),
      ));

      expect(find.bySemanticsLabel('99+ Benachrichtigungen'), findsOneWidget,
          reason: 'the plural form comes from the true count, the NUMBER from '
              'the painted one — a screen-reader user and the person beside '
              'them must hear and see the same badge');
      handle.dispose();
    });

    testWidgets('the modal names its close button and its route',
        (tester) async {
      final handle = tester.ensureSemantics();
      late BuildContext ctx;
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        Builder(builder: (context) {
          ctx = context;
          return const SizedBox.shrink();
        }),
      ));

      // A `title` is what draws the header, and the header is what carries the
      // close button; the route name below therefore comes from the title, so
      // the generic `dialog` fallback is asserted separately.
      ItModal.show<void>(
          context: ctx, title: 'Bestätigen', body: const Text('Korpus'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(de.closeModal), findsOneWidget);
      // The barrier is a separate node and must NOT share the close button's
      // name, or AT offers two identical targets (WCAG 4.1.2).
      expect(find.bySemanticsLabel(de.dismissModalBarrier), findsOneWidget);
      expect(de.dismissModalBarrier, isNot(de.closeModal));
      handle.dispose();
    });

    testWidgets('an untitled modal falls back to the generic dialog name',
        (tester) async {
      final handle = tester.ensureSemantics();
      late BuildContext ctx;
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        Builder(builder: (context) {
          ctx = context;
          return const SizedBox.shrink();
        }),
      ));

      ItModal.show<void>(context: ctx, body: const Text('Korpus'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(de.dialog), findsOneWidget,
          reason: 'a route announced as unnamed tells a screen-reader user '
              'nothing about what they have entered (WCAG 4.1.2)');
      handle.dispose();
    });

    testWidgets('the notification names its close button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        const ItNotification(
          title: 'Titel',
          body: 'Nachricht',
          dismissible: true,
          duration: null,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(de.closeNotification), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the nav header names its burger in both states',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        const MediaQuery(
          // Below `md`, which is the breakpoint that draws the burger.
          data: MediaQueryData(size: Size(400, 800)),
          child: ItNavHeader(items: [ItNavItem(label: 'Startseite')]),
        ),
      ));

      expect(find.bySemanticsLabel(de.openMenu), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(de.openMenu));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(de.closeMenu), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the megamenu names its toggle and its mobile panel',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        const MediaQuery(
          data: MediaQueryData(size: Size(400, 800)),
          child: ItMegamenu(sections: [
            ItMegamenuSection(
              label: 'Verwaltung',
              columns: [
                ItMegamenuColumn(links: [ItMegamenuLink(label: 'Ämter')]),
              ],
            ),
          ]),
        ),
      ));

      expect(find.bySemanticsLabel(de.openMenu), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(de.openMenu));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(de.navigationMenu), findsOneWidget);
      // One key, not two phrasings: this used to be `'Chiudi il menu'` while
      // the headers said `'Chiudi menu'`.
      expect(find.bySemanticsLabel(de.closeMenu), findsWidgets);
      handle.dispose();
    });

    testWidgets('the center header names its search control', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        const ItCenterHeader(
          title: 'Autonome Provinz Bozen',
          showSearch: true,
          socialLinks: [
            ItSocialLink(icon: Icons.link, label: 'Facebook'),
          ],
        ),
      ));

      // The visible label and the button's name are the same string by
      // contract (WCAG 2.5.3 Label in Name), so one is excluded from AT and
      // the other is not — hence findsOneWidget, not findsNothing.
      expect(find.bySemanticsLabel(de.search), findsOneWidget);
      expect(find.text(de.search), findsOneWidget);
      expect(find.text(de.followUs), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the footer localises its socials label', (tester) async {
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        const SingleChildScrollView(
          child: ItFooter(
            institutionName: 'Gemeinde',
            socialLinks: [
              ItSocialLink(icon: Icons.link, label: 'Facebook'),
            ],
          ),
        ),
      ));

      expect(find.text(de.followUs.toUpperCase()), findsOneWidget);
    });

    testWidgets('the password toggle names both states', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        const ItInput(
          label: 'Passwort',
          obscureText: true,
          showPasswordToggle: true,
        ),
      ));

      expect(find.bySemanticsLabel(de.showPassword), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(de.showPassword));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(de.hidePassword), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the searchable select localises its filter placeholder',
        (tester) async {
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        const ItSelect<String>(
          label: 'Provinz',
          searchable: true,
          items: [ItSelectItem(value: 'bz', label: 'Bozen')],
        ),
      ));

      await tester.tap(find.byType(ItSelect<String>));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '`searchable: true` used to throw: its TextField sits in an '
              'OverlayEntry above the host Scaffold, so nothing satisfied '
              '`debugCheckHasMaterial`');
      expect(find.text(de.searchPlaceholder), findsOneWidget);
    });

    testWidgets('the autocomplete localises its empty state', (tester) async {
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        ItAutocomplete<String>(
          label: 'Gemeinde',
          onSearch: (_) async => const <String>[],
          displayStringForOption: (s) => s,
          debounce: Duration.zero,
        ),
      ));

      await tester.enterText(find.byType(EditableText), 'xyz');
      await tester.pumpAndSettle();
      expect(find.text(de.noResults), findsOneWidget);
    });
  });

  group('per-widget overrides win over the delegate', () {
    // ADR 0002 layers the two rather than choosing: the delegate carries the
    // wording, the parameter carries what only the call site knows.
    testWidgets('an explicit label beats the locale', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_localised(
        locale: const Locale('de'),
        const ItNotificationBadge(
          count: 3,
          semanticLabel: '3 ungelesene Nachrichten',
          child: Text('Posta'),
        ),
      ));

      expect(find.bySemanticsLabel('3 ungelesene Nachrichten'), findsOneWidget);
      expect(find.bySemanticsLabel('3 Benachrichtigungen'), findsNothing);
      handle.dispose();
    });

    testWidgets('a resolve hook can restyle one string without restating the '
        'rest', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: [
          ItLocalizationsDelegate(
            resolve: (locale) => locale.languageCode == 'it'
                ? ItLocalizations.italian
                    .copyWith(backToTop: "Torna all'inizio")
                : null,
          ),
          const _AnyLocaleMaterial(),
          const _AnyLocaleCupertino(),
        ],
        supportedLocales: const [Locale('it')],
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox.shrink();
        }),
      ));

      final l10n = ItLocalizations.of(ctx);
      expect(l10n.backToTop, "Torna all'inizio");
      expect(l10n.close, 'Chiudi', reason: 'copyWith must not blank the rest');
    });

    testWidgets('a resolve hook can add a locale this package does not bundle',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: [
          ItLocalizationsDelegate(
            resolve: (locale) => locale.languageCode == 'en'
                ? ItLocalizations.italian
                    .copyWith(localeName: 'en', backToTop: 'Back to top')
                : null,
          ),
          const _AnyLocaleMaterial(),
          const _AnyLocaleCupertino(),
        ],
        supportedLocales: const [Locale('en')],
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox.shrink();
        }),
      ));

      expect(ItLocalizations.of(ctx).backToTop, 'Back to top');
    });
  });

  group('bundled translations', () {
    // Reads the source rather than the objects, because Dart has no reflection
    // in a Flutter test and the interesting mistakes are textual: a field
    // copied from the Italian block, or a `{count}` dropped in translation.
    // The same technique guards the Material import rule in
    // test/import_hygiene_test.dart.
    final source =
        File('lib/src/l10n/it_localizations.dart').readAsStringSync();

    /// The `name: 'value'` pairs inside `static const ItLocalizations <name>`.
    ///
    /// Throws rather than `expect`s: this runs at collection time, where the
    /// test framework has no test to attach a failure to.
    Map<String, String> block(String name) {
      final start = source.indexOf('ItLocalizations $name = ItLocalizations(');
      if (start < 0) {
        throw StateError('no bundled translation named "$name"');
      }
      final end = source.indexOf('\n  );', start);
      final body = source.substring(start, end);
      return {
        for (final m in RegExp(r"^\s+(\w+): '(.*)',$", multiLine: true)
            .allMatches(body))
          m.group(1)!: m.group(2)!,
      };
    }

    /// The constructor's `required this.<field>` list — the authoritative set.
    final fields = RegExp(r'^\s+required this\.(\w+),$', multiLine: true)
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toList();

    final it = block('italian');
    final translations = {'german': block('german'), 'french': block('french')};

    test('the field list is non-trivial and fully populated in every locale',
        () {
      expect(fields.length, greaterThan(20),
          reason: 'the regex above stopped matching the constructor');
      for (final entry in {'italian': it, ...translations}.entries) {
        expect(entry.value.keys.toSet(), fields.toSet(),
            reason: '${entry.key} does not state every field');
      }
    });

    // Fields that are legitimately identical across locales. Anything else
    // matching the Italian is an untranslated string, which in an accessible
    // name is a defect a compiler cannot see.
    const sameByDesign = <String, String>{
      'breadcrumb': 'Bootstrap Italia itself emits '
          '`<nav aria-label="breadcrumb">` in an Italian page, so the source '
          'design system spells this landmark in English. Diverging here on a '
          'string whose PA-standard German and French wording could not be '
          'verified would be a guess in a legally-binding accessible name.',
      'suggestions': 'French for "Suggerimenti" is "Suggestions", which is '
          'also the English. Coincidence, not omission.',
    };

    for (final entry in translations.entries) {
      test('${entry.key} translates every string', () {
        final untranslated = <String>[];
        for (final field in fields) {
          if (field == 'localeName') continue;
          if (entry.value[field] != it[field]) continue;
          if (sameByDesign.containsKey(field)) continue;
          untranslated.add('  $field: "${it[field]}"');
        }
        expect(untranslated, isEmpty,
            reason: 'these ${entry.key} strings are still the Italian:\n'
                '${untranslated.join('\n')}\n\n'
                'A wrong-language accessible name is invisible to everyone '
                'except a screen-reader user. If a string is the same in both '
                'languages on purpose, say so in `sameByDesign` above.');
      });

      test('${entry.key} keeps every {count} placeholder', () {
        for (final field in fields) {
          if (!(it[field] ?? '').contains('{count}')) continue;
          expect(entry.value[field], contains('{count}'),
              reason: '${entry.key}.$field dropped {count}, so the badge or '
                  'the announcement would state a plural with no number');
        }
      });
    }

    test('supportedLocales matches the bundled set', () {
      expect(
        ItLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
        {'it', 'de', 'fr'},
      );
      for (final locale in ItLocalizations.supportedLocales) {
        expect(ItLocalizations.forLocale(locale).localeName,
            locale.languageCode);
      }
    });

    test('English is deliberately not bundled', () {
      // Not an omission. `MaterialApp.supportedLocales` defaults to
      // `[Locale('en','US')]`, so bundling English would make an unconfigured
      // Italian app resolve to English accessible names — the exact outcome
      // "Italian is the default" exists to prevent. Applications that want
      // English opt in through `ItLocalizationsDelegate.resolve`, having
      // decided to. Delete this test only alongside that reasoning.
      expect(ItLocalizations.forLocale(const Locale('en')).localeName, 'it');
    });

    test('regional variants resolve on the language subtag', () {
      // The German of Bolzano, Austria and Switzerland differ in ways that do
      // not reach a word in this table.
      for (final locale in [
        const Locale('de', 'IT'),
        const Locale('de', 'AT'),
        const Locale.fromSubtags(languageCode: 'de', scriptCode: 'Latn'),
      ]) {
        expect(ItLocalizations.forLocale(locale).localeName, 'de');
      }
    });
  });
}
