// Standing guard: ADR 0001 — build on `flutter/widgets`, not Material.
//
// The analyzer cannot enforce this. `material.dart` re-exports the whole of
// `widgets.dart`, so a file that imports Material and uses nothing but `Widget`
// and `Container` is never reported as an unused import. Thirteen files were in
// exactly that state — including `it_activatable.dart`, whose own doc comment
// explains that it exists to get off Material.
//
// Why it matters beyond tidiness: an ambient `Material` silently supplies a
// font family and an ink overlay. Two real bugs in this package came from that
// — text rendered as tofu boxes once the enclosing `Material` was removed, and
// the visual-parity captures could not see it because they wrap every component
// in a `Material` of their own. Depending on Material without meaning to is how
// a component ends up correct only inside a `Scaffold`.
//
// So: importing `package:flutter/material.dart` is allowed, but only with a
// stated reason naming the symbol that requires it.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Files permitted to import Material, and the symbol that justifies it.
///
/// ADR 0001 keeps exactly one Material widget on purpose — `TextField`, because
/// reimplementing a text editor means reimplementing IME composition, selection
/// handles, autofill and the platform text-input channel, and getting any of
/// those wrong is a worse accessibility outcome than the visual cost.
const Map<String, String> _allowed = {
  'it_input.dart': 'TextField + InputDecoration — ADR 0001 keeps the text '
      'editor rather than reimplementing IME, selection and autofill.',
  'it_autocomplete.dart': 'TextField + InputDecoration, as it_input.',
  'it_select.dart': 'TextField + InputDecoration, as it_input.',
  'bootstrap_italia_theme_data.dart':
      'ThemeData/TextTheme/ColorScheme — this file IS the bridge to Material, '
          'so that an app embedding these components in a MaterialApp gets a '
          'coherent ambient theme. Importing Material here is its purpose.',
  // `it_modal.dart` is no longer here. It held the only genuine *behavioural*
  // Material dependency in the package — `MaterialLocalizations`, for the
  // barrier and dialog names — and that was a hidden ancestor requirement, not
  // a feature: `MaterialLocalizations.of` asserts. ADR 0002 replaced it with
  // `ItLocalizations`, which cannot assert and answers in Italian with no
  // delegate installed. `showGeneralDialog` was never the problem; it lives in
  // `flutter/widgets.dart`.

  // ── `Colors` only ────────────────────────────────────────────────────────
  // These reference `Colors.white` and nothing else from Material. That is a
  // Material import bought for a compile-time constant. `--bs-white` is a real
  // declared token and the scheme already exposes `white`, so each of these
  // should resolve from the scheme or state why it is paper rather than a
  // token. Tracked as a follow-up; listed individually so the count cannot
  // quietly grow.
  'it_accordion.dart': 'Colors.white only — pending the --bs-white pass.',
  'it_back_to_top.dart': 'Colors.white only — pending the --bs-white pass.',
  'it_breadcrumb.dart': 'Colors.white only — pending the --bs-white pass.',
  'it_card.dart': 'Colors.white only — pending the --bs-white pass.',
  'it_footer.dart': 'Colors.white only — pending the --bs-white pass.',
  'it_nav_header.dart': 'Colors.white only — pending the --bs-white pass.',
  'it_slim_header.dart': 'Colors.white only — pending the --bs-white pass.',
  'it_tab_bar.dart': 'Colors.white only — pending the --bs-white pass.',
};

void main() {
  test('no file imports Material without a stated reason', () {
    final offenders = <String>[];

    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (!file.readAsStringSync().contains("package:flutter/material.dart")) {
        continue;
      }
      final name = file.path.split('/').last;
      if (_allowed.containsKey(name)) continue;
      offenders.add('  ${file.path}');
    }

    expect(
      offenders,
      isEmpty,
      reason: 'ADR 0001 says this package builds on `flutter/widgets`. These '
          'files import Material:\n\n${offenders.join('\n')}\n\n'
          'If the file uses no Material-only symbol, change the import to '
          '`package:flutter/widgets.dart` — the analyzer will not tell you, '
          'because material.dart re-exports all of widgets.dart.\n\n'
          'If it genuinely needs one, add it to `_allowed` above naming the '
          'symbol and why reimplementing it would be worse.',
    );
  });

  test('every allowlist entry still imports Material', () {
    final importing = <String>{};
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (file.readAsStringSync().contains("package:flutter/material.dart")) {
        importing.add(file.path.split('/').last);
      }
    }

    final stale = _allowed.keys.where((k) => !importing.contains(k)).toList();
    expect(stale, isEmpty,
        reason: 'These files no longer import Material, so their exemption is '
            'dead and should be deleted — leaving it would silently permit a '
            'future re-import:\n  ${stale.join('\n  ')}');
  });
}
