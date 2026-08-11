import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../a11y/it_focus_ring.dart';
import '../theme/theme_extensions.dart';
import '../tokens/spacing.dart';
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

  /// Creates a radio option.
  const ItRadioOption({
    required this.value,
    required this.label,
    this.enabled = true,
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
class ItRadio extends StatefulWidget {
  /// Whether this radio is selected.
  final bool value;

  /// The label text.
  final String? label;

  /// Called when the user selects this radio.
  ///
  /// Always emits `true`. A radio is the one control of the three that cannot
  /// be switched off by operating it — HTML fires no `change` when a checked
  /// radio is clicked, and the only thing that clears one is another radio in
  /// the same group taking the selection. The callback keeps its sibling's
  /// `ValueChanged<bool>` shape rather than a bare `VoidCallback` so that
  /// `ItRadio`, `ItCheckbox` and `ItToggle` are driven by the same code:
  ///
  /// ```dart
  /// ItRadio(value: v, onChanged: (next) => setState(() => v = next))
  /// ```
  ///
  /// Use [ItRadioGroup] to bind several radios to one value; it is what turns
  /// "always true" into a real exclusive selection.
  final ValueChanged<bool>? onChanged;

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
    this.label,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.helperText,
    this.errorText,
    this.validationState,
    this.semanticLabel,
    this.focusNode,
    this.indexInGroup,
    this.groupLength,
  });

  @override
  State<ItRadio> createState() => _ItRadioState();
}

class _ItRadioState extends State<ItRadio> {
  bool _showFocus = false;

  bool get _interactive => widget.enabled && widget.onChanged != null;

  @override
  void didUpdateWidget(covariant ItRadio oldWidget) {
    super.didUpdateWidget(oldWidget);
    ItFieldValidation.announce(context, oldWidget.errorText, widget.errorText);
  }

  /// See [ItRadio.onChanged] for why this is unconditionally `true`.
  void _select() {
    if (!_interactive) return;
    widget.onChanged!.call(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final selected = widget.value;
    final label = widget.label;
    final enabled = widget.enabled;
    final validation =
        ItFieldValidation.effective(widget.errorText, widget.validationState);
    final validationColor =
        validation == null ? null : ItFieldValidation.color(colors, validation);

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

    final row = SizedBox(
      height: ItFormMetrics.textLineHeight,
      child: Stack(
        children: [
          if (label == null)
            const SizedBox(width: 30, height: ItFormMetrics.textLineHeight),
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
          if (label != null)
            Padding(
              // .form-check […]+label { padding-left: 2rem }
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                label,
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

    // WCAG 4.1.2: `inMutuallyExclusiveGroup` is what makes a screen reader
    // treat this as a radio rather than a checkbox, and it is the flag the
    // platform uses to derive the "1 of 3" position announcement.
    final control = MergeSemantics(
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        enabled: _interactive,
        isRequired: widget.required,
        label: widget.semanticLabel ?? label,
        // WCAG 3.3.1 / 3.3.2: carried on the control rather than left as loose
        // text below it.
        hint: ItFieldValidation.hint(widget.errorText, widget.helperText),
        validationResult: ItFieldValidation.result(validation),
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
      errorText: widget.errorText,
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
    final colors = resolveColorScheme(context);

    final radios = <Widget>[
      for (var i = 0; i < widget.options.length; i++)
        ItRadio(
          value: widget.options[i].value == widget.value,
          label: widget.options[i].label,
          enabled: widget.options[i].enabled,
          // The tint is a property of the set, so it reaches every radio; the
          // message, the instruction and the required state belong to the group
          // and are carried on its own node.
          validationState: widget.validationState,
          focusNode: i < _nodes.length ? _nodes[i] : null,
          indexInGroup: i + 1,
          groupLength: widget.options.length,
          onChanged: widget.onChanged == null
              ? null
              : (_) {
                  if (i < _nodes.length) _nodes[i].requestFocus();
                  widget.onChanged!.call(widget.options[i].value);
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
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowDown): _NextRadioIntent(),
          SingleActivator(LogicalKeyboardKey.arrowRight): _NextRadioIntent(),
          SingleActivator(LogicalKeyboardKey.arrowUp): _PreviousRadioIntent(),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _PreviousRadioIntent(),
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
    );
  }
}
