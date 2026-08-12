// The part of "does it sound right" that a machine can actually judge.
//
// Phase 6 — real VoiceOver/TalkBack/NVDA testing — cannot be automated, and
// nothing here claims otherwise. But a reviewer's time is the scarce resource,
// and it should be spent on the questions only a person can answer: is this
// name meaningful, is this order sensible, is this exhausting to listen to.
//
// These are the failures that waste that time because they are mechanical: a
// control with no name, two controls on one screen with the SAME name, and a
// name announced twice because a wrapper and its child both carry it. Each is a
// real defect this package has shipped at least once.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      localizationsDelegates: const [ItLocalizations.delegate],
      home: Scaffold(body: Center(child: SizedBox(width: 700, child: child))),
    );

/// Every node that a screen reader would stop on, with its name.
List<({String label, SemanticsData data})> _stops(WidgetTester tester) {
  final out = <({String label, SemanticsData data})>[];
  void walk(SemanticsNode node) {
    final d = node.getSemanticsData();
    final interactive = d.hasFlag(SemanticsFlag.isButton) ||
        d.hasFlag(SemanticsFlag.isLink) ||
        d.hasFlag(SemanticsFlag.isTextField) ||
        d.hasFlag(SemanticsFlag.hasCheckedState) ||
        d.hasFlag(SemanticsFlag.hasToggledState) ||
        d.hasAction(SemanticsAction.tap);
    if (interactive) out.add((label: d.label.trim(), data: d));
    node.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return out;
}

void main() {
  // Realistic compositions, not single widgets: these defects appear when
  // components are put together, which is the case no per-component contract
  // covers.
  final screens = <String, Widget>{
    'a form': Column(
      children: [
        const ItInput(label: 'Nome'),
        const ItInput(label: 'Cognome'),
        ItCheckbox(value: false, label: 'Accetto', onChanged: (_) {}),
        ItButton(onPressed: () {}, child: const Text('Invia')),
      ],
    ),
    'a page of cards': Column(
      children: [
        ItCard(title: 'Bando scuole', onTap: () {}),
        ItCard(title: 'Bando cultura', onTap: () {}),
      ],
    ),
    'chips and an alert': Column(
      children: [
        ItChip(label: 'Lazio', dismissible: true, onDismiss: () {}),
        ItChip(label: 'Lombardia', dismissible: true, onDismiss: () {}),
        ItAlert(
            dismissible: true, onDismissed: () {}, body: const Text('Nota')),
      ],
    ),
    'a navigation bar': const ItBreadcrumb(items: [
      ItBreadcrumbItem(label: 'Home'),
      ItBreadcrumbItem(label: 'Servizi'),
    ]),
  };

  group('4.1.2 — every interactive node is named', () {
    screens.forEach((name, screen) {
      testWidgets(name, (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(screen));
        await tester.pumpAndSettle();

        final unnamed = _stops(tester).where((s) => s.label.isEmpty).toList();
        expect(unnamed, isEmpty,
            reason: 'In "$name", ${unnamed.length} interactive node(s) have no '
                'accessible name. A screen reader announces those as bare '
                '"button" — the user is told a control exists and not what it '
                'does. ItCard shipped exactly this defect.');
        handle.dispose();
      });
    });
  });

  group('4.1.2 — no two controls on one screen share a name', () {
    // Not a style rule. Two identically-named targets are indistinguishable in
    // a screen reader's element list, so a user choosing between them is
    // guessing. `ItModal` shipped this: its barrier and its close button were
    // both "Chiudi finestra modale".
    screens.forEach((name, screen) {
      testWidgets(name, (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(screen));
        await tester.pumpAndSettle();

        final labels = _stops(tester).map((s) => s.label).toList();
        final seen = <String>{};
        final duplicated =
            labels.where((l) => l.isNotEmpty && !seen.add(l)).toSet();

        expect(duplicated, isEmpty,
            reason:
                'In "$name", these names are used by more than one control: '
                '${duplicated.join(', ')}.\n'
                'They are indistinguishable in an element list, so a user '
                'picking between them is guessing. Name them for what they act '
                'on — "Rimuovi Lazio", not "Rimuovi".');
        handle.dispose();
      });
    });
  });

  testWidgets('4.1.2 — a named wrapper does not repeat its child', (t) async {
    // The double-announcement bug: a wrapper carrying an explicit label whose
    // descendants are NOT excluded, so the merge appends them and the name is
    // said twice. ItCard has an ExcludeSemantics for exactly this reason.
    final handle = t.ensureSemantics();
    await t.pumpWidget(_host(ItCard(
      title: 'Bando scuole',
      semanticLabel: 'Leggi il bando per le scuole',
      onTap: () {},
    )));
    await t.pumpAndSettle();

    final label = _stops(t).first.label;
    expect(label, 'Leggi il bando per le scuole');
    expect(label.contains('Bando scuole'), isFalse,
        reason: 'the override must REPLACE the visible text, not be '
            'concatenated with it — otherwise the card is announced twice over');
    handle.dispose();
  });

  testWidgets('4.1.2 — an icon-only control is never bare', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(_host(ItIconAction(
      icon: BootstrapItaliaIcons.it_close,
      color: const Color(0xFF0066CC),
      label: 'Chiudi il pannello',
      onPressed: () {},
    )));
    await t.pumpAndSettle();

    expect(_stops(t).single.label, 'Chiudi il pannello');
    handle.dispose();
  });

  _controlsDoNotSwallowContent();
}

// ── A control must not swallow the content around it ────────────────────────
//
// Found by reading `doc/at-announcements.md`, not by a failing test. `ItAlert`
// announced its whole self as ONE focusable button called "Domanda non inviata.
// Chiudi": a `Semantics` that sets neither `container` nor `explicitChildNodes`
// merges into the nearest enclosing node, so the dismiss button's role and name
// folded into the alert's live region. The existing contract matched the
// dismiss label as a SUBSTRING, which the merged label still satisfied — the
// test was green and the announcement was wrong.
void _controlsDoNotSwallowContent() {
  Widget host(Widget child) => MaterialApp(
        localizationsDelegates: const [ItLocalizations.delegate],
        home: Scaffold(body: Center(child: SizedBox(width: 600, child: child))),
      );

  /// Every node that is a button, with its exact name.
  List<String> buttonNames(WidgetTester tester) {
    final out = <String>[];
    void walk(SemanticsNode n) {
      final d = n.getSemanticsData();
      if (d.hasFlag(SemanticsFlag.isButton)) out.add(d.label.trim());
      n.visitChildren((c) {
        walk(c);
        return true;
      });
    }

    walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
    return out;
  }

  testWidgets('a dismissible ItAlert keeps its body out of the button',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(ItAlert(
      variant: ItAlertVariant.danger,
      dismissible: true,
      onDismissed: () {},
      body: const Text('Domanda non inviata.'),
    )));
    await tester.pumpAndSettle();

    final names = buttonNames(tester);
    expect(names, hasLength(1),
        reason: 'exactly one control: the close button');
    // Equality, NOT contains. The whole defect was that a merged label still
    // "contained" the right words.
    expect(names.single, 'Chiudi',
        reason: 'the button is named for what it does. It was called "Domanda '
            'non inviata. Chiudi" — the alert text folded into the control, so '
            'the message was announced as part of a button and there was no '
            'separate control to reach.');

    expect(find.bySemanticsLabel('Domanda non inviata.'), findsOneWidget,
        reason: 'and the message is still its own node, so the live region '
            'announces it');
    handle.dispose();
  });
}
