import 'package:flutter/material.dart';

import '../theme/bootstrap_italia_theme_data.dart';
import '../theme/theme_extensions.dart';
import '../tokens/spacing.dart';

/// Validation state for form inputs.
enum ItValidationState {
  /// Green success state.
  success,

  /// Orange warning state.
  warning,

  /// Red danger/error state.
  danger,
}

/// A Bootstrap Italia text input field.
///
/// Wraps Flutter's [TextField] with Bootstrap Italia styling: underline-only
/// border (no box outline), floating label, icon, helper text, validation
/// states, and password visibility toggle.
///
/// When [icon] is provided, the input renders in an `.input-group` layout
/// with the icon in a separate container to the left of the field, matching
/// Bootstrap Italia's `.input-group-text` pattern.
///
/// When [trailingAction] is provided, it is placed to the right of the field,
/// matching Bootstrap Italia's `.input-group-append` pattern (e.g. "Invio"
/// button).
///
/// ```dart
/// ItInput(
///   label: 'Nome completo',
///   hint: 'Inserisci il tuo nome',
///   icon: Icons.edit,
///   helperText: 'Come da documento',
///   onChanged: (value) {},
/// )
/// ```
class ItInput extends StatefulWidget {
  /// The floating label text.
  final String? label;

  /// Placeholder text shown when the field is empty.
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

  /// Helper text below the field.
  final String? helperText;

  /// Error text. When set, forces [validationState] to danger.
  final String? errorText;

  /// Whether to obscure text (password field).
  final bool obscureText;

  /// Whether to show a password visibility toggle.
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
  });

  @override
  State<ItInput> createState() => _ItInputState();
}

class _ItInputState extends State<ItInput> {
  late bool _obscured;
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _initFocusNode();
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

  @override
  void didUpdateWidget(covariant ItInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (_ownsFocusNode) _focusNode.dispose();
      _initFocusNode();
    }
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  ItValidationState? get _effectiveValidation =>
      widget.errorText != null
          ? ItValidationState.danger
          : widget.validationState;

  Color _validationColor(BootstrapItaliaColorScheme colors) {
    return switch (_effectiveValidation!) {
      ItValidationState.success => colors.success,
      ItValidationState.warning => colors.warning,
      ItValidationState.danger => colors.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    // Bootstrap Italia: $input-border: $gray-secondary (#5D7083)
    final borderColor = _effectiveValidation == null
        ? colors.secondary
        : _validationColor(colors);

    // Bootstrap Italia: $input-focus-border-color: $gray-secondary
    // But with validation, keep the validation color on focus
    final focusBorderColor =
        _effectiveValidation == null ? colors.primary : borderColor;

    // BI: label color changes to primary on focus, validation color when
    // validation is active, muted gray when disabled.
    final Color labelColor;
    if (!widget.enabled) {
      labelColor = colors.gray400;
    } else if (_effectiveValidation != null) {
      labelColor = _validationColor(colors);
    } else if (_isFocused) {
      labelColor = colors.primary;
    } else {
      labelColor = colors.bodyColor;
    }

    final floatingLabelColor = labelColor;

    final helperOrError = widget.errorText ?? widget.helperText;
    // BI: helper/error text color matches validation state
    final helperColor = _effectiveValidation != null
        ? _validationColor(colors)
        : colors.secondary;

    final hasInputGroup = widget.icon != null || widget.trailingAction != null;

    final textField = TextField(
      controller: widget.controller,
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
      style: TextStyle(
        fontSize: 16,
        color: widget.enabled ? colors.bodyColor : colors.gray400,
      ),
      decoration: InputDecoration(
        // BI: disabled inputs get $input-disabled-bg: $gray-200 as a filled
        // rounded rectangle with no underline border.
        filled: !widget.enabled,
        fillColor: colors.gray200,
        labelText: widget.label,
        hintText: widget.hint,
        // Bootstrap Italia: $input-label-color: $color-text-base
        labelStyle: TextStyle(
          color: labelColor,
          fontSize: 16,
        ),
        floatingLabelStyle: TextStyle(
          color: floatingLabelColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        // BI disabled: label sits inline (not floating) — force non-floating
        floatingLabelBehavior: widget.enabled
            ? FloatingLabelBehavior.auto
            : FloatingLabelBehavior.never,
        // Bootstrap Italia: $input-color-placeholder: $color-text-muted
        hintStyle: TextStyle(
          color: colors.secondary,
          fontSize: 16,
        ),
        // No prefixIcon — BI uses separate .input-group-text container
        suffixIcon: _buildSuffix(colors, borderColor),
        // Bootstrap Italia: underline-only borders (enabled),
        // rounded filled rectangle with no border (disabled).
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: focusBorderColor, width: 2),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.black),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BootstrapItaliaSpacing.space2,
          vertical: BootstrapItaliaSpacing.space2,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasInputGroup)
          _buildInputGroup(colors, textField)
        else
          textField,
        if (helperOrError != null) ...[
          const SizedBox(height: BootstrapItaliaSpacing.space1),
          Text(
            helperOrError,
            style: TextStyle(fontSize: 12, color: helperColor),
          ),
        ],
      ],
    );
  }

  /// Builds the BI `.input-group` layout: [icon] [textField] [trailingAction]
  Widget _buildInputGroup(
      BootstrapItaliaColorScheme colors, Widget textField) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.icon != null)
          Padding(
            padding: const EdgeInsets.only(
              right: BootstrapItaliaSpacing.space2,
              bottom: BootstrapItaliaSpacing.space2,
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: !widget.enabled
                  ? colors.gray400
                  : _effectiveValidation != null
                      ? _validationColor(colors)
                      : colors.secondary,
            ),
          ),
        Expanded(child: textField),
        if (widget.trailingAction != null)
          Padding(
            padding: const EdgeInsets.only(
              left: BootstrapItaliaSpacing.space2,
            ),
            child: widget.trailingAction!,
          ),
      ],
    );
  }

  Widget? _buildSuffix(
      BootstrapItaliaColorScheme colors, Color borderColor) {
    final widgets = <Widget>[];

    if (_effectiveValidation != null) {
      final icon = switch (_effectiveValidation!) {
        ItValidationState.success => Icons.check_circle,
        ItValidationState.warning => Icons.warning_amber,
        ItValidationState.danger => Icons.error,
      };
      widgets.add(Icon(icon, size: 20, color: borderColor));
    }

    if (widget.showPasswordToggle) {
      widgets.add(
        GestureDetector(
          onTap: () => setState(() => _obscured = !_obscured),
          child: Icon(
            _obscured ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: colors.secondary,
          ),
        ),
      );
    }

    if (widgets.isEmpty) return null;
    if (widgets.length == 1) return widgets.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final w in widgets) ...[
          w,
          const SizedBox(width: 4),
        ],
      ],
    );
  }
}
