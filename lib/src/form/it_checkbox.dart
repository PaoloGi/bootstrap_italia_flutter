import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';
import '../tokens/spacing.dart';

/// A Bootstrap Italia checkbox.
///
/// Wraps Flutter's [Checkbox] with Bootstrap Italia styling and an
/// integrated label.
///
/// ```dart
/// ItCheckbox(
///   value: true,
///   label: 'Accetto i termini e le condizioni',
///   onChanged: (value) {},
/// )
/// ```
class ItCheckbox extends StatelessWidget {
  /// Whether the checkbox is checked.
  final bool value;

  /// Whether to enable tristate (null = indeterminate).
  final bool tristate;

  /// The label text displayed next to the checkbox.
  final String? label;

  /// Custom label widget. Overrides [label] if provided.
  final Widget? labelWidget;

  /// Called when the checkbox value changes.
  final ValueChanged<bool?>? onChanged;

  /// Whether the checkbox is disabled.
  final bool disabled;

  /// Creates a Bootstrap Italia checkbox.
  const ItCheckbox({
    super.key,
    required this.value,
    this.tristate = false,
    this.label,
    this.labelWidget,
    this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return GestureDetector(
      onTap: disabled
          ? null
          : () {
              if (tristate) {
                // cycle: false -> true -> null -> false
                if (value == false) {
                  onChanged?.call(true);
                } else if (value == true) {
                  onChanged?.call(null);
                } else {
                  onChanged?.call(false);
                }
              } else {
                onChanged?.call(!value);
              }
            },
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                tristate: tristate,
                onChanged: disabled ? null : onChanged,
                activeColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (label != null || labelWidget != null) ...[
              const SizedBox(width: BootstrapItaliaSpacing.space2),
              Flexible(
                child: labelWidget ??
                    Text(
                      label!,
                      style: TextStyle(
                        fontSize: 16,
                        color: disabled
                            ? colors.gray400
                            : colors.bodyColor,
                      ),
                    ),
              ),
            ],
          ],
        ),
      ),
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

  /// Creates a checkbox group.
  const ItCheckboxGroup({
    super.key,
    this.label,
    required this.options,
    required this.values,
    this.onChanged,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    final checkboxes = options.map((option) {
      return ItCheckbox(
        value: values.contains(option.value),
        label: option.label,
        disabled: option.disabled,
        onChanged: (checked) {
          final newValues = Set<T>.from(values);
          if (checked == true) {
            newValues.add(option.value);
          } else {
            newValues.remove(option.value);
          }
          onChanged?.call(newValues);
        },
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.neutral1,
            ),
          ),
          const SizedBox(height: BootstrapItaliaSpacing.space2),
        ],
        if (inline)
          Wrap(
            spacing: BootstrapItaliaSpacing.space4,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: checkboxes,
          )
        else
          ...checkboxes.map((cb) => Padding(
                padding: const EdgeInsets.only(bottom: BootstrapItaliaSpacing.space2),
                child: cb,
              )),
      ],
    );
  }
}

/// An option within an [ItCheckboxGroup].
class ItCheckboxOption<T> {
  /// The option value.
  final T value;

  /// The display label.
  final String label;

  /// Whether this option is disabled.
  final bool disabled;

  /// Creates a checkbox option.
  const ItCheckboxOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });
}
