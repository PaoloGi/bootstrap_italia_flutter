import 'package:flutter/widgets.dart';

/// An animated collapsible container — `.collapse` / `.collapsing`.
///
/// Smoothly expands and collapses its [child] based on [isExpanded]. The kit
/// expresses the three states as classes: `.collapse` hides the content,
/// `.collapsing` is worn during the transition, `.collapse.show` reveals it.
///
/// ```dart
/// ItCollapse(
///   isExpanded: _showDetails,
///   child: Text('Hidden content revealed on expand.'),
/// )
/// ```
///
/// The control that toggles it has accessibility obligations of its own —
/// `aria-expanded`, and `aria-controls` naming this panel. [ItCollapseToggle]
/// carries both; [semanticsIdentifier] is the other half of the pair.
class ItCollapse extends StatefulWidget {
  /// Whether the content is currently expanded.
  final bool isExpanded;

  /// The animation duration.
  ///
  /// `.collapsing { transition: height .35s ease }`.
  final Duration duration;

  /// The animation curve.
  ///
  /// CSS `ease` is `cubic-bezier(.25, .1, .25, 1)`, which is exactly
  /// [Curves.ease]. It is *not* `ease-in-out` — that is
  /// `cubic-bezier(.42, 0, .58, 1)`, a noticeably lazier start.
  final Curve curve;

  /// This panel's `Semantics.identifier`.
  ///
  /// §1.3.1: the string a control's `aria-controls` points at. The kit's docs
  /// are explicit that this is what lets a screen reader offer «a shortcut to
  /// navigate directly to the collapsible element itself», so it is worth
  /// setting whenever a named control opens this panel.
  final String? semanticsIdentifier;

  /// The collapsible content.
  final Widget child;

  /// Creates an animated collapse widget.
  const ItCollapse({
    super.key,
    required this.isExpanded,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.ease,
    this.semanticsIdentifier,
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
    final Widget content = SizeTransition(
      sizeFactor: _animation,
      // Reveal downward from the top edge (the replacement for the
      // deprecated `axisAlignment: -1` on a vertical SizeTransition).
      alignment: AlignmentDirectional.topStart,
      child: widget.child,
    );

    // Only when asked: an unconditional Semantics node would add one to every
    // accordion panel, callout body and megamenu section in the package for the
    // sake of a string none of them passes.
    if (widget.semanticsIdentifier == null) return content;
    return Semantics(
      identifier: widget.semanticsIdentifier,
      child: content,
    );
  }
}

/// Gives a control the state and the relationship a collapse trigger owes.
///
/// The kit's collapse docs are unusually specific about this, and the reason is
/// that the trigger is a *different element* from the thing it opens, so
/// nothing about it is self-evident to assistive technology:
///
///  * `aria-expanded` on the control — §4.1.2. Without it a screen-reader user
///    presses the button and is told nothing about what changed. The docs note
///    it must start `false` for a closed panel and `true` for one opened with
///    `.show`, which here is simply [expanded] tracking the same flag the
///    [ItCollapse] does.
///  * `aria-controls` naming the panel — §1.3.1, and the docs' own reason:
///    modern screen readers use it to offer a jump straight to the content.
///  * `role="button"` when the control is not a `<button>`. The docs call this
///    out for `<a>` and `<div>` triggers; here it is [isButton], which is on by
///    default because that is what a collapse trigger nearly always is.
///
/// Wraps an existing control rather than drawing one: the trigger in the docs
/// is a `.btn`, so the caller supplies an [ItButton] (or a link, or anything
/// else operable) and this adds only what the relationship needs.
///
/// ```dart
/// ItCollapseToggle(
///   expanded: _open,
///   controls: const {'dettagli'},
///   child: ItButton(
///     onPressed: () => setState(() => _open = !_open),
///     child: const Text('Mostra i dettagli'),
///   ),
/// )
/// ```
///
/// One control may open several panels — the docs' «Attiva/disattiva entrambi
/// gli elementi» — in which case [controls] names all of them, exactly as the
/// kit's `aria-controls="multiCollapseExample1 multiCollapseExample2"` does.
class ItCollapseToggle extends StatelessWidget {
  /// Whether the panels this control opens are currently expanded.
  final bool expanded;

  /// The [ItCollapse.semanticsIdentifier] of every panel this control opens.
  final Set<String> controls;

  /// Whether to assert the `button` role.
  ///
  /// Leave true unless the wrapped widget already carries a role of its own
  /// that would be wrong to overwrite — a link, say.
  final bool isButton;

  /// The control itself: the widget that handles the tap.
  final Widget child;

  /// Creates a collapse trigger wrapper.
  const ItCollapseToggle({
    super.key,
    required this.expanded,
    required this.controls,
    this.isButton = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      controls.isNotEmpty,
      'ItCollapseToggle.controls is empty.\n'
      'The whole point of this wrapper is the `aria-controls` relationship '
      'between a trigger and the panel it opens; with no identifiers it '
      'contributes an expanded state pointing at nothing. Give each ItCollapse '
      'a semanticsIdentifier and name it here.',
    );
    // MergeSemantics, not a bare Semantics: the wrapped control already
    // produces its own node with the label, role and tap action. Left
    // unmerged, `expanded` would sit on a separate parent node and AT would
    // read a container and then a button, instead of one control that says
    // what state it is in.
    return MergeSemantics(
      child: Semantics(
        button: isButton ? true : null,
        expanded: expanded,
        controlsNodes: controls,
        child: child,
      ),
    );
  }
}
