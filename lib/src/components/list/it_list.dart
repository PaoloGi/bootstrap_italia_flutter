import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/it_default_text_style.dart';
import '../../tokens/breakpoints.dart';
import '../../tokens/typography.dart';
import '../../theme/theme_extensions.dart';
import '../../utilities/interaction_states.dart';

/// One row of an [ItList].
///
/// Sealed so that a list can hold a rule or a form control alongside its links
/// without either of them pretending to be a link. Bootstrap Italia's markup
/// makes the same distinction — `<li><a class="list-item">`,
/// `<li><span class="divider">` and `<li><div class="toggles">` are three
/// different children of the same `<ul class="link-list">` — and a single
/// `ItListItem` type could only express the first.
sealed class ItListEntry {
  /// Const base constructor.
  const ItListEntry();
}

/// A `<span class="divider" role="separator">` between two groups of links.
///
/// ```css
/// .link-list-wrapper ul .divider {
///   display: block; height: 1px; background: hsl(210,4%,78%); margin: 8px 0 }
/// ```
///
/// Distinct from [ItList.showDividers], which rules between *every* pair of
/// rows. The docs use dividers deliberately — under an "Intestazione e
/// divisore" heading, to separate one group of links from the next — so a list
/// placing them explicitly should pass `showDividers: false` and put them
/// where it means them.
class ItListDivider extends ItListEntry {
  /// Creates a separator row.
  const ItListDivider();
}

/// An arbitrary widget occupying one row of the list.
///
/// The docs' *Lista con toggle* and *List con checkbox* put a form control in a
/// `<li>` instead of a link. Both get the list's horizontal gutter and nothing
/// else:
///
/// ```css
/// .link-list-wrapper ul .toggles label { padding: 0 24px; … }
/// .link-list-wrapper ul .form-check.form-check-group { padding: 0 24px;
///   box-shadow: none }
/// ```
///
/// The control keeps its own semantics: it is a checkbox or a switch, and
/// wrapping it in a link role — which is what reusing [ItListItem] would have
/// meant — would tell a screen reader the wrong thing about what activating it
/// does (§4.1.2).
class ItListCustom extends ItListEntry {
  /// The row's content.
  final Widget child;

  /// Whether to apply the list's 24px horizontal gutter.
  ///
  /// True by default, matching the two rules above. Set false for a control
  /// that draws its own inset.
  final bool gutter;

  /// Creates a custom row.
  const ItListCustom({required this.child, this.gutter = true});
}

/// A single link within an [ItList].
class ItListItem extends ItListEntry {
  /// The item title.
  final String title;

  /// Optional subtitle or description, rendered below the title.
  ///
  /// `<p>` in the kit's *Multiline con icona* markup:
  /// `.link-list-wrapper ul li a p { font-size: .875rem; line-height: initial;
  /// color: hsl(210,33%,28%) }`.
  final String? subtitle;

  /// Optional leading widget (icon, avatar, etc.) — `.icon-left`.
  final Widget? leading;

  /// Optional trailing widget (icon, badge, etc.) — `.icon-right`.
  final Widget? trailing;

  /// Whether this item is in an active/selected state.
  final bool active;

  /// Whether this item is disabled.
  final bool disabled;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  /// `.large` — the bigger of the two row sizes.
  ///
  /// ```css
  /// .link-list-wrapper ul li a.large { font-size: 1.125rem }
  /// @media (min-width: 576px) { .link-list-wrapper ul li a.large {
  ///   padding-top: .5rem; padding-bottom: .5rem; font-size: 1.125rem } }
  /// ```
  ///
  /// A size, not a weight — see [medium], which the kit spells confusingly
  /// close to this one.
  final bool large;

  /// `.medium` — semibold label.
  ///
  /// `.link-list-wrapper ul li a.medium { font-weight: 600 }`. Despite the
  /// name this is a **font weight**, not a size between the base row and
  /// [large]; the docs' nested-list example carries `class="large medium"`,
  /// which is how both can be true at once.
  final bool medium;

  /// A nested `<ul class="link-sublist">` under this item.
  ///
  /// `.link-list-wrapper ul.link-sublist { padding-left: 24px }`, dropped back
  /// to zero when the parent row carries an icon:
  /// `.link-list-wrapper ul li a.icon-right + ul, … a.icon-left + ul
  /// { padding-left: 0 }`.
  final List<ItListItem>? children;

  /// Whether [children] are shown behind a disclosure control.
  ///
  /// False renders the docs' *Espansa* form: the sublist is always visible and
  /// the parent stays an ordinary link. True renders *Collassabile*: the parent
  /// becomes a disclosure **button** — `role="button"` with `aria-expanded` in
  /// the kit's own markup — and [onTap] is not called, because the row's job is
  /// now to open and close the group rather than to navigate.
  final bool collapsible;

  /// Whether a [collapsible] group starts open.
  final bool initiallyExpanded;

  /// Creates a list item.
  const ItListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.active = false,
    this.disabled = false,
    this.onTap,
    this.large = false,
    this.medium = false,
    this.children,
    this.collapsible = false,
    this.initiallyExpanded = false,
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

  /// `@media (min-width: 576px) { … a.large { padding-top: .5rem;
  ///   padding-bottom: .5rem } }`
  static const double largePaddingY = 8;

  /// `.link-list-wrapper ul li a { line-height: 2rem }`
  static const double lineBoxHeight = 32;

  /// `.link-list-wrapper ul li a.disabled span { color: hsl(210,12%,44%) }`
  static const Color disabledColor = Color(0xFF63707E);

  /// `.link-list-wrapper ul li a.disabled svg { fill: hsl(210,3%,85%) }`
  ///
  /// The same value the spinner paints its track in, and a literal for the same
  /// reason: hsl(210,3%,85%) matches no palette token, and the stylesheet
  /// states it in its own right dozens of times.
  static const Color disabledIconColor = Color(0xFFD8D9DA);

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

  /// `.link-list-wrapper ul li a.list-item.icon-left .icon
  ///   { margin-right: 8px }`
  ///
  /// Eight, not the 24 the row's own gutter uses. This gap sat at 24 for the
  /// whole of the pixel-parity pass because no capture exercised `leading` —
  /// the three list captures all place their icon on the right.
  static const double leadingGap = 8;

  /// `.link-list-wrapper ul li a .list-item-title-icon-wrapper .list-item-title
  ///   { margin-right: 24px }`, and the blanket
  /// `.link-list-wrapper ul li a span { margin-right: 24px }`.
  static const double trailingGap = 24;

  /// `.link-list-wrapper ul.link-sublist { padding-left: 24px }`
  static const double sublistIndent = 24;

  /// `.link-list-wrapper .link-list-heading { padding: 0 24px;
  ///   font-weight: 600; margin-bottom: 8px; line-height: 1.25 }` at
  /// `font-size: 1.125rem`.
  static const double headingSize = 18;
  static const double headingGap = 8;
  static const double headingLineHeight = 1.25;

  /// `.link-list-wrapper .link-list-heading a { font-size: 1rem;
  ///   line-height: 2rem }` — a linked heading is the *smaller* of the two, and
  /// takes the link colour rather than the body colour.
  static const double headingLinkSize = 16;

  /// Bootstrap's `.collapsing { transition: height .35s ease }`, which the
  /// docs' collapsible sublists drive through `data-bs-toggle="collapse"`.
  static const Duration collapseDuration = Duration(milliseconds: 350);
}

/// A Bootstrap Italia link list (`.link-list`).
///
/// The navigation-menu family from the docs' *Liste per menu di navigazione*:
/// the rows the kit's Dropdown, Megamenu, Sidebar and Navscroll are all built
/// out of. For the content family — `.it-list`, with avatars, thumbnails,
/// metadata and per-row actions — see `ItContentList`; the two share a docs
/// page and nothing else.
///
/// ```dart
/// ItList(
///   heading: 'Sezione',
///   items: [
///     ItListItem(
///       title: 'Elemento 1',
///       subtitle: 'Descrizione',
///       trailing: Icon(BootstrapItaliaIcons.it_chevron_right),
///       onTap: () {},
///     ),
///     ItListDivider(),
///     ItListItem(title: 'Elemento 2'),
///   ],
/// )
/// ```
class ItList extends StatelessWidget {
  /// The list rows.
  final List<ItListEntry> items;

  /// Whether to show `.divider` rules between every pair of rows.
  ///
  /// Leave this on for a list of uniform rows; turn it off and place
  /// [ItListDivider] entries by hand to group links the way the docs do. An
  /// explicit divider never doubles up with an automatic one — the automatic
  /// rule is skipped either side of a hand-placed separator.
  final bool showDividers;

  // Two divergences from the docs were measured against the reference captures
  // rather than argued about, and both came out in favour of these defaults:
  //
  //   showDividers: false        list_multiline 99.90% -> 88.66%
  //   title at 1.125rem (18px)   list_active/disabled 100% -> ~96.8%,
  //                              list_multiline 99.90% -> 98.18%
  //
  // So the reference rows DO carry dividers and ARE 1rem. `.list-item-title`'s
  // 18px belongs to the `.list-item-title-icon-wrapper` shape, which `large`
  // covers; the docs' base navigation list is a different markup shape that
  // passes `showDividers: false`. The docs page and the reference story are not
  // the same specimen, and the reference is what parity is scored against.

  /// `.link-list-heading` — an optional heading above the list.
  ///
  /// Announced as a heading (§1.3.1): the kit's markup is `<h4>`, and a
  /// visually bolder run of text that is not marked up as a heading is
  /// invisible to a screen reader's heading navigation.
  final String? heading;

  /// Makes [heading] a link, as the docs' *Intestazione con link*.
  ///
  /// The linked form is styled differently rather than merely coloured —
  /// `.link-list-heading a { font-size: 1rem; line-height: 2rem }` against the
  /// unlinked 1.125rem — so this is not a decoration that can be added later.
  final VoidCallback? onHeadingTap;

  /// Creates a Bootstrap Italia list.
  const ItList({
    super.key,
    required this.items,
    this.showDividers = true,
    this.heading,
    this.onHeadingTap,
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
          if (heading != null)
            _ItListHeading(text: heading!, onTap: onHeadingTap),
          for (var index = 0; index < items.length; index++) ...[
            if (_autoDividerBefore(index)) const _ItListRule(),
            _row(items[index]),
          ],
        ],
      ),
    );
  }

  /// Whether an automatic rule belongs above the row at [index].
  ///
  /// Suppressed next to a hand-placed [ItListDivider], which would otherwise
  /// paint two rules 8px apart, and above the first row, which has nothing to
  /// be separated from.
  bool _autoDividerBefore(int index) {
    if (!showDividers || index == 0) return false;
    if (items[index] is ItListDivider) return false;
    if (items[index - 1] is ItListDivider) return false;
    return true;
  }

  Widget _row(ItListEntry entry) => switch (entry) {
        ItListDivider() => const _ItListRule(),
        ItListCustom(:final child, :final gutter) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: gutter ? _ListTokens.paddingX : 0,
            ),
            child: child,
          ),
        ItListItem(children: final sublist?) =>
          _ItListGroup(item: entry, children: sublist),
        ItListItem() => _ItListTile(item: entry),
      };
}

/// `<span class="divider" role="separator">`.
class _ItListRule extends StatelessWidget {
  const _ItListRule();

  @override
  Widget build(BuildContext context) {
    // No semantics node. The kit marks the rule `role="separator"`, but Flutter
    // has no separator role to map it onto, and a `Semantics` carrying neither
    // a flag nor a label is an empty node AT still has to step over. A painted
    // line that announces nothing is the closest honest equivalent.
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: _ListTokens.dividerMargin),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: _ListTokens.dividerColor),
      ),
    );
  }
}

/// `.link-list-heading`, with or without a link.
class _ItListHeading extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _ItListHeading({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final linked = onTap != null;

    // `.link-list-wrapper .link-list-heading { color: hsl(0,0%,10%) }` —
    // byte-identical to `--bs-body-color`, in the role that token names: this
    // is body copy set bold, not chrome. So it follows a retinted scheme.
    // The linked form takes the link colour instead, from the ambient `a`.
    final label = Text(
      text,
      style: TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        fontSize:
            linked ? _ListTokens.headingLinkSize : _ListTokens.headingSize,
        height: linked
            // `.link-list-heading a { line-height: 2rem }` against 1.25 unitless
            // on the heading itself.
            ? _ListTokens.lineBoxHeight / _ListTokens.headingLinkSize
            : _ListTokens.headingLineHeight,
        fontWeight: FontWeight.w600,
        color: linked ? colors.primary : colors.bodyColor,
      ),
    );

    final padded = Padding(
      padding: const EdgeInsets.only(
        left: _ListTokens.paddingX,
        right: _ListTokens.paddingX,
        bottom: _ListTokens.headingGap,
      ),
      child: Align(alignment: Alignment.centerLeft, child: label),
    );

    // §1.3.1: `header: true` regardless of whether it is also a link. A linked
    // heading is both, and dropping the heading flag to gain the link one is
    // how a heading disappears from a screen reader's outline.
    if (!linked) {
      return Semantics(header: true, child: padded);
    }
    return MergeSemantics(
      child: Semantics(
        header: true,
        link: true,
        label: text,
        child: ItActivatable(
          onPressed: onTap,
          child: ExcludeSemantics(child: padded),
        ),
      ),
    );
  }
}

/// An item that owns a `<ul class="link-sublist">`.
///
/// Stateful only for the collapsible form; the always-expanded form needs no
/// state but shares the indent and the parent row, so both live here rather
/// than in two near-identical widgets.
class _ItListGroup extends StatefulWidget {
  final ItListItem item;
  final List<ItListItem> children;

  const _ItListGroup({required this.item, required this.children});

  @override
  State<_ItListGroup> createState() => _ItListGroupState();
}

class _ItListGroupState extends State<_ItListGroup> {
  late bool _expanded = widget.item.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final collapsible = item.collapsible;
    final expanded = collapsible ? _expanded : true;

    // `a.icon-right + ul, a.icon-left + ul { padding-left: 0 }` — a parent row
    // carrying an icon has already given up its own 24px gutter, so indenting
    // its sublist would push the children past the parent instead of under it.
    final hasIcon = item.leading != null || item.trailing != null;

    final sublist = Padding(
      padding: EdgeInsets.only(
        left: hasIcon ? 0 : _ListTokens.sublistIndent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in widget.children) _ItListTile(item: child),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ItListTile(
          item: item,
          onTapOverride:
              collapsible ? () => setState(() => _expanded = !_expanded) : null,
          expanded: collapsible ? _expanded : null,
        ),
        // Collapsed children are removed from the tree, not merely clipped: a
        // hidden link that AT can still reach and focus is worse than no
        // animation (§2.4.3, §4.1.2).
        AnimatedSize(
          duration: _ListTokens.collapseDuration,
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? sublist
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}

class _ItListTile extends StatelessWidget {
  final ItListItem item;

  /// Replaces [ItListItem.onTap] for a collapsible group's parent row, which
  /// toggles rather than navigates.
  final VoidCallback? onTapOverride;

  /// Disclosure state, when this row heads a collapsible group; null otherwise.
  ///
  /// Non-null flips the row's role from link to button and adds `expanded`,
  /// mirroring `role="button" aria-expanded` in the kit's markup.
  final bool? expanded;

  const _ItListTile({
    required this.item,
    this.onTapOverride,
    this.expanded,
  });

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

    // `a:hover:not(.disabled) .icon { fill: #06c }`,
    // `a.active .icon { color: rgb(0,38.25,76.5) }` and
    // `a.disabled svg { fill: hsl(210,3%,85%) }` — the glyph tracks the label
    // through all three states. Supplied as an IconTheme rather than forced, so
    // an icon that names its own colour still wins; the parity captures do
    // exactly that.
    final iconColor =
        item.disabled ? _ListTokens.disabledIconColor : titleColor;

    // `.link-list-wrapper ul li a.icon-right, a.icon-left
    //   { padding-left: 0; padding-right: 0 }` — items carrying an icon drop
    // their horizontal padding so the icon aligns with the list edge.
    final hasIcon = item.leading != null || item.trailing != null;
    final horizontal = hasIcon ? 0.0 : _ListTokens.paddingX;

    // `a.large { font-size: 1.125rem }`, with the taller padding arriving only
    // at `sm`. Below it a large row is a larger label in the base line box.
    final width =
        MediaQuery.maybeSizeOf(context)?.width ?? ItBreakpoint.md.minWidth;
    final vertical = item.large && width >= ItBreakpoint.sm.minWidth
        ? _ListTokens.largePaddingY
        : _ListTokens.paddingY;
    final fontSize = item.large ? 18.0 : 16.0;

    // `.link-list-wrapper ul li a[aria-expanded=true] .icon
    //   { transform: scale(-1) }` — a half turn, not a mirror, so a chevron
    // pointing down comes back pointing up.
    final Widget? trailing = item.trailing == null
        ? null
        : (expanded ?? false)
            ? Transform.scale(scaleX: -1, scaleY: -1, child: item.trailing)
            : item.trailing;

    final titleRow = Row(
      children: [
        if (item.leading != null) ...[
          item.leading!,
          const SizedBox(width: _ListTokens.leadingGap),
        ],
        Expanded(
          child: Text(
            item.title,
            // `.link-list-wrapper ul li a { font-size: 1rem }` with
            // `span { line-height: normal }`, and `a.medium { font-weight: 600 }`.
            style: TextStyle(
              fontFamily: BootstrapItaliaFontFamily.sansSerif,
              package: BootstrapItaliaFontFamily.package,
              fontSize: fontSize,
              height: 24 / 16,
              fontWeight: item.medium ? FontWeight.w600 : FontWeight.w400,
              color: titleColor,
              decoration:
                  hovered ? TextDecoration.underline : TextDecoration.none,
              decorationColor: titleColor,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: _ListTokens.trailingGap),
          trailing,
        ],
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
        vertical: vertical,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: iconColor),
        child: content,
      ),
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

    final onPressed = onTapOverride ?? item.onTap;
    if (onPressed == null) return padded;

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
    //
    // A collapsible group's parent row is a **button** with `expanded`, not a
    // link: it opens a group rather than going anywhere, and the kit's own
    // markup says so with `role="button" aria-expanded`.
    final disclosure = expanded != null;
    return MergeSemantics(
      child: Semantics(
        link: !disclosure,
        button: disclosure,
        expanded: expanded,
        enabled: !item.disabled,
        selected: item.active,
        label: item.subtitle == null
            ? item.title
            : '${item.title}. ${item.subtitle}',
        child: ItActivatable(
          onPressed: item.disabled ? null : onPressed,
          child: ExcludeSemantics(child: padded),
        ),
      ),
    );
  }
}
