import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';
import '../tokens/spacing.dart';

/// A Bootstrap Italia toggle switch.
///
/// A styled on/off switch with an integrated label.
///
/// ```dart
/// ItToggle(
///   value: true,
///   label: 'Notifiche email',
///   onChanged: (value) {},
/// )
/// ```
class ItToggle extends StatelessWidget {
  /// Whether the toggle is on.
  final bool value;

  /// The label text.
  final String? label;

  /// Called when the toggle value changes.
  final ValueChanged<bool>? onChanged;

  /// Whether the toggle is disabled.
  final bool disabled;

  /// Creates a Bootstrap Italia toggle.
  const ItToggle({
    super.key,
    required this.value,
    this.label,
    this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return GestureDetector(
      onTap: disabled ? null : () => onChanged?.call(!value),
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 44,
              child: Switch(
                value: value,
                onChanged: disabled ? null : onChanged,
                // ignore: deprecated_member_use
                activeColor: colors.primary,
                activeTrackColor: colors.primary.withAlpha(77),
                inactiveThumbColor: colors.gray400,
                inactiveTrackColor: colors.gray300,
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: BootstrapItaliaSpacing.space2),
              Flexible(
                child: Text(
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
