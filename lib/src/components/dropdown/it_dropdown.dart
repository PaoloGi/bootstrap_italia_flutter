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

  /// Creates a dropdown item.
  const ItDropdownItem({
    required this.label,
    this.icon,
    this.onTap,
    this.danger = false,
    this.disabled = false,
    this.active = false,
  });
}

/// A non-interactive section header inside the dropdown menu.
class ItDropdownHeader extends ItDropdownEntry {
  /// The header label.
  final String label;

  /// Creates a dropdown header.
  const ItDropdownHeader({required this.label});
}

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

  /// Creates a Bootstrap Italia dropdown menu panel.
  const ItDropdownMenu({
    super.key,
    required this.items,
    this.width,
    this.onItemTap,
    this.autofocus = false,
    this.onDismiss,
    this.onTabOut,
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
            color: colors.white,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in widget.items)
                switch (entry) {
                  ItDropdownItem() =>
                    _buildItem(entry, _itemNodes[itemIndex++], colors),
                  ItDropdownHeader() => _buildHeader(entry, colors),
                  ItDropdownDivider() => _buildDivider(),
                },
            ],
          ),
        ),
      ),
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
      textColor = ItDropdownMenu._disabledColor;
    } else if (item.danger) {
      textColor = colors.danger;
    } else if (hovered || !item.active) {
      // `.link-list-wrapper ul li a span { color: #06c }` and
      // `…a:hover:not(.disabled) span { color: #06c }` — hover restores the
      // plain link colour even on the active row.
      textColor = colors.primary;
    } else {
      textColor = ItDropdownMenu._activeColor;
    }

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ItDropdownMenu._itemPaddingX,
      ),
      child: Row(
        children: [
          if (item.icon != null)
            // `a.list-item.left-icon .icon { margin-left: 0 }` — the icon
            // sits flush against the label. The extra top padding
            // reproduces the SVG's `vertical-align: middle`, which parks
            // the glyph's centre half an x-height above the text baseline
            // rather than at the row's centre.
            Padding(
              padding: const EdgeInsets.only(
                top: ItDropdownMenu._iconBaselineNudge,
              ),
              child: Icon(
                item.icon,
                size: ItDropdownMenu._iconSize,
                color: item.disabled ? const Color(0xFFD8DADB) : textColor,
              ),
            ),
          Expanded(
            child: Text(
              item.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: BootstrapItaliaFontFamily.sansSerif,
                package: BootstrapItaliaFontFamily.package,
                fontSize: 16,
                height: 24 / 16,
                leadingDistribution: TextLeadingDistribution.even,
                // Bootstrap Italia: letter-spacing: normal. Set explicitly so the
                // ambient Material text theme cannot leak its 0.25px tracking.
                letterSpacing: 0,
                fontWeight: FontWeight.w400,
                color: textColor,
                // `.link-list-wrapper ul li a:hover:not(.disabled) span
                //   { text-decoration: underline }`
                decoration:
                    hovered ? TextDecoration.underline : TextDecoration.none,
                decorationColor: textColor,
              ),
            ),
          ),
        ],
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
          height: ItDropdownMenu._itemHeight,
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
                  // font-weight: 600 }` = --bs-body-color.
                  color: colors.bodyColor,
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
    // theme-derived fallback colour). Purely decorative, so it stays out of the
    // semantics tree entirely (WCAG 1.3.1).
    return const ExcludeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ItDropdownMenu._dividerMargin,
        ),
        child: SizedBox(
          height: 1,
          child: ColoredBox(color: ItDropdownMenu._dividerColor),
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

  /// Creates a Bootstrap Italia dropdown.
  const ItDropdown({
    super.key,
    required this.trigger,
    required this.items,
    this.direction = ItDropdownDirection.down,
    this.width,
    this.offset,
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

  Offset _computeFollowerOffset(Size triggerSize) {
    if (widget.offset != null) return widget.offset!;

    // `--bs-dropdown-spacer: 0.125rem`
    const gap = 2.0;
    return switch (widget.direction) {
      ItDropdownDirection.down => Offset(0, triggerSize.height + gap),
      ItDropdownDirection.up => const Offset(0, -gap),
      ItDropdownDirection.right => Offset(triggerSize.width + gap, 0),
      ItDropdownDirection.left => const Offset(-gap, 0),
    };
  }

  Alignment _computeFollowerAnchor() {
    return switch (widget.direction) {
      ItDropdownDirection.down => Alignment.topLeft,
      ItDropdownDirection.up => Alignment.bottomLeft,
      ItDropdownDirection.right => Alignment.topLeft,
      ItDropdownDirection.left => Alignment.topRight,
    };
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final triggerSize = renderBox.size;
    final followerOffset = _computeFollowerOffset(triggerSize);

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
            CompositedTransformFollower(
              link: _layerLink,
              offset: followerOffset,
              targetAnchor: Alignment.topLeft,
              followerAnchor: _computeFollowerAnchor(),
              child: ItDropdownMenu(
                items: widget.items,
                width: widget.width ?? 200.0,
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
            child: GestureDetector(
              onTap: _toggle,
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
