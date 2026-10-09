import 'package:flutter/widgets.dart';

import '../../l10n/it_localizations.dart';
import '../../tokens/typography.dart';
import '../common/it_close_button.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/it_default_text_style.dart';
import '../../theme/theme_extensions.dart';

/// Which edge an [ItOffcanvas] slides in from.
///
/// Named for the CSS classes rather than for Flutter: `.offcanvas-start` is
/// the leading edge, which is the left in a left-to-right locale and the right
/// in Arabic. Bootstrap dropped `left`/`right` for exactly this reason.
enum ItOffcanvasPlacement {
  /// `.offcanvas-start` — `transform: translateX(-100%)`.
  start,

  /// `.offcanvas-end` — `transform: translateX(100%)`.
  end,

  /// `.offcanvas-top` — `transform: translateY(-100%)`, `height: 30vh`.
  top,

  /// `.offcanvas-bottom` — `transform: translateY(100%)`, `height: 30vh`.
  bottom,
}

/// `.offcanvas` — the panel that slides in over the page.
///
/// The sliding half of what Material calls a Drawer. Put an [ItSidebar] in
/// [body] and this is a navigation drawer; put anything else in it and it is
/// the general-purpose panel Bootstrap Italia's `offcanvas` plugin provides.
///
/// ```
/// --bs-offcanvas-width:    400px
/// --bs-offcanvas-height:   30vh
/// --bs-offcanvas-bg:       hsl(0,0%,100%)
/// --bs-offcanvas-padding-x: 1.5rem
/// --bs-offcanvas-padding-y: 1.5rem
/// --bs-offcanvas-zindex:   1045
/// .offcanvas-backdrop.show { background-color:#000; opacity:.8 }
/// .offcanvas-start { transform: translateX(-100%) }
/// ```
///
/// Imperative like [ItModal.show], and for the same reason: the panel is a
/// route. That is what gives it a focus trap, an Escape key that pops it, and
/// a back gesture that closes it rather than leaving the app — none of which a
/// widget rendered inline can provide.
abstract final class ItOffcanvas {
  /// `--bs-offcanvas-width: 400px`.
  ///
  /// A hard 400px is wider than a phone, so the panel is capped at a share of
  /// the screen below that. Upstream never faces this: the offcanvas is a
  /// desktop pattern that collapses into the page on small viewports
  /// (`.offcanvas { position:static; width:auto !important }`).
  static const double width = 400;

  /// The most of a narrow screen the panel may cover.
  ///
  /// Leaving a strip of the page visible is what tells the user this is a
  /// layer over the page rather than a new one, and gives a pointer user
  /// somewhere to tap to dismiss.
  static const double maxWidthFraction = 0.85;

  /// `--bs-offcanvas-height: 30vh` for the top and bottom placements.
  static const double heightFraction = 0.3;

  /// `--bs-offcanvas-padding-x` / `-y`: `1.5rem`.
  static const double padding = 24;

  /// `.offcanvas-title` renders at the `h5` step, `line-height: 1.5`.
  static const double titleFontSize = 18;

  /// Opens the panel and completes with whatever it is popped with.
  ///
  /// [title] names the route, which is what a screen reader announces when the
  /// panel opens. Without it the user is moved into an unnamed layer.
  ///
  /// [dismissible] false removes the barrier tap and the Escape key together,
  /// so the panel must then carry its own way out. That combination is
  /// asserted against rather than shipped: a layer with a focus trap and no
  /// exit is WCAG 2.1.2, and it is easier to write by accident than to notice.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget body,
    String? title,
    ItOffcanvasPlacement placement = ItOffcanvasPlacement.start,
    bool dismissible = true,
    bool showCloseButton = true,
    bool scrollable = true,
    bool animated = true,
    Color? backgroundColor,
    Color? barrierColor,
    bool hasOwnCloseAction = false,
  }) {
    assert(
      dismissible || showCloseButton || hasOwnCloseAction,
      'A non-dismissible ItOffcanvas must provide its own way out.\n'
      'With `dismissible: false` the barrier ignores taps and Escape does not '
      'pop the route, so the panel traps keyboard focus with nothing to move '
      'to (WCAG 2.1.2 No Keyboard Trap). Leave `dismissible` at its default, '
      'or keep the header `showCloseButton`, or pass `hasOwnCloseAction: '
      'true` to state that the body contains a control which closes it.',
    );

    final l10n = ItLocalizations.of(context);
    final colors = resolveColorScheme(context);
    // `.offcanvas-backdrop.show { background-color:#000; opacity:.8 }`
    final effectiveBarrier = barrierColor ?? colors.black.withAlpha(204);

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      // Its own name, not the panel's: the barrier and any close button inside
      // are two targets in one layer, and one name across both leaves AT
      // unable to tell them apart.
      barrierLabel: l10n.dismissModalBarrier,
      barrierColor: effectiveBarrier,
      // `.offcanvas { transition: transform .3s ease-out }`, and zero rather
      // than a second code path when the caller turns the animation off.
      transitionDuration:
          animated ? const Duration(milliseconds: 300) : Duration.zero,
      routeSettings: RouteSettings(name: title),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ItOffcanvasPanel(
          placement: placement,
          backgroundColor: backgroundColor,
          title: title,
          showCloseButton: showCloseButton,
          scrollable: scrollable,
          body: body,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (!animated) return child;
        // Each placement enters along its own axis, from fully off-screen —
        // `translateX(-100%)`, `translateX(100%)`, `translateY(±100%)`.
        final begin = switch (placement) {
          ItOffcanvasPlacement.start => const Offset(-1, 0),
          ItOffcanvasPlacement.end => const Offset(1, 0),
          ItOffcanvasPlacement.top => const Offset(0, -1),
          ItOffcanvasPlacement.bottom => const Offset(0, 1),
        };
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        );
      },
    );
  }
}

class _ItOffcanvasPanel extends StatelessWidget {
  const _ItOffcanvasPanel({
    required this.placement,
    required this.backgroundColor,
    required this.title,
    required this.showCloseButton,
    required this.scrollable,
    required this.body,
  });

  final ItOffcanvasPlacement placement;
  final Color? backgroundColor;
  final String? title;
  final bool showCloseButton;
  final bool scrollable;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final media = MediaQuery.of(context);
    final horizontal = placement == ItOffcanvasPlacement.start ||
        placement == ItOffcanvasPlacement.end;

    // 400px, or 85% of a screen too narrow to hold it.
    final panelWidth = horizontal
        ? (media.size.width * ItOffcanvas.maxWidthFraction)
            .clamp(0.0, ItOffcanvas.width)
        : media.size.width;
    final panelHeight = horizontal
        ? media.size.height
        : media.size.height * ItOffcanvas.heightFraction;

    final alignment = switch (placement) {
      ItOffcanvasPlacement.start => AlignmentDirectional.centerStart,
      ItOffcanvasPlacement.end => AlignmentDirectional.centerEnd,
      ItOffcanvasPlacement.top => AlignmentDirectional.topCenter,
      ItOffcanvasPlacement.bottom => AlignmentDirectional.bottomCenter,
    };

    return Align(
      alignment: alignment,
      child: Semantics(
        // A layer, not a region of the page behind it. `scopesRoute` plus a
        // name is what makes a screen reader announce the panel on open; the
        // route's own focus trap keeps the user inside it.
        scopesRoute: true,
        namesRoute: title != null,
        label: title,
        explicitChildNodes: true,
        child: SizedBox(
          width: panelWidth,
          height: panelHeight,
          child: ColoredBox(
            // `--bs-offcanvas-bg: hsl(0,0%,100%)`
            color: backgroundColor ?? colors.white,
            // The panel is a pushed route, so it sits ABOVE the host app's
            // Scaffold and inherits no Material text style — what is left
            // underneath is `DefaultTextStyle.fallback`, which supplies no font
            // family and a yellow double underline. The header title showed
            // exactly that until the component was rendered and looked at.
            child: ItDefaultTextStyle(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title != null || showCloseButton)
                      _buildHeader(context, colors),
                    // `.offcanvas-body { flex-grow:1; padding:1.5rem;
                    // overflow-y:auto }`. Expanded supplies the flex-grow, and
                    // the scroll view the overflow — which is also what keeps a
                    // panel usable at 200% text (WCAG 1.4.4), since a fixed-width
                    // column has nowhere else for the extra height to go.
                    Expanded(
                      child: scrollable
                          ? SingleChildScrollView(
                              padding:
                                  const EdgeInsets.all(ItOffcanvas.padding),
                              child: body,
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.all(ItOffcanvas.padding),
                              child: body,
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

  /// `.offcanvas-header { display:flex; align-items:center;
  /// justify-content:space-between; padding:1.5rem }`.
  ///
  /// Upstream hides this only inside `.navbar-expand*` and the responsive
  /// `.offcanvas-{bp}` variants — a plain `.offcanvas` shows it. Without it the
  /// panel has a name only assistive technology can reach, and no visible way
  /// out at all: a sighted pointer user would be left guessing that tapping the
  /// dimmed area closes it.
  Widget _buildHeader(BuildContext context, BootstrapItaliaColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(ItOffcanvas.padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                // The route already carries the name for AT via `namesRoute`,
                // so repeating it as a heading node would announce the panel
                // twice on open. This is the visible half only.
                : ExcludeSemantics(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontFamily: BootstrapItaliaFontFamily.sansSerif,
                        package: BootstrapItaliaFontFamily.package,
                        fontSize: ItOffcanvas.titleFontSize,
                        // `.offcanvas-title { line-height: 1.5 }`
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: colors.bodyColor,
                      ),
                    ),
                  ),
          ),
          if (showCloseButton)
            ItCloseButton(
              onPressed: () => Navigator.of(context).pop(),
              label: ItLocalizations.of(context).closePanel,
            ),
        ],
      ),
    );
  }
}
