import 'package:flutter/widgets.dart';

import '../tokens/breakpoints.dart';
import '../tokens/typography.dart';
import 'bootstrap_italia_theme.dart';
import 'bootstrap_italia_theme_data.dart';

/// Convenience extensions on [BuildContext] for accessing Bootstrap Italia
/// theme data, breakpoints, and responsive helpers.
extension BootstrapItaliaContext on BuildContext {
  /// The nearest [BootstrapItaliaThemeData] from the widget tree.
  ///
  /// Throws if no [BootstrapItaliaTheme] ancestor exists.
  BootstrapItaliaThemeData get bootstrapItaliaTheme =>
      BootstrapItaliaTheme.of(this);

  /// The colour scheme from the nearest Bootstrap Italia theme.
  ///
  /// Delegates to [resolveColorScheme] rather than reading the theme directly.
  /// The two used to differ on the case that matters: this getter threw when
  /// there was no [BootstrapItaliaTheme] ancestor, while the function every
  /// component actually calls falls back to the standard scheme. So a component
  /// rendered outside the theme worked, and a consumer's identical-looking call
  /// crashed. One concept, one behaviour.
  BootstrapItaliaColorScheme get itColors => resolveColorScheme(this);

  /// Responsive typography for the current screen width.
  BootstrapItaliaTypography get itTypography =>
      BootstrapItaliaTheme.typographyOf(this);

  /// The current breakpoint based on screen width.
  ItBreakpoint get breakpoint => BootstrapItaliaTheme.breakpointOf(this);

  /// Whether the current screen is mobile-sized (xs or sm).
  bool get isMobile {
    final bp = breakpoint;
    return bp == ItBreakpoint.xs || bp == ItBreakpoint.sm;
  }

  /// Whether the current screen is tablet-sized (md).
  bool get isTablet => breakpoint == ItBreakpoint.md;

  /// Whether the current screen is desktop-sized (lg, xl, or xxl).
  bool get isDesktop {
    final bp = breakpoint;
    return bp == ItBreakpoint.lg ||
        bp == ItBreakpoint.xl ||
        bp == ItBreakpoint.xxl;
  }
}

/// Resolves the [BootstrapItaliaColorScheme] from the widget tree.
///
/// Returns the theme colors if a [BootstrapItaliaTheme] ancestor exists,
/// otherwise falls back to [BootstrapItaliaColorScheme.standard].
///
/// This allows all components to be theme-aware while remaining functional
/// without an explicit theme wrapper (backward compatibility).
BootstrapItaliaColorScheme resolveColorScheme(BuildContext context) {
  return BootstrapItaliaTheme.maybeOf(context)?.colors ??
      BootstrapItaliaColorScheme.standard;
}
