import 'dart:io';

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_helpers.dart';

const _outDir = 'tool/visual_parity/flutter_captures';

/// The shared `test/flutter_test_config.dart` only registers the package's
/// text fonts. The overlay components draw Bootstrap Italia icon glyphs
/// (close button, notification status icons), so register that font family
/// here too — otherwise every icon renders as a missing-glyph box.
Future<void> _loadIconFont() async {
  final packageConfig =
      File('.dart_tool/package_config.json').readAsStringSync();
  final match = RegExp(
    r'"name"\s*:\s*"bootstrap_italia_icons"\s*,\s*"rootUri"\s*:\s*"([^"]+)"',
  ).firstMatch(packageConfig);
  if (match == null) return;

  var root = match.group(1)!;
  if (root.startsWith('file://')) root = Uri.parse(root).toFilePath();
  final fontFile = File('$root/fonts/BootstrapItaliaIcons.ttf');
  if (!fontFile.existsSync()) return;

  final bytes = ByteData.sublistView(
    Uint8List.fromList(await fontFile.readAsBytes()),
  );
  for (final family in [
    'BootstrapItaliaIcons',
    'packages/bootstrap_italia_icons/BootstrapItaliaIcons',
  ]) {
    final loader = FontLoader(family)..addFont(Future.value(bytes));
    await loader.load();
  }
}

void main() {
  setUpAll(_loadIconFont);

  // ── Notification ────────────────────────────────────────────────
  // Reference: "Notification With Message Static" and "States" stories.

  const notificationTitle = 'Titolo Notifica';
  const notificationMessage =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
      'sed do eiusmod tempor…';

  testWidgets('capture: notification_standard', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/notification_standard.png',
      child: const ItNotification(
        title: notificationTitle,
        body: notificationMessage,
      ),
    );
  });

  testWidgets('capture: notification_success', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/notification_success.png',
      child: const ItNotification(
        variant: ItNotificationVariant.success,
        icon: BootstrapItaliaIcons.it_check_circle,
        title: notificationTitle,
        body: notificationMessage,
      ),
    );
  });

  testWidgets('capture: notification_error', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/notification_error.png',
      child: const ItNotification(
        variant: ItNotificationVariant.danger,
        icon: BootstrapItaliaIcons.it_close_circle,
        title: notificationTitle,
      ),
    );
  });

  testWidgets('capture: notification_info', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/notification_info.png',
      child: const ItNotification(
        icon: BootstrapItaliaIcons.it_info_circle,
        title: notificationTitle,
      ),
    );
  });

  testWidgets('capture: notification_warning', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/notification_warning.png',
      child: const ItNotification(
        variant: ItNotificationVariant.warning,
        icon: BootstrapItaliaIcons.it_error,
        title: notificationTitle,
      ),
    );
  });

  // ── Dropdown ────────────────────────────────────────────────────
  // Reference: the "docs-show-dropdown-open" stories, whose `.dropdown-menu`
  // is 300px wide at a 332px viewport.

  const menuWidth = 300.0;

  testWidgets('capture: dropdown_menu_headers', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/dropdown_menu_headers.png',
      child: const ItDropdownMenu(
        width: menuWidth,
        items: [
          ItDropdownHeader(label: 'Header'),
          ItDropdownItem(label: 'Azione 1'),
          ItDropdownItem(label: 'Azione 2'),
          ItDropdownItem(label: 'Azione 3'),
          ItDropdownDivider(),
          ItDropdownItem(label: 'Azione 4'),
        ],
      ),
    );
  });

  testWidgets('capture: dropdown_menu_icons', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/dropdown_menu_icons.png',
      child: const ItDropdownMenu(
        width: menuWidth,
        items: [
          ItDropdownItem(
            label: 'Azione 1',
            icon: BootstrapItaliaIcons.it_info_circle,
          ),
          ItDropdownItem(
            label: 'Azione 2',
            icon: BootstrapItaliaIcons.it_info_circle,
          ),
          ItDropdownItem(
            label: 'Azione 3',
            icon: BootstrapItaliaIcons.it_info_circle,
          ),
        ],
      ),
    );
  });

  testWidgets('capture: dropdown_menu_disabled', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/dropdown_menu_disabled.png',
      child: const ItDropdownMenu(
        width: menuWidth,
        items: [
          ItDropdownItem(label: 'Azione 1'),
          ItDropdownItem(label: 'Azione 2', disabled: true),
          ItDropdownItem(label: 'Azione 3'),
        ],
      ),
    );
  });

  testWidgets('capture: dropdown_menu_active', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/dropdown_menu_active.png',
      child: const ItDropdownMenu(
        width: menuWidth,
        items: [
          ItDropdownItem(label: 'Azione 1', active: true),
          ItDropdownItem(label: 'Azione 2'),
          ItDropdownItem(label: 'Azione 3'),
        ],
      ),
    );
  });

  // ── Modal ───────────────────────────────────────────────────────
  // Reference: the "Modale" stories, captured with the dialog open.

  testWidgets('capture: modal_base', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/modal_base.png',
      child: ItModal(
        title: 'Titolo della modale',
        body: const Text('Woohoo, stai leggendo questo testo in una modale!'),
        actions: [
          ItButton(onPressed: () {}, child: const Text('Salva modifiche')),
        ],
      ),
    );
  });

  testWidgets('capture: modal_close_button', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/modal_close_button.png',
      child: ItModal(
        title: 'Titolo della modale',
        body: const Text('Woohoo, stai leggendo questo testo in una modale!'),
        actions: [
          ItButton(
            variant: ItButtonVariant.secondary,
            onPressed: () {},
            child: const Text('Chiudi'),
          ),
          ItButton(onPressed: () {}, child: const Text('Salva modifiche')),
        ],
      ),
    );
  });

  testWidgets('capture: modal_icon', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/modal_icon.png',
      child: ItModal(
        dismissible: false,
        icon: BootstrapItaliaIcons.it_info_circle,
        title: 'This is a notification message more long than usual',
        body: const Text(
          'In the various types of information modal dialog, only one '
          'button to close dialog is provided.',
        ),
        actions: [
          ItButton(onPressed: () {}, child: const Text('Ok')),
        ],
      ),
    );
  });
}
