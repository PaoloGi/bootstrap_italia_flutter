import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('ItBreadcrumb', () {
    testWidgets('renders all items', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItBreadcrumb(
          items: [
            ItBreadcrumbItem(label: 'Home'),
            ItBreadcrumbItem(label: 'Servizi'),
            ItBreadcrumbItem(label: 'Anagrafe'),
          ],
        ),
      ));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Servizi'), findsOneWidget);
      expect(find.text('Anagrafe'), findsOneWidget);
    });

    testWidgets('renders separators', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItBreadcrumb(
          items: [
            ItBreadcrumbItem(label: 'A'),
            ItBreadcrumbItem(label: 'B'),
            ItBreadcrumbItem(label: 'C'),
          ],
        ),
      ));

      // Two separators between 3 items
      expect(find.text('/'), findsNWidgets(2));
    });

    testWidgets('renders leading icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItBreadcrumb(
          icon: Icons.home,
          items: [ItBreadcrumbItem(label: 'Home')],
        ),
      ));

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('calls onTap on non-current items', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItBreadcrumb(
          items: [
            ItBreadcrumbItem(label: 'Home', onTap: () => tapped = true),
            const ItBreadcrumbItem(label: 'Current'),
          ],
        ),
      ));

      await tester.tap(find.text('Home'));
      expect(tapped, isTrue);
    });

    testWidgets('custom separator works', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItBreadcrumb(
          separator: '>',
          items: [
            ItBreadcrumbItem(label: 'A'),
            ItBreadcrumbItem(label: 'B'),
          ],
        ),
      ));

      expect(find.text('>'), findsOneWidget);
    });
  });

  group('ItSlimHeader', () {
    testWidgets('renders institution name', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItSlimHeader(institutionName: 'Repubblica Italiana'),
      ));

      expect(find.text('Repubblica Italiana'), findsOneWidget);
    });

    testWidgets('renders links', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItSlimHeader(
          institutionName: 'Test',
          links: [
            ItSlimHeaderLink(label: 'ITA', active: true),
            ItSlimHeaderLink(label: 'ENG'),
          ],
        ),
      ));

      expect(find.text('ITA'), findsOneWidget);
      expect(find.text('ENG'), findsOneWidget);
    });

    testWidgets('calls onTap on links', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItSlimHeader(
          institutionName: 'Test',
          links: [
            ItSlimHeaderLink(label: 'ENG', onTap: () => tapped = true),
          ],
        ),
      ));

      await tester.tap(find.text('ENG'));
      expect(tapped, isTrue);
    });
  });

  group('ItCenterHeader', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCenterHeader(title: 'Comune di Roma'),
      ));

      expect(find.text('Comune di Roma'), findsOneWidget);
    });

    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCenterHeader(
          title: 'Comune',
          subtitle: 'Segui su',
        ),
      ));

      expect(find.text('Segui su'), findsOneWidget);
    });

    testWidgets('renders search icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCenterHeader(
          title: 'Test',
          showSearch: true,
        ),
      ));

      expect(find.byType(ItSearchGlyph), findsOneWidget);
    });

    testWidgets('calls onSearchTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItCenterHeader(
          title: 'Test',
          showSearch: true,
          onSearchTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(ItSearchGlyph));
      expect(tapped, isTrue);
    });

    testWidgets('renders social links', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCenterHeader(
          title: 'Test',
          socialLinks: [
            ItSocialLink(icon: Icons.facebook, label: 'Facebook'),
          ],
        ),
      ));

      expect(find.byIcon(Icons.facebook), findsOneWidget);
    });
  });

  group('ItNavHeader', () {
    testWidgets('renders nav items on desktop', (tester) async {
      // Default test surface is 800x600 which is >= lg
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(
        const ItNavHeader(
          items: [
            ItNavItem(label: 'Amministrazione', active: true),
            ItNavItem(label: 'Servizi'),
            ItNavItem(label: 'Novità'),
          ],
        ),
      ));

      expect(find.text('Amministrazione'), findsOneWidget);
      expect(find.text('Servizi'), findsOneWidget);
      expect(find.text('Novità'), findsOneWidget);
    });

    testWidgets('shows hamburger on mobile', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(
        const ItNavHeader(
          items: [
            ItNavItem(label: 'Admin', active: true),
            ItNavItem(label: 'Services'),
          ],
        ),
      ));

      expect(find.byIcon(BootstrapItaliaIcons.it_burger), findsOneWidget);
    });

    testWidgets('calls onTap on nav item', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItNavHeader(
          items: [
            ItNavItem(label: 'Click', onTap: () => tapped = true),
          ],
        ),
      ));

      await tester.tap(find.text('Click'));
      expect(tapped, isTrue);
    });
  });

  group('ItHeader', () {
    testWidgets('renders all three sub-headers', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItHeader(
          slimHeader: ItSlimHeader(institutionName: 'Italia'),
          centerHeader: ItCenterHeader(title: 'Comune di Test'),
          navHeader: ItNavHeader(items: [
            ItNavItem(label: 'Home'),
          ]),
        ),
      ));

      expect(find.text('Italia'), findsOneWidget);
      expect(find.text('Comune di Test'), findsOneWidget);
    });

    testWidgets('works with only slim header', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItHeader(
          slimHeader: ItSlimHeader(institutionName: 'Solo Slim'),
        ),
      ));

      expect(find.text('Solo Slim'), findsOneWidget);
    });
  });

  group('ItFooter', () {
    testWidgets('renders institution name', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItFooter(institutionName: 'Comune di Roma'),
      ));

      expect(find.text('Comune di Roma'), findsOneWidget);
    });

    testWidgets('renders description', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItFooter(
          institutionName: 'Test',
          description: 'Via Roma 1',
        ),
      ));

      expect(find.text('Via Roma 1'), findsOneWidget);
    });

    testWidgets('renders link sections', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItFooter(
          institutionName: 'Test',
          sections: [
            ItFooterSection(title: 'Sezione 1', links: [
              ItFooterLink(label: 'Link A'),
              ItFooterLink(label: 'Link B'),
            ]),
          ],
        ),
      ));

      expect(find.text('SEZIONE 1'), findsOneWidget);
      expect(find.text('Link A'), findsOneWidget);
      expect(find.text('Link B'), findsOneWidget);
    });

    testWidgets('renders social links', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItFooter(
          institutionName: 'Test',
          socialLinks: [
            ItSocialLink(icon: Icons.facebook, label: 'Facebook'),
          ],
        ),
      ));

      expect(find.text('SEGUICI SU'), findsOneWidget);
      expect(find.byIcon(Icons.facebook), findsOneWidget);
    });

    testWidgets('renders legal info bar', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItFooter(
          institutionName: 'Test',
          legalInfo: [
            ItFooterLink(label: 'Privacy policy'),
            ItFooterLink(label: 'Note legali'),
          ],
        ),
      ));

      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Note legali'), findsOneWidget);
    });

    testWidgets('calls onTap on legal links', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItFooter(
          institutionName: 'Test',
          legalInfo: [
            ItFooterLink(label: 'Privacy', onTap: () => tapped = true),
          ],
        ),
      ));

      await tester.tap(find.text('Privacy'));
      expect(tapped, isTrue);
    });
  });

  group('ItBackToTop', () {
    testWidgets('is hidden initially', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ListView.builder(
                  controller: controller,
                  itemCount: 100,
                  itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
                ),
                ItBackToTop(scrollController: controller),
              ],
            ),
          ),
        ),
      );

      // The circle exists but is fully transparent.
      expect(find.byType(ItBackToTopButton), findsOneWidget);
      final opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byType(ItBackToTopButton),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 0.0);
    });

    testWidgets('appears after scrolling', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ListView.builder(
                  controller: controller,
                  itemCount: 100,
                  itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
                ),
                ItBackToTop(scrollController: controller, showAfter: 100),
              ],
            ),
          ),
        ),
      );

      controller.jumpTo(300);
      await tester.pumpAndSettle();

      // The circle should now be fully opaque.
      final opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byType(ItBackToTopButton),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 1.0);
    });

    testWidgets('has accessibility semantics', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ListView.builder(
                  controller: controller,
                  itemCount: 100,
                  itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
                ),
                ItBackToTop(scrollController: controller),
              ],
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Torna su',
        ),
        findsOneWidget,
      );
    });
  });
}
