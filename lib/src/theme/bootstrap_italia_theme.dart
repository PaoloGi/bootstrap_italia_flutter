import 'package:flutter/widgets.dart';

import '../tokens/breakpoints.dart';
import '../tokens/typography.dart';
import 'bootstrap_italia_theme_data.dart';

/// Provides [BootstrapItaliaThemeData] to descendant widgets.
///
/// Wrap your app (or a subtree) with this widget to make the Bootstrap Italia
/// theme available via [BootstrapItaliaTheme.of(context)].
///
/// ```dart
/// BootstrapItaliaTheme(
///   data: BootstrapItaliaThemeData.standard(),
///   child: MaterialApp(
///     theme: BootstrapItaliaThemeData.standard().toThemeData(),
///     home: MyApp(),
///   ),
/// )
/// ```
class BootstrapItaliaTheme extends InheritedWidget {
  /// The theme data provided to descendants.
  final BootstrapItaliaThemeData data;

  /// Creates a Bootstrap Italia theme provider.
  const BootstrapItaliaTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Returns the nearest [BootstrapItaliaThemeData] from the widget tree.
  ///
  /// Throws if no [BootstrapItaliaTheme] ancestor is found.
  static BootstrapItaliaThemeData of(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<BootstrapItaliaTheme>();
    assert(
      theme != null,
      'No BootstrapItaliaTheme found in the widget tree. '
      'Wrap your app with BootstrapItaliaTheme.',
    );
    return theme!.data;
  }

  /// Returns the nearest [BootstrapItaliaThemeData], or null if not found.
  static BootstrapItaliaThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BootstrapItaliaTheme>()
        ?.data;
  }

  /// Returns the responsive [BootstrapItaliaTypography] for the current
  /// screen width.
  static BootstrapItaliaTypography typographyOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return BootstrapItaliaTypography.responsive(width);
  }

  /// Returns the current [ItBreakpoint] based on screen width.
  static ItBreakpoint breakpointOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return ItBreakpoint.fromWidth(width);
  }

  @override
  bool updateShouldNotify(BootstrapItaliaTheme oldWidget) {
    return data != oldWidget.data;
  }
}
