import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/typography.dart';
import 'bottom_nav_clearance.dart';

/// `.bottom-nav` — the bar of primary destinations pinned to the bottom.
///
/// A real Bootstrap Italia component, not an adaptation: `design-react-kit`
/// ships `BottomNav` / `BottomNavItem`, and the CSS below is quoted from
/// `bootstrap-italia.min.css` v2.18.0 rather than eyeballed.
///
/// ```
/// .bottom-nav    { position:fixed; bottom:0; left:0; right:0;
///                  overflow:hidden; height:96px }
/// .bottom-nav ul { display:flex; justify-content:space-around;
///                  align-items:center; height:64px; background:#fff }
/// ```
///
/// The 96px outer box against a 64px bar is deliberate upstream: the extra
/// 32px is the overflow region the badge and alert dots protrude into. Only
/// the 64px bar is painted, which is why this widget reports 64px of height
/// and lets the dots draw outside it.
///
/// This is **not** `it-bottom-navscroll`. That is the Navscroll plugin —
/// scroll-spy navigation for the current page — and shares only a name.
///
/// While its page is the current route, bottom-placed `ItNotification`s sit
/// on top of the bar rather than over it — as a SnackBar sits above a bottom
/// navigation bar — and go back to the screen's edge on a page without one.
class ItBottomNav extends StatelessWidget {
  /// The destinations, left to right.
  ///
  /// `justify-content: space-around` distributes them, so they share the
  /// width evenly however many there are.
  final List<ItBottomNavItem> items;

  /// Index of the active destination, or null when none is.
  final int? selectedIndex;

  /// Called with the tapped index.
  ///
  /// Null disables every item, matching the convention the rest of this kit
  /// follows — `onChanged: null` is how Flutter says "read only", and a
  /// control that ignores it is a control that lies about its state.
  final ValueChanged<int>? onSelected;

  /// The bar's fill. `.bottom-nav ul { background-color:#fff }`.
  final Color? backgroundColor;

  /// Names the bar for assistive technology.
  ///
  /// The list is a navigation landmark upstream (`<nav>`), so it carries a
  /// name here too rather than arriving as an unlabelled row of buttons.
  final String? semanticLabel;

  /// Creates a Bootstrap Italia bottom navigation bar.
  const ItBottomNav({
    super.key,
    required this.items,
    this.selectedIndex,
    this.onSelected,
    this.backgroundColor,
    this.semanticLabel,
  });

  /// `.bottom-nav ul { height:64px }` — the painted bar.
  static const double barHeight = 64;

  /// The active-item rule: `3px`, the width `.nav-tabs .nav-link` reserves.
  ///
  /// Bootstrap Italia's own bottom nav marks the active item by colour alone
  /// (`.bottom-nav a.active { color: #06c }`), which is a WCAG 1.4.1 (Use of
  /// Color) weakness whatever palette is applied — and an outright failure for
  /// an administration whose brand is close to the inactive colour. Measured
  /// against Cohesion's `#2C546B`, the active and inactive labels differ by
  /// **1.18:1**: the same colour to a sighted user.
  ///
  /// The rule is not an invention. `.nav-tabs .nav-link` reserves
  /// `border-bottom: 3px solid transparent` and the active one colours it —
  /// and `.flex-column-reverse .nav-tabs .nav-link.active` moves that marker to
  /// `border-top-color` for exactly this case, a row of tabs sitting below its
  /// content. This is that idiom, applied to the bar.
  ///
  /// Presence-or-absence is what carries the state, so it survives greyscale
  /// and any palette. See doc/conformance.md.
  static const double activeRule = 3;

  /// The rule's width — the icon box, so it is the same on every destination.
  ///
  /// It used to span the item, and items are as wide as their labels: the rule
  /// measured 32px over "Crea" and 50.7px over "Da Evadere". A marker whose
  /// size depends on the length of a word reads as a rendering fault.
  static const double activeRuleWidth = _iconBox;

  /// Clear space between the rule and the icon beneath it.
  ///
  /// The rule and the icon box used to share a top edge — both at y=544 in a
  /// bar starting at 536 — so the marker was painted across the top of the
  /// glyph rather than above it.
  static const double activeRuleGap = 2;

  /// How long the rule takes to slide between destinations.
  ///
  /// Ignored when the platform asks for reduced motion: a marker that slides
  /// is decorative, and `MediaQuery.disableAnimations` is set by a user who
  /// has told the OS that movement makes the interface harder to use
  /// (WCAG 2.3.3 Animation from Interactions).
  static const Duration activeRuleDuration = Duration(milliseconds: 250);

  /// `.bottom-nav .it-ico { height:32px }`
  static const double _iconBox = 32;

  /// `.bottom-nav .bottom-nav-label { font-size:.625rem }` = 10px.
  static const double _labelFontSize = 10;

  /// `.bottom-nav ul li { margin:8px }`
  static const double _itemMargin = 8;

  @override
  Widget build(BuildContext context) {
    // The bar says how tall it is, so an overlay notification — which
    // cannot look down into this page — can sit on top of it. A SnackBar
    // gets that from Scaffold; see BottomNavClearance.
    return BottomNavClearanceReporter(child: _buildBar(context));
  }

  Widget _buildBar(BuildContext context) {
    final colors = resolveColorScheme(context);

    // `.bottom-nav { position: fixed; bottom: 0 }` — the component is by
    // definition anchored to the bottom of the screen, so it is the thing that
    // has to clear the home indicator. Unconditional for that reason: there is
    // no correct placement of this component where the inset does not apply.
    //
    // The split matters. The background takes the full height so the colour
    // reaches the screen edge, and only the CONTENT is padded above the
    // inset. Wrapping the whole bar in a SafeArea instead would lift it clear
    // of the edge and leave an unpainted strip below it.
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: SizedBox(
        height: barHeight + bottomInset,
        child: ColoredBox(
          color: backgroundColor ?? colors.white,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Equal widths rather than `space-around` with intrinsic ones.
                // Two things follow: the rule is the same size and in the same
                // place relative to every destination, and its position is a
                // function of the index, which is what lets one rule slide
                // between them instead of each item drawing its own.
                final slot = constraints.maxWidth / items.length;
                final selected = selectedIndex;
                final hasSelection = selected != null &&
                    selected >= 0 &&
                    selected < items.length;

                return Stack(
                  children: [
                    Padding(
                      // Reserves the rule and its gap, so the marker is above
                      // the icon rather than across it.
                      padding: const EdgeInsets.only(
                        top: activeRule + activeRuleGap,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: _ItBottomNavEntry(
                                item: items[i],
                                active: selected == i,
                                // Position is stated because a bar of four
                                // icons is read one item at a time, and
                                // "Storico" alone does not say where in the
                                // bar the user is.
                                indexInSet: i + 1,
                                setSize: items.length,
                                onTap: onSelected == null
                                    ? null
                                    : () => onSelected!(i),
                                colors: colors,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (hasSelection)
                      AnimatedPositioned(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : activeRuleDuration,
                        curve: Curves.easeOut,
                        top: 0,
                        left: selected * slot + (slot - activeRuleWidth) / 2,
                        width: activeRuleWidth,
                        height: activeRule,
                        child: ColoredBox(
                          color: onSelected == null
                              ? colors.secondary
                              : colors.primary,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// One destination in an [ItBottomNav].
///
/// Mirrors `BottomNavItem` in `design-react-kit`: an icon, a label, and
/// optionally a numeric [badge] or an [alert] dot.
class ItBottomNavItem {
  /// `.bottom-nav-label` — always required.
  ///
  /// Upstream allows an icon-only item; this does not. The label is the
  /// accessible name, and an unnamed destination is a button a screen-reader
  /// user cannot identify (WCAG 4.1.2).
  final String label;

  /// The glyph above the label.
  final IconData icon;

  /// `.bottom-nav-badge` — a count in the corner of the icon.
  final int? badge;

  /// `.bottom-nav-alert` — a dot marking new content, with no number.
  ///
  /// Ignored when [badge] is set: upstream renders both wrappers, but two
  /// marks on one icon says the same thing twice.
  final bool alert;

  /// Extra wording for assistive technology only.
  ///
  /// `srText` upstream. Appended to the label, so "Messaggi" can announce as
  /// "Messaggi, 3 non letti" without printing that on a 10px label.
  final String? semanticSuffix;

  /// Creates a bottom-navigation destination.
  const ItBottomNavItem({
    required this.label,
    required this.icon,
    this.badge,
    this.alert = false,
    this.semanticSuffix,
  });
}

class _ItBottomNavEntry extends StatelessWidget {
  const _ItBottomNavEntry({
    required this.item,
    required this.active,
    required this.indexInSet,
    required this.setSize,
    required this.onTap,
    required this.colors,
  });

  final ItBottomNavItem item;
  final bool active;
  final int indexInSet;
  final int setSize;
  final VoidCallback? onTap;
  final BootstrapItaliaColorScheme colors;

  @override
  Widget build(BuildContext context) {
    // `.bottom-nav a       { color: hsl(210,33%,28%) }`
    // `.bottom-nav a.active{ color: #06c }`
    final foreground = active ? colors.primary : _restColor;
    // `.bottom-nav a .icon { fill: hsl(210,17%,44%) }` — byte-identical to
    // the `secondary` token in a role where that token is meant, so it goes
    // through the scheme and re-themes with everything else.
    final iconColor = active ? colors.primary : colors.secondary;

    final name = item.semanticSuffix == null
        ? item.label
        : '${item.label}, ${item.semanticSuffix}';

    return Semantics(
      button: true,
      selected: active,
      enabled: onTap != null,
      label: name,
      value: '$indexInSet di $setSize',
      onTap: onTap,
      child: ExcludeSemantics(
        child: ItActivatable(
          onPressed: onTap,
          child: Padding(
            // `.bottom-nav ul li { margin:8px }`
            padding: const EdgeInsets.symmetric(
              horizontal: ItBottomNav._itemMargin,
            ),
            // The active rule is drawn once by the bar, not per item — that
            // is what lets it animate between destinations.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: ItBottomNav._iconBox,
                  child: Stack(
                    // The badge and the alert dot sit outside the icon box —
                    // `.bottom-nav { overflow:hidden; height:96px }` is what
                    // gives them room upstream.
                    clipBehavior: Clip.none,
                    children: [
                      Center(
                        child: Icon(
                          item.icon,
                          size: ItBottomNav._iconBox,
                          color: iconColor,
                        ),
                      ),
                      if (item.badge != null)
                        _Badge(count: item.badge!, colors: colors)
                      else if (item.alert)
                        _AlertDot(colors: colors),
                    ],
                  ),
                ),
                // `.bottom-nav-label { margin-top:6px; font-size:.625rem;
                //  line-height:1; font-weight:600 }`
                const SizedBox(height: 6),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: BootstrapItaliaFontFamily.sansSerif,
                    package: BootstrapItaliaFontFamily.package,
                    fontSize: ItBottomNav._labelFontSize,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// `.bottom-nav a { color: hsl(210,33%,28%) }`
  static const Color _restColor = Color(0xFF30475F);
}

/// `.bottom-nav-badge` — `min-width:1.15rem; padding:4px 6px;
/// font-size:.625rem; border-radius:2rem; border:1px solid #fff`.
class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.colors});

  final int count;
  final BootstrapItaliaColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        constraints: const BoxConstraints(minWidth: 18.4), // 1.15rem
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(32), // 2rem
          border: Border.all(color: colors.white),
        ),
        child: Text(
          '$count',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: BootstrapItaliaFontFamily.sansSerif,
            package: BootstrapItaliaFontFamily.package,
            fontSize: 10,
            height: 1,
            color: colors.white,
          ),
        ),
      ),
    );
  }
}

/// `.bottom-nav-alert` — `top:0; right:4px; min-width:12px; height:12px;
/// border-radius:50%`.
class _AlertDot extends StatelessWidget {
  const _AlertDot({required this.colors});

  final BootstrapItaliaColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 4,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colors.white),
        ),
      ),
    );
  }
}
