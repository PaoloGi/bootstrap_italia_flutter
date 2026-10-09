// A bottom-placed notification sits on top of the bottom navigation, not over
// it.
//
// Found in a real app: its welcome message — bottomFix, six seconds — covered
// the tab bar, where the SnackBar it replaced had floated above it. A smoke
// test only got through because it happened to tap the bar just as the message
// went. The notification lives in the root Overlay and cannot see the bar, so
// the bar reports its height (BottomNavClearance) while its page is current.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _screenHeight = 852.0; // iPhone 16 Pro, logical

const _items = [
  ItBottomNavItem(label: 'Crea', icon: BootstrapItaliaIcons.it_plus_circle),
  ItBottomNavItem(label: 'Storico', icon: BootstrapItaliaIcons.it_clock),
];

Future<GlobalKey<NavigatorState>> _app(
  WidgetTester t, {
  bool withBar = true,
  ValueChanged<int>? onSelected,
  double homeIndicator = 0,
}) async {
  final nav = GlobalKey<NavigatorState>();
  t.view.physicalSize = const Size(393 * 3, _screenHeight * 3);
  t.view.devicePixelRatio = 3;
  t.view.padding = FakeViewPadding(bottom: homeIndicator * 3);
  t.view.viewPadding = FakeViewPadding(bottom: homeIndicator * 3);
  addTearDown(t.view.reset);
  await t.pumpWidget(BootstrapItaliaTheme(
    data: BootstrapItaliaThemeData.standard(),
    child: MaterialApp(
      navigatorKey: nav,
      home: Scaffold(
        body: const SizedBox.expand(),
        bottomNavigationBar: withBar
            ? ItBottomNav(
                items: _items,
                selectedIndex: 0,
                onSelected: onSelected ?? (_) {},
              )
            : null,
      ),
    ),
  ));
  await t.pump(); // the bar reports once it has been laid out
  return nav;
}

OverlayEntry _notify(
        GlobalKey<NavigatorState> nav, ItNotificationPosition position) =>
    ItNotification.show(
      context: nav.currentContext!,
      body: 'Documento inviato con successo',
      position: position,
    );

Rect _card(WidgetTester t) => t.getRect(find.byType(ItNotification));
Rect _bar(WidgetTester t) => t.getRect(find.byType(ItBottomNav));

void main() {
  testWidgets('bottomFix sits on the bar, and the bar stays usable', (t) async {
    var selected = -1;
    final nav = await _app(t, onSelected: (i) => selected = i);
    final entry = _notify(nav, ItNotificationPosition.bottomFix);
    await t.pump();

    expect(_card(t).bottom, moreOrLessEquals(_bar(t).top, epsilon: 0.5),
        reason: 'the card must end where the bar begins, not cover it');
    await t.tap(find.text('Storico'));
    expect(selected, 1,
        reason: 'a message on screen must not take the tab bar away');
    entry.remove();
  });

  testWidgets('a floating bottom card keeps its gap from the bar, not the edge',
      (t) async {
    final nav = await _app(t);
    final entry = _notify(nav, ItNotificationPosition.bottomRight);
    await t.pump();
    expect(
        _card(t).bottom,
        moreOrLessEquals(_bar(t).top - BootstrapItaliaSpacing.space3,
            epsilon: 0.5));
    entry.remove();
  });

  testWidgets(
      'a page pushed over the bar sends the card back to the edge — '
      'and popping lifts it again', (t) async {
    final nav = await _app(t);
    final entry = _notify(nav, ItNotificationPosition.bottomFix);
    await t.pump();
    final onTheBar = _card(t).bottom;

    nav.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: SizedBox.expand())));
    await t.pumpAndSettle();
    expect(_card(t).bottom, moreOrLessEquals(_screenHeight, epsilon: 0.5),
        reason: 'the pushed page has no bar, so nothing to clear');

    nav.currentState!.pop();
    await t.pumpAndSettle();
    expect(_card(t).bottom, moreOrLessEquals(onTheBar, epsilon: 0.5));
    entry.remove();
  });

  testWidgets(
      'the bar already covers the home indicator, so the card does not '
      'pad for it again', (t) async {
    final nav = await _app(t, homeIndicator: 34);
    final entry = _notify(nav, ItNotificationPosition.bottomFix);
    await t.pump();
    expect(_bar(t).height, ItBottomNav.barHeight + 34);
    expect(_card(t).bottom, moreOrLessEquals(_bar(t).top, epsilon: 0.5));
    entry.remove();
  });

  // Last on purpose: a bar that failed to withdraw when disposed would still
  // be reporting from the tests above.
  testWidgets('with no bar, nothing changes', (t) async {
    final nav = await _app(t, withBar: false, homeIndicator: 34);
    final entry = _notify(nav, ItNotificationPosition.bottomFix);
    await t.pump();
    // Flush to the edge, content padded clear of the home indicator.
    expect(_card(t).bottom, moreOrLessEquals(_screenHeight - 34, epsilon: 0.5));
    entry.remove();
  });
}
