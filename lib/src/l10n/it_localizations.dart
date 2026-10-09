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
    required this.carousel,
    required this.previousSlide,
    required this.nextSlide,
    required this.goToSlide,
    required this.playCarousel,
    required this.pauseCarousel,
    required this.slideLabel,
    required this.closeModal,
    required this.closePanel,
    required this.dismissModalBarrier,
    required this.dialog,
    required this.closeNotification,
    required this.openMenu,
    required this.closeMenu,
    required this.mainNavigation,
    required this.navigationMenu,
    required this.breadcrumb,
    required this.search,
    required this.searchPlaceholder,
    required this.loading,
    required this.searching,
    required this.suggestions,
    required this.noResults,
    required this.chooseDate,
    required this.chooseTime,
    required this.confirmPick,
    required this.searchResultsOne,
    required this.searchResultsOther,
    required this.notificationCountOne,
    required this.notificationCountOther,
    required this.radioUnselected,
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

  /// The carousel's own accessible name. Italian: `'Carosello'`.
  ///
  /// All seven of these are `design-react-kit`'s own `i18n` block for the
  /// component, carried over verbatim rather than re-translated.
  final String carousel;

  /// Previous-slide control. Italian: `'Slide precedente'`.
  final String previousSlide;

  /// Next-slide control. Italian: `'Slide successiva'`.
  final String nextSlide;

  /// Pagination dot, with the slide number substituted for `%s`.
  /// Italian: `'Vai alla slide %s'`.
  final String goToSlide;

  /// Starts autoplay. Italian: `'Attiva autoplay'`.
  ///
  /// Autoplay is off by default here, as upstream. When it is on, a control
  /// carrying this name is **mandatory** rather than optional: moving content
  /// that runs for more than five seconds needs a pause (WCAG 2.2.2).
  final String playCarousel;

  /// Pauses autoplay. Italian: `'Pausa autoplay'`.
  final String pauseCarousel;

  /// A slide's position, `'%s di %s'` — index then total.
  final String slideLabel;

  /// The close button in [ItModal]'s header. Italian:
  /// `'Chiudi finestra modale'`.
  final String closeModal;

  /// The close button in [ItOffcanvas]'s header. Italian: `'Chiudi pannello'`.
  ///
  /// Separate from [closeModal] because the two are different places to be: a
  /// modal is a dialog that interrupts, a panel is a surface that slides over.
  /// Reusing the dialog wording would tell a screen-reader user they are
  /// leaving something they never entered.
  final String closePanel;

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

  /// Names the primary navigation landmark — [ItNavHeader]'s `<nav>`.
  ///
  /// Distinct from [navigationMenu] on purpose. Flutter asserts when a page
  /// carries more than one navigation landmark without unique labels, and a
  /// screen-reader user listing landmarks gets a row of identical entries.
  /// Italian: `'Navigazione principale'`.
  final String mainNavigation;

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

  /// Names [ItDateField]'s calendar button. Italian: `'Scegli la data'`.
  final String chooseDate;

  /// Names [ItDateField]'s clock button. Italian: `'Scegli l'ora'`.
  final String chooseTime;

  /// Confirms the wheel in the platform picker on iOS. Italian: `'Fatto'`.
  final String confirmPick;

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

  /// The hint on an **unselected** [ItRadio], on iOS and macOS only.
  ///
  /// Those platforms announce the *selected* option through
  /// `UIAccessibilityTraitSelected` and say nothing at all for the others, so
  /// without this a VoiceOver user cannot tell an unselected radio from one
  /// whose state was simply not announced. Android needs no such hint: it
  /// carries the checked state itself, and adding this there would say the same
  /// thing twice.
  ///
  /// Matches `WidgetsLocalizations.radioButtonUnselectedLabel`, which is what
  /// Flutter's own `RawRadio` uses. Italian: `'Non selezionato'`.
  final String radioUnselected;

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
    String? carousel,
    String? previousSlide,
    String? nextSlide,
    String? goToSlide,
    String? playCarousel,
    String? pauseCarousel,
    String? slideLabel,
    String? closeModal,
    String? closePanel,
    String? dismissModalBarrier,
    String? dialog,
    String? closeNotification,
    String? openMenu,
    String? closeMenu,
    String? mainNavigation,
    String? navigationMenu,
    String? breadcrumb,
    String? search,
    String? searchPlaceholder,
    String? loading,
    String? searching,
    String? suggestions,
    String? noResults,
    String? chooseDate,
    String? chooseTime,
    String? confirmPick,
    String? searchResultsOne,
    String? searchResultsOther,
    String? notificationCountOne,
    String? notificationCountOther,
    String? radioUnselected,
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
        carousel: carousel ?? this.carousel,
        previousSlide: previousSlide ?? this.previousSlide,
        nextSlide: nextSlide ?? this.nextSlide,
        goToSlide: goToSlide ?? this.goToSlide,
        playCarousel: playCarousel ?? this.playCarousel,
        pauseCarousel: pauseCarousel ?? this.pauseCarousel,
        slideLabel: slideLabel ?? this.slideLabel,
        closeModal: closeModal ?? this.closeModal,
        closePanel: closePanel ?? this.closePanel,
        dismissModalBarrier: dismissModalBarrier ?? this.dismissModalBarrier,
        dialog: dialog ?? this.dialog,
        closeNotification: closeNotification ?? this.closeNotification,
        openMenu: openMenu ?? this.openMenu,
        closeMenu: closeMenu ?? this.closeMenu,
        mainNavigation: mainNavigation ?? this.mainNavigation,
        navigationMenu: navigationMenu ?? this.navigationMenu,
        breadcrumb: breadcrumb ?? this.breadcrumb,
        search: search ?? this.search,
        searchPlaceholder: searchPlaceholder ?? this.searchPlaceholder,
        loading: loading ?? this.loading,
        searching: searching ?? this.searching,
        suggestions: suggestions ?? this.suggestions,
        noResults: noResults ?? this.noResults,
        chooseDate: chooseDate ?? this.chooseDate,
        chooseTime: chooseTime ?? this.chooseTime,
        confirmPick: confirmPick ?? this.confirmPick,
        searchResultsOne: searchResultsOne ?? this.searchResultsOne,
        searchResultsOther: searchResultsOther ?? this.searchResultsOther,
        notificationCountOne: notificationCountOne ?? this.notificationCountOne,
        notificationCountOther:
            notificationCountOther ?? this.notificationCountOther,
        radioUnselected: radioUnselected ?? this.radioUnselected,
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
  // English is provided but deliberately NOT auto-resolved — [english] exists,
  // and `'en'` is absent from [_bundled] and [supportedLocales] on purpose.
  //
  // Registering it would be the easiest change here and the most dangerous.
  // `MaterialApp.supportedLocales` defaults to `[Locale('en', 'US')]`, so an
  // application that installs the delegate and configures nothing else resolves
  // to `en` — today that falls through to Italian, which is right for the
  // audience this kit is for. Bundle `en` and the same app starts announcing
  // English accessible names to Italian users, silently, having asked for
  // nothing. Observed in this repo: with a device set to `de-DE` the example
  // catalogue still resolves `localeName: it`, precisely because `en` is not
  // bundled and de is not in ITS supportedLocales.
  //
  // So English is opt-in, in one line, by an application that has decided to:
  //
  // ```dart
  // ItLocalizationsDelegate(
  //   resolve: (l) => l.languageCode == 'en' ? ItLocalizations.english : null,
  // )
  // ```

  /// English — **not** auto-resolved. See the note above [italian]: `'en'` is
  /// absent from [supportedLocales] because `MaterialApp` defaults to it, and
  /// bundling it would switch an unconfigured Italian app to English names.
  ///
  /// Opt in through [ItLocalizationsDelegate.resolve]. Provided for
  /// English-language services, for reviewers who do not read Italian, and so
  /// that a screen-reader session can be run by someone who does not either.
  ///
  /// Wording follows `material_en.arb` / `widgets_en.arb` where an equivalent
  /// exists, for the same reason the other locales do.
  static const ItLocalizations english = ItLocalizations(
    localeName: 'en',
    backToTop: 'Back to top',
    // `MaterialLocalizations.closeButtonLabel` (material_en.arb).
    close: 'Close',
    remove: 'Remove',
    removeItem: 'Remove {label}',
    carousel: 'Carousel',
    previousSlide: 'Previous slide',
    nextSlide: 'Next slide',
    goToSlide: 'Go to slide %s',
    playCarousel: 'Start autoplay',
    pauseCarousel: 'Pause autoplay',
    slideLabel: '%s of %s',
    closeModal: 'Close dialog',
    closePanel: 'Close panel',
    // `modalBarrierDismissLabel` (material_en.arb).
    dismissModalBarrier: 'Dismiss',
    // `dialogLabel` (material_en.arb).
    dialog: 'Dialog',
    closeNotification: 'Close notification',
    openMenu: 'Open menu',
    closeMenu: 'Close menu',
    mainNavigation: 'Main navigation',
    navigationMenu: 'Navigation menu',
    breadcrumb: 'Breadcrumb',
    // `searchFieldLabel` (material_en.arb).
    search: 'Search',
    searchPlaceholder: 'Search...',
    loading: 'Loading',
    searching: 'Searching',
    suggestions: 'Suggestions',
    noResults: 'No results',
    chooseDate: 'Choose the date',
    chooseTime: 'Choose the time',
    confirmPick: 'Done',
    searchResultsOne: '1 result available',
    searchResultsOther: '{count} results available',
    notificationCountOne: '{count} notification',
    notificationCountOther: '{count} notifications',
    // `WidgetsLocalizations.radioButtonUnselectedLabel` (widgets_en.arb).
    radioUnselected: 'Not selected',
    showPassword: 'Show password',
    hidePassword: 'Hide password',
    followUs: 'Follow us on',
  );

  /// Italian — the package default, and the fallback for every locale not
  /// bundled here.
  static const ItLocalizations italian = ItLocalizations(
    localeName: 'it',
    backToTop: 'Torna su',
    // `MaterialLocalizations.closeButtonLabel` (material_it.arb).
    close: 'Chiudi',
    remove: 'Rimuovi',
    removeItem: 'Rimuovi {label}',
    carousel: 'Carosello',
    previousSlide: 'Slide precedente',
    nextSlide: 'Slide successiva',
    goToSlide: 'Vai alla slide %s',
    playCarousel: 'Attiva autoplay',
    pauseCarousel: 'Pausa autoplay',
    slideLabel: '%s di %s',
    closeModal: 'Chiudi finestra modale',
    closePanel: 'Chiudi pannello',
    // `modalBarrierDismissLabel` (material_it.arb).
    dismissModalBarrier: 'Ignora',
    // `dialogLabel` (material_it.arb).
    dialog: 'Finestra di dialogo',
    closeNotification: 'Chiudi notifica',
    openMenu: 'Apri menu',
    closeMenu: 'Chiudi menu',
    mainNavigation: 'Navigazione principale',
    navigationMenu: 'Menu di navigazione',
    breadcrumb: 'Breadcrumb',
    // `searchFieldLabel` (material_it.arb).
    search: 'Cerca',
    searchPlaceholder: 'Cerca...',
    loading: 'Caricamento in corso',
    searching: 'Ricerca in corso',
    suggestions: 'Suggerimenti',
    noResults: 'Nessun risultato',
    chooseDate: 'Scegli la data',
    chooseTime: 'Scegli l\'ora',
    confirmPick: 'Fatto',
    searchResultsOne: '1 risultato disponibile',
    searchResultsOther: '{count} risultati disponibili',
    // The singular is new. The badge said `'$count notifiche'` for every value,
    // so a badge of one announced "1 notifiche".
    notificationCountOne: '{count} notifica',
    notificationCountOther: '{count} notifiche',
    // `WidgetsLocalizations.radioButtonUnselectedLabel` (widgets_it.arb).
    radioUnselected: 'Non selezionato',
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
    carousel: 'Karussell',
    previousSlide: 'Vorherige Folie',
    nextSlide: 'Nächste Folie',
    goToSlide: 'Zu Folie %s wechseln',
    playCarousel: 'Automatische Wiedergabe starten',
    pauseCarousel: 'Automatische Wiedergabe pausieren',
    slideLabel: '%s von %s',
    closeModal: 'Dialogfeld schließen',
    closePanel: 'Bereich schließen',
    // `modalBarrierDismissLabel` (material_de.arb).
    dismissModalBarrier: 'Schließen',
    // `dialogLabel` (material_de.arb).
    dialog: 'Dialogfeld',
    closeNotification: 'Benachrichtigung schließen',
    openMenu: 'Menü öffnen',
    closeMenu: 'Menü schließen',
    mainNavigation: 'Hauptnavigation',
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
    chooseDate: 'Datum auswählen',
    chooseTime: 'Uhrzeit auswählen',
    confirmPick: 'Fertig',
    searchResultsOne: '1 Ergebnis verfügbar',
    searchResultsOther: '{count} Ergebnisse verfügbar',
    notificationCountOne: '{count} Benachrichtigung',
    notificationCountOther: '{count} Benachrichtigungen',
    // The `anzeigen`/`ausblenden` pair Flutter uses for
    // `showAccountsLabel`/`hideAccountsLabel` (material_de.arb).
    // widgets_de.arb.
    radioUnselected: 'Nicht ausgewählt',
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
    carousel: 'Carrousel',
    previousSlide: 'Diapositive précédente',
    nextSlide: 'Diapositive suivante',
    goToSlide: 'Aller à la diapositive %s',
    playCarousel: 'Activer la lecture automatique',
    pauseCarousel: 'Mettre en pause la lecture automatique',
    slideLabel: '%s sur %s',
    closeModal: 'Fermer la boîte de dialogue',
    closePanel: 'Fermer le panneau',
    // `modalBarrierDismissLabel` (material_fr.arb).
    dismissModalBarrier: 'Ignorer',
    // `dialogLabel` (material_fr.arb).
    dialog: 'Boîte de dialogue',
    closeNotification: 'Fermer la notification',
    openMenu: 'Ouvrir le menu',
    closeMenu: 'Fermer le menu',
    mainNavigation: 'Navigation principale',
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
    chooseDate: 'Choisir la date',
    chooseTime: 'Choisir l\'heure',
    confirmPick: 'Terminé',
    searchResultsOne: '1 résultat disponible',
    searchResultsOther: '{count} résultats disponibles',
    notificationCountOne: '{count} notification',
    notificationCountOther: '{count} notifications',
    // The `Afficher`/`Masquer` pair Flutter uses for
    // `showAccountsLabel`/`hideAccountsLabel` (material_fr.arb).
    // widgets_fr.arb.
    radioUnselected: 'Non sélectionné',
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
