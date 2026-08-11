import 'package:flutter/widgets.dart';

/// Predefined icon sizes for Bootstrap Italia.
///
/// Spelled out rather than carrying the `.icon-sm` / `.icon-lg` suffixes. See
/// [ItButtonSize].
enum ItIconSize {
  /// Extra small: 16px (`.icon-xs`).
  extraSmall(16),

  /// Small: 24px (`.icon-sm`).
  small(24),

  /// Medium: 32px — the base `.icon`. Default.
  medium(32),

  /// Large: 48px (`.icon-lg`).
  large(48),

  /// Extra large: 64px (`.icon-xl`).
  extraLarge(64);

  /// The size in logical pixels.
  final double value;

  const ItIconSize(this.value);
}

/// A Bootstrap Italia styled icon widget.
///
/// Wraps Flutter's [Icon] with Bootstrap Italia sizing and default coloring.
/// Works with both `bootstrap_italia_icons` and `bootstrap_icons` icon data.
///
/// ```dart
/// ItIcon(BootstrapItaliaIcons.it_file)
/// ItIcon(BootstrapIcons.house, size: ItIconSize.large)
/// ItIcon(Icons.check, color: BootstrapItaliaColors.success)
/// ```
class ItIcon extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The size of the icon. Defaults to [ItIconSize.medium] (32px).
  final ItIconSize size;

  /// Custom size in logical pixels. Overrides [size] if provided.
  final double? customSize;

  /// The color of the icon. Defaults to the current [IconTheme] color.
  final Color? color;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Creates a Bootstrap Italia icon.
  const ItIcon(
    this.icon, {
    super.key,
    this.size = ItIconSize.medium,
    this.customSize,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: customSize ?? size.value,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}
