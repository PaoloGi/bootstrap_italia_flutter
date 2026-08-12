// `.top-fix`, `.bottom-fix`, `.left-fix` and `.right-fix`.
//
// From the Bootstrap Italia docs page for Notifiche, which the example app
// mirrors. The four modifiers do two things the card has to know about — which
// corners stay rounded, and which side carries the variant accent — so they are
// not purely a matter of where `show` drops the overlay.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  final data = BootstrapItaliaThemeData.standard();
  return BootstrapItaliaTheme(
    data: data,
    child: MaterialApp(
      theme: data.toThemeData(),
      home: Scaffold(body: Align(alignment: Alignment.topLeft, child: child)),
    ),
  );
}

/// The card's own decoration.
BoxDecoration _card(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(ItNotification),
          matching: find.byType(Container),
        )
        .first,
  );
  return container.decoration! as BoxDecoration;
}

const _r = Radius.circular(BootstrapItaliaBorders.radius);

void main() {
  group('corner rounding', () {
    testWidgets('the floating placements keep all four corners', (t) async {
      for (final position in const [
        ItNotificationPosition.bottomRight,
        ItNotificationPosition.topLeft,
        ItNotificationPosition.topCenter,
      ]) {
        await t.pumpWidget(_host(ItNotification(
          key: ValueKey(position),
          position: position,
          title: 'Titolo notifica',
        )));
        await t.pump();

        expect(_card(t).borderRadius, const BorderRadius.all(_r),
            reason: '`border-radius: 4px` with no `…-fix` modifier — the docs '
                'call this "arrotondamento ai 4 angoli"');
      }
    });

    testWidgets('each fixed placement squares the pair it leans on', (t) async {
      const expected = {
        ItNotificationPosition.topFix: BorderRadius.vertical(bottom: _r),
        ItNotificationPosition.bottomFix: BorderRadius.vertical(top: _r),
        ItNotificationPosition.leftFix: BorderRadius.horizontal(right: _r),
        ItNotificationPosition.rightFix: BorderRadius.horizontal(left: _r),
      };

      for (final entry in expected.entries) {
        await t.pumpWidget(_host(ItNotification(
          key: ValueKey(entry.key),
          position: entry.key,
          title: 'Titolo notifica',
        )));
        await t.pump();

        expect(_card(t).borderRadius, entry.value,
            reason: '`.notification.${entry.key.name} { border-…-radius: 0 }` '
                'on the two corners against the window edge');
      }
    });

    testWidgets('the default constructor is unchanged', (t) async {
      // Additive: `ItNotification()` with no position is what the parity
      // captures hold, so it must still be four rounded corners and a left
      // accent.
      await t.pumpWidget(_host(const ItNotification(
        title: 'Titolo notifica',
        icon: BootstrapItaliaIcons.it_info_circle,
      )));
      await t.pump();

      final card = _card(t);
      expect(card.borderRadius, const BorderRadius.all(_r));
      expect((card.border! as Border).left.width, 4);
      expect((card.border! as Border).right, BorderSide.none);
    });
  });

  group('the accent edge', () {
    testWidgets('leftFix moves it to the right of the card', (t) async {
      await t.pumpWidget(_host(const ItNotification(
        position: ItNotificationPosition.leftFix,
        variant: ItNotificationVariant.success,
        title: 'Titolo notifica',
        icon: BootstrapItaliaIcons.it_check_circle,
      )));
      await t.pump();

      final border = _card(t).border! as Border;
      expect(border.left, BorderSide.none,
          reason: '`.notification.left-fix { border-left: none }`');
      expect(border.right.width, 4,
          reason: '`.left-fix { border-right-style: solid; '
              'border-right-width: 4px }` — the left edge is the one against '
              'the window, so the accent has to move');
      expect(border.right.color, BootstrapItaliaColors.success);
    });

    testWidgets('every other placement keeps it on the left', (t) async {
      for (final position in const [
        ItNotificationPosition.rightFix,
        ItNotificationPosition.topFix,
        ItNotificationPosition.bottomFix,
      ]) {
        await t.pumpWidget(_host(ItNotification(
          key: ValueKey(position),
          position: position,
          variant: ItNotificationVariant.warning,
          title: 'Titolo notifica',
          icon: BootstrapItaliaIcons.it_warning_circle,
        )));
        await t.pump();

        final border = _card(t).border! as Border;
        expect(border.left.width, 4);
        expect(border.right, BorderSide.none);
      }
    });

    testWidgets('no icon means no accent at all', (t) async {
      // `.notification.with-icon` is what carries the border; a titleless,
      // iconless notification has no accent to move.
      await t.pumpWidget(_host(const ItNotification(
        position: ItNotificationPosition.leftFix,
        title: 'Titolo notifica',
      )));
      await t.pump();

      expect(_card(t).border, isNull);
    });
  });

  group('show() places the fixed variants flush', () {
    Future<Rect> _showAt(
      WidgetTester tester,
      ItNotificationPosition position,
    ) async {
      final data = BootstrapItaliaThemeData.standard();
      late BuildContext ctx;
      await tester.pumpWidget(BootstrapItaliaTheme(
        data: data,
        child: MaterialApp(
          theme: data.toThemeData(),
          home: Scaffold(
            body: Builder(builder: (context) {
              ctx = context;
              return const SizedBox.expand();
            }),
          ),
        ),
      ));
      ItNotification.show(
        context: ctx,
        title: 'Titolo notifica',
        position: position,
      );
      await tester.pumpAndSettle();
      return tester.getRect(find.byType(ItNotification));
    }

    testWidgets('topFix touches the top edge', (t) async {
      final rect = await _showAt(t, ItNotificationPosition.topFix);
      expect(rect.top, 0,
          reason: '`.notification.top-fix { top: 0 }` — no inset and no safe '
              'area, or the squared corners would sit in mid-air');
    });

    testWidgets('bottomFix touches the bottom edge', (t) async {
      final rect = await _showAt(t, ItNotificationPosition.bottomFix);
      final screen = t.getSize(find.byType(MaterialApp));
      expect(rect.bottom, screen.height);
    });

    testWidgets('leftFix touches the left edge', (t) async {
      final rect = await _showAt(t, ItNotificationPosition.leftFix);
      expect(rect.left, 0);
    });

    testWidgets('rightFix touches the right edge', (t) async {
      final rect = await _showAt(t, ItNotificationPosition.rightFix);
      final screen = t.getSize(find.byType(MaterialApp));
      expect(rect.right, screen.width);
    });

    testWidgets('the default placement still floats clear', (t) async {
      final rect = await _showAt(t, ItNotificationPosition.bottomRight);
      final screen = t.getSize(find.byType(MaterialApp));
      expect(rect.right, lessThan(screen.width),
          reason: 'the floating placements keep a 16px inset so the drop '
              'shadow has somewhere to fall');
      expect(rect.bottom, lessThan(screen.height));
    });
  });
}
