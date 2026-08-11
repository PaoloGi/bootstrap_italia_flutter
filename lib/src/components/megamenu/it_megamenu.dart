// The megamenu component root: the always-visible bar, and the state that
// decides what it shows.
//
// This file holds the parts that cannot be moved apart without inventing an API
// between them — the open-section index, the Esc binding that closes a panel and
// restores focus, the breakpoint decision, the desktop toggles that read and
// write that index, and the route push that hands off to the mobile overlay.
// The three things it delegates to — the data model, the desktop panel and the
// mobile overlay — each render from a section and know nothing about which one
// is open.
//
// It also remains the package's entry point for the component: the barrel
// exports this file and nothing else under `megamenu/`, so the models and
// [ItMegamenuPanel] are re-exported here to keep the public surface exactly
// where it has always been.

import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../a11y/it_icon_action.dart';
import '../../l10n/it_localizations.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/spacing.dart';
import 'it_megamenu_mobile.dart';
import 'it_megamenu_models.dart';
import 'it_megamenu_panel.dart';

export 'it_megamenu_models.dart';
export 'it_megamenu_panel.dart';

// ── Main Widget ─────────────────────────────────────────────────

/// A Bootstrap Italia megamenu navigation component.
///
/// On desktop (≥ lg breakpoint), displays a horizontal nav bar where tapping
/// a section reveals a multi-column dropdown panel below.
///
/// On mobile (< lg breakpoint), displays a hamburger button that opens a
/// full-screen overlay with accordion-style section expansion, following
/// Bootstrap Italia's dialog-pattern mobile navigation (v2.15.0+).
///
/// ```dart
/// ItMegamenu(
///   sections: [
///     ItMegamenuSection(
///       label: 'Amministrazione',
///       active: true,
///       columns: [
///         ItMegamenuColumn(
///           heading: 'Organi di governo',
///           links: [
///             ItMegamenuLink(label: 'Sindaco', onTap: () {}),
///             ItMegamenuLink(label: 'Giunta comunale', onTap: () {}),
///           ],
///         ),
///       ],
///       headerCta: ItMegamenuCta(
///         label: 'Esplora la sezione',
///         onTap: () {},
///       ),
///     ),
///     ItMegamenuSection(
///       label: 'Servizi',
///       columns: [
///         ItMegamenuColumn(
///           links: [
///             ItMegamenuLink(label: 'Anagrafe', onTap: () {}),
///             ItMegamenuLink(label: 'Tributi', onTap: () {}),
///           ],
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
class ItMegamenu extends StatefulWidget {
  /// The megamenu sections (top-level nav items with their content).
  final List<ItMegamenuSection> sections;

  /// Background color for the nav bar. Defaults to primary.
  final Color? backgroundColor;

  /// Whether the mobile overlay allows multiple sections open at once.
  ///
  /// Defaults to false (accordion behavior: one section at a time).
  final bool mobileAllowMultipleOpen;

  /// Creates a Bootstrap Italia megamenu.
  const ItMegamenu({
    super.key,
    required this.sections,
    this.backgroundColor,
    this.mobileAllowMultipleOpen = false,
  });

  @override
  State<ItMegamenu> createState() => _ItMegamenuState();
}

class _ItMegamenuState extends State<ItMegamenu> {
  int? _openSectionIndex;

  /// Focus nodes for the desktop toggles, so Esc can restore focus to the
  /// toggle that opened the panel rather than dumping it at the page root.
  final Map<int, FocusNode> _toggleFocusNodes = <int, FocusNode>{};
  int _lastOpenedIndex = 0;

  FocusNode _toggleFocusNode(int index) =>
      _toggleFocusNodes.putIfAbsent(index, FocusNode.new);

  @override
  void dispose() {
    for (final node in _toggleFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final bgColor = widget.backgroundColor ?? colors.primary;

    return Builder(
      builder: (context) {
        // Viewport-based, via the theme's single breakpoint resolver — NOT the
        // widget's own constraints. CSS `@media` queries are viewport-based, so
        // the reference implementation keeps the desktop nav (letting links
        // wrap) even inside a narrow column. Measured: at a 1280px viewport with
        // this band constrained to 375px, React stays desktop while a
        // LayoutBuilder collapsed to the hamburger. Routing every breakpoint
        // decision through `context` also keeps the package internally
        // consistent — responsive typography and this band can no longer
        // disagree about which breakpoint they are in. Use ItResponsiveBuilder
        // where container-based behaviour is genuinely wanted.
        final isMobile = !context.isDesktop;

        // §2.1.2 No Keyboard Trap / §2.1.1 Keyboard: an open megamenu panel
        // must be dismissible from the keyboard. Esc closes it and returns
        // focus to the toggle, matching the kit's dropdown behaviour.
        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.escape): () {
              if (_openSectionIndex != null) {
                setState(() => _openSectionIndex = null);
                _toggleFocusNodes[_lastOpenedIndex]?.requestFocus();
              }
            },
          },
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            role: SemanticsRole.navigation,
            // §2.4.3 Focus Order. The panel is a sibling *after* the whole
            // bar, because that is what stacks it below on screen — but in the
            // kit the panel is a child of its own `li`, so Tab goes toggle →
            // that panel's links. Here it went toggle → every remaining toggle
            // → the panel, which for a menu of six sections means tabbing past
            // five unrelated controls to reach the thing you just opened.
            //
            // Fixed by ordering traversal rather than by moving the widget:
            // each toggle takes its index, and the open panel takes
            // `index + 0.5`, which places it immediately after its own toggle
            // without changing a pixel of the layout.
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    color: bgColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: BootstrapItaliaSpacing.space3,
                    ),
                    child:
                        isMobile ? _buildMobileBar(colors) : _buildDesktopBar(),
                  ),
                  if (!isMobile && _openSectionIndex != null)
                    FocusTraversalOrder(
                      order: NumericFocusOrder(_openSectionIndex! + 0.5),
                      child: ItMegamenuPanel(
                        section: widget.sections[_openSectionIndex!],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Desktop ─────────────────────────────────────────────────

  @override
  void didUpdateWidget(ItMegamenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `_openSectionIndex` is an index into `widget.sections`, so a shorter list
    // leaves it pointing past the end and `sections[_openSectionIndex!]`
    // throws RangeError on the next build — while a panel is open, i.e. exactly
    // when a user is interacting with it. Same defect class as ItAccordion's.
    if (_openSectionIndex != null &&
        _openSectionIndex! >= widget.sections.length) {
      _openSectionIndex = null;
    }
  }

  Widget _buildDesktopBar() {
    return Row(
      children: List.generate(widget.sections.length, (i) {
        final section = widget.sections[i];
        final isOpen = _openSectionIndex == i;

        return FocusTraversalOrder(
          order: NumericFocusOrder(i.toDouble()),
          child: _DesktopNavButton(
            label: section.label,
            icon: section.icon,
            isActive: section.active || isOpen,
            isCurrent: section.active,
            isOpen: isOpen,
            focusNode: _toggleFocusNode(i),
            onTap: () {
              setState(() {
                _openSectionIndex = isOpen ? null : i;
                if (!isOpen) _lastOpenedIndex = i;
              });
              // Move focus onto the toggle when the panel opens. Besides being
              // the behaviour a keyboard user expects, it is what puts focus
              // inside the Esc handler's subtree — otherwise a panel opened by
              // mouse could not be dismissed from the keyboard at all (§2.1.2).
              if (!isOpen) _toggleFocusNode(i).requestFocus();
            },
          ),
        );
      }),
    );
  }

  // ── Mobile ──────────────────────────────────────────────────

  Widget _buildMobileBar(BootstrapItaliaColorScheme colors) {
    // `orElse: () => sections.first` throws StateError on an empty list, so an
    // empty megamenu crashed on mobile while the desktop path rendered nothing
    // and carried on. Same input, two behaviours, one of them a crash.
    if (widget.sections.isEmpty) return const SizedBox.shrink();
    final activeSection = widget.sections.firstWhere(
      (s) => s.active,
      orElse: () => widget.sections.first,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            activeSection.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.white,
            ),
          ),
        ),
        // `.custom-navbar-toggler { background: none; border: none }` with a
        // 24px glyph: no fill in any state. The name was previously carried by
        // the tooltip and is now stated outright (§4.1.2).
        ItIconAction(
          icon: BootstrapItaliaIcons.it_burger,
          color: colors.white,
          label: ItLocalizations.of(context).openMenu,
          onPressed: () => _openMobileMenu(context),
        ),
      ],
    );
  }

  void _openMobileMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        // `.modal-backdrop { --bs-backdrop-bg: hsl(0, 0%, 0%);
        //   --bs-backdrop-opacity: .8; background-color: var(--bs-backdrop-bg) }`
        // — the scrim is named as the black token upstream, so retinting
        // `black` carries through here too.
        barrierColor: resolveColorScheme(context).black.withValues(alpha: 0.8),
        // Read from the caller's context: the route does not exist yet, and its
        // own context would not be under this subtree's `Localizations` anyway.
        barrierLabel: ItLocalizations.of(context).closeMenu,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        pageBuilder: (context, _, __) {
          return MegamenuMobileOverlay(
            sections: widget.sections,
            allowMultipleOpen: widget.mobileAllowMultipleOpen,
          );
        },
      ),
    );
  }
}

// ── Desktop Nav Button ──────────────────────────────────────────

class _DesktopNavButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final bool isCurrent;
  final bool isOpen;
  final FocusNode? focusNode;
  final VoidCallback onTap;

  const _DesktopNavButton({
    required this.label,
    this.icon,
    required this.isActive,
    required this.isCurrent,
    required this.isOpen,
    required this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    // §4.1.2 Name, Role, Value: the panel's open/closed state is otherwise
    // conveyed only by a static chevron glyph. `expanded` is the aria-expanded
    // equivalent; `selected` carries "this is the current section".
    return Semantics(
      button: true,
      expanded: isOpen,
      selected: isCurrent,
      label: label,
      child: ItActivatable(
        onPressed: onTap,
        focusNode: focusNode,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: isActive
                ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colors.white, width: 3),
                    ),
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.white,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                // `a.dropdown-toggle[aria-expanded=true] > .icon
                //   { transform: scaleY(-1) }`. The mobile tile already did
                // this; the desktop button painted a static glyph, so for a
                // sighted mouse user the only signal that a section was open
                // was the panel itself.
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(BootstrapItaliaIcons.it_expand,
                      size: 18, color: colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
