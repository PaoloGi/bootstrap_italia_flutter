// `.popconfirm-modal`, `.modal-dialog-left` / `-right`, `.modal-footer-shadow`
// and the `.fade`-less modal.
//
// All four come from the Bootstrap Italia docs page for Finestre modali, which
// the example app mirrors. None existed here before.
//
// The dialog's accessibility contract — the dialog role, the name, the focus
// trap, Escape — is asserted in `test/a11y/semantics_contract_test.dart` and is
// deliberately not re-asserted here. What this file guards is that none of the
// new variants *removes* it, which is a different claim and is checked at the
// bottom.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a host and returns a context that can push a dialog.
Future<BuildContext> _host(WidgetTester tester) async {
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
  return ctx;
}

/// The panel's own box — the `Container` that carries `.modal-content`'s fill.
Container _panel(WidgetTester tester) => tester.widget<Container>(
      find
          .ancestor(of: find.byType(Column), matching: find.byType(Container))
          .last,
    );

Rect _panelRect(WidgetTester tester) =>
    tester.getRect(find.byType(ItModal).first);

void main() {
  group('popconfirm — `.modal.popconfirm-modal`', () {
    testWidgets('it caps at 300px whatever size asks for', (t) async {
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        popconfirm: true,
        // Deliberately the widest preset: `max-width: 300px` is stated on
        // `.modal-dialog` itself, so it has to win over `--bs-modal-width`.
        size: ItModalSize.extraLarge,
        body: const Text('Font Titillium 14px. Leading 21px.'),
        actions: [const SizedBox.shrink()],
      );
      await t.pumpAndSettle();

      expect(_panelRect(t).width, 300);
    });

    testWidgets('the message drops to 1rem', (t) async {
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        popconfirm: true,
        body: const Text('Messaggio'),
        actions: [const SizedBox.shrink()],
      );
      await t.pumpAndSettle();

      final style = DefaultTextStyle.of(
        t.element(find.text('Messaggio')),
      ).style;
      expect(style.fontSize, 16,
          reason: '`@media (min-width: 576px) { .modal.popconfirm-modal … '
              '.modal-body p { font-size: 1rem } }`');
    });

    testWidgets('the panel rounds its corners', (t) async {
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        popconfirm: true,
        body: const Text('Messaggio'),
        actions: [const SizedBox.shrink()],
      );
      await t.pumpAndSettle();

      final decoration = _panel(t).decoration! as BoxDecoration;
      expect(decoration.borderRadius,
          BorderRadius.circular(BootstrapItaliaBorders.radius),
          reason: '`.popconfirm-modal … .modal-content { border-radius: 4px }` '
              '— the one modal design that is not square');
    });

    testWidgets('a plain modal stays square', (t) async {
      final ctx = await _host(t);
      ItModal.show(context: ctx, body: const Text('Messaggio'));
      await t.pumpAndSettle();

      final decoration = _panel(t).decoration! as BoxDecoration;
      expect(decoration.borderRadius, isNull,
          reason: 'additive: the default rendering the parity captures hold '
              'must not move');
    });

    testWidgets('the title is optional, and so is its header', (t) async {
      // *"Il titolo della modale è facoltativo, nel caso non fosse necessario è
      // sufficiente rimuovere l'intero elemento <div class="modal-header">"*.
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        popconfirm: true,
        dismissible: false,
        body: const Text('Messaggio'),
        actions: [
          ItButton(onPressed: () {}, child: const Text('Azione 1')),
        ],
      );
      await t.pumpAndSettle();

      expect(find.text('Azione 1'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('alignment — `.modal-dialog-left` / `.modal-dialog-right`', () {
    testWidgets('center and top are what `centered` always meant', (t) async {
      final ctx = await _host(t);
      ItModal.show(context: ctx, body: const Text('A'));
      await t.pumpAndSettle();
      final centred = _panelRect(t).center.dy;
      Navigator.of(ctx).pop();
      await t.pumpAndSettle();

      ItModal.show(context: ctx, centered: false, body: const Text('B'));
      await t.pumpAndSettle();
      final topped = _panelRect(t).center.dy;

      expect(topped, lessThan(centred));
    });

    testWidgets('left fills the height and hugs the left edge', (t) async {
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        alignment: ItModalAlignment.left,
        body: const Text('Messaggio'),
      );
      await t.pumpAndSettle();

      final rect = _panelRect(t);
      final screen = t.getSize(find.byType(MaterialApp));
      expect(rect.left, 0,
          reason: '`.modal-dialog-left { margin: 0 24px 0 0 }`');
      expect(rect.height, screen.height,
          reason: '`.modal-dialog-left .modal-content { height: 100vh }`');
    });

    testWidgets('right hugs the right edge', (t) async {
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        alignment: ItModalAlignment.right,
        body: const Text('Messaggio'),
      );
      await t.pumpAndSettle();

      final rect = _panelRect(t);
      final screen = t.getSize(find.byType(MaterialApp));
      expect(rect.right, screen.width,
          reason: '`.modal-dialog-right { margin: 0 0 0 24px; float: right }`');
      expect(rect.height, screen.height);
    });

    testWidgets('alignment supersedes centered', (t) async {
      // Two parameters that overlap is the sort of thing that drifts, so the
      // precedence is stated once here rather than only in a doc comment.
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        centered: true,
        alignment: ItModalAlignment.left,
        body: const Text('Messaggio'),
      );
      await t.pumpAndSettle();

      expect(_panelRect(t).left, 0);
    });
  });

  group('footerShadow — `.modal-footer.modal-footer-shadow`', () {
    Iterable<BoxShadow> _footerShadows(WidgetTester tester) => tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .expand((d) => d.boxShadow ?? const <BoxShadow>[])
        .where((s) => s.spreadRadius == 5);

    testWidgets('it paints only when asked for', (t) async {
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        scrollable: true,
        body: const Text('Messaggio'),
        actions: [ItButton(onPressed: () {}, child: const Text('Ok'))],
      );
      await t.pumpAndSettle();
      expect(_footerShadows(t), isEmpty);
      Navigator.of(ctx).pop();
      await t.pumpAndSettle();

      ItModal.show(
        context: ctx,
        scrollable: true,
        footerShadow: true,
        body: const Text('Messaggio'),
        actions: [ItButton(onPressed: () {}, child: const Text('Ok'))],
      );
      await t.pumpAndSettle();

      expect(_footerShadows(t), hasLength(1),
          reason: '`.modal-footer.modal-footer-shadow '
              '{ box-shadow: 0 15px 25px 5px rgba(0,0,0,.3) }`');
    });
  });

  group('animated — the `.fade`-less modal', () {
    // `pumpAndSettle` reports how many frames it had to pump, which is the one
    // measurement that distinguishes "appears" from "transitions in" without
    // reaching for a particular transition widget — and the route stacks
    // several, so picking one by type would be asserting an implementation
    // detail of ModalRoute rather than this variant.
    testWidgets('it arrives with nothing to settle', (t) async {
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        animated: false,
        title: 'Intestazione modale',
        body: const Text('Messaggio'),
      );
      await t.pump();
      expect(find.text('Intestazione modale'), findsOneWidget,
          reason: 'on screen after the first frame, not eased into place');

      expect(await t.pumpAndSettle(), 1,
          reason: '*"per avere modali che appaiono semplicemente senza '
              'dissolvenza, rimuovi la classe .fade"*');
    });

    testWidgets('the animated default still eases in', (t) async {
      final ctx = await _host(t);
      ItModal.show(context: ctx, body: const Text('Messaggio'));
      await t.pump();

      expect(await t.pumpAndSettle(), greaterThan(1),
          reason: '`.modal-dialog { transition: transform .3s ease-out }`');
    });
  });

  group('a11y: no variant drops the dialog contract', () {
    SemanticsData _route(WidgetTester tester) {
      SemanticsData? found;
      void walk(SemanticsNode node) {
        final data = node.getSemanticsData();
        if (data.hasFlag(SemanticsFlag.namesRoute)) found ??= data;
        node.visitChildren((c) {
          walk(c);
          return true;
        });
      }

      walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
      return found!;
    }

    testWidgets('4.1.2: a side sheet is still a named dialog', (t) async {
      final handle = t.ensureSemantics();
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        alignment: ItModalAlignment.right,
        title: 'Questo è un messaggio di notifica',
        body: const Text('Messaggio'),
      );
      await t.pumpAndSettle();

      final route = _route(t);
      expect(route.hasFlag(SemanticsFlag.scopesRoute), isTrue);
      expect(route.label, 'Questo è un messaggio di notifica');
      handle.dispose();
    });

    testWidgets('4.1.2: a titleless popconfirm still names its route',
        (t) async {
      // With no title there is nothing visible to name the dialog, which is the
      // case the docs cover with `aria-label="Modale popconfirm"`. The fallback
      // name comes from ItLocalizations, so it is translated rather than a
      // literal.
      final handle = t.ensureSemantics();
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        popconfirm: true,
        dismissible: false,
        body: const Text('Messaggio'),
        actions: [ItButton(onPressed: () {}, child: const Text('Azione 1'))],
      );
      await t.pumpAndSettle();

      expect(_route(t).label, ItLocalizations.italian.dialog);
      handle.dispose();
    });

    testWidgets('2.1.2: Escape still closes a side sheet', (t) async {
      final ctx = await _host(t);
      ItModal.show(
        context: ctx,
        alignment: ItModalAlignment.left,
        title: 'Intestazione modale',
        body: const Text('Messaggio'),
      );
      await t.pumpAndSettle();
      expect(find.text('Intestazione modale'), findsOneWidget);

      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.text('Intestazione modale'), findsNothing,
          reason: 'a dialog traps focus by design, so there must always be a '
              'keyboard way back out');
    });
  });
}
