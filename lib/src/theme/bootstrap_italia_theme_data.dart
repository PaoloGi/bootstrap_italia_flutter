import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Holds all Bootstrap Italia design tokens as a single theme object.
///
/// Use [BootstrapItaliaThemeData.standard] for the default Bootstrap Italia
/// theme, or create a custom instance to override specific tokens.
class BootstrapItaliaThemeData {
  /// The color scheme for this theme.
  final BootstrapItaliaColorScheme colors;

  /// Creates a Bootstrap Italia theme with the given tokens.
  const BootstrapItaliaThemeData({
    required this.colors,
  });

  /// The standard Bootstrap Italia theme with default colors.
  factory BootstrapItaliaThemeData.standard() {
    return const BootstrapItaliaThemeData(
      colors: BootstrapItaliaColorScheme.standard,
    );
  }

  /// Converts this theme to a Material [ThemeData] for compatibility.
  ///
  /// This allows Bootstrap Italia components to work alongside Material widgets
  /// and provides sensible defaults for Material components using Italia tokens.
  ThemeData toThemeData({Brightness brightness = Brightness.light}) {
    const typography = BootstrapItaliaTypography.desktop;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: colors.primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.white,
        secondary: colors.secondary,
        onSecondary: colors.white,
        error: colors.danger,
        onError: colors.white,
        surface: colors.bodyBg,
        onSurface: colors.bodyColor,
      ),
      scaffoldBackgroundColor: colors.bodyBg,
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      textTheme: TextTheme(
        displayLarge: typography.display1,
        headlineLarge: typography.h1,
        headlineMedium: typography.h2,
        headlineSmall: typography.h3,
        titleLarge: typography.h4,
        titleMedium: typography.h5,
        titleSmall: typography.h6,
        bodyLarge: typography.lead,
        bodyMedium: typography.bodyText,
        bodySmall: typography.bodySmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BootstrapItaliaBorders.radius),
          ),
        ),
      ),
      // Bootstrap Italia: $input-border-width: 0, $input-border-radius: 0
      // Inputs use underline-only borders, not outlined boxes.
      inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.secondary),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
    );
  }

  /// Creates a copy of this theme with the given overrides.
  BootstrapItaliaThemeData copyWith({
    BootstrapItaliaColorScheme? colors,
  }) {
    return BootstrapItaliaThemeData(
      colors: colors ?? this.colors,
    );
  }
}

/// Color scheme for Bootstrap Italia.
///
/// Contains all semantic, surface, and utility colors used across components.
/// Centralizes color resolution so components never hardcode static constants.
class BootstrapItaliaColorScheme {
  // ── Semantic variant colors ─────────────────────────────────────

  /// Primary brand color (Blu Italia).
  final Color primary;

  /// Secondary color.
  final Color secondary;

  /// Success semantic color.
  final Color success;

  /// Info semantic color.
  final Color info;

  /// Warning semantic color.
  final Color warning;

  /// Danger/error semantic color.
  final Color danger;

  /// Light background color.
  final Color light;

  /// Dark color.
  final Color dark;

  // ── Surface & body colors ───────────────────────────────────────

  /// Default body text color.
  final Color bodyColor;

  /// Default body background.
  final Color bodyBg;

  /// White.
  final Color white;

  /// Black.
  final Color black;

  // ── Neutral colors ──────────────────────────────────────────────

  /// Neutral 1 — dark navy, used for headings.
  final Color neutral1;

  /// Neutral 2 — light blue-gray, used for muted backgrounds/text.
  final Color neutral2;

  // ── Gray scale (subset used by components) ──────────────────────

  /// Gray 200 — dividers.
  final Color gray200;

  /// Gray 300 — borders, disabled track.
  final Color gray300;

  /// Gray 400 — placeholder text, disabled states.
  final Color gray400;

  /// Creates a color scheme with the given colors.
  const BootstrapItaliaColorScheme({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.info,
    required this.warning,
    required this.danger,
    required this.light,
    required this.dark,
    this.bodyColor = const Color(0xFF1A1A1A),
    this.bodyBg = const Color(0xFFFFFFFF),
    this.white = const Color(0xFFFFFFFF),
    this.black = const Color(0xFF000000),
    this.neutral1 = const Color(0xFF17324D),
    this.neutral2 = const Color(0xFFE6ECF2),
    this.gray200 = const Color(0xFFE6E6E6),
    this.gray300 = const Color(0xFFD4D4D4),
    this.gray400 = const Color(0xFFA3A3A3),
  });

  /// Standard Bootstrap Italia color scheme.
  static const BootstrapItaliaColorScheme standard = BootstrapItaliaColorScheme(
    primary: BootstrapItaliaColors.primary,
    secondary: BootstrapItaliaColors.secondary,
    success: BootstrapItaliaColors.success,
    info: BootstrapItaliaColors.info,
    warning: BootstrapItaliaColors.warning,
    danger: BootstrapItaliaColors.danger,
    light: BootstrapItaliaColors.light,
    dark: BootstrapItaliaColors.dark,
    bodyColor: BootstrapItaliaColors.bodyColor,
    bodyBg: BootstrapItaliaColors.bodyBg,
    white: BootstrapItaliaColors.white,
    black: BootstrapItaliaColors.black,
    neutral1: BootstrapItaliaColors.neutral1,
    neutral2: BootstrapItaliaColors.neutral2,
    gray200: BootstrapItaliaColors.gray200,
    gray300: BootstrapItaliaColors.gray300,
    gray400: BootstrapItaliaColors.gray400,
  );

  /// Returns the color for the given [variant] name.
  ///
  /// This eliminates the need for switch statements in components.
  /// Supports: primary, secondary, success, info, warning, danger, light, dark.
  Color forVariant(String variant) {
    return switch (variant) {
      'primary' => primary,
      'secondary' => secondary,
      'success' => success,
      'info' => info,
      'warning' => warning,
      'danger' => danger,
      'light' => light,
      'dark' => dark,
      _ => primary,
    };
  }

  /// Returns the foreground (text) color to use on top of [variant].
  Color foregroundForVariant(String variant) {
    return switch (variant) {
      'light' => dark,
      'warning' => white,
      _ => white,
    };
  }

  /// Returns alert-specific colors (background, foreground, border) for
  /// the given variant.
  ///
  /// Derived from Bootstrap Italia base colors using Bootstrap 5's alert
  /// formula: bg = tint-color(80%), border = tint-color(60%),
  /// text = shade-color(40%).
  ({Color background, Color foreground, Color border}) alertColorsForVariant(
      String variant) {
    return switch (variant) {
      'primary' => (
          background: const Color(0xFFCCE0F5),
          foreground: const Color(0xFF003D7A),
          border: const Color(0xFF99C2EB),
        ),
      'secondary' => (
          background: const Color(0xFFDEE3E7),
          foreground: const Color(0xFF38434F),
          border: const Color(0xFFBEC6CE),
        ),
      'success' => (
          background: const Color(0xFFCCE6DD),
          foreground: const Color(0xFF004D33),
          border: const Color(0xFF99CCBB),
        ),
      'danger' => (
          background: const Color(0xFFF5D6DC),
          foreground: const Color(0xFF7A1F2E),
          border: const Color(0xFFEBADB8),
        ),
      'warning' => (
          background: const Color(0xFFEBDFCC),
          foreground: const Color(0xFF5C3700),
          border: const Color(0xFFD6BE99),
        ),
      'info' || _ => (
          background: const Color(0xFFDEE3E7),
          foreground: const Color(0xFF38434F),
          border: const Color(0xFFBEC6CE),
        ),
    };
  }

  /// Returns callout-specific colors (accent, background) for the given variant.
  ///
  /// Variant mapping follows Bootstrap Italia's _callout.scss:
  /// success → $success, warning → $warning, danger → $danger,
  /// important → $success, note → $primary.
  ({Color accent, Color background}) calloutColorsForVariant(String variant) {
    return switch (variant) {
      'success' => (accent: success, background: const Color(0xFFF2F9F6)),
      'warning' => (accent: warning, background: const Color(0xFFFAF6F2)),
      'danger' => (accent: danger, background: const Color(0xFFFCF4F6)),
      'important' => (accent: success, background: const Color(0xFFF2F9F6)),
      'note' => (accent: primary, background: const Color(0xFFF2F7FC)),
      _ => (accent: primary, background: const Color(0xFFF2F7FC)),
    };
  }

  /// Creates a copy with the given overrides.
  BootstrapItaliaColorScheme copyWith({
    Color? primary,
    Color? secondary,
    Color? success,
    Color? info,
    Color? warning,
    Color? danger,
    Color? light,
    Color? dark,
    Color? bodyColor,
    Color? bodyBg,
    Color? white,
    Color? black,
    Color? neutral1,
    Color? neutral2,
    Color? gray200,
    Color? gray300,
    Color? gray400,
  }) {
    return BootstrapItaliaColorScheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      info: info ?? this.info,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      light: light ?? this.light,
      dark: dark ?? this.dark,
      bodyColor: bodyColor ?? this.bodyColor,
      bodyBg: bodyBg ?? this.bodyBg,
      white: white ?? this.white,
      black: black ?? this.black,
      neutral1: neutral1 ?? this.neutral1,
      neutral2: neutral2 ?? this.neutral2,
      gray200: gray200 ?? this.gray200,
      gray300: gray300 ?? this.gray300,
      gray400: gray400 ?? this.gray400,
    );
  }
}
