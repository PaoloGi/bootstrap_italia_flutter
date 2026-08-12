import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

  /// Fills an expanded header with the primary colour.
  ///
  /// `.accordion-background-active .accordion-header .accordion-button
  /// [aria-expanded=true] { background-color: #06c; color: #fff;
  /// border-color: #06c }` — and the chevron turns white with it.
  ///
  /// The band becomes the primary token here, so its foreground follows the
  /// theme too: an administration retinting `primary` without the label would
  /// lose the contrast this variant depends on.
  final bool backgroundActive;

  /// Replaces the trailing chevron with a leading `+` / `−` glyph.
  ///
  /// `.accordion-left-icon .accordion-header .accordion-button:after
  /// { content: none }`, and `:before { content: "-" }` becoming `"+"` when
  /// `[aria-expanded=false]`.
  ///
  /// Deliberately typography rather than an icon: the kit renders these as text
  /// in Titillium Web at weight 300, so an icon glyph would change both the
  /// shape and the optical weight.
  final bool leftIcon;

  /// Creates a Bootstrap Italia accordion.
  const ItAccordion({
    super.key,
    required this.items,
    this.allowMultipleOpen = false,
    this.backgroundActive = false,
    this.leftIcon = false,
  });

  @override
  State<ItAccordion> createState() => _ItAccordionState();
}

class _ItAccordionState extends State<ItAccordion> {
  late Set<int> _expandedIndices;

  final Map<int, FocusNode> _focusNodes = <int, FocusNode>{};

  FocusNode _focusNode(int index) =>
      _focusNodes.putIfAbsent(index, FocusNode.new);

  /// Moves focus by [delta], wrapping at both ends.
  ///
  /// §2.1.1, and the ARIA accordion pattern the kit's own docs describe under
  /// *Attivazione tramite codice*: Up/Down move between headers, Home/End jump
  /// to the ends. Tab alone reaches a header but gives a keyboard user no
  /// idiomatic way to move between them, which is the gap this closes.
  ///
  /// Unlike the tab pattern, this moves focus and **nothing else**: an
  /// accordion header is a disclosure button, so arrowing onto it must not open
  /// its panel. Tabs change selection as focus moves; accordions do not, and
  /// conflating the two would make the keyboard expand panels the user never
  /// asked for.
  void _moveFocus(int delta) {
    final count = widget.items.length;
    if (count == 0) return;
    var current = -1;
    for (final entry in _focusNodes.entries) {
      if (entry.value.hasFocus) {
        current = entry.key;
        break;
      }
    }
    // Focus is somewhere else entirely — a panel's own content, say. Moving it
    // to a header the user was not on would be worse than doing nothing.
    if (current < 0) return;
    var next = (current + delta) % count;
    if (next < 0) next += count;
    _focusNode(next).requestFocus();
  }

  void _focusAt(int index) {
    if (index < 0 || index >= widget.items.length) return;
    _focusNode(index).requestFocus();
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

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
    // §2.1.1 and the ARIA accordion pattern, which the kit's docs describe
    // under *Attivazione tramite codice*. Bound at the accordion rather than
    // per header so the keys work wherever focus sits inside it.
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _moveFocus(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _moveFocus(-1),
        const SingleActivator(LogicalKeyboardKey.home): () => _focusAt(0),
        const SingleActivator(LogicalKeyboardKey.end): () =>
            _focusAt(widget.items.length - 1),
      },
      child: _buildAccordion(context),
    );
  }

  Widget _buildAccordion(BuildContext context) {
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
                backgroundActive: widget.backgroundActive,
                leftIcon: widget.leftIcon,
                focusNode: _focusNode(index),
              ),
              Semantics(
                identifier: panelId,
                child: ItCollapse(
                  isExpanded: isExpanded,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFFFFFFF),
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
  final bool backgroundActive;
  final bool leftIcon;
  final FocusNode? focusNode;

  const _AccordionHeader({
    required this.title,
    this.icon,
    required this.isExpanded,
    required this.panelId,
    required this.onTap,
    this.backgroundActive = false,
    this.leftIcon = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return ItHoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: _build,
    );
  }

  Widget _build(BuildContext context, bool hovered) {
    final colors = resolveColorScheme(context);
    // `.accordion-background-active … [aria-expanded=true]
    //   { background-color: #06c; color: #fff }` — #06c is `--bs-primary` and
    // the band therefore re-themes, so its foreground must follow it or a
    // retinted administration loses the contrast this variant depends on.
    final activeBand = backgroundActive && isExpanded;

    final color = activeBand
        ? colors.white
        : isExpanded
            // `.accordion-button { color: #06c }` collapsed and
            // `hsl(210,17%,44%)` expanded — the primary and secondary tokens.
            ? colors.secondary
            : colors.primary;

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
        focusNode: focusNode,
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
              decoration: BoxDecoration(
                color: activeBand ? colors.primary : const Color(0xFFFFFFFF),
                border: Border(
                  top: BorderSide(
                    // `border-color: #06c` on the active band, so the rule
                    // between two open sections does not cut across the fill.
                    color: activeBand
                        ? colors.primary
                        : _AccordionTokens.borderColor,
                  ),
                ),
              ),
              padding: _AccordionTokens.headerPadding,
              child: Row(
                children: [
                  if (leftIcon)
                    _LeftGlyph(isExpanded: isExpanded, color: color),
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
                  // `.accordion-left-icon … .accordion-button:after
                  //   { content: none }` — the two indicators are alternatives,
                  // never both.
                  if (!leftIcon)
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        BootstrapItaliaIcons.it_expand,
                        size: _AccordionTokens.iconSize,
                        // The chevron keeps the link colour, except on the
                        // active band where it turns white with the label.
                        color: activeBand ? colors.white : colors.primary,
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

/// The `+` / `−` indicator of `.accordion-left-icon`.
///
/// `.accordion-left-icon .accordion-header .accordion-button:before
/// { font-weight: 300; content: "-"; float: left; margin: 0 1rem .333rem 0;
///   width: 1.5rem; font-size: 1.5rem; line-height: 1.2rem;
///   font-family: "Titillium Web" }`, with `content: "+"` while collapsed.
///
/// Text rather than an icon, because that is what the kit draws — a glyph from
/// the icon set would differ in both shape and optical weight. The box is fixed
/// at 24px so the title does not shift by a pixel when `+` becomes `−`, which
/// the differing advance widths would otherwise cause on every toggle.
class _LeftGlyph extends StatelessWidget {
  const _LeftGlyph({required this.isExpanded, required this.color});

  final bool isExpanded;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // `margin: 0 1rem .3333rem 0`
      padding: const EdgeInsets.only(right: 16, bottom: 5.33),
      child: SizedBox(
        width: 24,
        child: Text(
          isExpanded ? '-' : '+',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: BootstrapItaliaFontFamily.sansSerif,
            package: BootstrapItaliaFontFamily.package,
            fontSize: 24,
            height: 19.2 / 24,
            fontWeight: FontWeight.w300,
            color: color,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    );
  }
}
