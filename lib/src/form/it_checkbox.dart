import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../a11y/it_focus_ring.dart';
import '../theme/theme_extensions.dart';
import '../tokens/spacing.dart';
import 'it_field_support.dart';
import 'it_form_metrics.dart';

/// A Bootstrap Italia checkbox (`.form-check [type=checkbox] + label`).
///
/// The box is a 20x20 square with a 2px border and a 4px radius, offset 4px
/// from the row's left and top edges, and the label text starts at 32px
/// (`padding-left: 2rem`) in 16px semibold — exactly as the compiled
/// Bootstrap Italia stylesheet specifies.
///
/// The whole row is one keyboard-operable target exposed to assistive
/// technology as a checkbox with its checked state, matching the native
/// `<input type=checkbox> + <label>` the stylesheet is written against.
///
/// ```dart
/// ItCheckbox(
///   value: true,
///   label: 'Accetto i termini e le condizioni',
///   onChanged: (value) {},
/// )
/// ```
class ItCheckbox extends StatefulWidget {
  /// Whether the checkbox is checked.
  final bool value;

  /// Whether the checkbox is in the indeterminate ("semi-checked") state.
  ///
  /// Driven by the caller, never by tapping — `input.semi-checked` is a
  /// *computed* parent state ("select all", partially satisfied), not a third
  /// stop in a user-facing cycle. A `tristate` flag used to sit alongside this
  /// promising a false -> true -> null cycle; it never emitted null, and could
  /// not have, since [value] is non-nullable. Bootstrap Italia specifies no
  /// such cycle, so it was removed rather than implemented.
  final bool indeterminate;

  /// The label text displayed next to the checkbox.
  final String? label;

  /// Custom label widget. Overrides [label] if provided.
  final Widget? labelWidget;

  /// Called when the checkbox value changes.
  ///
  /// `ValueChanged<bool>`, not `ValueChanged<bool?>`. The nullable form was a
  /// leftover from the deleted `tristate` flag: [value] is non-nullable, so a
  /// null could never be produced, and every caller had to write `?? false` for
  /// a case that could not arise. [indeterminate] is caller-driven display
  /// state and is deliberately not folded back into this callback — see its
  /// doc.
  final ValueChanged<bool>? onChanged;

  /// Whether the checkbox is enabled.
  ///
  /// A disabled checkbox is skipped by Tab traversal and is not operable by
  /// pointer or keyboard, but stays in the semantics tree reporting both its
  /// checked and its disabled state (WCAG 4.1.2) — inert is not the same as
  /// absent.
  final bool enabled;

  /// Whether the field must be filled in before the form can be submitted.
  ///
  /// Exposed to assistive technology as the required state (WCAG 3.3.2).
  final bool required;

  /// `.form-text` — instruction shown below the control.
  final String? helperText;

  /// `.form-feedback` — validation message shown below the control.
  ///
  /// It is also carried on the control's own semantics node, so a screen reader
  /// hears it as part of the field (WCAG 3.3.1 Error Identification).
  final String? errorText;

  /// Validation state tinting the box and the label. [errorText] implies
  /// [ItValidationState.danger].
  final ItValidationState? validationState;

  /// Accessible name, when [labelWidget] carries the visible text or the
  /// control has no visible label at all (WCAG 4.1.2 requires a name).
  final String? semanticLabel;

  /// `.form-check.form-check-group` — the docs' "Raggruppati visivamente".
  ///
  /// ```
  /// .form-check.form-check-group { padding:0 0 1rem 0; margin-bottom:1rem;
  ///                                box-shadow:inset 0 -1px 0 0 rgba(1,1,1,.1) }
  /// .form-check.form-check-group [type=checkbox]+label
  ///   { position:static; padding-left:0; padding-right:3.25rem }
  /// .form-check.form-check-group [type=checkbox]+label::after,::before
  ///   { right:0px; left:auto }
  /// ```
  ///
  /// The row spans the full width, the label reads from the left and the box
  /// moves to the right-hand gutter, with a hairline beneath separating it from
  /// the next row. Only the box's *anchor* flips: every offset inside it is the
  /// resting variant's, mirrored, which is why the sheet parks the grouped tick
  /// at `right:11px` — the same 1px inside the box's leading edge it sits at on
  /// the left.
  ///
  /// Purely presentational. Nothing about the control's semantics changes, and
  /// [ItCheckboxGroup] is still what binds several boxes to one value: this is
  /// the treatment applied *to* rows, not a grouping of them.
  final bool visuallyGrouped;

  /// Optional external focus node.
  final FocusNode? focusNode;

  /// Creates a Bootstrap Italia checkbox.
  const ItCheckbox({
    super.key,
    required this.value,
    this.indeterminate = false,
    this.label,
    this.labelWidget,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.helperText,
    this.errorText,
    this.validationState,
    this.semanticLabel,
    this.visuallyGrouped = false,
    this.focusNode,
  });

  @override
  State<ItCheckbox> createState() => _ItCheckboxState();
}

class _ItCheckboxState extends State<ItCheckbox> {
  bool _showFocus = false;

  bool get _interactive => widget.enabled && widget.onChanged != null;

  @override
  void didUpdateWidget(covariant ItCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    ItFieldValidation.announce(context, oldWidget.errorText, widget.errorText);
  }

  void _toggle() {
    if (!_interactive) return;
    widget.onChanged!.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final value = widget.value;
    final label = widget.label;
    final labelWidget = widget.labelWidget;
    final indeterminate = widget.indeterminate;
    final enabled = widget.enabled;
    final validation =
        ItFieldValidation.effective(widget.errorText, widget.validationState);

    // .form-check [type=checkbox]:checked+label::after
    //   { border-color:#06c; background-color:#06c }
    // .form-check [type=checkbox]:not(:checked)+label::after
    //   { background-color:transparent; border-color:rgb(91,110.5,130) }
    // .form-check [type=checkbox]:disabled:not(:checked)+label::after
    //   { border-color:#e6e9f2; background-color:#fff }
    // .form-check [type=checkbox]:disabled:checked+label::after
    //   { background-color:#e6e9f2; border-color:#e6e9f2 }
    //
    // .form-check-input.is-invalid          { border-color:rgb(204,51,76.5) }
    // .form-check-input.is-invalid:checked  { background-color:rgb(204,51,76.5) }
    // — the validation tint replaces the accent but not the disabled chrome,
    // because `:disabled` is what stops the control being answerable at all.
    final checked = indeterminate || value;
    final validationColor =
        validation == null ? null : ItFieldValidation.color(colors, validation);
    final Color boxColor;
    final Color fill;
    if (!enabled) {
      boxColor = ItFormMetrics.mutedChrome;
      fill = checked ? ItFormMetrics.mutedChrome : const Color(0xFFFFFFFF);
    } else if (validationColor != null) {
      boxColor = validationColor;
      fill = checked ? validationColor : const Color(0x00000000);
    } else if (indeterminate) {
      // `input.semi-checked:not(:checked)+label::after
      //   { border-color:rgb(32.13,123.165,214.2);
      //     background-color:rgb(32.13,123.165,214.2) }`
      //
      // A *different* blue from `:checked`, and deliberately so — see
      // [ItFormMetrics.semiCheckedFill]. Painting `colors.primary` here, which
      // is what this did, made "some selected" indistinguishable from "all
      // selected" for anyone who could not resolve the bar-versus-tick glyph.
      boxColor = ItFormMetrics.semiCheckedFill;
      fill = ItFormMetrics.semiCheckedFill;
    } else if (checked) {
      boxColor = colors.primary;
      fill = colors.primary;
    } else {
      boxColor = ItFormMetrics.checkOutlineColor;
      fill = const Color(0x00000000);
    }

    // .form-check-input.is-invalid~.form-check-label { color:rgb(204,51,76.5) }
    final labelColor =
        enabled && validationColor != null ? validationColor : colors.bodyColor;

    // The box, its tick and its indeterminate bar, in a box of their own.
    //
    // Extracted so the two layouts can place the *same* pixels on either side
    // of the label: `.form-check-group` moves the anchor from `left` to
    // `right` and changes nothing else, and a second hand-offset copy of these
    // three children is exactly how the two variants would drift apart.
    //
    // 28px wide because the 20px box carries a 4px margin on each side; the
    // resting layout's `left: 4` and the grouped layout's `right: 4` are then
    // the same edge, measured from opposite sides.
    final indicator = SizedBox(
      width: 28,
      height: ItFormMetrics.textLineHeight,
      child: Stack(
        children: [
          // ::after — the box itself: 20x20, margin 4px, 2px border, radius 4px.
          Positioned(
            left: 4,
            top: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: boxColor, width: 2),
              ),
            ),
          ),
          // ::before — the tick, drawn as CSS does: an 8x13 box with only its
          // right and bottom borders, rotated 40 degrees about its
          // bottom-right corner.
          if (checked && !indeterminate)
            Positioned(
              left: 5,
              top: 6,
              child: Opacity(
                opacity: 0.8,
                child: Transform.rotate(
                  angle: 40 * math.pi / 180,
                  origin: const Offset(4, 6.5),
                  child: Container(
                    width: 8,
                    height: 13,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFFFFFFF), width: 2),
                        bottom: BorderSide(color: Color(0xFFFFFFFF), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // input.semi-checked:not(:checked)+label::before
          //   { top:11px; left:4px; width:12px; height:2px; background:#fff }
          //
          // The `margin: 2px 4px` of the base `::before` rule survives — the
          // semi-checked rule resets the borders and the transform but not the
          // margin — so the bar really lands at (8, 13), not (4, 11). Those
          // four and two pixels are the difference between a bar centred in its
          // box and one crowding its top-left corner: the box's interior is
          // 6..22 across and 6..22 down, and (8, 13) centres a 12x2 bar in it
          // exactly.
          if (indeterminate)
            const Positioned(
              left: 8,
              top: 13,
              child: SizedBox(
                width: 12,
                height: 2,
                child: ColoredBox(color: Color(0xFFFFFFFF)),
              ),
            ),
        ],
      ),
    );

    final Widget? labelChild = label == null && labelWidget == null
        ? null
        : labelWidget ??
            Text(
              label!,
              style: ItFormMetrics.textStyle(
                fontSize: ItFormMetrics.fontSize,
                lineHeight: ItFormMetrics.textLineHeight,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            );

    final row = widget.visuallyGrouped
        // `.form-check.form-check-group [type=checkbox]+label
        //    { position:static; padding-left:0; padding-right:3.25rem }`
        // with `::after { right:0; left:auto }`: the row fills the width, the
        // label reads from the left and the box parks in the 3.25rem gutter.
        ? SizedBox(
            height: ItFormMetrics.textLineHeight,
            child: Row(
              children: [
                Expanded(child: labelChild ?? const SizedBox.shrink()),
                SizedBox(
                  width: ItFormMetrics.checkGroupGutter,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: indicator,
                  ),
                ),
              ],
            ),
          )
        : SizedBox(
            // .form-check [type=checkbox]+label
            //   { line-height: var(--bs-body-line-height) }
            height: ItFormMetrics.textLineHeight,
            child: Stack(
              children: [
                // Without a label the row is just the box plus its 4px margins.
                indicator,
                if (labelChild != null)
                  Padding(
                    // .form-check […]+label { padding-left: 2rem }
                    padding: const EdgeInsets.only(left: 32),
                    child: labelChild,
                  ),
              ],
            ),
          );

    // WCAG 4.1.2: the box is hand-painted, so nothing in `row` tells assistive
    // technology this is a checkbox or whether it is checked — it previously
    // surfaced as a bare tappable label. `MergeSemantics` collapses the row and
    // the focus node into the single node a native checkbox produces.
    final control = MergeSemantics(
      child: Semantics(
        checked: indeterminate ? null : value,
        mixed: indeterminate ? true : null,
        enabled: _interactive,
        isRequired: widget.required,
        label: widget.semanticLabel ?? label,
        // WCAG 3.3.1 / 3.3.2: the two lines below the box are painted as
        // siblings, so they are carried here instead of being left as loose
        // text a screen reader cannot connect to the control.
        hint: ItFieldValidation.hint(widget.errorText, widget.helperText),
        validationResult: ItFieldValidation.result(validation),
        onTap: _interactive ? _toggle : null,
        child: ItFocusRing(
          // `.form-check [type=checkbox]:focus + label` — the indicator goes
          // round the whole row, not just the box.
          visible: _showFocus,
          radius: 4,
          child: FocusableActionDetector(
            focusNode: widget.focusNode,
            enabled: _interactive,
            mouseCursor: _interactive
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            // WCAG 2.1.1 Keyboard: Space toggles a checkbox natively; Enter is
            // accepted too because Flutter's activate intent covers both.
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            },
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  _toggle();
                  return null;
                },
              ),
            },
            // WCAG 2.4.7: only for keyboard focus, as the stylesheet's
            // `:not([data-focus-mouse=true])` guard specifies.
            onShowFocusHighlight: (show) {
              if (show != _showFocus) setState(() => _showFocus = show);
            },
            child: GestureDetector(
              onTap: _interactive ? _toggle : null,
              // The enclosing `Semantics` already carries `onTap`, so this
              // detector must not contribute a node of its own: it produced an
              // unnamed tappable child inside the named control, which a screen
              // reader offers as a second, meaningless stop. Hit testing and
              // behaviour are unchanged — only the duplicate node goes.
              excludeFromSemantics: true,
              // WCAG 2.5.8 Target Size: hit testing used to defer to the
              // children, leaving the 20x20 box (and the gaps around it) as the
              // only target. The row is 24px tall and at least 28px wide, so
              // making it opaque yields a conforming target without moving a
              // single painted pixel.
              behavior: HitTestBehavior.opaque,
              // The wrapper already carries the text label, so excluding the
              // painted one keeps it from being announced twice. A custom
              // [labelWidget] is left in the tree instead, so that it can
              // supply the accessible name when [semanticLabel] is not given.
              child: label != null ? ExcludeSemantics(child: row) : row,
            ),
          ),
        ),
      ),
    );

    return ItFieldSupport(
      helperText: widget.helperText,
      errorText: widget.errorText,
      grouped: widget.visuallyGrouped,
      child: control,
    );
  }
}

/// A group of [ItCheckbox] widgets.
///
/// ```dart
/// ItCheckboxGroup(
///   label: 'Seleziona opzioni',
///   options: [
///     ItCheckboxOption(value: 'a', label: 'Opzione A'),
///     ItCheckboxOption(value: 'b', label: 'Opzione B'),
///   ],
///   values: {'a'},
///   onChanged: (values) {},
/// )
/// ```
class ItCheckboxGroup<T> extends StatelessWidget {
  /// Group label.
  final String? label;

  /// The available options.
  final List<ItCheckboxOption<T>> options;

  /// Currently selected values.
  final Set<T> values;

  /// Called when selection changes.
  final ValueChanged<Set<T>>? onChanged;

  /// Whether to display options in a horizontal row.
  final bool inline;

  /// Whether a choice must be made before the form can be submitted.
  final bool required;

  /// `.form-check.form-check-group .form-text` — instruction for the set.
  final String? helperText;

  /// `.form-feedback` — validation message for the set.
  final String? errorText;

  /// Validation state tinting every box in the group. [errorText] implies
  /// [ItValidationState.danger].
  final ItValidationState? validationState;

  /// `.form-check.form-check-group` applied to every row — the docs'
  /// "Raggruppati visivamente".
  ///
  /// Reaches each [ItCheckbox] as [ItCheckbox.visuallyGrouped]. In the kit's
  /// markup the class sits on the individual `.form-check`, not on the
  /// `<fieldset>` around them, so a caller can also apply it row by row; this
  /// is the shorthand for the case the docs actually show, where every row in
  /// the fieldset carries it.
  ///
  /// Note that it is not the same axis as [inline]: `.form-check-inline` lays
  /// rows out side by side, `.form-check-group` restyles each one. Combining
  /// them is not a layout the stylesheet describes — a full-width row with a
  /// right-hand indicator has nothing to sit beside — so [inline] wins and this
  /// is ignored when both are set.
  final bool visuallyGrouped;

  /// Creates a checkbox group.
  const ItCheckboxGroup({
    super.key,
    this.label,
    required this.options,
    required this.values,
    this.onChanged,
    this.inline = false,
    this.required = false,
    this.helperText,
    this.errorText,
    this.validationState,
    this.visuallyGrouped = false,
  });

  @override
  Widget build(BuildContext context) {
    ItFieldValidation.debugCheckConfig(
      label: label,
      required: required,
      optionCount: options.length,
      optionValues: options.map((o) => o.value),
      widgetName: 'ItCheckboxGroup',
    );
    final colors = resolveColorScheme(context);

    // `.form-check-inline` and `.form-check-group` are alternatives, not a
    // matrix — see [visuallyGrouped].
    final grouped = visuallyGrouped && !inline;

    final checkboxes = options.map((option) {
      return ItCheckbox(
        value: values.contains(option.value),
        label: option.label,
        enabled: option.enabled,
        visuallyGrouped: grouped,
        // Per-row `<small class="form-text">`, which only the grouped layout
        // has room for: outside it the description would be painted below the
        // box with nothing reserving the space, and `.form-check-group
        // .form-text { display:block }` is the rule that makes it a line of its
        // own at all.
        helperText: grouped ? option.helperText : null,
        // The tint is a property of the set, so it reaches every box; the
        // message and the instruction belong to the group and are painted once,
        // below it.
        validationState: validationState,
        onChanged: (checked) {
          final newValues = Set<T>.from(values);
          if (checked) {
            newValues.add(option.value);
          } else {
            newValues.remove(option.value);
          }
          onChanged?.call(newValues);
        },
      );
    }).toList();

    // WCAG 1.3.1: the group's caption is a plain paragraph above the boxes, so
    // it is announced as a container label for the whole set rather than being
    // left visually — but not programmatically — associated with it.
    //
    // WCAG 3.3.1 / 3.3.2: the instruction and the validation message describe
    // the *set*, so they are the group node's hint, not any one box's.
    return Semantics(
      container: label != null || helperText != null || errorText != null,
      explicitChildNodes: true,
      label: label,
      hint: ItFieldValidation.hint(errorText, helperText),
      isRequired: required,
      validationResult: ItFieldValidation.result(
        ItFieldValidation.effective(errorText, validationState),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            ExcludeSemantics(
              child: Text(
                label!,
                style: ItFormMetrics.textStyle(
                  fontSize: 14,
                  lineHeight: 39,
                  fontWeight: FontWeight.w700,
                  color: colors.bodyColor,
                ),
              ),
            ),
          ],
          if (inline)
            Wrap(
              spacing: BootstrapItaliaSpacing.space4,
              runSpacing: BootstrapItaliaSpacing.space2,
              children: checkboxes,
            )
          else if (grouped)
            // No extra gap: `.form-check-group` already declares
            // `padding-bottom:1rem; margin-bottom:1rem`, and stacking the
            // resting `.form-check + .form-check { margin-top:.5rem }` on top
            // of it would push the rows 8px further apart than the sheet does.
            ...checkboxes
          else
            // .form-check + .form-check { margin-top: .5rem }
            ...checkboxes.map(
              (cb) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: cb,
              ),
            ),
          // Placed inside the Column rather than wrapping it, so the two lines
          // stay left-aligned with the boxes and the group's own semantics node
          // (above) keeps carrying them.
          if (helperText != null || errorText != null)
            ItFieldSupport(
              helperText: helperText,
              errorText: errorText,
              child: const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

/// An option within an [ItCheckboxGroup].
class ItCheckboxOption<T> {
  /// The option value.
  final T value;

  /// The display label.
  final String label;

  /// Whether this option is enabled. Same polarity as [ItCheckbox.enabled], so
  /// a group and the boxes it builds cannot read in opposite directions.
  final bool enabled;

  /// `<small class="form-text">` for this row alone.
  ///
  /// The second "Raggruppati visivamente" example in the docs gives every
  /// option its own description. It is read only when the group sets
  /// [ItCheckboxGroup.visuallyGrouped]: `.form-check-group .form-text
  /// { display:block }` is what turns it into a line of its own, and without
  /// that rule the kit paints no per-row description anywhere.
  ///
  /// Distinct from [ItCheckboxGroup.helperText], which describes the whole set
  /// and is announced on the group's node; this one is announced on the row's,
  /// which is the `aria-describedby` the docs put on each input.
  final String? helperText;

  /// Creates a checkbox option.
  const ItCheckboxOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.helperText,
  });
}
