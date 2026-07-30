import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';
import '../tokens/spacing.dart';

/// An option within an [ItRadioGroup].
class ItRadioOption<T> {
  /// The option value.
  final T value;

  /// The display label.
  final String label;

  /// Whether this option is disabled.
  final bool disabled;

  /// Creates a radio option.
  const ItRadioOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });
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
class ItRadioGroup<T> extends StatelessWidget {
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

  /// Creates a Bootstrap Italia radio group.
  const ItRadioGroup({
    super.key,
    this.label,
    required this.options,
    this.value,
    this.onChanged,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    final radios = options.map((option) {
      return GestureDetector(
        onTap: option.disabled
            ? null
            : () => onChanged?.call(option.value),
        child: Opacity(
          opacity: option.disabled ? 0.5 : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Radio<T>(
                  value: option.value,
                  // ignore: deprecated_member_use
                  groupValue: value,
                  // ignore: deprecated_member_use
                  onChanged: option.disabled
                      ? null
                      : (v) {
                          if (v != null) onChanged?.call(v);
                        },
                  // ignore: deprecated_member_use
                  activeColor: colors.primary,
                ),
              ),
              const SizedBox(width: BootstrapItaliaSpacing.space2),
              Flexible(
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 16,
                    color: option.disabled
                        ? colors.gray400
                        : colors.bodyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
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
            children: radios,
          )
        else
          ...radios.map((r) => Padding(
                padding:
                    const EdgeInsets.only(bottom: BootstrapItaliaSpacing.space2),
                child: r,
              )),
      ],
    );
  }
}
