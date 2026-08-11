import 'package:flutter/widgets.dart';

import '../../theme/theme_extensions.dart';

/// Draws Bootstrap Italia's `it-expand` sprite (the chevron used by every
/// header dropdown toggle):
/// `M11.6 15.4 6 9.8l.7-.8 4.9 4.9L16.5 9l.7.8z` on a 24x24 viewBox.
///
/// Painted rather than taken from an icon font so headers render identically
/// without callers having to wire up an icon package.
class ItExpandChevron extends StatelessWidget {
  /// Box size in logical pixels. Bootstrap Italia renders it at 18px inside
  /// headers (`.it-header-slim-wrapper ... a .icon { width: 18px }`).
  final double size;

  /// Fill color. Defaults to the theme's `white`.
  final Color? color;

  /// Flips the chevron vertically, matching
  /// `a.dropdown-toggle[aria-expanded=true] > .icon { transform: scaleY(-1) }`.
  final bool expanded;

  /// Creates the chevron glyph.
  const ItExpandChevron({
    super.key,
    this.size = 18,
    this.color,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    // `.it-header-slim-wrapper .it-header-slim-wrapper-content a .icon
    //   { fill: #fff }` — the white token, not a fixed white: the slim band
    // recolours wholesale under `.theme-light`, where the same sprite is
    // `fill: #06c`. Callers on a light band pass `color` explicitly.
    final effectiveColor = color ?? resolveColorScheme(context).white;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ExpandPainter(effectiveColor, expanded)),
    );
  }
}

/// Draws Bootstrap Italia's `it-arrow-right-triangle` sprite — the bullet in
/// front of every megamenu link:
/// `M12 14.8V9.2c0-.6.5-1 1-1 .3 0 .5.1.7.3l3.5 3.5-3.5 3.5c-.4.4-1 .4-1.4 0
///  -.2-.2-.3-.4-.3-.7z` on a 24x24 viewBox.
class ItArrowRightTriangle extends StatelessWidget {
  /// Box size in logical pixels.
  final double size;

  /// Fill color. Defaults to the theme's `primary`.
  final Color? color;

  /// Creates the triangle bullet.
  const ItArrowRightTriangle({
    super.key,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // `.megamenu a.nav-link:before { background-color: #06c }` and
    // `.navbar .dropdown-menu a.it-heading-link { color: #06c }` — the bullet
    // takes the link accent, byte-identical to `--bs-primary`
    // (`hsl(210, 100%, 40%)`) and to `--bs-link-color`.
    final effectiveColor = color ?? resolveColorScheme(context).primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TrianglePainter(effectiveColor)),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  const _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 24.0;
    Offset p(double x, double y) => Offset(x * s, y * s);
    final path = Path()
      ..moveTo(12 * s, 14.8 * s)
      ..lineTo(12 * s, 9.2 * s)
      ..cubicTo(p(12, 8.6).dx, p(12, 8.6).dy, p(12.5, 8.2).dx, p(12.5, 8.2).dy,
          p(13, 8.2).dx, p(13, 8.2).dy)
      ..cubicTo(p(13.3, 8.2).dx, p(13.3, 8.2).dy, p(13.5, 8.3).dx,
          p(13.5, 8.3).dy, p(13.7, 8.5).dx, p(13.7, 8.5).dy)
      ..lineTo(17.2 * s, 12 * s)
      ..lineTo(13.7 * s, 15.5 * s)
      ..cubicTo(p(13.3, 15.9).dx, p(13.3, 15.9).dy, p(12.7, 15.9).dx,
          p(12.7, 15.9).dy, p(12.3, 15.5).dx, p(12.3, 15.5).dy)
      ..cubicTo(p(12.1, 15.3).dx, p(12.1, 15.3).dy, p(12, 15.1).dx,
          p(12, 15.1).dy, p(12, 14.8).dx, p(12, 14.8).dy)
      ..close();
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

/// Draws Bootstrap Italia's `it-search` sprite: a hairline ring of radius 7.5
/// centred on (10,10) with a handle running to (21.9,21.1), on a 24x24
/// viewBox.
class ItSearchGlyph extends StatelessWidget {
  /// Box size in logical pixels.
  final double size;

  /// Stroke color. Defaults to the theme's `primary`.
  final Color? color;

  /// Creates the magnifier glyph.
  const ItSearchGlyph({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // The magnifier sits inside `a.rounded-icon { background: #fff }`, so in
    // the default band it is drawn in the brand accent — byte-identical to
    // `--bs-primary` (`hsl(210, 100%, 40%)`). Under `.theme-light` the circle
    // and glyph swap (`…a { background: #06c }`, `…svg { fill: #fff }`) and the
    // caller passes `color` explicitly.
    final effectiveColor = color ?? resolveColorScheme(context).primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SearchPainter(effectiveColor)),
    );
  }
}

class _SearchPainter extends CustomPainter {
  final Color color;

  const _SearchPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 24.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(10 * s, 10 * s), 7.5 * s, paint);
    canvas.drawLine(
      Offset(15.6 * s, 15.6 * s),
      Offset(21.5 * s, 21.5 * s),
      paint..strokeWidth = 1.13 * s,
    );
  }

  @override
  bool shouldRepaint(_SearchPainter old) => old.color != color;
}

class _ExpandPainter extends CustomPainter {
  final Color color;
  final bool expanded;

  const _ExpandPainter(this.color, this.expanded);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 24.0;
    if (expanded) {
      canvas.translate(0, size.height);
      canvas.scale(1, -1);
    }
    final path = Path()
      ..moveTo(11.6 * s, 15.4 * s)
      ..lineTo(6.0 * s, 9.8 * s)
      ..lineTo(6.7 * s, 9.0 * s)
      ..lineTo(11.6 * s, 13.9 * s)
      ..lineTo(16.5 * s, 9.0 * s)
      ..lineTo(17.2 * s, 9.8 * s)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ExpandPainter old) =>
      old.color != color || old.expanded != expanded;
}
