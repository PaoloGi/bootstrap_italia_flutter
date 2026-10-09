import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../../a11y/it_activatable.dart';
import '../../a11y/it_focus_ring.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/it_default_text_style.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';

// ── Data models ─────────────────────────────────────────────────────

/// Direction the dropdown menu opens relative to the trigger.
enum ItDropdownDirection {
  /// Opens above the trigger.
  up,

  /// Opens below the trigger.
  down,

  /// Opens to the left of the trigger.
  left,

  /// Opens to the right of the trigger.
  right,
}

/// Base type for all dropdown menu entries.
///
/// Use the concrete subtypes to build a list of entries:
/// - [ItDropdownItem] — a tappable menu item
/// - [ItDropdownHeader] — a non-interactive section header
/// - [ItDropdownDivider] — a visual separator line
sealed class ItDropdownEntry {
  /// Creates a dropdown entry.
  const ItDropdownEntry();
}

/// A tappable dropdown menu item.
///
/// Set [danger] to `true` for destructive actions (the label and icon
/// are rendered in the theme's danger color).
class ItDropdownItem extends ItDropdownEntry {
  /// The display label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when this item is tapped.
  final VoidCallback? onTap;

  /// Whether this item represents a destructive action.
  final bool danger;

  /// Whether this item is disabled.
  final bool disabled;

  /// Whether this item is the currently active one.
  final bool active;

  /// Renders [icon] after the label instead of before it.
  ///
  /// Bootstrap Italia's `.right-icon`:
  /// `.link-list-wrapper ul li a.right-icon .list-item-title-icon-wrapper
  ///   { padding-right: 0; margin-right: 0; justify-content: space-between }`
  /// — the glyph is pushed to the far edge of the row rather than sitting
  /// against the label, which is why this is not simply "icon on the other
  /// side". The default (`false`) is the kit's `.left-icon`.
  final bool rightIcon;

  /// The `.large` row: an 18px label in a taller row.
  ///
  /// `.link-list-wrapper ul li a.large { font-size: 1.125rem }` and, from the
  /// `sm` breakpoint up, `{ padding-top: .5rem; padding-bottom: .5rem }` —
  /// so the 2rem line box gains 8px above and below instead of 4px.
  final bool large;

  /// Creates a dropdown item.
  const ItDropdownItem({
    required this.label,
    this.icon,
    this.onTap,
    this.danger = false,
    this.disabled = false,
    this.active = false,
    this.rightIcon = false,
    this.large = false,
  });
}

/// A non-interactive section header inside the dropdown menu.
class ItDropdownHeader extends ItDropdownEntry {
  /// The header label.
  final String label;

  /// Creates a dropdown header.
  const ItDropdownHeader({required this.label});
}

/// `.link-list-wrapper ul li a.disabled .icon { fill: hsl(210,4%,85%) }`.
///
/// Named rather than inlined now that two branches read it. Matches no palette
/// entry, so it stays a literal.
const Color _kDisabledIconColor = Color(0xFFD8DADB);

/// A visual separator line inside the dropdown menu.
class ItDropdownDivider extends ItDropdownEntry {
  /// Creates a dropdown divider.
  const ItDropdownDivider();
}

// ── Menu panel ──────────────────────────────────────────────────────

/// The floating panel rendered by [ItDropdown] — Bootstrap Italia's
/// `.dropdown-menu` containing a `.link-list`.
///
/// Exposed separately so the panel can be embedded (or golden-tested)
/// without driving the overlay.
class ItDropdownMenu extends StatefulWidget {
  // ── Bootstrap Italia `.dropdown-menu` / `.link-list` metrics ──────
  // Source: bootstrap-italia.min.css
  //   .dropdown-menu { --bs-dropdown-padding-y: .5rem;
  //     --bs-dropdown-padding-x: 0; border-radius: 0 0 4px 4px;
  //     box-shadow: 0 3px 15px 0 rgba(0,0,0,.1) }
  //   .link-list-wrapper ul li a.list-item { padding: 4px 24px }
  //   .link-list-wrapper ul .divider { height: 1px;
  //     background: hsl(210,4%,78%); margin: 8px 0 }

  /// `--bs-dropdown-padding-y: 0.5rem`.
  static const double _menuPaddingY = BootstrapItaliaSpacing.space2;

  /// `--bs-dropdown-item-padding-x: 24px`.
  static const double _itemPaddingX = BootstrapItaliaSpacing.space4;

  /// `a.list-item` renders 4px padding around a 32px line box.
  static const double _itemHeight = 40;

  /// `a.list-item.large` renders 8px padding around the same 32px line box.
  static const double _largeItemHeight = 48;

  /// `.link-list-heading` / `h3.header` renders a 32px line box.
  static const double _headerHeight = 32;

  /// The 8px gap that follows a section header.
  static const double _headerGap = BootstrapItaliaSpacing.space2;

  /// `.link-list-wrapper ul .divider { margin: 8px 0 }`.
  static const double _dividerMargin = BootstrapItaliaSpacing.space2;

  /// `background: hsl(210,4%,78%)`.
  static const Color _dividerColor = Color(0xFFC5C7C9);

  /// `.link-list-wrapper ul li a.disabled span { color: hsl(210,12%,44%) }`.
  static const Color _disabledColor = Color(0xFF63707E);

  /// `.link-list-wrapper ul li a.active span { color: rgb(0,38.25,76.5) }`.
  static const Color _activeColor = Color(0xFF00264D);

  /// `.icon.icon-sm { width: 24px; height: 24px }`.
  static const double _iconSize = BootstrapItaliaSpacing.space4;

  // ── `.dropdown-menu.dark` ─────────────────────────────────────────
  //
  // Every colour below stays a literal. `.dropdown-menu.dark
  //   { background-color: hsl(210,25%,35.2%) }` is #435A70 — the same band
  // ItBreadcrumb's dark story paints, and established there as a literal: it
  // matches no entry in the palette, so nothing about it re-themes. Its
  // foregrounds inherit that: a `#fff` sitting on a fixed slate band is not the
  // on-primary role `--bs-white` names, and routing it through the scheme would
  // let a retinted `white` drift off a fill that did not move with it.

  /// `.dropdown-menu.dark { background-color: hsl(210,25%,35.2%) }`.
  static const Color _darkBg = Color(0xFF435A70);

  /// `.dropdown-menu.dark … a span, … li h3, … li i { color: #fff }` — the
  /// same declaration covers the resting label, the hover label and the
  /// heading, so one constant serves all three.
  static const Color _darkFg = Color(0xFFFFFFFF);

  /// `.dropdown-menu.dark .link-list-wrapper ul span.divider
  ///   { background: #2e465e }`.
  static const Color _darkDividerColor = Color(0xFF2E465E);

  /// `.dropdown-menu.dark … a.disabled span
  ///   { color: rgb(172.584,178.092,183.6) }`, rasterised as
  /// `rgb(173,178,184)`.
  static const Color _darkDisabledColor = Color(0xFFADB2B8);

  /// `.dropdown-menu.dark … a.active span { color: rgb(0,255,246.5) }`,
  /// rasterised as `rgb(0,255,247)`.
  ///
  /// A cyan rather than the light story's navy: on the slate band the navy
  /// would sit at about 1.4:1, so the active row is signalled by moving
  /// *away* from the foreground white rather than towards the background.
  static const Color _darkActiveColor = Color(0xFF00FFF7);

  /// Padding added above the item icon so that centring it in the 40px row
  /// lands where CSS `vertical-align: middle` puts it (2px lower).
  static const double _iconBaselineNudge = 4;

  /// The menu entries.
  final List<ItDropdownEntry> items;

  /// Fixed width for the panel. When null the panel sizes to its content
  /// (respecting `--bs-dropdown-min-width: 10rem`).
  final double? width;

  /// Called when an item is tapped, before the item's own callback.
  final VoidCallback? onItemTap;

  /// Whether the first entry should take focus as soon as the panel mounts.
  ///
  /// [ItDropdown] sets this so that opening the menu moves focus into it, as
  /// the WAI-ARIA menu-button pattern requires (WCAG 2.4.3 Focus Order).
  final bool autofocus;

  /// Called when the user presses Escape inside the panel, asking its owner to
  /// close it.
  ///
  /// Required for WCAG 2.1.2 No Keyboard Trap: a menu that can be entered with
  /// the keyboard has to be leavable with the keyboard.
  ///
  /// A *request* — the panel does not unmount itself — so it keeps the present
  /// tense, as [ItChip.onDismiss] does.
  final VoidCallback? onDismiss;

  /// Called when the user presses Tab inside the panel.
  final VoidCallback? onTabOut;

  /// The `.dropdown-menu.dark` panel: a slate fill with white content.
  ///
  /// Presentation only — every role, name, state and key binding is the same
  /// as on the light panel, which is what the a11y contract for this variant
  /// asserts.
  final bool dark;

  /// The `.dropdown-menu.full-width` panel.
  ///
  /// `.dropdown-menu.full-width { width: 100% }` with
  /// `.dropdown-menu.full-width .link-list li
  ///   { display: inline-block; width: auto }` — the rows stop being a stacked
  /// list and flow inline, wrapping when they run out of room. [ItDropdown]
  /// pairs this with a panel as wide as its trigger.
  final bool fullWidth;

  /// Creates a Bootstrap Italia dropdown menu panel.
  const ItDropdownMenu({
    super.key,
    required this.items,
    this.width,
    this.onItemTap,
    this.autofocus = false,
    this.onDismiss,
    this.onTabOut,
    this.dark = false,
    this.fullWidth = false,
  });

  @override
  State<ItDropdownMenu> createState() => _ItDropdownMenuState();
}

class _ItDropdownMenuState extends State<ItDropdownMenu> {
  /// One node per [ItDropdownItem], in order — including disabled ones.
  ///
  /// Disabled entries stay focusable on purpose: WCAG 4.1.2 wants them
  /// *announced as disabled*, and a node a keyboard user can never land on is
  /// announced as nothing at all. This mirrors the WAI-ARIA menu pattern,
  /// where `aria-disabled` items remain in the focus ring.
  final List<FocusNode> _itemNodes = [];

  @override
  void initState() {
    super.initState();
    _syncNodes();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _itemNodes.isNotEmpty) _itemNodes.first.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(ItDropdownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
  }

  void _syncNodes() {
    final needed = widget.items.whereType<ItDropdownItem>().length;
    while (_itemNodes.length < needed) {
      _itemNodes
          .add(FocusNode(debugLabel: 'ItDropdownItem ${_itemNodes.length}'));
    }
    while (_itemNodes.length > needed) {
      _itemNodes.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    for (final node in _itemNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Moves focus [delta] entries along, wrapping at both ends.
  void _moveFocus(int delta) {
    if (_itemNodes.isEmpty) return;
    final current = _itemNodes.indexWhere((n) => n.hasFocus);
    final next = current < 0
        ? (delta > 0 ? 0 : _itemNodes.length - 1)
        : (current + delta) % _itemNodes.length;
    _itemNodes[next].requestFocus();
  }

  /// WCAG 2.1.1 Keyboard: arrow keys walk the menu, Escape and Tab leave it.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveFocus(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveFocus(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      widget.onDismiss?.call();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      // Closing returns focus to the trigger, so the next Tab carries on from
      // there rather than from a node that no longer exists.
      widget.onTabOut?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    var itemIndex = 0;

    // No `Material` above the panel: it was a `MaterialType.transparency`
    // surface, i.e. an ink host and nothing else, and the panel paints its own
    // fill, radius and shadow below.
    return Focus(
      onKeyEvent: _handleKey,
      canRequestFocus: false,
      skipTraversal: true,
      child: ItDefaultTextStyle(
        child: Container(
          width: widget.width,
          constraints: const BoxConstraints(minWidth: 160),
          decoration: BoxDecoration(
            // `--bs-dropdown-bg: hsl(0,0%,100%)` on the default panel, which is
            // `--bs-white` in the surface role that token names; the `.dark`
            // fill is the literal slate above.
            color: widget.dark ? ItDropdownMenu._darkBg : colors.white,
            // `.dropdown-menu { border-radius: 0 0 4px 4px }` — the menu is
            // visually attached to its trigger.
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(BootstrapItaliaBorders.radius),
              bottomRight: Radius.circular(BootstrapItaliaBorders.radius),
            ),
            // `box-shadow: 0 3px 15px 0 rgba(0,0,0,.1)`
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 15,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            vertical: ItDropdownMenu._menuPaddingY,
          ),
          child: _layout(<Widget>[
            for (final entry in widget.items)
              switch (entry) {
                ItDropdownItem() =>
                  _buildItem(entry, _itemNodes[itemIndex++], colors),
                ItDropdownHeader() => _buildHeader(entry, colors),
                ItDropdownDivider() => _buildDivider(),
              },
          ]),
        ),
      ),
    );
  }

  /// Stacks [rows], or flows them inline for `.full-width`.
  ///
  /// `.dropdown-menu.full-width .link-list li { display: inline-block;
  ///   width: auto }` — inline boxes on a line that wraps, which is a [Wrap]
  /// rather than a [Row]: a Row would overflow instead of moving the surplus
  /// rows onto a second line, and a five-item menu does not fit a button's
  /// width.
  Widget _layout(List<Widget> rows) {
    if (!widget.fullWidth) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      );
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: rows,
    );
  }

  Widget _buildItem(
    ItDropdownItem item,
    FocusNode node,
    BootstrapItaliaColorScheme colors,
  ) {
    return ItHoverBuilder(
      enabled: !item.disabled,
      cursor:
          item.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      builder: (context, hovered) =>
          _buildItemBody(item, node, colors, hovered),
    );
  }

  Widget _buildItemBody(
    ItDropdownItem item,
    FocusNode node,
    BootstrapItaliaColorScheme colors,
    bool hovered,
  ) {
    final Color textColor;
    if (item.disabled) {
      textColor = widget.dark
          // `.dropdown-menu.dark … a.disabled span`
          ? ItDropdownMenu._darkDisabledColor
          : ItDropdownMenu._disabledColor;
    } else if (item.danger) {
      textColor = colors.danger;
    } else if (widget.dark) {
      // `.dropdown-menu.dark … a span, … a:hover span { color: #fff }` covers
      // resting and hover alike, so only the active row differs.
      textColor = item.active
          ? ItDropdownMenu._darkActiveColor
          : ItDropdownMenu._darkFg;
    } else if (hovered || !item.active) {
      // `.link-list-wrapper ul li a span { color: #06c }` and
      // `…a:hover:not(.disabled) span { color: #06c }` — hover restores the
      // plain link colour even on the active row.
      textColor = colors.primary;
    } else {
      textColor = ItDropdownMenu._activeColor;
    }

    // `.link-list-wrapper ul li a.disabled .icon { fill: hsl(210,4%,85%) }`;
    // on the dark panel the docs' own example uses `icon-light`, i.e. the same
    // `#fff` the label carries.
    final Color iconColor;
    if (item.disabled) {
      iconColor =
          widget.dark ? ItDropdownMenu._darkDisabledColor : _kDisabledIconColor;
    } else if (widget.dark) {
      iconColor = ItDropdownMenu._darkFg;
    } else {
      iconColor = textColor;
    }

    final label = Text(
      item.label,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        // `.link-list-wrapper ul li a { font-size: 1rem }`, raised to
        // `1.125rem` by `.large`. `.large` takes its extra height from the
        // padding pair below, not from leading, so the text box stays 24px in
        // both — the value the light story was measured against.
        fontSize: item.large ? 18 : 16,
        height: item.large ? 24 / 18 : 24 / 16,
        leadingDistribution: TextLeadingDistribution.even,
        // Bootstrap Italia: letter-spacing: normal. Set explicitly so the
        // ambient Material text theme cannot leak its 0.25px tracking.
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: textColor,
        // `.link-list-wrapper ul li a:hover:not(.disabled) span
        //   { text-decoration: underline }`
        decoration: hovered ? TextDecoration.underline : TextDecoration.none,
        decorationColor: textColor,
      ),
    );

    // `a.list-item.left-icon .icon { margin-left: 0 }` — the icon sits flush
    // against the label. The extra top padding reproduces the SVG's
    // `vertical-align: middle`, which parks the glyph's centre half an x-height
    // above the text baseline rather than at the row's centre.
    final glyph = item.icon == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(
              top: ItDropdownMenu._iconBaselineNudge,
            ),
            child: Icon(
              item.icon,
              size: ItDropdownMenu._iconSize,
              color: iconColor,
            ),
          );

    // `.right-icon … { justify-content: space-between }` pushes the glyph to
    // the far edge; a stacked row gets that from the label's Expanded, and an
    // inline `.full-width` row — which is only as wide as its own content —
    // from the 8px gap the sprite carries.
    final List<Widget> cells;
    if (glyph == null) {
      cells = [widget.fullWidth ? label : Expanded(child: label)];
    } else if (item.rightIcon) {
      cells = [
        if (widget.fullWidth) ...[label, const SizedBox(width: 8)] else
          Expanded(child: label),
        glyph,
      ];
    } else {
      cells = [glyph, widget.fullWidth ? label : Expanded(child: label)];
    }

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ItDropdownMenu._itemPaddingX,
      ),
      child: Row(
        mainAxisSize: widget.fullWidth ? MainAxisSize.min : MainAxisSize.max,
        children: cells,
      ),
    );

    // WCAG 4.1.2 Name, Role, Value. `InkWell` on its own exposed only
    // `isFocusable` plus a tap action: no role at all, so AT announced a bare
    // string. Worse, a disabled entry dropped its `onTap` and became a fully
    // inert node — present visually, invisible to a screen reader, and never
    // announced as *disabled*. The explicit flags fix both.
    //
    // Bootstrap Italia declares `--bs-dropdown-link-hover-bg: #e6ecf2` but then
    // overrides `.dropdown-item:hover { background-color: rgba(0,0,0,0) }`, and
    // this menu is built from `.link-list` markup, whose rows keep a transparent
    // background in the hover AND pressed state (measured on the React kit). So
    // the row has no fill in any state and nothing for an ink surface to paint;
    // hover is the underline resolved above.
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: !item.disabled,
        // Only the active entry claims selected state; emitting
        // `selected: false` on every row would make AT read "not selected"
        // over and over.
        selected: item.active ? true : null,
        child: SizedBox(
          // `a.list-item { padding: 4px 24px }` around a 2rem line box, and
          // `@media (min-width: 576px) { a.large { padding-top: .5rem;
          //   padding-bottom: .5rem } }`.
          height: item.large
              ? ItDropdownMenu._largeItemHeight
              : ItDropdownMenu._itemHeight,
          // §2.4.7 for both branches — a disabled entry stays in the focus ring
          // on purpose (see `_itemNodes`), so it needs an indicator too. It
          // cannot use ItActivatable, whose FocusableActionDetector drops
          // `canRequestFocus` when there is no callback, so it keeps a bare
          // Focus node and the descendant-tracking mode of the shared ring.
          child: item.disabled
              ? ItFocusRing(
                  trackDescendants: true,
                  child: Focus(focusNode: node, child: content),
                )
              : ItActivatable(
                  focusNode: node,
                  onPressed: () {
                    widget.onItemTap?.call();
                    item.onTap?.call();
                  },
                  child: content,
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    ItDropdownHeader header,
    BootstrapItaliaColorScheme colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ItDropdownMenu._headerGap),
      child: SizedBox(
        height: ItDropdownMenu._headerHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ItDropdownMenu._itemPaddingX,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            // `h3.header` upstream — WCAG 1.3.1 requires the section-heading
            // relationship to reach AT, not just the visual weight.
            child: Semantics(
              header: true,
              child: Text(
                header.label,
                // `h3.header.dropdown-item` renders 1.125rem / 2rem semibold in
                // the body colour.
                style: TextStyle(
                  fontFamily: BootstrapItaliaFontFamily.sansSerif,
                  package: BootstrapItaliaFontFamily.package,
                  fontSize: 18,
                  height: ItDropdownMenu._headerHeight / 18,
                  leadingDistribution: TextLeadingDistribution.even,
                  // Bootstrap Italia: letter-spacing: normal. Set explicitly so the
                  // ambient Material text theme cannot leak its 0.25px tracking.
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  // `.link-list-heading { color: hsl(0, 0%, 10%); font-size: 1.125rem;
                  // font-weight: 600 }` = --bs-body-color, overridden by
                  // `.dropdown-menu.dark .link-list-wrapper .link-list-heading
                  //   { color: #fff }`.
                  color:
                      widget.dark ? ItDropdownMenu._darkFg : colors.bodyColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    // `.link-list-wrapper ul .divider { display: block; height: 1px;
    //   background: hsl(210,4%,78%); margin: 8px 0 }` — a 1px rule with 8px of
    // margin above and below, which is a plain box rather than anything
    // Material's Divider adds (its `DividerThemeData` lookup, its indent, its
    // theme-derived fallback colour). `.dropdown-menu.dark .link-list-wrapper
    //   ul span.divider { background: #2e465e }` darkens it on the slate panel,
    // where the light rule would read as a bright line. Purely decorative, so
    // it stays out of the semantics tree entirely (WCAG 1.3.1).
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: ItDropdownMenu._dividerMargin,
        ),
        child: SizedBox(
          height: 1,
          child: ColoredBox(
            color: widget.dark
                ? ItDropdownMenu._darkDividerColor
                : ItDropdownMenu._dividerColor,
          ),
        ),
      ),
    );
  }
}

// ── Widget ──────────────────────────────────────────────────────────

/// A Bootstrap Italia dropdown menu.
///
/// Displays a list of [ItDropdownEntry] items in an overlay that opens
/// when the user taps the [trigger] widget.
///
/// ```dart
/// ItDropdown(
///   trigger: ItButton(child: Text('Azioni')),
///   direction: ItDropdownDirection.down,
///   items: [
///     ItDropdownHeader(label: 'Sezione'),
///     ItDropdownItem(label: 'Modifica', onTap: () {}),
///     ItDropdownDivider(),
///     ItDropdownItem(label: 'Elimina', onTap: () {}, danger: true),
///   ],
/// )
/// ```
class ItDropdown extends StatefulWidget {
  /// The widget that opens the dropdown when tapped.
  final Widget trigger;

  /// The menu entries.
  final List<ItDropdownEntry> items;

  /// The direction the menu opens relative to the trigger.
  final ItDropdownDirection direction;

  /// Custom width for the menu. Defaults to 200.
  final double? width;

  /// Custom offset from the trigger.
  final Offset? offset;

  /// The `.dropdown-menu.dark` panel — see [ItDropdownMenu.dark].
  final bool dark;

  /// The `.dropdown-menu.full-width` panel — see [ItDropdownMenu.fullWidth].
  ///
  /// Overrides [width]: `.dropdown-menu.full-width { width: 100% }` means the
  /// width of the element that contains the dropdown button, which here is the
  /// trigger itself.
  final bool fullWidth;

  /// Creates a Bootstrap Italia dropdown.
  const ItDropdown({
    super.key,
    required this.trigger,
    required this.items,
    this.direction = ItDropdownDirection.down,
    this.width,
    this.offset,
    this.dark = false,
    this.fullWidth = false,
  });

  @override
  State<ItDropdown> createState() => _ItDropdownState();
}

class _ItDropdownState extends State<ItDropdown> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _triggerFocusNode =
      FocusNode(debugLabel: 'ItDropdown trigger');
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _triggerFocused = false;
  Offset? _downAt;

  void _toggle() {
    if (_isOpen) {
      _close(restoreFocus: true);
    } else {
      _open();
    }
  }

  void _open() {
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  /// Closes the menu, optionally handing focus back to the trigger.
  ///
  /// WCAG 2.4.3 Focus Order: whenever the menu is dismissed by the keyboard —
  /// Escape, Tab, or activating an entry — focus has to return to the control
  /// that opened it. Otherwise it is left on a node that has just been removed
  /// from the tree and the user is dumped back at the top of the page.
  void _close({bool restoreFocus = false}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
    if (restoreFocus) _triggerFocusNode.requestFocus();
  }

  /// WCAG 2.1.1 Keyboard: the trigger was a bare [GestureDetector], operable
  /// with a pointer only. Enter/Space toggle the menu and Down opens it and
  /// steps inside, per the WAI-ARIA menu-button pattern.
  KeyEventResult _handleTriggerKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape && _isOpen) {
      _close(restoreFocus: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      _toggle();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown && !_isOpen) {
      _open();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// The trigger's box in the overlay's own coordinates.
  Rect _triggerRectInOverlay() {
    final box = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    return box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final triggerSize = renderBox.size;

    return OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            // Full-screen dismiss target. Kept out of the semantics tree: it
            // is a pointer affordance, not a control, and exposing an
            // unlabelled full-screen tappable node would leave a screen-reader
            // user swiping into a mystery button (WCAG 4.1.2).
            ExcludeSemantics(
              child: GestureDetector(
                onTap: () => _close(restoreFocus: true),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            CustomSingleChildLayout(
              delegate: _DropdownPlacement(
                direction: widget.direction,
                trigger: _triggerRectInOverlay(),
              ),
              child: ItDropdownMenu(
                items: widget.items,
                width: widget.fullWidth
                    ? triggerSize.width
                    : (widget.width ?? 200.0),
                dark: widget.dark,
                fullWidth: widget.fullWidth,
                autofocus: true,
                onItemTap: () => _close(restoreFocus: true),
                onDismiss: () => _close(restoreFocus: true),
                onTabOut: () => _close(restoreFocus: true),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _triggerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return CompositedTransformTarget(
      link: _layerLink,
      // Merged so AT announces one control — "Azioni, button, collapsed" —
      // rather than a button wrapping a separate unnamed node.
      child: MergeSemantics(
        child: Semantics(
          button: true,
          // WCAG 4.1.2 Name, Role, Value: a disclosure control must publish
          // whether it is currently open. Without this the menu silently
          // appears and disappears for a screen-reader user.
          expanded: _isOpen,
          child: Focus(
            focusNode: _triggerFocusNode,
            onKeyEvent: _handleTriggerKey,
            onFocusChange: (value) {
              if (_triggerFocused != value) {
                setState(() => _triggerFocused = value);
              }
            },
            // A Listener, not a GestureDetector: the trigger is usually an
            // ItButton, whose own tap recogniser wins the gesture arena over
            // an ancestor's, so a GestureDetector here never fired and the
            // menu never opened. A Listener takes no part in the arena, so it
            // sees the tap whatever the trigger does with it.
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (e) => _downAt = e.position,
              onPointerCancel: (_) => _downAt = null,
              onPointerUp: (e) {
                final down = _downAt;
                _downAt = null;
                if (down != null &&
                    (e.position - down).distance <= kTouchSlop) {
                  _toggle();
                }
              },
              child: DecoratedBox(
                // WCAG 2.4.7 Focus Visible. The trigger is caller-supplied, so
                // the ring is drawn here rather than assuming the child paints
                // one. Foreground decoration keeps layout — and the golden
                // captures, which never hold focus — untouched.
                position: DecorationPosition.foreground,
                decoration: _triggerFocused
                    ? BoxDecoration(
                        border: Border.all(color: colors.primary, width: 2),
                      )
                    : const BoxDecoration(),
                child: widget.trigger,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Places the menu beside its trigger and keeps it on screen.
///
/// Bootstrap Italia positions its menus with Popper, whose `flip` modifier
/// moves a menu to the opposite side when the requested one has no room, and
/// whose `preventOverflow` keeps it inside the viewport. Without both, a
/// `dropstart` menu on a trigger near the left edge opened off-screen and its
/// entries could not be reached at all.
class _DropdownPlacement extends SingleChildLayoutDelegate {
  _DropdownPlacement({required this.direction, required this.trigger});

  final ItDropdownDirection direction;
  final Rect trigger;

  /// `--bs-dropdown-spacer: 0.125rem`
  static const double _gap = 2;

  /// Breathing room kept between the menu and the screen edge.
  static const double _margin = 8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        maxWidth: constraints.maxWidth - 2 * _margin,
        maxHeight: constraints.maxHeight - 2 * _margin,
      );

  @override
  Offset getPositionForChild(Size size, Size child) {
    double clampX(double x) =>
        x.clamp(_margin, size.width - _margin - child.width).toDouble();
    double clampY(double y) =>
        y.clamp(_margin, size.height - _margin - child.height).toDouble();

    // One axis flips when the side asked for is too tight and the opposite
    // one is not; the other axis only clamps.
    double along(double start, double end, double extent, double limit,
        {required bool leading}) {
      final before = start - _gap - extent;
      final after = end + _gap;
      final fitsBefore = before >= _margin;
      final fitsAfter = after + extent <= limit - _margin;
      if (leading) return fitsBefore || !fitsAfter ? before : after;
      return fitsAfter || !fitsBefore ? after : before;
    }

    return switch (direction) {
      ItDropdownDirection.down => Offset(
          clampX(trigger.left),
          clampY(along(trigger.top, trigger.bottom, child.height, size.height,
              leading: false)),
        ),
      ItDropdownDirection.up => Offset(
          clampX(trigger.left),
          clampY(along(trigger.top, trigger.bottom, child.height, size.height,
              leading: true)),
        ),
      ItDropdownDirection.right => Offset(
          clampX(along(trigger.left, trigger.right, child.width, size.width,
              leading: false)),
          clampY(trigger.top),
        ),
      ItDropdownDirection.left => Offset(
          clampX(along(trigger.left, trigger.right, child.width, size.width,
              leading: true)),
          clampY(trigger.top),
        ),
    };
  }

  @override
  bool shouldRelayout(_DropdownPlacement old) =>
      old.direction != direction || old.trigger != trigger;
}
