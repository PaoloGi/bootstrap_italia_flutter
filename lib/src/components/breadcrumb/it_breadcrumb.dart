import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

/// A single item within an [ItBreadcrumb].
class ItBreadcrumbItem {
  /// The display label.
  final String label;

  /// Navigation target. Null for the current (last) item.
  final String? href;

  /// Called when tapped. Overrides [href] handling.
  final VoidCallback? onTap;

  /// Creates a breadcrumb item.
  const ItBreadcrumbItem({
    required this.label,
    this.href,
    this.onTap,
  });
}

/// A Bootstrap Italia breadcrumb navigation.
///
/// Shows a trail of navigation links with separators. The last item is
/// rendered as the current page (non-interactive).
///
/// ```dart
/// ItBreadcrumb(
///   items: [
///     ItBreadcrumbItem(label: 'Home', onTap: () => navigate('/')),
///     ItBreadcrumbItem(label: 'Servizi', onTap: () => navigate('/servizi')),
///     ItBreadcrumbItem(label: 'Anagrafe'),
///   ],
/// )
/// ```
class ItBreadcrumb extends StatelessWidget {
  /// The breadcrumb items.
  final List<ItBreadcrumbItem> items;

  /// Optional leading icon (e.g. home icon).
  final IconData? icon;

  /// Whether to use dark background variant (light text).
  final bool dark;

  /// The separator between items.
  final String separator;

  /// Creates a Bootstrap Italia breadcrumb.
  const ItBreadcrumb({
    super.key,
    required this.items,
    this.icon,
    this.dark = false,
    this.separator = '/',
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final fgColor =
        dark ? colors.white : colors.secondary;
    final activeColor =
        dark ? colors.white : colors.bodyColor;
    final linkColor =
        dark ? colors.neutral2 : colors.primary;

    return Semantics(
      label: 'Breadcrumb',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: linkColor),
              const SizedBox(width: 4),
            ],
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    separator,
                    style: TextStyle(fontSize: 14, color: fgColor),
                  ),
                ),
              ],
              _buildItem(items[i], i == items.length - 1, linkColor, activeColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    ItBreadcrumbItem item,
    bool isCurrent,
    Color linkColor,
    Color activeColor,
  ) {
    if (isCurrent) {
      return Text(
        item.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: activeColor,
        ),
      );
    }

    return GestureDetector(
      onTap: item.onTap,
      child: Text(
        item.label,
        style: TextStyle(
          fontSize: 14,
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        ),
      ),
    );
  }
}
