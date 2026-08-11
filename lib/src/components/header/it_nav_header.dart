import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../a11y/it_activatable.dart';
import '../../a11y/it_icon_action.dart';
import '../../l10n/it_localizations.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';
import 'header_glyphs.dart';

/// A navigation item within [ItNavHeader].
class ItNavItem {
  /// The display label.
  final String label;

  /// Called when tapped.
  ///
  /// There was an `href` field beside this one, never read by anything: the
  /// package does not own a router, so a URL string had nothing to navigate.
  /// Callers wire their own navigation through [onTap].
  final VoidCallback? onTap;

  /// Whether this item is currently active.
  final bool active;

  /// Whether the item is disabled.
  final bool disabled;

  /// Whether the item opens a dropdown (renders a chevron).
  final bool hasDropdown;

  /// Whether the item opens a megamenu panel.
  ///
  /// Implies [hasDropdown] and, matching the kit's `px-lg-2 px-xl-3` toggles,
  /// uses tighter horizontal padding so long megamenu labels still fit.
  final bool megamenu;

  /// Optional icon rendered before the label (mobile menu only).
  final IconData? icon;

  /// Creates a nav item.
  const ItNavItem({
    required this.label,
    this.onTap,
    this.active = false,
    this.disabled = false,
    this.hasDropdown = false,
    this.megamenu = false,
    this.icon,
  });

  /// Whether a chevron should be rendered after the label.
  bool get showsChevron => hasDropdown || megamenu;
}

/// The navigation bar band of a Bootstrap Italia header.
///
/// From the `lg` breakpoint up this renders the horizontal
/// `.it-header-navbar-wrapper` bar; below it collapses to a hamburger menu.
///
/// ```dart
/// ItNavHeader(
///   items: [
///     ItNavItem(label: 'link 1 active', active: true, onTap: () {}),
///     ItNavItem(label: 'Link 2', onTap: () {}),
///     ItNavItem(label: 'Dropdown Menu', hasDropdown: true),
///   ],
/// )
/// ```
class ItNavHeader extends StatefulWidget {
  /// The navigation items.
  final List<ItNavItem> items;

  /// Background color.
  ///
  /// Defaults to the theme's `primary` — `#0066CC` under the standard palette,
  /// but an administration's own scheme retints it. See [build].
  final Color? backgroundColor;

  /// Horizontal inset applied to the item row.
  ///
  /// Defaults to 30px, which aligns the first label with [ItSlimHeader] and
  /// [ItCenterHeader]. Pass 12 for a bar flush with the container gutter.
  final double contentInset;

  /// Creates a Bootstrap Italia navigation header.
  const ItNavHeader({
    super.key,
    required this.items,
    this.backgroundColor,
    this.contentInset = _defaultInset,
  });

  @override
  State<ItNavHeader> createState() => _ItNavHeaderState();
}

/// Default content inset: the `.container-xxl` gutter (12px) plus the
/// `nav.navbar` padding the kit's composed header applies (18px), so the nav
/// band's first label lines up with the slim and center bands above it.
const double _defaultInset = 30;

/// `a.nav-link`: font-size 18px, line-height 28px.
///
/// `.navbar .navbar-collapsable .navbar-nav li.nav-item a.nav-link
///   { font-weight: 400; padding: 13px 24px; color: #fff }` — and on mobile
/// `.it-header-navbar-wrapper.theme-dark-mobile … a.nav-link { color: #fff }`.
/// `#fff` is byte-identical to `--bs-white`, and here it is the on-primary
/// foreground of a band the scheme fills with `primary`: retinting the fill
/// without retinting the label is how a themed header loses its contrast, so
/// the colour is passed in from the scheme rather than baked into the const.
/// [ItMegamenu], which is the same band rendered from the same rules, already
/// resolves `colors.white` this way.
TextStyle _linkStyle(Color color) => TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 18,
      height: 28 / 18,
      fontWeight: FontWeight.w400,
      color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );

class _ItNavHeaderState extends State<ItNavHeader> {
  bool _mobileMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    // `@media (min-width: 992px) { .it-header-navbar-wrapper { background: #06c } }`
    // — `#06c` is byte-identical to `--bs-primary` (`hsl(210, 100%, 40%)`), and
    // the brand band is the accent role that token exists for, so it is resolved
    // from the scheme. Written literally it would keep an administration's
    // header Blu Italia while the rest of its page retinted around it.
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
        final isDesktop = context.isDesktop;

        // §1.3.1 Info and Relationships: this band is the primary navigation
        // landmark. `explicitChildNodes` keeps each nav item a separate node
        // rather than collapsing the whole bar into one label.
        return Semantics(
          container: true,
          explicitChildNodes: true,
          role: SemanticsRole.navigation,
          child: isDesktop
              ? Container(
                  width: double.infinity,
                  color: bgColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: widget.contentInset),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      for (final item in widget.items) _NavLink(item: item),
                    ],
                  ),
                )
              : Container(
                  width: double.infinity,
                  color: bgColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BootstrapItaliaSpacing.space3,
                        ),
                        child: _buildMobileBar(colors),
                      ),
                      if (_mobileMenuOpen) _buildMobileMenu(colors),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMobileBar(BootstrapItaliaColorScheme colors) {
    final current = widget.items.firstWhere(
      (i) => i.active,
      orElse: () => widget.items.first,
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            current.label,
            style:
                _linkStyle(colors.white).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        // `.custom-navbar-toggler { background: none; border: none;
        //   cursor: pointer; padding: 0 }` with a 24px white glyph — no fill in
        // any state, so there is nothing for Material's IconButton to
        // contribute. The tooltip that used to supply the accessible name is
        // replaced by an explicit label (§4.1.2).
        ItIconAction(
          icon: _mobileMenuOpen
              ? BootstrapItaliaIcons.it_close
              : BootstrapItaliaIcons.it_burger,
          color: colors.white,
          label: _mobileMenuOpen
              ? ItLocalizations.of(context).closeMenu
              : ItLocalizations.of(context).openMenu,
          onPressed: () => setState(() => _mobileMenuOpen = !_mobileMenuOpen),
        ),
      ],
    );
  }

  Widget _buildMobileMenu(BootstrapItaliaColorScheme colors) {
    return Container(
      width: double.infinity,
      // `.it-header-navbar-wrapper.theme-dark-mobile .navbar .navbar-collapsable
      //   .menu-wrapper { background: #06c }` — the same `--bs-primary` value the
      // band above it carries, so it follows the scheme for the same reason.
      color: colors.primary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in widget.items)
            Semantics(
              link: true,
              enabled: !item.disabled,
              selected: item.active,
              label: item.label,
              child: ItHoverBuilder(
                enabled: !item.disabled && !item.active,
                // §2.4.7: ItActivatable paints the row's focus ring and owns
                // its focus node, so the ring no longer has to track a
                // descendant to find out when the row is focused.
                //
                // `.navbar.theme-dark-mobile … a.nav-link:hover:not(.active)`
                // only underlines; the row keeps the flat `#06c` panel colour
                // in every state, so it has no fill for an ink surface to paint.
                builder: (context, hovered) => ItActivatable(
                  onPressed: item.disabled
                      ? null
                      : () {
                          setState(() => _mobileMenuOpen = false);
                          item.onTap?.call();
                        },
                  child: ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BootstrapItaliaSpacing.space3,
                        vertical: BootstrapItaliaSpacing.space2 + 4,
                      ),
                      // `.it-header-navbar-wrapper.theme-dark-mobile … li
                      //   a.nav-link.active { border-left-color: #fff }`
                      decoration: item.active
                          ? BoxDecoration(
                              border: Border(
                                left: BorderSide(color: colors.white, width: 3),
                              ),
                            )
                          : null,
                      child: Row(
                        children: [
                          if (item.icon != null) ...[
                            Icon(item.icon, size: 18, color: colors.white),
                            const SizedBox(
                                width: BootstrapItaliaSpacing.space2),
                          ],
                          Text(
                            item.label,
                            style: hovered
                                ? _linkStyle(colors.white).copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: colors.white,
                                  )
                                : _linkStyle(colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final ItNavItem item;

  const _NavLink({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    // §2.4.4 name + role, §1.3.1 active state (painted only as a 3px white
    // underline) and §2.1.1 keyboard operability via ItActivatable.
    //
    // No `expanded` here on purpose: ItNavHeader renders a chevron for
    // `hasDropdown` items but never actually opens a panel, so claiming an
    // expanded/collapsed state would report a control that does not exist.
    // ItMegamenu, which does own that state, exposes it.
    return Semantics(
      link: true,
      enabled: !item.disabled,
      selected: item.active,
      label: item.label,
      child: ItHoverBuilder(
        // `.navbar .navbar-collapsable .navbar-nav li a.nav-link:hover:not(.active)
        //   { text-decoration: underline }` — the label colour stays `#fff` and
        // the active link has no hover state at all (measured on the React kit).
        enabled: !item.disabled && !item.active,
        cursor:
            item.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        builder: (context, hovered) => ItActivatable(
          onPressed: item.disabled ? null : item.onTap,
          child: ExcludeSemantics(
            child: Container(
              // `a.nav-link { padding: 13px 24px }`; megamenu toggles carry
              // `px-xl-3` (16px) so their longer labels stay on one line.
              padding: EdgeInsets.symmetric(
                horizontal: item.megamenu ? 16 : 24,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    // `li.nav-item a.nav-link { border-bottom: 3px solid
                    //   rgba(0,0,0,0) }`, and `a.nav-link.active
                    //   { border-color: #fff }` — the same `--bs-white` the
                    // label carries, so it travels with the scheme too.
                    color: item.active ? colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    item.label,
                    style: hovered
                        ? _linkStyle(colors.white).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: colors.white,
                          )
                        : _linkStyle(colors.white),
                  ),
                  if (item.showsChevron) ...[
                    // The kit's markup separates label and chevron with a space.
                    const SizedBox(width: 4),
                    // `.navbar .navbar-collapsable .navbar-nav li.nav-item
                    //   a.nav-link.dropdown-toggle svg { fill: #fff }` — the
                    // glyph's own default is `#fff` too, stated here so it
                    // tracks the same `--bs-white` the label does.
                    ItExpandChevron(color: colors.white),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
