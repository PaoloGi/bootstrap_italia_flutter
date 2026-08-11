import 'package:flutter/widgets.dart';

/// An animated collapsible container.
///
/// Smoothly expands and collapses its [child] based on [isExpanded].
///
/// ```dart
/// ItCollapse(
///   isExpanded: _showDetails,
///   child: Text('Hidden content revealed on expand.'),
/// )
/// ```
class ItCollapse extends StatefulWidget {
  /// Whether the content is currently expanded.
  final bool isExpanded;

  /// The animation duration.
  final Duration duration;

  /// The animation curve.
  final Curve curve;

  /// The collapsible content.
  final Widget child;

  /// Creates an animated collapse widget.
  const ItCollapse({
    super.key,
    required this.isExpanded,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    required this.child,
  });

  @override
  State<ItCollapse> createState() => _ItCollapseState();
}

class _ItCollapseState extends State<ItCollapse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
  }

  @override
  void didUpdateWidget(ItCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      // Reveal downward from the top edge (the replacement for the
      // deprecated `axisAlignment: -1` on a vertical SizeTransition).
      alignment: AlignmentDirectional.topStart,
      child: widget.child,
    );
  }
}
