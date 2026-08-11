import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../utilities/interaction_states.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../spinner/progress_spinner.dart';

/// Color variants for [ItButton].
enum ItButtonVariant {
  /// Primary blue button.
  primary,

  /// Secondary gray button.
  secondary,

  /// Green success button.
  success,

  /// Danger red button.
  danger,

  /// Warning orange button.
  warning,

  /// Info button.
  info,

  /// Light button.
  light,

  /// Dark button.
  dark,
}

/// Maps [ItButtonVariant] onto the shared semantic colour roles.
///
/// Exhaustive by construction — Dart requires every value to be handled, so
/// adding a variant here without giving it a colour will not compile. The
/// string-keyed lookup this replaced silently rendered such a variant as
/// primary.
extension ItButtonVariantColor on ItButtonVariant {
  /// The semantic colour role this variant paints with.
  ItVariantColor get variantColor => switch (this) {
        ItButtonVariant.primary => ItVariantColor.primary,
        ItButtonVariant.secondary => ItVariantColor.secondary,
        ItButtonVariant.success => ItVariantColor.success,
        ItButtonVariant.danger => ItVariantColor.danger,
        ItButtonVariant.warning => ItVariantColor.warning,
        ItButtonVariant.info => ItVariantColor.info,
        ItButtonVariant.light => ItVariantColor.light,
        ItButtonVariant.dark => ItVariantColor.dark,
      };
}

/// Size variants for [ItButton].
///
/// Spelled out rather than carrying the CSS suffix. `.btn-sm` / `.btn-lg` are
/// cited on the metrics below, where the class name is evidence; as identifiers
/// they were a third spelling of a concept this package already names two ways
/// (`ItChip.large`, `ItAutocomplete.large`), and one concept gets one name.
enum ItButtonSize {
  /// Small button: reduced padding and font size (`.btn-sm`).
  small,

  /// Medium button: default size.
  medium,

  /// Large button: increased padding and font size (`.btn-lg`).
  large,
}

/// A Bootstrap Italia styled button.
///
/// Supports all color variants, sizes, outline mode, block (full-width) mode,
/// loading state with spinner, and leading/trailing icons.
///
/// ```dart
/// ItButton(
///   variant: ItButtonVariant.primary,
///   onPressed: () {},
///   child: Text('Conferma'),
/// )
///
/// ItButton(
///   variant: ItButtonVariant.danger,
///   outline: true,
///   icon: BootstrapItaliaIcons.it_delete,
///   onPressed: () {},
///   child: Text('Elimina'),
/// )
/// ```
class ItButton extends StatefulWidget {
  /// The button color variant.
  final ItButtonVariant variant;

  /// The button size.
  final ItButtonSize size;

  /// Whether to use the outline style.
  final bool outline;

  /// Whether the button takes the full width of its parent.
  final bool block;

  /// Whether the button is disabled.
  final bool disabled;

  /// Whether to show a loading spinner.
  final bool loading;

  /// Leading icon data.
  final IconData? icon;

  /// Trailing icon data.
  final IconData? trailingIcon;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// Custom background color override.
  final Color? backgroundColor;

  /// Custom foreground color override.
  final Color? foregroundColor;

  /// The button content.
  final Widget child;

  /// Creates a Bootstrap Italia button.
  const ItButton({
    super.key,
    this.variant = ItButtonVariant.primary,
    this.size = ItButtonSize.medium,
    this.outline = false,
    this.block = false,
    this.disabled = false,
    this.loading = false,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    required this.child,
  });

  @override
  State<ItButton> createState() => _ItButtonState();

  Widget _buildContent({
    required Color fgColor,
    required double iconSize,
  }) {
    final children = <Widget>[];

    if (loading) {
      children.add(
        // Bootstrap Italia has no `.progress-spinner` element inside a `.btn`,
        // so the track ring the standalone spinner carries is suppressed: on a
        // filled button the fill already reads as the track, and a grey CSS
        // ring over the brand blue would be a colour the design system never
        // declares here.
        ItProgressSpinner(
          diameter: iconSize,
          strokeWidth: 2,
          color: fgColor,
          trackColor: const Color(0x00000000),
        ),
      );
      children.add(const SizedBox(width: BootstrapItaliaSpacing.space2));
    } else if (icon != null) {
      children.add(Icon(icon, size: iconSize));
      children.add(const SizedBox(width: BootstrapItaliaSpacing.space2));
    }

    children.add(child);

    if (trailingIcon != null && !loading) {
      children.add(const SizedBox(width: BootstrapItaliaSpacing.space2));
      children.add(Icon(trailingIcon, size: iconSize));
    }

    if (children.length == 1) return children.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  /// `.btn:disabled { --bs-btn-disabled-opacity: 0.65 }`
  static const double _disabledOpacity = 0.65;

  // Matches Bootstrap Italia's .btn (base/md), .btn-lg, and .btn-xs padding
  // and font-size, extracted from bootstrap-italia.min.css.
  static EdgeInsetsGeometry _padding(ItButtonSize size) {
    return switch (size) {
      ItButtonSize.small =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ItButtonSize.medium =>
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ItButtonSize.large =>
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    };
  }

  static double _fontSize(ItButtonSize size) {
    return switch (size) {
      ItButtonSize.small => 14,
      ItButtonSize.medium => 16,
      ItButtonSize.large => 18,
    };
  }

  static double _iconSize(ItButtonSize size) {
    return switch (size) {
      ItButtonSize.small => 16,
      ItButtonSize.medium => 20,
      ItButtonSize.large => 24,
    };
  }
}

class _ItButtonState extends State<ItButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final w = widget;
    final bgColor =
        w.backgroundColor ?? colors.forVariant(w.variant.variantColor);
    final fgColor = w.foregroundColor ??
        colors.foregroundForVariant(w.variant.variantColor);
    final isDisabled = w.disabled || w.loading;
    final onPressed = isDisabled ? null : w.onPressed;

    final padding = ItButton._padding(w.size);
    final fontSize = ItButton._fontSize(w.size);
    final iconSize = ItButton._iconSize(w.size);
    final radius = BorderRadius.circular(BootstrapItaliaBorders.radius);

    // `.btn-*` fills and shades toward black on hover/active; `.btn-outline-*`
    // keeps `--bs-btn-hover-bg: transparent` and darkens only its border.
    // Material would instead paint a translucent overlay — lighter on a filled
    // button, darker on a white one — in both cases inventing a state change the
    // design system does not specify. See doc/adr/0001.
    // The shade factors below are read off the CSS: `.btn-primary` sets
    // `--bs-btn-hover-bg: rgb(0, 86.7, 173.4)` and
    // `--bs-btn-active-bg: rgb(0, 81.6, 163.2)` against a `#0066CC` base — i.e.
    // exactly 85% and 80% of the base channel values, hence 0.15 and 0.20.
    final Color fill;
    final Color edge;
    if (w.outline) {
      fill = const Color(0x00000000);
      edge = _pressed
          ? itShade(bgColor, 0.30)
          : _hovered
              ? itShade(bgColor, 0.20)
              : bgColor;
    } else {
      edge = const Color(0x00000000);
      fill = isDisabled
          ? bgColor.withValues(alpha: ItButton._disabledOpacity)
          : _pressed
              ? itShade(bgColor, 0.20)
              : _hovered
                  ? itShade(bgColor, 0.15)
                  : bgColor;
    }

    final content = w._buildContent(
      fgColor: w.outline ? bgColor : fgColor,
      iconSize: iconSize,
    );

    Widget button = Container(
      padding: padding,
      decoration: BoxDecoration(color: fill, borderRadius: radius),
      // `.btn-outline-*` draws its ring as `box-shadow: inset 0 0 0 2px`, which
      // in CSS consumes NO layout space. A `border` in the decoration would be
      // laid out, growing the button by 2px a side and making an outline button
      // larger than the solid one it must match — measured at 215x106 against a
      // 206x96 reference. `foregroundDecoration` paints over the child instead,
      // which is the faithful analogue of an inset shadow.
      foregroundDecoration: w.outline
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: edge,
                width: BootstrapItaliaBorders.widthThick,
              ),
            )
          : null,
      child: DefaultTextStyle.merge(
        // .merge, never the default constructor: a plain DefaultTextStyle
        // REPLACES the ambient style and drops the font family, rendering every
        // glyph as a missing-character box.
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: w.outline ? bgColor : fgColor,
          letterSpacing: 0,
          // `.btn { line-height: 1.5 }`. Material's button applied this via its
          // own text theme; stating it explicitly keeps the control box at the
          // CSS height instead of whatever the font's default metrics give.
          height: 1.5,
          leadingDistribution: TextLeadingDistribution.even,
          fontFamily: BootstrapItaliaFontFamily.sansSerif,
          package: BootstrapItaliaFontFamily.package,
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: w.outline ? bgColor : fgColor,
            size: iconSize,
          ),
          child: content,
        ),
      ),
    );

    // Bootstrap Italia's keyboard focus indicator (2px white, then 3px black).
    // Suppressing Material's overlay removed the only focus cue this button had,
    // so without this it would be a WCAG 2.4.7 regression. Uses the shared
    // ItFocusRing rather than a local copy, and is mounted unconditionally: a
    // ring that appears and disappears from the tree remounts the focus node and
    // destroys the very focus it is meant to show.
    button = Semantics(
      button: true,
      enabled: !isDisabled,
      // Delegates to ItActivatable rather than wiring its own
      // FocusableActionDetector, per ADR 0001. It used to do the latter, and
      // bound only `ActivateIntent` where ItActivatable binds that AND
      // `ButtonActivateIntent` — so the flagship button answered a different
      // set of keys from every other control in the package. Which intent
      // `WidgetsApp` dispatches varies by platform, so the difference was
      // latent rather than visible, which is the kind that ships.
      //
      // The focus ring is left to ItActivatable too (`showFocusRing` defaults
      // true); this file no longer paints one.
      child: ItActivatable(
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(BootstrapItaliaBorders.radius),
        onHoverChanged: (v) => setState(() => _hovered = v),
        onPressedChanged: (v) => setState(() => _pressed = v),
        child: button,
      ),
    );

    if (w.block) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
