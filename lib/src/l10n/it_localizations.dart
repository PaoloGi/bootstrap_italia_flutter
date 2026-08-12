import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The strings this package puts in front of a user on the application's
/// behalf.
///
/// Nearly all of them are **accessible names**: the text a screen reader
/// announces in place of "button" for a control that paints only a glyph. That
/// makes them a conformance surface, not a cosmetic one. WCAG 4.1.2 Name, Role,
/// Value requires the name to exist; §3.1.2 Language of Parts requires it to be
/// in the language of the page it is spoken on. For Italian public
/// administration both are legally binding — Legge 9 gennaio 2004 n. 4 (Legge
/// Stanca), Directive (EU) 2016/2102 and UNI CEI EN 301 549 v3.2.1, which
/// adopts WCAG AA by reference.
///
/// Two autonomous regions raise the stakes past "nice to have":
///
/// - **Alto Adige / Südtirol** — D.P.R. 670/1972 art. 99 parifies German to
///   Italian, and D.P.R. 574/1988 governs its use in dealings with the
///   administration.
/// - **Valle d'Aosta / Vallée d'Aoste** — Legge costituzionale 4/1948 art. 38
///   parifies French to Italian.
///
/// A PA in Bolzano publishing a German-language service whose close button
/// announces "Chiudi finestra modale" is not merely untidy; it is a service
/// that fails in the language the citizen is entitled to be served in.
///
/// ## Installing
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: const [
///     ItLocalizations.delegate,
///     ...GlobalMaterialLocalizations.delegates,
///   ],
///   supportedLocales: ItLocalizations.supportedLocales,
///   home: ...,
/// )
/// ```
///
/// **The delegate is optional.** With none installed every component still
/// renders, in Italian — see [of]. Nothing in this package requires a
/// `Localizations` ancestor, in keeping with the rest of the kit: components
/// work outside a `MaterialApp` and outside a `Scaffold`.
///
/// ## Overriding one string
///
/// The bundled translations are a starting point, not a house style. An
/// administration that says *"Torna all'inizio"* can change that one string
/// without restating the other twenty-four:
///
/// ```dart
/// ItLocalizationsDelegate(
///   resolve: (locale) => switch (locale.languageCode) {
///     'it' => ItLocalizations.italian.copyWith(backToTop: "Torna all'inizio"),
///     _ => null, // null = use the bundled translation
///   },
/// )
/// ```
///
/// The same hook adds a locale this package does not bundle: return a fully
/// populated [ItLocalizations] for it. Every field is `required`, so a new
/// locale cannot silently inherit an Italian string it forgot to translate.
@immutable
class ItLocalizations {
  /// Creates a complete set of strings for one locale.
  ///
  /// Every field is required on purpose. An optional parameter defaulting to
  /// the Italian text would mean a half-translated locale compiles and ships,
  /// which is exactly the "80% localisable" failure this class exists to
  /// prevent — and in an accessible name it is invisible until a screen-reader
  /// user hits it.
  const ItLocalizations({
    required this.localeName,
    required this.backToTop,
    required this.close,
    required this.remove,
    required this.removeItem,
    required this.closeModal,
    required this.dismissModalBarrier,
    required this.dialog,
    required this.closeNotification,
    required this.openMenu,
    required this.closeMenu,
    required this.navigationMenu,
    required this.breadcrumb,
    required this.search,
    required this.searchPlaceholder,
    required this.loading,
    required this.searching,
    required this.suggestions,
    required this.noResults,
    required this.searchResultsOne,
    required this.searchResultsOther,
    required this.notificationCountOne,
    required this.notificationCountOther,
    required this.showPassword,
    required this.hidePassword,
    required this.followUs,
  });

  /// The BCP 47 language subtag these strings are written in, e.g. `'it'`.
  ///
  /// Carried so an application can tell which translation it actually got —
  /// [of] falls back to Italian for any locale this package does not bundle,
  /// and without this that fallback is silent.
  final String localeName;

  // ── Controls that paint a glyph and nothing else ──────────────────
  //
  // Each of these is the *only* thing AT has to announce for its control.
  // Missing or wrong, the control is announced as a bare "button" (WCAG 4.1.2).

  /// [ItBackToTop]'s name. Italian: `'Torna su'`.
  final String backToTop;

  /// The dismiss control on [ItAlert]. Italian: `'Chiudi'`.
  final String close;

  /// The dismiss control on [ItChip] — it removes the chip rather than closing
  /// a surface, so it is a different word from [close]. Italian: `'Rimuovi'`.
  final String remove;

  /// [ItChip]'s dismiss control, naming what it removes.
  ///
  /// A template with `{label}`, not a concatenation: German puts the verb last
  /// (`"Lazio entfernen"`) and joining two strings in code would hard-code
  /// Italian word order into every other language.
  ///
  /// Why it is not simply [remove]: a filter bar with five chips gives five
  /// buttons all called "Rimuovi", which are indistinguishable in a screen
  /// reader's element list — a user picking between them is guessing. Named
  /// after its chip, each one says what it does.
  final String removeItem;

  /// The close button in [ItModal]'s header. Italian:
  /// `'Chiudi finestra modale'`.
  final String closeModal;

  /// The modal's barrier, which dismisses the dialog when tapped.
  ///
  /// Deliberately distinct from [closeModal]: the barrier and the header button
  /// are two nodes in the same dialog, and giving them one name leaves a
  /// screen-reader user with two identically-named targets and no way to tell
  /// them apart. The Italian is `'Ignora'`, matching
  /// `MaterialLocalizations.modalBarrierDismissLabel` — this is the string
  /// Italian Flutter users already hear on every other dialog.
  final String dismissModalBarrier;

  /// [ItModal]'s route name when the caller gives no `title`. Italian:
  /// `'Finestra di dialogo'`, matching `MaterialLocalizations.dialogLabel`.
  final String dialog;

  /// The dismiss control on [ItNotification]. Italian: `'Chiudi notifica'`.
  final String closeNotification;

  /// The burger toggle in [ItNavHeader] and [ItMegamenu]. Italian:
  /// `'Apri menu'`.
  final String openMenu;

  /// The same toggle once open, and the megamenu overlay's barrier. Italian:
  /// `'Chiudi menu'`.
  ///
  /// One string, three call sites. They used to be two phrasings — `'Chiudi
  /// menu'` in the headers and `'Chiudi il menu'` in the mobile megamenu — so
  /// the same action was announced two ways depending on which component drew
  /// it. Consolidated here, which is a thing a table of strings makes visible
  /// and a scatter of literals does not.
  final String closeMenu;

  /// The `navigation` landmark wrapping the mobile megamenu panel. Italian:
  /// `'Menu di navigazione'`.
  final String navigationMenu;

  /// The `navigation` landmark wrapping [ItBreadcrumb].
  ///
  /// `'Breadcrumb'` in every bundled locale, including Italian. That is not an
  /// oversight: Bootstrap Italia's own markup is `<nav aria-label="breadcrumb">`
  /// and Bootstrap 5's is the same, so the source design system spells this
  /// landmark with the English word in an Italian page. Translating it here
  /// would make this port diverge from the system it ports, on a string whose
  /// PA-standard wording in German and French could not be verified. Override
  /// it if your administration's style guide says otherwise.
  final String breadcrumb;

  // ── Search and suggestion surfaces ────────────────────────────────

  /// The search affordance in [ItCenterHeader] — both the visible label and the
  /// button's accessible name, which is why they cannot drift apart. Italian:
  /// `'Cerca'`.
  final String search;

  /// Placeholder in [ItSelect]'s filter field. Italian: `'Cerca...'`.
  final String searchPlaceholder;

  /// [ItSpinner]'s name. A spinner is a painted figure with no text, so this is
  /// the whole of what AT has. Italian: `'Caricamento in corso'`.
  final String loading;

  /// The in-field spinner in [ItAutocomplete], which reports a query in flight
  /// rather than a page loading. Italian: `'Ricerca in corso'`.
  final String searching;

  /// The container holding [ItAutocomplete]'s suggestion list. Italian:
  /// `'Suggerimenti'`.
  final String suggestions;

  /// Shown, and announced, when a search returns nothing. Italian:
  /// `'Nessun risultato'`.
  ///
  /// Serves both [ItAutocomplete]'s visible empty state and the zero case of
  /// [searchResults]; they were two identical literals before.
  final String noResults;

  /// The live-region announcement for exactly one result. Italian:
  /// `'1 risultato disponibile'`.
  final String searchResultsOne;

  /// The live-region announcement for any other count, with `{count}`
  /// substituted. Italian: `'{count} risultati disponibili'`.
  final String searchResultsOther;

  /// [ItNotificationBadge]'s name for a count of one, with `{count}`
  /// substituted. Italian: `'{count} notifica'`.
  final String notificationCountOne;

  /// [ItNotificationBadge]'s name for any other count. Italian:
  /// `'{count} notifiche'`.
  final String notificationCountOther;

  // ── Form and chrome ──────────────────────────────────────────────

  /// [ItInput]'s password reveal toggle. Italian: `'Mostra la password'`.
  final String showPassword;

  /// The same toggle once revealed. Italian: `'Nascondi la password'`.
  final String hidePassword;

  /// The label preceding the social icons in [ItCenterHeader] and [ItFooter].
  /// Italian: `'Seguici su'`.
  final String followUs;

  /// The announcement for a search that returned [count] results.
  ///
  /// WCAG 4.1.3 Status Messages: the suggestion list appears without moving
  /// focus, so its arrival has to be spoken. Plural selection is by [count]
  /// rather than by string formatting because German and French inflect the
  /// noun — `1 Ergebnis` / `2 Ergebnisse` — and a single `'$count risultati'`
  /// template says "1 risultati" in Italian too.
  String searchResults(int count) => switch (count) {
        0 => noResults,
        1 => searchResultsOne,
        _ => searchResultsOther.replaceAll('{count}', '$count'),
      };

  /// [ItNotificationBadge]'s accessible name.
  ///
  /// [count] is the true value and picks the plural form. [displayed] is the
  /// count as *painted*, which [ItNotificationBadge] caps at its `max` — the
  /// badge announces "99+" because a sighted user standing next to a screen
  /// reader has to hear the number they can see. The two differ only above the
  /// cap, where the plural form is "other" either way.
  String notificationCount(int count, String displayed) =>
      (count == 1 ? notificationCountOne : notificationCountOther)
          .replaceAll('{count}', displayed);

  /// [ItChip]'s dismiss name for the chip called [label].
  String removeNamed(String label) => removeItem.replaceAll('{label}', label);

  /// The strings for [locale], or [italian] when it is not one this package
  /// bundles.
  ///
  /// Matched on the language subtag alone. `de_AT`, `de_CH` and the German of
  /// Bolzano get the same strings; none of the differences between them reach
  /// a word in this table.
  static ItLocalizations forLocale(Locale locale) =>
      _bundled[locale.languageCode] ?? italian;

  /// The locales this package ships translations for.
  ///
  /// Pass to `MaterialApp.supportedLocales` — the delegate itself supports
  /// every locale (falling back to Italian), so it will not narrow the app's
  /// resolution for you.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('it'),
    Locale('de'),
    Locale('fr'),
  ];

  static const Map<String, ItLocalizations> _bundled =
      <String, ItLocalizations>{
    'it': italian,
    'de': german,
    'fr': french,
  };

  /// The strings in use for [context].
  ///
  /// Resolution order:
  ///
  /// 1. An [ItLocalizations] published by a delegate on an ancestor
  ///    `Localizations`.
  /// 2. Otherwise [italian].
  ///
  /// **Never null and never throws.** `MaterialLocalizations.of` *asserts* when
  /// no ancestor provides it, which is why `ItModal.show` used to throw rather
  /// than merely look wrong outside a `MaterialApp` (see
  /// `test/no_ambient_material_test.dart`). This lookup degrades instead.
  ///
  /// Note what step 2 does **not** do: it does not read
  /// `Localizations.localeOf` and resolve from that. That looks like a free
  /// improvement and is a trap — `MaterialApp.supportedLocales` defaults to
  /// `[Locale('en', 'US')]`, so an Italian app that has not configured
  /// localisation at all reports an *English* ambient locale. Resolving from it
  /// would hand an Italian PA English accessible names for the single commonest
  /// misconfiguration there is. Italian is the default because a missing
  /// delegate must mean Italian, not English.
  static ItLocalizations of(BuildContext context) =>
      Localizations.of<ItLocalizations>(context, ItLocalizations) ?? italian;

  /// The delegate that serves the bundled translations.
  ///
  /// Construct [ItLocalizationsDelegate] directly to override wording or add a
  /// locale.
  static const LocalizationsDelegate<ItLocalizations> delegate =
      ItLocalizationsDelegate();

  /// A copy of these strings with the given fields replaced.
  ///
  /// The intended way to restyle one or two strings: the base translation
  /// stays authoritative for everything else, so a later version of this
  /// package adding a string does not leave the application with a gap.
  ItLocalizations copyWith({
    String? localeName,
    String? backToTop,
    String? close,
    String? remove,
    String? removeItem,
    String? closeModal,
    String? dismissModalBarrier,
    String? dialog,
    String? closeNotification,
    String? openMenu,
    String? closeMenu,
    String? navigationMenu,
    String? breadcrumb,
    String? search,
    String? searchPlaceholder,
    String? loading,
    String? searching,
    String? suggestions,
    String? noResults,
    String? searchResultsOne,
    String? searchResultsOther,
    String? notificationCountOne,
    String? notificationCountOther,
    String? showPassword,
    String? hidePassword,
    String? followUs,
  }) =>
      ItLocalizations(
        localeName: localeName ?? this.localeName,
        backToTop: backToTop ?? this.backToTop,
        close: close ?? this.close,
        remove: remove ?? this.remove,
        removeItem: removeItem ?? this.removeItem,
        closeModal: closeModal ?? this.closeModal,
        dismissModalBarrier: dismissModalBarrier ?? this.dismissModalBarrier,
        dialog: dialog ?? this.dialog,
        closeNotification: closeNotification ?? this.closeNotification,
        openMenu: openMenu ?? this.openMenu,
        closeMenu: closeMenu ?? this.closeMenu,
        navigationMenu: navigationMenu ?? this.navigationMenu,
        breadcrumb: breadcrumb ?? this.breadcrumb,
        search: search ?? this.search,
        searchPlaceholder: searchPlaceholder ?? this.searchPlaceholder,
        loading: loading ?? this.loading,
        searching: searching ?? this.searching,
        suggestions: suggestions ?? this.suggestions,
        noResults: noResults ?? this.noResults,
        searchResultsOne: searchResultsOne ?? this.searchResultsOne,
        searchResultsOther: searchResultsOther ?? this.searchResultsOther,
        notificationCountOne: notificationCountOne ?? this.notificationCountOne,
        notificationCountOther:
            notificationCountOther ?? this.notificationCountOther,
        showPassword: showPassword ?? this.showPassword,
        hidePassword: hidePassword ?? this.hidePassword,
        followUs: followUs ?? this.followUs,
      );

  // ── Bundled translations ─────────────────────────────────────────
  //
  // Where a string has an equivalent in `flutter_localizations`' own
  // professionally-translated ARB files, that wording is used verbatim and the
  // key is cited. Two reasons: it is reviewed translation rather than this
  // author's, and it is what a German or French user already hears from every
  // other Flutter dialog, so the kit does not introduce a second vocabulary for
  // the same action.
  //
  // English is deliberately NOT bundled. It would be the easiest locale to add
  // and the most dangerous: `MaterialApp.supportedLocales` defaults to
  // `[Locale('en', 'US')]`, so shipping `en` would make an unconfigured Italian
  // app resolve to English accessible names. Applications that want English can
  // supply it through `ItLocalizationsDelegate.resolve` in a few lines, having
  // decided to.

  /// Italian — the package default, and the fallback for every locale not
  /// bundled here.
  static const ItLocalizations italian = ItLocalizations(
    localeName: 'it',
    backToTop: 'Torna su',
    // `MaterialLocalizations.closeButtonLabel` (material_it.arb).
    close: 'Chiudi',
    remove: 'Rimuovi',
    removeItem: 'Rimuovi {label}',
    closeModal: 'Chiudi finestra modale',
    // `modalBarrierDismissLabel` (material_it.arb).
    dismissModalBarrier: 'Ignora',
    // `dialogLabel` (material_it.arb).
    dialog: 'Finestra di dialogo',
    closeNotification: 'Chiudi notifica',
    openMenu: 'Apri menu',
    closeMenu: 'Chiudi menu',
    navigationMenu: 'Menu di navigazione',
    breadcrumb: 'Breadcrumb',
    // `searchFieldLabel` (material_it.arb).
    search: 'Cerca',
    searchPlaceholder: 'Cerca...',
    loading: 'Caricamento in corso',
    searching: 'Ricerca in corso',
    suggestions: 'Suggerimenti',
    noResults: 'Nessun risultato',
    searchResultsOne: '1 risultato disponibile',
    searchResultsOther: '{count} risultati disponibili',
    // The singular is new. The badge said `'$count notifiche'` for every value,
    // so a badge of one announced "1 notifiche".
    notificationCountOne: '{count} notifica',
    notificationCountOther: '{count} notifiche',
    showPassword: 'Mostra la password',
    hidePassword: 'Nascondi la password',
    followUs: 'Seguici su',
  );

  /// German — statutory in Alto Adige / Südtirol (D.P.R. 670/1972 art. 99).
  static const ItLocalizations german = ItLocalizations(
    localeName: 'de',
    backToTop: 'Nach oben',
    // `closeButtonLabel` (material_de.arb).
    close: 'Schließen',
    // Not `Löschen`: the chip is removed from a list, not deleted from a store.
    remove: 'Entfernen',
    removeItem: '{label} entfernen',
    // `dialogLabel` is `Dialogfeld`; the verb is the same one Flutter uses for
    // `closeButtonLabel`.
    closeModal: 'Dialogfeld schließen',
    // `modalBarrierDismissLabel` (material_de.arb).
    dismissModalBarrier: 'Schließen',
    // `dialogLabel` (material_de.arb).
    dialog: 'Dialogfeld',
    closeNotification: 'Benachrichtigung schließen',
    openMenu: 'Menü öffnen',
    closeMenu: 'Menü schließen',
    navigationMenu: 'Navigationsmenü',
    // Untranslated by design — see [breadcrumb].
    breadcrumb: 'Breadcrumb',
    // `searchFieldLabel` (material_de.arb).
    search: 'Suchen',
    searchPlaceholder: 'Suchen...',
    loading: 'Wird geladen',
    searching: 'Suche läuft',
    suggestions: 'Vorschläge',
    noResults: 'Keine Ergebnisse',
    searchResultsOne: '1 Ergebnis verfügbar',
    searchResultsOther: '{count} Ergebnisse verfügbar',
    notificationCountOne: '{count} Benachrichtigung',
    notificationCountOther: '{count} Benachrichtigungen',
    // The `anzeigen`/`ausblenden` pair Flutter uses for
    // `showAccountsLabel`/`hideAccountsLabel` (material_de.arb).
    showPassword: 'Passwort anzeigen',
    hidePassword: 'Passwort ausblenden',
    // Formal address (Sie), which is the register Südtirol's administration
    // uses with citizens.
    followUs: 'Folgen Sie uns auf',
  );

  /// French — statutory in Valle d'Aosta / Vallée d'Aoste
  /// (Legge costituzionale 4/1948 art. 38).
  static const ItLocalizations french = ItLocalizations(
    localeName: 'fr',
    backToTop: 'Retour en haut',
    // `closeButtonLabel` (material_fr.arb).
    close: 'Fermer',
    // Not `Effacer` (clear) — the chip leaves the list.
    remove: 'Supprimer',
    removeItem: 'Supprimer {label}',
    closeModal: 'Fermer la boîte de dialogue',
    // `modalBarrierDismissLabel` (material_fr.arb).
    dismissModalBarrier: 'Ignorer',
    // `dialogLabel` (material_fr.arb).
    dialog: 'Boîte de dialogue',
    closeNotification: 'Fermer la notification',
    openMenu: 'Ouvrir le menu',
    closeMenu: 'Fermer le menu',
    navigationMenu: 'Menu de navigation',
    // Untranslated by design — see [breadcrumb].
    breadcrumb: 'Breadcrumb',
    // `searchFieldLabel` (material_fr.arb).
    search: 'Rechercher',
    searchPlaceholder: 'Rechercher...',
    loading: 'Chargement en cours',
    searching: 'Recherche en cours',
    suggestions: 'Suggestions',
    noResults: 'Aucun résultat',
    searchResultsOne: '1 résultat disponible',
    searchResultsOther: '{count} résultats disponibles',
    notificationCountOne: '{count} notification',
    notificationCountOther: '{count} notifications',
    // The `Afficher`/`Masquer` pair Flutter uses for
    // `showAccountsLabel`/`hideAccountsLabel` (material_fr.arb).
    showPassword: 'Afficher le mot de passe',
    hidePassword: 'Masquer le mot de passe',
    followUs: 'Suivez-nous sur',
  );

  @override
  String toString() => 'ItLocalizations($localeName)';
}

/// Publishes [ItLocalizations] to a subtree.
///
/// Add [ItLocalizations.delegate] to `MaterialApp.localizationsDelegates` for
/// the bundled translations, or construct this directly with [resolve] to
/// change wording or add a locale.
class ItLocalizationsDelegate extends LocalizationsDelegate<ItLocalizations> {
  /// Creates a delegate serving the bundled translations, optionally filtered
  /// through [resolve].
  const ItLocalizationsDelegate({this.resolve});

  /// Supplies the strings for a locale, or returns null to accept the bundled
  /// translation.
  ///
  /// Called once per locale change, not per build. Returning a value for a
  /// locale [ItLocalizations.forLocale] does not know is how an application
  /// adds Slovenian, Ladin, Friulian or Sardinian without waiting on this
  /// package — every field is required, so the result cannot be a partial
  /// translation wearing an Italian remainder.
  final ItLocalizations? Function(Locale locale)? resolve;

  /// Always true.
  ///
  /// This delegate can serve any locale, because [ItLocalizations.forLocale]
  /// falls back to Italian. Returning false for unbundled locales would make
  /// the package drop out entirely and hand the components back the situation
  /// this class exists to fix. It does not narrow `MaterialApp`'s locale
  /// resolution either — that is driven by `supportedLocales`, which the
  /// application still owns.
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<ItLocalizations> load(Locale locale) =>
      SynchronousFuture<ItLocalizations>(
        resolve?.call(locale) ?? ItLocalizations.forLocale(locale),
      );

  @override
  bool shouldReload(ItLocalizationsDelegate old) => false;

  @override
  String toString() => 'ItLocalizations.delegate';
}
