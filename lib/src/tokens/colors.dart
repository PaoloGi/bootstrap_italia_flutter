import 'package:flutter/painting.dart';

/// All Bootstrap Italia design system colors.
///
/// Based on Bootstrap Italia v2.18.0 CSS custom properties.
/// Primary color is "Blu Italia" (#0066CC), the identifying color
/// of the Italian public administration brand identity.
abstract final class BootstrapItaliaColors {
  // ── Primary & Semantic ──────────────────────────────────────────

  /// Blu Italia — the primary brand color. hsl(210, 100%, 40%)
  static const Color primary = Color(0xFF0066CC);

  /// Secondary gray-blue. hsl(210, 17%, 44%)
  static const Color secondary = Color(0xFF5D7083);

  /// Success green. hsl(160, 100%, 25%)
  static const Color success = Color(0xFF008055);

  /// Info color (same as secondary). hsl(210, 17%, 44%)
  static const Color info = Color(0xFF5D7083);

  /// Warning orange-brown. hsl(36, 100%, 30%)
  static const Color warning = Color(0xFF995C00);

  /// Danger red. hsl(350, 60%, 50%)
  static const Color danger = Color(0xFFCC334D);

  /// Light lavender. hsl(255, 32%, 93%)
  static const Color light = Color(0xFFE9E6F2);

  /// Dark blue-gray. hsl(210, 54%, 20%)
  static const Color dark = Color(0xFF17334F);

  /// White.
  static const Color white = Color(0xFFFFFFFF);

  /// Black.
  static const Color black = Color(0xFF000000);

  // ── Gray Scale ──────────────────────────────────────────────────

  /// Gray 100. hsl(0, 0%, 96%)
  static const Color gray100 = Color(0xFFF5F5F5);

  /// Gray 200. hsl(0, 0%, 90%)
  static const Color gray200 = Color(0xFFE6E6E6);

  /// Gray 300. hsl(0, 0%, 83%)
  static const Color gray300 = Color(0xFFD4D4D4);

  /// Gray 400. hsl(0, 0%, 64%)
  static const Color gray400 = Color(0xFFA3A3A3);

  /// Gray 500. hsl(0, 0%, 45%)
  static const Color gray500 = Color(0xFF737373);

  /// Gray 600. hsl(0, 0%, 32%)
  static const Color gray600 = Color(0xFF525252);

  /// Gray 700. hsl(0, 0%, 25%)
  static const Color gray700 = Color(0xFF404040);

  /// Gray 800. hsl(0, 0%, 15%)
  static const Color gray800 = Color(0xFF262626);

  /// Gray 900. hsl(0, 0%, 10%)
  static const Color gray900 = Color(0xFF1A1A1A);

  /// Secondary gray. hsl(210, 17%, 44%)
  static const Color graySecondary = Color(0xFF5D7083);

  /// Tertiary gray. hsl(205, 21%, 45%)
  static const Color grayTertiary = Color(0xFF5B6F82);

  /// Quaternary gray. hsl(238, 100%, 100%)
  static const Color grayQuaternary = Color(0xFFFDFDFF);

  // ── Accent Colors ──────────────────────────────────────────────

  /// Indigo. hsl(243, 100%, 65%)
  static const Color indigo = Color(0xFF4D4DFF);

  /// Purple. hsl(243, 100%, 80%)
  static const Color purple = Color(0xFF9999FF);

  /// Pink. hsl(350, 100%, 85%)
  static const Color pink = Color(0xFFFFB3BF);

  /// Orange. hsl(36, 100%, 30%)
  static const Color orange = Color(0xFF995C00);

  /// Teal. hsl(178, 90%, 32%)
  static const Color teal = Color(0xFF08A3A0);

  /// Cyan. hsl(178, 100%, 50%)
  static const Color cyan = Color(0xFF00FFF7);

  // ── Italia-Specific Colors ─────────────────────────────────────

  /// Analogue 1 — blue-violet.
  static const Color analogue1 = Color(0xFF3126FF);

  /// Analogue 2 — turquoise.
  static const Color analogue2 = Color(0xFF0BD9D2);

  /// Complementary 1 — coral-red.
  static const Color complementary1 = Color(0xFFF73E5A);

  /// Complementary 2 — amber.
  static const Color complementary2 = Color(0xFFFF9900);

  /// Complementary 3 — green.
  static const Color complementary3 = Color(0xFF00CF86);

  /// Neutral 1 — dark navy. Used for body text.
  static const Color neutral1 = Color(0xFF17324D);

  /// Neutral 2 — light blue-gray. Used for backgrounds.
  static const Color neutral2 = Color(0xFFE6ECF2);

  // ── Body defaults ──────────────────────────────────────────────

  /// Default body text color. hsl(0, 0%, 10%)
  static const Color bodyColor = Color(0xFF1A1A1A);

  /// Default body background. hsl(0, 0%, 100%)
  static const Color bodyBg = Color(0xFFFFFFFF);
}
