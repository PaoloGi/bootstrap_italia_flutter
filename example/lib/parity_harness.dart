// Alternate web entrypoint used ONLY by the visual-parity harness.
//
// Build with:
//   flutter build web -t lib/parity_harness.dart
//
// It renders exactly one component in isolation, selected by query string, so
// Playwright can drive the Flutter side in the same browser it uses for the
// React reference. That makes interaction parity symmetric: one tool, one event
// model, instead of Playwright on one side and a Flutter test driver on the
// other.
//
//   /?key=button_primary&w=400&h=200
//
// The page reports readiness by setting `window.parityReady = true` once the
// first frame is on screen, so the capture script never screenshots a blank
// canvas.
import 'dart:js_interop';

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';

import 'parity_registry.dart';

@JS('window.parityReady')
external set _parityReady(bool value);

@JS('window.parityError')
external set _parityError(String? value);

/// Logical size of the component under test. Flutter web paints into a canvas,
/// so there is no DOM node for Playwright to measure — the app has to report
/// its own bounds. Values are CSS pixels, which is exactly what a Playwright
/// clip expects.
@JS('window.parityWidth')
external set _parityWidth(double value);

@JS('window.parityHeight')
external set _parityHeight(double value);

void main() {
  final params = Uri.base.queryParameters;
  final key = params['key'] ?? '';
  final entry = parityRegistry[key];

  // Flutter Web builds no semantics tree until assistive tech is detected, and
  // exposes an offscreen 1x1 "Enable accessibility" button to trigger it. For an
  // audit we want the tree unconditionally — but only when asked, so the visual
  // parity captures are not taken against a DOM that differs from the default.
  if (params['a11y'] == '1') {
    WidgetsFlutterBinding.ensureInitialized();
    SemanticsBinding.instance.ensureSemantics();
  }

  if (entry == null) {
    _parityError = 'unknown key: "$key". '
        'Known keys: ${parityRegistry.keys.join(', ')}';
  }

  // `cw` constrains the COMPONENT's width without changing the viewport. That
  // separates the two things "responsive" can mean: CSS media queries switch on
  // viewport width, while a Flutter LayoutBuilder switches on the width its
  // parent actually gives it. They agree only when a component is full-bleed,
  // so this is how we tell which rule a component is really following.
  final constrainWidth = double.tryParse(params['cw'] ?? '');

  runApp(
      _ParityApp(entry: entry, keyName: key, constrainWidth: constrainWidth));
}

class _ParityApp extends StatelessWidget {
  const _ParityApp({
    required this.entry,
    required this.keyName,
    this.constrainWidth,
  });

  final ParityEntry? entry;
  final String keyName;
  final double? constrainWidth;

  @override
  Widget build(BuildContext context) {
    final theme = BootstrapItaliaThemeData.standard();
    final child = entry;

    return BootstrapItaliaTheme(
      data: theme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.toThemeData(),
        home: _ReadySignal(
          child: Material(
            color: Colors.white,
            child: child == null
                ? Center(child: Text('unknown parity key: $keyName'))
                : Align(
                    // Top-left, not centred: the capture script measures the
                    // component from a known origin rather than hunting for it.
                    alignment: Alignment.topLeft,
                    child: _Measured(
                      child: constrainWidth == null
                          ? _Isolate(entry: child)
                          : SizedBox(
                              width: constrainWidth,
                              child: _Isolate(entry: child),
                            ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Applies the entry's own width constraint, if it declares one.
class _Isolate extends StatelessWidget {
  const _Isolate({required this.entry});

  final ParityEntry entry;

  @override
  Widget build(BuildContext context) {
    final built = entry.build(context);
    return entry.width == null
        ? built
        : SizedBox(width: entry.width, child: built);
  }
}

/// Publishes the measured size of its child to JS every frame.
///
/// Reported continuously rather than once, because interaction changes it: an
/// accordion that expands, or a field whose label floats on focus, resizes the
/// component after the initial frame.
class _Measured extends StatefulWidget {
  const _Measured({required this.child});

  final Widget child;

  @override
  State<_Measured> createState() => _MeasuredState();
}

class _MeasuredState extends State<_Measured> {
  final GlobalKey _key = GlobalKey();

  void _publish(Duration _) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      _parityWidth = box.size.width;
      _parityHeight = box.size.height;
    }
    SchedulerBinding.instance.addPostFrameCallback(_publish);
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(_publish);
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _key, child: widget.child);
}

/// Flips `window.parityReady` after the first rendered frame.
class _ReadySignal extends StatefulWidget {
  const _ReadySignal({required this.child});

  final Widget child;

  @override
  State<_ReadySignal> createState() => _ReadySignalState();
}

class _ReadySignalState extends State<_ReadySignal> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // A second frame guards against fonts/icons that only resolve after the
      // initial layout pass.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _parityReady = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
