// Standing guard: no component may write a palette colour as a literal.
//
// `BootstrapItaliaColorScheme` exists so an administration can apply its own
// palette. That promise is kept only while components resolve their colours
// from the scheme. It has been broken before — the brand blue `#0066CC` was
// written literally in a dozen component files, so `copyWith(primary: ...)`
// retinted buttons and alerts while navigation and content silently stayed Blu
// Italia. `theming_contract_test.dart` asserts the positive case component by
// component; this file is the net that catches the ones nobody thought to add.
//
// ── Why an allowlist rather than a ban ─────────────────────────────────────
//
// The inverse defect is equally real. Bootstrap Italia v2.18.0 resolves every
// semantic token to a literal at build time — `var(--bs-primary)` appears zero
// times in the whole stylesheet — so a value being written literally in the CSS
// says nothing about whether it is a token. And several palette values are
// *also* declared for non-palette purposes: `hsl(210, 17%, 44%)` is
// `--bs-secondary`, `--bs-info` AND `--bs-gray-secondary` at once. On a card
// date or a resting field border it is the neutral grey, and routing it through
// the scheme would be a fresh bug — an administration retinting `secondary`
// wants its buttons recoloured, not its publication dates.
//
// So a literal is permitted, but only with a stated reason. Adding an entry
// here is the moment to check the CSS; the test exists to make that moment
// unavoidable rather than to forbid the outcome.
import 'dart:io';

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

/// The semantic palette, by RGB, from `lib/src/tokens/colors.dart`.
///
/// Read from the tokens themselves rather than retyped, so the guard cannot
/// drift away from what it guards.
final Map<int, String> _palette = {
  BootstrapItaliaColors.primary.toARGB32() & 0xFFFFFF: 'primary',
  BootstrapItaliaColors.secondary.toARGB32() & 0xFFFFFF: 'secondary/info',
  BootstrapItaliaColors.success.toARGB32() & 0xFFFFFF: 'success',
  BootstrapItaliaColors.warning.toARGB32() & 0xFFFFFF: 'warning',
  BootstrapItaliaColors.danger.toARGB32() & 0xFFFFFF: 'danger',
  BootstrapItaliaColors.light.toARGB32() & 0xFFFFFF: 'light',
  BootstrapItaliaColors.dark.toARGB32() & 0xFFFFFF: 'dark',
  BootstrapItaliaColors.bodyColor.toARGB32() & 0xFFFFFF: 'bodyColor',
};

/// Literal palette values that are correct, and why.
///
/// Keyed by `<file basename>:<the RGB it writes>`. Every entry names the CSS
/// rule that justifies it. An entry without a checked CSS origin is the defect
/// this file is trying to prevent, so do not add one to make the test pass.
const Map<String, String> _allowed = {
  // `lib/src/tokens/` is where the palette is defined; excluded wholesale below.

  'it_form_metrics.dart:0x5D7083':
      'Resting form chrome: `input[type=text] { border-bottom: 1px solid '
          'hsl(210,17%,44%) }`, `.form-group label`, `::placeholder`. The value '
          'is declared as --bs-secondary, --bs-info AND --bs-gray-secondary; in '
          'a resting-chrome role it is the grey, so it must NOT follow a '
          'retinted secondary.',

  'it_card.dart:0x5D7083':
      'Card category and date: `--bs-it-card-category-color` and '
          '`--bs-it-card-date-color`, both `hsl(210,17%,44%)`. Muted metadata, '
          'so the grey rather than the brand accent — see '
          'theming_contract_test.dart, which asserts this one does not move.',

  'it_chip.dart:0x5D7083':
      'The dismiss glyph: `.chip button .icon { fill: hsl(210,17%,44%) }`, one '
          'step lighter than the label\'s `hsl(210,33%,28%)`. Byte-identical to '
          '--bs-secondary, but a close button is chrome: an administration '
          'retinting secondary to purple does not want purple close buttons. '
          'Same reasoning as the card date and the resting field border.',

  'bootstrap_italia_theme_data.dart:0x1A1A1A':
      'The default value of the `bodyColor` token itself, in the scheme that '
          'defines it. This is the definition, not a bypass of it.',
};

/// Every `Color(0x........)` literal in [source], as (line, argb).
Iterable<(int, int)> _colorLiterals(String source) sync* {
  final pattern = RegExp(r'Color\(0x([0-9A-Fa-f]{8})\)');
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    for (final m in pattern.allMatches(lines[i])) {
      yield (i + 1, int.parse(m.group(1)!, radix: 16));
    }
  }
}

void main() {
  test('no component writes a palette colour as a literal', () {
    final offenders = <String>[];

    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        // The tokens layer is where the palette lives.
        .where((f) => !f.path.contains('lib/src/tokens/'));

    for (final file in files) {
      final name = file.path.split('/').last;
      for (final (line, argb) in _colorLiterals(file.readAsStringSync())) {
        final rgb = argb & 0xFFFFFF;
        final role = _palette[rgb];
        if (role == null) continue; // not a palette colour — fine

        final key =
            '$name:0x${rgb.toRadixString(16).toUpperCase().padLeft(6, '0')}';
        if (_allowed.containsKey(key)) continue;

        final alpha = (argb >> 24) & 0xFF;
        offenders.add(
          '  ${file.path}:$line writes 0x${argb.toRadixString(16).toUpperCase()}'
          '${alpha != 0xFF ? ' (alpha 0x${alpha.toRadixString(16)})' : ''}'
          ', which is the `$role` token.',
        );
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'These literals are palette tokens, so an administration applying '
          'its own colours would see them stay Blu Italia while the rest of the '
          'page changed:\n\n${offenders.join('\n')}\n\n'
          'Resolve each from the scheme — `resolveColorScheme(context).<role>`, '
          'or `itShade(colors.<role>, n)` for a derived shade.\n\n'
          'If a value is genuinely NOT the token — several palette values are '
          'also declared as neutrals, and on muted metadata or resting chrome '
          'it is the neutral that is meant — add it to `_allowed` above WITH '
          'the CSS rule that proves it. Check the rule first; an unchecked '
          'entry is the bug this test exists to catch.',
    );
  });

  test('every allowlist entry still corresponds to a real literal', () {
    // An allowlist that outlives its call site is worse than none: it silently
    // permits a future literal in the same file with the same value.
    final live = <String>{};
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('lib/src/tokens/'))) {
      final name = file.path.split('/').last;
      for (final (_, argb) in _colorLiterals(file.readAsStringSync())) {
        final rgb = argb & 0xFFFFFF;
        live.add(
            '$name:0x${rgb.toRadixString(16).toUpperCase().padLeft(6, '0')}');
      }
    }

    final stale = _allowed.keys.where((k) => !live.contains(k)).toList();
    expect(stale, isEmpty,
        reason: 'These allowlist entries no longer match any literal in lib/ — '
            'the code was fixed or moved, so delete them:\n  ${stale.join('\n  ')}');
  });
}
