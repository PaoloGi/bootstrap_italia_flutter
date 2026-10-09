// ignore_for_file: deprecated_member_use
//
// `SemanticsData.hasFlag` is deprecated in favour of `flagsCollection`, but that
// replacement is not a like-for-like rename: it models state as tristate enums
// (`isChecked` is a `CheckedState`, `isEnabled`/`isToggled`/`isExpanded` are
// `Tristate`) rather than the has-X-state / is-X flag pairs asserted here.
// Mechanically rewriting these ~105 assertions would change what each one
// actually checks, with nothing to verify the translation — and these are the
// contracts that catch accessibility regressions, so a silent weakening is the
// worst possible outcome. Migrate deliberately, one criterion at a time.
// Semantic contracts for assistive technology.
//
// This complements the axe-core audit rather than duplicating it. axe checks the
// Flutter Web DOM against generic ARIA rules, which means it accepts anything
// that is *valid* — a checkbox exposed as a plain button with an accessible name
// passes axe cleanly while being wrong for a screen-reader user, who is never
// told whether the box is checked. Those defects can only be caught by asserting
// the intended role and state per component, which is what this file does.
//
// Asserting Flutter's own semantics tree (rather than the web DOM) also means
// these contracts hold on Android and iOS, where there is no DOM at all.
//
// WCAG 2.2 AA criteria exercised here:
//   1.3.1 Info and Relationships  — role and state are programmatically exposed
//   4.1.2 Name, Role, Value       — every control has all three
//   2.4.6 Headings and Labels     — controls are labelled
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_flutter/src/a11y/it_focus_ring.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        home: Scaffold(body: Center(child: child)),
      ),
    );

/// Finds the first semantics node satisfying [test], or null.
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

/// Every semantics node satisfying [test], in tree order.
///
/// Nodes merged into a parent are skipped: they exist in Flutter's internal
/// tree but are never handed to the platform, so asserting on them would be
/// asserting on something no assistive technology can observe.
List<SemanticsNode> _findAll(
  WidgetTester tester,
  bool Function(SemanticsData) test, {
  SemanticsNode? root,
}) {
  final found = <SemanticsNode>[];
  void walk(SemanticsNode node) {
    if (!node.isMergedIntoParent && test(node.getSemanticsData())) {
      found.add(node);
    }
    node.visitChildren((child) {
      walk(child);
      return true;
    });
  }

  walk(root ?? tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

/// The subtree rooted at the first node flagged [SemanticsFlag.namesRoute].
SemanticsNode? _dialogNode(WidgetTester tester) => _find(
      tester,
      (d) =>
          d.hasFlag(SemanticsFlag.namesRoute) &&
          d.hasFlag(SemanticsFlag.scopesRoute),
    );

/// Measures the region that actually accepts pointer events for [target],
/// by binary-searching outwards from its centre until the hit test stops
/// reaching it.
///
/// This is the only honest way to check WCAG 2.5.8 Target Size: the *painted*
/// size of a control says nothing about how big its tap target is, and the two
/// deliberately differ wherever CSS uses padding plus a negative margin.
Size _hitTargetSize(WidgetTester tester, Finder target) {
  final renderObject = tester.renderObject(target);
  final centre = tester.getCenter(target);

  bool hits(Offset point) => tester
      .hitTestOnBinding(point)
      .path
      .any((entry) => identical(entry.target, renderObject));

  double reach(Offset direction) {
    if (!hits(centre)) return 0;
    var lo = 0.0;
    var hi = 200.0;
    for (var i = 0; i < 24; i++) {
      final mid = (lo + hi) / 2;
      if (hits(centre + direction * mid)) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  return Size(
    reach(const Offset(-1, 0)) + reach(const Offset(1, 0)),
    reach(const Offset(0, -1)) + reach(const Offset(0, 1)),
  );
}

/// WCAG 2.5.8 Target Size (Minimum), AA: 24x24 CSS pixels.
const double _kMinTargetSize = 24;

/// Records the announcements the framework pushes to the platform.
///
/// WCAG 4.1.3 Status Messages cannot be verified from the semantics tree
/// alone: a `liveRegion` flag on a node that was born with its text already in
/// place is frequently never spoken. Capturing the accessibility channel is how
/// we prove something is actually announced.
List<String> _captureAnnouncements(WidgetTester tester) {
  final announcements = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (message) async {
      if (message is Map && message['type'] == 'announce') {
        final data = message['data'];
        if (data is Map && data['message'] is String) {
          announcements.add(data['message'] as String);
        }
      }
      return null;
    },
  );
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility, null));
  return announcements;
}

void _useKeyboardNavigation() {
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
}

bool _isAncestor(Element ancestor, Element descendant) {
  var found = false;
  descendant.visitAncestorElements((e) {
    if (e == ancestor) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

/// A tab must be ONE node, not a named tab wrapping an unnamed button.
void _tabHasNoNestedControl() {
  testWidgets('§4.1.2 a tab contains no second, unnamed control',
      (tester) async {
    // Found by running the package in a real browser: axe reported
    // `nested-interactive` and `aria-command-name` against `role="tab"` on the
    // Flutter Web build. The cause was ItActivatable publishing its own
    // focusable, tappable node inside the tab's Semantics, which already
    // carries the role, the name, the selected state and the tap action — so
    // AT met an unnamed button inside every tab.
    //
    // No widget test saw it because every assertion was about the tab node's
    // own properties, which were correct. The defect was the node BELOW it.
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        home: Scaffold(
          body: ItTabBar(
            selectedIndex: 0,
            onChanged: (_) {},
            tabs: const [
              ItTabItem(label: 'Prima'),
              ItTabItem(label: 'Seconda'),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final offenders = <String>[];
    void walk(SemanticsNode n, {bool insideTab = false}) {
      final data = n.getSemanticsData();
      final interactive = data.hasAction(SemanticsAction.tap) ||
          n.hasFlag(SemanticsFlag.isFocusable);
      if (insideTab && interactive) {
        offenders.add('role=${n.role} label="${n.label}"');
      }
      n.visitChildren((c) {
        walk(c, insideTab: insideTab || n.role == SemanticsRole.tab);
        return true;
      });
    }

    walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
    expect(offenders, isEmpty,
        reason: 'a tab must be a single node — an interactive descendant is '
            'an unnamed button to a screen reader (WCAG 4.1.2) and axe '
            'reports it as nested-interactive');
    handle.dispose();
  });
}

void main() {
  _tabHasNoNestedControl();
  group('4.1.2 Name, Role, Value', () {
    testWidgets('ItButton exposes the button role, a name and enabled state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItButton(onPressed: () {}, child: const Text('Conferma')),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isButton));
      expect(node, isNotNull, reason: 'no node exposes isButton');

      final data = node!.getSemanticsData();
      expect(data.label, 'Conferma', reason: 'button must expose its name');
      expect(data.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(data.hasFlag(SemanticsFlag.isEnabled), isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('a disabled ItButton reports itself disabled, not just inert',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItButton(
            disabled: true, onPressed: null, child: Text('Conferma')),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isButton));
      expect(node, isNotNull);
      final data = node!.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.hasEnabledState), isTrue,
          reason: 'AT must be able to tell this control CAN be enabled');
      expect(data.hasFlag(SemanticsFlag.isEnabled), isFalse);
      handle.dispose();
    });

    testWidgets('ItCheckbox exposes checked state, not just a tappable label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItCheckbox(label: 'Accetto', value: false, onChanged: (_) {}),
      ));

      final node =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.hasCheckedState));
      expect(node, isNotNull,
          reason: 'checkbox must expose hasCheckedState; a plain button with a '
              'label passes axe but never tells the user whether it is checked');

      final data = node!.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isChecked), isFalse);
      expect(data.label, contains('Accetto'));
      handle.dispose();
    });

    testWidgets('ItCheckbox reflects the checked state when true',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItCheckbox(label: 'Accetto', value: true, onChanged: (_) {}),
      ));

      final node =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.hasCheckedState));
      expect(node, isNotNull);
      expect(node!.getSemanticsData().hasFlag(SemanticsFlag.isChecked), isTrue);
      handle.dispose();
    });

    // The indeterminate box is the one state a screen reader cannot infer from
    // anything else on screen. Flutter has a distinct flag for it, and Android
    // renders it as a third state; iOS does NOT — see the iOS section of
    // doc/accessibility-audit.md, where this same control reports AXValue 0,
    // indistinguishable from unchecked. That is an engine limitation rather
    // than a defect here, and this test is what makes the distinction provable:
    // if the Dart contract ever silently degrades to `checked: false`, the iOS
    // observation stops being a platform note and becomes our bug.
    testWidgets('ItCheckbox exposes the mixed state as mixed, not unchecked',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItCheckbox(
          label: 'Tutti',
          value: false,
          indeterminate: true,
          onChanged: (_) {},
        ),
      ));

      final node =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.isCheckStateMixed));
      expect(node, isNotNull,
          reason: 'an indeterminate checkbox must set isCheckStateMixed; '
              'reporting it as merely unchecked tells the user the opposite '
              'of the truth about the group beneath it');

      final data = node!.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isChecked), isFalse,
          reason: 'mixed and checked are mutually exclusive');
      handle.dispose();
    });

    testWidgets('ItToggle exposes toggled state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItToggle(label: 'Notifiche', value: true, onChanged: (_) {}),
      ));

      final node = _find(
        tester,
        (d) =>
            d.hasFlag(SemanticsFlag.hasToggledState) ||
            d.hasFlag(SemanticsFlag.hasCheckedState),
      );
      expect(node, isNotNull,
          reason: 'a switch must expose toggled/checked state to AT');
      final data = node!.getSemanticsData();
      expect(
        data.hasFlag(SemanticsFlag.isToggled) ||
            data.hasFlag(SemanticsFlag.isChecked),
        isTrue,
      );
      handle.dispose();
    });

    testWidgets('ItRadio exposes the in-mutually-exclusive-group role',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItRadio<int>(value: 1, groupValue: 1, label: 'Uno', onChanged: (_) {}),
      ));

      final node = _find(
        tester,
        (d) => d.hasFlag(SemanticsFlag.isInMutuallyExclusiveGroup),
      );
      expect(node, isNotNull,
          reason: 'radios must be announced as part of a group, otherwise AT '
              'cannot convey "1 of 3"');
      handle.dispose();
    });

    // §4.1.2 on Apple platforms. `checked` does not reach VoiceOver at all for a
    // radio: the iOS embedder routes a mutually-exclusive node away from the
    // `UISwitch`-backed object and then returns nil for its value outright
    // ("iOS does not announce values of native radio buttons"). The chosen
    // option rides on `UIAccessibilityTraitSelected`, which only `selected:`
    // sets — so on a simulator the tree looked complete while conveying nothing
    // about which option was on. See the iOS section of
    // doc/accessibility-audit.md.
    //
    // These two tests pin the platform split. Android must NOT get the flag:
    // its bridge maps it to `setSelected` and fires a `TYPE_VIEW_SELECTED`
    // announcement on top of the checked state it already carries.
    group('ItRadio selection across platforms', () {
      testWidgets('iOS marks the chosen option selected', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(
          ItRadio<int>(
              value: 1, groupValue: 1, label: 'Uno', onChanged: (_) {}),
        ));

        final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isSelected));
        expect(node, isNotNull,
            reason: 'without isSelected nothing distinguishes the chosen radio '
                'on iOS — checked reaches nothing there');
        expect(node!.getSemanticsData().label, contains('Uno'));
        handle.dispose();
      }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

      testWidgets('iOS says so on the ones that are not chosen',
          (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(
          ItRadio<int>(
              value: 1, groupValue: 0, label: 'Due', onChanged: (_) {}),
        ));

        final node = _find(
          tester,
          (d) => d.hasFlag(SemanticsFlag.isInMutuallyExclusiveGroup),
        );
        expect(node!.getSemanticsData().hint, contains('Non selezionato'),
            reason: 'the trait marks only the chosen option, so an unselected '
                'radio is announced exactly as one whose state is missing');
        expect(
            node.getSemanticsData().hasFlag(SemanticsFlag.isSelected), isFalse);
        handle.dispose();
      }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

      testWidgets('Android is left alone — it already carries checked',
          (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(
          ItRadio<int>(
              value: 1, groupValue: 1, label: 'Uno', onChanged: (_) {}),
        ));

        final node = _find(
          tester,
          (d) => d.hasFlag(SemanticsFlag.isInMutuallyExclusiveGroup),
        );
        final data = node!.getSemanticsData();
        expect(data.hasFlag(SemanticsFlag.isChecked), isTrue);
        expect(data.hasFlag(SemanticsFlag.isSelected), isFalse,
            reason: 'Android maps isSelected to setSelected AND fires '
                'TYPE_VIEW_SELECTED, so adding it here states the checked '
                'state a second time');
        expect(data.hint, isNot(contains('Non selezionato')));
        handle.dispose();
      }, variant: TargetPlatformVariant.only(TargetPlatform.android));

      testWidgets('the unselected hint does not swallow a validation message',
          (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(
          ItRadio<int>(
            value: 1,
            groupValue: 0,
            label: 'Due',
            errorText: 'Selezione obbligatoria',
            onChanged: (_) {},
          ),
        ));

        final node = _find(
          tester,
          (d) => d.hasFlag(SemanticsFlag.isInMutuallyExclusiveGroup),
        );
        final hint = node!.getSemanticsData().hint;
        expect(hint, contains('Non selezionato'));
        expect(hint, contains('Selezione obbligatoria'),
            reason: 'both can be true at once and neither may replace the '
                'other');
        handle.dispose();
      }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
    });

    testWidgets('ItInput exposes the text-field role and its label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
            width: 320,
            child: ItInput(groupMargin: false, label: 'Codice fiscale')),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isTextField));
      expect(node, isNotNull, reason: 'no node exposes isTextField');
      expect(
        node!.getSemanticsData().label,
        contains('Codice fiscale'),
        reason:
            'the visible label must be programmatically associated with the '
            'field (WCAG 1.3.1 / 3.3.2); axe reported this as a critical '
            '"Form elements must have labels" violation on the web build',
      );
      handle.dispose();
    });

    testWidgets('ItSelect exposes a combobox with its label, value and state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItSelect<String>(
            groupMargin: false,
            label: 'Provincia',
            value: 'RM',
            items: const [
              ItSelectItem(value: 'RM', label: 'Roma'),
              ItSelectItem(value: 'MI', label: 'Milano'),
            ],
            onChanged: (_) {},
          ),
        ),
      ));

      // `SemanticsRole.comboBox` is in the enum but Flutter 3.44 asserts
      // "Missing checks for role SemanticsRole.comboBox" the moment it is
      // used, so the closed control is exposed the way Flutter's own dropdowns
      // are: a button that carries a value and an expanded state.
      final node =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.hasExpandedState));
      expect(node, isNotNull,
          reason: 'a hand-painted select must still say it opens a list; '
              'without an expanded state AT cannot tell it does anything');

      final data = node!.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(data.label, contains('Provincia'),
          reason: 'the floating label is painted as a sibling Text, so it must '
              'be re-attached to the control (WCAG 1.3.1)');
      expect(data.value, 'Roma',
          reason: 'the current choice is the control\'s value (WCAG 4.1.2)');
      expect(data.hasFlag(SemanticsFlag.hasExpandedState), isTrue);
      expect(data.hasFlag(SemanticsFlag.isExpanded), isFalse);
      expect(data.hasFlag(SemanticsFlag.isEnabled), isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('ItMultiSelect reads back every choice and marks its rows',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItMultiSelect<String>(
            groupMargin: false,
            label: 'Province',
            values: const {'RM', 'MI'},
            items: const [
              ItSelectItem(value: 'RM', label: 'Roma'),
              ItSelectItem(value: 'MI', label: 'Milano'),
              ItSelectItem(value: 'NA', label: 'Napoli'),
            ],
            onChanged: (_) {},
          ),
        ),
      ));

      final closed =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.hasExpandedState))!;
      final data = closed.getSemanticsData();
      expect(data.label, contains('Province'));
      expect(data.value, contains('Roma'));
      expect(data.value, contains('Milano'),
          reason: 'a multi-select that reads back only one of two choices '
              'leaves a screen-reader user unable to tell what is selected '
              '(WCAG 4.1.2)');
      expect(data.hasFlag(SemanticsFlag.isEnabled), isTrue);

      // Open it: each row says whether it is one of the choices. `selected`,
      // not `checked` — these are options in a list, which is `aria-selected`
      // in the markup, and the rows are not checkboxes.
      await tester.tap(find.byType(ItMultiSelect<String>));
      await tester.pumpAndSettle();

      final roma = _find(tester, (d) => d.label.contains('Roma'));
      final napoli = _find(tester, (d) => d.label.contains('Napoli'));
      expect(roma, isNotNull);
      expect(roma!.getSemanticsData().hasFlag(SemanticsFlag.isSelected), isTrue,
          reason: 'a chosen row that does not say so leaves the list readable '
              'only by colour (WCAG 1.4.1, 4.1.2)');
      expect(napoli, isNotNull);
      expect(napoli!.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
          isFalse);
      expect(
          roma
              .getSemanticsData()
              .hasFlag(SemanticsFlag.isInMutuallyExclusiveGroup),
          isFalse,
          reason: 'choosing one row does not clear the others here — saying '
              'otherwise would tell AT this behaves like a radio group');
      handle.dispose();
    });

    testWidgets('ItSelect reports the expanded state once the list is open',
        (tester) async {
      final handle = tester.ensureSemantics();
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

      await tester.tap(find.byType(ItSelect<String>));
      await tester.pumpAndSettle();

      final node =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.hasExpandedState));
      expect(node!.getSemanticsData().hasFlag(SemanticsFlag.isExpanded), isTrue,
          reason: 'a screen-reader user must be told the list opened');

      // Each option carries its own selectable state (WCAG 1.3.1).
      final options = _findAll(
        tester,
        (d) => d.hasFlag(SemanticsFlag.hasSelectedState) && d.label == 'Roma',
      );
      expect(options, isNotEmpty,
          reason: 'each option must report whether it is the current choice');
      handle.dispose();
    });

    testWidgets('ItAutocomplete exposes a combobox with its label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItAutocomplete<String>(
            groupMargin: false,
            label: 'Comune di residenza',
            onSearch: (q) async => const ['Roma'],
            displayStringForOption: (s) => s,
          ),
        ),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isTextField));
      expect(node, isNotNull, reason: 'no node exposes isTextField');

      final data = node!.getSemanticsData();
      expect(data.label, contains('Comune di residenza'),
          reason: 'the visible label must name the field (WCAG 1.3.1 / 3.3.2)');
      // `SemanticsRole.comboBox` is unusable on this Flutter version (see the
      // ItSelect contract above), so the expanded state is what tells AT this
      // field is backed by a suggestion list.
      expect(data.hasFlag(SemanticsFlag.hasExpandedState), isTrue,
          reason: 'AT must be able to report whether suggestions are showing');
      handle.dispose();
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // OVERLAYS — modal, dropdown, notification
  //
  // Overlays are where accessibility fails most often, because being correct
  // is about focus and announcement rather than appearance. Nothing in this
  // section can be caught by looking at a screenshot, and most of it cannot be
  // caught by axe either: a dialog with no accessible name, a menu that a
  // keyboard cannot open, or a toast that is never announced are all perfectly
  // valid ARIA.
  // ══════════════════════════════════════════════════════════════════

  group('ItModal', () {
    /// Pumps a page with a button that opens a modal, returning the focus node
    /// of the trigger so tests can assert focus comes back to it.
    Future<FocusNode> pumpModalTrigger(
      WidgetTester tester, {
      String? title = 'Titolo della modale',
      bool dismissible = true,
      List<Widget> actions = const [],
    }) async {
      final triggerFocus = FocusNode(debugLabel: 'trigger');
      addTearDown(triggerFocus.dispose);
      await tester.pumpWidget(_host(
        Builder(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('CONTENUTO DI SFONDO'),
              ElevatedButton(
                focusNode: triggerFocus,
                onPressed: () => ItModal.show(
                  context: context,
                  title: title,
                  dismissible: dismissible,
                  body: const Text('Corpo della modale'),
                  actions: actions,
                ),
                child: const Text('Apri'),
              ),
            ],
          ),
        ),
      ));
      triggerFocus.requestFocus();
      await tester.pump();
      await tester.tap(find.text('Apri'));
      await tester.pumpAndSettle();
      return triggerFocus;
    }

    testWidgets(
        '4.1.2 the dialog exposes the route role AND an accessible name',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpModalTrigger(tester);

      final dialog = _dialogNode(tester);
      expect(
        dialog,
        isNotNull,
        reason: 'the modal must set BOTH scopesRoute (role) and namesRoute. '
            'Setting scopesRoute alone — as it did — announces an unnamed '
            'route: the user is told they entered something, but not what',
      );
      expect(
        dialog!.getSemanticsData().label,
        'Titolo della modale',
        reason: 'the dialog name must be the visible title (4.1.2 / 2.5.3)',
      );
      handle.dispose();
    });

    testWidgets('4.1.2 an untitled dialog still gets a name', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpModalTrigger(tester, title: null);

      final dialog = _dialogNode(tester);
      expect(dialog, isNotNull);
      expect(
        dialog!.getSemanticsData().label,
        isNotEmpty,
        reason: 'a dialog with no title must fall back to the localised '
            '"Dialog" label rather than being announced anonymously',
      );
      handle.dispose();
    });

    testWidgets('1.3.1 the modal title carries the heading role',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpModalTrigger(tester);

      final headers = _findAll(
        tester,
        (d) => d.hasFlag(SemanticsFlag.isHeader),
        root: _dialogNode(tester),
      );
      expect(
        headers.map((n) => n.getSemanticsData().label),
        contains('Titolo della modale'),
        reason: '`.modal-title` is an <h5> upstream; losing the heading role '
            'means the title reads as ordinary text and cannot be reached by '
            "a screen reader's heading navigation",
      );
      handle.dispose();
    });

    testWidgets('2.4.3 / 2.4.11 focus moves INTO the dialog when it opens',
        (tester) async {
      final handle = tester.ensureSemantics();
      final trigger = await pumpModalTrigger(tester);

      expect(
        trigger.hasFocus,
        isFalse,
        reason: 'focus must not stay on the trigger: the barrier now covers '
            'it, so the focused element would be completely obscured (2.4.11)',
      );

      final focused = _findAll(
        tester,
        (d) => d.hasFlag(SemanticsFlag.isFocused),
        root: _dialogNode(tester),
      );
      expect(
        focused,
        isNotEmpty,
        reason: 'a node inside the dialog must hold focus. Flutter\'s '
            'ModalRoute only focuses its own FocusScope, which is not a real '
            'node, so AT is given nothing to land on',
      );
      handle.dispose();
    });

    testWidgets('1.3.1 content behind the modal is hidden from AT',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpModalTrigger(tester);

      // The widget is still mounted — this is specifically about semantics.
      expect(find.text('CONTENUTO DI SFONDO'), findsOneWidget);

      final background = _findAll(
        tester,
        (d) => d.label.contains('CONTENUTO DI SFONDO') || d.label == 'Apri',
      );
      expect(
        background,
        isEmpty,
        reason: 'with the dialog open a screen reader must not be able to '
            'wander out of it into the page behind the barrier',
      );
      handle.dispose();
    });

    testWidgets('2.1.2 Escape dismisses and returns focus to the trigger',
        (tester) async {
      final trigger = await pumpModalTrigger(tester);
      expect(find.text('Titolo della modale'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(
        find.text('Titolo della modale'),
        findsNothing,
        reason: 'trapping focus without an Escape hatch is a keyboard trap',
      );
      expect(
        trigger.hasFocus,
        isTrue,
        reason: 'closing must return focus to the control that opened the '
            'dialog, not drop it at the top of the page (2.4.3)',
      );
    });

    testWidgets('4.1.2 the close button is a named, focusable button',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpModalTrigger(tester);

      final close = _find(
        tester,
        (d) =>
            d.hasFlag(SemanticsFlag.isButton) &&
            d.label == 'Chiudi finestra modale',
      );
      expect(close, isNotNull);

      final data = close!.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(data.hasFlag(SemanticsFlag.isEnabled), isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(
        data.hasFlag(SemanticsFlag.isFocusable),
        isTrue,
        reason: 'the close button was a bare GestureDetector, operable with a '
            'pointer only — a keyboard user could never close the dialog from '
            'its header (2.1.1)',
      );
      handle.dispose();
    });

    testWidgets('2.1.1 the close button can be reached and fired by keyboard',
        (tester) async {
      await pumpModalTrigger(tester);
      expect(find.text('Titolo della modale'), findsOneWidget);

      // The dialog container is skipTraversal, so the first Tab lands on the
      // first real control in the dialog: the close button.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(
        find.text('Titolo della modale'),
        findsNothing,
        reason: 'Tab then Enter must be able to close the dialog',
      );
    });

    testWidgets('2.1.2 a non-dismissible modal still offers a keyboard way out',
        (tester) async {
      // `dismissible: false` removes the close button, the barrier tap AND
      // Escape. That is only conformant while an action can still close the
      // dialog, so the action must be keyboard-reachable and effective.
      var confirmed = false;
      await tester.pumpWidget(_host(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ItModal.show(
              context: context,
              title: 'Scelta obbligatoria',
              dismissible: false,
              body: const Text('Corpo'),
              actions: [
                ItButton(
                  onPressed: () {
                    confirmed = true;
                    Navigator.pop(context);
                  },
                  child: const Text('Conferma'),
                ),
              ],
            ),
            child: const Text('Apri'),
          ),
        ),
      ));
      await tester.tap(find.text('Apri'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(
        find.text('Scelta obbligatoria'),
        findsOneWidget,
        reason: 'Escape is intentionally inert here — this is the '
            '"you must choose" pattern',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
      expect(
        find.text('Scelta obbligatoria'),
        findsNothing,
        reason: 'the action is the keyboard exit; without one the dialog would '
            'be an inescapable focus trap',
      );
    });

    testWidgets('2.1.2 an actionless non-dismissible modal is rejected',
        (tester) async {
      await tester.pumpWidget(_host(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ItModal.show(
              context: context,
              title: 'Trappola',
              dismissible: false,
              body: const Text('Corpo'),
            ),
            child: const Text('Apri'),
          ),
        ),
      ));

      await tester.tap(find.text('Apri'));
      await tester.pump();

      expect(
        tester.takeException(),
        isAssertionError,
        reason: 'no close button, no barrier dismiss, no Escape and no action '
            'is an inescapable keyboard trap (2.1.2). It must fail loudly at '
            'development time rather than ship silently',
      );
    });

    testWidgets('2.5.8 the close button target is at least 24x24',
        (tester) async {
      await pumpModalTrigger(tester);

      final close = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Chiudi finestra modale',
      );
      final gesture = find.descendant(
        of: close,
        matching: find.byType(GestureDetector),
      );

      expect(
        tester.getSize(close),
        const Size(16, 16),
        reason: 'the painted glyph must stay 16x16 — `.btn-close` is 1em and '
            'growing it would break visual parity',
      );

      final target = _hitTargetSize(tester, gesture);
      expect(
        target.width,
        greaterThanOrEqualTo(_kMinTargetSize),
        reason: 'WCAG 2.5.8 requires a 24x24 target. Upstream gets there with '
            '`.modal-header .btn-close { padding: 12px; margin: -12px }` — a '
            '16x16 glyph in a 40x40 clickable box. The Flutter port painted '
            'the glyph but dropped the padding, leaving a 16x16 target. '
            'Measured: $target',
      );
      expect(
        target.height,
        greaterThanOrEqualTo(_kMinTargetSize),
        reason: 'measured: $target',
      );
    });
  });

  group('ItDropdown', () {
    Future<void> pumpDropdown(
      WidgetTester tester, {
      List<ItDropdownEntry> items = const [
        ItDropdownItem(label: 'Azione 1'),
        ItDropdownItem(label: 'Azione 2'),
        ItDropdownItem(label: 'Azione 3'),
      ],
    }) async {
      await tester.pumpWidget(_host(
        ItDropdown(trigger: const Text('Azioni'), items: items),
      ));
    }

    /// The dropdown's internal trigger focus node.
    FocusNode triggerNode(WidgetTester tester) => tester
        .widgetList<Focus>(
          find.descendant(
            of: find.byType(ItDropdown),
            matching: find.byType(Focus),
          ),
        )
        .map((f) => f.focusNode)
        .whereType<FocusNode>()
        .firstWhere((n) => n.debugLabel == 'ItDropdown trigger');

    testWidgets('4.1.2 the trigger publishes its expanded/collapsed state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDropdown(tester);

      SemanticsData trigger() => _find(
            tester,
            (d) => d.hasFlag(SemanticsFlag.hasExpandedState),
          )!
              .getSemanticsData();

      expect(
        _find(tester, (d) => d.hasFlag(SemanticsFlag.hasExpandedState)),
        isNotNull,
        reason: 'a disclosure control must expose expanded state; without it '
            'the menu silently appears and disappears for a screen reader',
      );
      expect(trigger().hasFlag(SemanticsFlag.isExpanded), isFalse);
      expect(trigger().hasFlag(SemanticsFlag.isButton), isTrue);

      await tester.tap(find.text('Azioni'));
      await tester.pumpAndSettle();
      expect(trigger().hasFlag(SemanticsFlag.isExpanded), isTrue);
      handle.dispose();
    });

    testWidgets('2.1.1 Enter opens the menu', (tester) async {
      await pumpDropdown(tester);
      triggerNode(tester).requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(
        find.text('Azione 1'),
        findsOneWidget,
        reason: 'the trigger was a bare GestureDetector — not focusable, not '
            'keyboard operable (2.1.1)',
      );
    });

    testWidgets('2.1.1 Space opens the menu', (tester) async {
      await pumpDropdown(tester);
      triggerNode(tester).requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(find.text('Azione 1'), findsOneWidget);
    });

    testWidgets('2.1.1 Down opens the menu', (tester) async {
      await pumpDropdown(tester);
      triggerNode(tester).requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('Azione 1'), findsOneWidget);
    });

    testWidgets('2.1.1 Up/Down move focus between menu items', (tester) async {
      await pumpDropdown(tester);
      triggerNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      final nodes = tester
          .widgetList<Focus>(find.byType(Focus))
          .map((f) => f.focusNode)
          .whereType<FocusNode>()
          .where((n) => n.debugLabel?.startsWith('ItDropdownItem') ?? false)
          .toList();
      expect(nodes, hasLength(3));

      expect(nodes[0].hasFocus, isTrue,
          reason: 'opening with the keyboard must step into the first entry');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(nodes[1].hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(nodes[2].hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(nodes[1].hasFocus, isTrue);
    });

    testWidgets(
        '2.1.2 Escape closes the menu and restores focus to the trigger',
        (tester) async {
      await pumpDropdown(tester);
      final trigger = triggerNode(tester);
      trigger.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('Azione 1'), findsOneWidget);
      expect(trigger.hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Azione 1'), findsNothing);
      expect(
        trigger.hasFocus,
        isTrue,
        reason: 'Escape must hand focus back to the trigger, otherwise it is '
            'left on a node that has just been removed from the tree (2.4.3)',
      );
    });

    testWidgets('2.1.1 Tab closes the menu', (tester) async {
      await pumpDropdown(tester);
      triggerNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('Azione 1'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        find.text('Azione 1'),
        findsNothing,
        reason: 'tabbing out must not leave an orphaned menu on screen',
      );
    });

    testWidgets('4.1.2 menu items expose the button role', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItDropdownMenu(
          width: 300,
          items: [ItDropdownItem(label: 'Azione 1')],
        ),
      ));

      final item = _find(tester, (d) => d.label == 'Azione 1');
      expect(item, isNotNull);
      expect(
        item!.getSemanticsData().hasFlag(SemanticsFlag.isButton),
        isTrue,
        reason: 'InkWell alone exposes only isFocusable plus a tap action, so '
            'AT announced a bare string with no role at all',
      );
      handle.dispose();
    });

    testWidgets('4.1.2 a disabled item is announced as disabled, not inert',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItDropdownMenu(
          width: 300,
          items: [
            ItDropdownItem(label: 'Attiva'),
            ItDropdownItem(label: 'Disattivata', disabled: true),
          ],
        ),
      ));

      final item = _find(tester, (d) => d.label == 'Disattivata');
      expect(
        item,
        isNotNull,
        reason: 'a disabled entry dropped its onTap and vanished from the '
            'semantics tree entirely — visible on screen, invisible to AT',
      );

      final data = item!.getSemanticsData();
      expect(
        data.hasFlag(SemanticsFlag.hasEnabledState),
        isTrue,
        reason: 'AT must be able to say this control CAN be enabled',
      );
      expect(data.hasFlag(SemanticsFlag.isEnabled), isFalse);
      expect(
        data.hasAction(SemanticsAction.tap),
        isFalse,
        reason: 'announced as disabled, and genuinely not activatable',
      );
      expect(
        data.hasFlag(SemanticsFlag.isFocusable),
        isTrue,
        reason: 'per the WAI-ARIA menu pattern disabled entries stay in the '
            'focus ring, otherwise the user never hears they exist',
      );
      handle.dispose();
    });

    testWidgets('4.1.2 the active item exposes selected state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItDropdownMenu(
          width: 300,
          items: [
            ItDropdownItem(label: 'Corrente', active: true),
            ItDropdownItem(label: 'Altra'),
          ],
        ),
      ));

      final active = _find(tester, (d) => d.label == 'Corrente')!;
      expect(
        active.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
        isTrue,
        reason: 'the active entry is distinguished only by colour otherwise, '
            'which fails 1.4.1 Use of Colour as well as 4.1.2',
      );

      final other = _find(tester, (d) => d.label == 'Altra')!;
      expect(
        other.getSemanticsData().hasFlag(SemanticsFlag.hasSelectedState),
        isFalse,
        reason: 'only the active entry should claim selected state; marking '
            'every row makes AT read "not selected" over and over',
      );
      handle.dispose();
    });

    testWidgets('1.3.1 a section header carries the heading role',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItDropdownMenu(
          width: 300,
          items: [
            ItDropdownHeader(label: 'Sezione'),
            ItDropdownItem(label: 'Azione 1'),
          ],
        ),
      ));

      final header = _find(tester, (d) => d.label == 'Sezione');
      expect(header, isNotNull);
      expect(
        header!.getSemanticsData().hasFlag(SemanticsFlag.isHeader),
        isTrue,
        reason: '`h3.header` upstream — the grouping must reach AT, not just '
            'the visual weight',
      );
      handle.dispose();
    });
  });

  group('ItNotification', () {
    testWidgets('4.1.3 the notification is a live region, not a button',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItNotification(title: 'Titolo', body: 'Messaggio'),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      final live = _find(
        tester,
        (d) => d.hasFlag(SemanticsFlag.isLiveRegion),
      );
      expect(live, isNotNull);

      final data = live!.getSemanticsData();
      expect(
        data.hasFlag(SemanticsFlag.isButton),
        isFalse,
        reason: 'the live region used the default container:false, so its '
            'annotation coalesced with the close button and every Text below '
            'it: the whole card collapsed into ONE node exposed as a button '
            'named "Titolo Messaggio Chiudi notifica"',
      );
      expect(data.label, contains('Titolo'));
      expect(data.label, contains('Messaggio'));
      handle.dispose();
    });

    testWidgets('4.1.3 the notification is actually announced', (tester) async {
      final handle = tester.ensureSemantics();
      final announcements = _captureAnnouncements(tester);

      await tester.pumpWidget(_host(
        const ItNotification(title: 'Titolo', body: 'Messaggio'),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        announcements,
        isNotEmpty,
        reason: 'a liveRegion flag on a node that is born with its text '
            'already in place is routinely never spoken — an explicit '
            'announcement is what makes 4.1.3 hold in practice',
      );
      expect(announcements.single, contains('Titolo'));
      expect(announcements.single, contains('Messaggio'));
      handle.dispose();
    });

    testWidgets('4.1.3 announcing does not steal focus', (tester) async {
      final elsewhere = FocusNode(debugLabel: 'elsewhere');
      addTearDown(elsewhere.dispose);

      await tester.pumpWidget(_host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              focusNode: elsewhere,
              onPressed: () {},
              child: const Text('Altrove'),
            ),
            const ItNotification(title: 'Titolo', body: 'Messaggio'),
          ],
        ),
      ));
      elsewhere.requestFocus();
      await tester.pumpAndSettle();

      expect(
        elsewhere.hasFocus,
        isTrue,
        reason: 'a status message must be announced without moving focus',
      );
    });

    testWidgets('4.1.2 the close button is a named, focusable button',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItNotification(title: 'Titolo', body: 'Messaggio'),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      final close = _find(
        tester,
        (d) =>
            d.hasFlag(SemanticsFlag.isButton) && d.label == 'Chiudi notifica',
      );
      expect(close, isNotNull);

      final data = close!.getSemanticsData();
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(
        data.hasFlag(SemanticsFlag.isFocusable),
        isTrue,
        reason: 'a GestureDetector cannot be reached with the keyboard, so a '
            'persistent notification could only be dismissed with a pointer '
            '(2.1.1)',
      );
      handle.dispose();
    });

    testWidgets('2.1.1 the close button can be fired by keyboard',
        (tester) async {
      var dismissed = false;
      await tester.pumpWidget(_host(
        ItNotification(
          title: 'Titolo',
          body: 'Messaggio',
          onDismissed: () => dismissed = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('2.5.8 the close button target is at least 24x24',
        (tester) async {
      await tester.pumpWidget(_host(
        const ItNotification(title: 'Titolo', body: 'Messaggio'),
      ));
      await tester.pumpAndSettle();

      final close = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Chiudi notifica',
      );
      final gesture = find.descendant(
        of: close,
        matching: find.byType(GestureDetector),
      );

      final target = _hitTargetSize(tester, gesture);
      expect(target.width, greaterThanOrEqualTo(_kMinTargetSize),
          reason: '`.notification-close` is 32x32 upstream. Measured: $target');
      expect(target.height, greaterThanOrEqualTo(_kMinTargetSize),
          reason: 'measured: $target');
    });

    testWidgets('2.2.1 auto-dismiss does not run under assistive technology',
        (tester) async {
      var dismissed = false;
      await tester.pumpWidget(_host(
        MediaQuery(
          // The platform reports a screen reader is driving the UI.
          data: const MediaQueryData(accessibleNavigation: true),
          child: ItNotification(
            title: 'Titolo',
            body: 'Messaggio',
            duration: const Duration(seconds: 2),
            onDismissed: () => dismissed = true,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(
        dismissed,
        isFalse,
        reason: 'WCAG 2.2.1 Timing Adjustable: a screen-reader user may still '
            'be working through the announcement when the timer would fire',
      );
    });

    testWidgets('2.2.1 focus pauses the auto-dismiss countdown',
        (tester) async {
      var dismissed = false;
      await tester.pumpWidget(_host(
        ItNotification(
          title: 'Titolo',
          body: 'Messaggio',
          duration: const Duration(seconds: 2),
          onDismissed: () => dismissed = true,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      // Move focus onto the close button; the countdown must stop.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(
        dismissed,
        isFalse,
        reason: 'a notification must not disappear out from under a keyboard '
            'user who has just focused it (2.2.1)',
      );
    });

    testWidgets('2.2.1 a notification with no duration never self-dismisses',
        (tester) async {
      var dismissed = false;
      await tester.pumpWidget(_host(
        ItNotification(
          title: 'Titolo',
          body: 'Messaggio',
          onDismissed: () => dismissed = true,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(minutes: 1));
      await tester.pumpAndSettle();

      expect(dismissed, isFalse,
          reason: 'duration: null is the unconditionally 2.2.1-safe setting');
    });
  });

  // ══ NAVIGATION group ═════════════════════════════════════════════
  //
  // Navigation is where screen-reader users orient themselves, so this group
  // carries most of WCAG's structural criteria. Every control below was a bare
  // GestureDetector before this pass: visible, tappable, and invisible to both
  // the focus system and assistive technology.

  /// Tabs focus into [finder]'s subtree, returning the focused node.
  ///
  /// Pressing Tab is how a real keyboard user reaches a control, so driving
  /// the tests this way proves the control is genuinely in the focus order
  /// (§2.4.3) rather than merely owning a FocusNode nothing can reach.
  Future<FocusNode> tabTo(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 30; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final node = FocusManager.instance.primaryFocus;
      if (node != null && node.context != null) {
        final inSubtree = find
            .descendant(
                of: finder, matching: find.byWidget(node.context!.widget))
            .evaluate()
            .isNotEmpty;
        if (inSubtree) return node;
      }
    }
    fail('Tab traversal never reached anything inside $finder — the control '
        'is not in the focus order, which fails WCAG 2.1.1 / 2.4.3.');
  }

  /// Widens the test surface past the `lg` breakpoint.
  ///
  /// ItNavHeader and ItMegamenu switch to their hamburger layout below 992px,
  /// and the default 800x600 test window silently lands on the mobile branch —
  /// so a desktop contract asserted without this is really asserting nothing.
  void useDesktopViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  group('2.4.1 Bypass Blocks — ItSkiplinks', () {
    testWidgets('the skiplink stays in the semantics tree while hidden',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItSkiplinks(
          links: [ItSkiplink(label: 'Salta al contenuto principale')],
        ),
      ));

      final node = _find(
        tester,
        (d) => d.label.contains('Salta al contenuto principale'),
      );
      expect(
        node,
        isNotNull,
        reason: 'A bypass block that is culled from the semantics tree while '
            'visually hidden is inert. Opacity(alwaysIncludeSemantics: true) '
            'is what keeps it reachable — see the note in ItSkiplinks.',
      );
      expect(node!.getSemanticsData().hasFlag(SemanticsFlag.isLink), isTrue);
      handle.dispose();
    });

    testWidgets('activating a skiplink moves focus to its target',
        (tester) async {
      final handle = tester.ensureSemantics();
      final target = FocusNode(debugLabel: 'main');
      addTearDown(target.dispose);

      await tester.pumpWidget(_host(
        Column(
          children: [
            ItSkiplinks(
              links: [
                ItSkiplink(
                  label: 'Salta al contenuto principale',
                  targetFocusNode: target,
                ),
              ],
            ),
            Focus(focusNode: target, child: const Text('Contenuto')),
          ],
        ),
      ));

      await tabTo(tester, find.byType(ItSkiplinks));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(target.hasFocus, isTrue,
          reason: 'the whole point of §2.4.1 is that focus lands past the '
              'repeated navigation block');
      handle.dispose();
    });
  });

  group('2.4.8 Location — ItBreadcrumb', () {
    testWidgets('the current page is exposed as selected', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItBreadcrumb(items: [
          ItBreadcrumbItem(label: 'Home', onTap: () {}),
          ItBreadcrumbItem(label: 'Servizi', onTap: () {}),
          const ItBreadcrumbItem(label: 'Anagrafe'),
        ]),
      ));

      final current = _find(
        tester,
        (d) => d.hasFlag(SemanticsFlag.isSelected) && d.label == 'Anagrafe',
      );
      expect(
        current,
        isNotNull,
        reason: 'the last crumb is the current page; without an aria-current '
            'equivalent AT reads the trail without ever saying where the user '
            'is (§2.4.8)',
      );
      handle.dispose();
    });

    testWidgets('the trail is a navigation landmark', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItBreadcrumb(items: [
          ItBreadcrumbItem(label: 'Home', onTap: () {}),
          const ItBreadcrumbItem(label: 'Anagrafe'),
        ]),
      ));

      expect(
          _find(tester, (d) => d.role == SemanticsRole.navigation), isNotNull,
          reason: 'breadcrumbs are a navigation landmark (§1.3.1)');
      handle.dispose();
    });

    testWidgets('preceding crumbs are links, and the separator is not read',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItBreadcrumb(items: [
          ItBreadcrumbItem(label: 'Home', onTap: () {}),
          const ItBreadcrumbItem(label: 'Anagrafe'),
        ]),
      ));

      final link = _find(
        tester,
        (d) => d.hasFlag(SemanticsFlag.isLink) && d.label == 'Home',
      );
      expect(link, isNotNull, reason: 'a crumb that navigates is a link');

      expect(
        _find(tester, (d) => d.label == '/'),
        isNull,
        reason: 'the "/" is presentational punctuation; announcing it between '
            'every crumb is noise',
      );
      handle.dispose();
    });

    testWidgets('a crumb activates from the keyboard', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_host(
        ItBreadcrumb(items: [
          ItBreadcrumbItem(label: 'Home', onTap: () => tapped = true),
          const ItBreadcrumbItem(label: 'Anagrafe'),
        ]),
      ));

      await tabTo(tester, find.byType(ItBreadcrumb));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(tapped, isTrue,
          reason: 'a link reachable by Tab must also activate by Enter '
              '(§2.1.1)');
    });
  });

  group('2.4.4 Link Purpose — icon-only navigation controls', () {
    testWidgets('ItBackToTopButton is a named, keyboard-operable button',
        (tester) async {
      final handle = tester.ensureSemantics();
      var pressed = false;
      await tester.pumpWidget(_host(
        ItBackToTopButton(onPressed: () => pressed = true),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isButton));
      expect(node, isNotNull);
      expect(
        node!.getSemanticsData().label,
        'Torna su',
        reason: 'the control paints only an arrow, so an unlabelled node here '
            'is a hard §2.4.4 failure',
      );

      await tabTo(tester, find.byType(ItBackToTopButton));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(pressed, isTrue, reason: 'Space must activate a button (§2.1.1)');
      handle.dispose();
    });

    testWidgets('footer social links carry their platform name',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItFooter(
          institutionName: 'Comune di Roma',
          socialLinks: [
            ItSocialLink(
              icon: Icons.facebook,
              label: 'Facebook',
              onTap: () {},
            ),
          ],
        ),
      ));

      final node = _find(
        tester,
        (d) => d.label == 'Facebook' && d.hasFlag(SemanticsFlag.isLink),
      );
      expect(node, isNotNull,
          reason: 'an icon-only social link is meaningless to AT without its '
              'accessible name (§2.4.4)');
      handle.dispose();
    });
  });

  group('1.3.1 Info and Relationships — landmarks and headings', () {
    testWidgets('ItFooter is a contentinfo landmark with real headings',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItFooter(
          institutionName: 'Comune di Roma',
          description: 'Uno dei tanti Comuni d Italia',
        ),
      ));

      expect(
        _find(tester, (d) => d.role == SemanticsRole.contentInfo),
        isNotNull,
        reason: 'a footer is the contentinfo landmark (§1.3.1)',
      );

      final h2 = _find(tester, (d) => d.label == 'Comune di Roma');
      expect(h2, isNotNull);
      expect(
        h2!.getSemanticsData().headingLevel,
        2,
        reason: 'the kit marks the institution name up as <h2>; carrying the '
            'level lets AT navigate by heading',
      );
      handle.dispose();
    });

    testWidgets('ItCenterHeader exposes the site title as a heading',
        (tester) async {
      final handle = tester.ensureSemantics();
      useDesktopViewport(tester);
      await tester.pumpWidget(_host(
        const ItCenterHeader(title: 'Lorem Ipsum', subtitle: 'Tag line'),
      ));

      final title = _find(tester, (d) => d.label == 'Lorem Ipsum');
      expect(title, isNotNull);
      expect(title!.getSemanticsData().headingLevel, 2);
      handle.dispose();
    });

    testWidgets(
        'ItNavHeader is a navigation landmark and marks the active item',
        (tester) async {
      final handle = tester.ensureSemantics();
      useDesktopViewport(tester);
      await tester.pumpWidget(_host(
        ItNavHeader(items: [
          ItNavItem(label: 'Link 1', active: true, onTap: () {}),
          ItNavItem(label: 'Link 2', onTap: () {}),
        ]),
      ));

      expect(
          _find(tester, (d) => d.role == SemanticsRole.navigation), isNotNull,
          reason: 'the nav band is the primary navigation landmark');

      final active = _find(tester, (d) => d.label == 'Link 1');
      expect(active, isNotNull);
      expect(
        active!.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
        isTrue,
        reason: 'the active item is distinguished only by a 3px underline; '
            'colour and shape alone are not programmatically determinable',
      );
      handle.dispose();
    });
  });

  group('4.1.2 expanded state — disclosure controls', () {
    testWidgets('ItSlimHeader dropdown reports collapsed and expanded',
        (tester) async {
      final handle = tester.ensureSemantics();

      useDesktopViewport(tester);
      for (final expanded in [false, true]) {
        await tester.pumpWidget(_host(
          ItSlimHeader(
            institutionName: 'Ente',
            dropdownLabel: 'ITA',
            dropdownExpanded: expanded,
            onDropdownTap: () {},
          ),
        ));

        final node = _find(tester, (d) => d.label == 'ITA');
        expect(node, isNotNull);
        final data = node!.getSemanticsData();
        expect(data.hasFlag(SemanticsFlag.hasExpandedState), isTrue,
            reason: 'a dropdown toggle must advertise that it expands');
        expect(
          data.hasFlag(SemanticsFlag.isExpanded),
          expanded,
          reason: 'the open/closed state is painted only as a flipped chevron; '
              'without aria-expanded a screen-reader user cannot tell',
        );
      }
      handle.dispose();
    });

    testWidgets('ItMegamenu toggle flips expanded, and Esc closes the panel',
        (tester) async {
      final handle = tester.ensureSemantics();
      useDesktopViewport(tester);
      await tester.pumpWidget(_host(
        const ItMegamenu(
          sections: [
            ItMegamenuSection(
              label: 'Amministrazione',
              columns: [
                ItMegamenuColumn(
                  links: [ItMegamenuLink(label: 'Sindaco')],
                ),
              ],
            ),
          ],
        ),
      ));

      SemanticsData toggle() =>
          _find(tester, (d) => d.label == 'Amministrazione')!
              .getSemanticsData();

      expect(toggle().hasFlag(SemanticsFlag.hasExpandedState), isTrue);
      expect(toggle().hasFlag(SemanticsFlag.isExpanded), isFalse);

      await tester.tap(find.text('Amministrazione'));
      await tester.pumpAndSettle();
      expect(toggle().hasFlag(SemanticsFlag.isExpanded), isTrue,
          reason: 'opening the panel must be reflected in the toggle state');
      expect(find.byType(ItMegamenuPanel), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(
        find.byType(ItMegamenuPanel),
        findsNothing,
        reason: 'an open overlay must be dismissible from the keyboard '
            '(§2.1.2); mouse-only dismissal traps keyboard users',
      );
      handle.dispose();
    });
  });

  group('2.5.8 Target Size — navigation controls', () {
    testWidgets('back-to-top, social and nav links all clear 24x24',
        (tester) async {
      await tester.pumpWidget(_host(
        ItBackToTopButton(onPressed: () {}),
      ));
      final backToTop = _hitTargetSize(tester, find.byType(ItBackToTopButton));
      expect(backToTop.width, greaterThanOrEqualTo(_kMinTargetSize));
      expect(backToTop.height, greaterThanOrEqualTo(_kMinTargetSize));

      useDesktopViewport(tester);
      await tester.pumpWidget(_host(
        ItNavHeader(items: [ItNavItem(label: 'Link 1', onTap: () {})]),
      ));
      final navLink = _hitTargetSize(tester, find.text('Link 1'));
      expect(
        navLink.height,
        greaterThanOrEqualTo(_kMinTargetSize),
        reason: 'nav links are ${navLink.height}px tall; §2.5.8 requires 24. '
            'Fix by enlarging the hit area, never the painted glyph.',
      );
    });
  });

  // ══ CONTENT group ════════════════════════════════════════════════

  group('ItAccordion', () {
    testWidgets('the header is a button that reports its expanded state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItAccordion(items: [
          ItAccordionItem(title: 'Sezione 1', body: Text('Contenuto 1')),
        ]),
      ));

      SemanticsData header() =>
          _find(tester, (d) => d.label == 'Sezione 1')!.getSemanticsData();

      expect(header().hasFlag(SemanticsFlag.isButton), isTrue,
          reason: 'the accordion header is a control, not static text');
      expect(header().hasFlag(SemanticsFlag.hasExpandedState), isTrue);
      expect(header().hasFlag(SemanticsFlag.isExpanded), isFalse);

      await tester.tap(find.text('Sezione 1'));
      await tester.pumpAndSettle();
      expect(
        header().hasFlag(SemanticsFlag.isExpanded),
        isTrue,
        reason: 'without aria-expanded, AT cannot distinguish an open panel '
            'from a closed one (§4.1.2)',
      );
      handle.dispose();
    });

    testWidgets('the header is a heading tied to the panel it controls',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItAccordion(items: [
          ItAccordionItem(title: 'Sezione 1', body: Text('Contenuto 1')),
        ]),
      ));

      final data =
          _find(tester, (d) => d.label == 'Sezione 1')!.getSemanticsData();
      expect(data.headingLevel, 2,
          reason: 'the kit wraps the button in <h2 class="accordion-header">');
      expect(
        data.controlsNodes,
        isNotEmpty,
        reason: 'aria-controls ties the header to its panel (§1.3.1)',
      );
      handle.dispose();
    });

    testWidgets('the header activates from the keyboard', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItAccordion(items: [
          ItAccordionItem(title: 'Sezione 1', body: Text('Contenuto 1')),
        ]),
      ));

      // Asserted on the semantics tree, not `find.text`: ItCollapse keeps the
      // collapsed panel's widgets mounted at zero height and merely drops them
      // from the semantics tree, so a widget-level check would pass while the
      // panel was shut.
      bool contentIsExposed() =>
          _find(tester, (d) => d.label.contains('Contenuto 1')) != null;

      expect(contentIsExposed(), isFalse,
          reason: 'a collapsed panel must not be reachable by AT');

      await tabTo(tester, find.byType(ItAccordion));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(contentIsExposed(), isTrue,
          reason: 'Enter must open the panel (§2.1.1)');
      handle.dispose();
    });
  });

  group('ItTabBar / ItTabView', () {
    testWidgets('tabs expose the tab role, the tab bar, and the selected tab',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItTabBar(
          tabs: const [ItTabItem(label: 'Uno'), ItTabItem(label: 'Due')],
          selectedIndex: 0,
          onChanged: (_) {},
        ),
      ));

      expect(_find(tester, (d) => d.role == SemanticsRole.tabBar), isNotNull,
          reason: 'the container role is what makes AT say "tab 1 of 2"');

      final tabs = _findAll(tester, (d) => d.role == SemanticsRole.tab);
      expect(tabs, hasLength(2));
      expect(tabs.first.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
          isTrue);
      expect(tabs.last.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
          isFalse);
      handle.dispose();
    });

    testWidgets('ItTabView exposes the tabpanel role', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItTabView(
          selectedIndex: 0,
          animated: false,
          children: [Text('Pannello 1')],
        ),
      ));

      expect(_find(tester, (d) => d.role == SemanticsRole.tabPanel), isNotNull,
          reason: 'the pane the selected tab controls is a tabpanel (§1.3.1)');
      handle.dispose();
    });

    testWidgets('arrow keys move between tabs, per the ARIA tab pattern',
        (tester) async {
      var selected = 0;
      await tester.pumpWidget(_host(
        StatefulBuilder(
          builder: (context, setState) => ItTabBar(
            tabs: const [
              ItTabItem(label: 'Uno'),
              ItTabItem(label: 'Due'),
              ItTabItem(label: 'Tre'),
            ],
            selectedIndex: selected,
            onChanged: (i) => setState(() => selected = i),
          ),
        ),
      ));

      await tabTo(tester, find.byType(ItTabBar));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(selected, 1,
          reason:
              'the ARIA tab pattern navigates with the arrow keys, not Tab');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(selected, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(selected, 2, reason: 'End jumps to the last tab');
    });
  });

  group('ItCard / ItList — one control, one name', () {
    testWidgets('a tappable card is a single node, not a pile of text',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 400,
          child: ItCard(
            title: 'Titolo',
            subtitle: 'Sottotitolo',
            date: '22 aprile 2025',
            body: const Text('Corpo'),
            onTap: () {},
          ),
        ),
      ));

      final buttons =
          _findAll(tester, (d) => d.hasFlag(SemanticsFlag.isButton));
      expect(
        buttons,
        hasLength(1),
        reason: 'a whole-card tap target must be ONE focusable control; '
            'otherwise AT walks title, subtitle, body and date as separate '
            'stops none of which say they activate anything (§2.4.3, §4.1.2)',
      );
      expect(buttons.single.getSemanticsData().label, contains('Titolo'));
      handle.dispose();
    });

    // Every constructor shape that can carry text must yield a non-empty name.
    // The regression this pins: the name was built only from the four *string*
    // slots, and the card body was inside an ExcludeSemantics — so
    // `ItCard(body: ..., onTap: ...)`, which is entirely legal, rendered a
    // focusable button announced as nothing at all (§4.1.2 Name, Role, Value).
    for (final shape in <String, ItCard>{
      'title only': ItCard(title: 'Titolo', onTap: () {}),
      'body only': ItCard(body: const Text('Corpo'), onTap: () {}),
      'footer only': ItCard(footer: const Text('Piede'), onTap: () {}),
      'category only': ItCard(
          category: const ItCardCategory(label: 'Categoria'), onTap: () {}),
      'date only': ItCard(date: '22 aprile 2025', onTap: () {}),
      'signature only': ItCard(signature: 'Firma', onTap: () {}),
    }.entries) {
      testWidgets('a tappable card built from ${shape.key} still has a name',
          (tester) async {
        final handle = tester.ensureSemantics();
        await tester
            .pumpWidget(_host(SizedBox(width: 400, child: shape.value)));

        final button = _find(tester, (d) => d.hasFlag(SemanticsFlag.isButton));
        expect(button, isNotNull, reason: 'a tappable card is a button');
        expect(
          button!.getSemanticsData().label.trim(),
          isNotEmpty,
          reason: 'a card whose only content is "${shape.key}" is announced as '
              'an unlabelled button — the user is told a control exists but not '
              'what it does (§4.1.2)',
        );
        handle.dispose();
      });
    }

    testWidgets('semanticLabel overrides the visible text and is not doubled',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 400,
          child: ItCard(
            title: 'Leggi di piu',
            body: const Text('Corpo'),
            semanticLabel: 'Leggi il bando per le scuole',
            onTap: () {},
          ),
        ),
      ));

      final label = _find(tester, (d) => d.hasFlag(SemanticsFlag.isButton))!
          .getSemanticsData()
          .label;
      expect(label, 'Leggi il bando per le scuole',
          reason: '§2.4.4: a generic "Leggi di piu" must be overridable, and '
              'the override must REPLACE the visible text rather than being '
              'concatenated with it');
      handle.dispose();
    });

    testWidgets('a tappable card with no nameable content is a build error',
        (tester) async {
      // Not a stylistic assert: an image-only card genuinely cannot be named
      // from here, because there is no way to read alt text out of an arbitrary
      // Widget. Failing loudly is the only alternative to shipping a silently
      // unlabelled control.
      await tester.pumpWidget(_host(
        SizedBox(
          width: 400,
          child: ItCard(image: const SizedBox(height: 40), onTap: () {}),
        ),
      ));
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('a non-tappable card stays readable as ordinary content',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 400,
          child: ItCard(title: 'Titolo', body: Text('Corpo')),
        ),
      ));

      expect(
          _findAll(tester, (d) => d.hasFlag(SemanticsFlag.isButton)), isEmpty,
          reason: 'static content must not claim to be a control');
      expect(_find(tester, (d) => d.label.contains('Corpo')), isNotNull);
      handle.dispose();
    });

    testWidgets('list items merge into one link and expose active/disabled',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 400,
          child: ItList(items: [
            ItListItem(
              title: 'Elemento 1',
              subtitle: 'Descrizione',
              active: true,
              onTap: () {},
            ),
            ItListItem(title: 'Elemento 2', disabled: true, onTap: () {}),
          ]),
        ),
      ));

      final first = _find(tester, (d) => d.label.contains('Elemento 1'))!;
      final firstData = first.getSemanticsData();
      expect(firstData.hasFlag(SemanticsFlag.isLink), isTrue);
      expect(firstData.hasFlag(SemanticsFlag.isSelected), isTrue,
          reason: 'the active item is otherwise distinguished by colour alone');
      expect(firstData.label, contains('Descrizione'),
          reason: 'title and description belong to one link, so they must be '
              'announced as one name');

      final second = _find(tester, (d) => d.label.contains('Elemento 2'))!
          .getSemanticsData();
      expect(second.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(second.hasFlag(SemanticsFlag.isEnabled), isFalse,
          reason: 'a disabled item must report itself disabled, not merely '
              'be inert');
      handle.dispose();
    });
  });

  group('ItCallout', () {
    testWidgets('the title is a heading and the variant icon is not announced',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 400,
          child: ItCallout(
            variant: ItCalloutVariant.success,
            title: 'Nota bene',
            body: Text('Testo'),
          ),
        ),
      ));

      final title = _find(tester, (d) => d.label == 'Nota bene');
      expect(title, isNotNull);
      expect(title!.getSemanticsData().headingLevel, 3,
          reason: 'the callout title heads its content (§1.3.1)');

      expect(
        _findAll(tester, (d) => d.label.toLowerCase().contains('check')),
        isEmpty,
        reason: 'the variant glyph is decorative — announcing it adds noise '
            'without adding information',
      );
      handle.dispose();
    });

    testWidgets('a collapsible callout reports and toggles its expanded state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 400,
          child: ItCallout(
            title: 'Nota bene',
            collapsible: true,
            initiallyExpanded: false,
            body: Text('Testo nascosto'),
          ),
        ),
      ));

      SemanticsData title() =>
          _find(tester, (d) => d.label == 'Nota bene')!.getSemanticsData();

      expect(title().hasFlag(SemanticsFlag.isButton), isTrue);
      expect(title().hasFlag(SemanticsFlag.isExpanded), isFalse);

      await tabTo(tester, find.byType(ItCallout));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(title().hasFlag(SemanticsFlag.isExpanded), isTrue);
      expect(find.text('Testo nascosto'), findsOneWidget,
          reason: 'Enter must open a collapsible callout (§2.1.1)');
      handle.dispose();
    });
  });

  group('3.3.1 Error Identification / 3.3.2 Labels or Instructions', () {
    testWidgets('ItInput ties its validation message to the field itself',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 320,
          child: ItInput(
            groupMargin: false,
            label: 'Codice fiscale',
            errorText: 'Il codice fiscale non è valido',
          ),
        ),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isTextField));
      final data = node!.getSemanticsData();
      expect(
        data.hint,
        contains('Il codice fiscale non è valido'),
        reason: 'WCAG 3.3.1: the message must reach the user *as part of the '
            'field*. Painted below it as loose text, a screen-reader user who '
            'tabs to the field never hears why it was rejected',
      );
      expect(
        data.validationResult,
        SemanticsValidationResult.invalid,
        reason: 'the field must also carry the invalid state, so AT can '
            'announce it on focus rather than only when read in order',
      );
      handle.dispose();
    });

    testWidgets('the validation message is not also announced as loose text',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 320,
          child: ItInput(
            groupMargin: false,
            label: 'Codice fiscale',
            errorText: 'Il codice fiscale non è valido',
          ),
        ),
      ));

      final strays = _findAll(
        tester,
        (d) =>
            !d.hasFlag(SemanticsFlag.isTextField) &&
            d.label.contains('Il codice fiscale non è valido'),
      );
      expect(strays, isEmpty,
          reason: 'the message belongs to the field; a second, unassociated '
              'copy makes a screen reader say it twice with nothing tying the '
              'stray one to the control');
      handle.dispose();
    });

    testWidgets('ItInput carries its helper text as the field hint',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 320,
          child: ItInput(
            groupMargin: false,
            label: 'Codice fiscale',
            helperText: 'Come riportato sulla tessera sanitaria',
          ),
        ),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isTextField));
      expect(
        node!.getSemanticsData().hint,
        'Come riportato sulla tessera sanitaria',
        reason: 'WCAG 3.3.2: the instruction has to be part of the field, not '
            'a paragraph that happens to sit under it',
      );
      handle.dispose();
    });

    testWidgets('ItSelect ties its validation message to the control',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItSelect<String>(
            groupMargin: false,
            label: 'Provincia',
            errorText: 'Scegli una provincia',
            items: const [ItSelectItem(value: 'RM', label: 'Roma')],
            onChanged: (_) {},
          ),
        ),
      ));

      final node =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.hasExpandedState));
      final data = node!.getSemanticsData();
      expect(data.hint, contains('Scegli una provincia'));
      expect(data.validationResult, SemanticsValidationResult.invalid);
      handle.dispose();
    });

    testWidgets('a required ItInput announces the constraint', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 320,
          child: ItInput(
              groupMargin: false, label: 'Codice fiscale', required: true),
        ),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isTextField));
      final data = node!.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.hasRequiredState), isTrue);
      expect(data.hasFlag(SemanticsFlag.isRequired), isTrue,
          reason: 'WCAG 3.3.2: a user must learn a field is mandatory before '
              'submitting, not from the error that follows');
      handle.dispose();
    });

    testWidgets('a non-required ItInput is not reported as required',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
            width: 320, child: ItInput(groupMargin: false, label: 'Note')),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isTextField));
      expect(
          node!.getSemanticsData().hasFlag(SemanticsFlag.isRequired), isFalse,
          reason: 'over-reporting required is as misleading as omitting it');
      handle.dispose();
    });

    testWidgets('a group announces one error, not one per option',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItRadioGroup<String>(
            label: 'Fase',
            value: null,
            errorText: 'Scegli una fase',
            options: const [
              ItRadioOption(value: 'a', label: 'Attenzione'),
              ItRadioOption(value: 'p', label: 'Preallarme'),
              ItRadioOption(value: 'l', label: 'Allarme'),
            ],
            onChanged: (_) {},
          ),
        ),
      ));

      final invalid = _findAll(
        tester,
        (d) => d.validationResult == SemanticsValidationResult.invalid,
      );
      expect(invalid, hasLength(1),
          reason: 'the tint reaches every option, because `.is-invalid` sits '
              'on each input — but the invalid STATE was reaching them too, so '
              'three radios and the group announced "non valido" four times '
              'for one message that exists once');
      expect(invalid.single.getSemanticsData().label, contains('Fase'),
          reason: 'the one that keeps it is the group, which is also the node '
              'carrying the message');
      handle.dispose();
    });

    testWidgets('a checkbox group does the same', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItCheckboxGroup<String>(
            label: 'Funzioni',
            values: const {},
            errorText: 'Scegli almeno una funzione',
            options: const [
              ItCheckboxOption(value: '1', label: 'Tecnica'),
              ItCheckboxOption(value: '2', label: 'Sanità'),
            ],
            onChanged: (_) {},
          ),
        ),
      ));

      expect(
        _findAll(tester,
            (d) => d.validationResult == SemanticsValidationResult.invalid),
        hasLength(1),
      );
      handle.dispose();
    });

    testWidgets('a control outside a group keeps its own invalid state',
        (tester) async {
      // The suppression must come from being inside a group, not from the
      // control having stopped reporting validity at all.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const SizedBox(
          width: 320,
          child: ItCheckbox(
            value: false,
            label: 'Accetto',
            errorText: 'Obbligatorio',
          ),
        ),
      ));
      expect(
        _findAll(tester,
            (d) => d.validationResult == SemanticsValidationResult.invalid),
        hasLength(1),
      );
      handle.dispose();
    });

    testWidgets('a required ItSelect and ItRadioGroup announce the constraint',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        Column(
          children: [
            SizedBox(
              width: 320,
              child: ItSelect<String>(
                groupMargin: false,
                label: 'Provincia',
                required: true,
                items: const [ItSelectItem(value: 'RM', label: 'Roma')],
                onChanged: (_) {},
              ),
            ),
            SizedBox(
              width: 320,
              child: ItRadioGroup<String>(
                label: 'Genere',
                required: true,
                options: const [ItRadioOption(value: 'M', label: 'Maschio')],
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ));

      final select =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.hasExpandedState));
      expect(
          select!.getSemanticsData().hasFlag(SemanticsFlag.isRequired), isTrue);

      final group = _find(tester, (d) => d.role == SemanticsRole.radioGroup);
      expect(group, isNotNull,
          reason: 'the set of radios must be exposed as one group, so its '
              'caption names every option in it (WCAG 1.3.1)');
      final groupData = group!.getSemanticsData();
      expect(groupData.label, contains('Genere'));
      expect(groupData.hasFlag(SemanticsFlag.isRequired), isTrue);
      handle.dispose();
    });
  });

  group('4.1.2 disabled states', () {
    testWidgets('a disabled ItCheckbox reports itself disabled, not inert',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItCheckbox(
          label: 'Accetto',
          value: true,
          enabled: false,
          onChanged: (_) {},
        ),
      ));

      final node =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.hasCheckedState));
      expect(node, isNotNull,
          reason: 'a disabled checkbox is still a checkbox and must still say '
              'whether it is checked');
      final data = node!.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.hasEnabledState), isTrue,
          reason: 'AT must be able to tell this control CAN be enabled');
      expect(data.hasFlag(SemanticsFlag.isEnabled), isFalse);
      expect(data.hasFlag(SemanticsFlag.isChecked), isTrue);
      handle.dispose();
    });

    testWidgets('a disabled ItToggle and ItRadio report themselves disabled',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        Column(
          children: [
            SizedBox(
              width: 320,
              child: ItToggle(
                label: 'Notifiche',
                value: true,
                enabled: false,
                onChanged: (_) {},
              ),
            ),
            ItRadio<int>(
              value: 1,
              groupValue: 1,
              label: 'Uno',
              enabled: false,
              onChanged: (_) {},
            ),
          ],
        ),
      ));

      final toggle =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.hasToggledState));
      expect(
          toggle!.getSemanticsData().hasFlag(SemanticsFlag.isEnabled), isFalse);
      expect(toggle.getSemanticsData().hasFlag(SemanticsFlag.isToggled), isTrue,
          reason: 'a disabled switch still has to report its position');

      final radio = _find(
        tester,
        (d) => d.hasFlag(SemanticsFlag.isInMutuallyExclusiveGroup),
      );
      final radioData = radio!.getSemanticsData();
      expect(radioData.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(radioData.hasFlag(SemanticsFlag.isEnabled), isFalse);
      expect(radioData.hasFlag(SemanticsFlag.isChecked), isTrue);
      handle.dispose();
    });

    testWidgets('a disabled ItInput and ItSelect report themselves disabled',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        Column(
          children: [
            const SizedBox(
              width: 320,
              child: ItInput(
                  groupMargin: false, label: 'Codice fiscale', enabled: false),
            ),
            SizedBox(
              width: 320,
              child: ItSelect<String>(
                groupMargin: false,
                label: 'Provincia',
                enabled: false,
                items: const [ItSelectItem(value: 'RM', label: 'Roma')],
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ));

      final field = _find(tester, (d) => d.hasFlag(SemanticsFlag.isTextField));
      final fieldData = field!.getSemanticsData();
      expect(fieldData.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(fieldData.hasFlag(SemanticsFlag.isEnabled), isFalse);
      expect(fieldData.label, contains('Codice fiscale'),
          reason: 'a disabled field still needs a name, or a screen reader '
              'reaches an anonymous read-only control');

      final select =
          _find(tester, (d) => d.hasFlag(SemanticsFlag.hasExpandedState));
      final selectData = select!.getSemanticsData();
      expect(selectData.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(selectData.hasFlag(SemanticsFlag.isEnabled), isFalse);
      handle.dispose();
    });

    testWidgets('a disabled control cannot be operated', (tester) async {
      var changes = 0;
      await tester.pumpWidget(_host(
        ItCheckbox(
          label: 'Accetto',
          value: false,
          enabled: false,
          onChanged: (_) => changes++,
        ),
      ));

      await tester.tap(find.byType(ItCheckbox), warnIfMissed: false);
      await tester.pump();
      expect(changes, 0, reason: 'a disabled checkbox must not change on tap');
    });
  });

  group('2.1.1 Keyboard / 2.1.2 No Keyboard Trap', () {
    testWidgets('Space toggles a Tab-focused ItCheckbox', (tester) async {
      bool? received;
      await tester.pumpWidget(_host(
        ItCheckbox(
          label: 'Accetto',
          value: false,
          onChanged: (v) => received = v,
        ),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(received, isTrue,
          reason: 'WCAG 2.1.1: Space is how a checkbox is operated without a '
              'pointer; a GestureDetector alone has no keyboard behaviour');
    });

    testWidgets('Space toggles a Tab-focused ItToggle', (tester) async {
      bool? received;
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItToggle(
            label: 'Notifiche',
            value: false,
            onChanged: (v) => received = v,
          ),
        ),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(received, isTrue, reason: 'WCAG 2.1.1');
    });

    testWidgets('Space selects a Tab-focused ItRadio', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(
        ItRadio<int>(
            value: 1, groupValue: 0, label: 'Uno', onChanged: (_) => taps++),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(taps, 1, reason: 'WCAG 2.1.1');
    });

    testWidgets('every form control is reachable with Tab', (tester) async {
      await tester.pumpWidget(_host(
        Column(
          children: [
            ItCheckbox(label: 'Accetto', value: false, onChanged: (_) {}),
            ItRadio<int>(
                value: 1, groupValue: 0, label: 'Uno', onChanged: (_) {}),
            SizedBox(
              width: 320,
              child: ItToggle(
                label: 'Notifiche',
                value: false,
                onChanged: (_) {},
              ),
            ),
            SizedBox(
              width: 320,
              child: ItSelect<String>(
                groupMargin: false,
                label: 'Provincia',
                items: const [ItSelectItem(value: 'RM', label: 'Roma')],
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ));

      final expected = <Type>[
        ItCheckbox,
        // Typed: `ItRadio` on its own is `ItRadio<dynamic>`, which matches
        // nothing now that the radio carries the type of what it stands for.
        ItRadio<int>,
        ItToggle,
        ItSelect<String>,
      ];
      final reached = <Type>{};
      for (var i = 0; i < 10; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focused = FocusManager.instance.primaryFocus?.context;
        if (focused == null) continue;
        for (final type in expected) {
          final host = tester.element(find.byType(type));
          if (_isAncestor(host, focused as Element)) reached.add(type);
        }
      }

      expect(reached, containsAll(expected),
          reason: 'WCAG 2.1.1: a control that Tab never reaches cannot be '
              'used without a pointer at all. Missing: '
              '${expected.toSet().difference(reached)}');
    });

    testWidgets('arrow keys move the selection inside an ItRadioGroup',
        (tester) async {
      String? value = 'M';
      await tester.pumpWidget(_host(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 320,
            child: ItRadioGroup<String>(
              label: 'Genere',
              value: value,
              options: const [
                ItRadioOption(value: 'M', label: 'Maschio'),
                ItRadioOption(value: 'F', label: 'Femmina'),
                ItRadioOption(value: 'X', label: 'Altro'),
              ],
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      ));

      // Focus the first radio, then walk the group.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, 'F',
          reason: 'WCAG 2.1.1: a native radio group moves with the arrow keys, '
              'and AT users are taught to expect exactly that');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(value, 'M');
    });

    testWidgets('Escape closes an open ItSelect and returns focus to it',
        (tester) async {
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItSelect<String>(
            groupMargin: false,
            label: 'Provincia',
            items: const [
              ItSelectItem(value: 'RM', label: 'Roma'),
              ItSelectItem(value: 'MI', label: 'Milano'),
            ],
            onChanged: (_) {},
          ),
        ),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(find.text('Milano'), findsOneWidget, reason: 'the list is open');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Milano'), findsNothing,
          reason: 'WCAG 2.1.2: Escape must dismiss the list from the keyboard');

      final scope =
          FocusScope.of(tester.element(find.byType(ItSelect<String>)));
      expect(scope.focusedChild, isNotNull,
          reason: 'WCAG 2.1.2: focus must not be stranded on a widget that no '
              'longer exists');
    });

    testWidgets('arrow keys and Enter choose an option in ItSelect',
        (tester) async {
      String? chosen;
      await tester.pumpWidget(_host(
        SizedBox(
          width: 320,
          child: ItSelect<String>(
            groupMargin: false,
            label: 'Provincia',
            items: const [
              ItSelectItem(value: 'RM', label: 'Roma'),
              ItSelectItem(value: 'MI', label: 'Milano'),
            ],
            onChanged: (v) => chosen = v,
          ),
        ),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(chosen, isNotNull,
          reason: 'WCAG 2.1.1: the list must be navigable and selectable '
              'without a pointer');
    });
  });

  group('2.4.7 Focus Visible', () {
    for (final entry in <String, Widget>{
      'ItCheckbox':
          ItCheckbox(label: 'Accetto', value: false, onChanged: (_) {}),
      'ItRadio': ItRadio<int>(
          value: 1, groupValue: 0, label: 'Uno', onChanged: (_) {}),
      'ItToggle': ItToggle(label: 'Notifiche', value: false, onChanged: (_) {}),
      // Their only indicator used to be `.form-control:focus`'s 25% ring —
      // which Italia overrides for keyboard focus too, with this same ring.
      // test/a11y/form_focus_rendering_test.dart checks the pixels.
      'ItInput': const ItInput(label: 'Nome', groupMargin: false),
      'ItAutocomplete': ItAutocomplete<String>(
        label: 'Comune',
        onSearch: (_) async => const <String>[],
        displayStringForOption: (o) => o,
        groupMargin: false,
      ),
    }.entries) {
      testWidgets('${entry.key} paints a focus indicator on keyboard focus',
          (tester) async {
        _useKeyboardNavigation();
        addTearDown(() => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic);

        await tester
            .pumpWidget(_host(SizedBox(width: 320, child: entry.value)));
        final ring = find.byWidgetPredicate(
          (w) => w is ItFocusRing && w.visible,
        );
        expect(ring, findsNothing,
            reason: 'unfocused controls must not paint an indicator, or the '
                'pixel parity of every resting capture moves');

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(ring, findsWidgets,
            reason: 'WCAG 2.4.7: without an indicator a keyboard user cannot '
                'tell which control they are about to operate. Bootstrap '
                'Italia paints `box-shadow: 0 0 0 2px #fff, 0 0 0 5px #000` '
                'for `:focus:not([data-focus-mouse=true])`');
      });
    }

    // Suppressing Material's overlay (`overlayColor: kItNoOverlay`) also
    // removed the grey fill it painted on keyboard focus. That fill was wrong
    // for the design system — the stylesheet keeps these rows transparent in
    // every pointer state — but it was the ONLY focus indicator these controls
    // had, so each of them now paints the kit's own ring instead.
    //
    // Asserted on the painter rather than on `ItFocusRing.visible`, because
    // the ring is driven two ways: explicitly by the controls that already
    // track focus, and from the subtree by the ones whose focus lives inside
    // an InkWell.
    for (final entry in <String, Widget>{
      'ItList row': ItList(items: [ItListItem(title: 'Link', onTap: () {})]),
      'ItDropdownMenu item': const ItDropdownMenu(
        width: 300,
        items: [ItDropdownItem(label: 'Azione')],
      ),
      'ItAccordion header': const ItAccordion(
        items: [ItAccordionItem(title: 'Sezione', body: SizedBox.shrink())],
      ),
      'ItTabBar tab': ItTabBar(
        tabs: const [ItTabItem(label: 'Uno'), ItTabItem(label: 'Due')],
        selectedIndex: 0,
        onChanged: (_) {},
      ),
      'ItChip': ItChip(label: 'Label', onTap: () {}),
      'ItBreadcrumb link': ItBreadcrumb(items: [
        ItBreadcrumbItem(label: 'Home', onTap: () {}),
        const ItBreadcrumbItem(label: 'Anagrafe'),
      ]),
      'ItFooter link': ItFooterLinkColumns(sections: [
        ItFooterSection(
          title: 'Sezione',
          links: [ItFooterLink(label: 'Link 1', onTap: () {})],
        ),
      ]),
      'ItBackToTopButton': ItBackToTopButton(onPressed: () {}),
      'ItCard tap target': ItCard(title: 'Titolo', onTap: () {}),
    }.entries) {
      testWidgets('${entry.key} paints a focus indicator on keyboard focus',
          (tester) async {
        _useKeyboardNavigation();
        addTearDown(() => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic);

        await tester
            .pumpWidget(_host(SizedBox(width: 400, child: entry.value)));

        expect(_paintedFocusRing, findsNothing,
            reason: 'an unfocused control must not paint an indicator, or the '
                'pixel parity of every resting capture moves');

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        expect(_paintedFocusRing, findsWidgets,
            reason: 'WCAG 2.4.7: with Material\'s overlay suppressed this '
                'control had no focus indicator left at all, so a keyboard '
                'user could not tell where they were');
      });
    }

    testWidgets('ItNavHeader link paints a focus indicator on keyboard focus',
        (tester) async {
      _useKeyboardNavigation();
      addTearDown(() => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic);
      useDesktopViewport(tester);

      await tester.pumpWidget(_host(
        ItNavHeader(items: [ItNavItem(label: 'Link 1', onTap: () {})]),
      ));
      expect(_paintedFocusRing, findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(_paintedFocusRing, findsWidgets,
          reason: 'WCAG 2.4.7: the nav band is the primary way around the '
              'site, so its links must be visible to a keyboard user');
    });

    testWidgets('ItMegamenu toggle paints a focus indicator on keyboard focus',
        (tester) async {
      _useKeyboardNavigation();
      addTearDown(() => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic);
      useDesktopViewport(tester);

      await tester.pumpWidget(_host(
        const ItMegamenu(
          sections: [
            ItMegamenuSection(
              label: 'Amministrazione',
              columns: [
                ItMegamenuColumn(links: [ItMegamenuLink(label: 'Sindaco')]),
              ],
            ),
          ],
        ),
      ));
      expect(_paintedFocusRing, findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(_paintedFocusRing, findsWidgets,
          reason: 'WCAG 2.4.7: the section toggle is what opens the panel, so '
              'it has to be visible before it is activated');
    });

    testWidgets('a mouse-driven focus paints nothing', (tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTouch;
      addTearDown(() => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic);

      await tester.pumpWidget(_host(
        SizedBox(
          width: 400,
          child: ItList(items: [ItListItem(title: 'Link', onTap: () {})]),
        ),
      ));
      await tester.tap(find.text('Link'));
      await tester.pumpAndSettle();

      expect(_paintedFocusRing, findsNothing,
          reason: 'the stylesheet guards the indicator with '
              '`:not([data-focus-mouse=true])`, so a pointer must never '
              'summon it');
    });
  });
}

/// Every Bootstrap Italia focus indicator currently being painted.
///
/// Matches on the painter rather than on [ItFocusRing.visible] so it covers
/// both ways the ring is driven — explicitly by controls that already track
/// keyboard focus, and from the subtree by controls whose focus node lives
/// inside an [InkWell].
final Finder _paintedFocusRing = find.byWidgetPredicate(
  (w) => w is CustomPaint && w.foregroundPainter is ItFocusRingPainter,
);
