import 'package:flutter/widgets.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/typography.dart';

/// `.sidebar-wrapper` — the styled panel a navigation link list sits in.
///
/// A port of `Sidebar` in `design-react-kit`, whose whole job is the wrapper:
/// it renders `.sidebar-wrapper > .sidebar-linklist-wrapper` and leaves the
/// links to a `LinkList`. This does the same — put an [ItList] in [child].
///
/// ```
/// .sidebar-wrapper                    { padding:24px 0 }
/// .sidebar-wrapper h3                 { font-weight:600; font-size:1.15rem;
///                                       letter-spacing:1px; text-transform:uppercase;
///                                       margin-top:4px; margin-bottom:.8rem;
///                                       padding-left:24px; padding-right:24px }
/// .sidebar-wrapper.it-line-left-side  { border-left:1px solid hsl(210,4%,78%) }
/// .sidebar-wrapper.it-line-right-side { border-right:1px solid hsl(210,4%,78%) }
/// .sidebar-wrapper.theme-dark         { background:hsl(210,25%,35.2%) }
/// ```
///
/// It is the *content* of a drawer, not the drawer itself: nothing here slides
/// or overlays. Upstream that separation is real too — the sliding panel is
/// the `offcanvas` plugin, and a Sidebar is what you put inside one.
class ItSidebar extends StatelessWidget {
  /// The panel's contents — typically an [ItList] of destinations.
  final Widget child;

  /// Optional heading, rendered as the `h3` upstream styles.
  ///
  /// Upstream sets `text-transform: uppercase`, which is a *presentation*
  /// choice: the string is passed to assistive technology as written, so a
  /// screen reader says "Navigazione" and not "N-A-V".
  final String? title;

  /// `.it-line-left-side` — a rule down the left edge.
  final bool lineLeft;

  /// `.it-line-right-side` — a rule down the right edge.
  final bool lineRight;

  /// `.theme-dark` — the dark band, `hsl(210,25%,35.2%)`.
  ///
  /// Upstream also swaps the edge rules to `rgba(229,229,229,.3)` in this
  /// theme, because a grey rule is invisible on the dark ground.
  final bool dark;

  /// Names the panel as a navigation landmark.
  ///
  /// Upstream a Sidebar is a `<nav>` in practice. Without a name, a screen
  /// reader announces an unlabelled region and the user has to read into it
  /// to find out what it is.
  final String? semanticLabel;

  /// Creates a Bootstrap Italia sidebar panel.
  const ItSidebar({
    super.key,
    required this.child,
    this.title,
    this.lineLeft = false,
    this.lineRight = false,
    this.dark = false,
    this.semanticLabel,
  });

  /// `.sidebar-wrapper { padding: 24px 0 }`
  static const double _verticalPadding = 24;

  /// `.sidebar-wrapper h3 { padding-left:24px; padding-right:24px }`
  static const double _titleInset = 24;

  /// `border: 1px solid hsl(210,4%,78%)`
  static const Color _rule = Color(0xFFC5C7C9);

  /// `.theme-dark { background: hsl(210,25%,35.2%) }` — the same band
  /// `.dropdown-menu.dark` uses.
  static const Color _darkBackground = Color(0xFF435A70);

  /// `.theme-dark .it-line-*-side { border-color: rgba(229,229,229,.3) }`
  static const Color _darkRule = Color(0x4DE5E5E5);

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final ruleColor = dark ? _darkRule : _rule;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? _darkBackground : null,
          border: Border(
            left: lineLeft ? BorderSide(color: ruleColor) : BorderSide.none,
            right: lineRight ? BorderSide(color: ruleColor) : BorderSide.none,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Padding(
                  // `margin-top:4px` on top of the wrapper's own padding.
                  padding: const EdgeInsets.fromLTRB(
                    _titleInset,
                    4,
                    _titleInset,
                    0,
                  ),
                  child: Semantics(
                    header: true,
                    child: Text(
                      // Upstreams uppercases in CSS, which leaves the accessible
                      // name intact. Doing it in Dart would change the string
                      // AT reads, so the transform is applied to the display
                      // text only and the semantics label keeps the original.
                      title!.toUpperCase(),
                      style: TextStyle(
                        fontFamily: BootstrapItaliaFontFamily.sansSerif,
                        package: BootstrapItaliaFontFamily.package,
                        fontSize: 18.4, // 1.15rem
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: dark ? colors.white : colors.bodyColor,
                      ),
                      semanticsLabel: title,
                    ),
                  ),
                ),
                // `margin-bottom: .8rem`
                const SizedBox(height: 12.8),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
