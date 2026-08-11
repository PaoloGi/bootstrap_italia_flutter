import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/it_default_text_style.dart';
import '../../tokens/typography.dart';
import '../../theme/theme_extensions.dart';
import '../../utilities/interaction_states.dart';

/// A single item within an [ItList].
class ItListItem {
  /// The item title.
  final String title;

  /// Optional subtitle or description, rendered below the title.
  final String? subtitle;

  /// Optional leading widget (icon, avatar, etc.).
  final Widget? leading;

  /// Optional trailing widget (icon, badge, etc.).
  final Widget? trailing;

  /// Whether this item is in an active/selected state.
  final bool active;

  /// Whether this item is disabled.
  final bool disabled;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  /// Creates a list item.
  const ItListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.active = false,
    this.disabled = false,
    this.onTap,
  });
}

/// Geometry and colour tokens for the Bootstrap Italia `.link-list`.
///
/// Values come from `bootstrap-italia.min.css`
/// (`.link-list-wrapper ul li a` and friends).
abstract final class _ListTokens {
  /// `.link-list-wrapper ul li a { padding: .25rem 24px }`
  static const double paddingY = 4;
  static const double paddingX = 24;

  /// `.link-list-wrapper ul li a { line-height: 2rem }`
  static const double lineBoxHeight = 32;

  /// `.link-list-wrapper ul li a.disabled span { color: hsl(210,12%,44%) }`
  static const Color disabledColor = Color(0xFF63707E);

  /// `.link-list-wrapper ul li a p { color: hsl(210,33%,28%) }`
  static const Color subtitleColor = Color(0xFF30475F);

  /// `.link-list-wrapper ul .divider { height: 1px;
  ///   background: hsl(210,4%,78%); margin: 8px 0 }`
  static const Color dividerColor = Color(0xFFC5C7C9);
  static const double dividerMargin = 8;

  /// `p { margin-bottom: 1rem }` below a multiline item's description.
  static const double subtitleGap = 16;

  /// `.link-list-wrapper.multiline .list-item-title-icon-wrapper
  ///   { margin-bottom: 4px }`
  static const double titleGap = 4;
}

/// A Bootstrap Italia link list (`.link-list`).
///
/// Renders a vertical list of link items with optional leading/trailing
/// widgets, descriptions, and active/disabled states.
///
/// ```dart
/// ItList(
///   items: [
///     ItListItem(
///       title: 'Elemento 1',
///       subtitle: 'Descrizione',
///       trailing: Icon(BootstrapItaliaIcons.it_chevron_right),
///       onTap: () {},
///     ),
///     ItListItem(title: 'Elemento 2'),
///   ],
/// )
/// ```
class ItList extends StatelessWidget {
  /// The list items.
  final List<ItListItem> items;

  /// Whether to show `.divider` rules between items.
  final bool showDividers;

  /// Creates a Bootstrap Italia list.
  const ItList({
    super.key,
    required this.items,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    // The rows used to sit on a transparent Material, which painted nothing but
    // did supply the ambient text style. Every Text below states its own font
    // and metrics, so nothing here depends on it — but stating it once at the
    // root keeps the list correct in a host that has no Material at all, which
    // is the point of doc/adr/0001.
    return ItDefaultTextStyle(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (showDividers && index > 0)
              const Padding(
                padding:
                    EdgeInsets.symmetric(vertical: _ListTokens.dividerMargin),
                child: SizedBox(
                  height: 1,
                  child: ColoredBox(color: _ListTokens.dividerColor),
                ),
              ),
            _ItListTile(item: items[index]),
          ],
        ],
      ),
    );
  }
}

class _ItListTile extends StatelessWidget {
  final ItListItem item;

  const _ItListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ItHoverBuilder(
      enabled: !item.disabled,
      cursor:
          item.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      builder: (context, hovered) => _build(context, hovered),
    );
  }

  Widget _build(BuildContext context, bool hovered) {
    final colors = resolveColorScheme(context);
    // `a span { color: #06c }` and `a:hover span { color: #06c }` are both the
    // primary token; `a.active span` is rgb(0, 38.25, 76.5) = 0.375 x primary,
    // so it is derived rather than declared. `disabled` is hsl(210,12%,44%),
    // which the stylesheet states in its own right — that one stays literal.
    final titleColor = item.disabled
        ? _ListTokens.disabledColor
        : hovered
            ? colors.primary
            : item.active
                ? itShade(colors.primary, 0.625)
                : colors.primary;

    // `.link-list-wrapper ul li a.icon-right, a.icon-left
    //   { padding-left: 0; padding-right: 0 }` — items carrying an icon drop
    // their horizontal padding so the icon aligns with the list edge.
    final hasIcon = item.leading != null || item.trailing != null;
    final horizontal = hasIcon ? 0.0 : _ListTokens.paddingX;

    final titleRow = Row(
      children: [
        if (item.leading != null) ...[
          item.leading!,
          const SizedBox(width: _ListTokens.paddingX),
        ],
        Expanded(
          child: Text(
            item.title,
            // `.link-list-wrapper ul li a { font-size: 1rem }` with
            // `span { line-height: normal }`.
            style: TextStyle(
              fontFamily: BootstrapItaliaFontFamily.sansSerif,
              package: BootstrapItaliaFontFamily.package,
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w400,
              color: titleColor,
              decoration:
                  hovered ? TextDecoration.underline : TextDecoration.none,
              decorationColor: titleColor,
            ),
          ),
        ),
        if (item.trailing != null) item.trailing!,
      ],
    );

    final Widget content = item.subtitle == null
        ? SizedBox(
            height: _ListTokens.lineBoxHeight,
            child: Align(alignment: Alignment.centerLeft, child: titleRow),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _ListTokens.lineBoxHeight,
                child: Align(alignment: Alignment.centerLeft, child: titleRow),
              ),
              const SizedBox(height: _ListTokens.titleGap),
              Text(
                item.subtitle!,
                // `.link-list-wrapper ul li a p { font-size: .875rem;
                //   line-height: initial; color: hsl(210,33%,28%) }`
                style: const TextStyle(
                  fontFamily: BootstrapItaliaFontFamily.sansSerif,
                  package: BootstrapItaliaFontFamily.package,
                  fontSize: 14,
                  height: 21 / 14,
                  fontWeight: FontWeight.w400,
                  // The disabled modifier only recolours the title span, not
                  // the description paragraph.
                  color: _ListTokens.subtitleColor,
                ),
              ),
              const SizedBox(height: _ListTokens.subtitleGap),
            ],
          );

    final padded = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: _ListTokens.paddingY,
      ),
      child: content,
    );

    // A non-interactive row is just its content: the transparent Material that
    // used to wrap it existed only to host an ink splash it never received.
    // `title` is required and non-nullable here, so unlike ItCard a list item
    // cannot be nameless by omission — only by being handed a blank string.
    assert(
      item.title.trim().isNotEmpty,
      'A tappable ItListItem has a blank title, so it is announced as an '
      'unlabelled button (WCAG 2.1 SC 4.1.2 Name, Role, Value).',
    );

    if (item.onTap == null) return padded;

    // §2.4.3 / §4.1.2: title and description are two text nodes inside one
    // link. Merge them so AT announces a single link with one name, and expose
    // the active and disabled states that are otherwise conveyed by colour
    // alone (§1.3.1, §1.4.1).
    //
    // ItActivatable stays *outside* the ExcludeSemantics: it is what supplies
    // the tap action and focusability. Only the inner text is excluded, so the
    // merged node carries exactly one name instead of repeating it.
    //
    // §2.4.7: it also paints the row's focus ring. `.link-list-wrapper ul li a`
    // keeps a transparent background in every state — hover and press are the
    // title colour and underline resolved above — so there is no fill here at
    // all, and nothing an ink surface could contribute.
    return MergeSemantics(
      child: Semantics(
        link: true,
        enabled: !item.disabled,
        selected: item.active,
        label: item.subtitle == null
            ? item.title
            : '${item.title}. ${item.subtitle}',
        child: ItActivatable(
          onPressed: item.disabled ? null : item.onTap,
          child: ExcludeSemantics(child: padded),
        ),
      ),
    );
  }
}
