// WCAG 2.2 §2.5.8 Target Size (Minimum), level AA — NEW in WCAG 2.2.
//
// Every pointer target must be at least 24x24 CSS px, unless an exception
// applies (inline targets in a sentence, targets whose spacing keeps a 24px
// circle clear, or where the presentation is legally required / essential).
//
// This matters more for a design-system port than for an application: the
// design system dictates the control sizes every downstream PA app inherits, so
// a control that is too small here is too small in every service built on it.
//
// Bootstrap Italia predates WCAG 2.2 and several of its controls are painted
// smaller than 24px (the checkbox box is 20x20, the modal close glyph 16x16).
// The correct fix is to enlarge the *hit target* while leaving the painted size
// alone — visual parity is preserved and the control becomes operable. These
// tests measure the hit target, which is what 2.5.8 is about, not the paint.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.2 §2.5.8 minimum, in logical pixels.
const double kMinTarget = 24.0;

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        home: Scaffold(body: Center(child: child)),
      ),
    );

/// Smallest rect that receives pointer events for [finder].
Size _hitTargetOf(WidgetTester tester, Finder finder) => tester.getSize(finder);

/// Whether a pointer at [p] lands anywhere inside [finder]'s render subtree.
///
/// [_hitTargetOf] measures the *layout* box, which is why the checkbox case
/// above pairs it with a tap on the label: a control can measure 24px tall
/// while only a 20x20 span in the middle of it actually responds. This probes
/// the thing 2.5.8 is actually about — the region that accepts the pointer.
bool _hits(WidgetTester tester, Finder finder, Offset p) {
  final root = tester.renderObject(finder);
  for (final entry in tester.hitTestOnBinding(p).path) {
    RenderObject? node =
        entry.target is RenderObject ? entry.target as RenderObject : null;
    while (node != null) {
      if (identical(node, root)) return true;
      node = node.parent;
    }
  }
  return false;
}

/// Asserts that a full 24x24 square centred on [finder] accepts the pointer,
/// not merely that the widget lays out that big.
void _expectSolid24Target(WidgetTester tester, Finder finder, String what) {
  final box = tester.getRect(finder);
  expect(box.width, greaterThanOrEqualTo(kMinTarget),
      reason: '$what lays out only ${box.width}px wide, so no ${kMinTarget}px '
          'target can exist inside it');
  expect(box.height, greaterThanOrEqualTo(kMinTarget),
      reason: '$what lays out only ${box.height}px tall, so no ${kMinTarget}px '
          'target can exist inside it');

  // A hair inside, so a probe never lands exactly on a boundary.
  final square = Rect.fromCenter(
    center: box.center,
    width: kMinTarget,
    height: kMinTarget,
  ).deflate(0.01);
  final probes = <String, Offset>{
    'top-left': square.topLeft,
    'top-right': square.topRight,
    'bottom-left': square.bottomLeft,
    'bottom-right': square.bottomRight,
    'centre': square.center,
  };
  for (final probe in probes.entries) {
    expect(_hits(tester, finder, probe.value), isTrue,
        reason: '$what: the ${probe.key} of the ${kMinTarget}x$kMinTarget '
            'square centred on the control does not respond to a pointer, so '
            'the real target is smaller than 2.5.8 allows');
  }
}

void main() {
  group('WCAG 2.2 AA §2.5.8 Target Size (Minimum)', () {
    testWidgets('ItButton meets the minimum on every size variant',
        (tester) async {
      for (final size in ItButtonSize.values) {
        await tester.pumpWidget(_host(
          ItButton(size: size, onPressed: () {}, child: const Text('Ok')),
        ));
        final s = _hitTargetOf(tester, find.byType(ItButton));
        expect(
          s.height,
          greaterThanOrEqualTo(kMinTarget),
          reason: 'ItButton(size: $size) is ${s.height}px tall; '
              '2.5.8 requires >= $kMinTarget.',
        );
        expect(s.width, greaterThanOrEqualTo(kMinTarget),
            reason: 'ItButton(size: $size) is ${s.width}px wide.');
      }
    });

    testWidgets(
        'ItCheckbox tap target reaches 24px even though the box is 20px',
        (tester) async {
      var fired = false;
      await tester.pumpWidget(_host(
        ItCheckbox(
          label: 'Accetto le condizioni',
          value: false,
          onChanged: (_) => fired = true,
        ),
      ));
      final s = _hitTargetOf(tester, find.byType(ItCheckbox));
      expect(
        s.height,
        greaterThanOrEqualTo(kMinTarget),
        reason:
            'Bootstrap Italia paints a 20x20 box; the HIT TARGET must still '
            'be at least ${kMinTarget}px for WCAG 2.2 §2.5.8. Enlarge the hit '
            'area, not the painted control.',
      );

      // The row only counts as the target if the label is genuinely part of it.
      // Without this, the size assertion above would keep passing even if a
      // refactor shrank the tappable area back to the 20px box — the widget
      // would still measure 24px tall while failing 2.5.8 in practice.
      final topLeft = tester.getTopLeft(find.byType(ItCheckbox));
      await tester.tapAt(
        Offset(topLeft.dx + s.width - 8, topLeft.dy + s.height / 2),
      );
      await tester.pump();
      expect(fired, isTrue,
          reason: 'tapping the label must toggle the checkbox, otherwise the '
              'real target is only the 20px box and 2.5.8 fails');
    });

    testWidgets('ItRadio tap target reaches 24px', (tester) async {
      await tester.pumpWidget(_host(
        ItRadio<int>(value: 1, groupValue: 0, label: 'Uno', onChanged: (_) {}),
      ));
      final s = _hitTargetOf(tester, find.byType(ItRadio<int>));
      expect(s.height, greaterThanOrEqualTo(kMinTarget),
          reason: 'radio hit target is ${s.height}px; 2.5.8 requires >= 24.');
    });

    testWidgets('ItToggle tap target reaches 24px', (tester) async {
      await tester.pumpWidget(_host(
        ItToggle(label: 'Notifiche', value: false, onChanged: (_) {}),
      ));
      final s = _hitTargetOf(tester, find.byType(ItToggle));
      expect(s.height, greaterThanOrEqualTo(kMinTarget),
          reason: 'toggle hit target is ${s.height}px; 2.5.8 requires >= 24.');
    });

    testWidgets('ItChip is operable at the minimum size when tappable',
        (tester) async {
      await tester.pumpWidget(_host(
        ItChip(label: 'Label', onTap: () {}),
      ));
      final s = _hitTargetOf(tester, find.byType(ItChip));
      expect(
        s.height,
        greaterThanOrEqualTo(kMinTarget),
        reason: 'a tappable chip is a target; `.chip` is 24px tall in CSS so '
            'this should hold exactly at the boundary.',
      );
    });
  });

  // The group above measures the layout box. These probe the actual pointer
  // region, which is where the form controls were failing: hit testing used to
  // defer to the children, so the only things that responded were the 20x20
  // painted box and the label glyphs — with the 4px margin around the box and
  // the 8px gutter before the label falling straight through.
  group('§2.5.8 — the measured box is genuinely all target', () {
    testWidgets('an unlabelled ItCheckbox is tappable across its whole box',
        (tester) async {
      await tester.pumpWidget(_host(
        ItCheckbox(value: false, semanticLabel: 'Accetto', onChanged: (_) {}),
      ));
      _expectSolid24Target(
        tester,
        find.byType(ItCheckbox),
        'ItCheckbox with no label',
      );
    });

    testWidgets('a labelled ItCheckbox has no dead zones', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(
        ItCheckbox(label: 'Accetto', value: false, onChanged: (_) => taps++),
      ));

      final box = tester.getRect(find.byType(ItCheckbox));
      final probes = <String, Offset>{
        'the 4px margin above and left of the box':
            box.topLeft + const Offset(1, 1),
        'the gutter between the box and the label':
            box.topLeft + const Offset(28, 12),
        'the far end of the label row': box.centerRight - const Offset(1, 0),
      };
      for (final probe in probes.entries) {
        taps = 0;
        await tester.tapAt(probe.value);
        await tester.pump();
        expect(taps, 1,
            reason: '2.5.8: ${probe.key} is inside the control\'s 24px row but '
                'does not activate it');
      }
    });

    testWidgets('an unlabelled ItRadio is tappable across its whole box',
        (tester) async {
      await tester.pumpWidget(
          _host(ItRadio<int>(value: 1, groupValue: 0, onChanged: (_) {})));
      _expectSolid24Target(
        tester,
        find.byType(ItRadio<int>),
        'ItRadio with no label',
      );
    });

    testWidgets('ItToggle is tappable across its whole row', (tester) async {
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItToggle(label: 'Notifiche', value: false, onChanged: (_) {}),
        ),
      ));
      _expectSolid24Target(tester, find.byType(ItToggle), 'ItToggle');
    });

    testWidgets('ItSelect is tappable across its whole control',
        (tester) async {
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItSelect<String>(
            groupMargin: false,
            label: 'Provincia',
            items: const [ItSelectItem(value: 'RM', label: 'Roma')],
            onChanged: (_) {},
          ),
        ),
      ));
      _expectSolid24Target(
        tester,
        find.byType(ItSelect<String>),
        'ItSelect',
      );
    });

    testWidgets('the password visibility toggle meets the minimum',
        (tester) async {
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 320,
          child: ItInput(
            groupMargin: false,
            label: 'Password',
            obscureText: true,
            showPasswordToggle: true,
          ),
        ),
      ));

      // `.password-icon` is a 24px glyph — exactly at the boundary, so it only
      // conforms if the whole glyph responds rather than just its strokes.
      final icon = find.byIcon(BootstrapItaliaIcons.it_password_visible);
      expect(icon, findsOneWidget);
      final box = tester.getRect(icon);
      expect(box.width, greaterThanOrEqualTo(kMinTarget));
      expect(box.height, greaterThanOrEqualTo(kMinTarget));

      for (final p in <Offset>[
        box.topLeft + const Offset(1, 1),
        box.bottomRight - const Offset(1, 1),
        box.center,
      ]) {
        expect(_hits(tester, icon, p), isTrue,
            reason: '2.5.8: the password toggle only responds on part of its '
                '24px glyph');
      }
    });
  });
}
