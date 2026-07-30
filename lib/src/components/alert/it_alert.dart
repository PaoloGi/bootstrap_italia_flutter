import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/spacing.dart';

/// Color variants for [ItAlert].
enum ItAlertVariant {
  /// Primary blue alert.
  primary,

  /// Secondary gray alert.
  secondary,

  /// Green success alert.
  success,

  /// Danger red alert.
  danger,

  /// Warning orange alert.
  warning,

  /// Info alert.
  info,
}

/// A Bootstrap Italia alert component.
///
/// Displays feedback messages with color-coded variants, optional icon,
/// title, and dismiss functionality.
///
/// ```dart
/// ItAlert(
///   variant: ItAlertVariant.success,
///   icon: Icons.check_circle,
///   title: 'Operazione completata',
///   child: Text('Il documento è stato salvato con successo.'),
/// )
/// ```
class ItAlert extends StatefulWidget {
  /// The alert color variant.
  final ItAlertVariant variant;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional title text.
  final String? title;

  /// Whether the alert can be dismissed.
  final bool dismissible;

  /// Called when the alert is dismissed.
  final VoidCallback? onDismissed;

  /// The alert content.
  final Widget child;

  /// Creates a Bootstrap Italia alert.
  const ItAlert({
    super.key,
    this.variant = ItAlertVariant.info,
    this.icon,
    this.title,
    this.dismissible = false,
    this.onDismissed,
    required this.child,
  });

  @override
  State<ItAlert> createState() => _ItAlertState();
}

class _ItAlertState extends State<ItAlert> with SingleTickerProviderStateMixin {
  bool _visible = true;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _visible = false);
        widget.onDismissed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final colors = resolveColorScheme(context);
    final alertColors = colors.alertColorsForVariant(widget.variant.name);
    final bgColor = alertColors.background;
    final fgColor = alertColors.foreground;
    final borderColor = alertColors.border;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Semantics(
        liveRegion: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(BootstrapItaliaSpacing.space3),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius:
                BorderRadius.circular(BootstrapItaliaBorders.radius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: fgColor, size: 24),
                const SizedBox(width: BootstrapItaliaSpacing.space2),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title != null)
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: BootstrapItaliaSpacing.space1),
                        child: Text(
                          widget.title!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: fgColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    DefaultTextStyle(
                      style: TextStyle(color: fgColor, fontSize: 14),
                      child: widget.child,
                    ),
                  ],
                ),
              ),
              if (widget.dismissible)
                GestureDetector(
                  onTap: _dismiss,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: BootstrapItaliaSpacing.space2),
                    child: Icon(Icons.close, color: fgColor, size: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
