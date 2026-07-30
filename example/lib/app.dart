import 'package:bootstrap_italia/bootstrap_italia.dart';
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
        home: const HomePage(),
      ),
    );
  }
}
