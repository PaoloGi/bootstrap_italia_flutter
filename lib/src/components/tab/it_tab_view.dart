import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// A Bootstrap Italia tab view that displays the content for the selected tab.
///
/// Use in combination with [ItTabBar] to create a full tabbed interface.
///
/// ```dart
/// Column(
///   children: [
///     ItTabBar(
///       tabs: [ItTabItem(label: 'Tab 1'), ItTabItem(label: 'Tab 2')],
///       selectedIndex: _index,
///       onChanged: (i) => setState(() => _index = i),
///     ),
///     Expanded(
///       child: ItTabView(
///         selectedIndex: _index,
///         children: [Page1(), Page2()],
///       ),
///     ),
///   ],
/// )
/// ```
class ItTabView extends StatelessWidget {
  /// The index of the currently visible child.
  final int selectedIndex;

  /// The content widgets for each tab.
  final List<Widget> children;

  /// Whether to animate transitions between tabs.
  final bool animated;

  /// The animation duration.
  final Duration duration;

  /// Creates a Bootstrap Italia tab view.
  const ItTabView({
    super.key,
    required this.selectedIndex,
    required this.children,
    this.animated = true,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    assert(
      selectedIndex >= 0 && selectedIndex < children.length,
      'selectedIndex ($selectedIndex) must be within children range (0..${children.length - 1})',
    );

    // §1.3.1 / §4.1.2: the visible pane is the `tabpanel` that the selected
    // tab controls. Without the role AT reads it as unrelated content and the
    // tab/panel relationship is lost.
    if (!animated) {
      return Semantics(
        container: true,
        role: SemanticsRole.tabPanel,
        child: children[selectedIndex],
      );
    }

    return Semantics(
      container: true,
      role: SemanticsRole.tabPanel,
      child: AnimatedSwitcher(
        duration: duration,
        child: KeyedSubtree(
          key: ValueKey<int>(selectedIndex),
          child: children[selectedIndex],
        ),
      ),
    );
  }
}
