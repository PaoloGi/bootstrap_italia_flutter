import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../tokens/colors.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';

/// Visual style for [ItTabBar].
enum ItTabStyle {
  /// `.nav-tabs` — underline indicator along the active tab's edge.
  underline,

  /// `.nav-tabs.nav-tabs-cards` — card-style background on the active tab.
  card,

  /// `.nav-pills` — button-style tabs.
  button,
}

/// Where the bar sits relative to the panel it drives.
///
/// The kit does not reorder the markup for any of these: the tab list always
/// comes first in the DOM and the *layout* is flipped with a flex utility, so
/// the reading and focus order stay the same however the bar is placed. That is
/// the point of the docs' «Posizione dei Tab» section, and the reason this is a
/// parameter on the bar rather than something a caller achieves by moving the
/// widget below its panel.
enum ItTabPlacement {
  /// `.nav-tabs` — a horizontal bar above the panel. The default.
  top,

  /// `.d-flex.flex-column-reverse > .nav-tabs` — a horizontal bar below the
  /// panel, with the container rule and the indicator on the top edge.
  bottom,

  /// `.nav-tabs.nav-tabs-vertical` — a vertical bar to the left of the panel.
  start,

  /// `.row.flex-row-reverse > .nav-tabs.nav-tabs-vertical` — a vertical bar to
  /// the right of the panel.
  end,
}

/// How a tab draws its icon and its label.
///
/// These are container-level classes in the kit (`.nav-tabs-icon-lg`,
/// `.nav-tabs-icon-text`), not per-item ones, so they belong on the bar: every
/// tab in a bar is laid out the same way.
enum ItTabLayout {
  /// `.nav-tabs` with no icon modifier.
  ///
  /// The label is drawn, and so is [ItTabItem.icon] when one is given — flush
  /// against the label, with no gap. This is what the design kit renders for
  /// icon-plus-text markup that does *not* carry `.nav-tabs-icon-text`.
  standard,

  /// A 32px `.icon` alone, with the label as `.visually-hidden`.
  ///
  /// The label is not optional here — it is the tab's accessible name and the
  /// only thing a screen reader has to go on, which is exactly why the kit
  /// spells it out in a `<span class="visually-hidden">` rather than leaving
  /// the icon to speak for itself.
  iconOnly,

  /// `.nav-tabs-icon-lg` — a 48px `.icon.icon-lg` alone, with the label as
  /// `.visually-hidden` and `padding: .778rem 1.778em`.
  iconOnlyLarge,

  /// `.nav-tabs-icon-text` — a 32px `.icon`, `.5rem` of space, then the label.
  iconAndText,
}

/// A single tab item definition.
class ItTabItem {
  /// The tab label text.
  ///
  /// Always required, including for the icon-only layouts: there it stops being
  /// visible and becomes the tab's accessible name, which is the one thing that
  /// cannot be omitted (§4.1.2).
  final String label;

  /// Optional icon.
  final IconData? icon;

  /// Whether this tab is disabled.
  final bool disabled;

  /// Removes this tab — `.nav-tabs-editable .nav-link-close`.
  ///
  /// Non-null renders a close control inside the tab. The kit puts it in the
  /// same `<li>` as the tab, absolutely positioned over the padding the tab
  /// reserves for it.
  final VoidCallback? onClose;

  /// The accessible name of the close control.
  ///
  /// Required whenever [onClose] is set, and deliberately not defaulted to a
  /// generic «Chiudi»: an editable bar has one close button per tab, and five
  /// buttons all called «Chiudi» are indistinguishable in a screen reader's
  /// element list. The kit's own markup names each one — `Chiudi tab 1`,
  /// `Chiudi tab 2` — for the same reason.
  final String? closeLabel;

  /// Creates a tab item.
  const ItTabItem({
    required this.label,
    this.icon,
    this.disabled = false,
    this.onClose,
    this.closeLabel,
  }) : assert(
          onClose == null || closeLabel != null,
          'A closable tab needs a closeLabel.\n'
          'The close control paints a glyph and nothing else, so without a name '
          'AT announces a bare "button" (WCAG 4.1.2). Name it after the tab it '
          'closes — «Chiudi la scheda Anagrafe» — rather than «Chiudi», so '
          'that a bar of five of them is not five identical entries in a '
          'screen reader element list.',
        );
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

  /// `.nav-tabs.nav-tabs-icon-lg .nav-link { padding: .778rem 1.778em }` —
  /// the large-icon layout buys its icons room by widening the tab.
  static const double paddingXLarge = 1.778 * fontSize;

  /// `.nav-tabs .nav-link { border-bottom: 3px solid transparent }`
  static const double indicatorWidth = 3;

  /// The indicator every other placement uses:
  /// `.flex-column-reverse .nav-tabs .nav-link { border-top: 2px solid … }`,
  /// `.nav-tabs-vertical .nav-link { border-right: 2px solid … }`,
  /// `.nav-dark .nav-link.active { border-bottom: 2px solid … }`.
  static const double indicatorWidthThin = 2;

  /// `--bs-border-color: hsl(210, 4%, 78%)`
  static const Color borderColor = Color(0xFFC5C7C9);

  /// `.nav-tabs .nav-link { color: hsl(210, 33%, 28%) }`
  static const Color color = Color(0xFF30475F);

  /// `.nav-tabs .nav-link.disabled { color: hsl(210, 3%, 85%) }`
  static const Color disabledColor = Color(0xFFD8D9DA);

  /// `.icon { width: 32px; height: 32px }` — the shared SVG sprite size, which
  /// is what the docs' tab examples embed.
  static const double iconSize = 32;

  /// `.icon.icon-lg { width: 48px; height: 48px }`
  static const double iconSizeLarge = 48;

  /// `.nav-tabs.nav-tabs-icon-text .icon { margin-right: .5rem }`
  static const double iconTextGap = 8;

  /// `.flex-row-reverse .nav-tabs.nav-tabs-vertical .nav-link .icon
  /// { margin-right: .889rem }` — a vertical bar on the right puts its icon
  /// first, so it needs a gap the left-hand one does not.
  static const double verticalIconGap = 0.889 * 16;

  // ── `.nav-dark` ─────────────────────────────────────────────────────────
  //
  // None of these four is a palette token. `--bs-cyan` is the closest thing to
  // one and it is not in `BootstrapItaliaColorScheme`, so a retinted
  // administration keeps this bar exactly as the kit draws it — which is the
  // honest outcome: `.nav-dark` is a fixed dark chrome, not a themed surface.

  /// `.nav-tabs.nav-dark { background-color: rgb(69.021615, 90.9933075,
  /// 112.965) }` — a `neutral-1` step, not `--bs-dark`.
  static const Color darkBackground = Color(0xFF455B71);

  /// `.nav-tabs.nav-dark .nav-link { color: rgb(217.107, 218.2035, 219.3) }`,
  /// declared elsewhere as `.neutral-1-color-a2`.
  static const Color darkColor = Color(0xFFD9DADB);

  /// `.nav-tabs.nav-dark .nav-link.active { color: rgb(0, 255, 246.5) }` —
  /// `--bs-cyan`, `hsl(178, 100%, 50%)`. The blue channel is exactly 246.5, so
  /// the byte is a rounding decision; a browser rounds it up.
  ///
  /// This now agrees with `BootstrapItaliaColors.cyan`. It did not: the token
  /// said `0xFF00FFFA`, 3.5/255 off what `hsl(178, 100%, 50%)` computes to,
  /// which is why this file carried its own literal. The token was corrected
  /// rather than worked around — a token that disagrees with the stylesheet is
  /// wrong for every future use of it, not only this one.
  static const Color darkActiveColor = BootstrapItaliaColors.cyan;

  /// `.nav-tabs.nav-dark .nav-link.disabled { color: rgb(118.32, 133.11,
  /// 147.9) }`, declared elsewhere as `.neutral-1-color-a6`.
  static const Color darkDisabledColor = Color(0xFF768594);

  /// `.nav-tabs-vertical.nav-tabs-vertical-background .nav-link.active
  /// { background-color: hsl(210, 62%, 97%) }` — declared as
  /// `.lightgrey-bg-a3` / `.lightgrey-bg-b1`, a near-white tint rather than any
  /// semantic colour, so it does not follow a retinted palette.
  static const Color verticalActiveBackground = Color(0xFFF3F7FC);

  // ── `.nav-tabs-editable` ────────────────────────────────────────────────

  /// `.nav-tabs.nav-tabs-editable .nav-link { padding-right: 2.888em }` — room
  /// for the absolutely positioned close control.
  static const double editablePaddingRight = 2.888 * fontSize;

  /// `.nav-tabs.nav-tabs-editable .nav-link-close { right: .889rem }`
  static const double closeInset = 0.889 * 16;

  /// `.nav-tabs.nav-tabs-editable .nav-tab-add
  /// { width: 1.444rem; height: 1.444rem; border-radius: 50% }`
  static const double addSize = 1.444 * 16;

  /// `.nav-tab-add:after { height: .778rem; width: 2px }` and `:before`
  /// mirrored — the `+` is drawn from two bars, not set as a glyph.
  static const double addBarLength = 0.778 * 16;
  static const double addBarThickness = 2;

  /// `.nav-tabs.nav-tabs-editable .nav-tab-add { margin: -0.2em 1em 0 }`, where
  /// `em` is the inherited 1rem — `.nav-tab-add` is not a `.nav-link`, so it
  /// never picks up the 1.125rem font size.
  static const double addMarginX = 16;
}

/// A Bootstrap Italia tab bar (`.nav-tabs`).
///
/// Displays a row (or column) of selectable tabs over a hairline rule, with an
/// indicator along the active tab's edge.
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

  /// Where the bar sits relative to its panel.
  final ItTabPlacement placement;

  /// How each tab draws its icon and label.
  final ItTabLayout layout;

  /// `.nav-tabs.auto` — every tab takes an equal share of the width.
  ///
  /// `.nav-tabs.auto .nav-item { flex: 1 }`. Without it the kit sizes each tab
  /// to its content and lets the bar scroll, which is what this widget does by
  /// default.
  final bool fullWidth;

  /// `.nav-dark` — a dark bar with light labels and a cyan indicator.
  final bool dark;

  /// `.nav-tabs-vertical-background` — fills the active tab of a vertical bar.
  ///
  /// Ignored unless [placement] is vertical, and asserted against so that a
  /// caller who sets it on a horizontal bar finds out rather than wondering why
  /// nothing changed.
  final bool verticalBackground;

  /// The `Semantics.identifier` of the panel these tabs drive.
  ///
  /// §1.3.1: this is `aria-controls`. The kit's markup pairs every `role="tab"`
  /// with the `id` of its `role="tabpanel"`, and modern screen readers use that
  /// pairing to jump from a tab straight to its content. Pass the same string
  /// to [ItTabView.identifier].
  final String? panelId;

  /// `.nav-tabs-editable .nav-tab-add` — adds a tab.
  ///
  /// Rendered after the last tab, and deliberately *outside* the `tablist`: it
  /// is a button that creates a tab, not a tab.
  final VoidCallback? onAddTab;

  /// The accessible name of [onAddTab]'s control.
  ///
  /// The kit's own markup is `<a class="nav-tab-add"><span
  /// class="visually-hidden">Aggiungi un tab</span></a>`: a bare `+` drawn from
  /// two rectangles has nothing for AT to read.
  final String? addTabLabel;

  /// Creates a Bootstrap Italia tab bar.
  const ItTabBar({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onChanged,
    this.style = ItTabStyle.underline,
    this.placement = ItTabPlacement.top,
    this.layout = ItTabLayout.standard,
    this.fullWidth = false,
    this.dark = false,
    this.verticalBackground = false,
    this.panelId,
    this.onAddTab,
    this.addTabLabel,
  }) : assert(
          onAddTab == null || addTabLabel != null,
          'ItTabBar.onAddTab needs an addTabLabel.\n'
          'The add control is a `+` drawn from two rectangles — there is no '
          'text in it at all, so without a name it is announced as an unlabelled '
          'button (WCAG 4.1.2).',
        );

  /// Whether [placement] lays the tabs out in a column.
  bool get _isVertical =>
      placement == ItTabPlacement.start || placement == ItTabPlacement.end;

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
    // In build rather than the constructor: `tabs.isNotEmpty` is not a
    // potentially-constant expression, so asserting it in a `const` constructor
    // would strip `const` from every call site to buy one check.
    assert(
      widget.tabs.isNotEmpty,
      'ItTabBar needs at least one tab.\n'
      'An empty bar still renders its container and still claims the `tablist` '
      'role, so AT announces a tab list with nothing in it (WCAG 4.1.2). Build '
      'the bar once you have tabs, or render nothing.',
    );
    assert(
      widget.selectedIndex >= 0 && widget.selectedIndex < widget.tabs.length,
      'ItTabBar.selectedIndex (${widget.selectedIndex}) must be within the '
      'tabs range (0..${widget.tabs.length - 1}).\n'
      'ItTabView already asserts this for the panes; the bar that drives it did '
      'not, so an out-of-range index surfaced as a RangeError from inside the '
      'framework, naming neither widget.',
    );
    assert(
      !widget.tabs.every((t) => t.disabled),
      'Every tab in this ItTabBar is disabled.\n'
      'Traversal skips disabled tabs, so the bar is reachable by no route at '
      'all and the arrow keys have nowhere to go (WCAG 2.1.1). If the whole '
      'section is unavailable, do not render the tab bar.',
    );
    assert(
      !_iconOnly || widget.tabs.every((t) => t.icon != null),
      'ItTabBar.layout is ${widget.layout}, but a tab has no icon.\n'
      'The icon-only layouts hide the label, so a tab without an icon draws '
      'nothing at all — an empty target the pointer can hit and the eye cannot '
      'find. Give every tab an icon, or use ItTabLayout.standard.',
    );
    assert(
      !widget.verticalBackground || widget._isVertical,
      'ItTabBar.verticalBackground has no effect on a horizontal bar.\n'
      '`.nav-tabs-vertical-background` is defined only under '
      '`.nav-tabs-vertical`, so setting it here changes nothing. Use '
      'ItTabPlacement.start or .end, or drop the flag.',
    );

    final tabs = List.generate(widget.tabs.length, (index) {
      final tab = widget.tabs[index];
      return _TabButton(
        item: tab,
        isSelected: index == widget.selectedIndex,
        style: widget.style,
        placement: widget.placement,
        layout: widget.layout,
        dark: widget.dark,
        verticalBackground: widget.verticalBackground,
        panelId: widget.panelId,
        focusNode: _focusNode(index),
        // Roving tabindex: only the selected tab is in the Tab order, so a
        // keyboard user tabs *into* the tab list once and then uses the
        // arrow keys, instead of tabbing through every tab (ARIA APG).
        inTabOrder: index == widget.selectedIndex,
        onTap: tab.disabled ? null : () => widget.onChanged?.call(index),
      );
    });

    final Widget bar = widget._isVertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: tabs,
          )
        // `.nav-tabs { display: flex }` with the default `align-items:
        // stretch`. Not stated here: a stretched Row needs a bounded height,
        // and this one sits inside a horizontal scroll view whose own parent
        // may leave the height unbounded. Every tab is made the same height
        // instead — see `_padding`, where the placements whose indicator is
        // thinner than the 3px the base rule reserves give the difference back
        // as padding, exactly as `align-items: stretch` would.
        : widget.fullWidth
            // `.nav-tabs.auto .nav-item { flex: 1 }` — equal shares. Unlike
            // the scrolling bar this one is not inside a scroll view, so it
            // can state `align-items: stretch` for real: a label that wraps
            // onto two lines ("Attivo") makes its tab taller than its
            // neighbours, and without the stretch their indicators stopped
            // short of the bar's rule.
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (final tab in tabs) Expanded(child: tab)],
                ),
              )
            : Row(mainAxisSize: MainAxisSize.min, children: tabs);

    // §1.3.1 / §4.1.2: the container carries the `tabBar` role so AT announces
    // "tab 2 of 4" instead of four unrelated buttons.
    //
    // CallbackShortcuts must wrap this from the OUTSIDE: it inserts a Focus
    // widget, and a Focus between the tab bar and its tabs produces an
    // intermediate semantics node that trips Flutter's own
    // "Children of TabBar must have the tab role" assertion. The same rule is
    // why the add control below is a sibling of this node, not a child: it is a
    // button, and a `tablist` may contain nothing but tabs.
    Widget content = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.tabBar,
      child: bar,
    );

    if (widget.onAddTab != null) {
      // `.nav-tabs-editable` closes the list with one more `<li>` holding the
      // add control. It travels with the tabs — inside the scroller, beside
      // the last one — but outside the `tablist` node, because a tab list may
      // contain nothing but tabs and this is a button that makes them.
      final add = _AddTabButton(
        onPressed: widget.onAddTab!,
        label: widget.addTabLabel!,
        dark: widget.dark,
      );
      content = widget._isVertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content, add],
            )
          : Row(
              mainAxisSize:
                  widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (widget.fullWidth) Expanded(child: content) else content,
                add,
              ],
            );
    }

    if (!widget._isVertical && !widget.fullWidth) {
      // `.nav-tabs { overflow-x: auto; flex-wrap: nowrap }` with
      // `white-space: nowrap` on each link: a bar wider than its container
      // scrolls rather than truncating. Without this a Row of tabs that does
      // not fit throws a RenderFlex overflow and paints the debug stripes.
      //
      // The kit swaps this for `flex-wrap: wrap` at >= 1200px, so a wide bar
      // wraps onto a second line rather than scrolling. That is not reproduced:
      // which width the swap should read — the viewport's or the bar's — is the
      // open container-vs-viewport question, and scrolling is correct at every
      // width the harness captures.
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }

    content = _decorated(context, content);

    // §2.1.1 Keyboard: the ARIA tab pattern navigates with the arrow keys
    // (plus Home/End), not Tab — and along the bar's own axis, which is why a
    // vertical bar answers Up/Down rather than Left/Right. The kit marks that
    // axis on the markup as `aria-orientation="vertical"`.
    final forward = widget._isVertical
        ? LogicalKeyboardKey.arrowDown
        : LogicalKeyboardKey.arrowRight;
    final backward = widget._isVertical
        ? LogicalKeyboardKey.arrowUp
        : LogicalKeyboardKey.arrowLeft;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        SingleActivator(forward): () => _move(1),
        SingleActivator(backward): () => _move(-1),
        const SingleActivator(LogicalKeyboardKey.home): () => _moveTo(0),
        const SingleActivator(LogicalKeyboardKey.end): () =>
            _moveTo(widget.tabs.length - 1),
      },
      child: content,
    );
  }

  bool get _iconOnly =>
      widget.layout == ItTabLayout.iconOnly ||
      widget.layout == ItTabLayout.iconOnlyLarge;

  /// The bar's own background and hairline rule.
  ///
  /// The rule is painted *behind* the tabs rather than under them:
  /// `.nav-tabs .nav-link { margin-bottom: calc(-1 * 1px) }` pulls each tab a
  /// pixel over the container's border so the indicator overlaps it instead of
  /// stacking below it.
  Widget _decorated(BuildContext context, Widget bar) {
    // `.nav-pills` has no background and no rule of its own — the fill it
    // carries belongs to the active pill.
    if (widget.style == ItTabStyle.button) return bar;

    // `.nav-tabs { background-color: #fff }`, replaced wholesale by
    // `.nav-tabs.nav-dark { background-color: rgb(69,91,113) }`.
    final background = widget.dark
        ? _TabTokens.darkBackground
        : resolveColorScheme(context).white;

    // Which edge carries `1px solid hsl(210,4%,78%)`:
    //   top      `.nav-tabs { border-bottom }`
    //   bottom   `.flex-column-reverse .nav-tabs { border-top }`
    //   start    `.nav-tabs-vertical { border-right }`
    //   end      `.flex-row-reverse .nav-tabs-vertical { border-left }`
    //
    // `.nav-dark` sets `border-bottom: none` and draws nothing in its place.
    //
    // `.nav-tabs-cards` also sets `border-bottom: none`, but only because it
    // rebuilds the same run out of pieces: every inactive card carries
    // `border-bottom: 2px solid hsl(210,4%,78%)` of its own, and
    // `.nav-tabs-cards::after { flex-grow: 1; border-bottom: 1px solid … }`
    // fills the gap past the last one. Drawing the single rule behind the row
    // reaches the identical pixels — the active card's own fill covers the
    // stretch beneath it, which is exactly the join the kit is making — and
    // avoids a flexible filler that would fight the scroll view for width.
    final hasRule = !widget.dark;

    return ColoredBox(
      color: background,
      child: Stack(
        children: [
          if (hasRule) _rule,
          bar,
        ],
      ),
    );
  }

  /// The container's hairline, positioned on the edge [ItTabBar.placement]
  /// puts it.
  Widget get _rule {
    const line = ColoredBox(color: _TabTokens.borderColor);
    return switch (widget.placement) {
      ItTabPlacement.top =>
        const Positioned(left: 0, right: 0, bottom: 0, height: 1, child: line),
      ItTabPlacement.bottom =>
        const Positioned(left: 0, right: 0, top: 0, height: 1, child: line),
      ItTabPlacement.start =>
        const Positioned(top: 0, bottom: 0, right: 0, width: 1, child: line),
      ItTabPlacement.end =>
        const Positioned(top: 0, bottom: 0, left: 0, width: 1, child: line),
    };
  }
}

class _TabButton extends StatelessWidget {
  final ItTabItem item;
  final bool isSelected;
  final ItTabStyle style;
  final ItTabPlacement placement;
  final ItTabLayout layout;
  final bool dark;
  final bool verticalBackground;
  final String? panelId;
  final FocusNode? focusNode;
  final bool inTabOrder;
  final VoidCallback? onTap;

  const _TabButton({
    required this.item,
    required this.isSelected,
    required this.style,
    required this.placement,
    required this.layout,
    required this.dark,
    required this.verticalBackground,
    required this.panelId,
    this.focusNode,
    this.inTabOrder = true,
    this.onTap,
  });

  bool get _isVertical =>
      placement == ItTabPlacement.start || placement == ItTabPlacement.end;

  bool get _iconOnly =>
      layout == ItTabLayout.iconOnly || layout == ItTabLayout.iconOnlyLarge;

  @override
  Widget build(BuildContext context) {
    return ItHoverBuilder(
      // `.nav-tabs .nav-link.disabled { pointer-events: none }`, and the active
      // tab carries `cursor: inherit` with no hover rule of its own — measured
      // on the React kit, hovering the selected tab changes nothing.
      enabled: !item.disabled && !isSelected,
      cursor:
          item.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      builder: _build,
    );
  }

  Widget _build(BuildContext context, bool hovered) {
    final colors = resolveColorScheme(context);

    // `.nav-dark` replaces the whole ramp: resting, hover, active and disabled
    // all come from the dark block rather than from the light one recoloured.
    final Color fgColor;
    final Color iconColor;
    if (dark) {
      final resting = item.disabled
          ? _TabTokens.darkDisabledColor
          : isSelected || hovered
              // `.nav-dark .nav-link:hover` and `.active` are the same cyan.
              ? _TabTokens.darkActiveColor
              : _TabTokens.darkColor;
      fgColor = resting;
      // `.nav-dark .nav-link .icon { fill: … }` tracks the label exactly.
      iconColor = resting;
    } else {
      fgColor = item.disabled
          ? _TabTokens.disabledColor
          : isSelected
              ? colors.primary
              : hovered
                  ? itShade(colors.primary, 0.25)
                  : _TabTokens.color;

      iconColor = item.disabled
          // `.nav-tabs .nav-link.disabled .icon { fill: hsl(210,3%,85%) }`
          ? _TabTokens.disabledColor
          : isSelected
              // `.nav-tabs .nav-link.active .icon { fill: #06c }`
              ? colors.primary
              : hovered
                  ? itShade(colors.primary, 0.25)
                  // `.nav-tabs .nav-link .icon { fill: hsl(210,17%,44%) }`
                  : colors.secondary;
    }

    // §4.1.2 Name, Role, Value: `tab` role plus the selected and enabled
    // states. Previously a tab was an unlabelled GestureDetector — AT could
    // not tell it was a tab, nor which one was active. The label is stated here
    // rather than left to the painted text, which is also what makes the
    // icon-only layouts (`<span class="visually-hidden">` in the kit) work.
    return Semantics(
      role: SemanticsRole.tab,
      selected: isSelected,
      enabled: !item.disabled,
      label: item.label,
      // Stated on the tab's own node rather than left to the gesture detector
      // below it. With a close control present the tab has two operable
      // descendants, so their configurations stop merging upward and the tab
      // node is left with no tap action — which Flutter asserts against
      // ("A tab must have a tap action") and which would leave AT unable to
      // activate the tab at all.
      onTap: item.disabled ? null : onTap,
      // §1.3.1: `aria-controls`, tying the tab to the panel it reveals.
      controlsNodes: panelId == null ? null : <String>{panelId!},
      child: FocusTraversalGroup(
        descendantsAreTraversable: inTabOrder,
        child: _maybeStack(
          context,
          // The whole activatable is excluded, not just the painted box
          // inside it. ItActivatable publishes its own focusable, tappable
          // node, and the tab above already carries the role, the name, the
          // selected state and the tap action — so the tab ended up
          // containing a second interactive node with no name at all.
          //
          // A real browser is what showed it: axe reported `nested-interactive`
          // and `aria-command-name` against `role="tab"` on the Flutter Web
          // build, and the semantics tree confirmed
          // `role=tab label="Prima"` → `role=none label="" focusable tap=true`.
          //
          // Focus traversal is unaffected — it does not run through the
          // semantics tree — and the close control, when present, is a sibling
          // in the stack rather than a descendant here, so it keeps its own
          // node.
          ExcludeSemantics(
            child: ItActivatable(
              onPressed: onTap,
              focusNode: focusNode,
              onDark: dark,
              child: Container(
                // A Container (unlike DecoratedBox) reserves layout space for
                // the border, which is what gives `.nav-link` its indicator.
                decoration: _decoration(colors),
                padding: _padding,
                child: _content(fgColor, iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Overlays the close control on the tab, or returns the tab untouched.
  ///
  /// A [Stack] unconditionally would be the tidier code and the wrong layout:
  /// `StackFit.passthrough` is what forwards a tight width down to a tab inside
  /// `.auto`, and a tab that does not need the overlay should not be paying for
  /// an extra render object to find that out.
  Widget _maybeStack(BuildContext context, Widget tab) {
    if (item.onClose == null) return tab;
    return Stack(
      // `.nav-tabs-editable .nav-item { position: relative }`
      fit: StackFit.passthrough,
      children: [
        tab,
        // `.nav-link-close { position: absolute; right: .889rem;
        //   top: calc(50% - .9rem) }`. Centred rather than offset by the
        // literal `50% - .9rem`: against the 32px `.icon` the kit embeds, that
        // expression lands 1.6px below centre, which reads as a misalignment
        // rather than as a deliberate one.
        Positioned.directional(
          textDirection: Directionality.of(context),
          end: _TabTokens.closeInset,
          top: 0,
          bottom: 0,
          child: Center(
            child: _CloseTabButton(
              label: item.closeLabel!,
              onPressed: item.disabled ? null : item.onClose,
              isSelected: isSelected,
              disabled: item.disabled,
              dark: dark,
            ),
          ),
        ),
      ],
    );
  }

  /// `.nav-tabs .nav-link { padding: .778rem 1.333em }`, widened by
  /// `.nav-tabs-icon-lg` and by the room `.nav-tabs-editable` reserves for the
  /// close control.
  EdgeInsetsGeometry get _padding {
    final horizontal = layout == ItTabLayout.iconOnlyLarge
        ? _TabTokens.paddingXLarge
        : _TabTokens.paddingX;
    // Every tab in a bar must come out the same height: the kit gets that from
    // `align-items: stretch`, which a Row cannot use here (it would need a
    // bounded height, and the horizontal scroller may not have one). So each
    // variant whose border is thinner than the tallest one's gives the
    // difference back as padding.
    //
    //  * `.nav-dark .nav-link.active { border-bottom: 2px }` against the base
    //    rule's 3px.
    //  * `.nav-tabs-cards .nav-link.active { border: 1px; border-bottom-color:
    //    transparent }` — 1px top and a transparent 1px bottom — against an
    //    inactive card's 2px bottom rule.
    final double bottomMakeUp;
    if (style == ItTabStyle.card) {
      bottomMakeUp = isSelected ? 1 : 0;
    } else if (dark && placement == ItTabPlacement.top) {
      bottomMakeUp = _TabTokens.indicatorWidth - _TabTokens.indicatorWidthThin;
    } else {
      bottomMakeUp = 0;
    }
    // An icon-only horizontal tab carries its horizontal padding as flexible
    // spacers in `_content` instead, so it can yield when the bar is narrow.
    final spacers = _iconOnly && !_isVertical && item.onClose == null;
    return EdgeInsetsDirectional.fromSTEB(
      spacers ? 0 : horizontal,
      _TabTokens.paddingY,
      // `.nav-tabs-editable .nav-link { padding-right: 2.888em }`
      item.onClose != null
          ? _TabTokens.editablePaddingRight
          : spacers
              ? 0
              : horizontal,
      _TabTokens.paddingY + bottomMakeUp,
    );
  }

  /// The icon and the label, in the order and spacing the layout asks for.
  Widget _content(Color fgColor, Color iconColor) {
    final iconSize = layout == ItTabLayout.iconOnlyLarge
        ? _TabTokens.iconSizeLarge
        : _TabTokens.iconSize;
    final icon = item.icon == null
        ? null
        : Icon(item.icon, size: iconSize, color: iconColor);

    final label = Text(
      item.label,
      style: TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        // `.nav-tabs .nav-link { font-size: 1.125rem; font-weight: 600;
        //   line-height: 1rem }`
        fontSize: _TabTokens.fontSize,
        height: _TabTokens.lineHeight / _TabTokens.fontSize,
        fontWeight: FontWeight.w600,
        color: fgColor,
      ),
    );

    if (_isVertical) {
      // `.nav-tabs-vertical .nav-link { justify-content: space-between;
      //   white-space: normal }` — the label sits at the leading edge and the
      // icon at the trailing one, and a long label wraps instead of scrolling.
      if (placement == ItTabPlacement.start) {
        if (_iconOnly) {
          // `.nav-tabs-vertical .nav-link.justify-content-end` — the docs'
          // icon-only vertical bar pins its glyphs to the trailing edge.
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [icon!],
          );
        }
        return Row(
          children: [
            Expanded(child: label),
            if (icon != null) icon,
          ],
        );
      }
      // `.flex-row-reverse .nav-tabs-vertical .nav-link
      //   { justify-content: flex-start }` with
      // `.nav-link .icon { margin-right: .889rem }` — a bar on the right leads
      // with the icon instead of trailing it.
      if (_iconOnly) {
        return Row(children: [icon!]);
      }
      return Row(
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: _TabTokens.verticalIconGap),
          ],
          Expanded(child: label),
        ],
      );
    }

    // `.nav-tabs .nav-link { display: flex; align-items: center;
    //   justify-content: center }`
    if (_iconOnly) {
      // In the kit a flex item never shrinks below its content, so tabs that
      // do not fit overflow and scroll. There is no scroller under a fullWidth
      // bar, and four 48px icons with 1.778em of padding either side need more
      // than a phone offers — the Row painted overflow stripes. The padding is
      // the only part that can give, so it is a pair of spacers that yield
      // down to the icon's own width and no further.
      final pad = layout == ItTabLayout.iconOnlyLarge
          ? _TabTokens.paddingXLarge
          : _TabTokens.paddingX;
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: SizedBox(width: pad)),
          icon!,
          Flexible(child: SizedBox(width: pad)),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon,
          // `.nav-tabs-icon-text .icon { margin-right: .5rem }`. Only that
          // container class buys the gap: plain `.nav-tabs` markup with an icon
          // and a label sets them flush, which is what the design kit renders.
          if (layout == ItTabLayout.iconAndText)
            const SizedBox(width: _TabTokens.iconTextGap),
        ],
        Flexible(child: label),
      ],
    );
  }

  BoxDecoration _decoration(BootstrapItaliaColorScheme colors) {
    // `.nav-dark .nav-link.active { border-bottom-color: rgb(0,255,246.5) }`,
    // and on a vertical dark bar `border-right-color` / `border-left-color`.
    final indicator = dark ? _TabTokens.darkActiveColor : colors.primary;
    final active = isSelected && !item.disabled;
    final visible = active ? indicator : const Color(0x00000000);

    switch (style) {
      case ItTabStyle.underline:
        // Which edge carries the indicator, and how thick it is:
        //   top      `border-bottom: 3px` (2px under `.nav-dark`)
        //   bottom   `.flex-column-reverse … { border-top: 2px }`
        //   start    `.nav-tabs-vertical … { border-right: 2px }`
        //   end      `.flex-row-reverse … { border-left: 2px }`
        final side = BorderSide(
          color: visible,
          width: placement == ItTabPlacement.top && !dark
              ? _TabTokens.indicatorWidth
              : _TabTokens.indicatorWidthThin,
        );
        return BoxDecoration(
          // `.nav-tabs-vertical-background .nav-link.active
          //   { background-color: hsl(210,62%,97%) }`
          color: verticalBackground && active
              ? _TabTokens.verticalActiveBackground
              : null,
          border: switch (placement) {
            ItTabPlacement.top => Border(bottom: side),
            ItTabPlacement.bottom => Border(top: side),
            ItTabPlacement.start => Border(right: side),
            ItTabPlacement.end => Border(left: side),
          },
        );
      case ItTabStyle.card:
        // `.nav-tabs-cards .nav-link { border-bottom-width: 2px;
        //   border-color: transparent; border-bottom-color: hsl(210,4%,78%);
        //   border-radius: 4px 4px 0 0 }` and
        // `.nav-tabs-cards .nav-link.active { border: 1px solid hsl(210,4%,78%);
        //   border-bottom-color: transparent; border-bottom-width: 1px }` — the
        // active card opens into the panel by dropping its own bottom rule.
        return BoxDecoration(
          color: isSelected ? colors.white : const Color(0x00000000),
          border: isSelected
              // The transparent bottom is left out rather than declared:
              // `Border` refuses a border radius unless every *visible* side is
              // the same colour, so a transparent 1px side beside three grey
              // ones is a paint-time assertion. The pixel it would have
              // reserved is added back as padding instead — see `_padding`.
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
        );
      case ItTabStyle.button:
        // `.nav-pills .nav-link.active
        //   { background-color: hsl(210,100%,40%) }`
        return BoxDecoration(
          color: isSelected ? colors.primary : const Color(0x00000000),
          borderRadius: BorderRadius.circular(4),
        );
    }
  }
}

/// `.nav-tabs-editable .nav-link-close` — removes the tab it sits in.
///
/// A separate control from the tab, in the kit as here: it is a sibling `<a>`
/// inside the same `<li>`, so activating it must not also select the tab.
class _CloseTabButton extends StatelessWidget {
  const _CloseTabButton({
    required this.label,
    required this.onPressed,
    required this.isSelected,
    required this.disabled,
    required this.dark,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool disabled;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return ItHoverBuilder(
      enabled: !disabled,
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) {
        final colors = resolveColorScheme(context);
        final color = disabled
            // `.nav-link-close.disabled { color: hsl(210,3%,85%) }`
            ? _TabTokens.disabledColor
            : isSelected
                // `.nav-link.active .nav-link-close { color: #06c }`
                ? colors.primary
                : hovered
                    // `.nav-link-close:hover { color: rgb(0,91.8,183.6) }`,
                    // which is `shade(#06c, 10%)` — derived so a retinted
                    // primary darkens with it rather than snapping to blue.
                    ? itShade(colors.primary, 0.1)
                    // `.nav-link-close { color: hsl(210,33%,28%) }`
                    : _TabTokens.color;

        // §4.1.2: a glyph-only control, so `label` is the whole of what AT has.
        return Semantics(
          button: true,
          enabled: !disabled,
          label: label,
          child: ItActivatable(
            onPressed: onPressed,
            onDark: dark,
            child: ExcludeSemantics(
              child: Icon(
                BootstrapItaliaIcons.it_close,
                // `.nav-link-close .icon` is the shared 32px sprite; the
                // `.it-ico { font-size: .625rem }` rule beside it applies to
                // the icon *font* variant, which the docs' markup does not use.
                size: _TabTokens.iconSize,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// `.nav-tabs-editable .nav-tab-add` — a `+` in a ring, appended to the bar.
///
/// Drawn rather than set: the kit builds the cross from two absolutely
/// positioned 2px rectangles inside a circular border, so an icon glyph would
/// differ in both stroke weight and optical size.
class _AddTabButton extends StatelessWidget {
  const _AddTabButton({
    required this.onPressed,
    required this.label,
    required this.dark,
  });

  final VoidCallback onPressed;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    // `.nav-tab-add { border: 1px solid #06c }` and both bars
    // `background-color: #06c` — the primary token, so the control follows a
    // retinted administration.
    final accent = colors.primary;

    return Semantics(
      button: true,
      label: label,
      child: ItActivatable(
        onPressed: onPressed,
        onDark: dark,
        borderRadius: BorderRadius.circular(_TabTokens.addSize / 2),
        child: ExcludeSemantics(
          child: Padding(
            // `.nav-tab-add { margin: -0.2em 1em 0; top: .8rem }` — the kit
            // nudges the ring down into the row it sits beside.
            padding: const EdgeInsets.fromLTRB(
              _TabTokens.addMarginX,
              0.8 * 16,
              _TabTokens.addMarginX,
              0,
            ),
            child: SizedBox(
              width: _TabTokens.addSize,
              height: _TabTokens.addSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent),
                ),
                child: Center(
                  child: SizedBox(
                    width: _TabTokens.addBarLength,
                    height: _TabTokens.addBarLength,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // `:before { width: .778rem; height: 2px }`
                        SizedBox(
                          width: _TabTokens.addBarLength,
                          height: _TabTokens.addBarThickness,
                          child: ColoredBox(color: accent),
                        ),
                        // `:after { width: 2px; height: .778rem }`
                        SizedBox(
                          width: _TabTokens.addBarThickness,
                          height: _TabTokens.addBarLength,
                          child: ColoredBox(color: accent),
                        ),
                      ],
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
