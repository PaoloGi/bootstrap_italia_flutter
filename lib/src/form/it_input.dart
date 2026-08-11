import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../a11y/it_focus_ring.dart';
import '../l10n/it_localizations.dart';
import '../theme/bootstrap_italia_theme_data.dart';
import '../theme/theme_extensions.dart';
import 'it_field_support.dart';
import 'it_form_metrics.dart';

/// A Bootstrap Italia text input field.
///
/// Matches Bootstrap Italia's `.form-group` + `.form-control` markup: the
/// control is 40px (`2.5rem`) tall with a 1px bottom border only, the label
/// sits *inside* the field while it is empty and unfocused, and floats above
/// it (`label.active`, `translateY(-85%)`, 14px semibold) as soon as the field
/// is focused, filled, or shows a placeholder.
///
/// When [icon] is provided, the input renders in an `.input-group` layout
/// with the icon in a separate 40px container to the left of the field,
/// matching Bootstrap Italia's `.input-group-text` pattern.
///
/// When [trailingAction] is provided, it is placed to the right of the field,
/// matching Bootstrap Italia's `.input-group-append` pattern (e.g. "Invio"
/// button).
///
/// ```dart
/// ItInput(
///   label: 'Nome completo',
///   hint: 'Inserisci il tuo nome',
///   icon: BootstrapItaliaIcons.it_pencil,
///   helperText: 'Come da documento',
///   onChanged: (value) {},
/// )
/// ```
class ItInput extends StatefulWidget {
  /// The floating label text.
  final String? label;

  /// Placeholder text shown when the field is empty.
  ///
  /// As in Bootstrap Italia, providing a placeholder floats the label so the
  /// two never overlap.
  final String? hint;

  /// Leading icon displayed in a separate container to the left of the field.
  ///
  /// Follows Bootstrap Italia's `.input-group-text` pattern where the icon
  /// sits outside the input area.
  final IconData? icon;

  /// Trailing action widget placed to the right of the field.
  ///
  /// Follows Bootstrap Italia's `.input-group-append` pattern. Typically an
  /// [ItButton] (e.g. "Invio").
  final Widget? trailingAction;

  /// Helper text below the field (`small.form-text`).
  final String? helperText;

  /// Error text (`.form-feedback`). When set, forces [validationState] to
  /// danger.
  final String? errorText;

  /// Whether to obscure text (password field).
  final bool obscureText;

  /// Whether to show a password visibility toggle (`.password-icon`).
  final bool showPasswordToggle;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when editing is complete.
  final VoidCallback? onEditingComplete;

  /// Called when the field is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Validation state (success, warning, danger).
  final ItValidationState? validationState;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Maximum number of lines.
  final int maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum length.
  final int? maxLength;

  /// Focus node.
  final FocusNode? focusNode;

  /// Text input action.
  final TextInputAction? textInputAction;

  /// Whether the field must be filled in before the form can be submitted.
  ///
  /// Exposed to assistive technology as the required state, so the constraint
  /// is conveyed before the user submits (WCAG 3.3.2 Labels or Instructions).
  final bool required;

  /// Accessible name, when it must differ from the visible [label] — or when
  /// there is no visible label at all, which WCAG 4.1.2 does not permit.
  final String? semanticLabel;

  /// Accessible name of the password visibility toggle (WCAG 4.1.2).
  ///
  /// Defaults to [ItLocalizations.showPassword] — `'Mostra la password'` with
  /// no delegate installed.
  final String? showPasswordLabel;

  /// Accessible name of the password visibility toggle once text is shown.
  ///
  /// Defaults to [ItLocalizations.hidePassword].
  final String? hidePasswordLabel;

  /// Creates a Bootstrap Italia text input.
  const ItInput({
    super.key,
    this.label,
    this.hint,
    this.icon,
    this.trailingAction,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.controller,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.validationState,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.textInputAction,
    this.required = false,
    this.semanticLabel,
    this.showPasswordLabel,
    this.hidePasswordLabel,
  });

  @override
  State<ItInput> createState() => _ItInputState();
}

class _ItInputState extends State<ItInput> {
  late bool _obscured;
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _ownsFocusNode = false;
  bool _ownsController = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _initFocusNode();
    _initController();
  }

  void _initFocusNode() {
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(covariant ItInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (_ownsFocusNode) _focusNode.dispose();
      _initFocusNode();
    }
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onTextChange);
      if (_ownsController) _controller.dispose();
      _initController();
    }
    ItFieldValidation.announce(context, oldWidget.errorText, widget.errorText);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onTextChange() {
    // Only the empty/non-empty transition changes the layout.
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    _controller.removeListener(_onTextChange);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  ItValidationState? get _effectiveValidation =>
      ItFieldValidation.effective(widget.errorText, widget.validationState);

  void _togglePasswordVisibility() => setState(() => _obscured = !_obscured);

  /// Bootstrap Italia adds `label.active` when the control is focused, holds a
  /// value, or shows a placeholder.
  bool get _labelIsFloating =>
      _isFocused || _controller.text.isNotEmpty || widget.hint != null;

  /// `.form-control.is-invalid { border-color: rgb(204,51,76.5) }` — which is
  /// exactly the `danger` token, so the validation colours are taken from the
  /// theme and stay customisable. Shared with the other five controls.
  Color _validationColor(BootstrapItaliaColorScheme colors) =>
      ItFieldValidation.color(colors, _effectiveValidation!);

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final validation = _effectiveValidation;

    // input[type=text] { border-bottom: 1px solid hsl(210,17%,44%) }
    // .form-control.is-invalid { border-color: rgb(204,51,76.5) }
    final borderColor = validation == null
        ? ItFormMetrics.borderColor
        : _validationColor(colors);

    final floating = _labelIsFloating;
    final hasIcon = widget.icon != null;

    final control = DecoratedBox(
      // .form-control:focus { box-shadow: 0 0 0 .25rem rgba(0,102,204,.25) }
      // — rgba() of the primary token, so it comes from the scheme.
      decoration: BoxDecoration(
        boxShadow: _isFocused && widget.enabled
            ? [
                BoxShadow(
                  color: ItFormMetrics.focusRingColor(colors),
                  spreadRadius: 4,
                )
              ]
            : null,
      ),
      child: SizedBox(
        height: ItFormMetrics.controlHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // .form-control:disabled { background-color: hsl(210,3%,85%) }
            if (!widget.enabled)
              const Positioned.fill(
                child: ColoredBox(color: ItFormMetrics.disabledBackground),
              ),
            // The label paints beneath the field chrome so an `.input-group`
            // append button covers it exactly as it does on the web.
            //
            // WCAG 1.3.1 / 3.3.2: it is a free-floating `Text`, not the
            // field's own label, so on its own it gives the input no
            // accessible name — axe reported a critical "Form elements must
            // have labels". It is excluded here and re-attached to the field
            // itself in [_buildField], which is the association AT needs.
            if (widget.label != null)
              Positioned(
                left: hasIcon && !floating
                    ? ItFormMetrics.inputGroupLabelLeft
                    : 0,
                top: floating ? ItFormMetrics.activeLabelOffset : 0,
                child: ExcludeSemantics(
                  child: _buildLabel(colors, floating, validation),
                ),
              ),
            Positioned.fill(child: _buildRow(colors, validation)),
            // input[type=text] { border-bottom: 1px solid … }
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: ItFormMetrics.borderWidth,
              child: ColoredBox(color: borderColor),
            ),
          ],
        ),
      ),
    );

    // WCAG 3.3.1 / 3.3.2: both lines are excluded from the semantics tree by
    // [ItFieldSupport] and carried on the field's own node as its hint below —
    // otherwise a screen-reader user meets them as loose text after the field,
    // with nothing tying them to it.
    return ItFieldSupport(
      helperText: widget.helperText,
      errorText: widget.errorText,
      child: control,
    );
  }

  Widget _buildLabel(
    BootstrapItaliaColorScheme colors,
    bool floating,
    ItValidationState? validation,
  ) {
    // .form-group label        { font-size:1rem; color:hsl(210,17%,44%) }
    // .form-group label.active { font-size:.875rem; font-weight:600;
    //                            color:hsl(0,0%,10%) }
    //
    // The floated label's hsl(0,0%,10%) is the bodyColor token; the resting
    // one's hsl(210,17%,44%) is the grey, not the secondary accent.
    final style = floating
        ? ItFormMetrics.textStyle(
            fontSize: ItFormMetrics.activeLabelFontSize,
            lineHeight: ItFormMetrics.labelLineHeight,
            fontWeight: FontWeight.w600,
            color: ItFormMetrics.textColor(colors),
          )
        : ItFormMetrics.textStyle(
            fontSize: ItFormMetrics.labelFontSize,
            lineHeight: ItFormMetrics.labelLineHeight,
            color: ItFormMetrics.borderColor,
          );

    return Padding(
      // .form-group label { padding: 0 .5rem }
      padding: const EdgeInsets.symmetric(
        horizontal: ItFormMetrics.horizontalPadding,
      ),
      child: Text(widget.label!, style: style, maxLines: 1),
    );
  }

  Widget _buildRow(
    BootstrapItaliaColorScheme colors,
    ItValidationState? validation,
  ) {
    return Row(
      children: [
        // .input-group .input-group-text { min-width:40px; padding:.375rem .5rem }
        if (widget.icon != null)
          SizedBox(
            width: ItFormMetrics.inputGroupTextWidth,
            child: Center(
              child: Icon(
                widget.icon,
                size: ItFormMetrics.iconSize,
                color: widget.enabled
                    ? ItFormMetrics.borderColor
                    : ItFormMetrics.checkOutlineColor,
              ),
            ),
          ),
        Expanded(child: _buildField(colors, validation)),
        // .input-group .input-group-append .btn { height: 100% }
        if (widget.trailingAction != null)
          SizedBox(
            height: ItFormMetrics.controlHeight - ItFormMetrics.borderWidth,
            child: widget.trailingAction,
          ),
      ],
    );
  }

  Widget _buildField(
    BootstrapItaliaColorScheme colors,
    ItValidationState? validation,
  ) {
    final suffix = _buildSuffix(colors, validation);

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      cursorColor: colors.primary,
      // .form-group input { color: hsl(0,0%,10%) } — the bodyColor token.
      style: ItFormMetrics.textStyle(
        fontSize: ItFormMetrics.fontSize,
        lineHeight: ItFormMetrics.textLineHeight,
        color: ItFormMetrics.textColor(colors),
      ),
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        counterText: '',
        contentPadding: EdgeInsets.zero,
        // input[type=text]::placeholder { color: hsl(210,17%,44%) }
        hintText: _labelIsFloating ? widget.hint : null,
        hintStyle: ItFormMetrics.textStyle(
          fontSize: ItFormMetrics.fontSize,
          lineHeight: ItFormMetrics.textLineHeight,
          color: ItFormMetrics.borderColor,
        ),
      ),
    );

    // WCAG 1.3.1 / 3.3.1 / 3.3.2 / 4.1.2.
    //
    // The visible label and the validation message are painted as siblings of
    // the field, so nothing connected them to it: the text field reached AT
    // with an empty name, which axe flagged as a critical "Form elements must
    // have labels". `MergeSemantics` folds this wrapper into the field's own
    // node, producing exactly the node Flutter's `TextField(labelText:,
    // errorText:)` produces — name, hint and validation state on the control
    // itself — while the painting stays byte-for-byte what it was.
    final labelled = MergeSemantics(
      child: Semantics(
        label: widget.semanticLabel ?? widget.label,
        hint: ItFieldValidation.hint(widget.errorText, widget.helperText),
        isRequired: widget.required,
        validationResult: ItFieldValidation.result(validation),
        child: field,
      ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ItFormMetrics.horizontalPadding,
            ),
            child: Align(alignment: Alignment.centerLeft, child: labelled),
          ),
        ),
        if (suffix != null) suffix,
      ],
    );
  }

  /// The right-hand affordances: the validation glyph that Bootstrap Italia
  /// paints as a background image on `.form-control.is-invalid`, and the
  /// `.password-icon` visibility toggle.
  Widget? _buildSuffix(
    BootstrapItaliaColorScheme colors,
    ItValidationState? validation,
  ) {
    if (widget.showPasswordToggle) {
      // .password-icon { right:0; top:8px; padding:0 .5rem }. The 2.5px extra
      // offset compensates for the icon font's eye glyph sitting higher in its
      // em box than the inline SVG the reference markup uses.
      //
      // WCAG 4.1.2: it was a bare tapped `Icon` — no role, no name, and
      // unreachable by keyboard (2.1.1). The 24px glyph is exactly the 24x24
      // that 2.5.8 asks for, so an opaque hit test over it is enough.
      return Positioned(
        right: ItFormMetrics.horizontalPadding,
        top: 10.5,
        child: Semantics(
          button: true,
          label: _obscured
              ? widget.showPasswordLabel ??
                  ItLocalizations.of(context).showPassword
              : widget.hidePasswordLabel ??
                  ItLocalizations.of(context).hidePassword,
          onTap: _togglePasswordVisibility,
          child: _ItPasswordToggle(
            obscured: _obscured,
            onPressed: _togglePasswordVisibility,
          ),
        ),
      );
    }

    if (validation == null) return null;

    // `.form-control { background-size: 45px 45% !important;
    //                  background-position: center right !important }`
    // The validation SVG is square, so it letterboxes to 18x18 (45% of the
    // 40px control) centred inside that 45px band: its right edge therefore
    // sits (45 - 18) / 2 = 13.5px inside the field, vertically centred.
    final icon = switch (validation) {
      ItValidationState.success => BootstrapItaliaIcons.it_check_circle,
      ItValidationState.warning => BootstrapItaliaIcons.it_warning_circle,
      ItValidationState.danger => BootstrapItaliaIcons.it_error,
    };
    const glyph = ItFormMetrics.controlHeight * 0.45;
    return Positioned(
      right: (45 - glyph) / 2,
      top: (ItFormMetrics.controlHeight - glyph) / 2,
      // WCAG 1.1.1: purely decorative — the state it depicts is already on the
      // field's own node as its validation result and hint.
      child: ExcludeSemantics(
        child: Icon(icon, size: glyph, color: _validationColor(colors)),
      ),
    );
  }
}

/// The `.password-icon` visibility toggle.
///
/// Split out so it owns a focus node: it is a control in its own right and
/// WCAG 2.1.1 requires it to be reachable and operable from the keyboard.
class _ItPasswordToggle extends StatefulWidget {
  const _ItPasswordToggle({required this.obscured, required this.onPressed});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  State<_ItPasswordToggle> createState() => _ItPasswordToggleState();
}

class _ItPasswordToggleState extends State<_ItPasswordToggle> {
  bool _showFocus = false;

  @override
  Widget build(BuildContext context) {
    return ItFocusRing(
      visible: _showFocus,
      radius: 4,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        onShowFocusHighlight: (show) {
          if (show != _showFocus) setState(() => _showFocus = show);
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: ExcludeSemantics(
            child: Icon(
              widget.obscured
                  ? BootstrapItaliaIcons.it_password_visible
                  : BootstrapItaliaIcons.it_password_invisible,
              size: ItFormMetrics.iconSize,
              color: ItFormMetrics.borderColor,
            ),
          ),
        ),
      ),
    );
  }
}
