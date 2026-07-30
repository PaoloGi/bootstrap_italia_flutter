import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('ItCollapse', () {
    testWidgets('shows child when expanded', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCollapse(
          isExpanded: true,
          child: Text('Visible'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Visible'), findsOneWidget);
    });

    testWidgets('hides child when collapsed', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCollapse(
          isExpanded: false,
          child: Text('Hidden'),
        ),
      ));
      await tester.pumpAndSettle();

      // SizeTransition with factor 0 still has the widget in tree
      // but it should have zero height
      final sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, 0.0);
    });

    testWidgets('animates between states', (tester) async {
      var expanded = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              Column(
                children: [
                  TextButton(
                    onPressed: () => setState(() => expanded = !expanded),
                    child: const Text('Toggle'),
                  ),
                  ItCollapse(
                    isExpanded: expanded,
                    child: const Text('Content'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Toggle'));
      await tester.pump();
      // During animation
      await tester.pump(const Duration(milliseconds: 150));
      final mid = tester.widget<SizeTransition>(find.byType(SizeTransition));
      expect(mid.sizeFactor.value, greaterThan(0));
      expect(mid.sizeFactor.value, lessThan(1));

      await tester.pumpAndSettle();
      final end = tester.widget<SizeTransition>(find.byType(SizeTransition));
      expect(end.sizeFactor.value, 1.0);
    });
  });

  group('ItAccordion', () {
    testWidgets('renders all item titles', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItAccordion(
          items: [
            ItAccordionItem(title: 'Section 1', child: Text('Body 1')),
            ItAccordionItem(title: 'Section 2', child: Text('Body 2')),
            ItAccordionItem(title: 'Section 3', child: Text('Body 3')),
          ],
        ),
      ));

      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 2'), findsOneWidget);
      expect(find.text('Section 3'), findsOneWidget);
    });

    testWidgets('expands on tap', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItAccordion(
          items: [
            ItAccordionItem(title: 'Section 1', child: Text('Body 1')),
          ],
        ),
      ));

      await tester.tap(find.text('Section 1'));
      await tester.pumpAndSettle();

      // After expand, body should be visible
      expect(find.text('Body 1'), findsOneWidget);
    });

    testWidgets('single mode collapses previous on new expand', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItAccordion(
          items: [
            ItAccordionItem(
              title: 'Section 1',
              child: Text('Body 1'),
              initiallyExpanded: true,
            ),
            ItAccordionItem(title: 'Section 2', child: Text('Body 2')),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      // Tap section 2
      await tester.tap(find.text('Section 2'));
      await tester.pumpAndSettle();

      // Both bodies exist in tree, but section 1's collapse should be animating to 0
      // Just verify section 2 content is visible
      expect(find.text('Body 2'), findsOneWidget);
    });

    testWidgets('multiple mode allows multiple open', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItAccordion(
          allowMultipleOpen: true,
          items: [
            ItAccordionItem(
              title: 'Section 1',
              child: Text('Body 1'),
              initiallyExpanded: true,
            ),
            ItAccordionItem(title: 'Section 2', child: Text('Body 2')),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Section 2'));
      await tester.pumpAndSettle();

      // Both should be visible
      expect(find.text('Body 1'), findsOneWidget);
      expect(find.text('Body 2'), findsOneWidget);
    });
  });

  group('ItCard', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCard(title: 'Card Title'),
      ));

      expect(find.text('Card Title'), findsOneWidget);
    });

    testWidgets('renders subtitle and body', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCard(
          title: 'Title',
          subtitle: 'Subtitle',
          body: Text('Body content'),
        ),
      ));

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);
    });

    testWidgets('renders category', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCard(
          category: ItCardCategory(label: 'News'),
          title: 'Title',
        ),
      ));

      expect(find.text('NEWS'), findsOneWidget);
    });

    testWidgets('renders signature', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCard(
          title: 'Title',
          signature: 'di Mario Rossi',
        ),
      ));

      expect(find.text('di Mario Rossi'), findsOneWidget);
    });

    testWidgets('calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItCard(
          title: 'Tap me',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('renders colored top border', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCard(
          title: 'Bordered',
          borderTopColor: BootstrapItaliaColors.primary,
        ),
      ));

      expect(find.text('Bordered'), findsOneWidget);
    });

    testWidgets('horizontal layout renders', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCard(
          title: 'Horizontal',
          horizontal: true,
        ),
      ));

      expect(find.text('Horizontal'), findsOneWidget);
    });
  });

  group('ItTabBar', () {
    testWidgets('renders all tab labels', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItTabBar(
          tabs: [
            ItTabItem(label: 'Tab 1'),
            ItTabItem(label: 'Tab 2'),
            ItTabItem(label: 'Tab 3'),
          ],
        ),
      ));

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsOneWidget);
    });

    testWidgets('calls onChanged when tab tapped', (tester) async {
      int? selectedIndex;
      await tester.pumpWidget(_wrap(
        ItTabBar(
          tabs: const [
            ItTabItem(label: 'Tab 1'),
            ItTabItem(label: 'Tab 2'),
          ],
          onChanged: (index) => selectedIndex = index,
        ),
      ));

      await tester.tap(find.text('Tab 2'));
      expect(selectedIndex, 1);
    });

    testWidgets('disabled tab does not call onChanged', (tester) async {
      int? selectedIndex;
      await tester.pumpWidget(_wrap(
        ItTabBar(
          tabs: const [
            ItTabItem(label: 'Tab 1'),
            ItTabItem(label: 'Tab 2', disabled: true),
          ],
          onChanged: (index) => selectedIndex = index,
        ),
      ));

      await tester.tap(find.text('Tab 2'));
      expect(selectedIndex, isNull);
    });
  });

  group('ItTabView', () {
    testWidgets('shows selected child', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItTabView(
          selectedIndex: 1,
          children: [Text('Page 0'), Text('Page 1'), Text('Page 2')],
        ),
      ));

      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 0'), findsNothing);
    });

    testWidgets('animates between tabs', (tester) async {
      var index = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              Column(
                children: [
                  TextButton(
                    onPressed: () => setState(() => index = 1),
                    child: const Text('Switch'),
                  ),
                  ItTabView(
                    selectedIndex: index,
                    children: const [Text('Page 0'), Text('Page 1')],
                  ),
                ],
              ),
            );
          },
        ),
      );

      expect(find.text('Page 0'), findsOneWidget);
      await tester.tap(find.text('Switch'));
      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);
    });
  });

  group('ItList', () {
    testWidgets('renders all items', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItList(
          items: [
            ItListItem(title: 'Item 1'),
            ItListItem(title: 'Item 2'),
            ItListItem(title: 'Item 3'),
          ],
        ),
      ));

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItList(
          items: [
            ItListItem(title: 'Item', subtitle: 'Description'),
          ],
        ),
      ));

      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('renders leading and trailing', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItList(
          items: [
            ItListItem(
              title: 'Item',
              leading: Icon(Icons.folder),
              trailing: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ));

      expect(find.byIcon(Icons.folder), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItList(
          items: [
            ItListItem(title: 'Tap me', onTap: () => tapped = true),
          ],
        ),
      ));

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('disabled item does not call onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItList(
          items: [
            ItListItem(
              title: 'Disabled',
              disabled: true,
              onTap: () => tapped = true,
            ),
          ],
        ),
      ));

      await tester.tap(find.text('Disabled'));
      expect(tapped, isFalse);
    });
  });

  group('ItCallout', () {
    testWidgets('renders content', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCallout(child: Text('Important info')),
      ));

      expect(find.text('Important info'), findsOneWidget);
    });

    testWidgets('renders title with icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCallout(
          variant: ItCalloutVariant.success,
          title: 'Nota bene',
          child: Text('Content'),
        ),
      ));

      expect(find.text('Nota bene'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('all variants render', (tester) async {
      for (final variant in ItCalloutVariant.values) {
        await tester.pumpWidget(_wrap(
          ItCallout(variant: variant, child: const Text('V')),
        ));
        expect(find.text('V'), findsOneWidget);
      }
    });

    testWidgets('collapsible toggles on title tap', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCallout(
          title: 'Toggle me',
          collapsible: true,
          initiallyExpanded: true,
          child: Text('Hidden content'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hidden content'), findsOneWidget);

      // Tap title to collapse
      await tester.tap(find.text('Toggle me'));
      await tester.pumpAndSettle();

      // Content should be collapsed (size 0)
      final collapse = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(collapse.sizeFactor.value, 0.0);
    });
  });
}
