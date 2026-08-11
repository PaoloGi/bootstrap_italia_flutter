import 'package:flutter/material.dart';

import '../../a11y/it_activatable.dart';
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
    color: Colors.white,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle _linkStyle = TextStyle(
    fontFamily: BootstrapItaliaFontFamily.sansSerif,
    package: BootstrapItaliaFontFamily.package,
    // `a.list-item`: font-size 16px, line-height 32px
    fontSize: 16,
    height: 32 / 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    leadingDistribution: TextLeadingDistribution.even,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _height,
      color: backgroundColor ?? _bg,
      padding: const EdgeInsets.symmetric(horizontal: _inset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(institutionName, style: _brandStyle),
          const Spacer(),
          if (links.isNotEmpty) _buildLinkList(),
          if (dropdownLabel != null) _buildDropdown(),
          if (accessLabel != null) _buildAccessButton(),
        ],
      ),
    );
  }

  Widget _buildLinkList() {
    return Container(
      height: _height,
      // `ul.link-list { padding: 0 24px; margin-right: 16px; border-left/right }`
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: _divider),
          right: BorderSide(color: _divider),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [for (final link in links) _buildLink(link)],
      ),
    );
  }

  Widget _buildLink(ItSlimHeaderLink link) {
    // §2.4.4 link role + name, §2.1.1 keyboard. `selected` carries the active
    // state that is otherwise conveyed only by a 2px white underline — colour
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
                  ? const BoxDecoration(
                      // `a.active { border-bottom: 2px solid #fff }`
                      border: Border(
                        bottom: BorderSide(color: Colors.white, width: 2),
                      ),
                    )
                  : null,
              child: Text(
                link.label,
                style: hovered
                    ? _linkStyle.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      )
                    : _linkStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
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
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          )
                        : _brandStyle,
                  ),
                  // The kit's markup separates label and chevron with a space.
                  const SizedBox(width: 4),
                  ItExpandChevron(expanded: dropdownExpanded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessButton() {
    return Semantics(
      button: true,
      label: accessLabel!,
      child: ItHoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => ItActivatable(
          onPressed: onAccessTap,
          borderRadius: BorderRadius.circular(4),
          child: ExcludeSemantics(
            child: Container(
              // `.btn-sm` padding-x 24px, slim override padding-y 7.5px
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 7.5),
              decoration: BoxDecoration(
                color: hovered ? _accessBgHover : _accessBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                accessLabel!,
                style: const TextStyle(
                  fontFamily: BootstrapItaliaFontFamily.sansSerif,
                  package: BootstrapItaliaFontFamily.package,
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
