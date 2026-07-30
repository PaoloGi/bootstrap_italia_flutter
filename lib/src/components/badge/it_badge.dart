import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';

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
    final bgColor = colors.forVariant(variant.name);
    final fgColor = colors.foregroundForVariant(variant.name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(
          pill ? BootstrapItaliaBorders.radiusPill : BootstrapItaliaBorders.radius,
        ),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fgColor,
          height: 1.5,
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

  /// Creates a notification badge.
  const ItNotificationBadge({
    super.key,
    required this.count,
    this.max = 99,
    this.variant = ItBadgeVariant.danger,
    required this.child,
  });

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
            child: ItBadge(
              variant: variant,
              pill: true,
              child: Text(count > max ? '$max+' : '$count'),
            ),
          ),
      ],
    );
  }
}
