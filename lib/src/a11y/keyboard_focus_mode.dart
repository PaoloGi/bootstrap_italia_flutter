import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Bootstrap Italia's `track-focus.js`, for the one input Flutter's own
/// [FocusManager.highlightMode] leaves out: a mouse.
///
/// The stylesheet paints its focus ring for
/// `:focus:not([data-focus-mouse=true])`, and `track-focus.js` sets that
/// attribute on whatever gains focus while the last input was a `mousedown`
/// rather than a `keydown`. Flutter's highlight mode already turns rings off
/// after a touch, but `FocusManager.handlePointerEvent` ignores mouse and
/// trackpad presses — so on a desktop, a field clicked into drew the keyboard
/// ring design-react-kit never shows.
///
/// This records only what the last press was. Classifying a focus is left to
/// the consumer, once, when that focus arrives — `ItFocusRing` and
/// [KeyboardFocusMode] — because the attribute is set on `focusin` and left
/// alone until `focusout`: typing into a field focused by a click does not
/// later give it a ring.
///
/// Internal: not exported.
abstract final class FocusModality {
  static bool _lastPressWasMouse = false;
  static bool _routeAdded = false;

  /// Whether the most recent press was a mouse or trackpad button rather than
  /// a key or a touch. False until anything is pressed, as `_usingMouse`
  /// starts.
  static bool get lastPressWasMouse => _lastPressWasMouse;

  /// Starts listening. Every consumer calls it when it mounts, so it has to be
  /// repeatable: the pointer route is added once, and the key handler is
  /// re-added each time, because `HardwareKeyboard.clearState` — which the
  /// test binding calls between tests — drops every handler.
  static void ensureListening() {
    if (!_routeAdded) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
      _routeAdded = true;
    }
    HardwareKeyboard.instance
      ..removeHandler(_onKey)
      ..addHandler(_onKey);
  }

  static void _onPointer(PointerEvent event) {
    if (event is! PointerDownEvent) return;
    _lastPressWasMouse = event.kind == PointerDeviceKind.mouse ||
        event.kind == PointerDeviceKind.trackpad;
  }

  static bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent) _lastPressWasMouse = false;
    return false; // Observes only; never consumes the key.
  }
}

/// Keyboard-or-not for a control that owns a text field's [FocusNode], and so
/// has no `FocusableActionDetector.onShowFocusHighlight` to follow — ItInput
/// and ItAutocomplete, whose border colour depends on it as well as the ring.
///
/// [keyboardFocusMode] is the same test `ItFocusRing` applies: the highlight
/// mode is the keyboard one (no touch since), and the focus did not arrive
/// from a mouse press. Call [classifyFocus] from the focus listener when focus
/// is gained.
///
/// Internal: not exported.
mixin KeyboardFocusMode<T extends StatefulWidget> on State<T> {
  bool _traditional =
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
  bool _focusFromMouse = false;

  /// Whether the control's focus shows as keyboard focus.
  bool get keyboardFocusMode => _traditional && !_focusFromMouse;

  /// Classifies focus that has just arrived — once per focus, as
  /// `data-focus-mouse` is set on `focusin` and kept until `focusout`.
  void classifyFocus() => _focusFromMouse = FocusModality.lastPressWasMouse;

  @override
  void initState() {
    super.initState();
    FocusModality.ensureListening();
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightModeChanged);
    super.dispose();
  }

  void _onHighlightModeChanged(FocusHighlightMode mode) {
    final next = mode == FocusHighlightMode.traditional;
    if (next == _traditional || !mounted) return;
    setState(() => _traditional = next);
  }
}
