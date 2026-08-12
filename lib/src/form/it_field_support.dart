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

  /// Debug-only checks shared by every form control.
  ///
  /// The six form widgets had no asserts at all, while carrying the most
  /// misuse-prone parameters in the package. These are the cases where the
  /// resulting widget is *silently* wrong — it renders, it does not throw, and
  /// the defect is only visible to someone using assistive technology.
  ///
  /// Deliberately not asserted: `validationState: danger` without [errorText].
  /// It looks like the same class of bug, but the control still reports
  /// `SemanticsValidationResult.invalid`, so the *state* does reach AT even
  /// when the *description* is rendered by the application somewhere else — a
  /// form-level error summary being the normal case. Asserting it would reject
  /// a correct design.
  static void debugCheckConfig({
    required String? label,
    required bool required,
    required int optionCount,
    required Iterable<Object?> optionValues,
    required String widgetName,
  }) {
    assert(
      !required || (label != null && label.trim().isNotEmpty),
      '$widgetName sets `required: true` with no label.\n'
      'The required state is announced against the control name, so with no '
      'name AT says "required" about nothing at all (WCAG 4.1.2 Name, Role, '
      'Value; 3.3.2 Labels or Instructions). Give it a label, or drop '
      '`required` and validate at the form level.',
    );
    assert(
      optionCount > 0,
      '$widgetName was given no options.\n'
      'It still renders its label, its required marker and its group role, so '
      'AT announces a control that cannot be operated (WCAG 4.1.2). Render it '
      'once the options are known — a spinner or a message is a better empty '
      'state than an empty control.',
    );
    assert(
      optionValues.toSet().length == optionCount,
      '$widgetName has duplicate option values.\n'
      'Selection is matched by value, so duplicates select together and the '
      'user sees one click change two rows. Values must be unique; use the '
      'label for anything that repeats.',
    );
  }

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
    this.grouped = false,
  });

  /// The control the text is describing.
  final Widget child;

  /// `.form-text` — the instruction, shown while the control is not in error.
  final String? helperText;

  /// `.form-feedback` — the validation message.
  final String? errorText;

  /// Whether the control is a `.form-check.form-check-group` row.
  ///
  /// ```
  /// .form-check.form-check-group { padding:0 0 1rem 0; margin-bottom:1rem;
  ///                                box-shadow:inset 0 -1px 0 0 rgba(1,1,1,.1) }
  /// .form-check.form-check-group .form-text
  ///   { display:block; padding-right:3.25rem; margin-bottom:.5rem }
  /// ```
  ///
  /// The row's separator lives here rather than in the three check controls
  /// because it belongs to the `.form-check` box, which in the kit's markup
  /// encloses **both** the label and its `<small class="form-text">` — the
  /// hairline is drawn under the description, not between it and the label.
  /// Three of this package's six form controls carry this variant, so a copy
  /// each is three chances for them to disagree about a padding.
  ///
  /// The instruction itself changes in three ways, none cosmetic. It becomes a
  /// **block**, so it no longer shares a line box with the control's strut and
  /// the inline baseline correction below would push it off its own line. It
  /// takes the same 3.25rem right gutter the label does, so a long description
  /// stops clear of the indicator instead of running under it. And it sits in a
  /// row whose padding the group already owns, so the 8px left padding of the
  /// `.form-group` case would indent it away from the label it describes.
  ///
  /// That last difference is why the base rules apply at all: this row is not
  /// inside a `.form-group` in the kit's own markup, so
  /// `.form-group small.form-text { margin:0; padding:.25rem .5rem }` never
  /// reaches it and the base `.form-text { margin-top:.25rem;
  /// font-size:.875rem }` does.
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final helper = helperText;
    final error = errorText;

    // Checked before the early return below: a grouped row carries the
    // separator and its spacing whether or not it has any supporting text.
    if (grouped) return _buildGrouped(child, helper, error);

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

  /// The `.form-check.form-check-group` variant of the block above.
  ///
  /// Same two lines, same exclusion from the semantics tree, same
  /// "message replaces instruction" rule — only the box model differs, and it
  /// differs because the row is a `.form-check` rather than a `.form-group`.
  Widget _buildGrouped(Widget child, String? helper, String? error) {
    return Container(
      // `.form-check.form-check-group { padding:0 0 1rem 0; margin-bottom:1rem;
      //                                 box-shadow:inset 0 -1px 0 0 rgba(1,1,1,.1) }`
      //
      // An inset shadow offset one pixel up, with no blur and no spread, paints
      // exactly the bottom edge of the padding box — which is a 1px bottom
      // border, drawn inside the element. `Border` is that, and it participates
      // in layout the way the shadow does not, which is what keeps the 1rem
      // padding above it and the 1rem margin below it distinguishable.
      padding: const EdgeInsets.only(
        bottom: ItFormMetrics.checkGroupPaddingBottom,
      ),
      margin: const EdgeInsets.only(
        bottom: ItFormMetrics.checkGroupMarginBottom,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ItFormMetrics.checkGroupSeparator),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          // `.form-text { margin-top:.25rem; font-size:.875rem;
          //               color:hsl(210,17%,44%) }` plus
          // `.form-check.form-check-group .form-text
          //   { display:block; padding-right:3.25rem; margin-bottom:.5rem }`.
          if (error == null && helper != null)
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: ItFormMetrics.checkGroupHelperTopMargin,
                  right: ItFormMetrics.checkGroupGutter,
                  bottom: ItFormMetrics.checkGroupHelperBottomMargin,
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
          // `.form-feedback { margin:.25rem 0 0 .5rem; font-size:.75rem }` —
          // unchanged by `.form-check-group`, which declares nothing for it.
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
      ),
    );
  }
}
