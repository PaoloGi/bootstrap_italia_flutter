// Focus that arrives from a mouse press shows no ring — as on the web.
//
// Bootstrap Italia shows its ring for `:focus:not([data-focus-mouse=true])`,
// and `track-focus.js` — which design-react-kit loads — sets that attribute on
// whatever gains focus while the last input was a `mousedown`, and keeps it
// until `focusout`. Measured in Chromium on the docs' input story: box-shadow
// `none` after a click, the black ring after Tab.
//
// Flutter had half of it. A touch switches FocusManager.highlightMode off the
// keyboard mode, so phones never drew a ring on a tap. A mouse leaves the mode
// alone, so on a desktop a clicked field — or a select handed focus back after
// a pick — drew the keyboard ring. These run as macOS, where the mode starts in
// the keyboard one and a click keeps it there.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final Finder _paintedRing = find.byWidgetPredicate(
  (w) => w is CustomPaint && w.foregroundPainter is ItFocusRingPainter,
);

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        home: Scaffold(
          body: Center(child: SizedBox(width: 320, child: child)),
        ),
      ),
    );

final _desktop = TargetPlatformVariant.only(TargetPlatform.macOS);

Future<void> _click(WidgetTester t, Finder f) async {
  await t.tap(f, kind: PointerDeviceKind.mouse);
  await t.pumpAndSettle();
}

Future<void> _tab(WidgetTester t) async {
  await t.sendKeyEvent(LogicalKeyboardKey.tab);
  await t.pumpAndSettle();
}

/// A key that moves no focus, then a rebuild. Were focus classified by the
/// *latest* press rather than the one it arrived with, this would light it.
Future<void> _keyThenRebuild(WidgetTester t, Widget Function() tree) async {
  await t.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
  await t.pumpWidget(tree());
  await t.pumpAndSettle();
}

const _keptItsClass = '`data-focus-mouse` is set on focusin and kept until '
    'focusout: a later key press does not turn a clicked control\'s focus into '
    'keyboard focus';

/// A control that takes focus when clicked, through [ItActivatable] — the
/// path every button-like control's ring takes.
Widget _clickToFocus(FocusNode node, Key key) => ItActivatable(
      key: key,
      focusNode: node,
      onPressed: node.requestFocus,
      child: const SizedBox(width: 80, height: 40),
    );

/// The same, through [ItFocusRing.trackDescendants].
Widget _trackedClickToFocus(FocusNode node, Key key) => ItFocusRing(
      trackDescendants: true,
      child: Focus(
        focusNode: node,
        child: GestureDetector(
          key: key,
          behavior: HitTestBehavior.opaque,
          onTap: node.requestFocus,
          child: const SizedBox(width: 80, height: 40),
        ),
      ),
    );

void main() {
  testWidgets('premise: on a desktop, a mouse press keeps the keyboard mode',
      (t) async {
    // Without this, every "no ring after a click" below could pass because
    // the highlight mode had simply gone to touch.
    await t.pumpWidget(_host(const ItInput(label: 'Nome', groupMargin: false)));
    await _click(t, find.byType(TextField));
    expect(FocusManager.instance.highlightMode, FocusHighlightMode.traditional);
    expect(t.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
        isTrue);
  }, variant: _desktop);

  testWidgets(
      'ItInput: a click shows no ring, typing keeps it off, Tab shows it on '
      'the next field', (t) async {
    await t.pumpWidget(_host(const Column(
      mainAxisSize: MainAxisSize.min,
      children: [ItInput(label: 'Nome'), ItInput(label: 'Cognome')],
    )));
    final first = find.byType(TextField).first;

    await _click(t, first);
    expect(_paintedRing, findsNothing,
        reason: 'a clicked field has `data-focus-mouse`, so box-shadow none');

    // A key press, then text that rebuilds the field.
    await t.sendKeyEvent(LogicalKeyboardKey.keyM);
    await t.enterText(first, 'Mario');
    await t.pumpAndSettle();
    expect(_paintedRing, findsNothing, reason: _keptItsClass);

    await _tab(t);
    expect(_paintedRing, findsOneWidget,
        reason: 'focus that moves by Tab is keyboard focus');
  }, variant: _desktop);

  testWidgets(
      'ItActivatable: a control focused by a click shows no ring, even after a '
      'key; Tab to the next one does', (t) async {
    final a = FocusNode(), b = FocusNode();
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    Widget tree() => _host(Row(children: [
          _clickToFocus(a, const Key('a')),
          _clickToFocus(b, const Key('b')),
        ]));
    await t.pumpWidget(tree());

    await _click(t, find.byKey(const Key('a')));
    expect(a.hasFocus, isTrue, reason: 'premise: the click focused it');
    expect(_paintedRing, findsNothing);

    await _keyThenRebuild(t, tree);
    expect(_paintedRing, findsNothing, reason: _keptItsClass);

    await _tab(t);
    expect(b.hasFocus, isTrue);
    expect(_paintedRing, findsOneWidget);
  }, variant: _desktop);

  testWidgets('trackDescendants: the same', (t) async {
    final a = FocusNode(), b = FocusNode();
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    Widget tree() => _host(Row(children: [
          _trackedClickToFocus(a, const Key('a')),
          _trackedClickToFocus(b, const Key('b')),
        ]));
    await t.pumpWidget(tree());

    await _click(t, find.byKey(const Key('a')));
    expect(a.hasFocus, isTrue, reason: 'premise: the click focused it');
    expect(_paintedRing, findsNothing);

    await _keyThenRebuild(t, tree);
    expect(_paintedRing, findsNothing, reason: _keptItsClass);

    await _tab(t);
    expect(b.hasFocus, isTrue);
    expect(_paintedRing, findsOneWidget);
  }, variant: _desktop);

  testWidgets(
      'ItSelect: a pick made with the mouse hands focus back without a ring',
      (t) async {
    await t.pumpWidget(_host(ItSelect<String>(
      label: 'Regione',
      groupMargin: false,
      items: const [
        ItSelectItem(value: 'lazio', label: 'Lazio'),
        ItSelectItem(value: 'marche', label: 'Marche'),
      ],
      onChanged: (_) {},
    )));

    await _click(t, find.byType(ItSelect<String>));
    await _click(t, find.text('Marche').last);

    final focused = FocusManager.instance.primaryFocus?.context;
    expect(
        focused?.findAncestorWidgetOfExactType<ItSelect<String>>(), isNotNull,
        reason: 'premise: the pick handed focus back to the select');
    expect(_paintedRing, findsNothing,
        reason: 'focus handed back after a mouse pick is mouse focus');
  }, variant: _desktop);
}
