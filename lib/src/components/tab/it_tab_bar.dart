import 'package:flutter/material.dart';

import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';

/// Visual style for [ItTabBar].
enum ItTabStyle {
  /// Underline indicator below active tab.
  underline,

  /// Card-style background on active tab.
  card,

  /// Button-style tabs.
  button,
}

/// A single tab item definition.
class ItTabItem {
  /// The tab label text.
  final String label;

  /// Optional icon.
  final IconData? icon;

  /// Whether this tab is disabled.
  final bool disabled;

  /// Creates a tab item.
  const ItTabItem({
    required this.label,
    this.icon,
    this.disabled = false,
  });
}

/// A Bootstrap Italia tab bar.
///
/// Displays a horizontal row of selectable tabs styled according to
/// Bootstrap Italia.
///
/// ```dart
/// ItTabBar(
///   tabs: [
///     ItTabItem(label: 'Tab 1'),
///     ItTabItem(label: 'Tab 2', icon: Icons.settings),
///   ],
///   selectedIndex: _currentTab,
///   onChanged: (index) => setState(() => _currentTab = index),
/// )
/// ```
class ItTabBar extends StatelessWidget {
  /// The tab items.
  final List<ItTabItem> tabs;

  /// The currently selected tab index.
  final int selectedIndex;

  /// Called when a tab is selected.
  final ValueChanged<int>? onChanged;

  /// The visual style of the tabs.
  final ItTabStyle style;

  /// Creates a Bootstrap Italia tab bar.
  const ItTabBar({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onChanged,
    this.style = ItTabStyle.underline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    return Container(
      decoration: style == ItTabStyle.underline
          ? BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: colors.gray300, width: 1),
              ),
            )
          : null,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = index == selectedIndex;

          return _TabButton(
            label: tab.label,
            icon: tab.icon,
            isSelected: isSelected,
            disabled: tab.disabled,
            style: style,
            onTap: tab.disabled ? null : () => onChanged?.call(index),
          );
        }),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final bool disabled;
  final ItTabStyle style;
  final VoidCallback? onTap;

  const _TabButton({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.disabled,
    required this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final fgColor = disabled
        ? colors.gray400
        : isSelected
            ? colors.primary
            : colors.secondary;

    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: fgColor,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _decoration(colors),
        child: content,
      ),
    );
  }

  BoxDecoration? _decoration(BootstrapItaliaColorScheme colors) {
    return switch (style) {
      ItTabStyle.underline => BoxDecoration(
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: colors.primary,
                    width: 2,
                  ),
                )
              : null,
        ),
      ItTabStyle.card => BoxDecoration(
          color: isSelected ? colors.white : Colors.transparent,
          border: isSelected
              ? Border.all(color: colors.gray300)
              : null,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ItTabStyle.button => BoxDecoration(
          color: isSelected
              ? colors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
    };
  }
}
