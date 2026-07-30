import 'dart:async';

import 'package:flutter/material.dart';

import '../../tokens/borders.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../theme/theme_extensions.dart';

/// Color variants for [ItNotification].
enum ItNotificationVariant {
  /// Green success notification.
  success,

  /// Orange warning notification.
  warning,

  /// Red danger notification.
  danger,

  /// Blue info notification.
  info,
}

/// Screen position for overlay notifications.
enum ItNotificationPosition {
  /// Top-right corner.
  topRight,

  /// Top-left corner.
  topLeft,

  /// Top center.
  topCenter,

  /// Bottom-right corner.
  bottomRight,

  /// Bottom-left corner.
  bottomLeft,

  /// Bottom center.
  bottomCenter,
}

/// A Bootstrap Italia notification (toast) component.
///
/// Displays a transient feedback message with a color-coded left border,
/// optional icon, title, message, and dismiss button.
///
/// Use [ItNotification.show] to display a notification as an overlay:
///
/// ```dart
/// ItNotification.show(
///   context: context,
///   variant: ItNotificationVariant.success,
///   title: 'Salvato',
///   message: 'Il documento è stato salvato.',
///   icon: Icons.check_circle,
///   dismissible: true,
///   duration: Duration(seconds: 5),
///   position: ItNotificationPosition.topRight,
/// );
/// ```
class ItNotification extends StatefulWidget {
  /// The notification color variant.
  final ItNotificationVariant variant;

  /// Optional title text displayed in bold.
  final String? title;

  /// Optional message body.
  final String? message;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the notification can be dismissed via a close button.
  final bool dismissible;

  /// Called after the exit animation completes when the notification
  /// is dismissed (either manually or by auto-dismiss timer).
  final VoidCallback? onDismissed;

  /// Auto-dismiss duration. When non-null the notification dismisses
  /// automatically after this duration. Pass `null` for a persistent
  /// notification.
  final Duration? duration;

  /// Creates a Bootstrap Italia notification widget.
  const ItNotification({
    super.key,
    this.variant = ItNotificationVariant.info,
    this.title,
    this.message,
    this.icon,
    this.dismissible = true,
    this.onDismissed,
    this.duration,
  });

  /// Shows a notification as an overlay positioned on screen.
  ///
  /// Returns the [OverlayEntry] so the caller can remove it programmatically.
  ///
  /// The notification auto-dismisses after [duration] (defaults to 5 seconds).
  /// Pass `null` for a persistent notification that must be dismissed manually
  /// or removed via the returned [OverlayEntry].
  static OverlayEntry show({
    required BuildContext context,
    ItNotificationVariant variant = ItNotificationVariant.info,
    String? title,
    String? message,
    IconData? icon,
    bool dismissible = true,
    Duration? duration = const Duration(seconds: 5),
    ItNotificationPosition position = ItNotificationPosition.topRight,
  }) {
    late final OverlayEntry entry;
    final padding = MediaQuery.of(context).padding;
    const inset = BootstrapItaliaSpacing.space3;

    entry = OverlayEntry(
      builder: (context) {
        final child = ItNotification(
          variant: variant,
          title: title,
          message: message,
          icon: icon,
          dismissible: dismissible,
          duration: duration,
          onDismissed: () => entry.remove(),
        );

        final isTop = position == ItNotificationPosition.topRight ||
            position == ItNotificationPosition.topLeft ||
            position == ItNotificationPosition.topCenter;
        final isBottom = !isTop;
        final isCenter = position == ItNotificationPosition.topCenter ||
            position == ItNotificationPosition.bottomCenter;
        final isLeft = position == ItNotificationPosition.topLeft ||
            position == ItNotificationPosition.bottomLeft;
        final isRight = position == ItNotificationPosition.topRight ||
            position == ItNotificationPosition.bottomRight;

        return Positioned(
          top: isTop ? inset + padding.top : null,
          bottom: isBottom ? inset + padding.bottom : null,
          left: isCenter ? 0 : (isLeft ? inset : null),
          right: isCenter ? 0 : (isRight ? inset : null),
          child: isCenter ? Center(child: child) : child,
        );
      },
    );

    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  State<ItNotification> createState() => _ItNotificationState();
}

class _ItNotificationState extends State<ItNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();

    if (widget.duration != null) {
      _autoDismissTimer = Timer(widget.duration!, _dismiss);
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final accentColor = colors.forVariant(widget.variant.name);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Semantics(
          liveRegion: true,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
                minWidth: 300,
              ),
              padding: const EdgeInsets.all(BootstrapItaliaSpacing.space3),
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius:
                    BorderRadius.circular(BootstrapItaliaBorders.radiusLg),
                boxShadow: BootstrapItaliaShadows.lg,
                border: Border(
                  left: BorderSide(color: accentColor, width: 4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: accentColor, size: 24),
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
                              bottom: BootstrapItaliaSpacing.space1,
                            ),
                            child: Text(
                              widget.title!,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colors.neutral1,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (widget.message != null)
                          Text(
                            widget.message!,
                            style: TextStyle(
                              color: colors.secondary,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.dismissible) ...[
                    const SizedBox(width: BootstrapItaliaSpacing.space2),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Icon(
                        Icons.close,
                        color: colors.gray400,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
