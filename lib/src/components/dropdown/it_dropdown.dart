import 'package:flutter/material.dart';

import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/spacing.dart';

// ── Data models ─────────────────────────────────────────────────────

/// Direction the dropdown menu opens relative to the trigger.
enum ItDropdownDirection {
  /// Opens above the trigger.
  up,

  /// Opens below the trigger.
  down,

  /// Opens to the left of the trigger.
  left,

  /// Opens to the right of the trigger.
  right,
}

/// Base type for all dropdown menu entries.
///
/// Use the concrete subtypes to build a list of entries:
/// - [ItDropdownItem] — a tappable menu item
/// - [ItDropdownHeader] — a non-interactive section header
/// - [ItDropdownDivider] — a visual separator line
sealed class ItDropdownEntry {
  /// Creates a dropdown entry.
  const ItDropdownEntry();
}

/// A tappable dropdown menu item.
///
/// Set [danger] to `true` for destructive actions (the label and icon
/// are rendered in the theme's danger color).
class ItDropdownItem extends ItDropdownEntry {
  /// The display label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when this item is tapped.
  final VoidCallback? onTap;

  /// Whether this item represents a destructive action.
  final bool danger;

  /// Whether this item is disabled.
  final bool disabled;

  /// Creates a dropdown item.
  const ItDropdownItem({
    required this.label,
    this.icon,
    this.onTap,
    this.danger = false,
    this.disabled = false,
  });
}

/// A non-interactive section header inside the dropdown menu.
class ItDropdownHeader extends ItDropdownEntry {
  /// The header label.
  final String label;

  /// Creates a dropdown header.
  const ItDropdownHeader({required this.label});
}

/// A visual separator line inside the dropdown menu.
class ItDropdownDivider extends ItDropdownEntry {
  /// Creates a dropdown divider.
  const ItDropdownDivider();
}

// ── Widget ──────────────────────────────────────────────────────────

/// A Bootstrap Italia dropdown menu.
///
/// Displays a list of [ItDropdownEntry] items in an overlay that opens
/// when the user taps the [trigger] widget.
///
/// ```dart
/// ItDropdown(
///   trigger: ItButton(child: Text('Azioni')),
///   direction: ItDropdownDirection.down,
///   items: [
///     ItDropdownHeader(label: 'Sezione'),
///     ItDropdownItem(label: 'Modifica', onTap: () {}),
///     ItDropdownDivider(),
///     ItDropdownItem(label: 'Elimina', onTap: () {}, danger: true),
///   ],
/// )
/// ```
class ItDropdown extends StatefulWidget {
  /// The widget that opens the dropdown when tapped.
  final Widget trigger;

  /// The menu entries.
  final List<ItDropdownEntry> items;

  /// The direction the menu opens relative to the trigger.
  final ItDropdownDirection direction;

  /// Custom width for the menu. Defaults to 200.
  final double? width;

  /// Custom offset from the trigger.
  final Offset? offset;

  /// Creates a Bootstrap Italia dropdown.
  const ItDropdown({
    super.key,
    required this.trigger,
    required this.items,
    this.direction = ItDropdownDirection.down,
    this.width,
    this.offset,
  });

  @override
  State<ItDropdown> createState() => _ItDropdownState();
}

class _ItDropdownState extends State<ItDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  Offset _computeFollowerOffset(Size triggerSize) {
    if (widget.offset != null) return widget.offset!;

    const gap = 4.0;
    return switch (widget.direction) {
      ItDropdownDirection.down => Offset(0, triggerSize.height + gap),
      ItDropdownDirection.up => const Offset(0, -gap),
      ItDropdownDirection.right => Offset(triggerSize.width + gap, 0),
      ItDropdownDirection.left => const Offset(-gap, 0),
    };
  }

  Alignment _computeTargetAnchor() {
    return switch (widget.direction) {
      ItDropdownDirection.down => Alignment.topLeft,
      ItDropdownDirection.up => Alignment.topLeft,
      ItDropdownDirection.right => Alignment.topLeft,
      ItDropdownDirection.left => Alignment.topLeft,
    };
  }

  Alignment _computeFollowerAnchor() {
    return switch (widget.direction) {
      ItDropdownDirection.down => Alignment.topLeft,
      ItDropdownDirection.up => Alignment.bottomLeft,
      ItDropdownDirection.right => Alignment.topLeft,
      ItDropdownDirection.left => Alignment.topRight,
    };
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final triggerSize = renderBox.size;
    final colors = resolveColorScheme(context);
    final menuWidth = widget.width ?? 200.0;
    final followerOffset = _computeFollowerOffset(triggerSize);

    return OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            // Full-screen dismiss target.
            GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              offset: followerOffset,
              targetAnchor: _computeTargetAnchor(),
              followerAnchor: _computeFollowerAnchor(),
              child: Material(
                elevation: 4,
                color: colors.white,
                borderRadius:
                    BorderRadius.circular(BootstrapItaliaBorders.radius),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: menuWidth,
                    maxHeight: 300,
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final entry in widget.items)
                          switch (entry) {
                            ItDropdownItem() =>
                              _buildItem(entry, colors),
                            ItDropdownHeader() =>
                              _buildHeader(entry, colors),
                            ItDropdownDivider() =>
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: colors.gray200,
                              ),
                          },
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItem(
    ItDropdownItem item,
    BootstrapItaliaColorScheme colors,
  ) {
    final Color textColor;
    if (item.disabled) {
      textColor = colors.gray400;
    } else if (item.danger) {
      textColor = colors.danger;
    } else {
      textColor = colors.bodyColor;
    }

    Widget child = InkWell(
      onTap: item.disabled
          ? null
          : () {
              _close();
              item.onTap?.call();
            },
      hoverColor: colors.primary.withAlpha(13),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BootstrapItaliaSpacing.space3,
          vertical: BootstrapItaliaSpacing.space2,
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 18, color: textColor),
              const SizedBox(width: BootstrapItaliaSpacing.space2),
            ],
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );

    if (item.disabled) {
      child = Opacity(opacity: 0.5, child: child);
    }

    return child;
  }

  Widget _buildHeader(
    ItDropdownHeader header,
    BootstrapItaliaColorScheme colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BootstrapItaliaSpacing.space3,
        vertical: BootstrapItaliaSpacing.space2,
      ),
      child: Text(
        header.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.secondary,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Semantics(
        button: true,
        child: GestureDetector(
          onTap: _toggle,
          child: widget.trigger,
        ),
      ),
    );
  }
}
