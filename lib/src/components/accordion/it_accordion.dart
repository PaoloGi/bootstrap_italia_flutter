import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/it_default_text_style.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';
import '../collapse/it_collapse.dart';

/// A single item within an [ItAccordion].
class ItAccordionItem {
  /// The header title text.
  final String title;

  /// Optional leading icon.
  final IconData? icon;

  /// The expandable content, revealed beneath [title] (`.accordion-body`).
  final Widget body;

  /// Whether this item starts expanded.
  final bool initiallyExpanded;

  /// Creates an accordion item.
  const ItAccordionItem({
    required this.title,
    this.icon,
    required this.body,
    this.initiallyExpanded = false,
  });
}

/// Geometry and colour tokens for the Bootstrap Italia `.accordion`.
///
/// All values come from `bootstrap-italia.min.css`.
abstract final class _AccordionTokens {
  /// `--bs-border-color: hsl(210, 4%, 78%)` — used by the accordion's
  /// bottom rule and each header's top rule.
  static const Color borderColor = Color(0xFFC5C7C9);

  /// `.accordion-header .accordion-button { padding: 14px 24px }`
  static const EdgeInsets headerPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 14);

  /// `.accordion-body { padding: 12px 24px 42px }`
  static const EdgeInsets bodyPadding = EdgeInsets.fromLTRB(24, 12, 24, 42);

  /// `.accordion-header .accordion-button:after { width: 1.5rem }`
  static const double iconSize = 24;
}

/// A Bootstrap Italia accordion component.
///
/// Displays a list of collapsible panels separated by hairline rules. By
/// default only one panel can be open at a time; set [allowMultipleOpen] to
/// enable multiple.
///
/// ```dart
/// ItAccordion(
///   items: [
///     ItAccordionItem(title: 'Sezione 1', body: Text('Contenuto 1')),
///     ItAccordionItem(title: 'Sezione 2', body: Text('Contenuto 2')),
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

  @override
  void didUpdateWidget(ItAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length == oldWidget.items.length) return;

    // Expansion is keyed by index, so a changed `items` list silently reassigns
    // it: removing the first of three sections leaves {1, 2} pointing at
    // different sections than the user opened, and any index past the new end
    // stays in the set forever, invisible and un-closable.
    //
    // Indices beyond the new length are dropped. The rest are kept as-is rather
    // than remapped, because without stable identity on ItAccordionItem there
    // is nothing to remap *by* — a list that changed length has no reliable
    // correspondence between old and new positions. Callers who need expansion
    // to follow a specific section across edits should give the accordion a
    // `Key` so the state is rebuilt from `initiallyExpanded`.
    setState(() {
      _expandedIndices.removeWhere((i) => i >= widget.items.length);
      if (!widget.allowMultipleOpen && _expandedIndices.length > 1) {
        final keep = _expandedIndices.reduce((a, b) => a < b ? a : b);
        _expandedIndices
          ..clear()
          ..add(keep);
      }
    });
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
      // `.accordion { border-bottom: 1px solid hsl(210, 4%, 78%) }`
      // A Container (unlike DecoratedBox) reserves layout space for the rule.
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _AccordionTokens.borderColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isExpanded = _expandedIndices.contains(index);

          // §1.3.1 Info and Relationships: `controlsNodes`/`identifier` is
          // Flutter's aria-controls equivalent, tying the header button to the
          // panel it opens so AT can report and reach the relationship.
          final panelId = 'it-accordion-panel-$index-${identityHashCode(this)}';

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AccordionHeader(
                title: item.title,
                icon: item.icon,
                isExpanded: isExpanded,
                panelId: panelId,
                onTap: () => _toggle(index),
              ),
              Semantics(
                identifier: panelId,
                child: ItCollapse(
                  isExpanded: isExpanded,
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: _AccordionTokens.bodyPadding,
                    child: DefaultTextStyle.merge(
                      // `.accordion-body { font-size: 1.125rem;
                      //   line-height: 1.75rem }` at >= 992px
                      style: TextStyle(
                        fontFamily: BootstrapItaliaFontFamily.sansSerif,
                        package: BootstrapItaliaFontFamily.package,
                        fontSize: 18,
                        height: 28 / 18,
                        fontWeight: FontWeight.w400,
                        // hsl(0,0%,10%) is the bodyColor token.
                        color: resolveColorScheme(context).bodyColor,
                      ),
                      child: item.body,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _AccordionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool isExpanded;
  final String panelId;
  final VoidCallback onTap;

  const _AccordionHeader({
    required this.title,
    this.icon,
    required this.isExpanded,
    required this.panelId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ItHoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: _build,
    );
  }

  Widget _build(BuildContext context, bool hovered) {
    final color = isExpanded
        // `.accordion-button { color: #06c }` collapsed and
        // `hsl(210,17%,44%)` expanded — the primary and secondary tokens.
        ? resolveColorScheme(context).secondary
        : resolveColorScheme(context).primary;

    // The kit's markup is `<h2 class="accordion-header"><button
    // class="accordion-button" aria-expanded aria-controls>`, so this node is
    // simultaneously a heading and a disclosure button:
    //   §4.1.2 — button role + `expanded` state (previously absent entirely:
    //            AT could not tell an open panel from a closed one).
    //   §1.3.1 — heading level, plus `controlsNodes` linking it to its panel.
    //   §2.1.1 — ItActivatable handles Enter/Space activation when focused.
    return Semantics(
      button: true,
      expanded: isExpanded,
      header: true,
      headingLevel: 2,
      label: title,
      controlsNodes: <String>{panelId},
      // §2.4.7: the header's own focus ring. ItActivatable owns the focus node
      // now, so it drives the ring directly — `trackDescendants` existed only
      // because the InkWell kept its focus node private.
      child: ItActivatable(
        onPressed: onTap,
        child: ExcludeSemantics(
          // The header's Text states its own font and metrics, so it does not
          // depend on the ambient style the removed Material supplied — but
          // stating it here keeps the accordion correct outside a Scaffold too.
          child: ItDefaultTextStyle(
            child: Container(
              // `.accordion-header .accordion-button
              //   { border-top: 1px solid hsl(210, 4%, 78%); padding: 14px 24px }`
              // on `--bs-accordion-bg: hsl(0, 0%, 100%)`. The fill moves onto this
              // decoration: it used to come from the Material that hosted the ink,
              // and `.accordion-header .accordion-button { background: none }`
              // means it must not change on hover or press, which is why the
              // overlay was suppressed in the first place.
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: _AccordionTokens.borderColor),
                ),
              ),
              padding: _AccordionTokens.headerPadding,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: color),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      // `.accordion-header .accordion-button { font-size:
                      //   1.125rem; font-weight: 600; line-height: 1.5rem }`.
                      // `height` is stated because the Material that used to host
                      // the ink also supplied a line-height through its text
                      // theme; without it the header box changes size.
                      style: TextStyle(
                        fontFamily: BootstrapItaliaFontFamily.sansSerif,
                        package: BootstrapItaliaFontFamily.package,
                        fontSize: 18,
                        height: 24 / 18,
                        fontWeight: FontWeight.w600,
                        color: color,
                        decoration: hovered
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationColor: color,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      BootstrapItaliaIcons.it_expand,
                      size: _AccordionTokens.iconSize,
                      // The chevron keeps the link colour in both states.
                      color: resolveColorScheme(context).primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
