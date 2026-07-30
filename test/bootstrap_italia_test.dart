import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BootstrapItaliaColors', () {
    test('primary is Blu Italia #0066CC', () {
      expect(BootstrapItaliaColors.primary, const Color(0xFF0066CC));
    });

    test('all semantic colors are defined', () {
      expect(BootstrapItaliaColors.secondary, isNotNull);
      expect(BootstrapItaliaColors.success, isNotNull);
      expect(BootstrapItaliaColors.info, isNotNull);
      expect(BootstrapItaliaColors.warning, isNotNull);
      expect(BootstrapItaliaColors.danger, isNotNull);
      expect(BootstrapItaliaColors.light, isNotNull);
      expect(BootstrapItaliaColors.dark, isNotNull);
    });

    test('gray scale has 9 levels ordered light to dark', () {
      final grays = [
        BootstrapItaliaColors.gray100,
        BootstrapItaliaColors.gray200,
        BootstrapItaliaColors.gray300,
        BootstrapItaliaColors.gray400,
        BootstrapItaliaColors.gray500,
        BootstrapItaliaColors.gray600,
        BootstrapItaliaColors.gray700,
        BootstrapItaliaColors.gray800,
        BootstrapItaliaColors.gray900,
      ];
      expect(grays.length, 9);
      for (var i = 0; i < grays.length - 1; i++) {
        expect(grays[i].computeLuminance(),
            greaterThan(grays[i + 1].computeLuminance()));
      }
    });
  });

  group('ItBreakpoint', () {
    test('fromWidth returns correct breakpoints', () {
      expect(ItBreakpoint.fromWidth(0), ItBreakpoint.xs);
      expect(ItBreakpoint.fromWidth(575), ItBreakpoint.xs);
      expect(ItBreakpoint.fromWidth(576), ItBreakpoint.sm);
      expect(ItBreakpoint.fromWidth(768), ItBreakpoint.md);
      expect(ItBreakpoint.fromWidth(992), ItBreakpoint.lg);
      expect(ItBreakpoint.fromWidth(1200), ItBreakpoint.xl);
      expect(ItBreakpoint.fromWidth(1400), ItBreakpoint.xxl);
      expect(ItBreakpoint.fromWidth(2000), ItBreakpoint.xxl);
    });
  });

  group('ItContainerWidths', () {
    test('forBreakpoint returns correct max-widths', () {
      expect(ItContainerWidths.forBreakpoint(ItBreakpoint.xs), double.infinity);
      expect(ItContainerWidths.forBreakpoint(ItBreakpoint.sm), 540);
      expect(ItContainerWidths.forBreakpoint(ItBreakpoint.md), 720);
      expect(ItContainerWidths.forBreakpoint(ItBreakpoint.lg), 960);
      expect(ItContainerWidths.forBreakpoint(ItBreakpoint.xl), 1176);
      expect(ItContainerWidths.forBreakpoint(ItBreakpoint.xxl), 1320);
    });
  });

  group('BootstrapItaliaTypography', () {
    test('responsive returns mobile below 576', () {
      final typography = BootstrapItaliaTypography.responsive(375);
      expect(typography.h1.fontSize, 40);
      expect(typography.bodyText.fontSize, 16);
    });

    test('responsive returns desktop at 576 and above', () {
      final typography = BootstrapItaliaTypography.responsive(576);
      expect(typography.h1.fontSize, 48);
      expect(typography.bodyText.fontSize, 18);
    });

    test('all styles use TitilliumWeb', () {
      final typography = BootstrapItaliaTypography.desktop;
      expect(typography.h1.fontFamily, contains('TitilliumWeb'));
      expect(typography.bodyText.fontFamily, contains('TitilliumWeb'));
    });
  });

  group('BootstrapItaliaThemeData', () {
    test('standard factory creates valid theme', () {
      final theme = BootstrapItaliaThemeData.standard();
      expect(theme.colors.primary, BootstrapItaliaColors.primary);
    });

    test('toThemeData returns valid Material ThemeData', () {
      final theme = BootstrapItaliaThemeData.standard();
      final materialTheme = theme.toThemeData();
      expect(materialTheme.primaryColor, BootstrapItaliaColors.primary);
      expect(materialTheme.colorScheme.primary, BootstrapItaliaColors.primary);
    });

    test('copyWith overrides correctly', () {
      final theme = BootstrapItaliaThemeData.standard();
      final custom = theme.copyWith(
        colors: theme.colors.copyWith(primary: const Color(0xFFFF0000)),
      );
      expect(custom.colors.primary, const Color(0xFFFF0000));
      expect(custom.colors.secondary, theme.colors.secondary);
    });
  });

  group('BootstrapItaliaColorScheme', () {
    test('forVariant returns correct colors', () {
      const scheme = BootstrapItaliaColorScheme.standard;
      expect(scheme.forVariant('primary'), BootstrapItaliaColors.primary);
      expect(scheme.forVariant('danger'), BootstrapItaliaColors.danger);
      expect(scheme.forVariant('unknown'), BootstrapItaliaColors.primary);
    });
  });

  group('BootstrapItaliaTheme widget', () {
    testWidgets('provides theme data to descendants', (tester) async {
      final theme = BootstrapItaliaThemeData.standard();

      late BootstrapItaliaThemeData retrievedTheme;

      await tester.pumpWidget(
        BootstrapItaliaTheme(
          data: theme,
          child: Builder(
            builder: (context) {
              retrievedTheme = BootstrapItaliaTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedTheme.colors.primary, BootstrapItaliaColors.primary);
    });

    testWidgets('maybeOf returns null when no theme', (tester) async {
      BootstrapItaliaThemeData? result;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            result = BootstrapItaliaTheme.maybeOf(context);
            return const SizedBox();
          },
        ),
      );

      expect(result, isNull);
    });
  });

  group('ItResponsiveBuilder', () {
    testWidgets('shows xs builder for narrow width', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(375, 812)),
          child: ItResponsiveBuilder(
            xs: (_) => const Text('mobile', textDirection: TextDirection.ltr),
            lg: (_) => const Text('desktop', textDirection: TextDirection.ltr),
          ),
        ),
      );

      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('desktop'), findsNothing);
    });
  });

  group('ItContainer', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(size: Size(1400, 900)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ItContainer(
              child: Text('content'),
            ),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);
    });
  });
}
