import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../a11y/it_focus_ring.dart';
import '../l10n/it_localizations.dart';
import '../theme/theme_extensions.dart';
import '../tokens/spacing.dart';
import 'it_field_group_scope.dart';
import 'it_field_support.dart';
import 'it_form_metrics.dart';

/// An option within an [ItRadioGroup].
class ItRadioOption<T> {
  /// The option value.
  final T value;

  /// The display label.
  final String label;

  /// Whether this option is enabled. Same polarity as [ItRadio.enabled], so a
  /// group and the radios it builds cannot read in opposite directions.
  final bool enabled;

  /// `<small class="form-text">` for this row alone.
  ///
  /// The second "Raggruppati visivamente" example in the docs gives every
  /// option its own description. It is read only when the group sets
  /// [ItRadioGroup.visuallyGrouped]: `.form-check-group .form-text
  /// { display:block }` is what turns it into a line of its own, and without
  /// that rule the kit paints no per-row description anywhere.
  ///
  /// Distinct from [ItRadioGroup.helperText], which describes the whole set and
  /// is announced on the group's node; this one is announced on the row's,
  /// which is the `aria-describedby` the docs put on each input.
  final String? helperText;

  /// Creates a radio option.
  const ItRadioOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.helperText,
  });
}

/// A single Bootstrap Italia radio button (`.form-check [type=radio] + label`).
///
/// The ring is a 20x20 circle with a 2px border offset 5px from the row's
/// left and top edges; when selected it is filled with a dot scaled to 64% of
/// the ring, and the label starts at 32px (`padding-left: 2rem`) in 16px
/// semibold.
///
/// Use [ItRadioGroup] to bind several of these to one value; the group is what
/// wires up arrow-key navigation and the mutually-exclusive semantics that let
/// a screen reader announce "1 of 3".
class ItRadio<T> extends StatefulWidget {
  /// What this radio stands for — `<input type="radio" value="...">`.
  ///
  /// It is selected when this equals [groupValue].
  final T value;

  /// The current selection of the group this radio belongs to.
  ///
  /// `null` means nothing is selected yet. The caller holds it, exactly as
  /// with Flutter's own `Radio`.
  ///
  /// Required — and nullable — on purpose: the old shape took a `bool value`,
  /// so leaving this optional would let `ItRadio(value: true)` keep compiling
  /// as an `ItRadio<bool>` that is never selected, because nothing equals a
  /// `groupValue` of null. A compile error is the kinder failure.
  final T? groupValue;

  /// The label text.
  final String? label;

  /// Called with [value] when the user selects this radio.
  ///
  /// It used to be a `ValueChanged<bool>` that always emitted `true`, which
  /// gave every caller a parameter carrying no information and made the
  /// selection something they had to reconstruct from which radio they had
  /// wired the callback to. A radio is the one control of the three that
  /// cannot be switched off by operating it — HTML fires no `change` when a
  /// checked radio is clicked — so "what happened" is *which value was
  /// chosen*, which is what arrives here:
  ///
  /// ```dart
  /// ItRadio<Fase>(
  ///   value: Fase.preallarme,
  ///   groupValue: fase,
  ///   onChanged: (next) => setState(() => fase = next),
  /// )
  /// ```
  ///
  /// [ItCheckbox] and [ItToggle] keep `ValueChanged<bool>`, because for them
  /// the boolean is real. Symmetry between the three is not worth a parameter
  /// that is the same on every call.
  ///
  /// Use [ItRadioGroup] to bind several radios to one value without holding
  /// each one yourself; it also supplies the arrow-key walk and the
  /// "1 of 3" announcement.
  final ValueChanged<T>? onChanged;

  /// Whether the radio is enabled.
  ///
  /// A disabled radio is skipped by Tab traversal and by [ItRadioGroup]'s
  /// arrow-key walk, but stays in the semantics tree still reporting whether it
  /// is the current choice (WCAG 4.1.2).
  final bool enabled;

  /// Whether a choice must be made before the form can be submitted.
  ///
  /// Exposed to assistive technology as the required state (WCAG 3.3.2). On a
  /// standalone radio only — [ItRadioGroup] carries its own, on the group node,
  /// which is where a screen reader looks for it.
  final bool required;

  /// `.form-text` — instruction shown below the control.
  final String? helperText;

  /// `.form-feedback` — validation message shown below the control.
  ///
  /// It is also carried on the control's own semantics node, so a screen reader
  /// hears it as part of the field (WCAG 3.3.1 Error Identification).
  final String? errorText;

  /// Validation state tinting the ring, the dot and the label. [errorText]
  /// implies [ItValidationState.danger].
  final ItValidationState? validationState;

  /// Accessible name, when it must differ from the visible [label] — or when
  /// there is no visible label at all, which WCAG 4.1.2 does not permit.
  final String? semanticLabel;

  /// `.form-check.form-check-group` — the docs' "Raggruppati visivamente".
  ///
  /// ```
  /// .form-check.form-check-group { padding:0 0 1rem 0; margin-bottom:1rem;
  ///                                box-shadow:inset 0 -1px 0 0 rgba(1,1,1,.1) }
  /// .form-check.form-check-group [type=radio]+label
  ///   { position:static; padding-left:0; padding-right:3.25rem }
  /// .form-check.form-check-group [type=radio]+label::after,::before
  ///   { right:0px; left:auto }
  /// ```
  ///
  /// The row spans the full width, the label reads from the left and the ring
  /// moves to the right-hand gutter, with a hairline beneath separating it from
  /// the next row. Only the ring's *anchor* flips; its 5px margin, its 20px
  /// diameter and the `scale(.64)` dot inside it are unchanged.
  ///
  /// Purely presentational — the exclusive-selection semantics are unaffected.
  final bool visuallyGrouped;

  /// Optional external focus node. [ItRadioGroup] supplies one per option so
  /// it can move focus with the arrow keys.
  final FocusNode? focusNode;

  /// Position of this radio within its group, 1-based, for the "n of m"
  /// announcement. Set by [ItRadioGroup].
  final int? indexInGroup;

  /// Number of radios in the group. Set by [ItRadioGroup].
  final int? groupLength;

  /// Creates a Bootstrap Italia radio button.
  const ItRadio({
    super.key,
    required this.value,
    required this.groupValue,
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
    this.indexInGroup,
    this.groupLength,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
  });

  /// Validates this control as part of an enclosing [Form], as
  /// `TextFormField.validator` does.
  ///
  /// Without it the control is not a [FormField], so a required ItRadio inside
  /// a `Form` compiles, looks correct, and is skipped entirely by
  /// `validate()`. That failure is silent — no crash, no warning, no visual
  /// difference — which is why this is a parameter and not a documentation
  /// note.
  ///
  /// It is handed [groupValue] — the selection — rather than this radio's own
  /// selected-ness, because that is what a message like "scegli una fase" is
  /// about.
  final FormFieldValidator<T?>? validator;

  /// Called by `Form.save()`, with [groupValue].
  final FormFieldSetter<T?>? onSaved;

  /// When the control re-validates. Defaults to [AutovalidateMode.disabled].
  final AutovalidateMode? autovalidateMode;

  @override
  State<ItRadio<T>> createState() => _ItRadioState<T>();
}

class _ItRadioState<T> extends State<ItRadio<T>> {
  bool _showFocus = false;

  bool get _interactive => widget.enabled && widget.onChanged != null;

  @override
  void didUpdateWidget(covariant ItRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    ItFieldValidation.announce(context, oldWidget.errorText, widget.errorText);
  }

  void _select() {
    if (!_interactive) return;
    _formState?.didChange(widget.value);
    widget.onChanged!.call(widget.value);
  }

  /// The message the enclosing [Form] produced, when participating in one.
  String? _formError;
  FormFieldState<T?>? _formState;

  /// An explicit `errorText` wins: a caller stating the error outright is more
  /// specific than a validator that may not have run yet.
  String? get _errorText => widget.errorText ?? _formError;

  bool get _isFormField => widget.validator != null || widget.onSaved != null;

  @override
  Widget build(BuildContext context) {
    if (!_isFormField) return _buildRadio(context);

    return FormField<T?>(
      initialValue: widget.groupValue,
      autovalidateMode: widget.autovalidateMode,
      // The widget's own `groupValue` is the truth: this is a controlled
      // component, and the FormField's copy goes stale as soon as the caller
      // rebuilds.
      validator: widget.validator == null
          ? null
          : (_) => widget.validator!(widget.groupValue),
      onSaved: widget.onSaved == null
          ? null
          : (_) => widget.onSaved!(widget.groupValue),
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
        return _buildRadio(context);
      },
    );
  }

  Widget _buildRadio(BuildContext context) {
    final colors = resolveColorScheme(context);
    final selected = widget.value == widget.groupValue;
    final label = widget.label;
    final enabled = widget.enabled;
    final validation =
        ItFieldValidation.effective(_errorText, widget.validationState);
    // Null for a warning: `.form-check-input` has no warning rule, so the box
    // keeps its resting colours and the message carries the state.
    final validationColor =
        ItFieldValidation.checkChromeColor(colors, validation);

    // .form-check [type=radio]:not(:checked)+label::before
    //   { border-color: hsl(210,17%,44%) }
    // .form-check [type=radio]:checked+label::before  { border-color:#06c }
    // .form-check [type=radio]:checked+label::after
    //   { border-color:#06c; background-color:#06c; transform:scale(.64) }
    // .form-check [type=radio]:disabled…             { border-color: hsl(210,3%,85%) }
    //
    // .form-check-input.is-invalid         { border-color:rgb(204,51,76.5) }
    // .form-check-input.is-invalid:checked { background-color:rgb(204,51,76.5) }
    // — the validation tint replaces the accent on both the ring and the dot,
    // but never the disabled chrome.
    final Color ringColor;
    if (!enabled) {
      ringColor = ItFormMetrics.disabledChrome;
    } else if (validationColor != null) {
      ringColor = validationColor;
    } else if (selected) {
      ringColor = colors.primary;
    } else {
      ringColor = ItFormMetrics.borderColor;
    }
    final dotColor = !enabled
        ? ItFormMetrics.disabledChrome
        : validationColor ?? colors.primary;

    // .form-check-input.is-invalid~.form-check-label { color:rgb(204,51,76.5) }
    final labelColor =
        enabled && validationColor != null ? validationColor : colors.bodyColor;

    // The ring and its dot, in a box of their own.
    //
    // Extracted so `.form-check-group` can move the *same* pixels to the other
    // side of the label: the sheet flips `left` for `right` on both pseudos and
    // changes nothing else, and a second hand-offset copy of these two children
    // is exactly how the two variants would drift apart.
    //
    // 30px wide because the 20px ring carries a 5px margin on each side; the
    // resting layout's `left: 5` and the grouped layout's `right: 5` are then
    // the same edge, measured from opposite sides.
    final indicator = SizedBox(
      width: 30,
      height: ItFormMetrics.textLineHeight,
      child: Stack(
        children: [
          // ::before — the 20x20 ring, margin 5px, 2px border.
          Positioned(
            left: 5,
            top: 5,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2),
              ),
            ),
          ),
          // ::after — the selected dot, scale(.64) of the same 20px circle.
          if (selected)
            Positioned(
              left: 5 + (20 - 20 * 0.64) / 2,
              top: 5 + (20 - 20 * 0.64) / 2,
              child: Container(
                width: 20 * 0.64,
                height: 20 * 0.64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            ),
        ],
      ),
    );

    final Widget? labelChild = label == null
        ? null
        : Text(
            label,
            style: ItFormMetrics.textStyle(
              fontSize: ItFormMetrics.fontSize,
              lineHeight: ItFormMetrics.textLineHeight,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          );

    final row = widget.visuallyGrouped
        // `.form-check.form-check-group [type=radio]+label
        //    { position:static; padding-left:0; padding-right:3.25rem }`
        // with `::before,::after { right:0; left:auto }`.
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
            height: ItFormMetrics.textLineHeight,
            child: Stack(
              children: [
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

    // WCAG 4.1.2 on iOS and macOS, where `checked` alone reaches nothing.
    //
    // Apple has no native radio, so Flutter's iOS embedder deliberately gives a
    // mutually-exclusive node no value at all — `SemanticsObject.mm` returns nil
    // for one, commented "iOS does not announce values of native radio buttons"
    // — and routes it away from the `UISwitch`-backed object that would supply
    // 0/1. The chosen option therefore rides on `UIAccessibilityTraitSelected`,
    // and the only thing that sets that trait is `selected:`. Without it
    // VoiceOver reads the name and the position and never says which one is on.
    //
    // Android is excluded on purpose: it already carries `checked`, and its
    // bridge maps this flag to `setSelected` *and* fires a `TYPE_VIEW_SELECTED`
    // announcement, so setting it there would state the same fact twice. This
    // is the same platform split Flutter's own `RawRadio` makes.
    final bool? accessibilitySelected;
    final String? unselectedHint;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        accessibilitySelected = null;
        unselectedHint = null;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        accessibilitySelected = selected;
        // The trait marks only the chosen option; the others are announced
        // exactly as they would be if the state were missing entirely. So the
        // unselected ones have to say so themselves.
        unselectedHint =
            selected ? null : ItLocalizations.of(context).radioUnselected;
    }

    // Both can be present: an unselected radio in a group that is also showing
    // a validation message. Neither may swallow the other.
    final hint = <String>[
      if (unselectedHint != null) unselectedHint,
      if (ItFieldValidation.hint(_errorText, widget.helperText)
          case final String v)
        v,
    ].join('. ');

    // WCAG 4.1.2: `inMutuallyExclusiveGroup` is what makes a screen reader
    // treat this as a radio rather than a checkbox, and it is the flag the
    // platform uses to derive the "1 of 3" position announcement.
    final control = MergeSemantics(
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        selected: accessibilitySelected,
        enabled: _interactive,
        isRequired: widget.required,
        label: widget.semanticLabel ?? label,
        // WCAG 3.3.1 / 3.3.2: carried on the control rather than left as loose
        // text below it, together with the platform hint composed above.
        hint: hint.isEmpty ? null : hint,
        // Inside a group the message, the required state and the invalid flag
        // all live on the group's node — see [ItFieldGroupScope].
        validationResult: ItFieldGroupScope.spokenFor(context)
            ? SemanticsValidationResult.none
            : ItFieldValidation.result(validation),
        value: widget.indexInGroup != null && widget.groupLength != null
            ? '${widget.indexInGroup} di ${widget.groupLength}'
            : null,
        onTap: _interactive ? _select : null,
        child: ItFocusRing(
          // `.form-check [type=radio]:focus + label`
          visible: _showFocus,
          radius: 4,
          child: FocusableActionDetector(
            focusNode: widget.focusNode,
            enabled: _interactive,
            mouseCursor: _interactive
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            // WCAG 2.1.1: Space selects the focused radio. The arrow keys are
            // handled by [ItRadioGroup], which is the only thing that knows
            // the other options.
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            },
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  _select();
                  return null;
                },
              ),
            },
            onShowFocusHighlight: (show) {
              if (show != _showFocus) setState(() => _showFocus = show);
            },
            child: GestureDetector(
              onTap: _interactive ? _select : null,
              // The enclosing `Semantics` already carries `onTap`, so this
              // detector must not contribute a node of its own: it produced an
              // unnamed tappable child inside the named control, which a screen
              // reader offers as a second, meaningless stop. Hit testing and
              // behaviour are unchanged — only the duplicate node goes.
              excludeFromSemantics: true,
              // WCAG 2.5.8: the painted ring is only 20x20 and used to be the
              // whole target. The row is 24px tall and at least 30px wide.
              behavior: HitTestBehavior.opaque,
              child: label != null ? ExcludeSemantics(child: row) : row,
            ),
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

/// A Bootstrap Italia radio button group.
///
/// Displays a group of mutually exclusive radio options.
///
/// ```dart
/// ItRadioGroup<String>(
///   label: 'Genere',
///   options: [
///     ItRadioOption(value: 'M', label: 'Maschio'),
///     ItRadioOption(value: 'F', label: 'Femmina'),
///   ],
///   value: 'M',
///   onChanged: (value) {},
/// )
/// ```
class ItRadioGroup<T> extends StatefulWidget {
  /// Group label.
  final String? label;

  /// The available options.
  final List<ItRadioOption<T>> options;

  /// The currently selected value.
  final T? value;

  /// Called when the selection changes.
  final ValueChanged<T>? onChanged;

  /// Whether to display options in a horizontal row.
  final bool inline;

  /// Whether a choice must be made before the form can be submitted.
  final bool required;

  /// `.form-check.form-check-group .form-text` — instruction for the set.
  final String? helperText;

  /// `.form-feedback` — validation message for the set.
  final String? errorText;

  /// Validation state tinting every radio in the group. [errorText] implies
  /// [ItValidationState.danger].
  final ItValidationState? validationState;

  /// `.form-check.form-check-group` applied to every row — the docs'
  /// "Raggruppati visivamente".
  ///
  /// Reaches each [ItRadio] as [ItRadio.visuallyGrouped]. In the kit's markup
  /// the class sits on the individual `.form-check`, not on the `<fieldset>`
  /// around them, so a caller can also apply it row by row; this is the
  /// shorthand for the case the docs actually show.
  ///
  /// Not the same axis as [inline]: `.form-check-inline` lays rows out side by
  /// side, `.form-check-group` restyles each one. Combining them is not a
  /// layout the stylesheet describes, so [inline] wins and this is ignored when
  /// both are set.
  final bool visuallyGrouped;

  /// Creates a Bootstrap Italia radio group.
  const ItRadioGroup({
    super.key,
    this.label,
    required this.options,
    this.value,
    this.onChanged,
    this.inline = false,
    this.required = false,
    this.helperText,
    this.errorText,
    this.validationState,
    this.visuallyGrouped = false,
  });

  @override
  State<ItRadioGroup<T>> createState() => _ItRadioGroupState<T>();
}

/// Moves the selection to the next radio in the group.
class _NextRadioIntent extends Intent {
  const _NextRadioIntent();
}

/// Moves the selection to the previous radio in the group.
class _PreviousRadioIntent extends Intent {
  const _PreviousRadioIntent();
}

class _ItRadioGroupState<T> extends State<ItRadioGroup<T>> {
  List<FocusNode> _nodes = const [];

  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  @override
  void didUpdateWidget(covariant ItRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.length != oldWidget.options.length) _syncNodes();
  }

  void _syncNodes() {
    for (final node in _nodes) {
      node.dispose();
    }
    _nodes = List<FocusNode>.generate(
      widget.options.length,
      (i) => FocusNode(debugLabel: 'ItRadio ${widget.options[i].label}'),
    );
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Moves focus and selection [delta] steps, skipping disabled options and
  /// wrapping around — the behaviour of a native radio group, and what WCAG
  /// 2.1.1 requires of a control that is otherwise only reachable by pointer.
  void _move(int delta) {
    if (widget.onChanged == null || _nodes.isEmpty) return;
    final from = _nodes.indexWhere((n) => n.hasFocus);
    if (from < 0) return;

    var next = from;
    for (var step = 0; step < _nodes.length; step++) {
      next = (next + delta) % _nodes.length;
      if (next < 0) next += _nodes.length;
      if (widget.options[next].enabled) break;
    }
    if (next == from || !widget.options[next].enabled) return;

    _nodes[next].requestFocus();
    widget.onChanged!.call(widget.options[next].value);
  }

  @override
  Widget build(BuildContext context) {
    ItFieldValidation.debugCheckConfig(
      label: widget.label,
      required: widget.required,
      optionCount: widget.options.length,
      optionValues: widget.options.map((o) => o.value),
      widgetName: 'ItRadioGroup',
    );
    final colors = resolveColorScheme(context);

    // `.form-check-inline` and `.form-check-group` are alternatives, not a
    // matrix — see [visuallyGrouped].
    final grouped = widget.visuallyGrouped && !widget.inline;

    final radios = <Widget>[
      for (var i = 0; i < widget.options.length; i++)
        ItRadio<T>(
          value: widget.options[i].value,
          groupValue: widget.value,
          label: widget.options[i].label,
          enabled: widget.options[i].enabled,
          visuallyGrouped: grouped,
          // Per-row `<small class="form-text">`, which only the grouped layout
          // has room for — see [ItRadioOption.helperText].
          helperText: grouped ? widget.options[i].helperText : null,
          // The tint is a property of the set, so it reaches every radio — and
          // `errorText` is a validation state, not only a message: with one
          // set and `validationState` left null the group printed the error
          // and drew every radio as if nothing were wrong, where the kit puts
          // `.is-invalid` on each input. The message, the instruction and the
          // required state stay on the group's own node, and so does the
          // invalid state a screen reader hears — see [ItFieldGroupScope].
          validationState: ItFieldValidation.effective(
              widget.errorText, widget.validationState),
          focusNode: i < _nodes.length ? _nodes[i] : null,
          indexInGroup: i + 1,
          groupLength: widget.options.length,
          onChanged: widget.onChanged == null
              ? null
              : (chosen) {
                  if (i < _nodes.length) _nodes[i].requestFocus();
                  widget.onChanged!.call(chosen);
                },
        ),
    ];

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          // WCAG 1.3.1: announced once, as the group's container label.
          ExcludeSemantics(
            child: Text(
              widget.label!,
              style: ItFormMetrics.textStyle(
                fontSize: 14,
                lineHeight: 39,
                fontWeight: FontWeight.w700,
                color: colors.bodyColor,
              ),
            ),
          ),
        if (widget.inline)
          Wrap(
            spacing: BootstrapItaliaSpacing.space4,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: radios,
          )
        else if (grouped)
          // No extra gap: `.form-check-group` already declares
          // `padding-bottom:1rem; margin-bottom:1rem`, and stacking the resting
          // `.form-check + .form-check { margin-top:.5rem }` on top of it would
          // push the rows 8px further apart than the sheet does.
          ...radios
        else
          // .form-check + .form-check { margin-top: .5rem }
          ...radios.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: r,
            ),
          ),
        // Inside the Column rather than around it, so the two lines stay
        // left-aligned with the rings and the group node below keeps carrying
        // them.
        if (widget.helperText != null || widget.errorText != null)
          ItFieldSupport(
            helperText: widget.helperText,
            errorText: widget.errorText,
            child: const SizedBox.shrink(),
          ),
      ],
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.radioGroup,
      label: widget.label,
      isRequired: widget.required,
      // WCAG 3.3.1 / 3.3.2: the instruction and the validation message describe
      // the *set*, so they are the group node's hint, not any one radio's.
      hint: ItFieldValidation.hint(widget.errorText, widget.helperText),
      validationResult: ItFieldValidation.result(
        ItFieldValidation.effective(widget.errorText, widget.validationState),
      ),
      // WCAG 2.1.1: `Shortcuts` sits in the focus chain above the radios, so
      // it sees the key events that bubble up from whichever one has focus.
      // The group reports validity for the set; its radios take the tint but
      // stay quiet about it, or one error is announced once per option.
      child: ItFieldGroupScope(
        child: Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowDown): _NextRadioIntent(),
            SingleActivator(LogicalKeyboardKey.arrowRight): _NextRadioIntent(),
            SingleActivator(LogicalKeyboardKey.arrowUp): _PreviousRadioIntent(),
            SingleActivator(LogicalKeyboardKey.arrowLeft):
                _PreviousRadioIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              _NextRadioIntent: CallbackAction<_NextRadioIntent>(
                onInvoke: (_) {
                  _move(1);
                  return null;
                },
              ),
              _PreviousRadioIntent: CallbackAction<_PreviousRadioIntent>(
                onInvoke: (_) {
                  _move(-1);
                  return null;
                },
              ),
            },
            child: column,
          ),
        ),
      ),
    );
  }
}
