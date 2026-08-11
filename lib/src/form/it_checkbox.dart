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

    final row = SizedBox(
      // .form-check [type=checkbox]+label { line-height: var(--bs-body-line-height) }
      height: ItFormMetrics.textLineHeight,
      child: Stack(
        children: [
          // Without a label the row is just the box plus its 4px margins.
          if (label == null && labelWidget == null)
            const SizedBox(width: 28, height: ItFormMetrics.textLineHeight),
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
          if (indeterminate)
            const Positioned(
              left: 4,
              top: 11,
              child: SizedBox(
                width: 12,
                height: 2,
                child: ColoredBox(color: Color(0xFFFFFFFF)),
              ),
            ),
          if (label != null || labelWidget != null)
            Padding(
              // .form-check […]+label { padding-left: 2rem }
              padding: const EdgeInsets.only(left: 32),
              child: labelWidget ??
                  Text(
                    label!,
                    style: ItFormMetrics.textStyle(
                      fontSize: ItFormMetrics.fontSize,
                      lineHeight: ItFormMetrics.textLineHeight,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
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
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    final checkboxes = options.map((option) {
      return ItCheckbox(
        value: values.contains(option.value),
        label: option.label,
        enabled: option.enabled,
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

  /// Creates a checkbox option.
  const ItCheckboxOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });
}
