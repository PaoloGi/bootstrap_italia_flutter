// Contracts for the list families the docs-parity pass added.
//
// Two of them are new surfaces rather than new options: `ItContentList` did not
// exist, and a collapsible `.link-sublist` inside `ItList` did not either. Both
// are shapes where the obvious implementation is inaccessible in a way no
// screenshot shows —
//
//  * a row with three icon buttons whose names are all "Azione" leaves a screen
//    reader user picking one of three identical entries out of a list, and
//  * putting those buttons *inside* the row's own link makes them unreachable
//    entirely, because a semantics node carrying an action absorbs its subtree.
//
// The first is why `ItListAction.label` is required; the second is why a row
// with actions links only its text.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        home: Scaffold(body: SizedBox(width: 600, child: child)),
      ),
    );

List<SemanticsNode> _findAll(
  WidgetTester tester,
  bool Function(SemanticsData) test,
) {
  final found = <SemanticsNode>[];
  void walk(SemanticsNode node) {
    if (test(node.getSemanticsData())) found.add(node);
    node.visitChildren((child) {
      walk(child);
      return true;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

SemanticsNode? _find(WidgetTester tester, bool Function(SemanticsData) test) {
  final all = _findAll(tester, test);
  return all.isEmpty ? null : all.first;
}

void main() {
  group('ItContentList — one row, the right number of controls', () {
    testWidgets('a row with no actions is ONE link carrying the whole name',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItContentList(items: [
          ItContentListItem(
            leading: const ItRoundedIcon(icon: Icons.folder),
            text: 'Documenti',
            description: 'Dodici file disponibili',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ]),
      ));

      final links = _findAll(tester, (d) => d.hasFlag(SemanticsFlag.isLink));
      expect(links, hasLength(1),
          reason: 'title, description, leading icon and chevron are one '
              'target; walking them as four stops, none of which says it '
              'activates anything, is the §2.4.3 / §4.1.2 failure');
      expect(links.single.getSemanticsData().label,
          'Documenti. Dodici file disponibili');
      handle.dispose();
    });

    testWidgets('the leading icon and the chevron contribute no name',
        (tester) async {
      // Both are decoration. If either announced itself the row would be read
      // as e.g. "Cartella, Documenti, Freccia destra" — three names for one
      // thing, and the middle one is the only useful one.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItContentList(items: [
          ItContentListItem(
            leading: const ItRoundedIcon(icon: Icons.folder),
            text: 'Documenti',
            trailing: const Icon(Icons.chevron_right, semanticLabel: 'Freccia'),
            onTap: () {},
          ),
        ]),
      ));

      final link = _find(tester, (d) => d.hasFlag(SemanticsFlag.isLink))!;
      expect(link.getSemanticsData().label, 'Documenti');
      handle.dispose();
    });

    testWidgets('a row with actions gives each action its own name',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItContentList(items: [
          ItContentListItem(
            text: 'Delibera 12',
            onTap: () {},
            actions: [
              ItListAction(
                  icon: Icons.code,
                  label: 'Delibera 12 - Scarica',
                  onPressed: () {}),
              ItListAction(
                  icon: Icons.share,
                  label: 'Delibera 12 - Condividi',
                  onPressed: () {}),
              ItListAction(
                  icon: Icons.delete,
                  label: 'Delibera 12 - Elimina',
                  onPressed: () {}),
            ],
          ),
        ]),
      ));

      final buttons = _findAll(tester, (d) => d.hasFlag(SemanticsFlag.isButton))
          .map((n) => n.getSemanticsData().label)
          .toList();
      expect(buttons, hasLength(3),
          reason: 'three actions, three controls — nesting them inside the '
              "row's own link would make a semantics node with an action "
              'absorb them and leave none reachable');
      expect(
        buttons.toSet(),
        hasLength(3),
        reason: 'names must be distinct: three buttons all called "Azione" are '
            "indistinguishable in a screen reader's element list (§2.4.4)",
      );
      handle.dispose();
    });

    testWidgets('with actions present the row links only its text',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItContentList(items: [
          ItContentListItem(
            text: 'Delibera 12',
            onTap: () {},
            actions: [
              ItListAction(icon: Icons.code, label: 'Azione', onPressed: () {}),
            ],
          ),
        ]),
      ));

      // The kit's own markup says the same thing: the row is a `<div>` and the
      // `<a>` is around `.text` alone.
      expect(_findAll(tester, (d) => d.hasFlag(SemanticsFlag.isLink)), isEmpty,
          reason: 'the whole row must not become one link when it also holds '
              'controls of its own');
      expect(
          _find(tester, (d) => d.hasFlag(SemanticsFlag.isButton)), isNotNull);
      handle.dispose();
    });

    testWidgets('a blank action label is a build error', (tester) async {
      // Not stylistic: the button paints a glyph and nothing else, so an empty
      // label is a control announced as "button" with no purpose (§4.1.2).
      await tester.pumpWidget(_host(
        ItContentList(items: [
          ItContentListItem(
            text: 'Riga',
            actions: [
              ItListAction(icon: Icons.code, label: '  ', onPressed: () {}),
            ],
          ),
        ]),
      ));
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('a non-tappable row stays readable content, not a control',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItContentList(items: [
          ItContentListItem(text: 'Testo', description: 'Descrizione'),
        ]),
      ));

      expect(_findAll(tester, (d) => d.hasFlag(SemanticsFlag.isLink)), isEmpty);
      expect(_find(tester, (d) => d.label.contains('Descrizione')), isNotNull,
          reason: 'static rows must still be readable');
      handle.dispose();
    });

    testWidgets('ItListThumb invents no name of its own', (tester) async {
      // `object-fit: cover` is layout. The alt text belongs to the caller's
      // image, and a wrapper that silently supplied one would be inventing a
      // description of a picture it cannot see.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItContentList(items: [
          ItContentListItem(
            leading: ItListThumb(
              child: SizedBox(
                width: 40,
                height: 40,
                child: ColoredBox(color: Color(0xFFCCCCCC)),
              ),
            ),
            text: 'Testo',
          ),
        ]),
      ));

      final labels = _findAll(tester, (d) => d.label.isNotEmpty)
          .map((n) => n.getSemanticsData().label);
      expect(labels, everyElement(isNot(contains('Image'))));
      expect(_find(tester, (d) => d.label.contains('Testo')), isNotNull);
      handle.dispose();
    });
  });

  group('ItList — the variants added for the docs page', () {
    testWidgets('§1.3.1: a heading is announced as a heading', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItList(
          heading: 'Sezione',
          items: [ItListItem(title: 'Voce')],
        ),
      ));

      final heading = _find(tester, (d) => d.hasFlag(SemanticsFlag.isHeader));
      expect(heading, isNotNull,
          reason: 'the kit marks it up as <h4>; bolder text that is not a '
              "heading is invisible to a screen reader's heading navigation");
      expect(heading!.getSemanticsData().label, 'Sezione');
      handle.dispose();
    });

    testWidgets('a linked heading is BOTH a heading and a link',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItList(
          heading: 'Sezione',
          onHeadingTap: () {},
          items: const [ItListItem(title: 'Voce')],
        ),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isHeader))!;
      final data = node.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isLink), isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.label, 'Sezione',
          reason: 'gaining the link role must not cost the heading role');
      handle.dispose();
    });

    testWidgets(
        'a collapsible group is a button with expanded state, and '
        'hides its children when closed', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItList(items: [
          ItListItem(
            title: 'Gruppo',
            collapsible: true,
            children: [ItListItem(title: 'Figlio')],
          ),
        ]),
      ));

      final closed =
          _find(tester, (d) => d.label == 'Gruppo')!.getSemanticsData();
      expect(closed.hasFlag(SemanticsFlag.isButton), isTrue,
          reason: 'it opens a group rather than going anywhere — the kit says '
              'the same with role="button"');
      expect(closed.hasFlag(SemanticsFlag.isLink), isFalse);
      expect(closed.hasFlag(SemanticsFlag.hasExpandedState), isTrue);
      expect(closed.hasFlag(SemanticsFlag.isExpanded), isFalse);
      expect(_find(tester, (d) => d.label == 'Figlio'), isNull,
          reason: 'a collapsed child that AT can still focus is worse than no '
              'animation — the user is taken somewhere invisible (§2.4.3)');

      await tester.tap(find.text('Gruppo'));
      await tester.pumpAndSettle();

      expect(
          _find(tester, (d) => d.label == 'Gruppo')!
              .getSemanticsData()
              .hasFlag(SemanticsFlag.isExpanded),
          isTrue);
      expect(_find(tester, (d) => d.label == 'Figlio'), isNotNull);
      handle.dispose();
    });

    testWidgets('an always-expanded group stays a link and shows its children',
        (tester) async {
      final handle = tester.ensureSemantics();
      var tapped = false;
      await tester.pumpWidget(_host(
        ItList(items: [
          ItListItem(
            title: 'Gruppo',
            onTap: () => tapped = true,
            children: const [ItListItem(title: 'Figlio')],
          ),
        ]),
      ));

      final data =
          _find(tester, (d) => d.label == 'Gruppo')!.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isLink), isTrue,
          reason: 'the docs\' "Espansa" form navigates; only "Collassabile" '
              'discloses');
      expect(data.hasFlag(SemanticsFlag.hasExpandedState), isFalse,
          reason: 'nothing can be expanded or collapsed, so claiming the state '
              'would promise a control that is not there');
      expect(_find(tester, (d) => d.label == 'Figlio'), isNotNull);

      await tester.tap(find.text('Gruppo'));
      expect(tapped, isTrue);
      handle.dispose();
    });

    testWidgets('a form control in a row keeps its own role', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItList(showDividers: false, items: [
          ItListCustom(
            child: ItToggle(
              value: true,
              label: 'Notifiche',
              onChanged: (_) {},
            ),
          ),
        ]),
      ));

      final node = _find(tester, (d) => d.label.contains('Notifiche'))!;
      final data = node.getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isLink), isFalse,
          reason: 'a switch inside a list of links is still a switch; '
              'announcing it as a link says the wrong thing about what '
              'activating it does (§4.1.2)');
      expect(data.hasFlag(SemanticsFlag.hasToggledState), isTrue);
      handle.dispose();
    });
  });

  group('ItListItem — what the trailing widget says', () {
    // A `.link-list` item's badge sits *inside* the `<a>`, so it is part of the
    // link's name. The row named itself from `title` and then excluded its
    // whole subtree, which took the badge with it: a menu entry reading
    // "Messaggi" with a red "2" beside it announced as "Messaggi", and the one
    // thing the badge was there to say was the one thing not said.
    testWidgets('a badge that names itself joins the row name', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItList(items: [
          ItListItem(
            title: 'Messaggi',
            trailing: const ItBadge(
              variant: ItBadgeVariant.danger,
              pill: true,
              semanticLabel: '2 messaggi da leggere',
              child: Text('2'),
            ),
            onTap: () {},
          ),
        ]),
      ));

      final links = _findAll(tester, (d) => d.hasFlag(SemanticsFlag.isLink));
      expect(links, hasLength(1), reason: 'still one target, not two');
      final label = links.single.getSemanticsData().label;
      expect(label, contains('Messaggi'));
      expect(label, contains('2 messaggi da leggere'),
          reason: 'the badge is inside the link, so its name is part of the '
              "link's name (§1.3.1, §4.1.2)");
      expect(label.split('Messaggi').length - 1, 1,
          reason: 'the title must be named once, not repeated by the text '
              'node the row already speaks for');
      handle.dispose();
    });

    testWidgets('a decorative trailing icon adds nothing', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItList(items: [
          ItListItem(
            title: 'Impostazioni',
            subtitle: 'Notifiche e privacy',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ]),
      ));

      final link = _find(tester, (d) => d.hasFlag(SemanticsFlag.isLink))!;
      expect(link.getSemanticsData().label, 'Impostazioni. Notifiche e privacy',
          reason: 'a chevron says nothing about itself, so the name is the '
              'row\'s text and nothing else');
      handle.dispose();
    });
  });
}
