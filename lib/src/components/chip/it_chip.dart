import 'package:flutter/material.dart';

import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';

/// A Bootstrap Italia chip component.
///
/// Chips are compact elements that represent an input, attribute, or action.
///
/// ```dart
/// ItChip(label: 'Flutter')
/// ItChip(label: 'Tag', icon: Icons.label, dismissible: true, onDismissed: () {})
/// ItChip(label: 'Attivo', selected: true)
/// ```
class ItChip extends StatelessWidget {
  /// The chip label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the chip shows a dismiss button.
  final bool dismissible;

  /// Called when the dismiss button is tapped.
  final VoidCallback? onDismissed;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  /// Whether the chip is in a selected state.
  final bool selected;

  /// Whether the chip uses the large variant.
  final bool large;

  /// Whether the chip is disabled.
  final bool disabled;

  /// Custom background color.
  final Color? color;

  /// Creates a Bootstrap Italia chip.
  const ItChip({
    super.key,
    required this.label,
    this.icon,
    this.dismissible = false,
    this.onDismissed,
    this.onTap,
    this.selected = false,
    this.large = false,
    this.disabled = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final bgColor = _resolveBackgroundColor(colors);
    final fgColor = _resolveForegroundColor(colors);
    final verticalPadding = large ? 8.0 : 4.0;
    final fontSize = large ? 16.0 : 14.0;
    final iconSize = large ? 20.0 : 16.0;

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius:
                BorderRadius.circular(BootstrapItaliaBorders.radiusPill),
            border: selected
                ? Border.all(color: colors.primary, width: 2)
                : Border.all(color: colors.gray300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: fgColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: fgColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (dismissible) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: disabled ? null : onDismissed,
                  child: Icon(
                    Icons.close,
                    size: iconSize,
                    color: fgColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _resolveBackgroundColor(BootstrapItaliaColorScheme colors) {
    if (color != null) return color!;
    if (selected) return colors.primary.withAlpha(26);
    return colors.white;
  }

  Color _resolveForegroundColor(BootstrapItaliaColorScheme colors) {
    if (selected) return colors.primary;
    return colors.neutral1;
  }
}
