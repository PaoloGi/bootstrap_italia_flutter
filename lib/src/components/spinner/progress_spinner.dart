import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/theme_extensions.dart';

/// `.progress-spinner { border: 4px solid hsl(210,3%,85%) }` — the track ring,
/// which Bootstrap Italia paints under the moving arc at every size.
///
/// Stays a literal: hsl(210,3%,85%) matches no token in the palette. The
/// nearest, `--bs-gray-300` = hsl(0,0%,83%), is a neutral grey where this one is
/// faintly blue, and the stylesheet repeats this exact value 37 times as a
/// declaration of its own. Re-theming would not move it upstream either.
const Color kItSpinnerTrackColor = Color(0xFFD8D9DA);

/// `animation: spinnerAnim .75s …` — one turn (single) or one leg of the
/// alternating oscillation (double).
const Duration _period = Duration(milliseconds: 750);

/// `cubic-bezier(0.25, 0.1, 0.5, 1)`, the easing of both inner keyframes.
const Curve _innerCurve = Cubic(0.25, 0.1, 0.5, 1);

/// A full turn.
const double _tau = 2 * math.pi;

/// Half a turn — the angular length of one CSS border pair, and of the window
/// each `.progress-spinner-inner` clips its arc to.
const double _halfTurn = math.pi;

/// Bootstrap Italia's `.progress-spinner`, painted with a [CustomPaint].
///
/// Replaces Material's `CircularProgressIndicator`, which draws a different
/// shape (a growing/shrinking arc with no track, on Material's own 1333ms
/// rotation) on a design system that specifies its own.
///
/// The stylesheet, from `bootstrap-italia.min.css`:
///
/// ```css
/// .progress-spinner {
///   width: 48px; height: 48px; border-radius: 50%;
///   border: 4px solid hsl(210,3%,85%);
/// }
/// .progress-spinner.progress-spinner-active {
///   animation: spinnerAnim .75s linear infinite;
/// }
/// .progress-spinner.progress-spinner-active:not(.progress-spinner-double) {
///   border-color: hsl(210,17%,44%);
///   border-bottom-color: hsl(210,3%,85%);
/// }
/// @keyframes spinnerAnim { 0% { transform: rotate(0) }
///                          100% { transform: rotate(360deg) } }
/// ```
///
/// A CSS border on a `border-radius: 50%` box renders as four quarter arcs
/// mitred on the 45° diagonals, so recolouring three of the four sides leaves a
/// **270° run** whose gap is centred on 6 o'clock: it starts at the
/// bottom-left diagonal and sweeps clockwise. `box-sizing: border-box` puts the
/// border inside the declared 48px, so the stroke's centreline sits
/// `strokeWidth / 2` in from the edge.
///
/// The double variant is a second, more involved figure:
///
/// ```css
/// .progress-spinner-double .progress-spinner-inner {
///   width: 48px; height: 24px; overflow: hidden; margin-left: -4px }
/// .progress-spinner-double .progress-spinner-inner:nth-child(1) {
///   margin-top: -4px }
/// .progress-spinner-double .progress-spinner-inner:nth-child(2) {
///   transform: rotate(180deg) }
/// .progress-spinner-double .progress-spinner-inner:after {
///   transform: rotate(45deg); border-radius: 50%;
///   border: 4px solid hsl(210,17%,44%);
///   border-right: 4px solid rgba(0,0,0,0);
///   border-bottom: 4px solid rgba(0,0,0,0);
///   width: 100%; height: 200%;
///   animation: spinnerAnimInner1 .75s cubic-bezier(.25,.1,.5,1)
///              infinite alternate }
/// .progress-spinner-double .progress-spinner-inner:nth-child(2):after {
///   animation-name: spinnerAnimInner2 }
/// @keyframes spinnerAnimInner1 { 0% { transform: rotate(60deg) }
///                                100% { transform: rotate(205deg) } }
/// @keyframes spinnerAnimInner2 { 0% { transform: rotate(30deg) }
///                                100% { transform: rotate(-105deg) } }
/// ```
///
/// Unpacked: the pseudo-element is a full circle the size of the spinner whose
/// `border-top` + `border-left` form one contiguous **180° run**, and each
/// `.progress-spinner-inner` is a 48x24 `overflow: hidden` window over one half
/// of it. The negative margins put the first window over the top half; the
/// second window sits over the bottom half and its `rotate(180deg)` both brings
/// the pseudo-element's circle back onto the spinner's centre and adds 180° to
/// its rotation. So each half shows the intersection of a 180° run with a 180°
/// window, which is always a single arc that lengthens and shortens as the two
/// keyframes oscillate in opposite directions.
class ItProgressSpinner extends StatefulWidget {
  /// Outer diameter, border included (`box-sizing: border-box`).
  final double diameter;

  /// Ring thickness — the CSS `border-width`.
  final double strokeWidth;

  /// Colour of the moving arc.
  ///
  /// Defaults to the theme's `secondary`, which is what
  /// `.progress-spinner-active` declares — see the note in `build`.
  final Color? color;

  /// Colour of the full-circle track behind the arc.
  ///
  /// Defaults to the CSS [kItSpinnerTrackColor]. Pass a fully transparent
  /// colour for the inline spinners (a button label, a field affix) that
  /// Bootstrap Italia has no `.progress-spinner` element for.
  final Color trackColor;

  /// Whether to paint `.progress-spinner-double` instead of the single arc.
  final bool doubleRing;

  /// Whether the arc rotates.
  ///
  /// In the stylesheet `.progress-spinner` is a STATIC ring and only
  /// `.progress-spinner-active` animates, so a resting spinner must not spin.
  /// Beyond fidelity this matters twice over: an always-running controller
  /// burns a frame every vsync for a component that is doing nothing, and it
  /// makes `pumpAndSettle` hang in any test that contains one.
  final bool animating;

  /// Creates a Bootstrap Italia spinner.
  const ItProgressSpinner({
    super.key,
    required this.diameter,
    required this.strokeWidth,
    this.color,
    this.trackColor = kItSpinnerTrackColor,
    this.doubleRing = false,
    this.animating = true,
  });

  @override
  State<ItProgressSpinner> createState() => _ItProgressSpinnerState();
}

class _ItProgressSpinnerState extends State<ItProgressSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _period);

  @override
  void initState() {
    super.initState();
    _start();
  }

  /// `infinite` for the single spinner, `infinite alternate` for the double.
  ///
  /// Drives the controller only while animating, so a resting spinner holds one
  /// frame instead of scheduling forever.
  void _start() {
    if (!widget.animating) {
      _controller.stop();
      _controller.value = 0;
      return;
    }
    if (widget.doubleRing) {
      _controller.repeat(reverse: true);
    } else {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ItProgressSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doubleRing != widget.doubleRing ||
        oldWidget.animating != widget.animating) {
      _start();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `.progress-spinner.progress-spinner-active:not(.progress-spinner-double)
    //   { border-color: hsl(210,17%,44%) }`, and the double variant's
    // `:after { border: 4px solid hsl(210,17%,44%) }` — byte-identical to
    // `--bs-secondary`. The same value is also declared as `--bs-gray-secondary`
    // and used as muted metadata elsewhere, where it is the grey and must stay
    // literal; here it is the figure's one chromatic element, painted on top of
    // the grey track, so it is the accent and follows the theme.
    //
    // [ItSpinner] passes `primary` explicitly — the package's louder default for
    // a standalone loading indicator. This is what the stylesheet itself asks
    // for when no caller names a colour.
    final arcColor = widget.color ?? resolveColorScheme(context).secondary;

    return SizedBox(
      width: widget.diameter,
      height: widget.diameter,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: ItProgressSpinnerPainter(
            // `linear` for the single spinner's rotation; the double's two
            // keyframes carry the cubic-bezier easing instead.
            t: widget.doubleRing
                ? _innerCurve.transform(_controller.value)
                : _controller.value,
            color: arcColor,
            trackColor: widget.trackColor,
            strokeWidth: widget.strokeWidth,
            doubleRing: widget.doubleRing,
            active: widget.animating,
          ),
        ),
      ),
    );
  }
}

/// Paints [ItProgressSpinner]. Public so tests can assert on the geometry and
/// colours actually being drawn.
class ItProgressSpinnerPainter extends CustomPainter {
  /// Animation position, 0..1, already eased.
  final double t;

  /// Colour of the moving arc.
  final Color color;

  /// Colour of the full-circle track.
  final Color trackColor;

  /// Ring thickness.
  final double strokeWidth;

  /// Whether to paint the double variant.
  final bool doubleRing;

  /// Whether to paint the coloured arc at all.
  ///
  /// `.progress-spinner` is only a grey ring; the arc appears with
  /// `.progress-spinner-active`, which recolours three of the four borders and
  /// leaves the fourth as track. A resting spinner that paints an arc looks
  /// like it is mid-spin but frozen.
  final bool active;

  /// Creates the painter for one frame of the spinner.
  const ItProgressSpinnerPainter({
    required this.t,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.doubleRing,
    required this.active,
  });

  /// Canvas angle of the bottom-left diagonal, where the recoloured 270° run
  /// begins (0 is 3 o'clock and sweeps are clockwise, so 6 o'clock is π/2 and
  /// the `border-bottom` quarter it belongs to spans π/4…3π/4).
  static const double _bottomLeftDiagonal = 3 * math.pi / 4;

  /// `border-color` minus `border-bottom-color`: three of four quarters.
  static const double _threeQuarters = 3 * math.pi / 2;

  static double _rad(double degrees) => degrees * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    // `box-sizing: border-box`: the border is drawn inside the declared box, so
    // the stroke centreline is half a stroke in from the edge.
    final rect =
        Rect.fromLTWH(0, 0, size.width, size.height).deflate(strokeWidth / 2);

    Paint stroke(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // `border: 4px solid hsl(210,3%,85%)` — the full circle, always present
    // under the arc. Skipped when the caller asks for no track at all.
    if (trackColor.a > 0) {
      canvas.drawArc(rect, 0, _tau, false, stroke(trackColor));
    }

    if (!active) return; // grey track only, per `.progress-spinner`

    final arc = stroke(color);

    if (!doubleRing) {
      // One 270° run, rotated `t` of a full turn by `spinnerAnim`.
      canvas.drawArc(
        rect,
        _bottomLeftDiagonal + t * _tau,
        _threeQuarters,
        false,
        arc,
      );
      return;
    }

    // `spinnerAnimInner1`: 60deg -> 205deg, over the top half (canvas π…2π).
    _windowedRun(canvas, rect, arc, _rad(_lerp(60, 205)), _halfTurn);

    // `spinnerAnimInner2`: 30deg -> -105deg, over the bottom half (0…π). The
    // container's own `rotate(180deg)` adds a half turn on top.
    _windowedRun(canvas, rect, arc, _rad(_lerp(30, -105)) + _halfTurn, 0);
  }

  double _lerp(double from, double to) => from + (to - from) * t;

  /// Strokes the part of the 180° run beginning at [runStart] that falls inside
  /// the 180° window beginning at [windowStart] — the `overflow: hidden` clip.
  ///
  /// Two arcs of exactly 180° on a circle always overlap in a single
  /// contiguous run: with `d` the run's offset into the window, the overlap is
  /// the window's tail (length `π - d`) while `d <= π`, and the window's head
  /// (length `d - π`) once the run has wrapped past it.
  void _windowedRun(
    Canvas canvas,
    Rect rect,
    Paint paint,
    double runStart,
    double windowStart,
  ) {
    final d = (runStart - windowStart) % _tau;
    final double start;
    final double sweep;
    if (d <= _halfTurn) {
      start = windowStart + d;
      sweep = _halfTurn - d;
    } else {
      start = windowStart;
      sweep = d - _halfTurn;
    }
    if (sweep <= 0) return;
    canvas.drawArc(rect, start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(ItProgressSpinnerPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.doubleRing != doubleRing ||
      oldDelegate.active != active;
}
