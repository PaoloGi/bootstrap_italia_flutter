import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

/// A Bootstrap Italia "back to top" floating button.
///
/// Appears after the user scrolls past [showAfter] pixels and smoothly
/// scrolls back to the top when tapped.
///
/// ```dart
/// Stack(
///   children: [
///     ListView(...),
///     ItBackToTop(scrollController: _scrollController),
///   ],
/// )
/// ```
class ItBackToTop extends StatefulWidget {
  /// The scroll controller to monitor and animate.
  final ScrollController scrollController;

  /// Scroll offset (in pixels) after which the button appears.
  final double showAfter;

  /// Animation duration for scrolling to top.
  final Duration scrollDuration;

  /// Custom icon. Defaults to [Icons.arrow_upward].
  final IconData icon;

  /// Button color. Defaults to the theme's primary color.
  final Color? color;

  /// Creates a back-to-top button.
  const ItBackToTop({
    super.key,
    required this.scrollController,
    this.showAfter = 200,
    this.scrollDuration = const Duration(milliseconds: 500),
    this.icon = Icons.arrow_upward,
    this.color,
  });

  @override
  State<ItBackToTop> createState() => _ItBackToTopState();
}

class _ItBackToTopState extends State<ItBackToTop> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    _checkVisibility();
  }

  @override
  void didUpdateWidget(ItBackToTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() => _checkVisibility();

  void _checkVisibility() {
    if (!widget.scrollController.hasClients) return;
    final shouldShow = widget.scrollController.offset > widget.showAfter;
    if (shouldShow != _visible) {
      setState(() => _visible = shouldShow);
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: widget.scrollDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final effectiveColor = widget.color ?? colors.primary;

    return Positioned(
      right: 16,
      bottom: 16,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedScale(
          scale: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Semantics(
            button: true,
            label: 'Torna su',
            child: FloatingActionButton.small(
              onPressed: _visible ? _scrollToTop : null,
              backgroundColor: effectiveColor,
              foregroundColor: colors.white,
              elevation: 4,
              child: Icon(widget.icon),
            ),
          ),
        ),
      ),
    );
  }
}
