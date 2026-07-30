import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/spacing.dart';

/// A single item within an [ItList].
class ItListItem {
  /// The item title.
  final String title;

  /// Optional subtitle or description.
  final String? subtitle;

  /// Optional leading widget (icon, avatar, etc.).
  final Widget? leading;

  /// Optional trailing widget (icon, badge, etc.).
  final Widget? trailing;

  /// Whether this item is in an active/selected state.
  final bool active;

  /// Whether this item is disabled.
  final bool disabled;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  /// Creates a list item.
  const ItListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.active = false,
    this.disabled = false,
    this.onTap,
  });
}

/// A Bootstrap Italia styled list component.
///
/// Renders a vertical list of items with optional leading/trailing widgets,
/// active state highlighting, and dividers.
///
/// ```dart
/// ItList(
///   items: [
///     ItListItem(
///       title: 'Elemento 1',
///       subtitle: 'Descrizione',
///       leading: Icon(Icons.folder),
///       trailing: Icon(Icons.chevron_right),
///       onTap: () {},
///     ),
///     ItListItem(title: 'Elemento 2'),
///   ],
/// )
/// ```
class ItList extends StatelessWidget {
  /// The list items.
  final List<ItListItem> items;

  /// Whether to show dividers between items.
  final bool showDividers;

  /// Creates a Bootstrap Italia list.
  const ItList({
    super.key,
    required this.items,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDividers && index > 0)
              Divider(height: 1, color: colors.gray200),
            _ItListTile(item: item),
          ],
        );
      }),
    );
  }
}

class _ItListTile extends StatelessWidget {
  final ItListItem item;

  const _ItListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final bgColor =
        item.active ? colors.primary.withAlpha(13) : null;
    final titleColor = item.disabled
        ? colors.gray400
        : item.active
            ? colors.primary
            : colors.neutral1;

    return Material(
      color: bgColor ?? Colors.transparent,
      child: InkWell(
        onTap: item.disabled ? null : item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BootstrapItaliaSpacing.space3,
            vertical: BootstrapItaliaSpacing.space2 + 4,
          ),
          child: Row(
            children: [
              if (item.leading != null) ...[
                item.leading!,
                const SizedBox(width: BootstrapItaliaSpacing.space3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            item.active ? FontWeight.w600 : FontWeight.w400,
                        color: titleColor,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: item.disabled
                              ? colors.gray400
                              : colors.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.trailing != null) ...[
                const SizedBox(width: BootstrapItaliaSpacing.space2),
                item.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
