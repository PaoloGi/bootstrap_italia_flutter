import 'package:flutter/material.dart';

import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/breakpoints.dart';
import '../../tokens/spacing.dart';
import '../collapse/it_collapse.dart';

// ── Data Models ─────────────────────────────────────────────────

/// A single link within a megamenu column.
class ItMegamenuLink {
  /// The link label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the link is tapped.
  final VoidCallback? onTap;

  /// Optional description text shown below the label.
  final String? description;

  /// Creates a megamenu link.
  const ItMegamenuLink({
    required this.label,
    this.icon,
    this.onTap,
    this.description,
  });
}

/// A column of links within a megamenu section.
class ItMegamenuColumn {
  /// Optional heading displayed above the links.
  final String? heading;

  /// The links in this column.
  final List<ItMegamenuLink> links;

  /// Creates a megamenu column.
  const ItMegamenuColumn({
    this.heading,
    required this.links,
  });
}

/// A call-to-action link in the megamenu header or footer area.
class ItMegamenuCta {
  /// The CTA label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the CTA is tapped.
  final VoidCallback? onTap;

  /// Creates a megamenu CTA.
  const ItMegamenuCta({
    required this.label,
    this.icon,
    this.onTap,
  });
}

/// A top-level section in the megamenu.
///
/// Each section appears as a nav item in the bar. When expanded, it shows
/// its [columns] of links along with optional description, image, and CTAs.
class ItMegamenuSection {
  /// The section label shown in the nav bar.
  final String label;

  /// Optional icon shown beside the label.
  final IconData? icon;

  /// The link columns displayed when this section is open.
  final List<ItMegamenuColumn> columns;

  /// Optional description text shown in the left panel (desktop).
  final String? description;

  /// Optional image widget shown in the left panel (desktop).
  final Widget? image;

  /// Optional header CTA (e.g. "Esplora la sezione").
  final ItMegamenuCta? headerCta;

  /// Optional footer CTA (e.g. "Esplora tutti").
  final ItMegamenuCta? footerCta;

  /// Whether this section is currently active.
  final bool active;

  /// Creates a megamenu section.
  const ItMegamenuSection({
    required this.label,
    this.icon,
    required this.columns,
    this.description,
    this.image,
    this.headerCta,
    this.footerCta,
    this.active = false,
  });
}

// ── Design Tokens ───────────────────────────────────────────────
// From Bootstrap Italia SCSS: _variables.scss megamenu values.

/// Desktop panel top padding: `$megamenu-padding-top-desktop: $v-gap * 4`.
const double _panelPaddingTop = 32.0;

/// Desktop column gap: `$megamenu-column-gap: $v-gap * 3`.
const double _columnGap = 24.0;

/// Heading font size: `$megamenu-heading-text-size: 1.125rem`.
const double _headingFontSize = 18.0;

/// Heading bottom margin: `$megamenu-heading-bottom-margin: 24px`.
const double _headingBottomMargin = 24.0;

/// Link vertical padding: `$megamenu-linklist-link-v-padding: 0.5em`.
const double _linkVerticalPadding = 8.0;

/// Mobile expanded section background:
/// `$color-background-primary-lighter: hsl(210, 62%, 97%)`.
const Color _mobileExpandedBg = Color(0xFFF2F7FC);

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

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              color: bgColor,
              padding: const EdgeInsets.symmetric(
                horizontal: BootstrapItaliaSpacing.space3,
              ),
              child: isMobile
                  ? _buildMobileBar(colors)
                  : _buildDesktopBar(colors),
            ),
            if (!isMobile && _openSectionIndex != null)
              _DesktopPanel(
                section: widget.sections[_openSectionIndex!],
                onClose: () => setState(() => _openSectionIndex = null),
              ),
          ],
        );
      },
    );
  }

  // ── Desktop ─────────────────────────────────────────────────

  Widget _buildDesktopBar(BootstrapItaliaColorScheme colors) {
    return Row(
      children: List.generate(widget.sections.length, (i) {
        final section = widget.sections[i];
        final isOpen = _openSectionIndex == i;

        return _DesktopNavButton(
          label: section.label,
          icon: section.icon,
          isActive: section.active || isOpen,
          onTap: () {
            setState(() {
              _openSectionIndex = isOpen ? null : i;
            });
          },
        );
      }),
    );
  }

  // ── Mobile ──────────────────────────────────────────────────

  Widget _buildMobileBar(BootstrapItaliaColorScheme colors) {
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
        IconButton(
          onPressed: () => _openMobileMenu(context),
          icon: Icon(Icons.menu, color: colors.white),
          tooltip: 'Apri menu',
        ),
      ],
    );
  }

  void _openMobileMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: const Color(0xCC000000), // 80% black
        barrierLabel: 'Chiudi menu',
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
          return _MobileOverlay(
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
  final VoidCallback onTap;

  const _DesktopNavButton({
    required this.label,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return GestureDetector(
      onTap: onTap,
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
            Icon(Icons.expand_more, size: 18, color: colors.white),
          ],
        ),
      ),
    );
  }
}

// ── Desktop Panel ───────────────────────────────────────────────

class _DesktopPanel extends StatelessWidget {
  final ItMegamenuSection section;
  final VoidCallback onClose;

  const _DesktopPanel({
    required this.section,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final hasLeftPanel =
        section.description != null || section.image != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.white,
        // $dialog-shadow: 0 2px 10px 0 rgba(0,0,0,0.1)
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          BootstrapItaliaSpacing.space4,
          _panelPaddingTop,
          BootstrapItaliaSpacing.space4,
          BootstrapItaliaSpacing.space5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header CTA
            if (section.headerCta != null)
              Padding(
                padding: const EdgeInsets.only(bottom: _columnGap),
                child: _CtaLink(
                  cta: section.headerCta!,
                  color: colors.primary,
                  isBold: true,
                ),
              ),

            // Main content row
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left panel: description + image
                  if (hasLeftPanel) ...[
                    SizedBox(
                      width: 280,
                      child: _DescriptionPanel(
                        description: section.description,
                        image: section.image,
                      ),
                    ),
                    const SizedBox(width: _columnGap),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: colors.gray200,
                    ),
                    const SizedBox(width: _columnGap),
                  ],

                  // Link columns
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0;
                            i < section.columns.length;
                            i++) ...[
                          if (i > 0) const SizedBox(width: _columnGap),
                          Expanded(
                            child: _DesktopColumn(
                              column: section.columns[i],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer CTA
            if (section.footerCta != null)
              Padding(
                padding: const EdgeInsets.only(top: _columnGap),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _CtaLink(
                    cta: section.footerCta!,
                    color: colors.primary,
                    isBold: true,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Desktop Column ──────────────────────────────────────────────

class _DesktopColumn extends StatelessWidget {
  final ItMegamenuColumn column;

  const _DesktopColumn({required this.column});

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (column.heading != null) ...[
          Text(
            column.heading!,
            style: TextStyle(
              // $megamenu-heading-text-size: 1.125rem
              fontSize: _headingFontSize,
              // $megamenu-heading-font-weight: 600
              fontWeight: FontWeight.w600,
              color: colors.bodyColor,
            ),
          ),
          const SizedBox(height: _headingBottomMargin),
        ],
        ...column.links.map((link) => _DesktopLinkTile(link: link)),
      ],
    );
  }
}

// ── Desktop Link Tile ───────────────────────────────────────────

class _DesktopLinkTile extends StatelessWidget {
  final ItMegamenuLink link;

  const _DesktopLinkTile({required this.link});

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return InkWell(
      onTap: link.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _linkVerticalPadding),
        child: Row(
          children: [
            Icon(
              link.icon ?? Icons.arrow_right,
              size: 16,
              color: colors.primary,
            ),
            const SizedBox(width: BootstrapItaliaSpacing.space2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.label,
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.primary,
                    ),
                  ),
                  if (link.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        link.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.bodyColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Description Panel ───────────────────────────────────────────

class _DescriptionPanel extends StatelessWidget {
  final String? description;
  final Widget? image;

  const _DescriptionPanel({this.description, this.image});

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (image != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: 21 / 9,
              child: image!,
            ),
          ),
          const SizedBox(height: BootstrapItaliaSpacing.space3),
        ],
        if (description != null)
          Text(
            description!,
            style: TextStyle(
              // $megamenu-vertical-description-font-size: 1rem
              fontSize: 16,
              color: colors.bodyColor,
              height: 1.5,
            ),
          ),
      ],
    );
  }
}

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
    return InkWell(
      onTap: cta.onTap,
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
                fontSize: _headingFontSize,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
            const SizedBox(width: BootstrapItaliaSpacing.space1),
            Icon(Icons.arrow_forward, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

// ── Mobile Overlay ──────────────────────────────────────────────

class _MobileOverlay extends StatefulWidget {
  final List<ItMegamenuSection> sections;
  final bool allowMultipleOpen;

  const _MobileOverlay({
    required this.sections,
    required this.allowMultipleOpen,
  });

  @override
  State<_MobileOverlay> createState() => _MobileOverlayState();
}

class _MobileOverlayState extends State<_MobileOverlay> {
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

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      label: 'Menu di navigazione',
      child: Material(
        color: colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Close button row
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(BootstrapItaliaSpacing.space2),
                  child: Semantics(
                    label: 'Chiudi il menu',
                    button: true,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: colors.bodyColor),
                      tooltip: 'Chiudi il menu',
                    ),
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
    );
  }
}

// ── Mobile Section Tile ─────────────────────────────────────────

class _MobileSectionTile extends StatelessWidget {
  final ItMegamenuSection section;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onLinkTap;

  const _MobileSectionTile({
    required this.section,
    required this.isExpanded,
    required this.onToggle,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header
        InkWell(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: BootstrapItaliaSpacing.space4,
              vertical: BootstrapItaliaSpacing.space3,
            ),
            decoration: section.active
                ? BoxDecoration(
                    border: Border(
                      left: BorderSide(color: colors.primary, width: 3),
                    ),
                  )
                : null,
            child: Row(
              children: [
                if (section.icon != null) ...[
                  Icon(section.icon, size: 20, color: colors.bodyColor),
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
                      color: colors.bodyColor,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    color: colors.bodyColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expandable content
        ItCollapse(
          isExpanded: isExpanded,
          child: Container(
            width: double.infinity,
            color: _mobileExpandedBg,
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
              ],
            ),
          ),
        ),

        Divider(height: 1, thickness: 1, color: colors.gray200),
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
    final colors = resolveColorScheme(context);

    return InkWell(
      onTap: () {
        link.onTap?.call();
        onOverlayClose();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _linkVerticalPadding,
          horizontal: BootstrapItaliaSpacing.space1,
        ),
        child: Row(
          children: [
            Icon(
              link.icon ?? Icons.arrow_right,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
