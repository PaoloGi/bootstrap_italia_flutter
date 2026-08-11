import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';

/// Visual style for [ItTabBar].
enum ItTabStyle {
  /// `.nav-tabs` — underline indicator below the active tab.
  underline,

  /// `.nav-tabs.nav-tabs-cards` — card-style background on the active tab.
  card,

  /// `.nav-pills` — button-style tabs.
  button,
}

/// A single tab item definition.
class ItTabItem {
  /// The tab label text.
  final String label;

  /// Optional icon.
  final IconData? icon;

  /// Whether this tab is disabled.
  final bool disabled;

  /// Creates a tab item.
  const ItTabItem({
    required this.label,
    this.icon,
    this.disabled = false,
  });
}

/// Geometry and colour tokens for the Bootstrap Italia `.nav-tabs`.
///
/// Values come from `bootstrap-italia.min.css`.
abstract final class _TabTokens {
  /// `.nav-tabs .nav-link { font-size: 1.125rem }` at >= 992px.
  static const double fontSize = 18;

  /// `.nav-tabs .nav-link { line-height: 1rem }`
  static const double lineHeight = 16;

  /// `.nav-tabs .nav-link { padding: .778rem 1.333em }` — the horizontal
  /// padding is in `em`, so it scales with [fontSize] (1.333 * 18 = 23.994).
  static const double paddingY = 0.778 * 16;
  static const double paddingX = 1.333 * fontSize;

  /// `.nav-tabs .nav-link { border-bottom: 3px solid transparent }`
  static const double indicatorWidth = 3;

  /// `--bs-border-color: hsl(210, 4%, 78%)`
  static const Color borderColor = Color(0xFFC5C7C9);

  /// `.nav-tabs .nav-link { color: hsl(210, 33%, 28%) }`
  static const Color color = Color(0xFF30475F);

  /// `.nav-tabs .nav-link.disabled { color: hsl(210, 3%, 85%) }`
  static const Color disabledColor = Color(0xFFD8D9DA);

  /// The shared `.icon` size used by the design kit inside tabs.
  static const double iconSize = 32;
}

/// A Bootstrap Italia tab bar (`.nav-tabs`).
///
/// Displays a horizontal row of selectable tabs over a full-width hairline
/// rule, with a 3px indicator under the active tab.
///
/// ```dart
/// ItTabBar(
///   tabs: [
///     ItTabItem(label: 'Tab 1'),
///     ItTabItem(label: 'Tab 2', icon: BootstrapItaliaIcons.it_settings),
///   ],
///   selectedIndex: _currentTab,
///   onChanged: (index) => setState(() => _currentTab = index),
/// )
/// ```
class ItTabBar extends StatefulWidget {
  /// The tab items.
  final List<ItTabItem> tabs;

  /// The currently selected tab index.
  final int selectedIndex;

  /// Called when a tab is selected.
  final ValueChanged<int>? onChanged;

  /// The visual style of the tabs.
  final ItTabStyle style;

  /// Creates a Bootstrap Italia tab bar.
  const ItTabBar({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onChanged,
    this.style = ItTabStyle.underline,
  });

  @override
  State<ItTabBar> createState() => _ItTabBarState();
}

class _ItTabBarState extends State<ItTabBar> {
  final Map<int, FocusNode> _focusNodes = <int, FocusNode>{};

  FocusNode _focusNode(int index) =>
      _focusNodes.putIfAbsent(index, FocusNode.new);

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  /// Moves selection and focus by [delta], skipping disabled tabs and wrapping
  /// at both ends, per the ARIA authoring practices for the tab pattern.
  void _move(int delta) {
    final count = widget.tabs.length;
    if (count == 0) return;
    var next = widget.selectedIndex;
    for (var step = 0; step < count; step++) {
      next = (next + delta) % count;
      if (next < 0) next += count;
      if (!widget.tabs[next].disabled) break;
    }
    if (next == widget.selectedIndex) return;
    widget.onChanged?.call(next);
    _focusNode(next).requestFocus();
  }

  void _moveTo(int index) {
    if (index < 0 || index >= widget.tabs.length) return;
    if (widget.tabs[index].disabled) return;
    widget.onChanged?.call(index);
    _focusNode(index).requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: List.generate(widget.tabs.length, (index) {
        final tab = widget.tabs[index];
        return _TabButton(
          label: tab.label,
          icon: tab.icon,
          isSelected: index == widget.selectedIndex,
          disabled: tab.disabled,
          style: widget.style,
          focusNode: _focusNode(index),
          // Roving tabindex: only the selected tab is in the Tab order, so a
          // keyboard user tabs *into* the tab list once and then uses the
          // arrow keys, instead of tabbing through every tab (ARIA APG).
          inTabOrder: index == widget.selectedIndex,
          onTap: tab.disabled ? null : () => widget.onChanged?.call(index),
        );
      }),
    );

    // §1.3.1 / §4.1.2: the container carries the `tabBar` role so AT announces
    // "tab 2 of 4" instead of four unrelated buttons.
    //
    // CallbackShortcuts must wrap this from the OUTSIDE: it inserts a Focus
    // widget, and a Focus between the tab bar and its tabs produces an
    // intermediate semantics node that trips Flutter's own
    // "Children of TabBar must have the tab role" assertion.
    final semantic = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.tabBar,
      child: row,
    );

    // §2.1.1 Keyboard: the ARIA tab pattern navigates with the arrow keys
    // (plus Home/End), not Tab. Without this a keyboard user can reach a tab
    // but has no idiomatic way to move between them.
    Widget withKeyboard(Widget child) => CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                _move(1),
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                _move(-1),
            const SingleActivator(LogicalKeyboardKey.home): () => _moveTo(0),
            const SingleActivator(LogicalKeyboardKey.end): () =>
                _moveTo(widget.tabs.length - 1),
          },
          child: child,
        );

    if (widget.style != ItTabStyle.underline) {
      return withKeyboard(semantic);
    }

    // `.nav-tabs { background-color: #fff;
    //   border-bottom: 1px solid hsl(210,4%,78%) }` with
    // `.nav-tabs .nav-link { margin-bottom: -1px }`: each tab's 3px indicator
    // overlaps the container rule rather than stacking below it, so the rule
    // is painted behind the row instead of under it.
    return withKeyboard(
      ColoredBox(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(height: 1, color: _TabTokens.borderColor),
            ),
            semantic,
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final bool disabled;
  final ItTabStyle style;
  final FocusNode? focusNode;
  final bool inTabOrder;
  final VoidCallback? onTap;

  const _TabButton({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.disabled,
    required this.style,
    this.focusNode,
    this.inTabOrder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ItHoverBuilder(
      // `.nav-tabs .nav-link.disabled { pointer-events: none }`, and the active
      // tab carries `cursor: inherit` with no hover rule of its own — measured
      // on the React kit, hovering the selected tab changes nothing.
      enabled: !disabled && !isSelected,
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      builder: _build,
    );
  }

  Widget _build(BuildContext context, bool hovered) {
    final colors = resolveColorScheme(context);
    final fgColor = disabled
        ? _TabTokens.disabledColor
        : isSelected
            ? colors.primary
            : hovered
                ? itShade(colors.primary, 0.25)
                : _TabTokens.color;

    final iconColor = disabled
        ? _TabTokens.disabledColor
        : isSelected
            ? colors.primary
            : hovered
                ? itShade(colors.primary, 0.25)
                : colors.secondary;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: _TabTokens.iconSize, color: iconColor),
        Text(
          label,
          style: TextStyle(
            fontFamily: BootstrapItaliaFontFamily.sansSerif,
            package: BootstrapItaliaFontFamily.package,
            fontSize: _TabTokens.fontSize,
            height: _TabTokens.lineHeight / _TabTokens.fontSize,
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
        ),
      ],
    );

    // §4.1.2 Name, Role, Value: `tab` role plus the selected and enabled
    // states. Previously a tab was an unlabelled GestureDetector — AT could
    // not tell it was a tab, nor which one was active.
    return Semantics(
      role: SemanticsRole.tab,
      selected: isSelected,
      enabled: !disabled,
      label: label,
      child: FocusTraversalGroup(
        descendantsAreTraversable: inTabOrder,
        child: ItActivatable(
          onPressed: onTap,
          focusNode: focusNode,
          child: ExcludeSemantics(
            child: Container(
              // A Container (unlike DecoratedBox) reserves layout space for the
              // border, which is what gives `.nav-link` its 3px indicator strip.
              decoration: _decoration(colors),
              padding: const EdgeInsets.symmetric(
                horizontal: _TabTokens.paddingX,
                vertical: _TabTokens.paddingY,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration(BootstrapItaliaColorScheme colors) {
    return switch (style) {
      // `.nav-tabs .nav-link { border-bottom: 3px solid transparent }`
      ItTabStyle.underline => BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  isSelected && !disabled ? colors.primary : Colors.transparent,
              width: _TabTokens.indicatorWidth,
            ),
          ),
        ),
      // `.nav-tabs.nav-tabs-cards .nav-link { border-radius: 4px 4px 0 0 }`
      ItTabStyle.card => BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: isSelected
              ? const Border(
                  top: BorderSide(color: _TabTokens.borderColor),
                  left: BorderSide(color: _TabTokens.borderColor),
                  right: BorderSide(color: _TabTokens.borderColor),
                )
              : const Border(
                  bottom: BorderSide(
                    color: _TabTokens.borderColor,
                    width: 2,
                  ),
                ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      // `.nav-pills .nav-link.active
      //   { background-color: hsl(210,100%,40%) }`
      ItTabStyle.button => BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
    };
  }
}
