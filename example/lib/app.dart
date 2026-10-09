import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/home_page.dart';

/// The Bootstrap Italia Flutter catalog/showcase app.
class BootstrapItaliaCatalog extends StatelessWidget {
  /// Creates a [BootstrapItaliaCatalog].
  const BootstrapItaliaCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = BootstrapItaliaThemeData.standard();

    return BootstrapItaliaTheme(
      data: theme,
      child: MaterialApp(
        title: 'Bootstrap Italia Flutter',
        debugShowCheckedModeBanner: false,
        theme: theme.toThemeData(),
        // The delegate is optional — every component renders in Italian without
        // it. It is wired here because the catalogue is also the
        // worked example of how an application installs the package, and a PA
        // in Bolzano or Aosta has to be able to see the shape.
        //
        // This is the whole of it: declare the locales, install the delegates,
        // and the device's language setting does the rest. Nothing here reads
        // the platform locale by hand.
        //
        // `flutter_localizations` is what makes the SECOND line honest.
        // Declaring `supportedLocales: [it, de, fr]` promises that every
        // delegate can serve those locales, and Material cannot on its own — it
        // warns at runtime that `it` is unsupported. Adding a locale is two
        // changes, not one, which is exactly the trap this now demonstrates
        // instead of side-stepping.
        // English is added by THIS APP, not by the package: `en` is absent from
        // `ItLocalizations.supportedLocales` and never auto-resolves, because
        // `MaterialApp` defaults to `en-US` and bundling it would switch every
        // unconfigured Italian app to English names. Offered here so a reviewer
        // or screen-reader tester who does not read Italian can use the
        // catalogue — the "having decided to" case.
        //
        // Opting in is TWO things, and the hook alone is not enough: without
        // `en` declared here, `MaterialApp` resolves an English device to the
        // first supported locale (`it`) and `resolve` is never called with
        // `en` at all. Declare the locale, then supply the strings.
        supportedLocales: const [
          ...ItLocalizations.supportedLocales,
          Locale('en'),
        ],
        localizationsDelegates: const [
          ItLocalizationsDelegate(resolve: _english),
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: const HomePage(),
      ),
    );
  }
}

/// Serves [ItLocalizations.english] to an English device, and lets every other
/// locale fall through to the package's own table.
///
/// Returning `null` is what keeps `it`, `de` and `fr` — and the Italian
/// fallback for anything unbundled — exactly as they were.
ItLocalizations? _english(Locale locale) =>
    locale.languageCode == 'en' ? ItLocalizations.english : null;
