import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../a11y/it_focus_ring.dart';
import '../theme/theme_extensions.dart';
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
    this.focusNode,
  });

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
    widget.onChanged!.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final value = widget.value;
    final label = widget.label;
    final enabled = widget.enabled;
    final validation =
        ItFieldValidation.effective(widget.errorText, widget.validationState);

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
    final labelColor = enabled && validation != null
        ? ItFieldValidation.color(colors, validation)
        : colors.bodyColor;

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
        hint: ItFieldValidation.hint(widget.errorText, widget.helperText),
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
      errorText: widget.errorText,
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
