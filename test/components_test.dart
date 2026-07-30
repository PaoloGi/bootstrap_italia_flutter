import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('ItButton', () {
    testWidgets('renders child text', (tester) async {
      await tester.pumpWidget(_wrap(
        ItButton(
          onPressed: () {},
          child: const Text('Click me'),
        ),
      ));

      expect(find.text('Click me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(_wrap(
        ItButton(
          onPressed: () => pressed = true,
          child: const Text('Tap'),
        ),
      ));

      await tester.tap(find.text('Tap'));
      expect(pressed, isTrue);
    });

    testWidgets('disabled button does not fire onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(_wrap(
        ItButton(
          disabled: true,
          onPressed: () => pressed = true,
          child: const Text('Tap'),
        ),
      ));

      await tester.tap(find.text('Tap'));
      expect(pressed, isFalse);
    });

    testWidgets('loading state disables button', (tester) async {
      var pressed = false;
      await tester.pumpWidget(_wrap(
        ItButton(
          loading: true,
          onPressed: () => pressed = true,
          child: const Text('Loading'),
        ),
      ));

      await tester.tap(find.text('Loading'));
      expect(pressed, isFalse);
      // Should show a CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('outline variant renders OutlinedButton', (tester) async {
      await tester.pumpWidget(_wrap(
        ItButton(
          outline: true,
          onPressed: () {},
          child: const Text('Outline'),
        ),
      ));

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('block variant takes full width', (tester) async {
      await tester.pumpWidget(_wrap(
        ItButton(
          block: true,
          onPressed: () {},
          child: const Text('Block'),
        ),
      ));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('renders leading icon', (tester) async {
      await tester.pumpWidget(_wrap(
        ItButton(
          icon: Icons.check,
          onPressed: () {},
          child: const Text('OK'),
        ),
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('ItBadge', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItBadge(child: Text('New')),
      ));

      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('renders all variants', (tester) async {
      for (final variant in ItBadgeVariant.values) {
        await tester.pumpWidget(_wrap(
          ItBadge(variant: variant, child: const Text('X')),
        ));
        expect(find.text('X'), findsOneWidget);
      }
    });
  });

  group('ItNotificationBadge', () {
    testWidgets('shows count when > 0', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItNotificationBadge(
          count: 5,
          child: Icon(Icons.mail),
        ),
      ));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('hides when count is 0', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItNotificationBadge(
          count: 0,
          child: Icon(Icons.mail),
        ),
      ));

      expect(find.byType(ItBadge), findsNothing);
    });

    testWidgets('shows max+ when exceeding max', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItNotificationBadge(
          count: 150,
          max: 99,
          child: Icon(Icons.mail),
        ),
      ));

      expect(find.text('99+'), findsOneWidget);
    });
  });

  group('ItAlert', () {
    testWidgets('renders content', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItAlert(child: Text('Alert message')),
      ));

      expect(find.text('Alert message'), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItAlert(
          title: 'Attenzione',
          child: Text('Details'),
        ),
      ));

      expect(find.text('Attenzione'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItAlert(
          icon: Icons.info,
          child: Text('Info'),
        ),
      ));

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('dismissible alert hides on close tap', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(_wrap(
        ItAlert(
          dismissible: true,
          onDismissed: () => dismissed = true,
          child: const Text('Dismiss me'),
        ),
      ));

      expect(find.text('Dismiss me'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });
  });

  group('ItSpinner', () {
    testWidgets('renders CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(_wrap(const ItSpinner()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('active variant shows two indicators', (tester) async {
      await tester.pumpWidget(_wrap(const ItSpinner(active: true)));

      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    });

    testWidgets('has accessibility label', (tester) async {
      await tester.pumpWidget(_wrap(const ItSpinner()));

      expect(
        find.bySemanticsLabel('Caricamento in corso'),
        findsOneWidget,
      );
    });
  });

  group('ItIcon', () {
    testWidgets('renders with default size', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItIcon(Icons.home),
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, ItIconSize.md.value);
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItIcon(Icons.home, size: ItIconSize.xl),
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 64);
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItIcon(Icons.home, color: Colors.red),
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.red);
    });
  });

  group('ItChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItChip(label: 'Flutter'),
      ));

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItChip(label: 'Tag', icon: Icons.label),
      ));

      expect(find.byIcon(Icons.label), findsOneWidget);
    });

    testWidgets('dismissible shows close icon', (tester) async {
      await tester.pumpWidget(_wrap(
        ItChip(label: 'Remove', dismissible: true, onDismissed: () {}),
      ));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onDismissed when close tapped', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(_wrap(
        ItChip(
          label: 'Remove',
          dismissible: true,
          onDismissed: () => dismissed = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });

    testWidgets('calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItChip(label: 'Tap me', onTap: () => tapped = true),
      ));

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('disabled does not call onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ItChip(label: 'Tap me', disabled: true, onTap: () => tapped = true),
      ));

      await tester.tap(find.text('Tap me'));
      expect(tapped, isFalse);
    });
  });
}
