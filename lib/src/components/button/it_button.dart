import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

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

/// Size variants for [ItButton].
enum ItButtonSize {
  /// Small button: reduced padding and font size.
  sm,

  /// Medium button: default size.
  md,

  /// Large button: increased padding and font size.
  lg,
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
///   icon: Icons.delete,
///   onPressed: () {},
///   child: Text('Elimina'),
/// )
/// ```
class ItButton extends StatelessWidget {
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
    this.size = ItButtonSize.md,
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
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final bgColor = backgroundColor ?? colors.forVariant(variant.name);
    final fgColor = foregroundColor ?? colors.foregroundForVariant(variant.name);
    final isDisabled = disabled || loading;
    final effectiveOnPressed = isDisabled ? null : onPressed;

    final padding = _padding(size);
    final fontSize = _fontSize(size);
    final iconSize = _iconSize(size);

    final buttonStyle = outline
        ? OutlinedButton.styleFrom(
            foregroundColor: bgColor,
            // Bootstrap Italia renders the outline as a 2px inset box-shadow,
            // not a 1px border — match its visual weight.
            side: BorderSide(color: bgColor, width: 2),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(BootstrapItaliaBorders.radius),
            ),
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              fontFamily: BootstrapItaliaFontFamily.sansSerif,
              package: BootstrapItaliaFontFamily.package,
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            padding: padding,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(BootstrapItaliaBorders.radius),
            ),
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              fontFamily: BootstrapItaliaFontFamily.sansSerif,
              package: BootstrapItaliaFontFamily.package,
            ),
          );

    final content = _buildContent(
      fgColor: outline ? bgColor : fgColor,
      iconSize: iconSize,
      fontSize: fontSize,
    );

    Widget button;

    if (outline) {
      button = OutlinedButton(
        onPressed: effectiveOnPressed,
        style: buttonStyle,
        child: content,
      );
    } else {
      button = ElevatedButton(
        onPressed: effectiveOnPressed,
        style: buttonStyle,
        child: content,
      );
    }

    if (block) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildContent({
    required Color fgColor,
    required double iconSize,
    required double fontSize,
  }) {
    final children = <Widget>[];

    if (loading) {
      children.add(
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(fgColor),
          ),
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

  // Matches Bootstrap Italia's .btn (base/md), .btn-lg, and .btn-xs padding
  // and font-size, extracted from bootstrap-italia.min.css.
  static EdgeInsetsGeometry _padding(ItButtonSize size) {
    return switch (size) {
      ItButtonSize.sm =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ItButtonSize.md =>
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ItButtonSize.lg =>
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    };
  }

  static double _fontSize(ItButtonSize size) {
    return switch (size) {
      ItButtonSize.sm => 14,
      ItButtonSize.md => 16,
      ItButtonSize.lg => 18,
    };
  }

  static double _iconSize(ItButtonSize size) {
    return switch (size) {
      ItButtonSize.sm => 16,
      ItButtonSize.md => 20,
      ItButtonSize.lg => 24,
    };
  }
}
