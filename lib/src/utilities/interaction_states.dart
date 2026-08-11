import 'package:flutter/widgets.dart';

/// Helpers for reproducing Bootstrap Italia's interaction states.
///
/// Material and Bootstrap Italia move in opposite directions when a control is
/// hovered or pressed. Material paints a translucent **white** overlay on top of
/// the widget (`WidgetState.hovered` -> `overlayColor`), so every interactive
/// state comes out *lighter*. Bootstrap Italia shades toward **black** — or, far
/// more often, does not change the fill at all and instead underlines the label
/// or recolours the text.
///
/// Concretely, on `#0066CC` Material rendered hover as `rgb(20, 114, 208)` and
/// press as `rgb(66, 141, 217)`, where the design system asks for
/// `rgb(0, 87, 173)` and `rgb(0, 82, 163)`.
///
/// Recolouring the overlay is not enough: it has to be **suppressed**, and the
/// component has to resolve its own colours per state.

/// Bootstrap's `shade-color()`: mix [color] toward black by [amount].
///
/// Bootstrap Italia compiles `shade-color()` by scaling the colour's HSL
/// lightness, which for the fully saturated brand blue is identical to a linear
/// RGB mix: `#0066CC` at 20% gives `rgb(0, 81.6, 163.2)` either way. For
/// desaturated colours the two differ by up to 1/255, so prefer the literal
/// value declared in the CSS whenever there is one.
Color itShade(Color color, double amount) =>
    Color.lerp(color, const Color(0xFF000000), amount)!;

/// Tracks pointer hover for a widget that paints its own interaction states.
///
/// Bootstrap Italia expresses most hover states as a text change (an underline,
/// or a darker link colour) rather than a background fill, which no Material
/// overlay can express. [builder] receives the current hover flag so the
/// component can resolve exactly the colours the stylesheet declares.
class ItHoverBuilder extends StatefulWidget {
  /// Builds the child for the current hover state.
  final Widget Function(BuildContext context, bool hovered) builder;

  /// When false the widget never reports hover, matching the design system's
  /// `:hover:not(.disabled)` guards.
  final bool enabled;

  /// Cursor to show while the pointer is over the widget.
  final MouseCursor cursor;

  /// Creates a hover tracker.
  const ItHoverBuilder({
    super.key,
    required this.builder,
    this.enabled = true,
    this.cursor = MouseCursor.defer,
  });

  @override
  State<ItHoverBuilder> createState() => _ItHoverBuilderState();
}

class _ItHoverBuilderState extends State<ItHoverBuilder> {
  bool _hovered = false;

  void _set(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  @override
  void didUpdateWidget(ItHoverBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _hovered) _hovered = false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: widget.enabled ? (_) => _set(true) : null,
      onExit: widget.enabled ? (_) => _set(false) : null,
      child: widget.builder(context, widget.enabled && _hovered),
    );
  }
}
