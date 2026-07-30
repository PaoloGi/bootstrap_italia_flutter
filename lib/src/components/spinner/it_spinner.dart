import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

/// Size variants for [ItSpinner].
enum ItSpinnerSize {
  /// Small spinner: 24px.
  sm(24, 2),

  /// Medium spinner: 48px. Default.
  md(48, 3);

  /// The diameter in logical pixels.
  final double diameter;

  /// The stroke width.
  final double strokeWidth;

  const ItSpinnerSize(this.diameter, this.strokeWidth);
}

/// A Bootstrap Italia loading spinner.
///
/// Displays a circular progress indicator styled according to Bootstrap Italia.
///
/// ```dart
/// ItSpinner()
/// ItSpinner(size: ItSpinnerSize.sm)
/// ItSpinner(active: true, color: Colors.blue)
/// ```
class ItSpinner extends StatelessWidget {
  /// The spinner color. Defaults to the theme's primary color.
  final Color? color;

  /// The size variant. Defaults to [ItSpinnerSize.md].
  final ItSpinnerSize size;

  /// Whether to show the "active" double-ring variant.
  /// When true, shows an outer ring alongside the spinning indicator.
  final bool active;

  /// Semantic label for accessibility.
  final String semanticLabel;

  /// Creates a Bootstrap Italia spinner.
  const ItSpinner({
    super.key,
    this.color,
    this.size = ItSpinnerSize.md,
    this.active = false,
    this.semanticLabel = 'Caricamento in corso',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? resolveColorScheme(context).primary;

    final spinner = SizedBox(
      width: size.diameter,
      height: size.diameter,
      child: CircularProgressIndicator(
        strokeWidth: size.strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );

    if (!active) {
      return Semantics(
        label: semanticLabel,
        child: spinner,
      );
    }

    // Active variant: outer ring + inner spinner
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: size.diameter,
        height: size.diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer static ring
            SizedBox(
              width: size.diameter,
              height: size.diameter,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: size.strokeWidth * 0.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(effectiveColor.withAlpha(51)),
              ),
            ),
            // Inner spinning indicator
            SizedBox(
              width: size.diameter * 0.7,
              height: size.diameter * 0.7,
              child: CircularProgressIndicator(
                strokeWidth: size.strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
