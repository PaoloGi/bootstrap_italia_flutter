// Anything anchored to a screen edge has to clear the system furniture there.
//
// Reported from a real iPhone: the bottom navigation's labels rendered
// underneath the home indicator. The CSS insets these components carry are
// measured from the viewport edge, which on the web is where the page ends —
// on a phone it is not. A 34px strip at the bottom belongs to the system.
//
// One file for all of them, because the defect is a class rather than a
// component: every widget that pins itself to an edge has the same hole, and
// finding it in one says nothing about the others. It was found in ItBottomNav;
// ItBackToTop had it too, and ItNotification's bottomFix cleared the indicator
// by 3px of luck.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// An iPhone 14's insets and logical size.
const _top = 47.0;
const _bottom = 34.0;
const _screen = Size(390, 700);

/// Sizes the render surface **as well as** the MediaQuery.
///
/// Both, and that is the point. `MediaQuery(size:)` alone tells the widget it
/// is on a 390x700 phone while the surface underneath stays at the 800x600
/// test default, so anything measured against the constant compares a claim
/// against a different reality. Written that way first, the back-to-top test
/// below passed with the fix removed: the button sat 16px above the REAL
/// bottom at 600, and the assertion was checking against 700.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double bottomInset = _bottom,
}) async {
  const dpr = 3.0;
  tester.view.physicalSize = _screen * dpr;
  tester.view.devicePixelRatio = dpr;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: _screen,
            padding: EdgeInsets.only(top: _top, bottom: bottomInset),
            viewPadding: EdgeInsets.only(top: _top, bottom: bottomInset),
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// The height actually rendered — never the constant.
double _screenHeight(WidgetTester tester) =>
    tester.getSize(find.byType(MaterialApp)).height;

void main() {
  group('the home indicator is not a place to draw', () {
    testWidgets('ItBottomNav labels clear it, background still reaches it',
        (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: ItBottomNav(
            selectedIndex: 0,
            onSelected: (_) {},
            items: const [
              ItBottomNavItem(
                  label: 'Crea', icon: BootstrapItaliaIcons.it_file),
              ItBottomNavItem(
                  label: 'Storico', icon: BootstrapItaliaIcons.it_clock),
            ],
          ),
        ),
      );
      await tester.pump();

      final bar = tester.getRect(find.byType(ItBottomNav));
      expect(bar.height, ItBottomNav.barHeight + _bottom,
          reason: 'the bar grows so its colour reaches the screen edge');
      expect(bar.bottom, _screenHeight(tester),
          reason: 'and it really is at the bottom of the rendered surface');
      expect(tester.getRect(find.text('Crea')).bottom,
          lessThanOrEqualTo(bar.bottom - _bottom),
          reason: 'the label sits above the indicator');
    });

    testWidgets('ItBackToTop keeps its CSS gap ABOVE the indicator',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await _pump(
        tester,
        Scaffold(
          body: Stack(
            children: [
              ListView(
                controller: controller,
                children: List<Widget>.generate(
                  60,
                  (i) => SizedBox(height: 40, child: Text('r$i')),
                ),
              ),
              ItBackToTop(scrollController: controller),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      controller.jumpTo(500);
      await tester.pumpAndSettle();

      // `.back-to-top { bottom: 16px }` — measured from the top of the
      // reserved strip, not the screen edge, so the button sits at 16 + 34.
      // Before the fix it sat at 16 and was half under the indicator.
      final button = tester.getRect(find.byType(ItBackToTopButton).first);
      expect(_screenHeight(tester) - button.bottom,
          greaterThanOrEqualTo(_bottom + 16),
          reason: 'the design system gap survives, above the indicator');
    });

    testWidgets('ItNotification bottomFix responds to the inset',
        (tester) async {
      // An absolute threshold cannot test this. The card's own padding already
      // exceeds an iPhone's 34px, so "the text clears the indicator" passes
      // whether or not the component looks at the inset at all — it cleared by
      // 3px of that padding before the fix, and a threshold test stayed green
      // when the fix was removed.
      //
      // What distinguishes them is whether the gap MOVES with the inset.
      Future<double> gapWith(double bottomInset) async {
        // A bare pumpWidget of the same shape REUSES the element tree, so the
        // Overlay survives and keeps the previous notification's entry — the
        // second measurement then finds two. Pumping a different root first
        // tears it down.
        await tester.pumpWidget(const Placeholder());
        await tester.pump();
        await _pump(
          tester,
          Scaffold(
            body: Builder(
              builder: (context) => ItButton(
                onPressed: () => ItNotification.show(
                  context: context,
                  body: 'Messaggio',
                  duration: null,
                  position: ItNotificationPosition.bottomFix,
                ),
                child: const Text('go'),
              ),
            ),
          ),
          bottomInset: bottomInset,
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        final gap = _screenHeight(tester) -
            tester.getRect(find.text('Messaggio')).bottom;
        return gap;
      }

      final flat = await gapWith(0);
      final phone = await gapWith(_bottom);

      expect(phone - flat, moreOrLessEquals(_bottom, epsilon: 0.5),
          reason: 'the message must move up by exactly the reserved strip');
      expect(flat, greaterThan(0),
          reason: 'sanity: the card has its own padding even with no inset, '
              'which is why the absolute check could not fail');
    });

    testWidgets('with no insets nothing moves', (tester) async {
      // The other half. Every capture in the parity harness renders without
      // insets, so a change that only ever ADDS padding cannot move them.
      await tester.pumpWidget(
        BootstrapItaliaTheme(
          data: BootstrapItaliaThemeData.standard(),
          child: MaterialApp(
            home: Scaffold(
              body: const SizedBox.shrink(),
              bottomNavigationBar: ItBottomNav(
                selectedIndex: 0,
                onSelected: (_) {},
                items: const [
                  ItBottomNavItem(
                      label: 'Crea', icon: BootstrapItaliaIcons.it_file),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.getSize(find.byType(ItBottomNav)).height,
          ItBottomNav.barHeight);
    });
  });
}
