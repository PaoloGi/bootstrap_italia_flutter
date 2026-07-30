import 'package:flutter/material.dart';

import '../../tokens/borders.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import '../collapse/it_collapse.dart';

/// A single item within an [ItAccordion].
class ItAccordionItem {
  /// The header title text.
  final String title;

  /// Optional leading icon.
  final IconData? icon;

  /// The expandable content.
  final Widget child;

  /// Whether this item starts expanded.
  final bool initiallyExpanded;

  /// Creates an accordion item.
  const ItAccordionItem({
    required this.title,
    this.icon,
    required this.child,
    this.initiallyExpanded = false,
  });
}

/// A Bootstrap Italia accordion component.
///
/// Displays a list of collapsible panels. By default only one panel can be
/// open at a time; set [allowMultipleOpen] to enable multiple.
///
/// ```dart
/// ItAccordion(
///   items: [
///     ItAccordionItem(title: 'Sezione 1', child: Text('Contenuto 1')),
///     ItAccordionItem(title: 'Sezione 2', child: Text('Contenuto 2')),
///   ],
/// )
/// ```
class ItAccordion extends StatefulWidget {
  /// The accordion items.
  final List<ItAccordionItem> items;

  /// Whether multiple panels can be open simultaneously.
  final bool allowMultipleOpen;

  /// Creates a Bootstrap Italia accordion.
  const ItAccordion({
    super.key,
    required this.items,
    this.allowMultipleOpen = false,
  });

  @override
  State<ItAccordion> createState() => _ItAccordionState();
}

class _ItAccordionState extends State<ItAccordion> {
  late Set<int> _expandedIndices;

  @override
  void initState() {
    super.initState();
    _expandedIndices = {};
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i].initiallyExpanded) {
        _expandedIndices.add(i);
      }
    }
  }

  void _toggle(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        if (!widget.allowMultipleOpen) {
          _expandedIndices.clear();
        }
        _expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: BootstrapItaliaColors.gray300),
        borderRadius: BorderRadius.circular(BootstrapItaliaBorders.radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BootstrapItaliaBorders.radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            final isExpanded = _expandedIndices.contains(index);
            final isFirst = index == 0;
            final isLast = index == widget.items.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isFirst)
                  const Divider(height: 1, color: BootstrapItaliaColors.gray300),
                _AccordionHeader(
                  title: item.title,
                  icon: item.icon,
                  isExpanded: isExpanded,
                  isFirst: isFirst,
                  isLast: isLast && !isExpanded,
                  onTap: () => _toggle(index),
                ),
                ItCollapse(
                  isExpanded: isExpanded,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(BootstrapItaliaSpacing.space3),
                    decoration: BoxDecoration(
                      color: BootstrapItaliaColors.gray100,
                      borderRadius: isLast
                          ? const BorderRadius.only(
                              bottomLeft: Radius.circular(
                                  BootstrapItaliaBorders.radius),
                              bottomRight: Radius.circular(
                                  BootstrapItaliaBorders.radius),
                            )
                          : null,
                    ),
                    child: item.child,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _AccordionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool isExpanded;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _AccordionHeader({
    required this.title,
    this.icon,
    required this.isExpanded,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BootstrapItaliaColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BootstrapItaliaSpacing.space3,
            vertical: BootstrapItaliaSpacing.space3,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: BootstrapItaliaColors.primary),
                const SizedBox(width: BootstrapItaliaSpacing.space2),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: BootstrapItaliaColors.primary,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.expand_more,
                  color: BootstrapItaliaColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
