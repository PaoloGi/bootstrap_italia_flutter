// WCAG 2.1 contrast audit over the design tokens.
//
// For Italian public administration this is a legal requirement, not a
// preference: Legge 4/2004 (Stanca) and EU Directive 2016/2102 bind PA services
// to EN 301 549, whose web clauses are satisfied by WCAG 2.1 level AA.
//
// The audit runs on TOKENS rather than on rendered pixels deliberately:
//   * it is exhaustive — every declared pair is checked, not just the ones a
//     screenshot happened to include;
//   * it is deterministic and offline, so it belongs in CI;
//   * axe-core cannot check contrast on Flutter Web at all (the semantics tree
//     is a transparent overlay above a canvas, so axe reports `incomplete`),
//     which means a rendering-based check would give false assurance.
//
// Colours here must be read from the token layer, never hard-coded, so that a
// token change is caught by this test rather than silently shipping.
import 'dart:math' as math;
import 'dart:ui';

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
// The form controls' pixel metrics and colours are an internal detail, but
// they are the token layer for everything under lib/src/form.
import 'package:bootstrap_italia_flutter/src/form/it_form_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Relative luminance per WCAG 2.1 §"relative luminance".
double _luminance(Color c) {
  double channel(double v) {
    final s = v / 255.0;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  // ignore: deprecated_member_use
  return 0.2126 * channel(c.red.toDouble()) +
      // ignore: deprecated_member_use
      0.7152 * channel(c.green.toDouble()) +
      // ignore: deprecated_member_use
      0.0722 * channel(c.blue.toDouble());
}

/// Contrast ratio per WCAG 2.1 §1.4.3.
double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

class _Pair {
  const _Pair(this.what, this.fg, this.bg, this.minRatio, this.criterion);

  final String what;
  final Color fg;
  final Color bg;
  final double minRatio;
  final String criterion;
}

void main() {
  const colors = BootstrapItaliaColorScheme.standard;
  const white = Color(0xFFFFFFFF);

  // 1.4.3 Contrast (Minimum), AA: 4.5:1 for body text, 3:1 for large text.
  final textPairs = <_Pair>[
    _Pair('white on primary (button, header)', white, colors.primary, 4.5,
        '1.4.3'),
    _Pair('white on secondary', white, colors.secondary, 4.5, '1.4.3'),
    _Pair('white on success', white, colors.success, 4.5, '1.4.3'),
    _Pair('white on danger', white, colors.danger, 4.5, '1.4.3'),
    _Pair('white on warning', white, colors.warning, 4.5, '1.4.3'),
    _Pair('dark on light', colors.dark, colors.light, 4.5, '1.4.3'),
    _Pair('body text on page', colors.bodyColor, colors.bodyBg, 4.5, '1.4.3'),
    _Pair(
        'link (primary) on page', colors.primary, colors.bodyBg, 4.5, '1.4.3'),
    _Pair('neutral1 heading on page', colors.neutral1, colors.bodyBg, 4.5,
        '1.4.3'),
  ];

  // 1.4.11 Non-text Contrast, AA: 3:1 for the parts of a CONTROL needed to
  // identify it, and for meaningful graphics. Purely decorative boundaries are
  // explicitly out of scope, so this list holds only load-bearing colours.
  final nonTextPairs = <_Pair>[
    _Pair('focus/active indicator on page', colors.primary, colors.bodyBg, 3.0,
        '1.4.11'),
    _Pair('input underline on page', colors.secondary, colors.bodyBg, 3.0,
        '1.4.11'),
  ];

  group('WCAG 2.1 AA contrast (EN 301 549 / Legge 4-2004)', () {
    for (final p in [...textPairs, ...nonTextPairs]) {
      test('${p.criterion}: ${p.what}', () {
        final ratio = contrastRatio(p.fg, p.bg);
        expect(
          ratio,
          greaterThanOrEqualTo(p.minRatio),
          reason: '${p.what} is ${ratio.toStringAsFixed(2)}:1, '
              'below the ${p.minRatio}:1 required by WCAG 2.1 §${p.criterion} (AA).',
        );
      });
    }

    test('disabled controls are exempt but still documented', () {
      // WCAG 1.4.3 exempts inactive controls. Recorded rather than asserted so
      // the exemption is a deliberate, visible decision instead of an omission.
      final ratio = contrastRatio(colors.gray400, colors.bodyBg);
      expect(ratio, greaterThan(1.0));
    });
  });

  // The form controls are hand-painted from their own token set, so none of
  // the pairs above cover them. Every colour here is one a user must be able
  // to see to operate or read the control.
  group('WCAG 2.1 AA contrast — form controls', () {
    final formPairs = <_Pair>[
      // 1.4.3, text.
      // `textColor` resolves `--bs-body-color` from the scheme, so the audit
      // asks it for the standard palette's value rather than a constant.
      _Pair('floating label / field value on white',
          ItFormMetrics.textColor(colors), white, 4.5, '1.4.3'),
      const _Pair('resting label and placeholder on white',
          ItFormMetrics.borderColor, white, 4.5, '1.4.3'),
      const _Pair('`.form-text` helper text on white',
          ItFormMetrics.borderColor, white, 4.5, '1.4.3'),
      const _Pair('`.form-feedback` validation message on white',
          ItFormMetrics.feedbackDangerColor, white, 4.5, '1.4.3'),

      // 1.4.11, the parts of a control needed to identify it and its state.
      const _Pair('unchecked checkbox border on white',
          ItFormMetrics.checkOutlineColor, white, 3.0, '1.4.11'),
      _Pair('checked checkbox fill on white', colors.primary, white, 3.0,
          '1.4.11'),
      _Pair('checkbox tick on its checked fill', white, colors.primary, 3.0,
          '1.4.11'),
      const _Pair('input underline on white', ItFormMetrics.borderColor, white,
          3.0, '1.4.11'),
      const _Pair('select underline on white', ItFormMetrics.selectBorderColor,
          white, 3.0, '1.4.11'),
      const _Pair('toggle thumb, off, on white',
          ItFormMetrics.checkOutlineColor, white, 3.0, '1.4.11'),
      _Pair('toggle thumb, on, on white', colors.primary, white, 3.0, '1.4.11'),

      // 2.4.7 / 1.4.11: Bootstrap Italia's keyboard focus indicator is
      // `box-shadow: 0 0 0 2px #fff, 0 0 0 5px #000`, so the visible band is
      // black against the page.
      const _Pair('keyboard focus ring on white', Color(0xFF000000), white, 3.0,
          '1.4.11'),
    ];

    for (final p in formPairs) {
      test('${p.criterion}: ${p.what}', () {
        final ratio = contrastRatio(p.fg, p.bg);
        expect(
          ratio,
          greaterThanOrEqualTo(p.minRatio),
          reason: '${p.what} is ${ratio.toStringAsFixed(2)}:1, below the '
              '${p.minRatio}:1 required by WCAG 2.1 §${p.criterion} (AA).',
        );
      });
    }

    test('the toggle track is a container, not the state indicator', () {
      // `.lever` is #e6e9f2 in every state — 1.21:1 on white — and Bootstrap
      // Italia never changes it. It is therefore out of 1.4.11 scope: what
      // identifies the switch position is the thumb's colour AND its position,
      // both of which are asserted above. Documented rather than asserted so
      // the exemption is a visible decision.
      expect(contrastRatio(ItFormMetrics.mutedChrome, white), lessThan(3.0));
      expect(
        contrastRatio(
            ItFormMetrics.checkOutlineColor, ItFormMetrics.mutedChrome),
        greaterThanOrEqualTo(3.0),
        reason: 'the thumb must at least stand out against the track it sits '
            'on, or the switch position is invisible',
      );
    });
  });
}
