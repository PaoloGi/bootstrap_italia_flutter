import 'package:flutter/widgets.dart';

import '../tokens/breakpoints.dart';

/// A builder that provides the current [ItBreakpoint] based on available width.
///
/// Uses [LayoutBuilder] internally so it responds to the actual available
/// width of its parent, not the full screen width.
///
/// At minimum, [xs] must be provided. All other breakpoints fall back to the
/// next smaller defined builder.
///
/// ```dart
/// ItResponsiveBuilder(
///   xs: (context) => MobileLayout(),
///   md: (context) => TabletLayout(),
///   lg: (context) => DesktopLayout(),
/// )
/// ```
class ItResponsiveBuilder extends StatelessWidget {
  /// Builder for extra small screens (< 576px). Required.
  final WidgetBuilder xs;

  /// Builder for small screens (>= 576px). Falls back to [xs].
  final WidgetBuilder? sm;

  /// Builder for medium screens (>= 768px). Falls back to [sm] or [xs].
  final WidgetBuilder? md;

  /// Builder for large screens (>= 992px). Falls back to [md], [sm], or [xs].
  final WidgetBuilder? lg;

  /// Builder for extra large screens (>= 1200px). Falls back to [lg] etc.
  final WidgetBuilder? xl;

  /// Builder for extra extra large screens (>= 1400px). Falls back to [xl] etc.
  final WidgetBuilder? xxl;

  /// Creates a responsive builder widget.
  const ItResponsiveBuilder({
    super.key,
    required this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
    this.xxl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ItBreakpoint.fromWidth(constraints.maxWidth);
        final builder = _builderForBreakpoint(breakpoint);
        return builder(context);
      },
    );
  }

  WidgetBuilder _builderForBreakpoint(ItBreakpoint breakpoint) {
    return switch (breakpoint) {
      ItBreakpoint.xxl => xxl ?? xl ?? lg ?? md ?? sm ?? xs,
      ItBreakpoint.xl => xl ?? lg ?? md ?? sm ?? xs,
      ItBreakpoint.lg => lg ?? md ?? sm ?? xs,
      ItBreakpoint.md => md ?? sm ?? xs,
      ItBreakpoint.sm => sm ?? xs,
      ItBreakpoint.xs => xs,
    };
  }
}
