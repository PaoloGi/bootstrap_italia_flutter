import 'package:flutter/widgets.dart';

import '../tokens/breakpoints.dart';
import '../tokens/spacing.dart';

/// A centered container with a max-width that adapts to the current breakpoint.
///
/// Mimics Bootstrap Italia's `.container` behavior:
/// - xs: fluid (no max-width)
/// - sm: 540px
/// - md: 720px
/// - lg: 960px
/// - xl: 1176px
/// - xxl: 1320px
///
/// ```dart
/// ItContainer(
///   child: Column(
///     children: [
///       Text('Centered content with max-width'),
///     ],
///   ),
/// )
/// ```
class ItContainer extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// Whether to always be fluid (no max-width). Defaults to false.
  final bool fluid;

  /// Horizontal padding inside the container. Defaults to 12px (half gutter).
  final double? padding;

  /// Creates a Bootstrap Italia container.
  const ItContainer({
    super.key,
    required this.child,
    this.fluid = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = padding ?? BootstrapItaliaSpacing.space2 + 4;

        if (fluid) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: child,
          );
        }

        final breakpoint = ItBreakpoint.fromWidth(constraints.maxWidth);
        final maxWidth = ItContainerWidths.forBreakpoint(breakpoint);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
