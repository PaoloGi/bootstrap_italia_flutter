import 'package:flutter/widgets.dart';

import '../../l10n/it_localizations.dart';
import '../../a11y/it_activatable.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/breakpoints.dart';
import '../../utilities/interaction_states.dart';

/// The circular "back to top" control, without any scroll wiring.
///
/// Rendered by [ItBackToTop]; exposed separately so it can be placed
/// manually (for example inside a custom overlay).
///
/// Mirrors Bootstrap Italia's `.back-to-top`:
/// `background:#06c; width:40px; height:40px; border-radius:50%` and, from
/// the `md` breakpoint up, `width:56px; height:56px`.
class ItBackToTopButton extends StatelessWidget {
  /// Called when the control is tapped.
  final VoidCallback? onPressed;

  /// Light-on-dark variant (`.back-to-top.dark`): white circle, dark arrow.
  final bool dark;

  /// Forces the 40px circle at every breakpoint (`.back-to-top-small`).
  final bool small;

  /// Adds the Bootstrap `.shadow` drop shadow.
  final bool shadow;

  /// Overrides the circle color.
  final Color? color;

  /// Overrides the arrow color.
  final Color? iconColor;

  /// Optional glyph replacing the built-in Bootstrap Italia `it-arrow-up`.
  final IconData? icon;

  /// Creates the back-to-top circle.
  const ItBackToTopButton({
    super.key,
    this.onPressed,
    this.dark = false,
    this.small = false,
    this.shadow = false,
    this.color,
    this.iconColor,
    this.icon,
  });

  /// `.back-to-top.dark:hover
  ///   { background: rgb(234.7785, 235.96425, 237.15) }`
  ///
  /// = hsl(210, 6.2%, 92.5%), which matches no palette token, and is not a
  /// uniform shade of the white resting fill either — shading white keeps
  /// saturation at zero and this is faintly blue. A value the stylesheet states
  /// in its own right, so the literal stays.
  static const Color _darkHover = Color(0xFFEBECED);

  /// `.back-to-top.dark .icon:before { color: hsl(210,25%,35.2%) }`
  ///
  /// Also stated in its own right: 18 occurrences across the stylesheet, and no
  /// `hsl(210,25%,44%)` anywhere for it to be a shade of. The nearest token,
  /// `--bs-secondary` = hsl(210,17%,44%), differs in both saturation and
  /// lightness, so this is not the grey-blue accent wearing a shade. Literal.
  static const Color _darkArrow = Color(0xFF435A70);

  @override
  Widget build(BuildContext context) {
    return ItHoverBuilder(
      enabled: onPressed != null,
      cursor: onPressed == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      builder: _build,
    );
  }

  Widget _build(BuildContext context, bool hovered) {
    final width =
        MediaQuery.maybeSizeOf(context)?.width ?? ItBreakpoint.md.minWidth;
    // `@media (min-width: 768px) { .back-to-top { width: 56px; height: 56px } }`
    final diameter = (small || width < ItBreakpoint.md.minWidth) ? 40.0 : 56.0;
    // `.back-to-top .icon { transform: scale(1) }` at md+, `scale(0.75)` below
    // and for `.back-to-top-small` — a 32px sprite scaled to 32 or 24.
    final iconBox = diameter == 56.0 ? 32.0 : 24.0;
    // The 32px sprite sits at `top: 10px` inside the 56px circle; the small
    // variant is exactly centred.
    final iconTop = diameter == 56.0 ? 10.0 : 8.0;

    final colors = resolveColorScheme(context);

    // `.back-to-top { background: #06c }` — byte-identical to `--bs-primary`
    // (hsl(210,100%,40%)), and it fills the whole control, which is the accent
    // slot rather than a neutral surface. So it follows the theme: an
    // administration that retints primary gets its own circle, not Blu Italia.
    // `.back-to-top.dark { background: #fff }` is the light-on-dark variant's
    // paper, not an accent, and stays white as everywhere else in the package.
    final restColor =
        color ?? (dark ? const Color(0xFFFFFFFF) : colors.primary);
    // `.back-to-top:hover { background: rgb(0, 91.8, 183.6) }` — exactly
    // 0.9 x primary, so a 10% shade and not the button's 15%; measured as
    // `rgb(0, 92, 184)` on the React kit in both the hover and the pressed
    // state, where Material's overlay pushed the same circle *lighter* instead.
    // Deriving it from the token keeps the CSS's fractional channels (the old
    // literal rounded them to the nearest 1/255) and keeps the hover in step
    // with a retinted fill. A caller-supplied fill has no declared hover value,
    // so it follows the same 10% shade.
    final hoverColor = color != null
        ? itShade(color!, 0.10)
        : (dark ? _darkHover : itShade(colors.primary, 0.10));
    final circleColor = hovered ? hoverColor : restColor;
    // `.back-to-top .icon:before { color: #fff }`, and `.dark` swaps in the
    // declared blue-grey above.
    final arrowColor =
        iconColor ?? (dark ? _darkArrow : const Color(0xFFFFFFFF));

    // §2.4.4 Link Purpose / §4.1.2 Name, Role, Value: the control paints only
    // an arrow, so the accessible name has to be supplied here — an unlabelled
    // icon button is a hard failure. §2.1.1: ItActivatable makes it reachable
    // and activatable from the keyboard, which a bare GestureDetector is not.
    // The name is hardcoded Italian; there is no localisation layer. See
    // doc/quality-plan.md — Alto Adige and Valle d'Aosta carry statutory German
    // and French obligations, so this is a known gap, not a decision.
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: ItLocalizations.of(context).backToTop,
      child: ItActivatable(
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(diameter),
        child: ExcludeSemantics(
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              boxShadow: shadow
                  ? const [
                      // Bootstrap `.shadow`: 0 .5rem 1rem rgba(0,0,0,.15)
                      BoxShadow(
                        color: Color(0x26000000),
                        offset: Offset(0, 8),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: (diameter - iconBox) / 2,
                  top: iconTop,
                  width: iconBox,
                  height: iconBox,
                  child: icon != null
                      ? Icon(icon, size: iconBox, color: arrowColor)
                      : CustomPaint(
                          painter: _ArrowUpPainter(arrowColor),
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

/// Paints Bootstrap Italia's `it-arrow-up` sprite:
/// `M18.6 10.1 12 3.5l-6.6 6.6.7.7 5.4-5.3V21h1V5.5l5.4 5.3.7-.7z`
/// on a 24x24 viewBox.
class _ArrowUpPainter extends CustomPainter {
  final Color color;

  const _ArrowUpPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 24.0;
    final path = Path()
      ..moveTo(18.6 * s, 10.1 * s)
      ..lineTo(12.0 * s, 3.5 * s)
      ..lineTo(5.4 * s, 10.1 * s)
      ..lineTo(6.1 * s, 10.8 * s)
      ..lineTo(11.5 * s, 5.5 * s)
      ..lineTo(11.5 * s, 21.0 * s)
      ..lineTo(12.5 * s, 21.0 * s)
      ..lineTo(12.5 * s, 5.5 * s)
      ..lineTo(17.9 * s, 10.8 * s)
      ..lineTo(18.6 * s, 10.1 * s)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowUpPainter oldDelegate) => oldDelegate.color != color;
}

/// A Bootstrap Italia "back to top" floating button.
///
/// Appears after the user scrolls past [showAfter] pixels and smoothly
/// scrolls back to the top when tapped. Must be placed inside a [Stack]
/// because it renders a [Positioned].
///
/// ```dart
/// Stack(
///   children: [
///     ListView(...),
///     ItBackToTop(scrollController: _scrollController),
///   ],
/// )
/// ```
class ItBackToTop extends StatefulWidget {
  /// The scroll controller to monitor and animate.
  final ScrollController scrollController;

  /// Scroll offset (in pixels) after which the button appears.
  final double showAfter;

  /// Animation duration for scrolling to top.
  ///
  /// The kit's `BackToTop` plugin documents `duration: 800` under *Opzioni*;
  /// this package has always defaulted to 500ms and that difference is kept
  /// rather than changed under a docs-parity pass, which is not the place to
  /// alter how long an existing application's page takes to scroll.
  final Duration scrollDuration;

  /// Easing for the scroll animation.
  ///
  /// Defaults to [Curves.easeInOutSine], which is the plugin's documented
  /// `easing: 'easeInOutSine'` — Flutter ships the same curve under the same
  /// name, so the previous [Curves.easeInOut] was a near-miss rather than a
  /// choice.
  final Curve scrollCurve;

  /// Optional glyph replacing the built-in Bootstrap Italia arrow.
  final IconData? icon;

  /// Button color. Defaults to the theme's primary (`#0066CC` as standard).
  final Color? color;

  /// Light-on-dark variant: white circle with a dark arrow.
  final bool dark;

  /// Forces the 40px circle at every breakpoint.
  final bool small;

  /// Adds the Bootstrap `.shadow` drop shadow.
  final bool shadow;

  /// Creates a back-to-top button.
  const ItBackToTop({
    super.key,
    required this.scrollController,
    this.showAfter = 200,
    this.scrollDuration = const Duration(milliseconds: 500),
    this.scrollCurve = Curves.easeInOutSine,
    this.icon,
    this.color,
    this.dark = false,
    this.small = false,
    this.shadow = false,
  });

  @override
  State<ItBackToTop> createState() => _ItBackToTopState();
}

class _ItBackToTopState extends State<ItBackToTop> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    _checkVisibility();
  }

  @override
  void didUpdateWidget(ItBackToTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() => _checkVisibility();

  void _checkVisibility() {
    if (!widget.scrollController.hasClients) return;
    final shouldShow = widget.scrollController.offset > widget.showAfter;
    if (shouldShow != _visible) {
      setState(() => _visible = shouldShow);
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: widget.scrollDuration,
      curve: widget.scrollCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The class doc says "must be placed inside a Stack" and nothing enforced
    // it. Without one, `Positioned` throws from deep inside the framework with
    // a message that names neither this widget nor the fix — the reader is told
    // an incorrect-use-of-ParentDataWidget occurred, not that ItBackToTop needs
    // a Stack.
    assert(
      context.findAncestorWidgetOfExactType<Stack>() != null,
      'ItBackToTop must be placed inside a Stack.\n'
      'It renders a Positioned so that it floats over the scrollable content '
      'rather than taking part in its layout. Wrap the page in a Stack with '
      'the scrollable first and this widget after it, or use '
      'ItBackToTopButton, which is the same control without the positioning.',
    );

    // `.back-to-top { bottom: 16px; right: 16px }`, `32px` from `xl` up.
    final width =
        MediaQuery.maybeSizeOf(context)?.width ?? ItBreakpoint.md.minWidth;
    final inset = width >= ItBreakpoint.xl.minWidth ? 32.0 : 16.0;

    return Positioned(
      right: inset,
      bottom: inset,
      child: IgnorePointer(
        ignoring: !_visible,
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            // `.back-to-top { transform: scale(0.7) }` until `.back-to-top-show`.
            scale: _visible ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 200),
            child: ItBackToTopButton(
              onPressed: _visible ? _scrollToTop : null,
              dark: widget.dark,
              small: widget.small,
              shadow: widget.shadow,
              color: widget.color,
              icon: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}
