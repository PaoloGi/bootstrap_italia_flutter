import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../theme/bootstrap_italia_theme_data.dart';
import 'it_form_metrics.dart';

/// Validation state of a form control.
///
/// Bootstrap Italia carries the state on the control itself (`.is-valid` /
/// `.is-invalid` on `.form-control`, `.form-select` and `.form-check-input`)
/// and, separately, in the message below it (`.form-feedback`). Both halves are
/// modelled here: the state tints the control's chrome, [ItFieldSupport] paints
/// the message.
///
/// Lives in its own file rather than in `it_input.dart` because all six form
/// controls now share it.
enum ItValidationState {
  /// `.is-valid` — `border-color: rgb(0,127.5,85)`.
  success,

  /// The kit's third state. Bootstrap declares no `.is-warning` on a control,
  /// only `.warning-feedback { color: rgb(153,91.8,0) }` for the message, so
  /// the chrome follows the same shape as the other two with the warning token.
  warning,

  /// `.is-invalid` — `border-color: rgb(204,51,76.5)`.
  danger,
}

/// The validation half of a form control's shared surface.
///
/// Six controls resolve the same four questions — which state is really in
/// force, what colour it paints, what it reports to assistive technology, and
/// what the control says when a screen reader reaches it. Answering them in one
/// place is what keeps `ItInput`, `ItSelect` and the three check controls from
/// drifting apart, which is exactly how `errorText` came to exist on two of six
/// in the first place.
abstract final class ItFieldValidation {
  /// The state the control actually renders.
  ///
  /// A message always implies the invalid state: `.is-invalid~.invalid-feedback
  /// { display: block }` is the only way the kit shows one, so a caller who
  /// passes [errorText] has already said the control is in error and should not
  /// have to say it twice.
  static ItValidationState? effective(
    String? errorText,
    ItValidationState? validationState,
  ) =>
      errorText != null ? ItValidationState.danger : validationState;

  /// The chrome colour for [state].
  ///
  /// `.form-control.is-invalid`, `.form-select.is-invalid` and
  /// `.form-check-input.is-invalid` all declare `border-color:rgb(204,51,76.5)`,
  /// which is byte-identical to `--bs-danger` and sits in the role that token
  /// exists for; `.is-valid` likewise carries `rgb(0,127.5,85)` = `--bs-success`
  /// and `.warning-feedback` `rgb(153,91.8,0)` = `--bs-warning`. All three are
  /// tokens, so they follow the scheme — a retinted administration gets its own
  /// validation palette.
  ///
  /// The *message* colour is the opposite case and is deliberately not here:
  /// [ItFormMetrics.feedbackDangerColor] is a standalone `#d9364f` backing no
  /// custom property.
  static Color color(
    BootstrapItaliaColorScheme colors,
    ItValidationState state,
  ) =>
      switch (state) {
        ItValidationState.success => colors.success,
        ItValidationState.warning => colors.warning,
        ItValidationState.danger => colors.danger,
      };

  /// What the control reports to assistive technology.
  ///
  /// WCAG 3.3.1 Error Identification: the invalid state has to be on the
  /// control's own node, so a screen reader announces it on focus rather than
  /// only when the page is read in order.
  static SemanticsValidationResult result(ItValidationState? effective) =>
      effective == ItValidationState.danger
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none;

  /// The text a screen reader hears as part of the control.
  ///
  /// WCAG 3.3.1 / 3.3.2: both the instruction and the validation message are
  /// painted as siblings of the control, so on their own they reach the user as
  /// loose text with nothing tying them to it. Carried as the control's hint
  /// instead — and the message wins, because a caller showing both is showing
  /// the error *about* the instruction.
  static String? hint(String? errorText, String? helperText) =>
      errorText ?? helperText;

  /// Pushes a newly-appeared validation message to assistive technology.
  ///
  /// WCAG 4.1.3 Status Messages: a message that appears after the fact takes no
  /// focus, so nothing would otherwise announce it. Call from `didUpdateWidget`.
  /// The message is *also* part of the control's own semantics (see [hint]),
  /// which is what a user who navigates back to it hears.
  static void announce(
    BuildContext context,
    String? previous,
    String? current,
  ) {
    if (current == null || current == previous) return;
    SemanticsService.sendAnnouncement(
      View.of(context),
      current,
      Directionality.of(context),
      assertiveness: Assertiveness.assertive,
    );
  }
}

/// The `.form-text` instruction and `.form-feedback` validation message
/// Bootstrap Italia paints beneath a form control.
///
/// ```
/// .form-group small.form-text        { margin:0; padding:.25rem .5rem;
///                                      font-size:.875rem }
/// .form-check.form-check-group .form-text { display:block; margin-bottom:.5rem }
/// .form-feedback                     { margin-left:.5rem; margin-top:.25rem;
///                                      width:100%; font-size:.75rem }
/// ```
///
/// Both lines are `ExcludeSemantics`: they belong to the control's own node as
/// its hint (see [ItFieldValidation.hint]), and a second unassociated copy makes
/// a screen reader say the message twice with nothing connecting the stray one
/// to the field.
///
/// With neither text present this returns [child] untouched rather than an
/// empty [Column]. A control that takes no supporting text must lay out exactly
/// as it did before it gained the parameters: all seventeen resting form parity
/// captures are measured through this widget, and a [Column] round the whole
/// package's form controls would loosen every one of their cross-axis
/// constraints to buy nothing.
class ItFieldSupport extends StatelessWidget {
  /// Creates the supporting-text block for a form control.
  const ItFieldSupport({
    super.key,
    required this.child,
    this.helperText,
    this.errorText,
  });

  /// The control the text is describing.
  final Widget child;

  /// `.form-text` — the instruction, shown while the control is not in error.
  final String? helperText;

  /// `.form-feedback` — the validation message.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final helper = helperText;
    final error = errorText;
    if (helper == null && error == null) return child;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        // `.form-group small.form-text { padding:.25rem .5rem; font-size:.875rem }`
        //
        // `small` is an *inline* element, so the line it sits on is as tall as
        // the group's strut (24px) and its baseline comes from that strut, not
        // from the 21px line box of its own 14px type.
        //
        // The message replaces the instruction rather than stacking under it:
        // `.is-invalid~.invalid-feedback { display:block }` is what reveals the
        // message, and the kit shows one line of supporting text at a time.
        if (error == null && helper != null)
          ExcludeSemantics(
            child: SizedBox(
              height: ItFormMetrics.helperBlockHeight,
              child: Baseline(
                baseline: ItFormMetrics.groupStrutBaseline,
                baselineType: TextBaseline.alphabetic,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: ItFormMetrics.horizontalPadding,
                  ),
                  child: Text(
                    helper,
                    style: ItFormMetrics.textStyle(
                      fontSize: ItFormMetrics.helperFontSize,
                      lineHeight: ItFormMetrics.helperLineHeight,
                      color: ItFormMetrics.borderColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        // `.form-feedback { margin:.25rem 0 0 .5rem; font-size:.75rem }`
        if (error != null)
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.only(
                left: ItFormMetrics.feedbackLeftMargin,
                top: ItFormMetrics.feedbackTopMargin,
              ),
              child: Text(
                error,
                style: ItFormMetrics.textStyle(
                  fontSize: ItFormMetrics.feedbackFontSize,
                  lineHeight: ItFormMetrics.feedbackLineHeight,
                  color: ItFormMetrics.feedbackDangerColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
