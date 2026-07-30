/// Bootstrap Italia responsive breakpoints.
///
/// Matches the six breakpoints defined in Bootstrap Italia's grid system.
enum ItBreakpoint {
  /// Extra small: < 576px (mobile portrait).
  xs(0),

  /// Small: >= 576px (mobile landscape).
  sm(576),

  /// Medium: >= 768px (tablet).
  md(768),

  /// Large: >= 992px (desktop).
  lg(992),

  /// Extra large: >= 1200px (large desktop).
  xl(1200),

  /// Extra extra large: >= 1400px (wide desktop).
  xxl(1400);

  /// The minimum width in logical pixels for this breakpoint.
  final double minWidth;

  const ItBreakpoint(this.minWidth);

  /// Returns the breakpoint for the given [width].
  static ItBreakpoint fromWidth(double width) {
    if (width >= ItBreakpoint.xxl.minWidth) return ItBreakpoint.xxl;
    if (width >= ItBreakpoint.xl.minWidth) return ItBreakpoint.xl;
    if (width >= ItBreakpoint.lg.minWidth) return ItBreakpoint.lg;
    if (width >= ItBreakpoint.md.minWidth) return ItBreakpoint.md;
    if (width >= ItBreakpoint.sm.minWidth) return ItBreakpoint.sm;
    return ItBreakpoint.xs;
  }

  /// Whether this breakpoint is at or above [other].
  bool operator >=(ItBreakpoint other) => minWidth >= other.minWidth;

  /// Whether this breakpoint is above [other].
  bool operator >(ItBreakpoint other) => minWidth > other.minWidth;

  /// Whether this breakpoint is below [other].
  bool operator <(ItBreakpoint other) => minWidth < other.minWidth;

  /// Whether this breakpoint is at or below [other].
  bool operator <=(ItBreakpoint other) => minWidth <= other.minWidth;
}

/// Container max-widths at each breakpoint.
///
/// Matches Bootstrap Italia's `.container` max-width values.
abstract final class ItContainerWidths {
  /// Max-width at sm breakpoint: 540px.
  static const double sm = 540;

  /// Max-width at md breakpoint: 720px.
  static const double md = 720;

  /// Max-width at lg breakpoint: 960px.
  static const double lg = 960;

  /// Max-width at xl breakpoint: 1176px.
  static const double xl = 1176;

  /// Max-width at xxl breakpoint: 1320px.
  static const double xxl = 1320;

  /// Returns the container max-width for the given [breakpoint].
  ///
  /// Returns `double.infinity` for xs (fluid, no max-width).
  static double forBreakpoint(ItBreakpoint breakpoint) {
    return switch (breakpoint) {
      ItBreakpoint.xs => double.infinity,
      ItBreakpoint.sm => sm,
      ItBreakpoint.md => md,
      ItBreakpoint.lg => lg,
      ItBreakpoint.xl => xl,
      ItBreakpoint.xxl => xxl,
    };
  }
}
