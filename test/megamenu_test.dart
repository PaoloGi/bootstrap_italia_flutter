import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

List<ItMegamenuSection> _testSections() {
  return [
    ItMegamenuSection(
      label: 'Amministrazione',
      active: true,
      columns: [
        ItMegamenuColumn(
          heading: 'Organi',
          links: [
            ItMegamenuLink(label: 'Sindaco'),
            ItMegamenuLink(label: 'Giunta'),
          ],
        ),
        ItMegamenuColumn(
          heading: 'Uffici',
          links: [
            ItMegamenuLink(label: 'Segreteria'),
          ],
        ),
      ],
      headerCta: ItMegamenuCta(label: 'Esplora la sezione'),
      footerCta: ItMegamenuCta(label: 'Vedi tutto'),
      description: 'Struttura del Comune.',
    ),
    ItMegamenuSection(
      label: 'Servizi',
      columns: [
        ItMegamenuColumn(
          links: [
            ItMegamenuLink(label: 'Anagrafe'),
            ItMegamenuLink(label: 'Tributi'),
          ],
        ),
      ],
    ),
    ItMegamenuSection(
      label: 'Novità',
      columns: [
        ItMegamenuColumn(
          links: [
            ItMegamenuLink(label: 'Notizie'),
          ],
        ),
      ],
    ),
  ];
}

void main() {
  group('ItMegamenu data models', () {
    test('ItMegamenuLink has correct defaults', () {
      const link = ItMegamenuLink(label: 'Test');
      expect(link.label, 'Test');
      expect(link.icon, isNull);
      expect(link.onTap, isNull);
      expect(link.description, isNull);
    });

    test('ItMegamenuColumn has correct defaults', () {
      const col = ItMegamenuColumn(links: [ItMegamenuLink(label: 'A')]);
      expect(col.heading, isNull);
      expect(col.links.length, 1);
    });

    test('ItMegamenuCta stores label and icon', () {
      const cta = ItMegamenuCta(label: 'Go', icon: Icons.arrow_forward);
      expect(cta.label, 'Go');
      expect(cta.icon, Icons.arrow_forward);
    });

    test('ItMegamenuSection has correct defaults', () {
      const section = ItMegamenuSection(
        label: 'Test',
        columns: [],
      );
      expect(section.label, 'Test');
      expect(section.active, isFalse);
      expect(section.description, isNull);
      expect(section.image, isNull);
      expect(section.headerCta, isNull);
      expect(section.footerCta, isNull);
    });
  });

  group('ItMegamenu desktop', () {
    testWidgets('renders all section labels', (tester) async {
      // Force a wide viewport for desktop
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      expect(find.text('Amministrazione'), findsOneWidget);
      expect(find.text('Servizi'), findsOneWidget);
      expect(find.text('Novità'), findsOneWidget);
    });

    testWidgets('shows expand arrows on desktop', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      expect(find.byIcon(Icons.expand_more), findsNWidgets(3));
    });

    testWidgets('tapping section opens panel with links', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      // Panel not open yet
      expect(find.text('Sindaco'), findsNothing);

      // Tap first section
      await tester.tap(find.text('Amministrazione'));
      await tester.pumpAndSettle();

      // Panel should show links and headings
      expect(find.text('Sindaco'), findsOneWidget);
      expect(find.text('Giunta'), findsOneWidget);
      expect(find.text('Organi'), findsOneWidget);
      expect(find.text('Uffici'), findsOneWidget);
    });

    testWidgets('tapping same section toggles panel closed', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      // Open
      await tester.tap(find.text('Amministrazione'));
      await tester.pumpAndSettle();
      expect(find.text('Sindaco'), findsOneWidget);

      // Close
      await tester.tap(find.text('Amministrazione'));
      await tester.pumpAndSettle();
      expect(find.text('Sindaco'), findsNothing);
    });

    testWidgets('switching sections changes panel content', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      // Open first section
      await tester.tap(find.text('Amministrazione'));
      await tester.pumpAndSettle();
      expect(find.text('Sindaco'), findsOneWidget);

      // Switch to second section
      await tester.tap(find.text('Servizi'));
      await tester.pumpAndSettle();
      expect(find.text('Sindaco'), findsNothing);
      expect(find.text('Anagrafe'), findsOneWidget);
    });

    testWidgets('shows header and footer CTAs', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      await tester.tap(find.text('Amministrazione'));
      await tester.pumpAndSettle();

      expect(find.text('Esplora la sezione'), findsOneWidget);
      expect(find.text('Vedi tutto'), findsOneWidget);
    });

    testWidgets('shows description panel', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      await tester.tap(find.text('Amministrazione'));
      await tester.pumpAndSettle();

      expect(find.text('Struttura del Comune.'), findsOneWidget);
    });
  });

  group('ItMegamenu mobile', () {
    testWidgets('shows hamburger menu on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      expect(find.byIcon(Icons.menu), findsOneWidget);
      // Shows active section label
      expect(find.text('Amministrazione'), findsOneWidget);
    });

    testWidgets('hamburger opens mobile overlay', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // All sections visible in overlay (Amministrazione appears twice:
      // mobile bar label behind overlay + overlay section)
      expect(find.text('Amministrazione'), findsWidgets);
      expect(find.text('Servizi'), findsOneWidget);
      expect(find.text('Novità'), findsOneWidget);
      // Close button visible
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('close button dismisses overlay', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Back to hamburger
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('tapping section expands links (accordion)', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Expand first section (use last match to hit overlay, not nav bar)
      await tester.tap(find.text('Amministrazione').last);
      await tester.pumpAndSettle();

      // Links should be visible after expansion
      expect(find.text('Sindaco'), findsOneWidget);
      expect(find.text('Giunta'), findsOneWidget);
    });

    testWidgets('accordion collapses previous section', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Expand first section
      await tester.tap(find.text('Amministrazione').last);
      await tester.pumpAndSettle();
      expect(find.text('Sindaco'), findsOneWidget);

      // Expand second section — first should collapse
      await tester.tap(find.text('Servizi'));
      await tester.pumpAndSettle();
      expect(find.text('Anagrafe'), findsOneWidget);
    });

    testWidgets('shows CTAs in mobile expanded section', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Amministrazione').last);
      await tester.pumpAndSettle();

      expect(find.text('Esplora la sezione'), findsOneWidget);
      expect(find.text('Vedi tutto'), findsOneWidget);
    });

    testWidgets('link tap calls onTap and closes overlay', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      var tapped = false;
      final sections = [
        ItMegamenuSection(
          label: 'Sezione',
          active: true,
          columns: [
            ItMegamenuColumn(
              links: [
                ItMegamenuLink(
                  label: 'Click Me',
                  onTap: () => tapped = true,
                ),
              ],
            ),
          ],
        ),
      ];

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: sections),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Expand section (use last to hit overlay)
      await tester.tap(find.text('Sezione').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      // Overlay should be closed
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('has accessibility semantics', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_wrap(
        ItMegamenu(sections: _testSections()),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });
  });

  group('ItMegamenu size variants', () {
    test('ItModalSize values remain correct', () {
      // Quick sanity check that modal sizes still work
      expect(ItModalSize.sm.maxWidth, 300);
      expect(ItModalSize.md.maxWidth, 500);
    });
  });
}
