import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart'
    show TimeOfDay, showDatePicker, showTimePicker;

import '../a11y/it_icon_action.dart';
import '../l10n/it_localizations.dart';
import 'it_form_metrics.dart';
import 'it_input.dart';

/// What [ItDateField] asks for.
enum ItDateFieldMode {
  /// A day. `<input type="date">`.
  date,

  /// A time of day. `<input type="time">`.
  time,

  /// Both, in one field — a day and a time on it.
  dateAndTime,
}

/// Bootstrap Italia's "Input Datepicker" and "Input Hourpicker".
///
/// Upstream these are plain form controls. Read back from design-react-kit in
/// Chromium, the whole of the datepicker's markup is
///
/// ```html
/// <div class="form-group">
///   <label class="active">Datepicker</label>
///   <input type="date" class="form-control" placeholder="22/12/2023">
/// </div>
/// ```
///
/// — no panel, no calendar, no stylesheet rules of its own beyond
/// `.form-control`. The browser supplies the picker, and the browser's picker
/// is the operating system's.
///
/// So this is an [ItInput] whose value is chosen in the *platform's* picker
/// rather than in a calendar this package draws: a calendar would have no
/// upstream to be faithful to, and every pixel of it would be invented. On iOS
/// and macOS that is Cupertino's wheel; elsewhere it is the one the OS ships,
/// which on Android is Material's. That split is the point — it is what
/// "whatever the browser does" means on a phone.
///
/// The field is read-only: a tap anywhere on it opens the picker, and so does
/// the calendar button beside it, which is a real focus stop with a name, so
/// the control is reachable without a pointer.
class ItDateField extends StatefulWidget {
  /// Creates a date, time, or date-and-time field.
  const ItDateField({
    super.key,
    this.value,
    this.onChanged,
    this.mode = ItDateFieldMode.date,
    this.label,
    this.helperText,
    this.errorText,
    this.required = false,
    this.enabled = true,
    this.groupMargin = true,
    this.firstDate,
    this.lastDate,
    this.semanticLabel,
    this.pickLabel,
    this.focusNode,
  });

  /// The current value, or null when the field is empty.
  final DateTime? value;

  /// Called with what the picker returned. Not called when it is dismissed.
  final ValueChanged<DateTime?>? onChanged;

  /// Whether to ask for a day, a time, or both.
  final ItDateFieldMode mode;

  /// The field's label, as [ItInput.label].
  final String? label;

  /// Supporting text under the field.
  final String? helperText;

  /// The validation message, which also turns the field's chrome red.
  final String? errorText;

  /// Whether the field is required, as [ItInput.required].
  final bool required;

  /// Whether the field can be used.
  final bool enabled;

  /// Whether to reserve `.form-group`'s bottom margin, as [ItInput.groupMargin].
  final bool groupMargin;

  /// The earliest value the picker offers. Defaults to the year 1900.
  final DateTime? firstDate;

  /// The latest value the picker offers. Defaults to the year 2100.
  final DateTime? lastDate;

  /// The field's accessible name, when the visible label is not it.
  final String? semanticLabel;

  /// The field's focus node, when the caller needs one — to scroll to the
  /// field after a failed validation, say.
  final FocusNode? focusNode;

  /// Names the button that opens the picker. Defaults to the localised
  /// "choose the date" / "choose the time".
  final String? pickLabel;

  @override
  State<ItDateField> createState() => _ItDateFieldState();
}

class _ItDateFieldState extends State<ItDateField> {
  late final TextEditingController _controller =
      TextEditingController(text: _format(widget.value));

  @override
  void didUpdateWidget(ItDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = _format(widget.value);
    if (text != _controller.text) _controller.text = text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// `dd/MM/yyyy`, `HH:mm`, or both — the format upstream shows in its own
  /// placeholder (`22/12/2023`), and a 24-hour clock, as Italian uses.
  String _format(DateTime? v) {
    if (v == null) return '';
    final date = '${_two(v.day)}/${_two(v.month)}/${v.year}';
    final time = '${_two(v.hour)}:${_two(v.minute)}';
    return switch (widget.mode) {
      ItDateFieldMode.date => date,
      ItDateFieldMode.time => time,
      ItDateFieldMode.dateAndTime => '$date $time',
    };
  }

  bool get _cupertino => switch (defaultTargetPlatform) {
        TargetPlatform.iOS || TargetPlatform.macOS => true,
        _ => false,
      };

  DateTime get _first => widget.firstDate ?? DateTime(1900);
  DateTime get _last => widget.lastDate ?? DateTime(2100);

  Future<void> _open() async {
    if (!widget.enabled || widget.onChanged == null) return;
    final initial = widget.value ?? DateTime.now();
    final picked =
        _cupertino ? await _wheel(initial) : await _platformDialogs(initial);
    if (picked != null && mounted) widget.onChanged!(picked);
  }

  /// iOS and macOS: one wheel, confirmed by a button — the picker those
  /// platforms show for a date input.
  Future<DateTime?> _wheel(DateTime initial) {
    final l10n = ItLocalizations.of(context);
    var current = initial;
    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (sheet) => Container(
        height: 320,
        color: CupertinoColors.systemBackground.resolveFrom(sheet),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  onPressed: () => Navigator.of(sheet).pop(current),
                  child: Text(l10n.confirmPick),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: initial,
                  minimumDate: _first,
                  maximumDate: _last,
                  use24hFormat: true,
                  mode: switch (widget.mode) {
                    ItDateFieldMode.date => CupertinoDatePickerMode.date,
                    ItDateFieldMode.time => CupertinoDatePickerMode.time,
                    ItDateFieldMode.dateAndTime =>
                      CupertinoDatePickerMode.dateAndTime,
                  },
                  onDateTimeChanged: (v) => current = v,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Everywhere else: the OS's own dialogs, one per part.
  Future<DateTime?> _platformDialogs(DateTime initial) async {
    DateTime? day = initial;
    if (widget.mode != ItDateFieldMode.time) {
      day = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: _first,
        lastDate: _last,
      );
      if (day == null || !mounted) return null;
    }
    if (widget.mode == ItDateFieldMode.date) return day;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ItLocalizations.of(context);
    final asksTime = widget.mode == ItDateFieldMode.time;
    return ItInput(
      label: widget.label,
      controller: _controller,
      readOnly: true,
      onTap: _open,
      enabled: widget.enabled,
      required: widget.required,
      helperText: widget.helperText,
      errorText: widget.errorText,
      groupMargin: widget.groupMargin,
      semanticLabel: widget.semanticLabel,
      focusNode: widget.focusNode,
      trailingAction: ItIconAction(
        icon: asksTime
            ? BootstrapItaliaIcons.it_clock
            : BootstrapItaliaIcons.it_calendar,
        color: ItFormMetrics.borderColor,
        label:
            widget.pickLabel ?? (asksTime ? l10n.chooseTime : l10n.chooseDate),
        onPressed: widget.enabled ? _open : null,
      ),
    );
  }
}
