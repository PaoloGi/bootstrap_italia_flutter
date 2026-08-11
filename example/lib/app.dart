import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

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
        // it (ADR 0002). It is wired here because the catalogue is also the
        // worked example of how an application installs the package, and
        // because a PA in Bolzano or Aosta has to be able to see the shape.
        //
        // `supportedLocales` is deliberately NOT widened to it/de/fr: this app
        // ships no `flutter_localizations`, so declaring German would leave
        // Material's own strings unresolved. Adding a locale is two changes,
        // not one, and the catalogue shows the honest version.
        localizationsDelegates: const [ItLocalizations.delegate],
        home: const HomePage(),
      ),
    );
  }
}
