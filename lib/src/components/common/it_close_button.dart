import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../a11y/it_focus_ring.dart';

/// Metrics for `.btn-close`, shared by every component that renders one.
///
/// `.modal-header .btn-close` and `.offcanvas-header .btn-close` resolve to the
/// same numbers — each is `calc(<container padding> * .5)`, and both containers
/// pad by 24px — so one set of constants covers both.
abstract final class ItCloseButtonMetrics {
  /// `.btn-close` occupies a 16x16 slot flush with the header padding edge.
  static const double boxSize = 16;

  /// `.modal-header .btn-close { padding: calc(--bs-modal-header-padding * .5) }`
  /// and `.offcanvas-header .btn-close { padding: calc(--bs-offcanvas-padding-y * .5) }`
  /// — a 12px inset on every side, cancelled for layout purposes by equal
  /// negative margins. The button therefore *occupies* 16x16 of the header row
  /// but is *clickable* across 40x40.
  ///
  /// Reproducing the inset is what keeps the control above the 24x24 floor of
  /// WCAG 2.5.8 Target Size (Minimum): the painted glyph alone is 16x16.
  static const double hitInset = 12;

  /// The Bootstrap Italia `it-close` glyph covers ~9/24 of its em box, so it
  /// has to be scaled up to fill the 16x16 `.btn-close` background artwork.
  static const double glyphSize = boxSize * 24 / 9;
}

/// `.btn-close` — the dismiss control in a modal or offcanvas header.
///
/// The header `.btn-close` has a 12px inset and equal negative margins, so
/// it occupies a 16x16 slot flush with the header's right padding edge while
/// remaining clickable across 40x40. [ItExpandedHitTarget] reproduces exactly
/// that split, which is what lifts the control over the 24x24 minimum of
/// WCAG 2.5.8 without moving a single painted pixel.
///
/// It is a real focus target too: the previous `GestureDetector` could only be
/// operated with a pointer, so a keyboard user could never close the dialog
/// from its header (WCAG 2.1.1 Keyboard).
class ItCloseButton extends StatefulWidget {
  /// Called when the button is activated by pointer, keyboard or AT.
  final VoidCallback onPressed;

  /// The accessible name.
  ///
  /// Required rather than defaulted, because the right words depend on what
  /// is being closed: a modal is a dialog, an offcanvas is a panel, and a
  /// screen-reader user hearing the wrong noun is told the wrong thing about
  /// where they are.
  final String label;

  /// Creates a `.btn-close`.
  const ItCloseButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  State<ItCloseButton> createState() => _ItCloseButtonState();
}

class _ItCloseButtonState extends State<ItCloseButton> {
  bool _focused = false;

  void _setFocused(bool value) {
    if (_focused != value) setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    return ItExpandedHitTarget(
      // `.modal-header .btn-close { padding: 12px; margin: -12px }`.
      expansion: const EdgeInsets.all(ItCloseButtonMetrics.hitInset),
      // The label, the button role and the focusability all have to land on a
      // single node: split across two, AT announces an unnamed focusable child
      // inside a button it cannot reach (WCAG 4.1.2).
      child: MergeSemantics(
        child: Semantics(
          label: widget.label,
          button: true,
          enabled: true,
          onTap: widget.onPressed,
          child: FocusableActionDetector(
            onShowFocusHighlight: _setFocused,
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  widget.onPressed();
                  return null;
                },
              ),
              ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
                onInvoke: (_) {
                  widget.onPressed();
                  return null;
                },
              ),
            },
            // WCAG 2.4.7 Focus Visible. The design system's own indicator is
            // painted only while the control holds keyboard focus, so the
            // default rendering — and therefore visual parity — is untouched.
            child: ItFocusRing(
              visible: _focused,
              child: GestureDetector(
                onTap: widget.onPressed,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: ItCloseButtonMetrics.boxSize,
                  height: ItCloseButtonMetrics.boxSize,
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: Icon(
                      BootstrapItaliaIcons.it_close,
                      // `.btn-close` paints a black glyph at 50% opacity.
                      color: Color(0x80000000),
                      size: ItCloseButtonMetrics.glyphSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays out exactly like its child but accepts pointer events across a larger
/// rectangle, reproducing a CSS `padding` + equal negative `margin` pair.
///
/// Flutter clips hit testing to a render object's own box, so the usual tricks
/// (`OverflowBox`, an oversized `Stack` child) cannot enlarge a tap target
/// without also enlarging the layout box — which would move neighbouring
/// content. This widget keeps the layout box untouched and instead widens the
/// region it answers `hitTest` for, clamping the hit back into the child so the
/// child's own gesture recognisers still receive it.
///
/// Note that ancestors still bound hit testing to *their* boxes, so the usable
/// target is the expansion intersected with the parent's rect. For the modal
/// close button that yields roughly 28x36 against a 16x16 painted glyph, which
/// clears the 24x24 floor of WCAG 2.5.8 Target Size (Minimum).
class ItExpandedHitTarget extends SingleChildRenderObjectWidget {
  /// How far beyond the child's box pointer events are still accepted.
  final EdgeInsets expansion;

  /// Creates a hit target that extends [expansion] beyond its child.
  const ItExpandedHitTarget({
    super.key,
    required this.expansion,
    required super.child,
  });

  @override
  RenderProxyBox createRenderObject(BuildContext context) =>
      _RenderItExpandedHitTarget(expansion);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderProxyBox renderObject,
  ) {
    (renderObject as _RenderItExpandedHitTarget).expansion = expansion;
  }
}

class _RenderItExpandedHitTarget extends RenderProxyBox {
  _RenderItExpandedHitTarget(this._expansion);

  EdgeInsets _expansion;

  EdgeInsets get expansion => _expansion;

  set expansion(EdgeInsets value) {
    if (_expansion == value) return;
    _expansion = value;
    markNeedsLayout();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!_expansion.inflateRect(Offset.zero & size).contains(position)) {
      return false;
    }
    // Clamp into the painted box so the child's recognisers accept the hit.
    // A tap only needs to be on the recogniser's hit path, so nudging the
    // local coordinates costs nothing.
    final clamped = Offset(
      position.dx.clamp(0.0, size.width - _kHitEpsilon),
      position.dy.clamp(0.0, size.height - _kHitEpsilon),
    );
    return super.hitTest(result, position: clamped);
  }

  /// Keeps a clamped position strictly inside the box: `size.contains` treats
  /// the right and bottom edges as outside.
  static const double _kHitEpsilon = 0.01;
}
