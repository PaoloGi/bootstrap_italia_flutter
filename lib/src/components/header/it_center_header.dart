import 'package:flutter/widgets.dart';

import '../../l10n/it_localizations.dart';
import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/breakpoints.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';
import '../social_link/it_social_link.dart';
import 'header_glyphs.dart';

/// The center (branding) band of a Bootstrap Italia header.
///
/// Displays the logo, site title and tag line on the left, with optional
/// social links and a search affordance on the right.
///
/// ```dart
/// ItCenterHeader(
///   logo: Icon(BootstrapItaliaIcons.it_code_circle, size: 82),
///   title: 'Lorem Ipsum Lorem Ipsum',
///   subtitle: 'Inserire qui la tag line',
///   socialLinks: [
///     ItSocialLink(icon: BootstrapItaliaIcons.it_facebook, label: 'Facebook'),
///   ],
///   showSearch: true,
///   onSearchTap: () {},
/// )
/// ```
class ItCenterHeader extends StatelessWidget {
  /// The logo widget, laid out in an 82x82 box (48x48 when [small]).
  final Widget? logo;

  /// The main site title.
  final String title;

  /// Optional tag line rendered beneath the title.
  final String? subtitle;

  /// Social media links.
  final List<ItSocialLink> socialLinks;

  /// Label rendered before the social icons.
  ///
  /// Defaults to `'Seguici su'`, with no
  /// installed.
  final String? socialsLabel;

  /// Whether to show the search affordance.
  final bool showSearch;

  /// Label rendered before the search button, and the button's own accessible
  /// name — the two must be the same string, or WCAG 2.5.3 Label in Name fails.
  ///
  /// Defaults to `'Cerca'`, with no
  /// installed.
  final String? searchLabel;

  /// Called when the search button is tapped.
  final VoidCallback? onSearchTap;

  /// Glyph replacing the built-in Bootstrap Italia `it-search` magnifier.
  final IconData? searchIcon;

  /// The `.it-small-header` variant: a shorter band with smaller headings.
  final bool small;

  /// The `.theme-light` variant: white background with blue content.
  final bool light;

  /// Background color override.
  final Color? backgroundColor;

  /// Creates a Bootstrap Italia center header.
  const ItCenterHeader({
    super.key,
    this.logo,
    required this.title,
    this.subtitle,
    this.socialLinks = const [],
    this.socialsLabel,
    this.showSearch = false,
    this.searchLabel,
    this.onSearchTap,
    this.searchIcon,
    this.small = false,
    this.light = false,
    this.backgroundColor,
  });

  /// `.it-header-center-content-wrapper .it-right-zone .it-socials ul a:hover
  ///   svg { fill: hsl(0, 0%, 95%) }` — and the same value for
  /// `.it-search-wrapper a.rounded-icon:hover { background }`.
  ///
  /// Stays a literal: `hsl(0, 0%, 95%)` is declared in its own right and
  /// matches no token in the palette — the nearest, `--bs-gray-100`, is
  /// `hsl(0, 0%, 96%)`. Routing it through the scheme would retint a near-white
  /// that Bootstrap Italia does not retint either.
  static const Color _hoverTintDark = Color(0xFFF2F2F2);

  /// The `.theme-light` counterparts:
  /// `…a:hover svg { fill: rgb(0, 96.9, 193.8) }` and
  /// `…a.rounded-icon:hover { background: rgb(0, 96.9, 193.8) }`, rasterised
  /// as `rgb(0, 97, 194)`.
  ///
  /// Those fractional channels are exactly 95% of `--bs-primary`
  /// (`102 x .95 = 96.9`, `204 x .95 = 193.8`), i.e. Sass emitted a *computed*
  /// colour rather than a declared one — so it is `shade-color($primary, 5%)`
  /// and has to follow a retinted primary.
  static Color _hoverTintLight(BootstrapItaliaColorScheme colors) =>
      itShade(colors.primary, 0.05);

  /// `.container-xxl` gutter (12px) plus the content wrapper's `18px`.
  static const double _inset = 30;

  /// The band's height, which depends on the viewport.
  ///
  /// `.it-header-center-wrapper { height: 80px }` is the **base** rule; the
  /// 120px is inside `@media (min-width: 992px)`, and `.it-small-header`'s
  /// 104px is a modifier on top of the desktop band.
  ///
  /// This used to return the desktop number unconditionally, which meant a
  /// phone got the desktop header in a phone-width box: an 82px logo and a
  /// 28px title in 120px, overflowing by 19px at 390 and 360. Below `lg` the
  /// component now renders the layout the stylesheet actually specifies there.
  double _height(bool desktop) => desktop ? (small ? 104 : 120) : 80;

  /// `.it-header-center-wrapper { padding-top: 6px }` at `lg` and up.
  static const double _paddingTop = 6;

  /// `.it-brand-wrapper a .icon`: 48px in the base rule, 82px from `lg` up.
  double _logoSize(bool desktop) => desktop ? 82 : 48;

  /// `.icon { margin-right: 8px }`, 16px from `lg` up.
  double _logoGap(bool desktop) => desktop ? 16 : 8;

  /// `.it-header-center-wrapper { background: #06c }` with
  /// `….it-right-zone { color: #fff }`, and under `.theme-light`
  /// `{ background: #fff }` with `….it-right-zone { color: #06c }`.
  ///
  /// Both are byte-identical to declared tokens — `#06c` to `--bs-primary`
  /// (`hsl(210, 100%, 40%)`) and `#fff` to `--bs-white` — and the band is the
  /// brand accent itself, so this is precisely the role the tokens name.
  Color _fg(BootstrapItaliaColorScheme colors) =>
      light ? colors.primary : colors.white;

  Color _bg(BootstrapItaliaColorScheme colors) =>
      light ? colors.white : colors.primary;

  TextStyle _titleStyle(Color fg, bool desktop) => TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        // `h2 { font-size: 1.25rem }` in the base rule, `1.75rem` from `lg`
        // up, and `1.25rem` again under `.it-small-header`.
        fontSize: (desktop && !small) ? 28 : 20,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: fg,
        leadingDistribution: TextLeadingDistribution.even,
      );

  TextStyle _taglineStyle(Color fg, bool desktop) => TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        // `h3 { font-size: .875rem; font-weight: normal }` (`.75rem` small),
        // inheriting the base `h3` line-height of 40px. The tagline does not
        // change size at the breakpoint — only the title and the logo do.
        fontSize: small ? 12 : 14,
        height: small ? 40 / 12 : 40 / 14,
        fontWeight: FontWeight.w400,
        color: fg,
        leadingDistribution: TextLeadingDistribution.even,
      );

  TextStyle _labelStyle(Color fg) => TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        // `.it-socials`/`.it-search-wrapper { font-size: .875rem }`
        fontSize: 14,
        height: 21 / 14,
        fontWeight: FontWeight.w400,
        color: fg,
        leadingDistribution: TextLeadingDistribution.even,
      );

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    // The viewport, not the container — see breakpoint_semantics_test.dart.
    // `.it-header-center-wrapper`'s 120px band, 82px logo and 1.75rem title
    // all live inside `@media (min-width: 992px)`; the base rule is an 80px
    // band with a 48px logo and a 1.25rem title.
    final width =
        MediaQuery.maybeSizeOf(context)?.width ?? ItBreakpoint.lg.minWidth;
    final desktop = width >= ItBreakpoint.lg.minWidth;
    return Container(
      width: double.infinity,
      // WCAG 1.4.4: the band grows with the text it contains.
      // `.it-header-center-wrapper` is 120px (104 small), and pinning that
      // flat meant the band could not grow: at iOS's `accessibility-large`
      // (194%, inside the range the criterion requires) the tag line was cut
      // off by the bottom edge and Flutter painted an overflow stripe across
      // it. Verified on an iPhone 16 simulator, 16 August 2026.
      //
      // `minHeight` was tried first and is NOT equivalent: releasing the exact
      // height let the band size to its child, and `nav_header_center` fell
      // from 100% to 66.6% against the React kit. Scaling is parity-safe by
      // construction — at the default text scale this resolves to exactly
      // 120/104, which is the scale the parity captures are taken at.
      // Fixed at `lg` and up, a floor below it.
      //
      // `minHeight` was tried for the desktop band once and is NOT equivalent
      // there: releasing the exact height let it size to its child and
      // `nav_header_center` fell from 100% to 66.6% against the React kit. But
      // below `lg` nothing is captured — every parity reference is taken at
      // desktop width — and a pinned band cannot hold a title that wraps: at
      // 360px "Bootstrap Italia Flutter" takes two lines and overflowed the
      // 80px band by 32px. CSS overflows a fixed-height flex box silently;
      // Flutter reports it, which is the better behaviour but still a defect.
      height: desktop
          ? MediaQuery.textScalerOf(context).scale(_height(desktop))
          : null,
      constraints: desktop
          ? null
          : BoxConstraints(
              minHeight:
                  MediaQuery.textScalerOf(context).scale(_height(desktop)),
            ),
      color: backgroundColor ?? _bg(colors),
      padding: const EdgeInsets.only(top: _paddingTop),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _inset),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // The brand block is the one that gives. `.it-brand-text` is a
              // flex item with no `flex-shrink: 0`, so a long institution name
              // shrinks and wraps rather than pushing the search button off the
              // band — which is what the docs' own
              // "Nome dell'Istituzione" / three socials / search combination
              // did here at container width. Loose fit, so a name that fits
              // is laid out exactly where it was.
              Flexible(child: _buildBrand(colors, desktop)),
              _buildRightZone(context, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrand(BootstrapItaliaColorScheme colors, bool desktop) {
    final fg = _fg(colors);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (logo != null)
          Padding(
            // `.icon { margin-right: 8px }`, 16px from `lg` up.
            padding: EdgeInsets.only(right: _logoGap(desktop)),
            child: SizedBox(
              width: _logoSize(desktop),
              height: _logoSize(desktop),
              child: IconTheme.merge(
                data: IconThemeData(color: fg, size: _logoSize(desktop)),
                child: logo!,
              ),
            ),
          ),
        Flexible(
          child: Padding(
            // `.it-brand-text { padding-right: 24px }`
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // §1.3.1: the kit renders the site title as <h2> and the tag
                // line as <h3>. Exposing the levels gives AT a real outline to
                // navigate instead of two anonymous runs of text.
                Semantics(
                  header: true,
                  headingLevel: 2,
                  child: Text(title, style: _titleStyle(fg, desktop)),
                ),
                if (subtitle != null) ...[
                  // `.it-small-header h3 { margin-top: 4px }`
                  if (small) const SizedBox(height: 4),
                  Semantics(
                    header: true,
                    headingLevel: 3,
                    child: Text(subtitle!, style: _taglineStyle(fg, desktop)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightZone(
      BuildContext context, BootstrapItaliaColorScheme colors) {
    final fg = _fg(colors);
    final hoverTint = light ? _hoverTintLight(colors) : _hoverTintDark;
    final l10n = ItLocalizations.of(context);
    // Resolved once: the visible text and the button's accessible name are the
    // same string by contract (WCAG 2.5.3 Label in Name), and two separate
    // lookups is one edit away from them drifting apart.
    final effectiveSearchLabel = searchLabel ?? l10n.search;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (socialLinks.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(socialsLabel ?? l10n.followUs, style: _labelStyle(fg)),
              // Icon-only navigation: `social.label` is the sole accessible
              // name (§2.4.4). Hit target is 40x24 including the 16px lead-in,
              // meeting §2.5.8 without resizing the 24px glyph.
              for (final social in socialLinks)
                Semantics(
                  label: social.label,
                  link: true,
                  child: ItHoverBuilder(
                    cursor: SystemMouseCursors.click,
                    builder: (context, hovered) => ItActivatable(
                      onPressed: social.onTap,
                      child: ExcludeSemantics(
                        child: Padding(
                          // `.it-socials ul .icon { margin-left: 16px }`
                          padding: const EdgeInsets.only(left: 16),
                          child: Icon(
                            social.icon,
                            size: 24,
                            color: hovered ? hoverTint : fg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        if (showSearch)
          Padding(
            // `.it-search-wrapper { margin-left: 80px }`
            padding: const EdgeInsets.only(left: 80),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // The adjacent text repeats the button's own name, so hide it
                // from AT to avoid announcing "Cerca Cerca" (§4.1.2).
                ExcludeSemantics(
                    child: Text(effectiveSearchLabel, style: _labelStyle(fg))),
                Semantics(
                  label: effectiveSearchLabel,
                  button: true,
                  child: ItHoverBuilder(
                    cursor: SystemMouseCursors.click,
                    builder: (context, hovered) => ItActivatable(
                      onPressed: onSearchTap,
                      borderRadius: BorderRadius.circular(24),
                      child: ExcludeSemantics(
                        child: Container(
                          // `a.rounded-icon { width: 48px; height: 48px;
                          //   border-radius: 24px; background: #fff;
                          //   margin-left: 16px }`
                          margin: const EdgeInsets.only(left: 16),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            // `.it-search-wrapper a.rounded-icon:hover
                            //   { background: hsl(0,0%,95%) }` — a *specific*
                            // near-white, not a translucent white overlay.
                            color: hovered ? hoverTint : _fg(colors),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          // The circle and the glyph swap roles between themes:
                          // `a.rounded-icon { background: #fff }` with a `#06c`
                          // glyph by default, and `.theme-light …a
                          // { background: #06c }` with `svg { fill: #fff }`.
                          child: searchIcon != null
                              ? Icon(
                                  searchIcon,
                                  size: 24,
                                  color: _bg(colors),
                                )
                              : ItSearchGlyph(color: _bg(colors)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
