// Generates `doc/at-announcements.md`: what each component gives a screen
// reader, in order.
//
// This is NOT a test. It asserts nothing. It exists because Phase 6 — real
// VoiceOver/TalkBack/NVDA testing — is the one item automation cannot close,
// and the thing that makes it expensive is not the screen readers. It is that a
// reviewer must discover, component by component, what *should* be announced
// before they can judge what *is*.
//
// The 574 contracts prove a role and a state are exposed. They cannot prove the
// resulting announcement is intelligible, correctly ordered, or not maddening to
// hear — three properties only a person can judge. So this dumps the raw
// material for that judgement: every semantics node with a name or a role, in
// tree order, plus the Tab order, plus the actions each node offers.
//
// Read the generated file next to a real screen reader. Where they disagree,
// the screen reader is right and the disagreement is the finding.
// ignore_for_file: deprecated_member_use
//
// `SemanticsData.hasFlag` is deprecated in favour of `flagsCollection`. It is
// used 117 times across `test/a11y/`, which the analyzer never sees because
// `analysis_options.yaml` excludes `test/**` — this file trips the lint only
// because `tool/` IS analysed. Migrating one file would leave two APIs side by
// side in the same suite for a reader to reconcile. It should be one sweep over
// all 118 sites, and it is not this change.
import 'dart:io';

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _out = StringBuffer();

String _roles(SemanticsData d) {
  final roles = <String>[
    if (d.hasFlag(SemanticsFlag.isButton)) 'button',
    if (d.hasFlag(SemanticsFlag.isLink)) 'link',
    if (d.hasFlag(SemanticsFlag.isHeader)) 'heading',
    if (d.hasFlag(SemanticsFlag.isTextField)) 'textfield',
    if (d.hasFlag(SemanticsFlag.isImage)) 'image',
    // Flutter has no `checkbox`/`switch`/`radio` role flag — it conveys them
    // through the state flags, and the platform layer maps that to a role. So
    // infer it here, or the preview reads as an unlabelled thing that happens
    // to be checkable.
    if (d.hasFlag(SemanticsFlag.hasCheckedState) &&
        !d.hasFlag(SemanticsFlag.isInMutuallyExclusiveGroup))
      'checkbox',
    if (d.hasFlag(SemanticsFlag.isInMutuallyExclusiveGroup)) 'radio',
    if (d.hasFlag(SemanticsFlag.hasToggledState)) 'switch',
    if (d.hasFlag(SemanticsFlag.scopesRoute)) 'route',
    if (d.hasFlag(SemanticsFlag.namesRoute)) 'names-route',
  ];
  return roles.isEmpty ? '' : roles.join('/');
}

String _states(SemanticsData d) {
  final states = <String>[
    if (d.hasFlag(SemanticsFlag.hasCheckedState))
      d.hasFlag(SemanticsFlag.isChecked) ? 'checked' : 'unchecked',
    if (d.hasFlag(SemanticsFlag.hasToggledState))
      d.hasFlag(SemanticsFlag.isToggled) ? 'on' : 'off',
    if (d.hasFlag(SemanticsFlag.hasExpandedState))
      d.hasFlag(SemanticsFlag.isExpanded) ? 'expanded' : 'collapsed',
    if (d.hasFlag(SemanticsFlag.hasSelectedState) &&
        d.hasFlag(SemanticsFlag.isSelected))
      'selected',
    if (!d.hasFlag(SemanticsFlag.isEnabled) &&
        d.hasFlag(SemanticsFlag.hasEnabledState))
      'disabled',
    if (d.hasFlag(SemanticsFlag.isFocusable)) 'focusable',
  ];
  return states.isEmpty ? '' : states.join(', ');
}

String _actions(SemanticsData d) {
  final actions = <String>[
    if (d.hasAction(SemanticsAction.tap)) 'tap',
    if (d.hasAction(SemanticsAction.increase)) 'increase',
    if (d.hasAction(SemanticsAction.decrease)) 'decrease',
    if (d.hasAction(SemanticsAction.dismiss)) 'dismiss',
  ];
  return actions.isEmpty ? '' : actions.join(', ');
}

void _dump(SemanticsNode node, int depth) {
  final d = node.getSemanticsData();
  final label = d.label.replaceAll('\n', ' ').trim();
  final role = _roles(d);
  final states = _states(d);
  final actions = _actions(d);

  // Nodes with nothing to say are structural; skip them so the shape of the
  // announcement is readable.
  if (label.isNotEmpty || role.isNotEmpty || d.hint.isNotEmpty) {
    final bits = <String>[
      if (role.isNotEmpty) '**$role**',
      if (label.isNotEmpty) '"$label"' else '_(no name)_',
      if (d.hint.isNotEmpty) 'hint: "${d.hint}"',
      if (d.value.isNotEmpty) 'value: "${d.value}"',
      if (states.isNotEmpty) '[$states]',
      if (actions.isNotEmpty) '{$actions}',
    ];
    _out.writeln('${'  ' * depth}- ${bits.join(' ')}');
  }
  node.visitChildren((c) {
    _dump(c, depth + 1);
    return true;
  });
}

Future<void> _preview(
  WidgetTester tester,
  String name,
  Widget child, {
  String? note,
}) async {
  final handle = tester.ensureSemantics();
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: const [ItLocalizations.delegate],
    home: Scaffold(body: Center(child: SizedBox(width: 700, child: child))),
  ));
  await tester.pumpAndSettle();

  _out.writeln('\n### $name\n');
  if (note != null) _out.writeln('> $note\n');

  _out.writeln('**Tree order** — roughly what a swipe-through reads out:\n');
  _dump(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!, 0);

  // Tab order is what a keyboard user gets, and it is computed separately from
  // the tree — the two disagreeing is a real §2.4.3 defect, and one of the
  // things a reviewer should be looking for.
  final stops = <String>[];
  for (var i = 0; i < 8; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final node =
        tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
    String? focusedLabel;
    void findFocused(SemanticsNode n) {
      final d = n.getSemanticsData();
      if (d.hasFlag(SemanticsFlag.isFocused) && focusedLabel == null) {
        focusedLabel = d.label.trim().isEmpty ? '(no name)' : d.label.trim();
      }
      n.visitChildren((c) {
        findFocused(c);
        return true;
      });
    }

    findFocused(node);
    if (focusedLabel == null) break;
    if (stops.isNotEmpty && stops.first == focusedLabel) break; // wrapped
    stops.add(focusedLabel!);
  }
  if (stops.isNotEmpty) {
    _out.writeln('\n**Tab order:** ${stops.map((s) => '`$s`').join(' → ')}');
  }
  handle.dispose();
}

void main() {
  tearDownAll(() {
    const header = '''
# What the components announce

Generated by `tool/a11y/preview/announcement_preview_test.dart` — do not edit.

    flutter test tool/a11y/preview

This is the raw material for **Phase 6**, the real-assistive-technology pass
that automation cannot close. The contracts in `test/a11y/` prove that a role
and a state are *exposed*; nothing in this repository can prove the resulting
announcement is intelligible, correctly ordered, or not maddening to hear.

Read this beside a real screen reader and look for:

- **Names that say nothing.** "button", "immagine", a bare number.
- **Names said twice.** A wrapper naming itself and its child both announcing.
- **Order that contradicts the layout.** Tree order and Tab order are computed
  separately here, so a disagreement between the two lines below is a §2.4.3
  finding before a screen reader is even involved.
- **State that never changes.** `[collapsed]` on something already open.
- **Verbosity.** Technically complete and exhausting to listen to is a defect;
  it is the one this file is least able to show you and a person is best at.

Where this file and a screen reader disagree, the screen reader is right.
''';
    File('doc/at-announcements.md').writeAsStringSync('$header$_out');
  });

  testWidgets(
      'button',
      (t) => _preview(t, 'ItButton',
          ItButton(onPressed: () {}, child: const Text('Invia la domanda'))));

  testWidgets(
      'disabled button',
      (t) => _preview(
            t,
            'ItButton (disabled)',
            const ItButton(onPressed: null, child: Text('Invia la domanda')),
            note:
                'A disabled control should be *reported* as disabled, not merely '
                'skipped — a user who cannot find it cannot know why.',
          ));

  testWidgets(
      'checkbox',
      (t) => _preview(
            t,
            'ItCheckbox',
            ItCheckbox(
                value: false,
                label: 'Accetto le condizioni',
                onChanged: (_) {}),
          ));

  testWidgets(
      'indeterminate checkbox',
      (t) => _preview(
            t,
            'ItCheckbox (indeterminate)',
            ItCheckbox(
              value: false,
              indeterminate: true,
              label: 'Seleziona tutto',
              onChanged: (_) {},
            ),
            note: 'The mixed state of a "select all". Listen for whether it is '
                'announced at all, and whether "mixed" is intelligible in Italian.',
          ));

  testWidgets(
      'invalid input',
      (t) => _preview(
            t,
            'ItInput (invalid)',
            const ItInput(
              label: 'Codice fiscale',
              errorText: 'Il codice fiscale non è valido',
              validationState: ItValidationState.danger,
            ),
            note:
                'Two things must reach the user: that the field is in error, and '
                'what is wrong with it. Check the error text is not announced only '
                'on focus, and not duplicated.',
          ));

  testWidgets(
      'select',
      (t) => _preview(
            t,
            'ItSelect',
            ItSelect<String>(
              label: 'Regione',
              items: const [
                ItSelectItem(value: 'lazio', label: 'Lazio'),
                ItSelectItem(value: 'lombardia', label: 'Lombardia'),
              ],
              onChanged: (_) {},
            ),
          ));

  testWidgets(
      'tabs',
      (t) => _preview(
            t,
            'ItTabBar',
            const ItTabBar(tabs: [
              ItTabItem(label: 'Anagrafica'),
              ItTabItem(label: 'Documenti'),
            ]),
            note:
                'Listen for position — "2 di 2" or equivalent. Without it a user '
                'cannot tell how much is there.',
          ));

  testWidgets(
      'accordion',
      (t) => _preview(
            t,
            'ItAccordion',
            const ItAccordion(items: [
              ItAccordionItem(
                  title: 'Come presentare domanda', body: Text('Testo')),
            ]),
          ));

  testWidgets(
      'card',
      (t) => _preview(
            t,
            'ItCard (tappable)',
            ItCard(
              title: 'Bando per le scuole',
              subtitle: 'Contributi 2026',
              date: '22 aprile 2026',
              body: const Text('Descrizione del bando.'),
              onTap: () {},
            ),
            note:
                'Deliberately ONE control with one long name. Judge whether the '
                'joined name is bearable to hear, or whether it should be shorter.',
          ));

  testWidgets(
      'alert',
      (t) => _preview(
            t,
            'ItAlert (dismissible)',
            ItAlert(
              variant: ItAlertVariant.danger,
              dismissible: true,
              onDismissed: () {},
              body: const Text('Domanda non inviata.'),
            ),
            note:
                'The variant is carried by colour and an icon. Check that being '
                'an ERROR rather than a notice survives into speech (§1.4.1).',
          ));

  testWidgets(
      'notification badge',
      (t) => _preview(
            t,
            'ItNotificationBadge',
            const ItNotificationBadge(
              count: 3,
              child: Icon(BootstrapItaliaIcons.it_mail),
            ),
            note:
                'The badge and the thing it sits on are separate nodes. Listen to '
                'whether they read as one idea or two unrelated ones.',
          ));

  testWidgets(
      'breadcrumb',
      (t) => _preview(
            t,
            'ItBreadcrumb',
            const ItBreadcrumb(items: [
              ItBreadcrumbItem(label: 'Home'),
              ItBreadcrumbItem(label: 'Servizi'),
              ItBreadcrumbItem(label: 'Anagrafe'),
            ]),
            note: 'Separators must not be announced. Check the current page is '
                'distinguishable from the links.',
          ));

  testWidgets(
      'spinner',
      (t) => _preview(
            t,
            'ItSpinner',
            const ItSpinner(animating: false),
            note: 'A loading state that is only painted is invisible to AT.',
          ));
}
