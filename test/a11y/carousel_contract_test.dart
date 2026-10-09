import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double width = 1200}) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: width, height: 400, child: child),
          ),
        ),
      ),
    );

List<Widget> _slides(int n) =>
    List<Widget>.generate(n, (i) => Text('slide $i'));

void main() {
  group('ItCarousel — the presets are upstream\'s, not invented', () {
    test('Splide breakpoints are max-width, so narrow means fewer slides', () {
      // The single easiest thing to get backwards. In Splide a `768` entry
      // applies at 768px AND BELOW; reading it as min-width inverts every
      // layout, and it would still render plausibly.
      const t = ItCarouselType.landscapeThreeCols;
      expect(ItCarousel.configFor(t, 360).perPage, 1, reason: 'phone');
      expect(ItCarousel.configFor(t, 768).perPage, 1, reason: 'at the bound');
      expect(ItCarousel.configFor(t, 900).perPage, 2, reason: 'tablet');
      expect(ItCarousel.configFor(t, 1200).perPage, 3, reason: 'desktop');
    });

    test('every preset narrows to a single slide on a phone', () {
      for (final t in ItCarouselType.values) {
        expect(ItCarousel.configFor(t, 360).perPage, 1,
            reason: '$t must not try to show several slides on a phone');
      }
    });

    test('only the arrows preset gets arrows', () {
      for (final t in ItCarouselType.values) {
        expect(
          ItCarousel.configFor(t, 1200).arrows,
          t == ItCarouselType.landscapeThreeColsArrows,
          reason: '$t arrows must follow CONFIGS in Carousel.tsx',
        );
      }
    });

    test('the image presets loop and the rest do not', () {
      const looping = {ItCarouselType.bigImage, ItCarouselType.standardImage};
      for (final t in ItCarouselType.values) {
        expect(ItCarousel.configFor(t, 1200).loop, looping.contains(t),
            reason: '$t: `type: loop` is set only on the image presets');
      }
    });

    test('calendar has a fourth breakpoint at 560', () {
      const t = ItCarouselType.calendar;
      expect(ItCarousel.configFor(t, 500).perPage, 1);
      expect(ItCarousel.configFor(t, 700).perPage, 2);
      expect(ItCarousel.configFor(t, 900).perPage, 3);
      expect(ItCarousel.configFor(t, 1200).perPage, 4);
    });
  });

  group('ItCarousel §1.3.1 / §4.1.2 / §2.2.2', () {
    testWidgets('the carousel is named and each slide states its position',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItCarousel(items: _slides(3))));
      await tester.pump();

      expect(find.bySemanticsLabel(ItLocalizations.italian.carousel),
          findsOneWidget,
          reason: 'an unnamed carousel is an anonymous region');
      expect(find.bySemanticsLabel('1 di 3'), findsOneWidget,
          reason: 'upstream slideLabel is `%s di %s`');
      handle.dispose();
    });

    testWidgets('the dots are actually painted, not merely named',
        (tester) async {
      // The bug this exists for: the dots were built from an ItIconAction with
      // `iconSize: 0`, on the assumption that the button paints its own
      // background the way `.splide__pagination button` does. It does not, so
      // the dots were invisible — while every other test in this group passed,
      // because they all check the accessible name and none checks the paint.
      //
      // Rendering it and looking at the PNG is what found it.
      await tester.pumpWidget(_host(ItCarousel(items: _slides(3))));
      await tester.pump();

      final decorations = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.color != null)
          .toList();

      const primary = Color(0xFF0066CC);
      expect(
        decorations.where((d) => d.color == primary).length,
        1,
        reason: 'exactly one dot is the active one, filled with --bs-primary',
      );
      expect(
        decorations.where((d) => d.color == ItCarousel.inactiveDot).length,
        2,
        reason: 'the other two carry hsl(210,83%,77%)',
      );

      // And each is the size the CSS gives it, not a zero-area box that
      // happens to hold the right colour.
      final dot = tester.getSize(find
          .descendant(
            of: find.byType(ItActivatable).first,
            matching: find.byType(Container),
          )
          .first);
      expect(dot.width, ItCarousel.dotSize);
      expect(dot.height, ItCarousel.dotSize);
    });

    testWidgets('pagination dots are named and move the carousel',
        (tester) async {
      final handle = tester.ensureSemantics();
      var page = -1;
      await tester.pumpWidget(_host(ItCarousel(
        items: _slides(3),
        onPageChanged: (i) => page = i,
      )));
      await tester.pump();

      final third = find.bySemanticsLabel('Vai alla slide 3');
      expect(third, findsOneWidget);

      await tester.tap(third, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(page, 2, reason: 'the dot must actually navigate');
      handle.dispose();
    });

    testWidgets('three slides in a one-up track do paginate', (tester) async {
      // The positive half. Without it the negative test below cannot tell
      // "correctly hidden" from "never rendered at all".
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItCarousel(items: _slides(3))));
      await tester.pump();
      expect(find.bySemanticsLabel('Vai alla slide 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('no dots when there is nothing to scroll to', (tester) async {
      // `.splide:not(.is-overflow) .splide__pagination { display: none }`.
      //
      // Two things this test needed before it could fail. `ensureSemantics`,
      // because `bySemanticsLabel` matches nothing at all without a handle —
      // so the negative assertion passed whatever the widget did. And its own
      // pump: re-pumping a different item count into the same tree reuses the
      // carousel's State, leaving the controller on a page that no longer
      // exists, and the pagination then fails to build for the wrong reason.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(ItCarousel(items: _slides(1))));
      await tester.pump();

      expect(tester.takeException(), isNull,
          reason: 'the absence must be a decision, not a build failure');
      expect(find.bySemanticsLabel('Vai alla slide 1'), findsNothing,
          reason: 'a single slide has nothing to paginate');
      handle.dispose();
    });

    testWidgets('autoplay is off unless asked for, and carries a pause',
        (tester) async {
      await tester.pumpWidget(_host(ItCarousel(items: _slides(3))));
      await tester.pump();
      expect(find.text(ItLocalizations.italian.pauseCarousel), findsNothing,
          reason: 'CONFIG_DEFAULT sets no autoplay, so no control is needed');

      await tester.pumpWidget(_host(
        ItCarousel(items: _slides(3), autoPlay: true),
      ));
      await tester.pump();
      // WCAG 2.2.2: content that moves for more than five seconds must be
      // pausable. This control is the whole reason autoplay is allowed at all.
      expect(find.text(ItLocalizations.italian.pauseCarousel), findsOneWidget);
    });

    testWidgets('autoplay advances, and pausing actually stops it',
        (tester) async {
      var page = 0;
      await tester.pumpWidget(_host(ItCarousel(
        items: _slides(3),
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 1),
        onPageChanged: (i) => page = i,
      )));
      await tester.pump();

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(page, 1, reason: 'autoplay must actually advance');

      await tester.tap(find.text(ItLocalizations.italian.pauseCarousel));
      await tester.pumpAndSettle();

      final atPause = page;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(page, atPause,
          reason: 'a pause that only delays the next jump is not a pause');
    });
  });
}
