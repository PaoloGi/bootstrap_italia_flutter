// Accessibility contracts for the controls added while mirroring the official
// docs pages for Alert, Badge, Button, Callout, Card and Chip.
//
// Every new *interactive* variant needs role, name, state and keyboard, and the
// reason is on record in this repository: a pixel-parity pass once replaced
// working controls with hand-painted ones and destroyed their semantics
// wholesale, and axe-core passed the broken control. Only Dart contracts like
// these caught it. So a variant that merely repaints is checked in
// `test/docs_parity_variants_test.dart`; a variant that can be operated is
// checked here.
//
// Three of these are genuinely new controls rather than restyled ones:
// `ItAlertLink` (`.alert-link`), a linked `ItBadge` (`<a class="badge">`), and
// the «Leggi tutto» toggle of a `.callout-more`.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
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

/// Tabs until [finder]'s control holds focus, or gives up after [limit] hops.
Future<void> _tabTo(WidgetTester tester, Finder finder, {int limit = 8}) async {
  for (var i = 0; i < limit; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final node = tester
        .widgetList<Focus>(
            find.descendant(of: finder, matching: find.byType(Focus)))
        .where((f) => f.focusNode?.hasPrimaryFocus ?? false);
    if (node.isNotEmpty) return;
    if (FocusManager.instance.primaryFocus?.hasPrimaryFocus ?? false) {
      // The focused node is somewhere; whether it is *ours* is what the
      // caller's own assertion decides.
      final ctx = FocusManager.instance.primaryFocus?.context;
      if (ctx != null && find.byWidget(ctx.widget).evaluate().isNotEmpty) {
        if (finder.evaluate().any((e) => _isAncestor(e, ctx))) return;
      }
    }
  }
}

bool _isAncestor(Element ancestor, BuildContext descendant) {
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

void main() {
  group('ItAlertLink — `.alert-link`', () {
    testWidgets('§4.1.2: announces as a link, by its own text', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItAlert(body: ItAlertLink(label: 'documento', onPressed: () {})),
      ));

      final data =
          tester.getSemantics(find.text('documento')).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isLink), isTrue,
          reason:
              'the docs write it as `<a class="alert-link">`; a span with a '
              'tap recogniser would announce as nothing at all');
      expect(data.label, 'documento');
      handle.dispose();
    });

    testWidgets('§2.4.4: semanticLabel names a link whose text does not',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItAlert(
          body: ItAlertLink(
            label: 'link',
            semanticLabel: 'Leggi la circolare 12/2025',
            onPressed: () {},
          ),
        ),
      ));
      expect(
          find.bySemanticsLabel('Leggi la circolare 12/2025'), findsOneWidget,
          reason: '«link» read out of context tells a screen-reader user '
              'nothing about where it goes');
      // The visible text is unchanged — this renames, it does not relabel.
      expect(find.text('link'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('§2.1.1: is operable from the keyboard', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(
        ItAlert(body: ItAlertLink(label: 'documento', onPressed: () => taps++)),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(taps, 1,
          reason: 'this is the whole reason ItAlertLink is a widget and not a '
              'TextStyle: an inline TextSpan recogniser is pointer-only');
    });

    testWidgets('§2.4.3: a link with no callback is skipped by traversal',
        (tester) async {
      await tester.pumpWidget(_host(
        const ItAlert(body: ItAlertLink(label: 'documento')),
      ));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('ItBadge as a link — `<a class="badge">`', () {
    testWidgets('§4.1.2: link role, name and tap action', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(_host(
        ItBadge(onTap: () => taps++, child: const Text('Bandi')),
      ));

      final data = tester.getSemantics(find.text('Bandi')).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isLink), isTrue);
      expect(data.label, 'Bandi');
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(taps, 1, reason: '§2.1.1');
      handle.dispose();
    });

    testWidgets('§4.1.2: an unlinked badge is content, with no role',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const ItBadge(child: Text('Bandi'))));
      final data = tester.getSemantics(find.text('Bandi')).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isLink), isFalse);
      expect(data.hasFlag(SemanticsFlag.isButton), isFalse,
          reason: 'a badge that does nothing must not claim to');
      handle.dispose();
    });

    testWidgets('§4.1.2: semanticLabel replaces the stray number',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItBadge(semanticLabel: '9 messaggi non letti', child: Text('9')),
      ));
      final data = tester
          .getSemantics(find.bySemanticsLabel('9 messaggi non letti'))
          .getSemanticsData();
      expect(data.label, '9 messaggi non letti',
          reason: 'not «9, 9 messaggi non letti» — the hidden text stands in '
              'place of the digit, as `.visually-hidden` does in the docs');
      handle.dispose();
    });
  });

  group('ItButton — the new renderings keep the button contract', () {
    for (final entry in <String, ItButton>{
      'link': ItButton(link: true, onPressed: _noop, child: const Text('Vai')),
      'onDark':
          ItButton(onDark: true, onPressed: _noop, child: const Text('Vai')),
      'onDark + outline': ItButton(
        onDark: true,
        outline: true,
        onPressed: _noop,
        child: const Text('Vai'),
      ),
      'roundedIcon': ItButton(
        icon: BootstrapItaliaIcons.it_user,
        roundedIcon: true,
        onPressed: _noop,
        child: const Text('Vai'),
      ),
    }.entries) {
      testWidgets('§4.1.2 / §2.1.1: ${entry.key}', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_host(entry.value));

        final data = tester.getSemantics(find.text('Vai')).getSemanticsData();
        expect(data.hasFlag(SemanticsFlag.isButton), isTrue,
            reason: '`.btn-link` still renders a `<button>`; only the paint '
                'changes');
        expect(data.label, 'Vai',
            reason: 'the .rounded-icon disc is decoration — the label must not '
                'pick up the glyph');
        expect(data.hasAction(SemanticsAction.tap), isTrue);
        expect(data.hasFlag(SemanticsFlag.isEnabled), isTrue);
        handle.dispose();
      });
    }

    testWidgets('§2.5.8: a link button keeps the full 48px target',
        (tester) async {
      // `.btn-link` drops the fill but not `.btn`'s `padding: 12px 24px`, so it
      // is a control-sized target and not a run of text. Losing that would be a
      // silent Target Size regression.
      await tester.pumpWidget(_host(
        ItButton(link: true, onPressed: _noop, child: const Text('Vai')),
      ));
      expect(tester.getSize(find.byType(ItButton)).height,
          greaterThanOrEqualTo(24));
    });

    testWidgets('§4.1.2: a disabled link button reports disabled',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        const ItButton(link: true, disabled: true, child: Text('Vai')),
      ));
      expect(
        tester
            .getSemantics(find.text('Vai'))
            .getSemanticsData()
            .hasFlag(SemanticsFlag.isEnabled),
        isFalse,
      );
      handle.dispose();
    });
  });

  group('ItCallout «Leggi tutto» — the .callout-more disclosure', () {
    testWidgets('§4.1.2: button role, name and expanded state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const SizedBox(
        width: 600,
        child: ItCallout(
          style: ItCalloutStyle.more,
          title: 'Approfondimento',
          body: Text('Testo'),
          moreContent: Text('Il resto'),
        ),
      )));

      var data =
          tester.getSemantics(find.text('Leggi tutto')).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(data.label, 'Leggi tutto');
      expect(data.hasFlag(SemanticsFlag.hasExpandedState), isTrue,
          reason: 'the docs put `aria-expanded` on this very button');
      expect(data.hasFlag(SemanticsFlag.isExpanded), isFalse);

      await tester.tap(find.text('Leggi tutto'));
      await tester.pumpAndSettle();
      data = tester.getSemantics(find.text('Leggi tutto')).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isExpanded), isTrue,
          reason: 'without this the control looks identical to AT whether it '
              'is open or shut');
      handle.dispose();
    });

    testWidgets('§2.1.1: the toggle answers the keyboard', (tester) async {
      await tester.pumpWidget(_host(const SizedBox(
        width: 600,
        child: ItCallout(
          style: ItCalloutStyle.more,
          title: 'Approfondimento',
          body: Text('Testo'),
          moreContent: Text('Il resto'),
        ),
      )));

      await _tabTo(tester, find.text('Leggi tutto'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(
        tester
            .getSemantics(find.text('Leggi tutto'))
            .getSemanticsData()
            .hasFlag(SemanticsFlag.isExpanded),
        isTrue,
      );
    });

    testWidgets('§2.4.4: the download link announces as a link, by its name',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(SizedBox(
        width: 600,
        child: ItCallout(
          style: ItCalloutStyle.more,
          title: 'Approfondimento',
          body: const Text('Testo'),
          moreContent: const Text('Il resto'),
          downloadLabel: 'Scarica la scheda in PDF, 200Kb',
          onDownload: () {},
        ),
      )));

      final data = tester
          .getSemantics(find.text('Scarica la scheda in PDF, 200Kb'))
          .getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isLink), isTrue);
      expect(data.label, 'Scarica la scheda in PDF, 200Kb',
          reason:
              'the docs prefix the visible «Download» with a hidden format; '
              'the equivalent here is naming the format in the label itself');
      handle.dispose();
    });
  });

  group('ItCard — the title is a heading', () {
    testWidgets('§1.3.1: heading role and level reach AT', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const SizedBox(
        width: 400,
        child: ItCard(
          title: 'Titolo del contenuto',
          titleHeadingLevel: 4,
          body: Text('Testo'),
        ),
      )));

      final data = tester
          .getSemantics(find.text('Titolo del contenuto'))
          .getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isHeader), isTrue,
          reason: '«Accessibilità titoli» and «Gerarchia dei titoli» both say '
              'a card title is a heading in the page outline; before this it '
              'was plain text, so a page of cards had no outline at all');
      expect(data.headingLevel, 4);
      handle.dispose();
    });

    testWidgets('§4.1.2: a tappable card is still ONE control, named once',
        (tester) async {
      // The heading semantics must not fragment the single-control contract the
      // tappable card already had.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(SizedBox(
        width: 400,
        child: ItCard(
          title: 'Titolo del contenuto',
          titleIcon: BootstrapItaliaIcons.it_video,
          body: const Text('Testo'),
          onTap: () {},
        ),
      )));

      final data = tester.getSemantics(find.byType(ItCard)).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(data.label, 'Titolo del contenuto',
          reason: 'the title icon is decoration and must not join the name');
      handle.dispose();
    });
  });

  group('ItChip — colour variants change nothing about what is announced', () {
    testWidgets('§4.1.2: a coloured chip keeps role, name and enabled state',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItChip(
          label: 'Lazio',
          variant: ItChipVariant.primary,
          onTap: () {},
        ),
      ));
      final data = tester
          .getSemantics(find.bySemanticsLabel('Lazio'))
          .getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(data.label, 'Lazio');
      expect(data.hasFlag(SemanticsFlag.isEnabled), isTrue);
      handle.dispose();
    });

    testWidgets('§4.1.2: an avatar in `leading` does not become the name',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItChip(
          label: 'Mario Rossi',
          leading: const ColoredBox(color: Color(0xFF123456)),
          dismissible: true,
          onDismiss: () {},
        ),
      ));
      expect(find.bySemanticsLabel('Mario Rossi'), findsOneWidget);
      // And the dismiss control is still its own node, named for what it
      // removes rather than announced as a bare "button".
      expect(find.bySemanticsLabel('Rimuovi Mario Rossi'), findsOneWidget);
      handle.dispose();
    });
  });
}

void _noop() {}
