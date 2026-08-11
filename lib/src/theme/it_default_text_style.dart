import 'package:flutter/widgets.dart';

import '../tokens/typography.dart';
import 'theme_extensions.dart';

/// Installs Bootstrap Italia's ambient body text style.
///
/// Material used to supply one for free: `Material` wraps its child in an
/// `AnimatedDefaultTextStyle` carrying `ThemeData.textTheme.bodyMedium`, which
/// `toThemeData()` builds from [BootstrapItaliaTypography.desktop] — TitilliumWeb
/// 18/28 at `letterSpacing: 0` in `--bs-body-color`.
///
/// Removing Material (doc/adr/0001) removes that, and what is left underneath is
/// [DefaultTextStyle.fallback]: **no font family at all**, so every glyph falls
/// back to the platform font, and no `height`, so every line box changes size.
/// Measured on the megamenu's mobile overlay, a 16px label went from
/// `111.3 x 25.0` to `256.0 x 16.0`. That is both traps from the ADR at once —
/// the missing-glyph boxes and the silently-supplied `line-height`.
///
/// It bites specifically where a component renders **outside the host app's
/// `Scaffold`**: overlay entries and pushed routes sit above it, so they have no
/// other `Material` to inherit from. Those roots state the style here instead,
/// which also makes them correct in an app that has no `Scaffold` at all.
///
/// [DefaultTextStyle.merge], never the plain constructor: per the ADR a bare
/// `DefaultTextStyle` *replaces* the ambient style, and inheriting the
/// alignment and overflow settings around it is the behaviour Material had.
class ItDefaultTextStyle extends StatelessWidget {
  /// The subtree that inherits the style.
  final Widget child;

  /// Wraps [child] in Bootstrap Italia's body text style.
  const ItDefaultTextStyle({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      // The desktop variant, not the responsive `typographyOf(context)`:
      // `toThemeData()` hardcodes `BootstrapItaliaTypography.desktop` for the
      // Material text theme, so this is what the removed Material actually
      // supplied. Switching to the responsive one here would be a separate
      // change of behaviour, not a faithful replacement.
      style: BootstrapItaliaTypography.desktop.bodyText.copyWith(
        // `_withoutLetterSpacing` zeroes the tracking Material's defaults would
        // otherwise merge in; the same reasoning applies verbatim here.
        letterSpacing: 0,
        color: resolveColorScheme(context).bodyColor,
      ),
      child: child,
    );
  }
}
