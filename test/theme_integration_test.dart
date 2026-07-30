import 'package:bootstrap_italia/bootstrap_italia.dart';
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

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final style = button.style!;
    // Resolve the background color from the ButtonStyle
    final bgColor =
        style.backgroundColor?.resolve(<WidgetState>{});
    expect(bgColor, const Color(0xFFFF0000));
  });

  // ── 3. ItAlert uses theme alert colors ───────────────────────────

  testWidgets('ItAlert uses theme-derived colors', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      ItAlert(variant: ItAlertVariant.primary, child: const Text('Alert')),
    ));

    // The alert uses alertColorsForVariant which returns hardcoded derived
    // colors based on variant name. Verify the Container decoration uses
    // the expected alert colors for 'primary'.
    final alertColors = _customColors.alertColorsForVariant('primary');

    // Find the outermost Container inside the FadeTransition > Semantics
    final container = tester.widget<Container>(
      find.byType(Container).first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, alertColors.background);
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

  testWidgets('ItSpinner uses theme primary color', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItSpinner(),
    ));

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    final animation =
        indicator.valueColor as AlwaysStoppedAnimation<Color>;
    expect(animation.value, const Color(0xFFFF0000));
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
        child: Text('Note'),
      ),
    ));
    await tester.pumpAndSettle();

    // The callout uses calloutColorsForVariant which returns
    // accent: success (our custom blue) for the 'success' variant.
    // Find the Container with a left border.
    final containers = find.byType(Container);
    bool foundSuccessLeftBorder = false;
    for (final element in containers.evaluate()) {
      final container = element.widget as Container;
      if (container.decoration is BoxDecoration) {
        final decoration = container.decoration as BoxDecoration;
        if (decoration.border is Border) {
          final border = decoration.border as Border;
          // ItCallout sets left: BorderSide(color: accentColor, width: 4)
          if (border.left.color == const Color(0xFF0000FF) &&
              border.left.width == 4) {
            foundSuccessLeftBorder = true;
            break;
          }
        }
      }
    }
    expect(foundSuccessLeftBorder, isTrue);
  });

  // ── 8. ItNotification uses theme variant colors ──────────────────

  testWidgets('ItNotification uses theme variant color', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItNotification(
        variant: ItNotificationVariant.success,
        title: 'Test',
        duration: null,
      ),
    ));
    await tester.pumpAndSettle();

    // The notification uses forVariant('success') for the left border accent.
    // Our custom success = 0xFF0000FF (blue).
    final containers = find.byType(Container);
    bool foundSuccessLeftBorder = false;
    for (final element in containers.evaluate()) {
      final container = element.widget as Container;
      if (container.decoration is BoxDecoration) {
        final decoration = container.decoration as BoxDecoration;
        if (decoration.border is Border) {
          final border = decoration.border as Border;
          if (border.left.color == const Color(0xFF0000FF) &&
              border.left.width == 4) {
            foundSuccessLeftBorder = true;
            break;
          }
        }
      }
    }
    expect(foundSuccessLeftBorder, isTrue);
  });

  // ── 9. ItSlimHeader uses theme primary ───────────────────────────

  testWidgets('ItSlimHeader uses theme primary as default bg', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItSlimHeader(institutionName: 'Test'),
    ));

    // ItSlimHeader sets Container color: bgColor (= colors.primary by default)
    final containers = find.byType(Container);
    bool foundPrimaryBg = false;
    for (final element in containers.evaluate()) {
      final container = element.widget as Container;
      if (container.color == const Color(0xFFFF0000)) {
        foundPrimaryBg = true;
        break;
      }
    }
    expect(foundPrimaryBg, isTrue);
  });

  // ── 10. ItInput uses theme colors for validation ─────────────────

  testWidgets('ItInput uses theme colors for validation', (tester) async {
    await tester.pumpWidget(_wrapWithTheme(
      const ItInput(
        label: 'Test',
        validationState: ItValidationState.success,
      ),
    ));

    final textField = tester.widget<TextField>(find.byType(TextField));
    final decoration = textField.decoration!;
    // The enabledBorder should use the custom success color (0xFF0000FF)
    final enabledBorder = decoration.enabledBorder as UnderlineInputBorder;
    expect(enabledBorder.borderSide.color, const Color(0xFF0000FF));
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
    expect(_customColors.forVariant('primary'), const Color(0xFFFF0000));
    expect(_customColors.forVariant('success'), const Color(0xFF0000FF));
    expect(
      _customColors.forVariant('unknown'),
      _customColors.primary,
    ); // fallback
  });

  // ── 15. foregroundForVariant returns correct colors ───────────────

  test('foregroundForVariant returns white for most variants', () {
    expect(
      _customColors.foregroundForVariant('primary'),
      _customColors.white,
    );
    expect(
      _customColors.foregroundForVariant('light'),
      _customColors.dark,
    );
  });
}
