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

  /// Strips the letter-spacing Material's default typography would otherwise
  /// contribute.
  ///
  /// `ThemeData(textTheme: ...)` MERGES onto Material's defaults rather than
  /// replacing them, so any field we leave null inherits Material's tracking —
  /// `bodyMedium` 0.25px, `bodyLarge` 0.5px, `titleMedium` 0.15px. That leaks
  /// into every `Text` through the ambient `DefaultTextStyle`, widening a
  /// 39-character line by ~10px. Bootstrap Italia sets letter-spacing only in a
  /// handful of scoped rules (uppercase labels and similar); body copy is the
  /// browser default of zero, so we zero it across the board here and let
  /// individual components opt back in.
  static TextTheme _withoutLetterSpacing(TextTheme t) {
    TextStyle? f(TextStyle? s) => s?.copyWith(letterSpacing: 0);
    return t.copyWith(
      displayLarge: f(t.displayLarge),
      displayMedium: f(t.displayMedium),
      displaySmall: f(t.displaySmall),
      headlineLarge: f(t.headlineLarge),
      headlineMedium: f(t.headlineMedium),
      headlineSmall: f(t.headlineSmall),
      titleLarge: f(t.titleLarge),
      titleMedium: f(t.titleMedium),
      titleSmall: f(t.titleSmall),
      bodyLarge: f(t.bodyLarge),
      bodyMedium: f(t.bodyMedium),
      bodySmall: f(t.bodySmall),
      labelLarge: f(t.labelLarge),
      labelMedium: f(t.labelMedium),
      labelSmall: f(t.labelSmall),
    );
  }

  /// Converts this theme to a Material [ThemeData] for compatibility.
  ///
  /// This allows Bootstrap Italia components to work alongside Material widgets
  /// and provides sensible defaults for Material components using Italia tokens.
  ThemeData toThemeData({Brightness brightness = Brightness.light}) {
    const typography = BootstrapItaliaTypography.desktop;

    final base = ThemeData(
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
      // Bootstrap Italia has no ripple: interaction is expressed purely through
      // colour transitions (`--bs-btn-hover-bg`, `--bs-btn-active-bg`). Material's
      // default InkSparkle is both wrong for the design system and a liability —
      // it loads `shaders/ink_sparkle.frag`, which fails outright on engine/
      // framework artifact mismatches and takes any test that taps a Material
      // widget down with it.
      splashFactory: NoSplash.splashFactory,
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

    // Applied after construction so it also covers the styles we never set
    // (labelLarge and friends), which come wholly from Material's defaults.
    return base.copyWith(textTheme: _withoutLetterSpacing(base.textTheme));
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

/// The semantic colour roles a component variant can map onto.
///
/// Bootstrap Italia gives several components the same eight-way colour choice
/// (`.btn-primary`, `.badge-primary`, `.alert-primary`, ...). Each component
/// declares its own enum, because not all of them offer all eight — an alert
/// has no `light` or `dark`. This enum is the shared vocabulary those component
/// enums translate *into*, via the `.variantColor` extensions next to each one.
///
/// The translation is deliberately a per-component exhaustive switch rather
/// than a name lookup: it is what makes an unmapped variant fail to compile.
enum ItVariantColor {
  /// `--bs-primary`, hsl(210, 100%, 40%).
  primary,

  /// `--bs-secondary`, hsl(210, 17%, 44%).
  secondary,

  /// `--bs-success`, hsl(160, 100%, 25%).
  success,

  /// `--bs-info`, hsl(210, 17%, 44%).
  info,

  /// `--bs-warning`, hsl(36, 100%, 30%).
  warning,

  /// `--bs-danger`, hsl(350, 60%, 50%).
  danger,

  /// `--bs-light`, hsl(255, 32.2%, 92.6%).
  light,

  /// `--bs-dark`, hsl(210, 54%, 20%).
  dark,
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

  /// Returns the colour for the given semantic [variant].
  ///
  /// Takes an [ItVariantColor] rather than a string. It previously took
  /// `variant.name` from four unrelated component enums and fell through to
  /// `primary` on anything unrecognised, so a typo or a newly-added enum value
  /// rendered as primary with no error anywhere — the component looked
  /// deliberately blue. With an enum the switch is exhaustive, so adding a
  /// variant that has no colour is a compile error at every call site.
  Color forVariant(ItVariantColor variant) {
    return switch (variant) {
      ItVariantColor.primary => primary,
      ItVariantColor.secondary => secondary,
      ItVariantColor.success => success,
      ItVariantColor.info => info,
      ItVariantColor.warning => warning,
      ItVariantColor.danger => danger,
      ItVariantColor.light => light,
      ItVariantColor.dark => dark,
    };
  }

  /// Returns the foreground (text) colour to place on top of [variant].
  ///
  /// Listed exhaustively rather than defaulting to white, so that a new variant
  /// has to state its foreground instead of inheriting one that may not meet
  /// §1.4.3 Contrast (Minimum) against its fill.
  Color foregroundForVariant(ItVariantColor variant) {
    return switch (variant) {
      // `.btn-light` is a near-white fill; white on white is unreadable.
      ItVariantColor.light => dark,
      ItVariantColor.primary ||
      ItVariantColor.secondary ||
      ItVariantColor.success ||
      ItVariantColor.info ||
      // hsl(36, 100%, 30%) is dark enough for white (5.07:1), unlike
      // Bootstrap 5's yellow warning, which is not.
      ItVariantColor.warning ||
      ItVariantColor.danger ||
      ItVariantColor.dark =>
        white,
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
