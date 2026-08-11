// Two components kept state that the parent could not correct.
//
// Both bugs share a shape worth naming: a StatefulWidget derived something in
// `initState` (or latched it on an event) and then never reconsidered it, so
// the widget's rendering and its parent's intent drifted apart with no error
// anywhere. Neither had a test, and neither is visible in a static read —
// they only appear when the parent rebuilds with different inputs, which no
// single-pump widget test does.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: SizedBox(width: 600, child: child)));

void main() {
  group('ItAlert visibility', () {
    testWidgets('uncontrolled: the close button still hides it', (t) async {
      var dismissed = false;
      await t.pumpWidget(_host(ItAlert(
        dismissible: true,
        onDismissed: () => dismissed = true,
        body: const Text('Attenzione'),
      )));
      await t.tap(find.byType(ItActivatable).last);
      await t.pumpAndSettle();

      expect(find.text('Attenzione'), findsNothing);
      expect(dismissed, isTrue,
          reason: 'uncontrolled onDismissed fires after the alert has gone');
    });

    testWidgets('controlled: the parent can dismiss AND re-show', (t) async {
      // The regression. `_visible` was a one-way latch, so once the alert had
      // hidden itself no parent could bring it back — it rendered
      // SizedBox.shrink() for the rest of its life.
      var visible = true;
      await t.pumpWidget(_host(StatefulBuilder(
        builder: (context, setState) => ItAlert(
          dismissible: true,
          visible: visible,
          onDismiss: () => setState(() => visible = false),
          body: const Text('Attenzione'),
        ),
      )));
      expect(find.text('Attenzione'), findsOneWidget);

      await t.tap(find.byType(ItActivatable).last);
      await t.pumpAndSettle();
      expect(find.text('Attenzione'), findsNothing,
          reason: 'controlled onDismiss is a request; the parent honoured it');

      // Re-show: the same State object, told to be visible again.
      visible = true;
      await t.pumpWidget(_host(StatefulBuilder(
        builder: (context, setState) => ItAlert(
          dismissible: true,
          visible: visible,
          onDismiss: () {},
          body: const Text('Attenzione'),
        ),
      )));
      await t.pumpAndSettle();
      expect(find.text('Attenzione'), findsOneWidget,
          reason: 'a controlled alert must come back when the parent says so');

      // And it must be *visible*, not merely present: the fade controller sat
      // at 0 after the dismissal, so without a reset it would occupy its box
      // fully transparent.
      final opacity = t.widgetList<FadeTransition>(find.byType(FadeTransition));
      for (final f in opacity) {
        expect(f.opacity.value, 1.0,
            reason: 'restored alert must be opaque, not an invisible box');
      }
    });
  });

  group('ItAccordion expansion survives an items change', () {
    Widget build(List<String> titles) => _host(ItAccordion(
          allowMultipleOpen: true,
          items: [
            for (final title in titles)
              ItAccordionItem(
                title: title,
                initiallyExpanded: false,
                body: Text('corpo $title'),
              ),
          ],
        ));

    /// Which headers report themselves open, straight from the semantics tree.
    Set<String> expandedHeaders(WidgetTester tester) {
      final open = <String>{};
      void walk(SemanticsNode node) {
        final d = node.getSemanticsData();
        if (d.hasFlag(SemanticsFlag.isExpanded) && d.label.isNotEmpty) {
          open.add(d.label);
        }
        node.visitChildren((c) {
          walk(c);
          return true;
        });
      }

      walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
      return open;
    }

    testWidgets('a stale index does not re-open a later section', (t) async {
      final handle = t.ensureSemantics();

      await t.pumpWidget(build(['A', 'B', 'C']));
      await t.tap(find.text('C'));
      await t.pumpAndSettle();
      expect(expandedHeaders(t), {'C'}, reason: 'the user opened C');

      // The parent removes two sections. Index 2 no longer exists.
      await t.pumpWidget(build(['A']));
      await t.pumpAndSettle();
      expect(expandedHeaders(t), isEmpty,
          reason: 'nothing the user opened is still on screen');

      // ...and then the list grows back. This is where the bug showed: index 2
      // was never removed from the set, so the *new* third section came up
      // already expanded, having never been touched.
      await t.pumpWidget(build(['A', 'B', 'C']));
      await t.pumpAndSettle();
      expect(expandedHeaders(t), isEmpty,
          reason: 'expansion is keyed by index, so a stale index silently '
              'reassigns itself to whatever section later occupies that '
              'position — a section the user never opened');

      handle.dispose();
    });
  });

  _notificationBadge();
}

// ── ItNotificationBadge ─────────────────────────────────────────────────────
//
// In a package where `ItIconAction` makes `label` required on principle, this
// was the widget that most needed a name and had none: `count: 5` announced a
// bare "5" beside whatever it overlaid.
void _notificationBadge() {
  group('ItNotificationBadge announces what it is counting', () {
    String? badgeLabel(WidgetTester tester) {
      String? found;
      void walk(SemanticsNode node) {
        final label = node.getSemanticsData().label;
        if (label.contains('notifiche') || label.contains('messaggi')) {
          found = label;
        }
        node.visitChildren((c) {
          walk(c);
          return true;
        });
      }

      walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
      return found;
    }

    testWidgets('a bare count gets a default name', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(const ItNotificationBadge(
        count: 5,
        child: Icon(Icons.abc),
      )));
      expect(badgeLabel(t), '5 notifiche',
          reason: '"5" on its own says something is five, not what');
      handle.dispose();
    });

    testWidgets('the announced count matches the displayed one', (t) async {
      // Deliberately NOT the true 250. An earlier version announced the real
      // number, on the grounds that speech has no 24px circle to fit — which
      // contradicted an existing contract in content_semantics_test.dart, and
      // lost: a screen-reader user and the person beside them must not read
      // different numbers off one badge. Naming what is being counted was the
      // defect here; the cap is not.
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(const ItNotificationBadge(
        count: 250,
        child: Icon(Icons.abc),
      )));
      expect(find.text('99+'), findsOneWidget);
      expect(badgeLabel(t), '99+ notifiche');
      handle.dispose();
    });

    testWidgets('semanticLabel says what is being counted', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(const ItNotificationBadge(
        count: 3,
        semanticLabel: '3 messaggi non letti',
        child: Icon(Icons.abc),
      )));
      expect(badgeLabel(t), '3 messaggi non letti');
      handle.dispose();
    });
  });
}
