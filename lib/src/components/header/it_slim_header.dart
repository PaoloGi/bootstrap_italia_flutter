import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';
import 'header_glyphs.dart';

/// A link in the slim header.
class ItSlimHeaderLink {
  /// The link label.
  final String label;

  /// Called when the link is tapped.
  final VoidCallback? onTap;

  /// Whether this link is active.
  final bool active;

  /// Creates a slim header link.
  const ItSlimHeaderLink({
    required this.label,
    this.onTap,
    this.active = false,
  });
}

/// The top-most institutional slim bar of Bootstrap Italia headers.
///
/// Displays the institution name on the left, an optional right-aligned link
/// list, an optional dropdown toggle (typically the language switcher) and an
/// optional access button.
///
/// ```dart
/// ItSlimHeader(
///   institutionName: 'Ente appartenenza',
///   links: [
///     ItSlimHeaderLink(label: 'Link 1'),
///     ItSlimHeaderLink(label: 'Link 2 Active', active: true),
///   ],
///   dropdownLabel: 'ITA',
///   accessLabel: 'Accedi',
/// )
/// ```
class ItSlimHeader extends StatelessWidget {
  /// The institution name displayed on the left.
  final String institutionName;

  /// Optional links displayed to the left of the right zone.
  final List<ItSlimHeaderLink> links;

  /// Optional dropdown toggle label (e.g. the current language).
  final String? dropdownLabel;

  /// Called when the dropdown toggle is tapped.
  final VoidCallback? onDropdownTap;

  /// Whether the dropdown is currently open (flips the chevron).
  final bool dropdownExpanded;

  /// Optional access button label (e.g. `Accedi`).
  final String? accessLabel;

  /// Called when the access button is tapped.
  final VoidCallback? onAccessTap;

  /// Background color. Defaults to `hsl(210,100%,35%)`.
  final Color? backgroundColor;

  /// The `.theme-light` band: white ground with primary-coloured content.
  ///
  /// `.it-header-slim-wrapper.theme-light { background: #fff;
  ///   border-bottom: 1px solid rgba(0,102,204,.2) }` with
  /// `… .it-header-slim-wrapper-content a { color: #06c }` and
  /// `… .navbar-brand { color: #06c }`.
  ///
  /// Unlike the default band, this variant *does* re-theme. `#fff` and `#06c`
  /// are `--bs-white` and `--bs-primary` byte for byte, and here they are in
  /// exactly the roles those tokens name — a neutral surface carrying brand
  /// accent content, the same pairing [ItCenterHeader.light] already resolves
  /// from the scheme. The default band's `hsl(210,100%,35%)` matches no token
  /// at all, which is why it stays a literal.
  final bool light;

  /// The `.btn-full` access button: stretched to the full height of the band,
  /// with square corners.
  ///
  /// `.btn-full { border-radius: 0; align-self: stretch; … }` and, from `lg`
  /// up, `{ padding: 12px 24px !important; margin: 0; flex: 1;
  ///   display: flex; justify-content: center; align-items: center }`.
  ///
  /// The docs call this *"full-responsive"*: on a narrow band it is what keeps
  /// the action reachable, because a pill floating in a 48px bar has nowhere
  /// left to go.
  final bool accessButtonFull;

  /// Creates a Bootstrap Italia slim header.
  const ItSlimHeader({
    super.key,
    required this.institutionName,
    this.links = const [],
    this.dropdownLabel,
    this.onDropdownTap,
    this.dropdownExpanded = false,
    this.accessLabel,
    this.onAccessTap,
    this.backgroundColor,
    this.light = false,
    this.accessButtonFull = false,
  });

  // ── `.it-header-slim-wrapper` ────────────────────────────────────
  /// `background: hsl(210,100%,35%)`
  static const Color _bg = Color(0xFF0059B3);

  /// `.it-header-slim-right-zone button { background: hsl(210,100%,25%) }`
  static const Color _accessBg = Color(0xFF004080);

  /// `.it-header-slim-wrapper-content .it-header-slim-right-zone button:hover
  ///   { background: rgb(0, 76.5, 153) }` — rasterised as `rgb(0, 77, 153)`.
  static const Color _accessBgHover = Color(0xFF004D99);

  /// `ul.link-list { border-left/right: 1px solid hsla(0,0%,100%,.2) }`
  static const Color _divider = Color(0x33FFFFFF);

  /// `@media (min-width: 992px) { .it-header-slim-wrapper { height: 48px } }`
  static const double _height = 48;

  /// `.container-xxl` gutter (12px) plus
  /// `.it-header-slim-wrapper-content { padding: 0 18px }`.
  static const double _inset = 30;

  static const TextStyle _brandStyle = TextStyle(
    fontFamily: BootstrapItaliaFontFamily.sansSerif,
    package: BootstrapItaliaFontFamily.package,
    // `.navbar-brand { font-size: .875rem }`, line-height 21px
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFFFFFFF),
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle _linkStyle = TextStyle(
    fontFamily: BootstrapItaliaFontFamily.sansSerif,
    package: BootstrapItaliaFontFamily.package,
    // `a.list-item`: font-size 16px, line-height 32px
    fontSize: 16,
    height: 32 / 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFFFFFFFF),
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// `.it-header-slim-wrapper.theme-light { border-bottom: 1px solid
  ///   rgba(0,102,204,.2) }`, and the same value on the link list's side rules.
  ///
  /// Derived rather than declared: `rgba(0,102,204,.2)` is `--bs-primary` at
  /// 20% alpha, so it has to follow a retinted primary or the rule that draws
  /// the band's only edge stops matching the content inside it.
  static Color _lightRule(Color primary) => primary.withValues(alpha: 0.2);

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    // `.theme-light { background: #fff }` with `… a { color: #06c }`; the
    // default band is the literal `hsl(210,100%,35%)` with white content.
    final fg = light ? colors.primary : const Color(0xFFFFFFFF);
    final bandBg = backgroundColor ?? (light ? colors.white : _bg);
    final rule = light ? _lightRule(colors.primary) : _divider;

    return Container(
      width: double.infinity,
      height: _height,
      // `color:` on the default band rather than an equivalent `decoration:`.
      // Only the light band draws an edge — on the dark one there is nothing
      // beneath it light enough for a rule to separate — and a Container
      // rejects both arguments at once, so the choice is between two shapes.
      // Keeping the default one exactly as it was is what leaves
      // `nav_header_slim.png` and the callers that read `Container.color`
      // untouched by an additive flag.
      color: light ? null : bandBg,
      decoration: light
          ? BoxDecoration(
              color: bandBg,
              border:
                  Border(bottom: BorderSide(color: _lightRule(colors.primary))),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: _inset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(institutionName, style: _brandStyle.copyWith(color: fg)),
          const Spacer(),
          if (links.isNotEmpty) _buildLinkList(fg, rule),
          if (dropdownLabel != null) _buildDropdown(fg),
          if (accessLabel != null) _buildAccessButton(colors),
        ],
      ),
    );
  }

  Widget _buildLinkList(Color fg, Color rule) {
    return Container(
      height: _height,
      // `ul.link-list { padding: 0 24px; margin-right: 16px; border-left/right }`
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: rule),
          right: BorderSide(color: rule),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [for (final link in links) _buildLink(link, fg)],
      ),
    );
  }

  Widget _buildLink(ItSlimHeaderLink link, Color fg) {
    // §2.4.4 link role + name, §2.1.1 keyboard. `selected` carries the active
    // state that is otherwise conveyed only by a 2px underline — colour
    // and shape alone are not programmatically determinable (§1.3.1).
    return Semantics(
      link: true,
      selected: link.active,
      label: link.label,
      child: ItHoverBuilder(
        // `.it-header-slim-wrapper-content a:hover:not(.active)
        //   { text-decoration: underline }` — the colour never changes, and the
        // active link is explicitly excluded.
        enabled: !link.active,
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => ItActivatable(
          onPressed: link.onTap,
          child: ExcludeSemantics(
            child: Container(
              height: _height,
              // `a.list-item { padding: 7px 24px }`
              padding: const EdgeInsets.fromLTRB(24, 7, 24, 0),
              alignment: Alignment.topCenter,
              decoration: link.active
                  ? BoxDecoration(
                      // `a.active { border-bottom: 2px solid #fff }`, and under
                      // `.theme-light` `a.list-item.active { color: #06c;
                      //   border-bottom: 2px solid #06c }` — the rule always
                      // matches the label it underlines.
                      border: Border(
                        bottom: BorderSide(color: fg, width: 2),
                      ),
                    )
                  : null,
              child: Text(
                link.label,
                style: hovered
                    ? _linkStyle.copyWith(
                        color: fg,
                        decoration: TextDecoration.underline,
                        decorationColor: fg,
                      )
                    : _linkStyle.copyWith(color: fg),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(Color fg) {
    // §4.1.2 Name, Role, Value: the toggle's open/closed state is painted as a
    // flipped chevron only. `expanded` is the aria-expanded equivalent, without
    // which a screen-reader user cannot tell whether the menu is open.
    return Semantics(
      button: true,
      expanded: dropdownExpanded,
      label: dropdownLabel!.toUpperCase(),
      child: ItHoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => ItActivatable(
          onPressed: onDropdownTap,
          child: ExcludeSemantics(
            child: Padding(
              // `a.dropdown-toggle { padding: 12px 16px }`
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    // `a.dropdown-toggle { text-transform: uppercase }`
                    dropdownLabel!.toUpperCase(),
                    // `.it-header-slim-wrapper-content a:hover:not(.active)
                    //   { text-decoration: underline }`
                    style: hovered
                        ? _brandStyle.copyWith(
                            color: fg,
                            decoration: TextDecoration.underline,
                            decorationColor: fg,
                          )
                        : _brandStyle.copyWith(color: fg),
                  ),
                  // The kit's markup separates label and chevron with a space.
                  const SizedBox(width: 4),
                  // `.theme-light … a .icon { fill: #06c }`; the default band's
                  // glyph is the same white as its label.
                  ItExpandChevron(expanded: dropdownExpanded, color: fg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessButton(BootstrapItaliaColorScheme colors) {
    // `.theme-light … .it-header-slim-right-zone .btn
    //   { background: #06c; color: #fff }`, and `…:hover { background: #06c }`
    // — the light story's button does not move on hover at all, which is why
    // the hover fill below is only computed for the default band.
    final Color buttonBg = light ? colors.primary : _accessBg;
    final Color buttonHoverBg = light ? colors.primary : _accessBgHover;
    final Color buttonFg = light ? colors.white : const Color(0xFFFFFFFF);
    final radius = accessButtonFull
        // `.btn-full { border-radius: 0 }`
        ? BorderRadius.zero
        : BorderRadius.circular(4);

    final button = Semantics(
      button: true,
      label: accessLabel!,
      child: ItHoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => ItActivatable(
          onPressed: onAccessTap,
          borderRadius: radius,
          child: ExcludeSemantics(
            child: Container(
              // `.btn-sm` padding-x 24px, slim override padding-y 7.5px; the
              // `.btn-full` modifier restates it as `padding: 12px 24px` and
              // stretches the box to the band's height instead.
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: accessButtonFull ? 12 : 7.5,
              ),
              alignment: accessButtonFull ? Alignment.center : null,
              decoration: BoxDecoration(
                color: hovered ? buttonHoverBg : buttonBg,
                borderRadius: radius,
              ),
              child: Text(
                accessLabel!,
                style: TextStyle(
                  fontFamily: BootstrapItaliaFontFamily.sansSerif,
                  package: BootstrapItaliaFontFamily.package,
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w600,
                  color: buttonFg,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // `.btn-full { align-self: stretch }`, plus the negative margins that
    // cancel the band's own vertical padding — the button reaches both edges
    // of the 48px bar rather than sitting inside it.
    return accessButtonFull ? SizedBox(height: _height, child: button) : button;
  }
}
