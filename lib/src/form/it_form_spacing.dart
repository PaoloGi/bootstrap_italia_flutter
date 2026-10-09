import 'it_form_metrics.dart';

/// The two numbers a caller laying out a form needs, and no more.
///
/// [ItFormMetrics] records all 41 measurements the form CSS specifies, but
/// most are internal — the width of an input-group addon is the kit's business.
/// These two are not: they are what a caller has to know to place a field
/// without it colliding with something.
///
/// A floating label is `position: absolute; top: 0` inside its form group and
/// rises on activation, **outside the control's own box and unclipped**. Two
/// consequences, one handled by the kit and one that cannot be:
///
///  * the field *below* is protected by [groupMarginBottom], which every
///    floating-label control reserves by default (`groupMargin`);
///  * the field *above the first one* is not. `.form-group` sets
///    `margin-top: 0`, so upstream the page provides that space — and so must
///    a Flutter caller. [floatingLabelHeadroom] is how much.
///
/// The second one is easy to miss: it looks fine until a heading or a card
/// edge happens to sit within 34px of the first field. Measured at −17.25px in
/// a real form before this constant existed.
abstract final class ItFormSpacing {
  /// `.form-group { margin-bottom: 3rem }` — 48px.
  ///
  /// Reserved automatically below every floating-label control. Exposed so a
  /// caller who turns `groupMargin` off knows what to supply instead.
  static const double groupMarginBottom = ItFormMetrics.groupMarginBottom;

  /// How far a floating label rises above its own control — 33.15px.
  ///
  /// `transform: translateY(-85%)` of the 39px label line box. Leave at least
  /// this much clear above the FIRST field in a form; the kit cannot, because
  /// the space belongs to whatever is above it.
  static const double floatingLabelHeadroom = -ItFormMetrics.activeLabelOffset;
}
