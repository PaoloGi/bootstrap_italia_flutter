import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/it_localizations.dart';
import '../a11y/it_focus_ring.dart';
import '../theme/bootstrap_italia_theme_data.dart';
import '../theme/theme_extensions.dart';
import 'it_field_support.dart';
import 'it_form_metrics.dart';

/// The `.form-control-sm` / `.form-control-lg` size variants.
///
/// ```
/// .form-control-sm { min-height:calc(1.5em + 0.5rem); padding:.25rem .5rem;
///                    font-size:0.875rem }
/// .form-control-lg { min-height:calc(1.5em + 1rem);   padding:.5rem 1rem;
///                    font-size:1.25rem }
/// ```
///
/// The docs introduce these under "Area di testo", because a text area is where
/// a taller or shorter box is normally wanted, but the classes are declared on
/// `.form-control` and apply to every control that carries it.
///
/// One asymmetry is real and is not a bug here: on a **single-line** input the
/// padding does not move. `input[type=text] { padding:.375rem .5rem }` is an
/// attribute selector, specificity (0,1,1), and out-ranks the (0,1,0) of
/// `.form-control-sm`; a `<textarea>` matches by element name, (0,0,1), and
/// loses to it. So the size class changes the type size and the minimum height
/// everywhere, and the internal spacing only on a text area — which is exactly
/// the case the docs demonstrate it on.
enum ItInputSize {
  /// `.form-control-sm` — 14px type in a 29px box.
  small,

  /// The default `.form-control` — 16px type in a 40px box.
  medium,

  /// `.form-control-lg` — 20px type in a 46px box.
  large,
}

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
  /// Defaults to `'Mostra la password'`, with
  /// no delegate installed.
  final String? showPasswordLabel;

  /// Accessible name of the password visibility toggle once text is shown.
  ///
  /// Defaults to `'Nascondi la password'`.
  final String? hidePasswordLabel;

  /// `.form-control-sm` / `.form-control-lg` — see [ItInputSize].
  final ItInputSize size;

  /// `.form-control-plaintext` — the docs' "Readonly normalizzato".
  ///
  /// ```
  /// .form-control-plaintext { padding:.375rem .5rem;
  ///                           background-color:#fff !important;
  ///                           cursor:not-allowed }
  /// .form-control-plaintext+label { cursor:not-allowed }
  /// ```
  ///
  /// Implies [readOnly]: the docs' markup pairs the class with the `readonly`
  /// attribute in every example, and a plaintext-styled field the user can
  /// still type into would be lying about itself.
  ///
  /// **What it does not do, and why.** The docs describe it as showing the
  /// field "nella forma stilizzata come testo normale", and Bootstrap's own
  /// rule does strip the border — `.form-control-plaintext { border:solid
  /// rgba(0,0,0,0); border-width:0 0 }`. In this build that rule never wins:
  /// the class replaces `.form-control` but not the element, and
  /// `input[type=text] { border:none; border-bottom:1px solid hsl(210,17%,44%) }`
  /// is specificity (0,1,1) against the class's (0,1,0). The underline
  /// therefore survives on the reference kit, and it survives here, because
  /// matching the docs' *prose* over the docs' *rendering* would put this
  /// package half a pixel-diff away from the thing it is a port of. What the
  /// class really changes is the height — `.form-control-plaintext` declares no
  /// `min-height`, so the box collapses from 2.5rem to its content — and the
  /// cursor, on the field and on its label alike.
  final bool plaintext;

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
    this.size = ItInputSize.medium,
    this.plaintext = false,
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

  /// Whether this control is a `<textarea>` rather than an `<input>`.
  ///
  /// Which it is decides the *chrome*, not just the line count:
  /// `textarea.form-control { border:1px solid hsl(210,17%,44%) }` is a box on
  /// all four sides where an input has only its bottom edge, and
  /// `textarea { height:auto }` lets it grow where an input is pinned to
  /// `min-height:2.5rem`. Before this, a multi-line `ItInput` was drawn as a
  /// single-line one: four lines of text squeezed into a 40px underlined box.
  bool get _isTextarea => widget.maxLines != 1 || widget.minLines != null;

  /// `.form-control { font-size:1rem }`, `.form-control-sm { font-size:.875rem }`,
  /// `.form-control-lg { font-size:1.25rem }`.
  double get _fontSize => switch (widget.size) {
        ItInputSize.small => ItFormMetrics.smallFontSize,
        ItInputSize.medium => ItFormMetrics.fontSize,
        ItInputSize.large => ItFormMetrics.largeFontSize,
      };

  /// The computed line box of [_fontSize] at `line-height: 1.5`.
  double get _lineHeight => _fontSize * 1.5;

  /// `min-height` for the size in force — and none at all under [plaintext],
  /// which is the one thing that class reliably takes away.
  double get _minHeight => switch (widget.size) {
        ItInputSize.small => ItFormMetrics.smallControlHeight,
        ItInputSize.medium => ItFormMetrics.controlHeight,
        ItInputSize.large => ItFormMetrics.largeControlHeight,
      };

  /// Horizontal padding, which the size class only reaches on a text area.
  ///
  /// `input[type=text] { padding:.375rem .5rem }` is (0,1,1) and beats
  /// `.form-control-sm`/`-lg` at (0,1,0), so a single-line field keeps its 8px
  /// whatever size it is. A `<textarea>` matches at (0,0,1) and loses to both
  /// the size classes and to `.form-control { padding:.375rem .75rem }`, so its
  /// padding really does follow the size — 8, 12 or 16.
  double get _horizontalPadding {
    if (!_isTextarea) return ItFormMetrics.horizontalPadding;
    return switch (widget.size) {
      ItInputSize.small => ItFormMetrics.smallHorizontalPadding,
      // `.form-control { padding: .375rem .75rem }`
      ItInputSize.medium => 12,
      ItInputSize.large => ItFormMetrics.largeHorizontalPadding,
    };
  }

  /// Vertical padding of the text area's box: `.375rem`, `.25rem` or `.5rem`.
  ///
  /// Only a text area uses it; a single-line control centres its one line in a
  /// box of fixed height instead, which is what the CSS's line-height does.
  double get _verticalPadding => switch (widget.size) {
        ItInputSize.small => 4,
        ItInputSize.medium => 6,
        ItInputSize.large => 8,
      };

  /// `.form-control.is-invalid { border-color: rgb(204,51,76.5) }` — which is
  /// exactly the `danger` token, so the validation colours are taken from the
  /// theme and stay customisable. Shared with the other five controls.
  Color _validationColor(BootstrapItaliaColorScheme colors) =>
      ItFieldValidation.color(colors, _effectiveValidation!);

  @override
  Widget build(BuildContext context) {
    assert(
      !_isTextarea || (widget.icon == null && widget.trailingAction == null),
      'ItInput was given an icon or a trailing action on a multi-line field.\n'
      'The `.input-group` container and its append button are declared for '
      '<input> only, and the docs show neither on a text area, so there is no '
      'rule saying where they would go. Both are ignored in this layout rather '
      'than being placed by invention — drop them, or make the field single '
      'line.',
    );
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
      child: _isTextarea
          ? _buildTextarea(colors, validation, borderColor, floating)
          : SizedBox(
              // `.form-control { min-height:2.5rem }`, or the size class that
              // supersedes it. Under `.form-control-plaintext` there is no
              // `min-height` rule at all, so the box is only as tall as one
              // line of text plus its padding and its surviving bottom border.
              height: widget.plaintext
                  ? _lineHeight +
                      _verticalPadding * 2 +
                      ItFormMetrics.borderWidth
                  : _minHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // .form-control:disabled { background-color: hsl(210,3%,85%) }
                  //
                  // `.form-control-plaintext { background-color:#fff
                  // !important }` — the `!important` is what keeps a plaintext
                  // field white, so it is checked first.
                  if (!widget.enabled && !widget.plaintext)
                    const Positioned.fill(
                      child:
                          ColoredBox(color: ItFormMetrics.disabledBackground),
                    ),
                  // The label paints beneath the field chrome so an
                  // `.input-group` append button covers it exactly as it does
                  // on the web.
                  //
                  // WCAG 1.3.1 / 3.3.2: it is a free-floating `Text`, not the
                  // field's own label, so on its own it gives the input no
                  // accessible name — axe reported a critical "Form elements
                  // must have labels". It is excluded here and re-attached to
                  // the field itself in [_buildField], which is the association
                  // AT needs.
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

  /// The `<textarea>` layout.
  ///
  /// ```
  /// textarea               { border:1px solid hsl(210,17%,44%); height:auto }
  /// textarea.form-control  { min-height:2.5rem;
  ///                          border:1px solid hsl(210,17%,44%) }
  /// .form-control          { padding:.375rem .75rem }
  /// ```
  ///
  /// A box on all four sides, and a height that follows the content instead of
  /// being pinned. The label keeps the same two positions it has on an input —
  /// `top:0` while resting, `translateY(-85%)` once active — because
  /// `.form-group label` never mentions which control it labels.
  ///
  /// No `.input-group` here: the icon container and the append button are
  /// declared for `<input>` and the docs show neither on a text area, so
  /// [icon] and [trailingAction] are not read in this branch rather than being
  /// given an invented placement.
  Widget _buildTextarea(
    BootstrapItaliaColorScheme colors,
    ItValidationState? validation,
    Color borderColor,
    bool floating,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The only non-positioned child, so it is what sizes the stack — which
        // is how `height:auto` reaches Flutter.
        Container(
          // `.form-control-plaintext` declares no `min-height`, so a plaintext
          // area is only as tall as what it holds.
          constraints:
              BoxConstraints(minHeight: widget.plaintext ? 0 : _minHeight),
          decoration: BoxDecoration(
            // .form-control:disabled { background-color: hsl(210,3%,85%) }
            // — but `.form-control-plaintext { background-color:#fff
            // !important }` outranks it.
            color: widget.enabled || widget.plaintext
                ? null
                : ItFormMetrics.disabledBackground,
            // Here the cascade falls the *other* way round from the
            // single-line case, and for the same reason. A text area matches
            // `textarea { border:1px solid hsl(210,17%,44%) }` by element name,
            // specificity (0,0,1), so `.form-control-plaintext
            // { border-width:0 0 }` at (0,1,0) wins and the box really does
            // lose its border — while on an `input[type=text]`, at (0,1,1), it
            // does not. See [ItInput.plaintext].
            border: widget.plaintext
                ? null
                : Border.all(
                    color: borderColor,
                    width: ItFormMetrics.borderWidth,
                  ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: _verticalPadding,
          ),
          child: _buildField(colors, validation),
        ),
        if (widget.label != null)
          Positioned(
            left: 0,
            top: floating ? ItFormMetrics.activeLabelOffset : 0,
            child: ExcludeSemantics(
              child: _buildLabel(colors, floating, validation),
            ),
          ),
      ],
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
      // `.form-control-plaintext` is only ever paired with `readonly` in the
      // kit's markup — see [ItInput.plaintext].
      readOnly: widget.readOnly || widget.plaintext,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      cursorColor: colors.primary,
      // .form-group input { color: hsl(0,0%,10%) } — the bodyColor token.
      style: ItFormMetrics.textStyle(
        fontSize: _fontSize,
        lineHeight: _lineHeight,
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
          fontSize: _fontSize,
          lineHeight: _lineHeight,
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

    // A text area's box already supplies the padding, and its field must fill
    // the box's height rather than be centred on one line — so the field is
    // returned bare and the caller's `Container` does the rest.
    if (_isTextarea) {
      return suffix == null ? labelled : Stack(children: [labelled, suffix]);
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
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
      // `textarea.form-control { background-position: top .3em right .3em
      //                          !important }` — a text area parks the glyph in
      // its top-right corner instead of centring it, because on a tall box a
      // vertically centred mark would float in the middle of the user's text.
      // `.3em` of 16px type is 4.8px.
      right: _isTextarea ? 4.8 : (45 - glyph) / 2,
      top: _isTextarea ? 4.8 : (ItFormMetrics.controlHeight - glyph) / 2,
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
