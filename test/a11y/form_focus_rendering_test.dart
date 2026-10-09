// What a focused text field actually paints — read back from the rasterised
// pixels, and checked against design-react-kit measured in a real browser.
//
// Reported from a real app, twice. First a focused field filled grey-blue
// across its whole width, with a thick underline over the kit's own border;
// then, with the fill removed, a grey-blue frame around it.
//
// Both were the same mistake. `.form-control:focus` declares
// `box-shadow: 0 0 0 .25rem rgba(0,102,204,.25)`, and the port painted it. But
// that rule never wins: Italia overrides it with `!important` for both ways
// focus can arrive, and design-react-kit loads the `track-focus.js` that tells
// them apart. Computed styles in Chromium, on the docs' input story:
//
//   mouse, touch    box-shadow none                              border #1A1A1A
//   keyboard (Tab)  box-shadow #fff 0 0 0 2px, #000 0 0 0 5px    border #000
//
// So a tapped field only darkens its border, and a keyboard-focused one gets
// the kit-wide black ring. The underline was a separate leak: the TextField set
// only `border: InputBorder.none`, so `toThemeData()`'s `focusedBorder` was
// merged in.
//
// Nothing else could see any of it. The parity captures are taken unfocused,
// and the theming contract asserted that the ring followed primary — which it
// did, faithfully painting a rule the stylesheet discards.
import 'dart:ui' as ui;

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _white = Color(0xFFFFFFFF);
const _black = Color(0xFF000000);

/// `input[type=text] { border-bottom: 1px solid hsl(210,17%,44%) }` — measured
/// on design-react-kit as rgb(93,112,131).
const _restingBorder = Color(0xFF5D7083);

/// `[data-focus-mouse=true] { border-color: inherit !important }` — the text
/// colour, measured as rgb(26,26,26).
const _pointerFocusBorder = Color(0xFF1A1A1A);

enum _Via { rest, touch, mouse, keyboard }

/// Mounts [field] under [scheme] with `toThemeData()` — the configuration a
/// real app uses, and the only one in which the leaked border appears — then
/// focuses it [via] a touch, a mouse or the keyboard.
Future<GlobalKey> _mount(
  WidgetTester tester,
  BootstrapItaliaColorScheme scheme,
  Widget field,
  _Via via,
) async {
  final key = GlobalKey();
  final theme = BootstrapItaliaThemeData(colors: scheme);
  tester.view.physicalSize = const Size(800, 320);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(RepaintBoundary(
    key: key,
    child: BootstrapItaliaTheme(
      data: theme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.toThemeData(),
        home: Scaffold(
          backgroundColor: _white,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            child: field,
          ),
        ),
      ),
    ),
  ));
  switch (via) {
    case _Via.rest:
      break;
    case _Via.touch:
      // `tester.tap` is a PointerDeviceKind.touch: what a phone sends.
      await tester.tap(find.byType(TextField));
    case _Via.mouse:
      // A desktop: a mouse press leaves Flutter's highlight mode in the
      // keyboard one, which is how a click came to draw the keyboard ring.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic);
      await tester.tap(find.byType(TextField), kind: PointerDeviceKind.mouse);
    case _Via.keyboard:
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  }
  await tester.pumpAndSettle();
  // Every "nothing is painted" check below would pass on an unfocused field,
  // so first make sure focus really landed.
  final hasFocus =
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;
  expect(hasFocus, via != _Via.rest, reason: 'focus did not land as intended');
  return key;
}

/// The control box — `.form-control` — that the ring surrounds.
Rect _control(WidgetTester tester) => tester.getRect(find
    .ancestor(of: find.byType(TextField), matching: find.byType(ItFocusRing))
    .first);

/// Reads back the pixels actually rasterised, at logical [points].
Future<List<Color>> _sample(
  WidgetTester tester,
  GlobalKey key,
  List<Offset> points,
) async {
  late List<Color> out;
  await tester.runAsync(() async {
    final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2);
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    out = [
      for (final p in points)
        () {
          final i = (((p.dy * 2).round()) * img.width + (p.dx * 2).round()) * 4;
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

/// Within a few levels per channel — enough to absorb edge antialiasing, far
/// too little to confuse #1A1A1A with #000 or #5D7083.
Matcher _near(Color expected) => predicate<Color>(
      (c) =>
          (c.r - expected.r).abs() * 255 <= 6 &&
          (c.g - expected.g).abs() * 255 <= 6 &&
          (c.b - expected.b).abs() * 255 <= 6,
      'within 6/255 of ${_hex(expected)}',
    );

/// Where each check looks, relative to the control box.
Offset _inside(Rect box) => Offset(box.right - 20, box.center.dy);
Offset _borderRow(Rect box) => Offset(box.center.dx, box.bottom - 0.5);

/// 2px out: the old 25% ring's band, and the keyboard ring's white one.
Offset _nearRing(Rect box) => Offset(box.left - 2, box.center.dy);

/// 3.5px out: the keyboard ring's black band.
Offset _outerRing(Rect box) => Offset(box.left - 3.5, box.center.dy);

void main() {
  final schemes = {
    'standard': BootstrapItaliaColorScheme.standard,
    // A real administration's palette — the one both reports came from.
    'slate': BootstrapItaliaColorScheme.standard
        .copyWith(primary: const Color(0xFF2C546B)),
  };

  final fields = <String, Widget Function()>{
    'ItInput': () => ItInput(
          label: 'Attiva il COC presso',
          controller: TextEditingController(text: 'TESTTEST'),
          groupMargin: false,
        ),
    'ItAutocomplete': () => ItAutocomplete<String>(
          label: 'Comune',
          onSearch: (q) async => const <String>[],
          displayStringForOption: (o) => o,
          groupMargin: false,
        ),
  };

  for (final s in schemes.entries) {
    for (final f in fields.entries) {
      group('${f.key}, ${s.key} palette', () {
        testWidgets('at rest: the resting border, and no ring', (tester) async {
          // Also proves the sampling points: were [_borderRow] off by a row,
          // the focused checks below could pass on the page background.
          final key = await _mount(tester, s.value, f.value(), _Via.rest);
          final box = _control(tester);
          final [border, near, outer] = await _sample(
              tester, key, [_borderRow(box), _nearRing(box), _outerRing(box)]);
          expect(border, _near(_restingBorder), reason: _hex(border));
          expect([near, outer], everyElement(_white));
        });

        testWidgets('after a tap: no ring — neither the 25% one nor the black',
            (tester) async {
          final key = await _mount(tester, s.value, f.value(), _Via.touch);
          final box = _control(tester);
          final [near, outer] =
              await _sample(tester, key, [_nearRing(box), _outerRing(box)]);
          expect(near, _white,
              reason: '${_hex(near)} just outside a tapped field: '
                  '`.form-control:focus`\'s ring is painted, but Italia '
                  'overrides it with `box-shadow: none !important`');
          expect(outer, _white,
              reason: '${_hex(outer)}: the keyboard ring is shown for a tap');
        });

        testWidgets('after a tap: the border darkens to the text colour',
            (tester) async {
          final key = await _mount(tester, s.value, f.value(), _Via.touch);
          final [border] =
              await _sample(tester, key, [_borderRow(_control(tester))]);
          expect(border, _near(_pointerFocusBorder),
              reason: 'measured on design-react-kit: `border-color: inherit`, '
                  'rgb(26,26,26); painted ${_hex(border)}');
        });

        testWidgets('after a tap: the field is not filled, and no second line',
            (tester) async {
          final key = await _mount(tester, s.value, f.value(), _Via.touch);
          final box = _control(tester);
          final field = tester.getRect(find.byType(TextField));
          final [inside, edge] = await _sample(tester, key,
              [_inside(box), Offset(box.right - 20, field.bottom - 1)]);
          expect(inside, _white,
              reason: 'the focused field is filled ${_hex(inside)}');
          expect(edge, _white,
              reason: 'a line (${_hex(edge)}) on the text field\'s own bottom '
                  'edge: the theme\'s focusedBorder has leaked into it');
        });

        testWidgets('after a mouse click: no ring, and the text-colour border',
            (tester) async {
          // design-react-kit, measured: identical to a tap — `track-focus.js`
          // sets `data-focus-mouse` on mousedown.
          final key = await _mount(tester, s.value, f.value(), _Via.mouse);
          final box = _control(tester);
          final [near, outer, border] = await _sample(
              tester, key, [_nearRing(box), _outerRing(box), _borderRow(box)]);
          expect([near, outer], everyElement(_white),
              reason: 'a ring around a clicked field: ${_hex(near)} / '
                  '${_hex(outer)}');
          expect(border, _near(_pointerFocusBorder),
              reason: 'measured rgb(26,26,26) after a click; painted '
                  '${_hex(border)}');
        });

        testWidgets('after Tab: the black ring', (tester) async {
          final key = await _mount(tester, s.value, f.value(), _Via.keyboard);
          final [outer] =
              await _sample(tester, key, [_outerRing(_control(tester))]);
          expect(outer, _black,
              reason: 'WCAG 2.4.7: `box-shadow: 0 0 0 2px #fff, 0 0 0 5px #000`'
                  ' — painted ${_hex(outer)}');
        });

        testWidgets('after Tab: a black border, and the field not filled',
            (tester) async {
          final key = await _mount(tester, s.value, f.value(), _Via.keyboard);
          final box = _control(tester);
          final [border, inside] =
              await _sample(tester, key, [_borderRow(box), _inside(box)]);
          expect(border, _near(_black),
              reason:
                  '`border-color: #000 !important`; painted ${_hex(border)}');
          expect(inside, _white,
              reason: 'the focused field is filled ${_hex(inside)}');
        });
      });
    }
  }
}
