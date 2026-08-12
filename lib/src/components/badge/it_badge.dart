import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../l10n/it_localizations.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';

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

  /// Overrides the fill — the `.bg-*` utility rather than a `.badge-*` variant.
  ///
  /// «Accessibilità» builds its counter badge as
  /// `<span class="badge bg-white text-secondary">4</span>`: white on the blue
  /// button, not one of the semantic fills. `bg-white` is not a value of
  /// [ItBadgeVariant] and should not become one — it is a background utility
  /// that happens to be spelled like a variant.
  final Color? backgroundColor;

  /// Overrides the label colour — the `.text-*` utility.
  ///
  /// Note that `.text-secondary` is `hsl(210, 33%, 28%)` (#30475F), which is
  /// *not* `--bs-secondary` (`hsl(210, 17%, 44%)`). The two utilities disagree
  /// with the palette they are named after, so pass the colour you want rather
  /// than assuming the scheme's `secondary`.
  final Color? foregroundColor;

  /// Called when the badge is activated, making it a link.
  ///
  /// «Link» puts the contextual class on an `<a>`: `<a href="#" class="badge
  /// bg-primary">`. The hover state comes with it —
  /// `a.badge:hover.bg-primary { background-color: rgb(0, 81.6, 163.2) }`, the
  /// fill at 80% — and so does the role, which is why this announces as a link
  /// rather than a button.
  final VoidCallback? onTap;

  /// Text announced in place of, or in addition to, the badge's own content.
  ///
  /// «Accessibilità» is explicit about the problem: *«questi badge possono
  /// sembrare parole o numeri aggiuntivi casuali alla fine di una frase, un
  /// collegamento o un pulsante»*. Its remedy is a
  /// `<span class="visually-hidden">Messaggi non letti</span>` beside the
  /// number — text for screen readers that does not appear on screen. This is
  /// that span: pass `'9 messaggi non letti'` and the bare "9" stops being a
  /// stray digit.
  ///
  /// Naming what a badge counts is per-call-site content, not per-locale
  /// wording, so there is nothing for the localisations to supply — the same
  /// reasoning as [ItNotificationBadge.semanticLabel].
  final String? semanticLabel;

  /// The badge content.
  final Widget child;

  /// Creates a Bootstrap Italia badge.
  const ItBadge({
    super.key,
    this.variant = ItBadgeVariant.primary,
    this.pill = false,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
    this.semanticLabel,
    required this.child,
  });

  /// `--bs-body-font-size: 1rem`, the size an `em` resolves against when the
  /// badge sits directly on the page with nothing overriding it.
  static const double _rootFontSize = 16;

  @override
  Widget build(BuildContext context) {
    return ItHoverBuilder(
      enabled: onTap != null,
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      builder: _build,
    );
  }

  Widget _build(BuildContext context, bool hovered) {
    final colors = resolveColorScheme(context);
    var bgColor = backgroundColor ?? colors.forVariant(variant.variantColor);
    final fgColor =
        foregroundColor ?? colors.foregroundForVariant(variant.variantColor);

    // `a.badge:hover.bg-primary { background-color: rgb(0, 81.6, 163.2) }`,
    // `.bg-success { #064 }`, `.bg-secondary { hsl(210, 17%, 35.2%) }` — every
    // one of the twenty-odd rules is its fill at 80%. Italia compiles the shade
    // by scaling HSL lightness, which for these colours lands on the same bytes
    // as the linear RGB mix `itShade` performs (checked on secondary: both give
    // #4A5A69).
    if (hovered) bgColor = itShade(bgColor, 0.20);

    // `--bs-badge-font-size: 0.875em` — an **em**, so the badge takes its size
    // from whatever it is placed in, and «La grandezza di ogni badge si adatta
    // come dimensione a quella del font dell'elemento in cui è contenuto» is the
    // first thing the docs say about it. Hardcoding 14 made a badge in an `h1`
    // the same size as one in a caption, which is the whole point of the em.
    //
    // The fallback matters: outside any Material or ItDefaultTextStyle the
    // ambient style is `DefaultTextStyle.fallback()`, whose `fontSize` is null —
    // so `?? 16` stands in for the CSS root, not for Flutter's own 14px default.
    final inherited = DefaultTextStyle.of(context).style.fontSize;
    final fontSize = 0.875 * (inherited ?? _rootFontSize);
    // `--bs-badge-padding-y: 0.25em`, `--bs-badge-padding-x: 0.4em`, and
    // `.rounded-pill { padding-right: 0.6em; padding-left: 0.6em }` — all em
    // against the badge's own font size, so they scale with it.
    final paddingY = 0.25 * fontSize;
    final paddingX = (pill ? 0.6 : 0.4) * fontSize;

    final Widget box = Container(
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
          // `--bs-badge-font-weight: 600` (Italia's override of Bootstrap's
          // 700), and `a.badge:hover { color: #fff }` keeps the label white
          // through the darker hover fill — which is what `foregroundForVariant`
          // already returns for every fill except `light`.
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

    if (onTap == null) {
      // Plain content. A `semanticLabel` on a non-interactive badge REPLACES
      // what is read, rather than adding to it: "9" and "9 messaggi non letti"
      // read one after the other is exactly the stray-number noise the docs are
      // warning about.
      if (semanticLabel == null) return box;
      return Semantics(
        label: semanticLabel,
        child: ExcludeSemantics(child: box),
      );
    }

    // §4.1.2 / §2.1.1: an `<a class="badge">` is a link, so it needs the role,
    // a name, and the keyboard. Without ItActivatable it would be a
    // pointer-only target with no focus indicator.
    return Semantics(
      link: true,
      label: semanticLabel,
      child: ItActivatable(
        onPressed: onTap,
        cursor: MouseCursor.defer,
        borderRadius: BorderRadius.circular(
          pill
              ? BootstrapItaliaBorders.radiusPill
              : BootstrapItaliaBorders.radius,
        ),
        // With an explicit name the content must be excluded or the merge says
        // it twice; with none, the content IS the name.
        child: semanticLabel == null ? box : ExcludeSemantics(child: box),
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
  /// This parameter
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
            // Pluralised rather than interpolated into one template: the
            // old `'$count notifiche'` announced "1 notifiche" for a badge of
            // one, and German and French inflect the noun.
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
