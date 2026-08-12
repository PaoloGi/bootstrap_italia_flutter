import 'package:flutter/widgets.dart';

import '../../l10n/it_localizations.dart';
import '../../theme/theme_extensions.dart';
import 'progress_spinner.dart';

/// Size variants for [ItSpinner].
///
/// Spelled out rather than carrying the CSS suffix; the `size-*` classes stay
/// in the citations below, where they are evidence. See [ItButtonSize].
enum ItSpinnerSize {
  /// 32px — `.progress-spinner.size-sm`.
  small(32),

  /// 48px — the base `.progress-spinner`. Default.
  medium(48),

  /// 64px — `.progress-spinner.size-lg`.
  large(64),

  /// 80px — `.progress-spinner.size-xl`.
  extraLarge(80);

  /// The diameter in logical pixels.
  final double diameter;

  /// The stroke width.
  ///
  /// `border: 4px` is declared once on `.progress-spinner` and never overridden
  /// by a size modifier, so every size shares it — the ring does NOT scale with
  /// the diameter.
  double get strokeWidth => 4;

  const ItSpinnerSize(this.diameter);
}

/// A Bootstrap Italia loading spinner (`.progress-spinner`).
///
/// The figure is painted from the stylesheet by [ItProgressSpinner] rather than
/// delegating to Material's `CircularProgressIndicator`, which draws a
/// different shape on a different clock. See doc/adr/0001.
///
/// ```dart
/// ItSpinner()                              // spinning, single arc
/// ItSpinner(size: ItSpinnerSize.small)
/// ItSpinner(doubleRing: true)              // spinning, two arcs
/// ItSpinner(animating: false)              // the static track ring only
/// ```
class ItSpinner extends StatelessWidget {
  /// The arc colour. Defaults to the theme's `secondary`.
  ///
  /// `.progress-spinner-active:not(.progress-spinner-double)
  ///   { border-color: hsl(210,17%,44%) }` and, for the double form,
  /// `.progress-spinner-double .progress-spinner-inner:after
  ///   { border: 4px solid hsl(210,17%,44%) }` — the same value in both, and
  /// byte-identical to `--bs-secondary` in a role that warrants the token: the
  /// arc is the figure's only chromatic element, painted over the grey track.
  ///
  /// This defaulted to `primary`, which matched neither the stylesheet nor
  /// [ItProgressSpinner] — the widget it delegates the painting to, which has
  /// always resolved `secondary`. No parity capture arbitrates it, because the
  /// only spinner capture is the *inactive* ring and an inactive ring has no
  /// arc at all; the CSS is the whole of the evidence, and it is unambiguous.
  final Color? color;

  /// The size variant. Defaults to [ItSpinnerSize.medium].
  final ItSpinnerSize size;

  /// Whether the arc turns.
  ///
  /// Maps to `.progress-spinner-active`. Defaults to true: a loading indicator
  /// that does not move is not a loading indicator. Set false for the bare
  /// `.progress-spinner` track ring.
  final bool animating;

  /// Whether to paint `.progress-spinner-double` — two oscillating arcs instead
  /// of one.
  ///
  /// Orthogonal to [animating], exactly as the two CSS classes are. A single
  /// flag used to drive both, which made the plain animating spinner — the most
  /// common case there is — impossible to express, and made the default render
  /// a motionless ring.
  final bool doubleRing;

  /// Semantic label for accessibility.
  ///
  /// Defaults to `'Caricamento in corso'`, with no
  /// delegate installed. Pass one to say what is loading; the locale can only
  /// say *that* something is.
  final String? semanticLabel;

  /// Creates a Bootstrap Italia spinner.
  const ItSpinner({
    super.key,
    this.color,
    this.size = ItSpinnerSize.medium,
    this.animating = true,
    this.doubleRing = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? resolveColorScheme(context).secondary;

    // The label is the only thing AT has to go on — the spinner is a bare
    // painted figure with no text — so it is kept exactly as it was.
    return Semantics(
      label: semanticLabel ?? ItLocalizations.of(context).loading,
      child: ItProgressSpinner(
        diameter: size.diameter,
        strokeWidth: size.strokeWidth,
        color: effectiveColor,
        doubleRing: doubleRing,
        animating: animating,
      ),
    );
  }
}
