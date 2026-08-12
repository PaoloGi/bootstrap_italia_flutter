import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/semantics.dart';

import '../../l10n/it_localizations.dart';
import '../../a11y/it_activatable.dart';
import '../../a11y/it_icon_action.dart';
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

  /// A second, right-aligned list of navigation items.
  ///
  /// `.it-header-navbar-wrapper nav .navbar-collapsable .menu-wrapper
  ///   .navbar-nav.navbar-secondary { display: flex; justify-content: flex-end }`
  /// with `… a { font-size: .875rem; line-height: 1.6 }` — the menu wrapper is
  /// `justify-content: space-between`, so the primary list keeps the left of
  /// the band and this one takes the right, in smaller type.
  ///
  /// On mobile the kit puts both lists in the same panel, so these follow the
  /// primary items down the menu.
  final List<ItNavItem> secondaryItems;

  /// The `.theme-light-desk` desktop band: white ground, primary content.
  ///
  /// `@media (min-width: 992px) { .it-header-navbar-wrapper.theme-light-desk
  ///   { background: #fff; box-shadow: 0 20px 30px 5px rgba(0,0,0,.05) } }`
  /// with `… li a.nav-link { color: #06c }` and
  /// `… li a.nav-link.active { border-bottom-color: #06c }`.
  ///
  /// Affects the desktop layout only; below `lg` the band is governed by
  /// [darkMobile], exactly as the two independent CSS classes are.
  final bool lightDesk;

  /// The `.theme-dark-mobile` panel: primary ground, white content, below `lg`.
  ///
  /// `.it-header-navbar-wrapper.theme-dark-mobile .navbar .navbar-collapsable
  ///   .menu-wrapper { background: #06c }` with `… li a.nav-link { color: #fff }`
  /// and `… a.nav-link.active { border-left-color: #fff }`.
  ///
  /// Defaults to **false**, matching the kit: the light panel is
  /// `.navbar .navbar-collapsable .menu-wrapper { background: #fff }`, and the
  /// docs say so in as many words — *"su mobile lo stile di default ha un
  /// background bianco e testi e link di colore primario"*.
  ///
  /// This package rendered the dark panel for a long time, which inverted the
  /// kit's default. `.theme-dark-mobile` is a *modifier* class, so a variant
  /// you opt into cannot also be the default; ours was simply wrong. Corrected
  /// rather than preserved because the package has no published users
  /// (`publish_to: none`) and no parity capture covers the mobile panel — the
  /// four header captures are all 1280px desktop selectors — so there was
  /// nothing to weigh against fidelity.
  final bool darkMobile;

  /// An accessible name for the navigation landmark this band publishes.
  ///
  /// Null by default, and that is the right answer for the ordinary case: a
  /// page with one navigation region does not need it named, and ARIA guidance
  /// is that a redundant label is a redundant announcement.
  ///
  /// It becomes necessary the moment a page carries more than one — a primary
  /// bar and a footer menu, say, or the several specimens a documentation page
  /// shows side by side. Repeated landmarks of the same role have to be told
  /// apart by name, and Flutter asserts on it: *"the navigation landmark role
  /// should have a unique label as it is used more than once"*.
  ///
  /// Caller-supplied content rather than a bundled string, for the same reason
  /// [ItSocialLink.label] is: only the application knows what distinguishes its
  /// two menus.
  final String? semanticsLabel;

  /// Creates a Bootstrap Italia navigation header.
  const ItNavHeader({
    super.key,
    required this.items,
    this.semanticsLabel,
    this.backgroundColor,
    this.contentInset = _defaultInset,
    this.secondaryItems = const [],
    this.lightDesk = false,
    this.darkMobile = false,
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
    //
    // The two theme classes invert that pairing on their own side of the `lg`
    // breakpoint: `.theme-light-desk { background: #fff }` with `#06c` links on
    // desktop, `.theme-dark-mobile { background: #06c }` with `#fff` links on
    // mobile. `#fff` is `--bs-white`, in the surface/on-primary roles those
    // tokens name, so both sides of every pair travel with the scheme together —
    // retinting the fill without the label is how a themed header loses its
    // contrast.
    final deskBg = widget.backgroundColor ??
        (widget.lightDesk ? colors.white : colors.primary);
    final deskFg = widget.lightDesk ? colors.primary : colors.white;
    final mobileBg = widget.backgroundColor ??
        (widget.darkMobile ? colors.primary : colors.white);
    final mobileFg = widget.darkMobile ? colors.white : colors.primary;

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
          label: widget.semanticsLabel,
          child: isDesktop
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: deskBg,
                    // `.theme-light-desk { box-shadow: 0 20px 30px 5px
                    //   rgba(0,0,0,.05) }` — a white band needs an edge against
                    // the white page beneath it, which the primary band does
                    // not. A drop shadow is not a palette colour, so the
                    // `rgba()` stays a literal.
                    boxShadow: widget.lightDesk
                        ? const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: Offset(0, 20),
                            ),
                          ]
                        : null,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: widget.contentInset),
                      // `.menu-wrapper { display: flex;
                      //   justify-content: space-between }` — the primary list
                      // takes the left, `.navbar-secondary` the right. With no
                      // secondary list the Row is exactly what it was.
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Natural width, NOT `Flexible`.
                          //
                          // `.navbar-nav { display: flex; flex-direction: row }`
                          // declares no `flex-wrap`, and its items shrink under
                          // pressure — but CSS shrinks them *proportionally to
                          // their content*, so a long label keeps more of the
                          // width than a short one. Flutter's `Flexible` divides
                          // the space **equally** (`spacePerFlex = max /
                          // totalFlex`), which handed "Link 2" as much room as
                          // "Megamenu con Immagine e Descrizione" and wrapped
                          // the long one onto three lines. That took
                          // `nav_header_nav` from parity to 67%: the reference
                          // band is one line, 57px tall, and ours became 113px.
                          //
                          // The docs' own six-item example needs ~1620px at
                          // natural size, so it must still survive a narrower
                          // container. It scrolls rather than shrinking: at any
                          // width where the items fit — including the 1248px
                          // the reference is captured at — this is pixel-for-
                          // pixel what a plain Row produced, and where they do
                          // not, a reachable overflow beats a wrapped band that
                          // matches neither the kit nor the reference.
                          for (final item in widget.items)
                            _NavLink(item: item, foreground: deskFg),
                          if (widget.secondaryItems.isNotEmpty) ...[
                            const Spacer(),
                            for (final item in widget.secondaryItems)
                              _NavLink(
                                item: item,
                                foreground: deskFg,
                                secondary: true,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  color: mobileBg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BootstrapItaliaSpacing.space3,
                        ),
                        child: _buildMobileBar(mobileFg),
                      ),
                      if (_mobileMenuOpen) _buildMobileMenu(mobileBg, mobileFg),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMobileBar(Color foreground) {
    final current = widget.items.firstWhere(
      (i) => i.active,
      orElse: () => widget.items.first,
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            current.label,
            style: _linkStyle(foreground).copyWith(fontWeight: FontWeight.w600),
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
          color: foreground,
          label: _mobileMenuOpen
              ? ItLocalizations.of(context).closeMenu
              : ItLocalizations.of(context).openMenu,
          onPressed: () => setState(() => _mobileMenuOpen = !_mobileMenuOpen),
        ),
      ],
    );
  }

  Widget _buildMobileMenu(Color background, Color foreground) {
    return Container(
      width: double.infinity,
      // `.navbar .navbar-collapsable .menu-wrapper { background: #fff }`, which
      // `.theme-dark-mobile` overrides with `{ background: #06c }` — the same
      // value the band above it carries, so it follows the scheme for the same
      // reason.
      color: background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in [...widget.items, ...widget.secondaryItems])
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
                                left: BorderSide(color: foreground, width: 3),
                              ),
                            )
                          : null,
                      child: Row(
                        children: [
                          if (item.icon != null) ...[
                            Icon(item.icon, size: 18, color: foreground),
                            const SizedBox(
                                width: BootstrapItaliaSpacing.space2),
                          ],
                          Text(
                            item.label,
                            style: hovered
                                ? _linkStyle(foreground).copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: foreground,
                                  )
                                : _linkStyle(foreground),
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

  /// The band's content colour — `#fff` on the primary band, `#06c` under
  /// `.theme-light-desk`. Passed in rather than resolved here, because the
  /// band above owns the pairing and the two must not be decided separately.
  final Color foreground;

  /// Whether this link belongs to `.navbar-nav.navbar-secondary`, which is
  /// `{ font-size: .875rem; line-height: 1.6 }` rather than the primary
  /// list's 18px/28px.
  final bool secondary;

  const _NavLink({
    required this.item,
    required this.foreground,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = secondary
        ? _linkStyle(foreground).copyWith(fontSize: 14, height: 1.6)
        : _linkStyle(foreground);

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
                    color: item.active ? foreground : const Color(0x00000000),
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // The label is what gives when the band runs out of room:
                  // CSS lets the flex item shrink and the text wrap, so the
                  // label has to be allowed to take less than its natural
                  // width rather than pushing the row past its bounds.
                  Flexible(
                    child: Text(
                      item.label,
                      style: hovered
                          ? style.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: foreground,
                            )
                          : style,
                    ),
                  ),
                  if (item.showsChevron) ...[
                    // The kit's markup separates label and chevron with a space.
                    const SizedBox(width: 4),
                    // `.navbar .navbar-collapsable .navbar-nav li.nav-item
                    //   a.nav-link.dropdown-toggle svg { fill: #fff }`, and
                    // `.theme-light-desk … svg { fill: #06c }` — the glyph
                    // always matches the label beside it.
                    ItExpandChevron(color: foreground),
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
