import 'package:flutter/widgets.dart';

/// Predefined icon sizes for Bootstrap Italia.
enum ItIconSize {
  /// Extra small: 16px.
  xs(16),

  /// Small: 24px.
  sm(24),

  /// Medium: 32px. Default.
  md(32),

  /// Large: 48px.
  lg(48),

  /// Extra large: 64px.
  xl(64);

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
/// ItIcon(BootstrapItaliaIcons.document)
/// ItIcon(BootstrapIcons.house, size: ItIconSize.lg)
/// ItIcon(Icons.check, color: BootstrapItaliaColors.success)
/// ```
class ItIcon extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The size of the icon. Defaults to [ItIconSize.md] (32px).
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
    this.size = ItIconSize.md,
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
