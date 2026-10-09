// Standing guard: every public component has an accessibility contract.
//
// The gap this closes is not hypothetical. A coverage audit found that
// `ItActivatable` — the widget that supplies focus, keyboard activation and the
// focus ring to most of the package, and the thing ADR 0001 is built around —
// had **zero** tests. Nothing was red. It simply had never been written, and
// nothing existed to notice.
//
// Coverage is the weakest useful assertion: being named in `test/a11y/` does
// not mean a component is accessible. But a component that appears nowhere in
// those files has certainly never been checked, and that is worth failing over.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Exported widget classes, from the files the barrel actually exports.
Set<String> _publicWidgets() {
  final barrel = File('lib/bootstrap_italia_flutter.dart').readAsStringSync();
  final files = RegExp(r"^export '([^']+)';", multiLine: true)
      .allMatches(barrel)
      .map((m) => File('lib/${m.group(1)}'))
      .where((f) => f.existsSync());

  final widgets = <String>{};
  final decl = RegExp(
    r'^class\s+(It\w+)(?:<[^>]*>)?\s+extends\s+(StatelessWidget|StatefulWidget)',
    multiLine: true,
  );
  for (final f in files) {
    final code = f
        .readAsStringSync()
        .replaceAll(RegExp(r'^\s*///.*$', multiLine: true), '');
    for (final m in decl.allMatches(code)) {
      widgets.add(m.group(1)!);
    }
  }
  return widgets;
}

/// Components exempt from needing their own contract, and why.
const Map<String, String> _exempt = {
  // A horizontal rule. `.divider` is a line and nothing else: it carries no
  // name, state or value, and `ItDivider` excludes itself from the semantics
  // tree so a screen reader never meets it. Where a rule separates groups
  // that AT should tell apart, the grouping belongs in the tree instead.
  'ItDivider': 'decorative — a line with no semantics of its own',
  // ── Paints pixels, carries no semantics ──────────────────────────────────
  // Each is a CustomPaint glyph whose meaning lives on the control that draws
  // it. Giving them names of their own would double every announcement: the
  // header's search button would be "Cerca, Cerca".
  'ItArrowRightTriangle': 'decorative glyph — the megamenu link names itself',
  'ItExpandChevron': 'decorative glyph — the toggle carries `expanded`',
  'ItSearchGlyph': 'decorative glyph — the search button carries the name',
  'ItProgressSpinner': 'the painted arc; ItSpinner wraps it and carries the '
      'role and the loading announcement, and is contracted',

  // ── Behaviour with no rendering of its own ───────────────────────────────
  'ItHoverBuilder': 'reports pointer state to a builder; paints nothing and '
      'announces nothing',
  'ItResponsiveBuilder': 'passes a breakpoint to a builder',
  'ItContainer': 'layout only — its child carries the semantics',
  'ItDefaultTextStyle': 'supplies the font family, not semantics; covered by '
      'no_ambient_material_test, which is what it exists for',

  // ── Sub-parts whose semantics belong to the composite ────────────────────
  // Each is exercised through its parent, which IS contracted. Contracting the
  // part separately would assert a tree shape rather than a behaviour.
  'ItCardBody': 'part of ItCard, which is contracted as one control',
  'ItCardFooter': 'part of ItCard',
  'ItFooterBrand': 'part of ItFooter',
  'ItFooterSmallPrints': 'part of ItFooter',
  'ItFieldSupport': 'the shared helper/error block; asserted through all six '
      'form controls, which is where it is reachable from',
  'ItHeader': 'a composition of ItSlimHeader/ItCenterHeader/ItNavHeader, each '
      'contracted individually',
  'ItSliverHeader': 'the same composition in a CustomScrollView; the sliver '
      'behaviour is pinned by test/header_sliver_test.dart',
};

void main() {
  test('every public component appears in an accessibility contract', () {
    final contracts = Directory('test/a11y')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.readAsStringSync())
        .join('\n');

    final missing = <String>[];
    for (final widget in _publicWidgets()) {
      if (_exempt.containsKey(widget)) continue;
      if (RegExp('\\b$widget\\b').hasMatch(contracts)) continue;
      missing.add(widget);
    }
    missing.sort();

    expect(
      missing,
      isEmpty,
      reason: 'These public components appear nowhere in `test/a11y/`:\n\n'
          '${missing.map((w) => '  $w').join('\n')}\n\n'
          'Being named there is a low bar and it is the point: a component that '
          'appears nowhere has certainly never been checked. `ItActivatable`, '
          'which supplies keyboard activation to most of this package, sat in '
          'exactly that state with nothing red.\n\n'
          'Write a contract asserting role, name and state, or — if the widget '
          'genuinely has no semantics of its own — add it to `_exempt` above '
          'with the reason.',
    );
  });

  test('no exemption outlives the widget it excuses', () {
    final widgets = _publicWidgets();
    final stale = _exempt.keys.where((w) => !widgets.contains(w)).toList();
    expect(stale, isEmpty,
        reason: 'These exemptions name widgets that no longer exist, so they '
            'excuse nothing and would silently excuse a future widget that '
            'reused the name:\n  ${stale.join('\n  ')}');
  });
}
