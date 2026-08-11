// Contracts for components a coverage audit found had visual parity but no
// accessibility contract.
//
// These are easy to overlook precisely because they look finished: they render
// correctly, they have parity keys, and nothing about a screenshot reveals that
// a screen-reader user gets nothing useful from them. Each group below states
// the obligation and the WCAG criterion behind it.
import 'dart:ui' show CheckedState;

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        home: Scaffold(body: Center(child: child)),
      ),
    );

SemanticsNode? _find(WidgetTester tester, bool Function(SemanticsData) test) {
  SemanticsNode? found;
  void walk(SemanticsNode node) {
    if (found != null) return;
    if (test(node.getSemanticsData())) {
      found = node;
      return;
    }
    node.visitChildren((child) {
      walk(child);
      return found == null;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

/// Every label in the tree, joined — for asserting *something* conveys a value.
String _allLabels(WidgetTester tester) {
  final buf = StringBuffer();
  void walk(SemanticsNode node) {
    buf.write(' ${node.getSemanticsData().label}');
    node.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return buf.toString();
}

void main() {
  group('ItNotificationBadge — the count IS the information', () {
    testWidgets('1.1.1 / 4.1.2: the count is announced, not just painted',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItNotificationBadge(
          count: 5,
          child: Icon(Icons.notifications),
        ),
      ));

      // The whole point of this widget is the number. If it is only painted,
      // a screen-reader user is told there is a bell and nothing else — the
      // one piece of information the component exists to convey is lost.
      expect(_allLabels(tester), contains('5'),
          reason: 'the badge count must reach assistive technology');
      handle.dispose();
    });

    testWidgets('the capped "99+" form is announced as shown', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItNotificationBadge(
          count: 150,
          child: Icon(Icons.notifications),
        ),
      ));

      expect(_allLabels(tester), contains('99'),
          reason: 'a capped count must not announce the true number, which '
              'would disagree with what sighted users see');
      handle.dispose();
    });

    testWidgets('a zero count renders nothing and announces nothing',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItNotificationBadge(
          count: 0,
          child: Icon(Icons.notifications),
        ),
      ));

      expect(_allLabels(tester), isNot(contains('0')),
          reason: 'an empty badge must not announce a phantom "0"');
      handle.dispose();
    });
  });

  group('ItIcon — decorative vs meaningful', () {
    testWidgets('1.1.1: an icon given a semanticLabel exposes it',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItIcon(Icons.warning, semanticLabel: 'Attenzione'),
      ));

      expect(_allLabels(tester), contains('Attenzione'));
      handle.dispose();
    });

    testWidgets('1.1.1: a decorative icon contributes no label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItIcon(Icons.star),
      ));

      // A decorative glyph that announces itself is noise: the user hears a
      // meaningless token between the content they actually asked for.
      expect(_allLabels(tester).trim(), isEmpty,
          reason: 'an unlabelled icon is decorative and must be silent');
      handle.dispose();
    });
  });

  group('ItCollapse — hidden content must really be hidden', () {
    testWidgets('4.1.2: collapsed content is removed from the semantics tree',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 400,
          child:
              ItCollapse(isExpanded: false, child: Text('Contenuto nascosto')),
        ),
      ));
      await tester.pumpAndSettle();

      // Content that is visually hidden but still in the semantics tree is worse
      // than either state on its own: a screen-reader user is read text they
      // cannot see and cannot act on.
      expect(_allLabels(tester), isNot(contains('Contenuto nascosto')),
          reason: 'collapsed content must not be announced');
      handle.dispose();
    });

    testWidgets('expanded content IS in the semantics tree', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 400,
          child:
              ItCollapse(isExpanded: true, child: Text('Contenuto visibile')),
        ),
      ));
      await tester.pumpAndSettle();

      expect(_allLabels(tester), contains('Contenuto visibile'));
      handle.dispose();
    });
  });

  group('ItCheckboxGroup — the group label must reach its options', () {
    testWidgets('1.3.1: the group label is exposed', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 400,
          child: ItCheckboxGroup<String>(
            label: 'Preferenze di contatto',
            options: const [
              ItCheckboxOption(value: 'email', label: 'Email'),
              ItCheckboxOption(value: 'sms', label: 'SMS'),
            ],
            values: const {'email'},
            onChanged: (_) {},
          ),
        ),
      ));

      expect(_allLabels(tester), contains('Preferenze di contatto'),
          reason: 'without the group label, "Email" and "SMS" are announced '
              'with no indication of what they are options FOR (WCAG 1.3.1)');
      handle.dispose();
    });

    testWidgets('4.1.2: each option still exposes its own checked state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 400,
          child: ItCheckboxGroup<String>(
            label: 'Preferenze',
            options: const [
              ItCheckboxOption(value: 'email', label: 'Email'),
              ItCheckboxOption(value: 'sms', label: 'SMS'),
            ],
            values: const {'email'},
            onChanged: (_) {},
          ),
        ),
      ));

      // `flagsCollection.isChecked` is a tristate (`CheckedState`), not a bool —
      // the deprecated `hasFlag` API modelled this as a has-state/is-state pair.
      final checked = _find(
        tester,
        (d) =>
            d.flagsCollection.isChecked == CheckedState.isTrue &&
            d.label.contains('Email'),
      );
      expect(checked, isNotNull,
          reason: 'grouping must not swallow the per-option checked state');
      handle.dispose();
    });
  });

  group('ItSpinner — a loading state must be perceivable', () {
    testWidgets('1.1.1 / 4.1.3: the spinner announces what it is',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const ItSpinner(doubleRing: true)));
      await tester.pump(const Duration(milliseconds: 100));

      // A bare painted ring conveys "something is happening" only to people who
      // can see it. Without a label, a screen-reader user meets silence and has
      // no way to tell a slow page from a broken one.
      expect(_allLabels(tester), contains('Caricamento'),
          reason: 'the spinner must expose its loading semantics');
      handle.dispose();

      // Leave no live animation behind: pumpWidget of an empty tree disposes
      // the controller, which would otherwise keep the test binding busy.
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a custom semanticLabel is honoured', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItSpinner(semanticLabel: 'Invio in corso'),
      ));

      expect(_allLabels(tester), contains('Invio in corso'));
      handle.dispose();
    });

    testWidgets('a resting spinner schedules no frames', (tester) async {
      await tester.pumpWidget(_host(const ItSpinner(animating: false)));
      // `.progress-spinner` is a static ring; only `.progress-spinner-active`
      // animates. If the resting spinner still drives a controller this call
      // never returns — which is exactly how the bug was found.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('ItNotification — WCAG 2.2.1 Timing Adjustable', () {
    testWidgets('show() does not auto-dismiss by default', (tester) async {
      // An auto-dismissing toast is a content-set time limit, and none of
      // 2.2.1's exceptions (real-time, essential, 20-hour) cover one. The
      // conformant default is therefore no limit at all; a caller that wants
      // auto-dismiss opts in and takes on the obligation.
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (c) {
          ctx = c;
          return const SizedBox.shrink();
        }),
      ));

      ItNotification.show(
          context: ctx, title: 'Salvato', body: 'Documento salvato');
      await tester.pump();
      expect(find.byType(ItNotification), findsOneWidget);

      // Well past the 5s that used to be the default.
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();
      expect(find.byType(ItNotification), findsOneWidget,
          reason: 'the default must not impose a time limit');
    });

    testWidgets('an explicit duration still dismisses', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (c) {
          ctx = c;
          return const SizedBox.shrink();
        }),
      ));

      ItNotification.show(
        context: ctx,
        title: 'Temporaneo',
        duration: const Duration(seconds: 3),
      );
      await tester.pump();
      expect(find.byType(ItNotification), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.byType(ItNotification), findsNothing,
          reason: 'opting in must still work');
    });
  });
}
