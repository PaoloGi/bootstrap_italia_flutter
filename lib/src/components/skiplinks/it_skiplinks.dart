import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/typography.dart';

/// A single "skip to…" destination in an [ItSkiplinks] bar.
class ItSkiplink {
  /// The visible link text, e.g. `Salta al contenuto principale`.
  final String label;

  /// Focus node of the target region.
  ///
  /// When supplied, activating the link moves keyboard focus there, which is
  /// what actually lets a keyboard user bypass the header.
  final FocusNode? targetFocusNode;

  /// Key of the target widget.
  ///
  /// When supplied, activating the link scrolls that widget into view. Combine
  /// with [targetFocusNode] to both scroll and focus.
  final GlobalKey? targetKey;

  /// Extra work to run when the link is activated, e.g. moving a router focus.
  final VoidCallback? onActivate;

  /// Creates a skiplink destination.
  const ItSkiplink({
    required this.label,
    this.targetFocusNode,
    this.targetKey,
    this.onActivate,
  });
}

/// Bootstrap Italia's `.skiplinks` bypass block.
///
/// Satisfies WCAG 2.2 §2.4.1 (Bypass Blocks): a keyboard or screen-reader user
/// landing on a page must be able to jump past the repeated header/navigation
/// block instead of tabbing through every nav item on every page.
///
/// Place it as the **first** focusable thing in the app, above the header:
///
/// ```dart
/// final mainFocus = FocusNode(debugLabel: 'main');
///
/// Column(
///   children: [
///     ItSkiplinks(
///       links: [ItSkiplink(label: 'Salta al contenuto principale',
///                          targetFocusNode: mainFocus)],
///     ),
///     ItHeader(...),
///     Focus(focusNode: mainFocus, child: MainContent()),
///   ],
/// )
/// ```
///
/// ## Why this reserves layout space
///
/// Upstream hides the links with `.visually-hidden-focusable`
/// (`position:absolute; left:-9999px`) and reveals them on `:focus`. That idiom
/// does **not** port to Flutter: the framework culls semantics for render
/// objects clipped or translated out of view, so an off-screen link stops being
/// reachable by focus or assistive technology — it would look conformant and be
/// inert, the exact failure mode this package is trying to eliminate.
///
/// So when [hideUntilFocused] is true the bar keeps its box and is painted
/// fully transparent, with `alwaysIncludeSemantics` forcing the links to stay in
/// the semantics tree. It is invisible, silent to sighted users, and genuinely
/// operable — which is what §2.4.1 asks for.
class ItSkiplinks extends StatefulWidget {
  /// The bypass destinations, in focus order.
  final List<ItSkiplink> links;

  /// Whether the bar is transparent until one of its links takes focus.
  ///
  /// Set false to render it permanently, as some PA sites prefer.
  final bool hideUntilFocused;

  // There was a `height` parameter here, fixed at 40 for the whole bar. It was
  // wrong for more than one link: upstream's links are block-level and stack,
  // so N links occupy N x 40, not 40 total. The 40 is not a free choice either
  // — `.skiplinks a` has 8px padding either side of a 24px line box, which
  // comes to exactly 40 — so the bar now takes its height from its content and
  // there is no second knob to disagree with the stylesheet.

  /// Background colour of the bar.
  ///
  /// Defaults to `.skiplinks { background-color: hsl(210, 62%, 97%) }` — a pale
  /// blue that matches no palette token, so it does not follow the theme.
  final Color? backgroundColor;

  /// Creates a Bootstrap Italia skiplinks bar.
  const ItSkiplinks({
    super.key,
    required this.links,
    this.hideUntilFocused = true,
    this.backgroundColor,
  });

  @override
  State<ItSkiplinks> createState() => _ItSkiplinksState();
}

class _ItSkiplinksState extends State<ItSkiplinks> {
  /// `.skiplinks { background-color: hsl(210, 62%, 97%) }`.
  ///
  /// Matches no palette token — 17 standalone occurrences in the stylesheet —
  /// so it does not follow the theme.
  static const Color _bandColor = Color(0xFFF3F7FC);

  bool _anyFocused = false;

  void _activate(ItSkiplink link) {
    final key = link.targetKey;
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
    link.targetFocusNode?.requestFocus();
    link.onActivate?.call();
  }

  @override
  Widget build(BuildContext context) {
    final visible = !widget.hideUntilFocused || _anyFocused;

    // The stylesheet declares exactly three `.skiplinks` rules:
    //
    //   .skiplinks   { background-color: hsl(210, 62%, 97%); text-align: center }
    //   .skiplinks a { padding: .5rem .5rem; display: block; font-weight: 600;
    //                  color: #06c; text-decoration: underline }
    //
    // So the band is a pale blue and the link carries the accent. This port had
    // the two inverted — a primary-filled bar with the label reversed out in
    // white, a colour upstream never declares here. Nothing caught it because
    // skiplinks was the one component with no parity capture at all. It has one
    // now (`nav_skiplinks`, 99.61%), captured after a Tab press because
    // `.visually-hidden-focusable` keeps the bar off-screen until focused.
    //
    // The capture settled the layout too: upstream's `li > a` are block-level,
    // so links stack vertically at full width and `text-align: center` centres
    // each. This was a Row.
    //
    // One divergence remains, deliberately. Upstream puts
    // `.visually-hidden-focusable` on each `li`, so only the *focused* link
    // occupies space and the bar shows one at a time; this port reveals every
    // link together once any has focus. Revealing one at a time is the faithful
    // reading; revealing all shows a keyboard user every available bypass at
    // once, which is arguably better for the criterion the component exists to
    // satisfy (§2.4.1 Bypass Blocks). That wants a decision and real AT
    // testing, not a silent change.
    //
    // `#06c` on the text is byte-identical to `--bs-primary` and is the
    // component's own accent, so it follows the theme. The band is not a token
    // (`hsl(210, 62%, 97%)` appears 17 times as a standalone declaration and
    // matches nothing in the palette), so it stays literal. Contrast holds at
    // 5.38:1, above the 4.5:1 §1.4.3 requires.
    final colors = resolveColorScheme(context);
    final linkColor = colors.primary;

    final bar = ColoredBox(
      color: widget.backgroundColor ?? _bandColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final link in widget.links)
            // `.skiplinks ul li a { display: block }` — each link is
            // block-level and spans the bar, so it stretches rather than
            // hugging its label. Confirmed against the live kit: with two
            // links the anchors measure 868x40 each, stacked.
            SizedBox(
              width: double.infinity,
              child: Focus(
                skipTraversal: true,
                canRequestFocus: false,
                onFocusChange: (hasFocus) {
                  if (hasFocus != _anyFocused && mounted) {
                    setState(() => _anyFocused = hasFocus);
                  }
                },
                child: Semantics(
                  link: true,
                  label: link.label,
                  child: ItActivatable(
                    onPressed: () => _activate(link),
                    child: ExcludeSemantics(
                      child: Padding(
                        // `.skiplinks a { padding: .5rem .5rem }` = 8px both ways.
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Text(
                          link.label,
                          // `.skiplinks { text-align: center }`.
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: BootstrapItaliaFontFamily.sansSerif,
                            package: BootstrapItaliaFontFamily.package,
                            // `.skiplinks ul { font-size: 1rem;
                            // line-height: 1.5rem }`
                            fontSize: 16,
                            height: 24 / 16,
                            fontWeight: FontWeight.w600,
                            color: linkColor,
                            decoration: TextDecoration.underline,
                            decorationColor: linkColor,
                            leadingDistribution: TextLeadingDistribution.even,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // `alwaysIncludeSemantics` is the whole point: without it Opacity(0) drops
    // the links from the semantics tree and the bypass block stops working.
    return Opacity(
      opacity: visible ? 1.0 : 0.0,
      alwaysIncludeSemantics: true,
      child: bar,
    );
  }
}
