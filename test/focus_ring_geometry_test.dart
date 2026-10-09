// The ring's shape, against the two box-shadows it stands for:
//
//   :focus:not([data-focus-mouse=true]) { box-shadow: 0 0 0 2px #fff, 0 0 0 5px #000 }
//
// A spread shadow's corners follow CSS Backgrounds 3: the border radius grows
// by the spread, but a radius below the spread grows by less, and a radius of
// 0 not at all — so a text field (`border-radius: 0`) has a square ring, which
// is how design-react-kit draws it in Chromium. The painter stroked each band
// along a path of `radius + inset`, which rounded a square control's ring to
// 5px at its outer edge.
import 'dart:ui' as ui;

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _white = Color(0xFFFFFFFF);
const _black = Color(0xFF000000);
const _darkBand = Color(0xFF17324D);

/// The control's top-left corner on the surface; samples are relative to it.
const _origin = Offset(40, 40);

/// Paints a focused 120×40 control of [radius] on a plain surface, and reads
/// back the rasterised pixels at [at] (relative to the control's top-left).
Future<List<Color>> _ring(
  WidgetTester tester, {
  required double radius,
  bool onDark = false,
  required List<Offset> at,
}) async {
  final key = GlobalKey();
  tester.view.physicalSize = const Size(400, 240);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(RepaintBoundary(
    key: key,
    child: ColoredBox(
      color: onDark ? _darkBand : _white,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(left: _origin.dx, top: _origin.dy),
          child: ItFocusRing(
            visible: true,
            radius: radius,
            onDark: onDark,
            child: const SizedBox(width: 120, height: 40),
          ),
        ),
      ),
    ),
  ));
  late List<Color> out;
  await tester.runAsync(() async {
    final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2);
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    out = [
      for (final p in at)
        () {
          final q = _origin + p;
          final i = ((q.dy * 2).round() * img.width + (q.dx * 2).round()) * 4;
          return Color.fromARGB(255, bytes.getUint8(i), bytes.getUint8(i + 1),
              bytes.getUint8(i + 2));
        }(),
    ];
    img.dispose();
  });
  return out;
}

String _hex(Color c) =>
    '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

void main() {
  testWidgets('along a side: 2px white, then 3px black, then nothing',
      (tester) async {
    final [inner, outer, beyond, inside] = await _ring(tester, radius: 0, at: [
      const Offset(-1, 20),
      const Offset(-3.5, 20),
      const Offset(-6, 20),
      const Offset(1, 20),
    ]);
    expect(inner, _white, reason: 'the 2px band: ${_hex(inner)}');
    expect(outer, _black, reason: 'the 5px band: ${_hex(outer)}');
    expect(beyond, _white, reason: 'the ring ends at 5px: ${_hex(beyond)}');
    expect(inside, _white,
        reason: 'a box-shadow is clipped to outside the control, so nothing '
            'is painted inside it: ${_hex(inside)}');
  });

  testWidgets('a square control has a square ring', (tester) async {
    // 0.5px in from the outer band's corner on both axes: inside the ring if
    // it is square, beyond it if the corner is rounded at all past ~0.7px.
    final [corner] =
        await _ring(tester, radius: 0, at: [const Offset(-4.5, -4.5)]);
    expect(corner, _black,
        reason: 'box-shadow spread keeps a 0 radius at 0; the ring was '
            'rounded to 5px here (${_hex(corner)} at the corner)');
  });

  testWidgets('a rounded control keeps a rounded ring', (tester) async {
    // radius 4 < spread 5: 4 + 5 * (1 + (4/5 - 1)^3) = 8.96px at the outer
    // edge, so the same point lies well outside the corner.
    final [corner, side] = await _ring(tester,
        radius: 4, at: [const Offset(-4.5, -4.5), const Offset(-3.5, 20)]);
    expect(corner, _white,
        reason: 'the corner must follow the control\'s own rounding: '
            '${_hex(corner)}');
    expect(side, _black);
  });

  testWidgets(
      'onDark: the same bands, in the opposite order, and nothing '
      'inside', (tester) async {
    // Inside is sampled here rather than on the light surface: there the
    // inner band is white on white, so paint inside the control is invisible.
    final [inner, outer, inside] = await _ring(tester,
        radius: 0,
        onDark: true,
        at: [
          const Offset(-1, 20),
          const Offset(-3.5, 20),
          const Offset(1, 20)
        ]);
    expect(inner, _black);
    expect(outer, _white);
    expect(inside, _darkBand,
        reason: 'the ring painted inside the control: ${_hex(inside)}');
  });
}
