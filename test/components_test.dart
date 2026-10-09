import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_flutter/src/components/spinner/progress_spinner.dart';
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
      // The loading affordance is Bootstrap Italia's own painted spinner, not
      // Material's CircularProgressIndicator.
      expect(find.byType(ItProgressSpinner), findsOneWidget);
    });

    testWidgets('outline variant draws a ring and no fill', (tester) async {
      // Asserts the rendered result, not the widget type: ItButton no longer
      // wraps a Material OutlinedButton. The outline ring is
      // a foregroundDecoration because `.btn-outline-*` uses an INSET box-shadow
      // that consumes no layout space — a laid-out border would make an outline
      // button larger than the solid button it has to match.
      await tester.pumpWidget(_wrap(
        ItButton(
          outline: true,
          onPressed: () {},
          child: const Text('Outline'),
        ),
      ));

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ItButton),
              matching: find.byType(Container),
            )
            .first,
      );
      final ring = container.foregroundDecoration! as BoxDecoration;
      expect(ring.border, isNotNull, reason: 'outline must paint a ring');
      expect((ring.border! as Border).top.width, 2);
      expect(
        (container.decoration! as BoxDecoration).color?.a,
        0,
        reason: 'outline buttons have no fill until hovered',
      );
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
        const ItAlert(body: Text('Alert message')),
      ));

      expect(find.text('Alert message'), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItAlert(
          title: 'Attenzione',
          body: Text('Details'),
        ),
      ));

      expect(find.text('Attenzione'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItAlert(
          icon: Icons.info,
          body: Text('Info'),
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
          body: const Text('Dismiss me'),
        ),
      ));

      expect(find.text('Dismiss me'), findsOneWidget);

      await tester.tap(find.byIcon(BootstrapItaliaIcons.it_close));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });
  });

  group('ItSpinner', () {
    testWidgets('paints the .progress-spinner figure', (tester) async {
      await tester.pumpWidget(_wrap(const ItSpinner()));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      final spinner =
          tester.widget<ItProgressSpinner>(find.byType(ItProgressSpinner));
      expect(spinner.doubleRing, isFalse);
      // `.progress-spinner { width: 48px; height: 48px }` is the default size.
      expect(spinner.diameter, 48);
      // `border: 4px solid hsl(210,3%,85%)` — the track is always painted,
      // which is what distinguishes the CSS figure from Material's trackless
      // indeterminate arc.
      expect(spinner.trackColor, kItSpinnerTrackColor);
    });

    testWidgets('spins by default — a static loading indicator is not one',
        (tester) async {
      await tester.pumpWidget(_wrap(const ItSpinner()));
      final s =
          tester.widget<ItProgressSpinner>(find.byType(ItProgressSpinner));
      expect(s.animating, isTrue);
      expect(s.doubleRing, isFalse,
          reason: 'the plain animating spinner is the commonest case and used '
              'to be unreachable: one flag drove both CSS modifiers');
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('animating and doubleRing are independent', (tester) async {
      await tester.pumpWidget(_wrap(const ItSpinner(animating: false)));
      final s =
          tester.widget<ItProgressSpinner>(find.byType(ItProgressSpinner));
      expect(s.animating, isFalse);
      await tester.pumpAndSettle(); // would hang if a resting spinner ticked
    });

    testWidgets('active variant paints .progress-spinner-double',
        (tester) async {
      await tester.pumpWidget(_wrap(const ItSpinner(doubleRing: true)));

      final spinner =
          tester.widget<ItProgressSpinner>(find.byType(ItProgressSpinner));
      expect(spinner.doubleRing, isTrue);
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
      expect(icon.size, ItIconSize.medium.value);
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItIcon(Icons.home, size: ItIconSize.extraLarge),
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
        ItChip(label: 'Remove', dismissible: true, onDismiss: () {}),
      ));

      expect(find.byIcon(BootstrapItaliaIcons.it_close), findsOneWidget);
    });

    testWidgets('calls onDismiss when close tapped', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(_wrap(
        ItChip(
          label: 'Remove',
          dismissible: true,
          onDismiss: () => dismissed = true,
        ),
      ));

      await tester.tap(find.byIcon(BootstrapItaliaIcons.it_close));
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
