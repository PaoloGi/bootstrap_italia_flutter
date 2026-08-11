import 'package:flutter/widgets.dart';

/// Bootstrap Italia's keyboard focus indicator, painted around a control.
///
/// The stylesheet applies one indicator to every keyboard-focused element:
///
/// ```css
/// :focus:not([data-focus-mouse=true]),
/// .toggles label input[type=checkbox]:focus + .lever,
/// .form-check [type=checkbox]:focus + label,
/// .form-check [type=radio]:focus + label {
///   border-color: #000 !important;
///   box-shadow: 0 0 0 2px #fff, 0 0 0 5px #000 !important;
/// }
/// ```
///
/// So: 2px of white immediately outside the control, then 3px of black. The
/// `:not([data-focus-mouse=true])` guard means it is shown for keyboard focus
/// only — Flutter's analogue is [FocusManager.highlightMode], which is what
/// [FocusableActionDetector.onShowFocusHighlight] is driven by and what
/// [trackDescendants] consults directly.
///
/// Black on the white page background is 21:1, and the black band is 3px wide,
/// so the indicator satisfies WCAG 2.2 **2.4.7 Focus Visible** (AA) and also
/// clears the stricter contrast and area thresholds of 2.4.13 Focus Appearance.
///
/// The ring is drawn as two *stroked* rounded rectangles rather than as a
/// [BoxShadow]: a shadow paints a filled shape behind the child, which would
/// show through controls whose interior is transparent (an unchecked
/// checkbox row, for example). Stroking also keeps the paint entirely outside
/// the control's own box, so the widget's size — and therefore the pixel
/// parity of every unfocused capture — is unchanged.
///
/// There are two ways to drive it:
///
///  * [visible] — the caller already tracks keyboard focus, typically through
///    [FocusableActionDetector.onShowFocusHighlight]. Used by the form
///    controls and by `ItActivatable`.
///  * [trackDescendants] — the control's focus lives inside a descendant that
///    owns its own [FocusNode], so there is no callback to hang off. The ring
///    inserts a non-focusable, non-traversable [Focus] above the child and
///    paints while that node reports focus *and* the focus highlight mode is
///    the keyboard one. This existed for Material's [InkWell]; per ADR 0001
///    there are none left, and the remaining users are controls that delegate
///    focus to a child rather than owning it.
class ItFocusRing extends StatefulWidget {
  /// Wraps [child] with the Bootstrap Italia keyboard focus indicator.
  const ItFocusRing({
    super.key,
    this.visible = false,
    this.trackDescendants = false,
    required this.child,
    this.radius = 0,
  });

  /// Whether the indicator is currently painted.
  ///
  /// Ignored when [trackDescendants] resolves to true on its own; the two are
  /// OR-ed, so a caller may set both.
  final bool visible;

  /// Whether to watch the subtree's own focus instead of relying on [visible].
  ///
  /// Set this where the focusable widget is a descendant that does not expose
  /// a focus callback — an [InkWell], for example.
  final bool trackDescendants;

  /// Corner radius of the control the ring surrounds.
  final double radius;

  /// The control the ring is painted around.
  final Widget child;

  @override
  State<ItFocusRing> createState() => _ItFocusRingState();
}

class _ItFocusRingState extends State<ItFocusRing> {
  bool _descendantFocused = false;
  bool _keyboardMode =
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightModeChanged);
    super.dispose();
  }

  void _onHighlightModeChanged(FocusHighlightMode mode) {
    final next = mode == FocusHighlightMode.traditional;
    if (next == _keyboardMode || !mounted) return;
    setState(() => _keyboardMode = next);
  }

  void _onFocusChange(bool value) {
    if (value == _descendantFocused || !mounted) return;
    setState(() => _descendantFocused = value);
  }

  @override
  Widget build(BuildContext context) {
    final painted = widget.visible ||
        (widget.trackDescendants && _descendantFocused && _keyboardMode);

    // The [CustomPaint] is always present, even with no painter: returning
    // `child` directly when unfocused would change the widget type at this
    // slot the moment focus arrives, which remounts everything below — taking
    // the focus node with it, so the control would immediately lose the focus
    // that made the ring appear. A painterless [CustomPaint] draws nothing, so
    // this costs no pixels.
    final Widget painter = CustomPaint(
      foregroundPainter:
          painted ? ItFocusRingPainter(radius: widget.radius) : null,
      child: widget.child,
    );

    if (!widget.trackDescendants) return painter;

    // `canRequestFocus: false` + `skipTraversal: true` keeps this node out of
    // the Tab ring — it exists only to observe the focusable below it.
    // `includeSemantics: false` keeps it from inserting a semantics node,
    // which would sit between a component's own Semantics wrapper and its
    // content (and, in the tab bar, break Flutter's tab-role assertion).
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: _onFocusChange,
      child: painter,
    );
  }
}

/// Paints [ItFocusRing]'s two bands. Public so tests can assert on the
/// indicator actually being painted, whichever way the ring is driven.
class ItFocusRingPainter extends CustomPainter {
  /// Creates the painter for a ring of the given geometry.
  const ItFocusRingPainter({required this.radius});

  /// Corner radius of the control the ring surrounds.
  final double radius;

  /// Extra distance between the control's box and the ring.

  /// `box-shadow: 0 0 0 2px #fff` — the inner band, 0…2px outside the control.
  static const double _whiteBand = 2;

  /// `box-shadow: … , 0 0 0 5px #000` — the outer band, 2…5px outside.
  static const double _blackBand = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;

    void ring(double inset, double width, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          box.inflate(inset),
          Radius.circular(radius + inset),
        ),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width,
      );
    }

    // Strokes are centred on the path, so the black ring's centreline sits at
    // 2 + 3/2 = 3.5px out and the white one's at 2/2 = 1px out. Together they
    // tile 0…5px exactly as the two box-shadows do.
    ring(_whiteBand + _blackBand / 2, _blackBand, const Color(0xFF000000));
    ring(_whiteBand / 2, _whiteBand, const Color(0xFFFFFFFF));
  }

  @override
  bool shouldRepaint(ItFocusRingPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
