import 'dart:math';

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Custom colors that are clearly different from standard
const _customColors = BootstrapItaliaColorScheme(
  primary: Color(0xFFFF0000), // RED instead of blue
  secondary: Color(0xFF00FF00), // GREEN instead of gray
  success: Color(0xFF0000FF), // BLUE instead of green
  info: Color(0xFFFF00FF), // MAGENTA
  warning: Color(0xFFFFFF00), // YELLOW
  danger: Color(0xFF00FFFF), // CYAN instead of red
  light: Color(0xFFEEEEEE),
  dark: Color(0xFF111111),
);

Widget _wrapWithTheme(Widget child) {
  return BootstrapItaliaTheme(
    data: BootstrapItaliaThemeData(colors: _customColors),
    child: MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  // ── 1. Theme resolution ──────────────────────────────────────────

  group('Theme resolution', () {
    testWidgets('resolveColorScheme returns custom scheme when theme present',
        (tester) async {
      late BootstrapItaliaColorScheme resolved;

      await tester.pumpWidget(
        BootstrapItaliaTheme(
          data: BootstrapItaliaThemeData(colors: _customColors),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                resolved = resolveColorScheme(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resolved.primary, const Color(0xFFFF0000));
      expect(resolved.success, const Color(0xFF0000FF));
      expect(resolved.danger, const Color(0xFF00FFFF));
    });

    testWidgets('resolveColorScheme returns standard when no theme present',
        (tester) async {
      late BootstrapItaliaColorScheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = resolveColorScheme(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.primary, BootstrapItaliaColors.primary);
      expect(resolved.success, BootstrapItaliaColors.success);
      expect(resolved.danger, BootstrapItaliaColors.danger);
    });
  });

  // ── 2. ItButton uses theme colors ────────────────────────────────

  testWidgets('ItButton uses theme primary color', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      ItButton(
        variant: ItButtonVariant.primary,
        onPressed: () {},
        child: const Text('Test'),
      ),
    ));

    // ItButton no longer wraps a Material ElevatedButton (doc/adr/0001), so
    // assert the painted fill rather than a ButtonStyle. Checking the rendered
    // result is what we actually care about and does not couple the test to
    // whichever widget happens to be underneath.
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(ItButton),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (container.decoration! as BoxDecoration).color,
      const Color(0xFFFF0000),
    );
  });

  // ── 3. ItAlert uses theme alert colors ───────────────────────────

  testWidgets('ItAlert uses theme-derived colors', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      ItAlert(variant: ItAlertVariant.primary, body: const Text('Alert')),
    ));

    // Bootstrap Italia alerts are a white box with a neutral 1px border; the
    // variant shows up only as the 8px coloured left border. So the theme's
    // primary colour must drive the left border, NOT the background.
    final container = tester.widget<Container>(
      find.byType(Container).first,
    );
    final decoration = container.decoration as BoxDecoration;
    final border = decoration.border! as Border;
    expect(decoration.color, const Color(0xFFFFFFFF));
    expect(border.left.color, _customColors.primary);
    expect(border.left.width, 8);
    expect(border.top.color, _customColors.secondary);
  });

  // ── 4. ItBadge uses theme colors ─────────────────────────────────

  testWidgets('ItBadge uses theme variant color', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      ItBadge(variant: ItBadgeVariant.success, child: const Text('New')),
    ));

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, const Color(0xFF0000FF));
  });

  // ── 5. ItSpinner uses theme primary ──────────────────────────────

  testWidgets('ItSpinner uses theme secondary color', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItSpinner(),
    ));

    // The arc colour of the painted `.progress-spinner`; the track keeps the
    // stylesheet's own hsl(210,3%,85%) regardless of the theme.
    //
    // `secondary`, not `primary`. `.progress-spinner-active:not(
    // .progress-spinner-double) { border-color: hsl(210,17%,44%) }` — and
    // ItProgressSpinner, which does the painting, already defaulted to it. This
    // test asserted the widget's own divergence rather than the stylesheet.
    final spinner =
        tester.widget<ItProgressSpinner>(find.byType(ItProgressSpinner));
    expect(spinner.color, const Color(0xFF00FF00));
  });

  // ── 6. ItChip uses theme primary when selected ───────────────────

  testWidgets('ItChip uses theme primary when selected', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItChip(label: 'Test', selected: true),
    ));

    // Find the Container that has the border decoration
    final containers = find.byType(Container);
    // The ItChip renders a Container with a Border.all(color: colors.primary)
    bool foundPrimaryBorder = false;
    for (final element in containers.evaluate()) {
      final container = element.widget as Container;
      if (container.decoration is BoxDecoration) {
        final decoration = container.decoration as BoxDecoration;
        if (decoration.border is Border) {
          final border = decoration.border as Border;
          if (border.top.color == const Color(0xFFFF0000)) {
            foundPrimaryBorder = true;
            break;
          }
        }
      }
    }
    expect(foundPrimaryBorder, isTrue);
  });

  // ── 7. ItCallout uses theme variant colors ───────────────────────

  testWidgets('ItCallout uses theme colors for variant', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItCallout(
        variant: ItCalloutVariant.success,
        body: Text('Note'),
      ),
    ));
    await tester.pumpAndSettle();

    // `.callout .callout-inner { border: 2px solid <variant colour> }`, so the
    // success variant paints a 2px box in the theme's success colour.
    final containers = find.byType(Container);
    bool foundSuccessBorder = false;
    for (final element in containers.evaluate()) {
      final container = element.widget as Container;
      if (container.decoration is BoxDecoration) {
        final decoration = container.decoration as BoxDecoration;
        if (decoration.border is Border) {
          final border = decoration.border as Border;
          if (border.left.color == const Color(0xFF0000FF) &&
              border.left.width == 2) {
            foundSuccessBorder = true;
            break;
          }
        }
      }
    }
    expect(foundSuccessBorder, isTrue);
  });

  // ── 8. ItNotification uses theme variant colors ──────────────────

  testWidgets('ItNotification uses theme variant color', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItNotification(
        variant: ItNotificationVariant.success,
        // Bootstrap Italia only paints the coloured accent border on the
        // `.notification.with-icon` variant.
        icon: Icons.check_circle,
        title: 'Test',
        duration: null,
      ),
    ));
    await tester.pumpAndSettle();

    // The notification uses forVariant('success') for the left border accent.
    // Our custom success = 0xFF0000FF (blue). `.notification.with-icon` sets
    // `border-left: 4px` — narrower than the callout's 2px box border, so the
    // two must not be conflated.
    final containers = find.byType(Container);
    bool foundSuccessBorder = false;
    for (final element in containers.evaluate()) {
      final container = element.widget as Container;
      if (container.decoration is BoxDecoration) {
        final decoration = container.decoration as BoxDecoration;
        if (decoration.border is Border) {
          final border = decoration.border as Border;
          if (border.left.color == const Color(0xFF0000FF) &&
              border.left.width == 4) {
            foundSuccessBorder = true;
            break;
          }
        }
      }
    }
    expect(foundSuccessBorder, isTrue);
  });

  // ── 9. ItSlimHeader uses theme primary ───────────────────────────

  testWidgets('ItSlimHeader honours its backgroundColor override',
      (tester) async {
    // The slim bar's default is the fixed `.it-header-slim-wrapper`
    // background (`hsl(210,100%,35%)` = #0059B3), which Bootstrap Italia
    // defines independently of `$primary` so it reads darker than the center
    // band. Callers theme it through `backgroundColor`.
    await tester.pumpWidget(_wrapWithTheme(
      const ItSlimHeader(institutionName: 'Test'),
    ));

    Iterable<Color?> containerColors() => find
        .byType(Container)
        .evaluate()
        .map((e) => (e.widget as Container).color);

    expect(containerColors(), contains(const Color(0xFF0059B3)));

    await tester.pumpWidget(_wrapWithTheme(
      const ItSlimHeader(
        institutionName: 'Test',
        backgroundColor: Color(0xFFFF0000),
      ),
    ));

    expect(containerColors(), contains(const Color(0xFFFF0000)));
  });

  // ── 10. ItInput uses theme colors for validation ─────────────────

  testWidgets('ItInput uses theme colors for validation', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItInput(
        label: 'Test',
        validationState: ItValidationState.success,
      ),
    ));

    // Bootstrap Italia inputs have no box border: the validation state is
    // shown by the 1px bottom rule the widget paints itself, which must pick
    // up the custom success color (0xFF0000FF).
    expect(
      find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == const Color(0xFF0000FF),
      ),
      findsOneWidget,
    );
  });

  // ── 11. ItCard uses theme white for background ───────────────────

  testWidgets('ItCard uses theme white for background', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItCard(title: 'Test'),
    ));

    // ItCard wraps content in a GestureDetector > Container with
    // color: colors.white
    final containers = find.byType(Container);
    bool foundWhiteBg = false;
    for (final element in containers.evaluate()) {
      final container = element.widget as Container;
      if (container.decoration is BoxDecoration) {
        final decoration = container.decoration as BoxDecoration;
        if (decoration.color == _customColors.white) {
          foundWhiteBg = true;
          break;
        }
      }
    }
    expect(foundWhiteBg, isTrue);
  });

  // ── 12. ItModal uses theme colors ────────────────────────────────

  testWidgets('ItModal uses theme colors', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItModal(title: 'Test', body: Text('Body')),
    ));

    // ItModal wraps content in a Container with color: colors.white
    final containers = find.byType(Container);
    bool foundWhiteBg = false;
    for (final element in containers.evaluate()) {
      final container = element.widget as Container;
      if (container.decoration is BoxDecoration) {
        final decoration = container.decoration as BoxDecoration;
        if (decoration.color == _customColors.white) {
          foundWhiteBg = true;
          break;
        }
      }
    }
    expect(foundWhiteBg, isTrue);
  });

  // ── 13. BootstrapItaliaColorScheme.copyWith works ────────────────

  test('copyWith overrides specific colors', () {
    final custom = BootstrapItaliaColorScheme.standard.copyWith(
      primary: const Color(0xFFABCDEF),
    );
    expect(custom.primary, const Color(0xFFABCDEF));
    expect(custom.secondary, BootstrapItaliaColors.secondary); // unchanged
  });

  // ── 14. forVariant returns correct colors ────────────────────────

  test('forVariant maps to correct scheme colors', () {
    expect(_customColors.forVariant(ItVariantColor.primary),
        const Color(0xFFFF0000));
    expect(_customColors.forVariant(ItVariantColor.success),
        const Color(0xFF0000FF));
  });

  // There is no longer an "unknown variant" case to test, and that is the
  // point. `forVariant` took a String and fell back to primary on anything it
  // did not recognise, so `variant.name` from a newly-added enum value rendered
  // as a deliberate-looking blue with no error anywhere. Every value of every
  // component enum must now resolve, checked by the compiler.
  test('every component variant resolves to a colour role', () {
    for (final v in ItButtonVariant.values) {
      expect(_customColors.forVariant(v.variantColor), isA<Color>());
    }
    for (final v in ItBadgeVariant.values) {
      expect(_customColors.forVariant(v.variantColor), isA<Color>());
    }
    for (final v in ItAlertVariant.values) {
      expect(_customColors.forVariant(v.variantColor), isA<Color>());
    }
  });

  // Guards the mapping itself, not just its totality: an off-by-one in an
  // extension's switch would still be total, but wrong.
  test('variant names map to the colour role of the same name', () {
    for (final v in ItButtonVariant.values) {
      expect(v.variantColor.name, v.name,
          reason: 'ItButtonVariant.${v.name} must paint with the ${v.name} '
              'role — a mismatch here is invisible until someone re-themes');
    }
    for (final v in ItBadgeVariant.values) {
      expect(v.variantColor.name, v.name);
    }
    for (final v in ItAlertVariant.values) {
      expect(v.variantColor.name, v.name);
    }
  });

  // ── 15. foregroundForVariant returns correct colors ───────────────

  test('foregroundForVariant returns white for most variants', () {
    expect(
      _customColors.foregroundForVariant(ItVariantColor.primary),
      _customColors.white,
    );
    expect(
      _customColors.foregroundForVariant(ItVariantColor.light),
      _customColors.dark,
    );
  });

  // §1.4.3 Contrast (Minimum). The old signature defaulted every unrecognised
  // variant to white, so a new light-coloured variant would have shipped white
  // text on a near-white fill. The exhaustive switch cannot do that silently,
  // but nothing stops a wrong-but-total mapping, so check the contrast itself.
  test('every variant foreground clears 4.5:1 against its own fill', () {
    double luminance(Color c) => c.computeLuminance();
    for (final role in ItVariantColor.values) {
      final bg = BootstrapItaliaColorScheme.standard.forVariant(role);
      final fg = BootstrapItaliaColorScheme.standard.foregroundForVariant(role);
      final l1 = luminance(fg), l2 = luminance(bg);
      final ratio = (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'the ${role.name} variant renders its own foreground at '
              '${ratio.toStringAsFixed(2)}:1, below the 4.5:1 that WCAG 2.1 '
              'SC 1.4.3 requires of body text — and Italian PA is bound to AA '
              'by Legge 4/2004 and EN 301 549');
    }
  });
}
