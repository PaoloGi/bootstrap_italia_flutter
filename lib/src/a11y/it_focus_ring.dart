import 'package:flutter/widgets.dart';

import 'keyboard_focus_mode.dart';

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
/// only, and it takes two things to say so in Flutter. After a touch,
/// [FocusManager.highlightMode] turns highlights off — that is what
/// [FocusableActionDetector.onShowFocusHighlight] is driven by and what
/// [trackDescendants] consults. But a mouse leaves the mode alone, so the ring
/// also classifies each focus as it arrives, by whether the last press was a
/// mouse button: the kit's port of `track-focus.js`, which sets the attribute
/// on `focusin` and keeps it until `focusout`. A field clicked into shows no
/// ring, typing into it does not give it one, and Tab does.
///
/// Black on the white page background is 21:1, and the black band is 3px wide,
/// so the indicator satisfies WCAG 2.2 **2.4.7 Focus Visible** (AA) and also
/// clears the stricter contrast and area thresholds of 2.4.13 Focus Appearance.
///
/// The ring is drawn as two bands cut out at the control's edge rather than as
/// a [BoxShadow]: a shadow paints a filled shape behind the child, which shows
/// through controls whose interior is transparent — an unchecked checkbox
/// row, or a text field, where it once filled the whole field. Cutting out
/// keeps the paint entirely outside the control's own box, so the widget's
/// size — and therefore the pixel parity of every unfocused capture — is
/// unchanged.
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
    this.onDark = false,
  });

  /// Whether the control has the focus this indicator is for — typically
  /// [FocusableActionDetector.onShowFocusHighlight]'s value.
  ///
  /// Not quite "painted": focus that arrived from a mouse press still shows no
  /// ring, as on the web (see the class documentation). OR-ed with
  /// [trackDescendants], so a caller may set both.
  final bool visible;

  /// Whether to watch the subtree's own focus instead of relying on [visible].
  ///
  /// Set this where the focusable widget is a descendant that does not expose
  /// a focus callback — an [InkWell], for example.
  final bool trackDescendants;

  /// Corner radius of the control the ring surrounds.
  final double radius;

  /// Whether the control sits on a dark surface, which inverts the two bands.
  ///
  /// See [ItFocusRingPainter.onDark].
  final bool onDark;

  /// The control the ring is painted around.
  final Widget child;

  @override
  State<ItFocusRing> createState() => _ItFocusRingState();
}

class _ItFocusRingState extends State<ItFocusRing> {
  bool _descendantFocused = false;
  bool _keyboardMode =
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  /// Whether the focus being shown arrived from a mouse press. Decided when it
  /// arrives and then kept, as `data-focus-mouse` is.
  bool _focusFromMouse = false;

  @override
  void initState() {
    super.initState();
    FocusModality.ensureListening();
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChanged);
    if (widget.visible) _focusFromMouse = FocusModality.lastPressWasMouse;
  }

  @override
  void didUpdateWidget(ItFocusRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _focusFromMouse = FocusModality.lastPressWasMouse;
    }
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
    setState(() {
      _descendantFocused = value;
      if (value) _focusFromMouse = FocusModality.lastPressWasMouse;
    });
  }

  @override
  Widget build(BuildContext context) {
    final painted = (widget.visible ||
            (widget.trackDescendants && _descendantFocused && _keyboardMode)) &&
        !_focusFromMouse;

    // The [CustomPaint] is always present, even with no painter: returning
    // `child` directly when unfocused would change the widget type at this
    // slot the moment focus arrives, which remounts everything below — taking
    // the focus node with it, so the control would immediately lose the focus
    // that made the ring appear. A painterless [CustomPaint] draws nothing, so
    // this costs no pixels.
    final Widget painter = CustomPaint(
      foregroundPainter: painted
          ? ItFocusRingPainter(radius: widget.radius, onDark: widget.onDark)
          : null,
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
  const ItFocusRingPainter({required this.radius, this.onDark = false});

  /// Corner radius of the control the ring surrounds.
  final double radius;

  /// `box-shadow: 0 0 0 2px #fff` — the inner band, 0…2px outside the control.
  static const double _whiteBand = 2;

  /// `box-shadow: … , 0 0 0 5px #000` — the outer band, 2…5px outside.
  static const double _blackBand = 3;

  /// Whether the control sits on a dark surface.
  ///
  /// `.bg-dark .btn:focus:not([data-focus-mouse=true])` and
  /// `.back-to-top.dark:focus…` declare
  /// `box-shadow: 0 0 0 2px #000, 0 0 0 5px #fff` — the same two bands in the
  /// opposite order. It is not decoration: the indicator's own contrast is what
  /// §2.4.11 Focus Appearance measures, and a white-then-black ring on a dark
  /// band puts the black outer band against near-black.
  final bool onDark;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    final control = RRect.fromRectAndRadius(box, Radius.circular(radius));

    RRect grown(double spread) => RRect.fromRectAndRadius(
          box.inflate(spread),
          Radius.circular(_spreadRadius(radius, spread)),
        );

    const black = Color(0xFF000000);
    const white = Color(0xFFFFFFFF);
    final inner = onDark ? black : white;
    final outer = onDark ? white : black;

    // Filled, in the order the two box-shadows stack — the 5px one, then the
    // 2px one over it — and each cut out at the control's edge, as a
    // box-shadow is clipped to outside the border box.
    canvas
      ..drawDRRect(
          grown(_whiteBand + _blackBand), control, Paint()..color = outer)
      ..drawDRRect(grown(_whiteBand), control, Paint()..color = inner);
  }

  /// A spread shadow's corner radius, per CSS Backgrounds 3: the border radius
  /// grows by the spread — except that a radius smaller than the spread grows
  /// by `spread * (1 + (radius / spread - 1)^3)`, so a square control keeps
  /// square corners at every spread. Stroking the bands along a path of
  /// `radius + inset` rounded them instead, to 5px at the outer edge of a
  /// field whose `border-radius` is 0.
  static double _spreadRadius(double radius, double spread) {
    if (radius >= spread) return radius + spread;
    final ratio = radius / spread - 1;
    return radius + spread * (1 + ratio * ratio * ratio);
  }

  @override
  bool shouldRepaint(ItFocusRingPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.onDark != onDark;
}
