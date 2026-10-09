// The mobile navigation overlay — the full-screen route Bootstrap Italia opens
// below the `lg` breakpoint (its dialog-pattern mobile navigation, v2.15.0+),
// with its close button, accordion section tiles, flattened link lists and CTA
// links.
//
// Its own file because it is a second, independent rendering of the same
// sections: it shares no widget with the desktop panel, only the data model and
// the SCSS tokens. It is also the only part of the megamenu that lives on a
// route rather than in the caller's tree, which is what gives it a hard
// ancestor requirement the rest of the component does not have — see the note
// on [MegamenuMobileOverlay].
//
// Nothing here is exported from the package barrel: the overlay is reached by
// tapping the bar's hamburger, never by construction.

import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/it_localizations.dart';
import '../../a11y/it_activatable.dart';
import '../../a11y/it_icon_action.dart';
import '../../theme/it_default_text_style.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/spacing.dart';
import '../../utilities/interaction_states.dart';
import '../collapse/it_collapse.dart';
import 'it_megamenu_models.dart';
import 'it_megamenu_tokens.dart';

// ── CTA Link ────────────────────────────────────────────────────

class _CtaLink extends StatelessWidget {
  final ItMegamenuCta cta;
  final Color color;
  final bool isBold;

  const _CtaLink({
    required this.cta,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return ItHoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: _build,
    );
  }

  Widget _build(BuildContext context, bool hovered) {
    return Semantics(
      link: true,
      label: cta.label,
      // §2.4.7: ItActivatable owns the focus node and paints the shared ring
      // directly, so the ring no longer has to watch a descendant for it.
      //
      // `.it-heading-link` / `.it-footer-link` only underline on hover — the row
      // itself never fills, so there is nothing an ink surface could paint.
      child: ItActivatable(
        onPressed: cta.onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (cta.icon != null) ...[
                  Icon(cta.icon, size: 18, color: color),
                  const SizedBox(width: BootstrapItaliaSpacing.space2),
                ],
                Text(
                  cta.label,
                  style: TextStyle(
                    fontSize: ItMegamenuTokens.headingFontSize,
                    fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                    decoration: hovered
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: color,
                  ),
                ),
                const SizedBox(width: BootstrapItaliaSpacing.space1),
                Icon(BootstrapItaliaIcons.it_arrow_right,
                    size: 16, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mobile Overlay ──────────────────────────────────────────────

/// The megamenu's full-screen mobile navigation panel.
///
/// Internal to the component — `ItMegamenu` pushes it as a route when the
/// hamburger is tapped, and it is deliberately absent from the package barrel.
/// It is not private only because Dart's library privacy does not reach across
/// files, and the bar that pushes it lives in `it_megamenu.dart`.
///
/// Requires a [Navigator] ancestor: it is pushed as a route and pops itself
/// from the close button, the Esc binding and every link tap. That is an
/// undocumented hard ancestor requirement, which it shares with
/// `it_modal.dart`: without one, the first interaction throws rather than
/// failing at build.
class MegamenuMobileOverlay extends StatefulWidget {
  /// The sections to list, in bar order.
  final List<ItMegamenuSection> sections;

  /// Whether more than one section may be expanded at a time.
  final bool allowMultipleOpen;

  /// The `.theme-dark-mobile` panel — see [ItMegamenu.darkMobile].
  ///
  /// Applies to the panel's own chrome only: its fill, the close glyph, the
  /// section tiles and their active rule. The expanded body below each tile
  /// keeps `.it-vertical { background: hsl(210,62%,97%) }` in both themes,
  /// because `.theme-dark-mobile` states no override for it — so the links
  /// inside stay on a light ground and keep their `#06c`.
  final bool dark;

  /// Creates the mobile navigation panel.
  const MegamenuMobileOverlay({
    super.key,
    required this.sections,
    required this.allowMultipleOpen,
    this.dark = false,
  });

  @override
  State<MegamenuMobileOverlay> createState() => _MegamenuMobileOverlayState();
}

class _MegamenuMobileOverlayState extends State<MegamenuMobileOverlay> {
  final Set<int> _expandedIndices = {};

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
    final colors = resolveColorScheme(context);
    // `.navbar .navbar-collapsable .menu-wrapper { background: #fff }`, which
    // `.theme-dark-mobile` overrides with `{ background: #06c }`; the panel's
    // own foreground follows it, per
    // `… .close-div .close-menu { color: #fff }` and
    // `… li > button.nav-link { color: #fff }`.
    final panelBg = widget.dark ? colors.primary : colors.white;
    final panelFg = widget.dark ? colors.white : colors.bodyColor;

    // §2.1.2: Esc must close the overlay, not just the barrier tap.
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: FocusScope(
        autofocus: true,
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          role: SemanticsRole.navigation,
          label: ItLocalizations.of(context).navigationMenu,
          // The overlay route is `opaque: false` over an 80%-black barrier, so
          // this panel must paint its own opaque fill. That fill was the only
          // thing the Material contributed (it hosted no ink at all), and a
          // ColoredBox states it without pulling in a Material surface — or its
          // text theme, which is why every Text below sets its own metrics.
          child: ItDefaultTextStyle(
            child: ColoredBox(
              color: panelBg,
              child: SafeArea(
                child: Column(
                  children: [
                    // Close button row
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(BootstrapItaliaSpacing.space2),
                        // `.navbar .close-div .close-menu
                        //   { background: rgba(0,0,0,0); padding: 0;
                        //     width: 44px; height: 44px; display: flex;
                        //     align-items: center; justify-content: center }` —
                        // a centred glyph on no fill. ItIconAction states the
                        // button role and the name itself, so the surrounding
                        // Semantics is no longer needed.
                        //
                        // One key for both this and the header toggles. They
                        // once said `'Chiudi il menu'` and `'Chiudi menu'` —
                        // the same action announced two ways depending on which
                        // component drew it, which is the sort of thing a
                        // single string table makes impossible.
                        child: ItIconAction(
                          icon: BootstrapItaliaIcons.it_close,
                          color: panelFg,
                          label: ItLocalizations.of(context).closeMenu,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // Scrollable section list
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(
                            widget.sections.length,
                            (i) => _MobileSectionTile(
                              section: widget.sections[i],
                              isExpanded: _expandedIndices.contains(i),
                              dark: widget.dark,
                              onToggle: () => _toggle(i),
                              onLinkTap: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mobile Section Tile ─────────────────────────────────────────

class _MobileSectionTile extends StatelessWidget {
  final ItMegamenuSection section;
  final bool isExpanded;
  final bool dark;
  final VoidCallback onToggle;
  final VoidCallback onLinkTap;

  const _MobileSectionTile({
    required this.section,
    required this.isExpanded,
    required this.dark,
    required this.onToggle,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    // `.theme-dark-mobile … li a.nav-link { color: #fff }` and
    // `… a.nav-link.active { border-left-color: #fff }` — the tile's label,
    // glyphs and active rule are one declaration in the stylesheet, so they
    // are one value here.
    final tileFg = dark ? colors.white : colors.bodyColor;
    final activeRule = dark ? colors.white : colors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // §4.1.2: the section header is a disclosure control — expose its
        // expanded state and its name as one node.
        Semantics(
          button: true,
          expanded: isExpanded,
          selected: section.active,
          label: section.label,
          // §2.4.7: ItActivatable owns the focus node and paints the ring.
          //
          // `.navbar-collapsable .navbar-nav a.nav-link:hover` underlines and
          // never fills, so the tile has no background in any state.
          child: ItActivatable(
            onPressed: onToggle,
            child: ExcludeSemantics(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: BootstrapItaliaSpacing.space4,
                  vertical: BootstrapItaliaSpacing.space3,
                ),
                decoration: section.active
                    ? BoxDecoration(
                        border: Border(
                          left: BorderSide(color: activeRule, width: 3),
                        ),
                      )
                    : null,
                child: Row(
                  children: [
                    if (section.icon != null) ...[
                      Icon(section.icon, size: 20, color: tileFg),
                      const SizedBox(width: BootstrapItaliaSpacing.space2),
                    ],
                    Expanded(
                      child: Text(
                        section.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: section.active
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: tileFg,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        BootstrapItaliaIcons.it_expand,
                        color: tileFg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Expandable content
        ItCollapse(
          isExpanded: isExpanded,
          child: Container(
            width: double.infinity,
            color: ItMegamenuTokens.mobileExpandedBg,
            padding: const EdgeInsets.symmetric(
              horizontal: BootstrapItaliaSpacing.space4,
              vertical: BootstrapItaliaSpacing.space3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header CTA
                if (section.headerCta != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: BootstrapItaliaSpacing.space3,
                    ),
                    child: _CtaLink(
                      cta: section.headerCta!,
                      color: colors.primary,
                      isBold: true,
                    ),
                  ),

                // All columns flattened into a single column
                for (final column in section.columns) ...[
                  if (column.heading != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: BootstrapItaliaSpacing.space2,
                        bottom: BootstrapItaliaSpacing.space2,
                      ),
                      child: Text(
                        column.heading!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.bodyColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ...column.links.map(
                    (link) => _MobileLinkTile(
                      link: link,
                      onOverlayClose: onLinkTap,
                    ),
                  ),
                ],

                // Footer CTA
                if (section.footerCta != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: BootstrapItaliaSpacing.space3,
                    ),
                    child: _CtaLink(
                      cta: section.footerCta!,
                      color: colors.primary,
                      isBold: true,
                    ),
                  ),

                // The bottom and right CTA groups both flatten to the same
                // stack here: `.it-footer-link-wrapper` and its `-vertical`
                // twin differ only in how the desktop panel arranges them, and
                // there is one column to arrange them in on mobile. They keep
                // `#06c` because the body they sit on keeps its light fill in
                // both themes.
                for (final cta in [...section.footerCtas, ...section.sideCtas])
                  Padding(
                    padding: const EdgeInsets.only(
                      top: BootstrapItaliaSpacing.space2,
                    ),
                    child: _CtaLink(cta: cta, color: colors.primary),
                  ),
              ],
            ),
          ),
        ),

        // A 1px rule between mobile section tiles:
        // `.it-heading-link-wrapper { border-color: hsl(210, 4%, 78%) }`.
        //
        // This painted `colors.gray200` (#E6E6E6) instead — a documented
        // substitution, but a substitution: #C5C7C9 is a standalone declaration
        // matching no palette token (it is `--bs-border-color`, and the scheme
        // exposes no border role), so there was nothing for it to re-theme
        // with and the swap only moved it away from the stylesheet. Nothing
        // caught it because the mobile megamenu has no parity capture.
        //
        // Decorative, so it is excluded from semantics rather than announced as
        // a separator (WCAG 1.3.1).
        const ExcludeSemantics(
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: Color(0xFFC5C7C9)),
          ),
        ),
      ],
    );
  }
}

// ── Mobile Link Tile ────────────────────────────────────────────

class _MobileLinkTile extends StatelessWidget {
  final ItMegamenuLink link;
  final VoidCallback onOverlayClose;

  const _MobileLinkTile({
    required this.link,
    required this.onOverlayClose,
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

    return Semantics(
      link: true,
      label: link.label,
      // §2.4.7: ItActivatable owns the focus node and paints the ring.
      //
      // `.link-list-wrapper ul li a:hover span { text-decoration: underline }`
      // with an unchanged, transparent row background in every state.
      child: ItActivatable(
        onPressed: () {
          link.onTap?.call();
          onOverlayClose();
        },
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ItMegamenuTokens.linkVerticalPadding,
              horizontal: BootstrapItaliaSpacing.space1,
            ),
            child: Row(
              children: [
                Icon(
                  link.icon ?? BootstrapItaliaIcons.it_arrow_right,
                  size: 16,
                  color: colors.primary,
                ),
                const SizedBox(width: BootstrapItaliaSpacing.space2),
                Expanded(
                  child: Text(
                    link.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                      decoration: hovered
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
