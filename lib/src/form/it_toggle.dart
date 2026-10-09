import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../a11y/it_focus_ring.dart';
import '../theme/theme_extensions.dart';
import '../tokens/spacing.dart';
import 'it_field_support.dart';
import 'it_form_metrics.dart';

/// A Bootstrap Italia toggle switch (`.toggles label > input + .lever`).
///
/// The label text sits on the left of a full-width row and the lever floats
/// right, matching `.toggles label { width:100%; height:32px }` and
/// `.lever { width:46px; height:16px; margin:8px 10px 0 16px; float:right }`.
///
/// ```dart
/// ItToggle(
///   value: true,
///   label: 'Notifiche email',
///   onChanged: (value) {},
/// )
/// ```
class ItToggle extends StatefulWidget {
  /// Whether the toggle is on.
  final bool value;

  /// The label text.
  final String? label;

  /// Called when the toggle value changes.
  final ValueChanged<bool>? onChanged;

  /// Whether the toggle is enabled.
  ///
  /// A disabled toggle is skipped by Tab traversal and is not operable, but
  /// stays in the semantics tree still reporting its position (WCAG 4.1.2).
  final bool enabled;

  /// Whether the field must be answered before the form can be submitted.
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

  /// Validation state tinting the label. [errorText] implies
  /// [ItValidationState.danger].
  final ItValidationState? validationState;

  /// Accessible name, when the control has no visible [label].
  final String? semanticLabel;

  /// `.form-check.form-check-group` — the docs' "Raggruppati visivamente".
  ///
  /// ```
  /// .form-check.form-check-group { padding:0 0 1rem 0; margin-bottom:1rem;
  ///                                box-shadow:inset 0 -1px 0 0 rgba(1,1,1,.1) }
  /// .form-check.form-check-group .form-text
  ///   { display:block; padding-right:3.25rem; margin-bottom:.5rem }
  /// ```
  ///
  /// Less happens here than on the checkbox and the radio, and that is the
  /// point: `.form-check-group` moves the indicator to the right, and
  /// `.lever { float:right }` has already put it there. So the grouped toggle
  /// gains only the row's separator, its 1rem of padding and margin, and the
  /// block treatment of its description — the row itself is untouched.
  final bool visuallyGrouped;

  /// Optional external focus node.
  final FocusNode? focusNode;

  /// Creates a Bootstrap Italia toggle.
  const ItToggle({
    super.key,
    required this.value,
    this.label,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.helperText,
    this.errorText,
    this.validationState,
    this.semanticLabel,
    this.visuallyGrouped = false,
    this.focusNode,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
  });

  /// Validates this control as part of an enclosing [Form], as
  /// `TextFormField.validator` does.
  ///
  /// Without it the control is not a [FormField], so a required ItToggle inside
  /// a `Form` compiles, looks correct, and is skipped entirely by
  /// `validate()`. That failure is silent — no crash, no warning, no visual
  /// difference — which is why this is a parameter and not a documentation
  /// note.
  final FormFieldValidator<bool>? validator;

  /// Called by `Form.save()`.
  final FormFieldSetter<bool>? onSaved;

  /// When the control re-validates. Defaults to [AutovalidateMode.disabled].
  final AutovalidateMode? autovalidateMode;

  @override
  State<ItToggle> createState() => _ItToggleState();
}

class _ItToggleState extends State<ItToggle> {
  /// `.toggles label { height: 32px }` plus its 8px bottom margin.
  static const double _rowHeight = 32;
  static const double _leverWidth = 46;
  static const double _leverHeight = 16;
  static const double _thumbSize = 26;

  bool _showFocus = false;

  bool get _interactive => widget.enabled && widget.onChanged != null;

  @override
  void didUpdateWidget(covariant ItToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    ItFieldValidation.announce(context, oldWidget.errorText, widget.errorText);
  }

  void _toggle() {
    if (!_interactive) return;
    _formState?.didChange(!widget.value);
    widget.onChanged!.call(!widget.value);
  }

  /// The message the enclosing [Form] produced, when participating in one.
  String? _formError;
  FormFieldState<bool>? _formState;

  /// An explicit `errorText` wins: a caller stating the error outright is more
  /// specific than a validator that may not have run yet.
  String? get _errorText => widget.errorText ?? _formError;

  bool get _isFormField => widget.validator != null || widget.onSaved != null;

  @override
  Widget build(BuildContext context) {
    if (!_isFormField) return _buildToggle(context);

    return FormField<bool>(
      initialValue: widget.value,
      autovalidateMode: widget.autovalidateMode,
      // The widget's own `value` is the truth: this is a controlled component,
      // and the FormField's copy goes stale as soon as the caller rebuilds.
      validator: widget.validator == null
          ? null
          : (_) => widget.validator!(widget.value),
      onSaved:
          widget.onSaved == null ? null : (_) => widget.onSaved!(widget.value),
      builder: (state) {
        _formState = state;
        if (state.errorText != _formError) {
          final previous = _formError;
          _formError = state.errorText;
          // WCAG 4.1.3: a message that appears after the fact takes no focus,
          // so nothing would otherwise announce it. Deferred: this is build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ItFieldValidation.announce(context, previous, _formError);
            }
          });
        }
        return _buildToggle(context);
      },
    );
  }

  Widget _buildToggle(BuildContext context) {
    final colors = resolveColorScheme(context);
    final value = widget.value;
    final label = widget.label;
    final enabled = widget.enabled;
    final validation =
        ItFieldValidation.effective(_errorText, widget.validationState);

    // .lever { background-color:#e6e9f2 } — unchanged when checked or disabled.
    // .lever:after { background-color:rgb(91,110.5,130) } unchecked,
    //               { background-color:#06c } checked,
    //               { background-color:#e6e9f2 } disabled.
    final Color thumbColor;
    if (!enabled) {
      thumbColor = ItFormMetrics.mutedChrome;
    } else if (value) {
      thumbColor = colors.primary;
    } else {
      thumbColor = ItFormMetrics.checkOutlineColor;
    }

    // `.form-check-input.is-invalid~.form-check-label { color:rgb(204,51,76.5) }`
    // — the toggle's input is a checkbox inside `.form-check .toggles label`,
    // so the label follows the validation tint.
    //
    // The lever deliberately does NOT: `.lever` and `.lever:after` are declared
    // for `:checked` and `[disabled]` and nothing else, so the kit has no
    // invalid appearance for the track or the thumb. Inventing one would put a
    // colour on screen that no rule in the stylesheet asks for.
    //
    // Nor does a warning tint anything: `~ .form-check-label` is declared for
    // `.is-valid` and `.is-invalid` only.
    final labelColor = (enabled
            ? ItFieldValidation.checkChromeColor(colors, validation)
            : null) ??
        colors.bodyColor;

    final lever = SizedBox(
      width: _leverWidth,
      height: _rowHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            // .lever { margin: 8px 10px 0 16px }
            top: 8,
            left: 0,
            child: ItFocusRing(
              // `.toggles label input[type=checkbox]:focus + .lever` —
              // Bootstrap Italia rings the lever, not the whole row.
              visible: _showFocus,
              radius: 10,
              child: Container(
                width: _leverWidth,
                height: _leverHeight,
                decoration: BoxDecoration(
                  color: ItFormMetrics.mutedChrome,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            // .lever:before/:after { top:-5px; left:-3px } → left:23px when on
            top: 8 - 5,
            left: value ? 23 : -3,
            child: Container(
              width: _thumbSize,
              height: _thumbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: thumbColor,
                border: const Border.fromBorderSide(
                  BorderSide(color: Color(0xFFFFFFFF), width: 2),
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: value ? const Size(14, 14) : const Size(10, 10),
                  painter: _ToggleGlyphPainter(checked: value),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final row = SizedBox(
      height: _rowHeight,
      child: Row(
        children: [
          if (label != null)
            Expanded(
              child: Text(
                label,
                style: ItFormMetrics.textStyle(
                  fontSize: ItFormMetrics.fontSize,
                  lineHeight: _rowHeight,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            )
          else
            const Spacer(),
          lever,
          // .lever { margin-right: 10px }
          const SizedBox(width: 10),
        ],
      ),
    );

    // WCAG 4.1.2: a switch must report a toggled state. Without it the control
    // reached assistive technology as a plain named button, so the user was
    // never told whether the setting was on.
    final control = MergeSemantics(
      child: Semantics(
        toggled: value,
        enabled: _interactive,
        isRequired: widget.required,
        label: widget.semanticLabel ?? label,
        // WCAG 3.3.1 / 3.3.2: carried on the control rather than left as loose
        // text below it.
        hint: ItFieldValidation.hint(_errorText, widget.helperText),
        validationResult: ItFieldValidation.result(validation),
        onTap: _interactive ? _toggle : null,
        child: FocusableActionDetector(
          focusNode: widget.focusNode,
          enabled: _interactive,
          mouseCursor: _interactive
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          // WCAG 2.1.1: Space is what flips a native checkbox-backed switch.
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
            // WCAG 2.5.8: the row is 32px tall and spans the full width, so
            // the whole of it — not just the 46x16 lever — is the target.
            behavior: HitTestBehavior.opaque,
            child: label != null ? ExcludeSemantics(child: row) : row,
          ),
        ),
      ),
    );

    return ItFieldSupport(
      helperText: widget.helperText,
      errorText: _errorText,
      grouped: widget.visuallyGrouped,
      child: control,
    );
  }
}

/// Draws the white glyph inside the toggle thumb: a cross when off
/// (`background-image` on `.lever:after`) and a check when on.
class _ToggleGlyphPainter extends CustomPainter {
  const _ToggleGlyphPainter({required this.checked});

  final bool checked;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, checked ? 0.5 : 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt;

    final w = size.width;
    final h = size.height;
    if (checked) {
      // 14x11 check mark.
      final path = Path()
        ..moveTo(w * 0.14, h * 0.52)
        ..lineTo(w * 0.40, h * 0.78)
        ..lineTo(w * 0.86, h * 0.24);
      canvas.drawPath(path, paint);
    } else {
      canvas.drawLine(const Offset(0, 0), Offset(w, h), paint);
      canvas.drawLine(Offset(w, 0), Offset(0, h), paint);
    }
  }

  @override
  bool shouldRepaint(_ToggleGlyphPainter oldDelegate) =>
      oldDelegate.checked != checked;
}

/// An option within an [ItToggleGroup].
class ItToggleOption<T> {
  /// The option value — the key under which this switch's "on" state is
  /// reported in [ItToggleGroup.values].
  final T value;

  /// The display label.
  final String label;

  /// Whether this switch is enabled. Same polarity as [ItToggle.enabled], so a
  /// group and the switches it builds cannot read in opposite directions.
  final bool enabled;

  /// `<small class="form-text">` for this row alone.
  ///
  /// The second "Raggruppati visivamente" example on the Toggles docs page
  /// gives every switch its own description. Read only when the group sets
  /// [ItToggleGroup.visuallyGrouped]: `.form-check-group .form-text
  /// { display:block }` is what turns it into a line of its own.
  final String? helperText;

  /// Creates a toggle option.
  const ItToggleOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.helperText,
  });
}

/// A `<fieldset>` of [ItToggle] switches under one `<legend>`.
///
/// ```html
/// <fieldset>
///   <legend>Gruppo di toggle</legend>
///   <div class="form-check form-check-group"> … </div>
///   <div class="form-check form-check-group"> … </div>
/// </fieldset>
/// ```
///
/// Two of the four sections on the Toggles docs page put their switches in a
/// fieldset with a legend, and the 2.10.0 breaking change makes that native
/// element mandatory for grouped inputs. Without a group widget the legend
/// could only be a loose `Text` above the rows — visually a caption, and to a
/// screen reader an unrelated paragraph.
///
/// The switches are **independent**, unlike [ItRadioGroup]: a set of toggles is
/// a set of separate answers that happen to share a caption. So the selection
/// is a `Set` of the values that are on, which is [ItCheckboxGroup]'s shape,
/// and turning one on or off does not touch the others.
///
/// ```dart
/// ItToggleGroup<String>(
///   label: 'Notifiche',
///   options: [
///     ItToggleOption(value: 'email', label: 'Email'),
///     ItToggleOption(value: 'sms', label: 'SMS'),
///   ],
///   values: {'email'},
///   onChanged: (values) {},
/// )
/// ```
class ItToggleGroup<T> extends StatelessWidget {
  /// `<legend>` — the caption for the set.
  final String? label;

  /// The available switches.
  final List<ItToggleOption<T>> options;

  /// The values whose switch is currently on.
  final Set<T> values;

  /// Called with the new set of values that are on.
  final ValueChanged<Set<T>>? onChanged;

  /// `.form-check-inline` — lays the switches out side by side.
  final bool inline;

  /// Whether the set must be answered before the form can be submitted.
  final bool required;

  /// `.form-text` — instruction for the set.
  final String? helperText;

  /// `.form-feedback` — validation message for the set.
  final String? errorText;

  /// Validation state tinting every label in the group. [errorText] implies
  /// [ItValidationState.danger].
  final ItValidationState? validationState;

  /// `.form-check.form-check-group` applied to every row — the docs'
  /// "Raggruppati visivamente".
  ///
  /// Not the same axis as [inline]: `.form-check-inline` lays rows out side by
  /// side, `.form-check-group` restyles each one. Combining them is not a
  /// layout the stylesheet describes, so [inline] wins and this is ignored when
  /// both are set.
  final bool visuallyGrouped;

  /// Creates a Bootstrap Italia toggle group.
  const ItToggleGroup({
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
      widgetName: 'ItToggleGroup',
    );
    final colors = resolveColorScheme(context);

    // `.form-check-inline` and `.form-check-group` are alternatives, not a
    // matrix — see [visuallyGrouped].
    final grouped = visuallyGrouped && !inline;

    final toggles = options.map((option) {
      return ItToggle(
        value: values.contains(option.value),
        label: option.label,
        enabled: option.enabled,
        visuallyGrouped: grouped,
        helperText: grouped ? option.helperText : null,
        // The tint is a property of the set, so it reaches every label; the
        // message and the instruction belong to the group and are painted once,
        // below it.
        validationState: validationState,
        onChanged: (on) {
          final next = Set<T>.from(values);
          if (on) {
            next.add(option.value);
          } else {
            next.remove(option.value);
          }
          onChanged?.call(next);
        },
      );
    }).toList();

    // WCAG 1.3.1 / 4.1.2: `<fieldset>` + `<legend>` is a labelled group, so the
    // caption is announced as the container's name rather than as a stray line
    // of text before the first switch.
    //
    // Deliberately NOT `SemanticsRole.radioGroup` (which [ItRadioGroup] uses):
    // these switches are independent, and announcing them as a radio group
    // would tell the user that choosing one clears the others.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      // WCAG 3.3.1 / 3.3.2: the instruction and the validation message describe
      // the *set*, so they are the group node's hint, not any one switch's.
      hint: ItFieldValidation.hint(errorText, helperText),
      isRequired: required,
      validationResult: ItFieldValidation.result(
        ItFieldValidation.effective(errorText, validationState),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            // Announced once, as the group's container label.
            ExcludeSemantics(
              child: Text(
                label!,
                // `fieldset legend { font-size:.875rem; font-weight:700;
                //                    line-height:calc(2.5rem - 1px) }` — the
                // same treatment [ItCheckboxGroup] and [ItRadioGroup] give it.
                style: ItFormMetrics.textStyle(
                  fontSize: 14,
                  lineHeight: 39,
                  fontWeight: FontWeight.w700,
                  color: colors.bodyColor,
                ),
              ),
            ),
          if (inline)
            Wrap(
              // `.form-check-inline { display:inline-block; margin-right:1rem }`
              spacing: BootstrapItaliaSpacing.space4,
              runSpacing: BootstrapItaliaSpacing.space2,
              children: [
                // An inline switch cannot take the full-width row the default
                // layout uses — `.toggles label { width:100% }` would make one
                // switch fill the line — so each is given the intrinsic width
                // of its own label plus its lever.
                for (final toggle in toggles) IntrinsicWidth(child: toggle),
              ],
            )
          else if (grouped)
            // No extra gap: `.form-check-group` already declares
            // `padding-bottom:1rem; margin-bottom:1rem`.
            ...toggles
          else
            // `.toggles label { margin-bottom: 8px }`
            ...toggles.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: t,
              ),
            ),
          // Inside the Column rather than around it, so the two lines stay
          // left-aligned with the labels and the group node above keeps
          // carrying them.
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
