import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';
import '../tokens/borders.dart';
import '../tokens/spacing.dart';

/// A single option within an [ItSelect].
class ItSelectItem<T> {
  /// The option value.
  final T value;

  /// The display label.
  final String label;

  /// Optional group name for grouped options.
  final String? group;

  /// Whether this option is disabled.
  final bool disabled;

  /// Creates a select item.
  const ItSelectItem({
    required this.value,
    required this.label,
    this.group,
    this.disabled = false,
  });
}

/// A Bootstrap Italia select dropdown.
///
/// Provides a styled dropdown for single or multiple selection with
/// optional search filtering.
///
/// ```dart
/// ItSelect<String>(
///   label: 'Provincia',
///   items: [
///     ItSelectItem(value: 'RM', label: 'Roma'),
///     ItSelectItem(value: 'MI', label: 'Milano'),
///   ],
///   value: 'RM',
///   onChanged: (value) {},
/// )
/// ```
class ItSelect<T> extends StatefulWidget {
  /// The floating label text.
  final String? label;

  /// Hint text when no value is selected.
  final String? hint;

  /// The available options.
  final List<ItSelectItem<T>> items;

  /// Currently selected value (single select).
  final T? value;

  /// Currently selected values (multiple select).
  final Set<T>? values;

  /// Called when single selection changes.
  final ValueChanged<T?>? onChanged;

  /// Called when multiple selection changes.
  final ValueChanged<Set<T>>? onMultiChanged;

  /// Whether to allow multiple selection.
  final bool multiple;

  /// Whether to show a search/filter field.
  final bool searchable;

  /// Whether the select is disabled.
  final bool disabled;

  /// Creates a Bootstrap Italia select.
  const ItSelect({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.value,
    this.values,
    this.onChanged,
    this.onMultiChanged,
    this.multiple = false,
    this.searchable = false,
    this.disabled = false,
  });

  @override
  State<ItSelect<T>> createState() => _ItSelectState<T>();
}

class _ItSelectState<T> extends State<ItSelect<T>> {
  bool _isOpen = false;
  String _searchQuery = '';
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  List<ItSelectItem<T>> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items
        .where((item) =>
            item.label.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String get _displayText {
    if (widget.multiple) {
      final selected = widget.values ?? {};
      if (selected.isEmpty) return widget.hint ?? '';
      final labels = widget.items
          .where((item) => selected.contains(item.value))
          .map((item) => item.label);
      return labels.join(', ');
    }
    if (widget.value == null) return widget.hint ?? '';
    final item = widget.items.cast<ItSelectItem<T>?>().firstWhere(
          (item) => item!.value == widget.value,
          orElse: () => null,
        );
    return item?.label ?? '';
  }

  void _toggleDropdown() {
    if (widget.disabled) return;
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
      _searchQuery = '';
    });
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  void _selectItem(ItSelectItem<T> item) {
    if (item.disabled) return;

    if (widget.multiple) {
      final current = Set<T>.from(widget.values ?? {});
      if (current.contains(item.value)) {
        current.remove(item.value);
      } else {
        current.add(item.value);
      }
      widget.onMultiChanged?.call(current);
      _overlayEntry?.markNeedsBuild();
    } else {
      widget.onChanged?.call(item.value);
      _close();
    }
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final colors = resolveColorScheme(context);

    return OverlayEntry(
      builder: (context) {
        final filtered = _filteredItems;
        return Stack(
          children: [
            GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 4,
                borderRadius:
                    BorderRadius.circular(BootstrapItaliaBorders.radius),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width,
                    maxHeight: 300,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.searchable)
                        Padding(
                          padding: const EdgeInsets.all(
                              BootstrapItaliaSpacing.space2),
                          child: TextField(
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Cerca...',
                              isDense: true,
                              prefixIcon: Icon(Icons.search, size: 18),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (query) {
                              _searchQuery = query;
                              _overlayEntry?.markNeedsBuild();
                            },
                          ),
                        ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final isSelected = widget.multiple
                                ? (widget.values ?? {}).contains(item.value)
                                : widget.value == item.value;

                            return InkWell(
                              onTap: item.disabled
                                  ? null
                                  : () => _selectItem(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: BootstrapItaliaSpacing.space3,
                                  vertical: BootstrapItaliaSpacing.space2,
                                ),
                                color: isSelected
                                    ? colors.primary
                                        .withAlpha(26)
                                    : null,
                                child: Row(
                                  children: [
                                    if (widget.multiple) ...[
                                      Icon(
                                        isSelected
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                        size: 18,
                                        color: isSelected
                                            ? colors.primary
                                            : colors.gray400,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: item.disabled
                                              ? colors.gray400
                                              : colors.bodyColor,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (!widget.multiple && isSelected)
                                      Icon(
                                        Icons.check,
                                        size: 18,
                                        color: colors.primary,
                                      ),
                                  ],
                                ),
                            ),
                          );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Opacity(
          opacity: widget.disabled ? 0.5 : 1.0,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(
                color: colors.secondary,
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BootstrapItaliaBorders.radius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(BootstrapItaliaBorders.radius),
                borderSide:
                    BorderSide(color: colors.gray400),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: BootstrapItaliaSpacing.space3,
                vertical: BootstrapItaliaSpacing.space2 + 4,
              ),
              suffixIcon: AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more),
              ),
            ),
            child: Text(
              _displayText,
              style: TextStyle(
                fontSize: 16,
                color: _displayText == (widget.hint ?? '')
                    ? colors.gray400
                    : colors.bodyColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
