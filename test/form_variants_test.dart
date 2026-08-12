// The form variants added so the example app can show what the docs show.
//
// `.form-check-group`, `<optgroup>`, `textarea.form-control`,
// `.form-control-sm` / `-lg`, `.form-control-plaintext` and the `.semi-checked`
// fill. Every expectation below names the rule it is checking; where a value
// looks arbitrary it is because the stylesheet says so, and the comment is
// where to look.
//
// The semantics of the same variants are contracted separately, in
// `test/a11y/form_variants_semantics_test.dart`.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {BootstrapItaliaColorScheme? colors}) {
  final data = BootstrapItaliaThemeData(
      colors: colors ?? BootstrapItaliaColorScheme.standard);
  return BootstrapItaliaTheme(
    data: data,
    child: MaterialApp(
      theme: data.toThemeData(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 400, child: child),
        ),
      ),
    ),
  );
}

/// The 20x20 indicator box of a checkbox, found by the fill it was given.
Finder _boxWithFill(Color fill) => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == fill &&
          (w.decoration! as BoxDecoration).borderRadius != null,
    );

/// Pumps [child] and returns the assertion message it produced, or `''`.
Future<String> _assertionFrom(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(_host(child));
  final error = tester.takeException();
  return error == null ? '' : error.toString();
}

void main() {
  group('visuallyGrouped — `.form-check-group`', () {
    testWidgets('the checkbox moves to the right of its label', (t) async {
      // `.form-check.form-check-group [type=checkbox]+label
      //    { padding-left:0; padding-right:3.25rem }`
      // with `::after { right:0px; left:auto }`.
      await t.pumpWidget(_host(const Column(children: [
        ItCheckbox(value: false, label: 'A destra', visuallyGrouped: true),
      ])));

      final row = t.getRect(find.byType(ItCheckbox));
      final label = t.getRect(find.text('A destra'));
      final box = t.getRect(_boxWithFill(const Color(0x00000000)));
      expect(box.left, greaterThan(label.right),
          reason: 'the box parks in the 3.25rem gutter after the text');
      // 20px box with a 4px margin, anchored to the right of the row.
      expect(row.right - box.right, 4);
      expect(box.width, 20);
    });

    testWidgets('the default layout is untouched', (t) async {
      // The resting variant is what every parity capture measures, so the
      // refactor that made the indicator shareable must not have moved it.
      await t.pumpWidget(_host(const Column(children: [
        ItCheckbox(value: false, label: 'A sinistra'),
      ])));

      final row = t.getRect(find.byType(ItCheckbox));
      final box = t.getRect(_boxWithFill(const Color(0x00000000)));
      expect(box.left - row.left, 4,
          reason: '`::after { margin:4px; left:0 }`');
      expect(box.top - row.top, 4);
      expect(t.getRect(find.text('A sinistra')).left - row.left, 32,
          reason: '`+label { padding-left: 2rem }`');
    });

    testWidgets('the radio ring moves too, keeping its 5px margin', (t) async {
      await t.pumpWidget(_host(const Column(children: [
        ItRadio(value: false, label: 'A destra', visuallyGrouped: true),
      ])));

      final row = t.getRect(find.byType(ItRadio));
      final ring = t.getRect(find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).shape == BoxShape.circle,
      ));
      expect(row.right - ring.right, 5,
          reason: '`::before { margin:5px }` mirrored to `right:0`');
      expect(ring.width, 20);
    });

    testWidgets('each row gets the separator, the padding and the margin',
        (t) async {
      // `.form-check.form-check-group { padding:0 0 1rem 0; margin-bottom:1rem;
      //                                 box-shadow:inset 0 -1px 0 0 rgba(1,1,1,.1) }`
      await t.pumpWidget(_host(const Column(children: [
        ItCheckbox(value: false, label: 'Riga', visuallyGrouped: true),
      ])));

      final separator = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).border ==
                const Border(
                  bottom: BorderSide(color: Color(0x1A010101)),
                ),
      );
      expect(separator, findsOneWidget);

      // The 24px row, 16px of padding, the 1px rule, then 16px of margin.
      // `Container`'s margin is part of its own render object, so measuring it
      // here counts the whole 57 — the split between padding and margin is
      // what the stacked-rows test below pins down.
      expect(t.getSize(find.byType(ItCheckbox)).height, 24 + 16 + 1 + 16);
      expect(t.getRect(find.text('Riga')).top - t.getRect(separator).top, 0,
          reason: 'the padding is below the row, not above it');
    });

    testWidgets('a resting row has no separator at all', (t) async {
      await t.pumpWidget(_host(const Column(children: [
        ItCheckbox(value: false, label: 'Riga'),
      ])));
      expect(t.getSize(find.byType(ItCheckbox)).height, 24);
    });

    testWidgets('the toggle gains the chrome but keeps its row', (t) async {
      // `.form-check-group` moves the indicator right, and `.lever` already
      // floats right — so on a toggle only the box model changes.
      await t.pumpWidget(_host(const Column(children: [
        ItToggle(value: true, label: 'Acceso'),
      ])));
      final resting = t.getRect(find.text('Acceso'));

      await t.pumpWidget(_host(const Column(children: [
        ItToggle(value: true, label: 'Acceso', visuallyGrouped: true),
      ])));
      expect(t.getRect(find.text('Acceso')), resting,
          reason: 'the label must not shift: the sheet declares nothing for '
              'the toggle row inside `.form-check-group`');
      expect(t.getSize(find.byType(ItToggle)).height, 32 + 16 + 1 + 16);
    });

    testWidgets('a group applies it to every row and drops the 8px gap',
        (t) async {
      // `.form-check + .form-check { margin-top:.5rem }` must not stack on top
      // of the group's own 1rem margin.
      await t.pumpWidget(_host(ItCheckboxGroup<String>(
        label: 'Gruppo',
        visuallyGrouped: true,
        options: const [
          ItCheckboxOption(value: 'a', label: 'Prima'),
          ItCheckboxOption(value: 'b', label: 'Seconda'),
        ],
        values: const {},
        onChanged: (_) {},
      )));

      final first = t.getRect(find.text('Prima'));
      final second = t.getRect(find.text('Seconda'));
      expect(second.top - first.top, 24 + 16 + 1 + 16);
    });

    testWidgets('inline wins when both are set', (t) async {
      // `.form-check-inline` and `.form-check-group` are alternatives: a
      // full-width row with a right-hand indicator has nothing to sit beside.
      await t.pumpWidget(_host(ItCheckboxGroup<String>(
        label: 'Gruppo',
        inline: true,
        visuallyGrouped: true,
        options: const [
          ItCheckboxOption(value: 'a', label: 'Prima'),
          ItCheckboxOption(value: 'b', label: 'Seconda'),
        ],
        values: const {},
        onChanged: (_) {},
      )));

      // Laid out side by side, and with the box back on the left.
      final first = t.getRect(find.text('Prima'));
      final second = t.getRect(find.text('Seconda'));
      expect(second.left, greaterThan(first.right));
      expect(first.left, 32);
    });

    testWidgets('a per-option description takes the same right gutter',
        (t) async {
      // `.form-check.form-check-group .form-text
      //    { display:block; padding-right:3.25rem; margin-bottom:.5rem }`
      await t.pumpWidget(_host(ItCheckboxGroup<String>(
        label: 'Gruppo',
        visuallyGrouped: true,
        options: const [
          ItCheckboxOption(
            value: 'a',
            label: 'Prima',
            helperText: 'Descrizione',
          ),
        ],
        values: const {},
        onChanged: (_) {},
      )));

      final helper = t.getRect(find.text('Descrizione'));
      expect(helper.left, 0, reason: '`padding-left` is reset to 0');
      expect(helper.right, lessThanOrEqualTo(400 - 52));
      expect(helper.top, greaterThanOrEqualTo(24.0),
          reason: 'a block below the row, not beside it');
    });
  });

  group('semi-checked — `.primary-color-a5`, not `--bs-primary`', () {
    testWidgets('the indeterminate box is the ramp step', (t) async {
      // `.form-check input.semi-checked:not(:checked)+label::after
      //    { background-color: rgb(32.13,123.165,214.2) }`
      await t.pumpWidget(_host(const Column(children: [
        ItCheckbox(value: false, indeterminate: true, label: 'Misto'),
      ])));
      expect(_boxWithFill(const Color(0xFF207BD6)), findsOneWidget);
      expect(_boxWithFill(BootstrapItaliaColors.primary), findsNothing,
          reason: 'painting `primary` here made "some selected" and "all '
              'selected" the same colour');
    });

    testWidgets('the checked box IS the primary token', (t) async {
      await t.pumpWidget(_host(const Column(children: [
        ItCheckbox(value: true, label: 'Selezionato'),
      ])));
      expect(_boxWithFill(BootstrapItaliaColors.primary), findsOneWidget);
    });

    testWidgets('a retinted scheme moves the checked box, not the mixed one',
        (t) async {
      // The ramp value backs no `--bs-*` custom property, so it does not
      // re-theme; `:checked` carries `--bs-primary` itself, so it does.
      const purple = Color(0xFF7A1FA2);
      await t.pumpWidget(_host(
        const Column(children: [
          ItCheckbox(value: true, label: 'Selezionato'),
          ItCheckbox(value: false, indeterminate: true, label: 'Misto'),
        ]),
        colors: BootstrapItaliaColorScheme.standard.copyWith(primary: purple),
      ));
      expect(_boxWithFill(purple), findsOneWidget);
      expect(_boxWithFill(const Color(0xFF207BD6)), findsOneWidget);
    });

    testWidgets('the bar is centred in its box', (t) async {
      // `input.semi-checked:not(:checked)+label::before
      //    { top:11px; left:4px; width:12px; height:2px }` — plus the
      // `margin:2px 4px` of the base `::before`, which the semi-checked rule
      // resets the borders of but not the margin. (8, 13), not (4, 11).
      await t.pumpWidget(_host(const Column(children: [
        ItCheckbox(value: false, indeterminate: true, label: 'Misto'),
      ])));

      final box = t.getRect(_boxWithFill(const Color(0xFF207BD6)));
      final bar = t.getRect(find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 12 && w.height == 2,
      ));
      expect(bar.center.dx, box.center.dx);
      expect(bar.center.dy, box.center.dy);
    });
  });

  group('ItSelect — `<optgroup>`', () {
    testWidgets('a caption is printed once per run of options', (t) async {
      await t.pumpWidget(_host(ItSelect<String>(
        label: 'Etichetta',
        hint: "Scegli un'opzione",
        items: const [
          ItSelectItem(value: '1', label: 'Opzione 1', group: 'Gruppo 1'),
          ItSelectItem(value: '2', label: 'Opzione 2', group: 'Gruppo 1'),
          ItSelectItem(value: '3', label: 'Opzione 3', group: 'Gruppo 2'),
        ],
        onChanged: (_) {},
      )));

      await t.tap(find.text("Scegli un'opzione"));
      await t.pumpAndSettle();

      // `.dropdown-header .text { text-transform: uppercase }`
      expect(find.text('GRUPPO 1'), findsOneWidget);
      expect(find.text('GRUPPO 2'), findsOneWidget);
      expect(t.getRect(find.text('GRUPPO 1')).top,
          lessThan(t.getRect(find.text('Opzione 1')).top));
      expect(t.getRect(find.text('Opzione 2')).top,
          lessThan(t.getRect(find.text('GRUPPO 2')).top));
    });

    testWidgets('the keyboard cursor still walks options only', (t) async {
      // The list view's index counts captions; `_highlighted` must not.
      String? chosen;
      await t.pumpWidget(_host(ItSelect<String>(
        label: 'Etichetta',
        hint: "Scegli un'opzione",
        items: const [
          ItSelectItem(value: '1', label: 'Opzione 1', group: 'Gruppo 1'),
          ItSelectItem(value: '2', label: 'Opzione 2', group: 'Gruppo 2'),
        ],
        onChanged: (v) => chosen = v,
      )));

      await t.tap(find.text("Scegli un'opzione"));
      await t.pumpAndSettle();
      await t.tap(find.text('Opzione 2'));
      await t.pumpAndSettle();
      expect(chosen, '2');
    });

    testWidgets('a repeated group name prints its caption again', (t) async {
      // Same as `<optgroup>`: the caption follows document order, so scattered
      // options produce a scattered caption rather than being re-sorted behind
      // the caller's back.
      await t.pumpWidget(_host(ItSelect<String>(
        label: 'Etichetta',
        hint: "Scegli un'opzione",
        items: const [
          ItSelectItem(value: '1', label: 'Opzione 1', group: 'A'),
          ItSelectItem(value: '2', label: 'Opzione 2', group: 'B'),
          ItSelectItem(value: '3', label: 'Opzione 3', group: 'A'),
        ],
        onChanged: (_) {},
      )));

      await t.tap(find.text("Scegli un'opzione"));
      await t.pumpAndSettle();
      expect(find.text('A'), findsNWidgets(2));
    });
  });

  group('ItInput — `<textarea>`', () {
    testWidgets('a multiline field gets a box, not an underline', (t) async {
      // `textarea.form-control { border:1px solid hsl(210,17%,44%) }` against
      // `input[type=text] { border:none; border-bottom:1px solid … }`.
      await t.pumpWidget(_host(const ItInput(label: 'Note', maxLines: 3)));

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).border ==
                  Border.all(color: const Color(0xFF5D7083)),
        ),
        findsOneWidget,
      );
    });

    testWidgets('it grows past 2.5rem instead of squeezing the text',
        (t) async {
      // `textarea { height:auto }` with `min-height:2.5rem`. Before this a
      // four-line field was drawn in a 40px box.
      await t.pumpWidget(_host(const ItInput(label: 'Note', maxLines: 4)));
      expect(t.getSize(find.byType(ItInput)).height, greaterThan(40));
    });

    testWidgets('a single-line field is unchanged', (t) async {
      await t.pumpWidget(_host(const ItInput(label: 'Nome')));
      expect(t.getSize(find.byType(ItInput)).height, 40,
          reason: '`.form-control { min-height: 2.5rem }`');
    });
  });

  group('ItInput — `.form-control-sm` / `.form-control-lg`', () {
    testWidgets('the size changes the type and the minimum height', (t) async {
      for (final (size, fontSize, height) in <(ItInputSize, double, double)>[
        (ItInputSize.small, 14, 29),
        (ItInputSize.medium, 16, 40),
        (ItInputSize.large, 20, 46),
      ]) {
        await t.pumpWidget(_host(ItInput(label: 'Nome', size: size)));
        expect(t.getSize(find.byType(ItInput)).height, height,
            reason: 'min-height for $size');
        expect(t.widget<TextField>(find.byType(TextField)).style?.fontSize,
            fontSize,
            reason: 'font-size for $size');
      }
    });

    testWidgets('the padding follows the size only on a text area', (t) async {
      // `input[type=text] { padding:.375rem .5rem }` is (0,1,1) and outranks
      // the size class; `textarea` is (0,0,1) and loses to it.
      await t.pumpWidget(_host(const ItInput(
        label: 'Nome',
        size: ItInputSize.large,
      )));
      // The single-line field keeps its 8px gutter.
      expect(t.getRect(find.byType(TextField)).left, 8);

      await t.pumpWidget(_host(const ItInput(
        label: 'Note',
        maxLines: 3,
        size: ItInputSize.large,
      )));
      // `.form-control-lg { padding: .5rem 1rem }`, inside the 1px border.
      expect(t.getRect(find.byType(TextField)).left, 1 + 16);
    });
  });

  group('ItInput — `.form-control-plaintext`', () {
    testWidgets('it forces read-only', (t) async {
      await t.pumpWidget(_host(const ItInput(label: 'Nome', plaintext: true)));
      expect(t.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    });

    testWidgets('the box collapses onto its content', (t) async {
      // `.form-control-plaintext` declares no `min-height`, which is the one
      // thing about it that survives the cascade in this build.
      await t.pumpWidget(_host(const ItInput(label: 'Nome', plaintext: true)));
      expect(t.getSize(find.byType(ItInput)).height, 24 + 6 + 6 + 1);
    });

    testWidgets('the underline survives, as it does on the kit', (t) async {
      // `input[type=text] { border-bottom:1px solid hsl(210,17%,44%) }` is
      // (0,1,1) and beats `.form-control-plaintext { border-width:0 0 }`.
      await t.pumpWidget(_host(const ItInput(label: 'Nome', plaintext: true)));
      expect(
        find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == const Color(0xFF5D7083),
        ),
        findsOneWidget,
      );
    });
  });

  group('ItToggleGroup — misuse is caught in debug', () {
    // The same three checks the other two groups carry, through the shared
    // `ItFieldValidation.debugCheckConfig`. A new group widget that forgot to
    // call it would be silently exempt from all of them.
    testWidgets('required with no legend', (t) async {
      final msg = await _assertionFrom(
        t,
        const ItToggleGroup<String>(
          required: true,
          options: [ItToggleOption(value: 'a', label: 'A')],
          values: {},
        ),
      );
      expect(msg, contains('no label'));
      expect(msg, contains('ItToggleGroup'));
    });

    testWidgets('no options at all', (t) async {
      final msg = await _assertionFrom(
        t,
        const ItToggleGroup<String>(
          label: 'Gruppo',
          options: [],
          values: {},
        ),
      );
      expect(msg, contains('no options'));
    });

    testWidgets('duplicate option values', (t) async {
      final msg = await _assertionFrom(
        t,
        const ItToggleGroup<String>(
          label: 'Gruppo',
          options: [
            ItToggleOption(value: 'a', label: 'Primo'),
            ItToggleOption(value: 'a', label: 'Secondo'),
          ],
          values: {},
        ),
      );
      expect(msg, contains('duplicate option values'));
    });

    testWidgets('a valid configuration asserts nothing', (t) async {
      expect(
        await _assertionFrom(
          t,
          const ItToggleGroup<String>(
            label: 'Gruppo',
            required: true,
            options: [
              ItToggleOption(value: 'a', label: 'Primo'),
              ItToggleOption(value: 'b', label: 'Secondo'),
            ],
            values: {'a'},
          ),
        ),
        '',
      );
    });
  });

  group('ItInput — a text area has nowhere to put an .input-group', () {
    testWidgets('an icon on a multiline field is rejected', (t) async {
      final msg = await _assertionFrom(
        t,
        const ItInput(label: 'Note', maxLines: 3, icon: Icons.edit),
      );
      expect(msg, contains('multi-line'));
    });

    testWidgets('an icon on a single-line field is fine', (t) async {
      expect(
        await _assertionFrom(t, const ItInput(label: 'Nome', icon: Icons.edit)),
        '',
      );
    });
  });
}
