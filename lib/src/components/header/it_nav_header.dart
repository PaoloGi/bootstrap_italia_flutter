import 'package:flutter/material.dart';

import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/breakpoints.dart';
import '../../tokens/spacing.dart';

/// A navigation item within [ItNavHeader].
class ItNavItem {
  /// The display label.
  final String label;

  /// Navigation target.
  final String? href;

  /// Called when tapped.
  final VoidCallback? onTap;

  /// Whether this item is currently active.
  final bool active;

  /// Optional icon.
  final IconData? icon;

  /// Creates a nav item.
  const ItNavItem({
    required this.label,
    this.href,
    this.onTap,
    this.active = false,
    this.icon,
  });
}

/// The navigation bar section of a Bootstrap Italia header.
///
/// On desktop, displays a horizontal row of navigation items.
/// On mobile (< lg breakpoint), collapses to a hamburger menu.
///
/// ```dart
/// ItNavHeader(
///   items: [
///     ItNavItem(label: 'Amministrazione', active: true, onTap: () {}),
///     ItNavItem(label: 'Servizi', onTap: () {}),
///     ItNavItem(label: 'Novità', onTap: () {}),
///   ],
/// )
/// ```
class ItNavHeader extends StatefulWidget {
  /// The navigation items.
  final List<ItNavItem> items;

  /// Background color. Defaults to primary.
  final Color? backgroundColor;

  /// Creates a Bootstrap Italia navigation header.
  const ItNavHeader({
    super.key,
    required this.items,
    this.backgroundColor,
  });

  @override
  State<ItNavHeader> createState() => _ItNavHeaderState();
}

class _ItNavHeaderState extends State<ItNavHeader> {
  bool _mobileMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final bgColor = widget.backgroundColor ?? colors.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ItBreakpoint.fromWidth(constraints.maxWidth);
        final isMobile = breakpoint == ItBreakpoint.xs ||
            breakpoint == ItBreakpoint.sm ||
            breakpoint == ItBreakpoint.md;

        return Container(
          width: double.infinity,
          color: bgColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BootstrapItaliaSpacing.space3,
                ),
                child: isMobile ? _buildMobileBar(colors) : _buildDesktopBar(),
              ),
              if (isMobile && _mobileMenuOpen) _buildMobileMenu(colors),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopBar() {
    return Row(
      children: widget.items.map((item) {
        return _NavButton(item: item);
      }).toList(),
    );
  }

  Widget _buildMobileBar(BootstrapItaliaColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.items.firstWhere((i) => i.active, orElse: () => widget.items.first).label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.white,
            ),
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _mobileMenuOpen = !_mobileMenuOpen),
          icon: Icon(
            _mobileMenuOpen ? Icons.close : Icons.menu,
            color: colors.white,
          ),
          tooltip: _mobileMenuOpen ? 'Chiudi menu' : 'Apri menu',
        ),
      ],
    );
  }

  Widget _buildMobileMenu(BootstrapItaliaColorScheme colors) {
    return Container(
      width: double.infinity,
      color: colors.dark,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.items.map((item) {
          return InkWell(
            onTap: () {
              setState(() => _mobileMenuOpen = false);
              item.onTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: BootstrapItaliaSpacing.space3,
                vertical: BootstrapItaliaSpacing.space2 + 4,
              ),
              decoration: item.active
                  ? BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: colors.white,
                          width: 3,
                        ),
                      ),
                    )
                  : null,
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, size: 18, color: colors.white),
                    const SizedBox(width: BootstrapItaliaSpacing.space2),
                  ],
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.white,
                      fontWeight:
                          item.active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final ItNavItem item;

  const _NavButton({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: item.active
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.white,
                    width: 3,
                  ),
                ),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 18, color: colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              item.label,
              style: TextStyle(
                fontSize: 16,
                color: colors.white,
                fontWeight: item.active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
