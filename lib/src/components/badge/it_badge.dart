import 'package:flutter/widgets.dart';

import '../../l10n/it_localizations.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/typography.dart';

/// Color variants for [ItBadge].
enum ItBadgeVariant {
  /// Primary blue badge.
  primary,

  /// Secondary gray badge.
  secondary,

  /// Green success badge.
  success,

  /// Danger red badge.
  danger,

  /// Warning orange badge.
  warning,

  /// Info badge.
  info,

  /// Light badge.
  light,

  /// Dark badge.
  dark,
}

/// Maps [ItBadgeVariant] onto the shared semantic colour roles.
///
/// Exhaustive by construction — Dart requires every value to be handled, so
/// adding a variant here without giving it a colour will not compile. The
/// string-keyed lookup this replaced silently rendered such a variant as
/// primary.
extension ItBadgeVariantColor on ItBadgeVariant {
  /// The semantic colour role this variant paints with.
  ItVariantColor get variantColor => switch (this) {
        ItBadgeVariant.primary => ItVariantColor.primary,
        ItBadgeVariant.secondary => ItVariantColor.secondary,
        ItBadgeVariant.success => ItVariantColor.success,
        ItBadgeVariant.danger => ItVariantColor.danger,
        ItBadgeVariant.warning => ItVariantColor.warning,
        ItBadgeVariant.info => ItVariantColor.info,
        ItBadgeVariant.light => ItVariantColor.light,
        ItBadgeVariant.dark => ItVariantColor.dark,
      };
}

/// A Bootstrap Italia badge.
///
/// Displays a small count or label, typically used for status indicators
/// or notification counts.
///
/// ```dart
/// ItBadge(variant: ItBadgeVariant.primary, child: Text('Nuovo'))
/// ItBadge(variant: ItBadgeVariant.danger, pill: true, child: Text('3'))
/// ```
class ItBadge extends StatelessWidget {
  /// The badge color variant.
  final ItBadgeVariant variant;

  /// Whether to use the pill (rounded) shape.
  final bool pill;

  /// The badge content.
  final Widget child;

  /// Creates a Bootstrap Italia badge.
  const ItBadge({
    super.key,
    this.variant = ItBadgeVariant.primary,
    this.pill = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final bgColor = colors.forVariant(variant.variantColor);
    final fgColor = colors.foregroundForVariant(variant.variantColor);

    // Bootstrap Italia overrides the Bootstrap base: --bs-badge-font-size is
    // 0.875em (14px against the 16px body) and --bs-badge-font-weight is 600.
    // Padding is expressed in em relative to the badge's own font-size:
    // 0.25em/0.4em, and 0.6em horizontally for the pill variant.
    const fontSize = 14.0;
    const paddingY = 0.25 * fontSize;
    final paddingX = (pill ? 0.6 : 0.4) * fontSize;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingX, vertical: paddingY),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(
          pill
              ? BootstrapItaliaBorders.radiusPill
              : BootstrapItaliaBorders.radius,
        ),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: fgColor,
          // .badge sets line-height: 1. CSS splits the leading evenly above
          // and below the glyphs ("half-leading"); Flutter's default puts it
          // all above, which pushes the text visibly low in the badge.
          height: 1,
          leadingDistribution: TextLeadingDistribution.even,
          fontFamily: BootstrapItaliaFontFamily.sansSerif,
          package: BootstrapItaliaFontFamily.package,
        ),
        child: child,
      ),
    );
  }
}

/// A positioned notification badge that overlays on another widget.
///
/// ```dart
/// ItNotificationBadge(
///   count: 5,
///   child: ItIcon(BootstrapIcons.bell),
/// )
/// ```
class ItNotificationBadge extends StatelessWidget {
  /// The number to display. Hidden when 0.
  final int count;

  /// Maximum number before showing "99+". Defaults to 99.
  final int max;

  /// Badge color variant.
  final ItBadgeVariant variant;

  /// The widget to overlay the badge on.
  final Widget child;

  /// Accessible name for the count.
  ///
  /// Without one the badge announces a bare number — "5" — next to whatever it
  /// is overlaying, which tells a screen-reader user that something is five but
  /// not what (WCAG 4.1.2 Name, Role, Value). Defaults to
  /// `'<count> notifiche'`; pass this to say what is being counted, e.g.
  /// `'3 messaggi non letti'`.
  ///
  /// The default now follows the locale — see [ItLocalizations]. This parameter
  /// stays because it says something the localisations cannot: *what* the badge
  /// counts. That is per-call-site content, not per-locale wording, and it is
  /// the part that actually satisfies WCAG 4.1.2 here.
  final String? semanticLabel;

  /// Creates a notification badge.
  const ItNotificationBadge({
    super.key,
    required this.count,
    this.max = 99,
    this.variant = ItBadgeVariant.danger,
    this.semanticLabel,
    required this.child,
  });

  /// The count as shown, clipped to [max].
  String _displayCount() => count > max ? '$max+' : '$count';

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            // The announced count is the DISPLAYED one, cap included. It is
            // tempting to announce the true 250 instead — speech has no 24px
            // circle to fit — but then a screen-reader user and the person
            // next to them are looking at the same badge and reading different
            // numbers, with no way to tell which is authoritative. Naming what
            // is counted was the actual defect here; the cap is not a defect.
            // The count is pluralised rather than interpolated into one
            // template: the old `'$count notifiche'` announced "1 notifiche"
            // for a badge of one, and German and French inflect the noun.
            child: Semantics(
              label: semanticLabel ??
                  ItLocalizations.of(context)
                      .notificationCount(count, _displayCount()),
              child: ExcludeSemantics(
                child: ItBadge(
                  variant: variant,
                  pill: true,
                  child: Text(_displayCount()),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
