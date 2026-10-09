import 'package:flutter/widgets.dart';

/// How much of the bottom of the screen the app's bottom navigation covers —
/// so a notification placed at the bottom can sit on top of it, as a SnackBar
/// sits above a BottomNavigationBar.
///
/// An ItNotification is inserted into the root Overlay, far from the page that
/// owns the bar, so it cannot find the bar by looking up the tree. The bar
/// reports here instead: its laid-out height — home-indicator inset included,
/// since the bar paints down to the screen's edge — for as long as its page is
/// the current route. A page pushed over it (a form, which has no bar) makes it
/// withdraw, and bottom notifications go back to the screen's edge.
///
/// Found in a real app: its welcome message covered the tab bar for six
/// seconds, where the SnackBar it replaced had floated above it.
///
/// Internal: not exported.
abstract final class BottomNavClearance {
  /// The tallest report from a bar whose page is current; 0 with none.
  static final ValueNotifier<double> height = ValueNotifier<double>(0);

  static final Map<Object, double> _reports = <Object, double>{};

  static void _report(Object owner, double value) {
    if (_reports[owner] == value) return;
    _reports[owner] = value;
    _recompute();
  }

  static void _withdraw(Object owner) {
    if (_reports.remove(owner) != null) _recompute();
  }

  static void _recompute() {
    height.value = _reports.values.fold<double>(0, (a, b) => a > b ? a : b);
  }
}

/// Reports [child]'s laid-out height to [BottomNavClearance] while its route
/// is the current one.
///
/// Internal: not exported.
class BottomNavClearanceReporter extends StatefulWidget {
  /// Reports [child]'s height.
  const BottomNavClearanceReporter({super.key, required this.child});

  /// The bar whose height is reported.
  final Widget child;

  @override
  State<BottomNavClearanceReporter> createState() =>
      _BottomNavClearanceReporterState();
}

class _BottomNavClearanceReporterState
    extends State<BottomNavClearanceReporter> {
  bool _current = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Called again whenever the route stops or starts being the current one:
    // a page pushed over this one, or popped off it.
    _current = ModalRoute.isCurrentOf(context) ?? true;
    _scheduleReport();
  }

  @override
  void didUpdateWidget(BottomNavClearanceReporter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleReport();
  }

  // After layout: the height is the bar's own, and exists only once laid out.
  void _scheduleReport() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _reportNow());

  void _reportNow() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (!_current || box is! RenderBox || !box.hasSize) {
      BottomNavClearance._withdraw(this);
    } else {
      BottomNavClearance._report(this, box.size.height);
    }
  }

  @override
  void dispose() {
    BottomNavClearance._withdraw(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
