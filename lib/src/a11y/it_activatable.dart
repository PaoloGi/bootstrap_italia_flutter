import 'package:flutter/widgets.dart';

import 'it_focus_ring.dart';

/// Makes a hand-painted control keyboard operable without changing its layout.
///
/// The pixel-parity pass replaced Material widgets with
/// [GestureDetector]-based painting. A bare [GestureDetector] is invisible to
/// focus traversal, so those controls became mouse/touch only — a WCAG 2.2
/// §2.1.1 (Keyboard) failure, and §2.4.3 (Focus Order) has nothing to order.
///
/// This wrapper restores both:
///
///  * §2.1.1 — [FocusableActionDetector] registers the control with the focus
///    system and binds [ActivateIntent] (Enter / Space, mapped by [WidgetsApp]'s
///    default shortcuts) to [onPressed].
///  * §2.4.7 Focus Visible — [ItFocusRing] paints Bootstrap Italia's
///    `box-shadow: 0 0 0 2px #fff, 0 0 0 5px #000` indicator, and only while
///    the control holds *keyboard* focus.
///
/// The ring is stroked outside the child's box by a painter that is always
/// mounted, so it consumes no layout space, cannot shift a single pixel of the
/// painted control, and cannot remount the focus node it depends on. Parity
/// captures render unfocused, so they are unaffected.
///
/// Semantics are deliberately *not* set here: role and state differ per call
/// site (link, button, tab, expanded…), so each component wraps its own
/// [Semantics] around this widget.
class ItActivatable extends StatefulWidget {
  /// Invoked on tap, and on Enter/Space while focused.
  ///
  /// When null the control is inert and skipped by focus traversal.
  final VoidCallback? onPressed;

  /// The painted control.
  final Widget child;

  /// Whether to paint the focus ring. Disable only when an ancestor already
  /// draws one for this control.
  final bool showFocusRing;

  /// Corner radius of the focus ring.
  final BorderRadius borderRadius;

  /// Cursor shown on hover when enabled.
  final MouseCursor cursor;

  /// Cursor shown while the control is inert.
  ///
  /// Defaults to the plain arrow. Pass [MouseCursor.defer] where an ancestor
  /// already resolves the disabled cursor (the chip's `:not(.chip-disabled)`
  /// guard, for example, asks for `not-allowed`).
  final MouseCursor disabledCursor;

  /// How the underlying [GestureDetector] participates in hit testing.
  final HitTestBehavior hitTestBehavior;

  /// An externally owned focus node.
  final FocusNode? focusNode;

  /// Whether this control takes focus when first built.
  final bool autofocus;

  /// Whether the control sits on a dark surface.
  ///
  /// Inverts the focus ring's two bands, per
  /// `.bg-dark .btn:focus:not([data-focus-mouse=true])`. Forwarded to
  /// [ItFocusRing.onDark].
  final bool onDark;

  /// Called when the pointer enters or leaves the control.
  ///
  /// Bootstrap Italia expresses hover as a colour change the control paints
  /// itself, so this reports the state rather than painting anything. It exists
  /// so a control needing hover does not have to reimplement the whole detector
  /// to get it — which is how `ItButton` came to bind a different set of
  /// activation intents from every other control in the package.
  final ValueChanged<bool>? onHoverChanged;

  /// Called when the control is pressed and released.
  ///
  /// Reports `true` on tap-down and `false` on tap-up *or* tap-cancel. The
  /// cancel case matters: a press that slides off the control must not leave it
  /// painted as pressed for the rest of its life.
  final ValueChanged<bool>? onPressedChanged;

  /// Creates a keyboard-operable wrapper around a painted control.
  const ItActivatable({
    super.key,
    required this.onPressed,
    required this.child,
    this.showFocusRing = true,
    this.borderRadius = BorderRadius.zero,
    this.cursor = SystemMouseCursors.click,
    this.disabledCursor = SystemMouseCursors.basic,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.focusNode,
    this.autofocus = false,
    this.onDark = false,
    this.onHoverChanged,
    this.onPressedChanged,
  });

  @override
  State<ItActivatable> createState() => _ItActivatableState();
}

class _ItActivatableState extends State<ItActivatable> {
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final Widget control = GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressedChanged == null || !_enabled
          ? null
          : (_) => widget.onPressedChanged!(true),
      onTapUp: widget.onPressedChanged == null || !_enabled
          ? null
          : (_) => widget.onPressedChanged!(false),
      onTapCancel: widget.onPressedChanged == null || !_enabled
          ? null
          : () => widget.onPressedChanged!(false),
      behavior: widget.hitTestBehavior,
      child: widget.child,
    );

    return FocusableActionDetector(
      enabled: _enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: _enabled ? widget.cursor : widget.disabledCursor,
      onShowFocusHighlight: (value) {
        if (value != _focused && mounted) setState(() => _focused = value);
      },
      onShowHoverHighlight: widget.onHoverChanged,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      // ItFocusRing is mounted unconditionally — swapping the child in and out
      // when focus arrives would remount the subtree, and with it the focus
      // node that made the ring appear in the first place. Unfocused it paints
      // nothing at all, so parity captures are byte-identical.
      child: ItFocusRing(
        visible: widget.showFocusRing && _focused,
        onDark: widget.onDark,
        radius: widget.borderRadius.topLeft.x,
        child: control,
      ),
    );
  }
}
