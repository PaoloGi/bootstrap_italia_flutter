// `groupMargin: false` throughout, and it is not a workaround.
//
// The reference is a Playwright **element screenshot** of `.form-group`, and an
// element's bounding box excludes its own margin by definition — no reference
// capture can ever contain `margin-bottom: 3rem`. Rendering the Flutter side
// with the margin therefore compares a 48px-taller image against one that
// physically cannot have it: parity fell 73/74 to 62/74, every loss an input,
// select or autocomplete.
//
// The margin is covered instead by test/a11y/readonly_and_overlap_test.dart,
// which is about the relationship BETWEEN two fields — something a
// single-element screenshot cannot express either.
import 'dart:convert';
import 'dart:io';

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_helpers.dart';

const _outDir = 'tool/visual_parity/flutter_captures';

/// Width of the `.form-group` / `.select-wrapper` in the captured stories
/// (400px viewport minus the 16px body padding on each side).
const double _fieldWidth = 368;

void main() {
  setUpAll(_loadIconFont);

  // ── Input ─────────────────────────────────────────────────────────

  testWidgets('capture: input_default', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/input_default.png',
      child: const SizedBox(
        width: _fieldWidth,
        child: ItInput(groupMargin: false, label: 'Etichetta di esempio'),
      ),
    );
  });

  // The four `.form-group` states of the "Utilizzo di placeholder e label"
  // story, laid out with the same 3rem gap the stylesheet applies.
  testWidgets('capture: input_states', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/input_states.png',
      child: const SizedBox(
        width: _fieldWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ItInput(groupMargin: false, label: 'Etichetta di esempio'),
            SizedBox(height: 48),
            ItInput(
                groupMargin: false,
                label: 'Etichetta di esempio',
                hint: 'Testo di esempio'),
            SizedBox(height: 48),
            ItInput(
              groupMargin: false,
              label: 'Etichetta di esempio',
              hint: 'Testo di esempio',
              helperText: 'Ulteriore testo informativo',
            ),
            SizedBox(height: 48),
            ItInput(
              groupMargin: false,
              label: 'Etichetta di esempio',
              hint: 'Testo di esempio',
              errorText: 'Campo non valido',
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('capture: input_disabled', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/input_disabled.png',
      child: const SizedBox(
        width: _fieldWidth,
        child: ItInput(
            groupMargin: false,
            label: 'Contenuto disabilitato',
            enabled: false),
      ),
    );
  });

  testWidgets('capture: input_password', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/input_password.png',
      child: const SizedBox(
        width: _fieldWidth,
        child: ItInput(
          groupMargin: false,
          label: 'Password con label, placeholder e testo di aiuto',
          obscureText: true,
          showPasswordToggle: true,
          helperText: 'Inserisci almeno 8 caratteri e una lettera maiuscola',
        ),
      ),
    );
  });

  testWidgets('capture: input_invalid', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/input_invalid.png',
      child: const SizedBox(
        width: _fieldWidth,
        child: ItInput(
          groupMargin: false,
          label: 'Username',
          errorText: 'Please choose a username.',
        ),
      ),
    );
  });

  // Filled + valid: the label floats out of the control's box (exactly as it
  // does on the web, where the `.form-group` screenshot clips it away).
  testWidgets('capture: input_filled_valid', (tester) async {
    final controller = TextEditingController(text: 'Mario');
    addTearDown(controller.dispose);
    await captureWidget(
      tester,
      outputPath: '$_outDir/input_filled_valid.png',
      child: SizedBox(
        width: _fieldWidth,
        child: ItInput(
          groupMargin: false,
          label: 'First name',
          controller: controller,
          validationState: ItValidationState.success,
        ),
      ),
    );
  });

  testWidgets('capture: input_icon', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/input_icon.png',
      child: const SizedBox(
        width: _fieldWidth,
        child: ItInput(
          groupMargin: false,
          label: 'Campo di tipo testuale',
          icon: BootstrapItaliaIcons.it_pencil,
        ),
      ),
    );
  });

  testWidgets('capture: input_button', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/input_button.png',
      child: SizedBox(
        width: _fieldWidth,
        child: ItInput(
          groupMargin: false,
          label: 'Con etichetta e bottone di tipo primary',
          icon: BootstrapItaliaIcons.it_pencil,
          trailingAction:
              ItButton(onPressed: () {}, child: const Text('Invio')),
        ),
      ),
    );
  });

  // ── Checkbox ──────────────────────────────────────────────────────

  testWidgets('capture: checkbox_unchecked', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/checkbox_unchecked.png',
      child: const ItCheckbox(value: false, label: 'Checkbox di esempio'),
    );
  });

  testWidgets('capture: checkbox_checked', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/checkbox_checked.png',
      child: const ItCheckbox(value: true, label: 'Checkbox selezionato'),
    );
  });

  testWidgets('capture: checkbox_disabled_unchecked', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/checkbox_disabled_unchecked.png',
      child: const ItCheckbox(
        value: false,
        enabled: false,
        label: 'Checkbox disabilitato non selezionato',
      ),
    );
  });

  testWidgets('capture: checkbox_disabled_checked', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/checkbox_disabled_checked.png',
      child: const ItCheckbox(
        value: true,
        enabled: false,
        label: 'Checkbox disabilitato selezionato',
      ),
    );
  });

  // ── Radio ─────────────────────────────────────────────────────────

  testWidgets('capture: radio_checked', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/radio_checked.png',
      child: const ItRadio<int>(
          value: 1, groupValue: 1, label: 'Radio di esempio 1'),
    );
  });

  testWidgets('capture: radio_unchecked', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/radio_unchecked.png',
      child: const ItRadio<int>(
          value: 1, groupValue: 0, label: 'Radio di esempio 2'),
    );
  });

  testWidgets('capture: radio_disabled_checked', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/radio_disabled_checked.png',
      child: const ItRadio<int>(
        value: 1,
        groupValue: 1,
        enabled: false,
        label: 'Opzione disabilitata selezionata',
      ),
    );
  });

  testWidgets('capture: radio_disabled_unchecked', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/radio_disabled_unchecked.png',
      child: const ItRadio<int>(
        value: 1,
        groupValue: 0,
        enabled: false,
        label: 'Opzione disabilitata non selezionata',
      ),
    );
  });

  // ── Toggle ────────────────────────────────────────────────────────

  testWidgets('capture: toggle_off', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/toggle_off.png',
      child: const SizedBox(
        width: _fieldWidth,
        child: ItToggle(value: false, label: "Label dell'interruttore 1"),
      ),
    );
  });

  testWidgets('capture: toggle_on', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/toggle_on.png',
      child: const SizedBox(
        width: 248,
        child: ItToggle(value: true, label: 'Toggle acceso'),
      ),
    );
  });

  testWidgets('capture: toggle_disabled', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/toggle_disabled.png',
      child: const SizedBox(
        width: _fieldWidth,
        child: ItToggle(
          value: false,
          enabled: false,
          label: "Label dell'interruttore 1",
        ),
      ),
    );
  });

  // ── Select ────────────────────────────────────────────────────────

  testWidgets('capture: select_default', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/select_default.png',
      child: const SizedBox(
        width: _fieldWidth,
        child: ItSelect<String>(
          groupMargin: false,
          label: 'Etichetta di esempio',
          hint: "Scegli un'opzione",
          items: _selectItems,
        ),
      ),
    );
  });

  testWidgets('capture: select_disabled', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/select_disabled.png',
      child: const SizedBox(
        width: _fieldWidth,
        child: ItSelect<String>(
          groupMargin: false,
          label: 'Etichetta di esempio',
          hint: "Scegli un'opzione",
          items: _selectItems,
          enabled: false,
        ),
      ),
    );
  });

  // ── Autocomplete ──────────────────────────────────────────────────

  testWidgets('capture: autocomplete_default', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/autocomplete_default.png',
      child: SizedBox(
        width: _fieldWidth,
        child: ItAutocomplete<String>(
          groupMargin: false,
          label: 'Regione',
          onSearch: (query) async => const <String>[],
          displayStringForOption: (option) => option,
        ),
      ),
    );
  });
}

const _selectItems = <ItSelectItem<String>>[
  ItSelectItem(value: 'v1', label: 'Lorem ipsum dolor sit amet'),
  ItSelectItem(value: 'v2', label: 'Duis vestibulum eleifend libero'),
];

/// The package's own icon font is not registered by `flutter_test_config.dart`
/// (which only loads the text families), so glyph-based icons would render as
/// blank boxes in golden captures. Register it here from the resolved package
/// location.
Future<void> _loadIconFont() async {
  final config = File('.dart_tool/package_config.json');
  if (!config.existsSync()) return;
  final packages =
      (jsonDecode(config.readAsStringSync()) as Map)['packages'] as List;
  final entry = packages.cast<Map<String, dynamic>>().firstWhere(
        (p) => p['name'] == 'bootstrap_italia_icons',
        orElse: () => <String, dynamic>{},
      );
  final rootUri = entry['rootUri'] as String?;
  if (rootUri == null) return;

  // Hosted packages record an absolute file:// URI; path packages record a
  // URI relative to `.dart_tool/`.
  final root = config.parent.uri.resolve('$rootUri/');
  final ttf = File.fromUri(root.resolve('fonts/BootstrapItaliaIcons.ttf'));
  if (!ttf.existsSync()) return;

  final bytes = ByteData.sublistView(Uint8List.fromList(ttf.readAsBytesSync()));
  for (final family in [
    'BootstrapItaliaIcons',
    'packages/bootstrap_italia_icons/BootstrapItaliaIcons',
  ]) {
    final loader = FontLoader(family)..addFont(Future.value(bytes));
    await loader.load();
  }
}
