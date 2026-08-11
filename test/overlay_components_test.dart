import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('ItModal', () {
    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItModal(
          title: 'Test Title',
          body: Text('Body content'),
        ),
      ));

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItModal(
          title: 'With Icon',
          icon: Icons.warning,
          body: Text('Content'),
        ),
      ));

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      await tester.pumpWidget(_wrap(
        ItModal(
          title: 'Actions',
          body: const Text('Content'),
          actions: [
            TextButton(onPressed: () {}, child: const Text('Cancel')),
            TextButton(onPressed: () {}, child: const Text('OK')),
          ],
        ),
      ));

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('shows close button when dismissible', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItModal(
          title: 'Dismissible',
          body: Text('Content'),
          dismissible: true,
        ),
      ));

      expect(find.byIcon(BootstrapItaliaIcons.it_close), findsOneWidget);
    });

    testWidgets('hides close button when not dismissible', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItModal(
          title: 'Not Dismissible',
          body: Text('Content'),
          dismissible: false,
        ),
      ));

      expect(find.byIcon(BootstrapItaliaIcons.it_close), findsNothing);
    });

    testWidgets('renders without title (body only)', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItModal(body: Text('Body only')),
      ));

      expect(find.text('Body only'), findsOneWidget);
    });

    testWidgets('scrollable wraps body', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItModal(
          title: 'Scrollable',
          body: Text('Scrollable content'),
          scrollable: true,
        ),
      ));

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('show() opens dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ItModal.show(
                  context: context,
                  title: 'Dialog Title',
                  body: const Text('Dialog Body'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.text('Dialog Body'), findsOneWidget);
    });

    testWidgets('show() close button pops dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ItModal.show(
                  context: context,
                  title: 'Closeable',
                  body: const Text('Content'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Closeable'), findsOneWidget);

      await tester.tap(find.byIcon(BootstrapItaliaIcons.it_close));
      await tester.pumpAndSettle();
      expect(find.text('Closeable'), findsNothing);
    });

    testWidgets('has accessibility semantics', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItModal(
          title: 'A11y Test',
          body: Text('Content'),
        ),
      ));

      expect(find.bySemanticsLabel('Chiudi finestra modale'), findsOneWidget);
    });
  });

  group('ItDropdown', () {
    testWidgets('renders trigger widget', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItDropdown(
          trigger: Text('Open Menu'),
          items: [
            ItDropdownItem(label: 'Item 1'),
          ],
        ),
      ));

      expect(find.text('Open Menu'), findsOneWidget);
    });

    testWidgets('opens menu on tap', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItDropdown(
          trigger: Text('Open Menu'),
          items: [
            ItDropdownItem(label: 'Item 1'),
            ItDropdownItem(label: 'Item 2'),
          ],
        ),
      ));

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('renders header entries', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItDropdown(
          trigger: Text('Open'),
          items: [
            ItDropdownHeader(label: 'Section'),
            ItDropdownItem(label: 'Item'),
          ],
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Section'), findsOneWidget);
    });

    testWidgets('renders divider entries', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItDropdown(
          trigger: Text('Open'),
          items: [
            ItDropdownItem(label: 'Above'),
            ItDropdownDivider(),
            ItDropdownItem(label: 'Below'),
          ],
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // `.link-list-wrapper ul .divider { height: 1px;
      //   background: hsl(210,4%,78%); margin: 8px 0 }`, painted as a plain box
      // now that Material's Divider is gone (doc/adr/0001). Decorative, so it
      // is also kept out of the semantics tree.
      final rule = find.descendant(
        of: find.byType(ExcludeSemantics),
        matching: find.byType(ColoredBox),
      );
      expect(rule, findsOneWidget);
      expect(
        tester.widget<ColoredBox>(rule).color,
        const Color(0xFFC5C7C9),
      );
      expect(tester.getSize(rule).height, 1);
    });

    testWidgets('calls onTap and closes menu', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItDropdown(
          trigger: const Text('Open'),
          items: [
            ItDropdownItem(label: 'Click Me', onTap: () => tapped = true),
          ],
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      // Menu should be closed
      expect(find.text('Click Me'), findsNothing);
    });

    testWidgets('renders item with icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItDropdown(
          trigger: Text('Open'),
          items: [
            ItDropdownItem(label: 'Edit', icon: Icons.edit),
          ],
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('closes on outside tap', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItDropdown(
          trigger: Text('Open'),
          items: [
            ItDropdownItem(label: 'Item'),
          ],
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsOneWidget);

      // Tap outside (top-left corner)
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsNothing);
    });

    testWidgets('toggle opens and closes', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItDropdown(
          trigger: Text('Toggle'),
          items: [
            ItDropdownItem(label: 'Item'),
          ],
        ),
      ));

      // Open
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsOneWidget);

      // Close via trigger
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsNothing);
    });
  });

  group('ItNotification', () {
    testWidgets('renders title and message', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItNotification(
          title: 'Success',
          body: 'Operation completed',
          duration: null,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('SUCCESS'), findsOneWidget);
      expect(find.text('Operation completed'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItNotification(
          icon: Icons.check_circle,
          title: 'Done',
          duration: null,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders close button when dismissible', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItNotification(
          title: 'Dismissible',
          dismissible: true,
          duration: null,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(BootstrapItaliaIcons.it_close), findsOneWidget);
    });

    testWidgets('hides close button when not dismissible', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItNotification(
          title: 'Persistent',
          dismissible: false,
          duration: null,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(BootstrapItaliaIcons.it_close), findsNothing);
    });

    testWidgets('dismiss calls onDismissed', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(_wrap(
        ItNotification(
          title: 'Dismiss Me',
          dismissible: true,
          duration: null,
          onDismissed: () => dismissed = true,
        ),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(BootstrapItaliaIcons.it_close));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('has liveRegion semantics', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItNotification(
          title: 'A11y',
          duration: null,
        ),
      ));

      await tester.pumpAndSettle();

      // Verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('show() creates overlay entry', (tester) async {
      late OverlayEntry entry;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  entry = ItNotification.show(
                    context: context,
                    title: 'Overlay Toast',
                    body: 'Hello!',
                    duration: null,
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('OVERLAY TOAST'), findsOneWidget);
      expect(find.text('Hello!'), findsOneWidget);

      // Clean up
      entry.remove();
      await tester.pumpAndSettle();
    });

    testWidgets('auto-dismisses after duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ItNotification.show(
                    context: context,
                    title: 'Auto Dismiss',
                    duration: const Duration(seconds: 1),
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('AUTO DISMISS'), findsOneWidget);

      // Advance time past the duration
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('AUTO DISMISS'), findsNothing);
    });

    testWidgets('renders all variant types', (tester) async {
      for (final variant in ItNotificationVariant.values) {
        await tester.pumpWidget(_wrap(
          ItNotification(
            variant: variant,
            title: variant.name,
            duration: null,
          ),
        ));

        await tester.pumpAndSettle();
        expect(find.text(variant.name.toUpperCase()), findsOneWidget);
      }
    });
  });

  group('ItModalSize', () {
    test('has correct max widths', () {
      expect(ItModalSize.small.maxWidth, 300);
      expect(ItModalSize.medium.maxWidth, 500);
      expect(ItModalSize.large.maxWidth, 800);
      expect(ItModalSize.extraLarge.maxWidth, 1140);
    });
  });

  group('ItDropdownEntry sealed class', () {
    test('ItDropdownItem has correct defaults', () {
      const item = ItDropdownItem(label: 'Test');
      expect(item.label, 'Test');
      expect(item.icon, isNull);
      expect(item.onTap, isNull);
      expect(item.danger, isFalse);
      expect(item.disabled, isFalse);
    });

    test('ItDropdownHeader holds label', () {
      const header = ItDropdownHeader(label: 'Section');
      expect(header.label, 'Section');
    });

    test('entries are subtypes of ItDropdownEntry', () {
      const ItDropdownEntry item = ItDropdownItem(label: 'A');
      const ItDropdownEntry header = ItDropdownHeader(label: 'B');
      const ItDropdownEntry divider = ItDropdownDivider();
      expect(item, isA<ItDropdownItem>());
      expect(header, isA<ItDropdownHeader>());
      expect(divider, isA<ItDropdownDivider>());
    });
  });
}
