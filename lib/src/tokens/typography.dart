import 'package:flutter/painting.dart';

/// Font family constants for Bootstrap Italia.
abstract final class BootstrapItaliaFontFamily {
  /// Default sans-serif font for all UI text.
  static const String sansSerif = 'TitilliumWeb';

  /// Serif font for long-form reading content.
  static const String serif = 'Lora';

  /// Monospace font for code and numeric data.
  static const String monospace = 'RobotoMono';

  /// Package name for font resolution.
  /// Must match `name:` in pubspec.yaml — Flutter resolves a bundled font as
  /// `packages/<package>/<family>`, so a stale value here does not error, it
  /// silently falls back to the platform font everywhere.
  static const String package = 'bootstrap_italia_flutter';
}

/// Typography system for Bootstrap Italia.
///
/// Provides responsive text styles that switch between mobile and desktop
/// sizes at the 576px breakpoint, matching Bootstrap Italia's CSS behavior.
class BootstrapItaliaTypography {
  /// Heading 1 style.
  final TextStyle h1;

  /// Heading 2 style.
  final TextStyle h2;

  /// Heading 3 style.
  final TextStyle h3;

  /// Heading 4 style.
  final TextStyle h4;

  /// Heading 5 style.
  final TextStyle h5;

  /// Heading 6 style.
  final TextStyle h6;

  /// Standard body text.
  final TextStyle bodyText;

  /// Small body text.
  final TextStyle bodySmall;

  /// Lead paragraph text (emphasized).
  final TextStyle lead;

  /// Display heading (larger than h1).
  final TextStyle display1;

  const BootstrapItaliaTypography._({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.h5,
    required this.h6,
    required this.bodyText,
    required this.bodySmall,
    required this.lead,
    required this.display1,
  });

  /// Mobile typography styles (screen width < 576px).
  static const BootstrapItaliaTypography mobile = BootstrapItaliaTypography._(
    h1: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 40,
      height: 48 / 40,
      fontWeight: FontWeight.w700,
    ),
    h2: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w700,
    ),
    h3: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 28,
      height: 32 / 28,
      fontWeight: FontWeight.w700,
    ),
    h4: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 24,
      height: 28 / 24,
      fontWeight: FontWeight.w600,
    ),
    h5: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 20,
      height: 24 / 20,
      fontWeight: FontWeight.w400,
    ),
    h6: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w600,
    ),
    bodyText: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
    ),
    lead: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w400,
    ),
    display1: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 52,
      height: 60 / 52,
      fontWeight: FontWeight.w700,
    ),
  );

  /// Desktop typography styles (screen width >= 576px).
  static const BootstrapItaliaTypography desktop = BootstrapItaliaTypography._(
    h1: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 48,
      height: 60 / 48,
      fontWeight: FontWeight.w700,
    ),
    h2: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 40,
      height: 48 / 40,
      fontWeight: FontWeight.w700,
    ),
    h3: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w700,
    ),
    h4: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 28,
      height: 40 / 28,
      fontWeight: FontWeight.w600,
    ),
    h5: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 24,
      height: 40 / 24,
      fontWeight: FontWeight.w400,
    ),
    h6: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 18,
      height: 28 / 18,
      fontWeight: FontWeight.w600,
    ),
    bodyText: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 18,
      height: 28 / 18,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
    ),
    lead: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w400,
    ),
    display1: TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      fontSize: 64,
      height: 72 / 64,
      fontWeight: FontWeight.w700,
    ),
  );

  /// Returns the appropriate typography for the given [screenWidth].
  ///
  /// Uses mobile styles below 576px, desktop styles at 576px and above,
  /// matching Bootstrap Italia's responsive breakpoint.
  factory BootstrapItaliaTypography.responsive(double screenWidth) {
    return screenWidth < 576 ? mobile : desktop;
  }
}
