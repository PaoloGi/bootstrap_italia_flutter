// The megamenu values Bootstrap Italia declares as SCSS variables.
//
// Its own file because these cross the split: `$megamenu-heading-text-size`
// sizes both the desktop panel's column headings and the mobile overlay's CTA
// labels, and Dart's library privacy leaves no way for two files to share a
// private constant. The alternatives were a duplicate per renderer, which
// drifts, or an import cycle through the component root, which would leak these
// into the package's public API — `it_megamenu.dart` is exported from the
// barrel and this file deliberately is not.
//
// Note that this is *not* every measurement the megamenu makes. The panel's
// numbers are taken off the compiled stylesheet at the `lg` breakpoint rather
// than from `_variables.scss`, and stay private to `it_megamenu_panel.dart`
// beside the only code that reads them.

import 'package:flutter/widgets.dart';

/// Design tokens from Bootstrap Italia SCSS: `_variables.scss` megamenu values.
abstract final class ItMegamenuTokens {
  /// Heading font size: `$megamenu-heading-text-size: 1.125rem`.
  static const double headingFontSize = 18.0;

  /// Heading bottom margin: `$megamenu-heading-bottom-margin: 24px`.
  static const double headingBottomMargin = 24.0;

  /// Link vertical padding: `$megamenu-linklist-link-v-padding: 0.5em`.
  static const double linkVerticalPadding = 8.0;

  /// Mobile expanded section background:
  /// `.megamenu .dropdown-menu .it-vertical { background: hsl(210, 62%, 97%) }`
  /// (`$color-background-primary-lighter`, also emitted as `.lightgrey-bg-a3`).
  ///
  /// Stays a literal despite the variable's name. It is not a tint of primary:
  /// a `lighten($primary, …)` would hold saturation at 100%, and a
  /// `tint-color()` would have compiled to a fractional `rgb()` the way the
  /// header's hover shade does — this one compiles to `hsl()`, i.e. a declared
  /// palette entry passed through untouched. No `--bs-*` custom property carries
  /// this value, so it matches no token at all.
  static const Color mobileExpandedBg = Color(0xFFF2F7FC);
}
