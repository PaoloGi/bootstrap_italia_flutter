// The desktop dropdown panel — everything Bootstrap Italia renders inside
// `li.megamenu > .dropdown-menu`: the heading CTA, the optional description
// column and its rule, the link columns, and the footer CTA.
//
// Its own file because it is the only part of the megamenu that is separately
// public. [ItMegamenuPanel] can be placed in a custom overlay or tested on its
// own, so the widgets and the metrics behind it form a unit that does not
// depend on the bar's open/closed state at all — it renders one section and
// nothing else. Its measurements are also of a different kind from the SCSS
// tokens in `it_megamenu_tokens.dart`: they were read off the compiled
// stylesheet at the `lg` breakpoint, they are used nowhere but here, and they
// stay private so that exporting this file cannot leak them.

import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../header/header_glyphs.dart';
import 'it_megamenu_models.dart';
import 'it_megamenu_tokens.dart';

// ── Desktop Panel ───────────────────────────────────────────────

// Bootstrap Italia `.dropdown-menu` inside `li.megamenu`, measured from the
// compiled kit at the `lg` breakpoint.

/// `.dropdown-menu { padding: 32px 24px }`
const double _panelPaddingY = 32;
const double _panelPaddingX = 24;

/// `.row { margin: 0 -12px }` + `.col { padding: 0 12px }` between columns.
const double _panelColumnGap = 24;

/// `a.it-heading-link { font-size: 1.125rem; font-weight: 600;
/// line-height: 1.2; color: #06c }`, preceded by a 32px sprite.
const double _headingLinkFontSize = 18;
const double _headingLinkIconSize = 32;

/// `a.dropdown-item.list-item { padding: 12px 24px; line-height: 28px;
/// color: hsl(210,54%,20%) }` with a 16px sprite and an 8px gap.
const double _panelItemPaddingX = 24;
const double _panelItemPaddingY = 12;
const double _panelItemLineHeight = 28;
const double _panelItemIconSize = 16;
const double _panelIconGap = 8;

/// `.it-heading-link-wrapper` / `.it-footer-link-wrapper`
/// `{ margin/padding: 24px; border: 1px solid hsl(210,4%,78%) }`
///
/// The colour stays a literal. `hsl(210,4%,78%)` is declared as
/// `--bs-border-color` (and `--bs-card-border-color`), so it *is* a named value
/// upstream — but it is a border neutral, not one of the semantic accents, and
/// [BootstrapItaliaColorScheme] deliberately exposes no `borderColor` slot.
/// Resolving it to any of the greys the scheme does carry would be inventing a
/// derivation the stylesheet does not make: `--bs-gray-300` is `hsl(0,0%,83%)`,
/// a different colour.
const double _panelDividerSpacing = 24;
const Color _panelDividerColor = Color(0xFFC5C7C9);

TextStyle _panelStyle({
  required double size,
  required double lineHeight,
  required Color color,
  FontWeight weight = FontWeight.w400,
  bool underline = false,
}) {
  return TextStyle(
    fontFamily: BootstrapItaliaFontFamily.sansSerif,
    package: BootstrapItaliaFontFamily.package,
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
    color: color,
    decoration: underline ? TextDecoration.underline : TextDecoration.none,
    decorationColor: color,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

/// The expanded megamenu panel (`li.megamenu > .dropdown-menu`).
///
/// Rendered by [ItMegamenu] when a section is open; public so it can be
/// placed inside a custom overlay or tested on its own.
class ItMegamenuPanel extends StatelessWidget {
  /// The section whose content is displayed.
  final ItMegamenuSection section;

  /// Creates a megamenu panel.
  const ItMegamenuPanel({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final hasLeftPanel = section.description != null || section.image != null;
    final colors = resolveColorScheme(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // `.dropdown-menu { background-color: var(--bs-dropdown-bg) }` with
        // `--bs-dropdown-bg: hsl(0, 0%, 100%)` — the panel surface is the white
        // token by name, so it follows a retinted `white`.
        color: colors.white,
        // `.dropdown-menu { border-radius: 0 0 4px 4px }`
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
        // `box-shadow: rgba(0,0,0,.1) 0 3px 15px 0` — an `rgba()` stated in its
        // own right, matching no token; a drop shadow is not a palette colour.
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _panelPaddingY,
          horizontal: _panelPaddingX,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (section.headerCta != null) _buildHeadingLink(colors),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasLeftPanel) ...[
                    SizedBox(
                      width: 280,
                      child: _DescriptionPanel(
                        description: section.description,
                        image: section.image,
                      ),
                    ),
                    const SizedBox(width: _panelColumnGap),
                    // Was a Material `VerticalDivider(width: 1, thickness: 1)`.
                    // Expanded rather than swapped for a ColoredBox, because
                    // the two are not interchangeable here: a childless
                    // `Container` grows to its maximum constraint — which under
                    // the enclosing `IntrinsicHeight` is the row's full height —
                    // whereas a childless `ColoredBox` collapses to zero under
                    // the same loose constraints and would silently vanish.
                    SizedBox(
                      width: 1,
                      child: Center(
                        child: Container(width: 1, color: _panelDividerColor),
                      ),
                    ),
                    const SizedBox(width: _panelColumnGap),
                  ],
                  for (var i = 0; i < section.columns.length; i++) ...[
                    if (i > 0) const SizedBox(width: _panelColumnGap),
                    Expanded(
                      child: _DesktopColumn(column: section.columns[i]),
                    ),
                  ],
                ],
              ),
            ),
            if (section.footerCta != null) _buildFooterLink(colors),
          ],
        ),
      ),
    );
  }

  /// `.it-heading-link-wrapper { padding-bottom: 24px; margin-bottom: 24px;
  /// border-bottom: 1px solid }`
  ///
  /// `.navbar .dropdown-menu a.it-heading-link { color: #06c }` — byte-identical
  /// to `--bs-primary` (`hsl(210, 100%, 40%)`) and to `--bs-link-color`, in the
  /// link-accent role those tokens name, so it follows a retinted primary.
  Widget _buildHeadingLink(BootstrapItaliaColorScheme colors) {
    final cta = section.headerCta!;
    return Padding(
      padding: const EdgeInsets.only(bottom: _panelDividerSpacing),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: _panelDividerSpacing),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _panelDividerColor)),
        ),
        child: Semantics(
          link: true,
          label: cta.label,
          child: ItActivatable(
            onPressed: cta.onTap,
            child: ExcludeSemantics(
              child: SizedBox(
                // The 32px sprite carries `margin-bottom: 4px`.
                height: _headingLinkIconSize + 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: _headingLinkIconSize,
                      child: cta.icon != null
                          ? Icon(
                              cta.icon,
                              size: _headingLinkIconSize,
                              color: colors.primary,
                            )
                          : ItArrowRightTriangle(
                              size: _headingLinkIconSize,
                              color: colors.primary,
                            ),
                    ),
                    const SizedBox(width: _panelIconGap),
                    SizedBox(
                      height: _headingLinkIconSize,
                      child: Center(
                        child: Text(
                          cta.label,
                          style: _panelStyle(
                            size: _headingLinkFontSize,
                            lineHeight: _headingLinkFontSize * 1.2,
                            weight: FontWeight.w600,
                            color: colors.primary,
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

  /// `.it-footer-link-wrapper { margin-top: 24px; padding-top: 24px;
  /// border-top: 1px solid; text-align: right }`
  ///
  /// Shares `a.it-heading-link`'s `color: #06c` declaration — the same
  /// `--bs-primary` link accent.
  Widget _buildFooterLink(BootstrapItaliaColorScheme colors) {
    final cta = section.footerCta!;
    return Padding(
      padding: const EdgeInsets.only(top: _panelDividerSpacing),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: _panelDividerSpacing),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: _panelDividerColor)),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Semantics(
            link: true,
            label: cta.label,
            child: ItActivatable(
              onPressed: cta.onTap,
              child: ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      cta.label,
                      style: _panelStyle(
                        size: 16,
                        lineHeight: _panelItemLineHeight,
                        color: colors.primary,
                        underline: true,
                      ),
                    ),
                    const SizedBox(width: _panelIconGap),
                    Icon(
                      cta.icon ?? BootstrapItaliaIcons.it_arrow_right,
                      size: 24,
                      color: colors.primary,
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

// ── Desktop Column ──────────────────────────────────────────────

class _DesktopColumn extends StatelessWidget {
  final ItMegamenuColumn column;

  const _DesktopColumn({required this.column});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (column.heading != null)
          Padding(
            padding: const EdgeInsets.only(
              bottom: ItMegamenuTokens.headingBottomMargin,
            ),
            // §1.3.1: each column heading labels the group of links beneath
            // it, so it must be a real heading rather than styled text.
            child: Semantics(
              header: true,
              headingLevel: 3,
              child: Text(
                column.heading!,
                style: _panelStyle(
                  // `.link-list-wrapper .link-list-heading { color:
                  // hsl(0,0%,10%); font-size: 1.125rem; font-weight: 600 }`
                  // ($megamenu-heading-text-size). That value is declared as
                  // `--bs-body-color`, and a column heading on the white panel
                  // is exactly the default foreground, so it tracks the token.
                  size: ItMegamenuTokens.headingFontSize,
                  lineHeight: ItMegamenuTokens.headingFontSize * 1.2,
                  weight: FontWeight.w600,
                  color: resolveColorScheme(context).bodyColor,
                ),
              ),
            ),
          ),
        for (final link in column.links) _DesktopLinkTile(link: link),
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
    // `.dropdown-item { color: var(--bs-dropdown-link-color) }` with
    // `--bs-dropdown-link-color: hsl(210, 54%, 20%)` — the megamenu panel *is*
    // a `.dropdown-menu`, and that value is declared as `--bs-dark`, so the
    // item colour is the dark token reached through the dropdown's own
    // variable rather than a standalone navy.
    final itemColor = resolveColorScheme(context).dark;

    // One node per link carrying label + description, so AT announces a single
    // coherent link instead of two adjacent text runs (§2.4.4, §4.1.2).
    return Semantics(
      link: true,
      label: link.description == null
          ? link.label
          : '${link.label}. ${link.description}',
      child: ItActivatable(
        onPressed: link.onTap,
        child: ExcludeSemantics(
          child: Padding(
            // `a.dropdown-item.list-item { padding: 12px 24px }`
            padding: const EdgeInsets.symmetric(
              horizontal: _panelItemPaddingX,
              vertical: _panelItemPaddingY,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: _panelItemLineHeight,
                  child: Center(
                    child: link.icon != null
                        ? Icon(
                            link.icon,
                            size: _panelItemIconSize,
                            color: itemColor,
                          )
                        : ItArrowRightTriangle(
                            size: _panelItemIconSize,
                            color: itemColor,
                          ),
                  ),
                ),
                const SizedBox(width: _panelIconGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        link.label,
                        style: _panelStyle(
                          size: 16,
                          lineHeight: _panelItemLineHeight,
                          color: itemColor,
                        ),
                      ),
                      if (link.description != null)
                        Text(
                          link.description!,
                          style: _panelStyle(
                            size: 14,
                            lineHeight: 21,
                            // `.link-list-wrapper ul li a p { font-size: .875rem;
                            // color: hsl(210, 33%, 28%) }` — #30475F, the same
                            // value `ItList` already renders for this rule as
                            // `_ListTokens.subtitleColor`. This call site had
                            // #1A1A1A, which is `--bs-body-color`, a full step
                            // darker. #30475F matches no palette token, so it
                            // stays a literal. Only the megamenu *heading* is
                            // captured for parity, which is why the description
                            // was never compared against the kit.
                            color: const Color(0xFF30475F),
                          ),
                        ),
                    ],
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
