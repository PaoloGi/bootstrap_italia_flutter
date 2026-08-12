// Standing guard: the exported surface is a golden file.
//
// This package is `publish_to: none` today, but the whole argument of Phase 2
// was that breaking changes are free *now* and expensive later. The corollary
// is that once a change stops being free, it must stop being invisible. A
// rename, a widened parameter, an accidental `export` of something meant to be
// internal — none of those fail a test, and none of them show up in a diff that
// a reviewer reads as "API change" rather than "moved some code".
//
// So: the surface is extracted and compared against `api_snapshot.txt`. The
// test failing is not a problem to route around — it is the diff. Read it, and
// if the change is intended, run with UPDATE_API_SNAPSHOT=1 to accept it.
//
// This is a change DETECTOR, not a type checker. It reads declarations with
// regular expressions rather than the analyser, so it is deliberately coarse:
// it will notice a renamed class or a new public parameter, and it will not
// notice a changed return type. Coarse and always-run beats precise and
// aspirational.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _snapshot = File('test/api_snapshot.txt');

/// Public top-level declarations and their public members, sorted.
List<String> _extractApi() {
  final out = <String>[];

  final decl = RegExp(
    r'^(?:abstract\s+|final\s+|sealed\s+|base\s+|interface\s+|mixin\s+)*'
    // The leading `_` is matched deliberately, then skipped below. Without it a
    // private class is not a declaration boundary at all, so its members fall
    // into the range of the previous PUBLIC class and are reported as part of
    // that class's surface — `_LeftGlyph.color` showed up as
    // `ItAccordion.color`.
    r'(class|enum|extension|typedef)\s+(_?[A-Za-z]\w*)',
    multiLine: true,
  );
  // Constructors, fields and methods that a consumer can name.
  //
  // The indent is load-bearing: exactly two spaces, and the third character
  // must not be one. Without that this matched inside method bodies, so a local
  // `const Color(0xFFFFFFFF)` was reported as a member named `Color` — which
  // then showed up as a public API addition when a component simply stopped
  // using `Colors.white`.
  final member = RegExp(
    r'^  (?! )(?:static\s+|final\s+|const\s+)*'
    r'(?:[\w<>,\s\?\[\]]+\s+)?([a-zA-Z_]\w*)\s*[({;=]',
    multiLine: true,
  );

  // Only files the barrel exports. Scanning all of `lib/` would list internal
  // classes that no consumer can name — 1,635 lines of mostly noise, in which
  // a real API change would be invisible. Five of the 56 source files are not
  // exported, and their contents are deliberately not a promise.
  final barrel = File('lib/bootstrap_italia_flutter.dart').readAsStringSync();
  final exported = RegExp(r"^export '([^']+)';", multiLine: true)
      .allMatches(barrel)
      .map((m) => File('lib/${m.group(1)}'))
      .where((f) => f.existsSync());

  // A bare field declaration ends in `;` with no initialiser, and its name is
  // the last identifier on the line. The pattern above reads left to right and
  // so reports the TYPE of a function-typed field —
  // `ItLocalizations? Function(Locale)? resolve;` came out as `Function`.
  // Anchoring on the `;` cannot mis-fire on an initialised field, because those
  // end `);` or a literal rather than an identifier.
  final bareField = RegExp(
    r'^  (?! )(?:static\s+|final\s+|const\s+|late\s+)*'
    r'.*\s([a-zA-Z_]\w*);\s*$',
    multiLine: true,
  );

  for (final file in exported) {
    final src = file.readAsStringSync();
    // Strip comments so a class named in prose is not mistaken for one declared.
    final code = src
        .replaceAll(RegExp(r'^\s*///.*$', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');

    for (final m in decl.allMatches(code)) {
      final kind = m.group(1)!;
      final name = m.group(2)!;
      if (name.startsWith('_')) continue;
      out.add('$kind $name');

      // Members up to the next top-level declaration.
      final start = m.end;
      final next = decl.firstMatch(code.substring(start));
      final body = code.substring(
          start, next == null ? code.length : start + next.start);
      for (final mm in [
        ...member.allMatches(body),
        // An expression-bodied getter also ends in `;`, and its last identifier
        // is whatever the expression returns — `=> widget.onPressed != null;`
        // reported a member called `null`. A declaration has no `=`.
        ...bareField.allMatches(body).where((m) => !m.group(0)!.contains('=')),
      ]) {
        final field = mm.group(1)!;
        if (field.startsWith('_')) continue;
        // Keywords picked up from statements, and `Function`, which is a type
        // rather than a name — the left-to-right pattern reports it for a
        // function-typed field, whose real name the `;`-anchored pattern
        // supplies instead.
        if (const {
          'return',
          'if',
          'for',
          'while',
          'switch',
          'assert',
          'await',
          'Function',
        }.contains(field)) {
          continue;
        }
        out.add('  $name.$field');
      }
    }
  }

  final unique = out.toSet().toList()..sort();
  return unique;
}

void main() {
  test('the public API matches its snapshot', () {
    final actual = _extractApi();

    if (Platform.environment['UPDATE_API_SNAPSHOT'] == '1') {
      _snapshot.writeAsStringSync('${actual.join('\n')}\n');
      markTestSkipped('snapshot rewritten — review the diff before committing');
      return;
    }

    expect(_snapshot.existsSync(), isTrue,
        reason: 'run with UPDATE_API_SNAPSHOT=1 to create it');

    final expected =
        _snapshot.readAsLinesSync().where((l) => l.trim().isNotEmpty).toList();

    final added = actual.where((l) => !expected.contains(l)).toList();
    final removed = expected.where((l) => !actual.contains(l)).toList();

    expect(
      [...added.map((l) => '+ $l'), ...removed.map((l) => '- $l')],
      isEmpty,
      reason: 'The exported surface changed.\n\n'
          '${added.map((l) => '  + $l').join('\n')}\n'
          '${removed.map((l) => '  - $l').join('\n')}\n\n'
          'A REMOVED line is a breaking change for anyone depending on this '
          'package. An ADDED line is a new promise that has to be kept.\n\n'
          'If the change is intended, accept it deliberately:\n'
          '  UPDATE_API_SNAPSHOT=1 flutter test test/public_api_snapshot_test.dart',
    );
  });
}
