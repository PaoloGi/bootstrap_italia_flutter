// `ItSkiplinks` is the one component with no visual-parity capture, so nothing
// compared it against the design system. It shipped rendering the *inverse*:
// a primary-filled bar with the label reversed out in white, where the
// stylesheet declares
//
//   .skiplinks   { background-color: hsl(210, 62%, 97%); text-align: center }
//   .skiplinks a { padding: .5rem .5rem; display: block; font-weight: 600;
//                  color: #06c; text-decoration: underline }
//
// White appears nowhere in those rules. Until the capture exists, this file
// stands in for it. Every number here was read off the live design-react-kit
// (`documentazione-componenti-skiplinks--esempi-with-nav`, after a Tab press to
// reveal the bar), not off the CSS alone:
//
//   link colour   rgb(0, 102, 204)      band  rgb(243, 247, 252)
//   decoration    underline             anchor box  868 x 40, stacked
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _links = [
  ItSkiplink(label: 'Skip to main content'),
  ItSkiplink(label: 'Skip to footer'),
];

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: SizedBox(width: 900, child: child)),
    );

void main() {
  group('ItSkiplinks matches the design system', () {
    testWidgets('links are block-level: full width, 40px each, stacked',
        (tester) async {
      await tester.pumpWidget(
          _host(const ItSkiplinks(hideUntilFocused: false, links: _links)));
      await tester.pumpAndSettle();

      for (final label in ['Skip to main content', 'Skip to footer']) {
        final box = tester.getSize(find
            .ancestor(of: find.text(label), matching: find.byType(Padding))
            .first);
        expect(box.height, 40,
            reason: '`.skiplinks a { padding: .5rem .5rem }` around a 1.5rem '
                'line box is exactly 40 — the kit measures 40 too');
        expect(box.width, 800,
            reason: '`display: block` means the anchor spans the bar; the kit '
                'measures 868 in an 900px viewport with the section padding');
      }

      expect(tester.getSize(find.byType(ItSkiplinks)).height, 80,
          reason: 'two block-level links stack (2 x 40). This was a Row, which '
              'laid them side by side and made the bar 40 tall however many '
              'links it had');
    });

    testWidgets('the link carries the accent and the band does not',
        (tester) async {
      await tester.pumpWidget(
          _host(const ItSkiplinks(hideUntilFocused: false, links: _links)));
      await tester.pumpAndSettle();

      final style = tester.widget<Text>(find.text('Skip to footer')).style!;
      expect(style.color, const Color(0xFF0066CC),
          reason: '`.skiplinks a { color: #06c }` — the kit reports '
              'rgb(0, 102, 204). It was white.');
      expect(style.decoration, TextDecoration.underline,
          reason: '`text-decoration: underline`');
      expect(style.fontWeight, FontWeight.w600, reason: '`font-weight: 600`');

      final band = tester.widgetList<ColoredBox>(find.byType(ColoredBox));
      expect(
        band.map((b) => b.color),
        contains(const Color(0xFFF3F7FC)),
        reason: '`.skiplinks { background-color: hsl(210,62%,97%) }` — the kit '
            'reports rgb(243, 247, 252). It was the primary blue.',
      );
    });

    testWidgets('hidden until focused, but still reachable', (tester) async {
      // The reason this component cannot use the upstream idiom: Flutter culls
      // semantics for render objects moved off-screen, so `left: -9999px` would
      // make the bypass block inert — conformant-looking and useless. It stays
      // in the tree at zero opacity instead.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const ItSkiplinks(links: _links)));
      await tester.pumpAndSettle();

      expect(find.text('Skip to main content'), findsOneWidget,
          reason: 'WCAG 2.4.1 Bypass Blocks: a hidden skiplink that is also '
              'unreachable is worse than none, because it reads as compliant');
      handle.dispose();
    });
  });
}
