import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/it_default_text_style.dart';
import '../../tokens/breakpoints.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../theme/theme_extensions.dart';
import '../../utilities/interaction_states.dart';

/// One of the icon buttons in a row's `.it-multiple` group.
///
/// ```html
/// <span class="it-multiple">
///   <a href="#" aria-label="Testo - Azione 1"><svg class="icon">…</svg></a>
/// ```
///
/// [label] is required, and that is the point of the class. The kit's own
/// markup labels each action *with the row it belongs to* — "Testo - Azione 1",
/// not "Azione 1" — because a page of eight rows with three actions each
/// otherwise gives a screen reader twenty-four buttons whose names repeat in
/// groups of three, and a user picking one out of the element list is guessing
/// (§2.4.4 Link Purpose, §4.1.2 Name, Role, Value).
@immutable
class ItListAction {
  /// The glyph. Painted at 24px — `.it-right-zone svg { width: 24px;
  /// height: 24px }` — regardless of the icon's own default size.
  final IconData icon;

  /// The accessible name. Name the row as well as the action.
  final String label;

  /// Invoked when the action is activated.
  final VoidCallback? onPressed;

  /// Creates an action for a content list row.
  const ItListAction({
    required this.icon,
    required this.label,
    this.onPressed,
  });
}

/// A single row of an [ItContentList] — the kit's `<li><div class="list-item">`.
@immutable
class ItContentListItem {
  /// `.text` — the row's title. Semibold, and the row's accessible name.
  final String text;

  /// The `<p class="small">` beneath [text].
  ///
  /// `.it-right-zone .text + p { font-size: .875rem;
  /// color: hsl(210,17%,44%); font-weight: 400 }`. The docs put both inside one
  /// `<div>` "per il corretto allineamento", which is what the column below is.
  final String? description;

  /// The `.avatar` / `.it-rounded-icon` / `.it-thumb` slot ahead of the text.
  ///
  /// Any widget: the three the docs show differ only in what they draw, and the
  /// row treats them identically —
  /// `.list-item .avatar, .it-rounded-icon, .it-thumb
  /// { flex-shrink: 0; margin-right: 16px }`. See [ItRoundedIcon] and
  /// [ItListThumb] for two of them.
  final Widget? leading;

  /// `.metadata` — a short muted string after the text.
  final String? metadata;

  /// A single `.icon` after the text, as the docs' *Con freccia*.
  ///
  /// Decorative: it is inside the row's own link and repeating it in the
  /// announcement would say the row's name twice. Use [actions] for a glyph
  /// that is a control in its own right.
  final Widget? trailing;

  /// `.it-multiple` — one or more icon buttons at the end of the row.
  final List<ItListAction> actions;

  /// Makes the row a link.
  ///
  /// What it makes into a link depends on [actions], exactly as the docs'
  /// markup does. With no actions the whole row is one `<a class="list-item">`
  /// and one control. With actions the row is a plain `<div>` and only the
  /// text is wrapped in an `<a>`, so that the actions are siblings of the link
  /// rather than controls nested inside one — which is both invalid HTML and,
  /// in a Flutter semantics tree, a node whose children can never be reached.
  final VoidCallback? onTap;

  /// Creates a content list row.
  const ItContentListItem({
    required this.text,
    this.description,
    this.leading,
    this.metadata,
    this.trailing,
    this.actions = const <ItListAction>[],
    this.onTap,
  });
}

/// Geometry and colour for `.it-list`.
abstract final class _ContentTokens {
  /// `.it-list-wrapper .it-list .list-item
  ///   { border-bottom: 1px solid hsl(210,4%,78%) }`
  ///
  /// The same rule carries `margin-top: -1px`, which exists so the CSS border
  /// boxes of adjacent rows overlap instead of stacking. Drawing one 1px line
  /// under each row reproduces what that renders.
  static const Color borderColor = Color(0xFFC5C7C9);

  /// `.it-list-wrapper .it-list .list-item .it-right-zone
  ///   { padding: 16px 0 16px 0 }`
  static const double zonePaddingY = 16;

  /// `.list-item .avatar, .it-rounded-icon, .it-thumb { margin-right: 16px }`
  static const double leadingGap = 16;

  /// `.it-right-zone svg { width: 24px; height: 24px }`
  static const double iconSize = 24;

  /// `.it-right-zone .it-multiple svg { margin-left: 16px }`
  static const double actionGap = 16;

  /// `.it-right-zone .text { font-size: 1rem; font-weight: 600 }`, and
  /// `@media (min-width: 992px) { … { font-size: 1.125rem } }`.
  static const double textSize = 16;
  static const double textSizeLg = 18;

  /// `.it-right-zone .text + p { font-size: .875rem; font-weight: 400 }`
  static const double descriptionSize = 14;

  /// `.it-right-zone .metadata { font-size: .75rem; letter-spacing: .5px }`
  static const double metadataSize = 12;
  static const double metadataTracking = 0.5;

  /// `.it-list-wrapper .it-list .list-item .it-rounded-icon { width: 40px }`,
  /// and `.it-thumb { width: 40px; height: 40px }`. `.avatar.size-lg` — the
  /// size the docs use in every list example — is 40px as well.
  static const double leadingBox = 40;

  /// Bootstrap Italia's `.icon` default, which is what sits inside the 40px
  /// `.it-rounded-icon` box.
  static const double roundedIconGlyph = 32;

  /// `.it-list-wrapper .it-list .list-item .it-rounded-icon svg
  ///   { fill: rgb(32.13, 123.165, 214.2) }`
  ///
  /// Stays a literal, and it is the more interesting of the two reasons in this
  /// file. The value is the kit's `.primary-color-a5` — one rung of the twelve
  /// step `primary-*-a1…a12` ladder whose sixth rung IS `--bs-primary`. So it is
  /// unmistakably *about* the brand blue, and yet it is not derivable from it
  /// with the tools this package has: `itShade` is a linear mix toward black,
  /// while this rung both lightens and desaturates — hsl(210,100%,40%) becomes
  /// hsl(210,73.9%,48.3%), which is neither an RGB mix with white nor an HSL
  /// `lighten()`. Byte-identical to no declared token, so by the rule this
  /// package uses it stays literal; deriving it with a formula that does not
  /// reproduce it would be worse than stating it.
  static const Color roundedIconColor = Color(0xFF207BD6);
}

/// Checks that every row and every action can be announced.
///
/// Both failures render perfectly and are invisible to a screenshot: a row with
/// blank text is a link with no name, and an action with a blank label is a
/// button announced as "button" and nothing else (WCAG 2.1 SC 4.1.2 Name, Role,
/// Value). Returns true so it can be the condition of a bare `assert`.
bool _debugNamesAreUsable(List<ItContentListItem> items) {
  for (final item in items) {
    assert(
      item.text.trim().isNotEmpty,
      'An ItContentListItem has a blank text, so a tappable row is announced '
      'as an unlabelled link (WCAG 2.1 SC 4.1.2 Name, Role, Value).',
    );
    for (final action in item.actions) {
      assert(
        action.label.trim().isNotEmpty,
        'An ItListAction on the row "${item.text}" has a blank label. It '
        'paints only a glyph, so this is a button announced as "button" and '
        'nothing else (WCAG 2.1 SC 4.1.2). Name the row as well as the action '
        '— "${item.text} - Scarica" — so that a page of rows does not give a '
        'screen reader a column of identically-named buttons.',
      );
    }
  }
  return true;
}

/// A Bootstrap Italia content list (`.it-list`).
///
/// The docs' *Tipologie di lista*, *Lista con azioni* and *Altre variazioni*:
/// rows of substantive content — an avatar or thumbnail, a title, an optional
/// paragraph, a metadata string, and per-row actions. Distinct from [ItList],
/// which is the same docs page's `.link-list`: a menu of links with no content
/// of its own. The two share a page and a `.list-item` class name and nothing
/// else — different padding, different type scale, different rules about what
/// is one control.
///
/// ```dart
/// ItContentList(
///   items: [
///     ItContentListItem(
///       leading: ItRoundedIcon(icon: BootstrapItaliaIcons.it_folder),
///       text: 'Documenti',
///       description: 'Lorem ipsum dolor sit amet.',
///       metadata: '12 file',
///       onTap: () {},
///     ),
///   ],
/// )
/// ```
class ItContentList extends StatelessWidget {
  /// The rows.
  final List<ItContentListItem> items;

  /// Creates a Bootstrap Italia content list.
  const ItContentList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // Validated here rather than inside each row: a row rebuilds on hover and
    // on every state change, and an assert that fires four times reports as
    // "multiple exceptions" instead of as the one problem it is. The list
    // builds once, so this says it once.
    assert(_debugNamesAreUsable(items));

    // Same reason as ItList: every Text below states its own font, but a host
    // with no Material at all still needs the ambient style declared once.
    return ItDefaultTextStyle(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items) _ItContentTile(item: item),
        ],
      ),
    );
  }
}

/// `.it-rounded-icon` — the icon form of a row's leading slot.
///
/// Despite the name, v2.18.0 declares **no** circle here: the only rules are a
/// 40px width and the glyph's fill. An earlier reading of the name added a
/// tinted disc that the stylesheet does not ask for.
class ItRoundedIcon extends StatelessWidget {
  /// The glyph.
  final IconData icon;

  /// Overrides the declared fill.
  final Color? color;

  /// Creates a rounded-icon leading slot.
  const ItRoundedIcon({super.key, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    // Decorative by construction. The row's own text names it, and the docs'
    // `<title>Cartella</title>` inside the SVG is a tooltip rather than a name
    // the row needs — announcing it would give the row two names.
    return ExcludeSemantics(
      child: SizedBox(
        width: _ContentTokens.leadingBox,
        height: _ContentTokens.leadingBox,
        child: Center(
          child: Icon(
            icon,
            size: _ContentTokens.roundedIconGlyph,
            color: color ?? _ContentTokens.roundedIconColor,
          ),
        ),
      ),
    );
  }
}

/// `.it-thumb` — the image form of a row's leading slot.
///
/// ```css
/// .it-list-wrapper .it-list .list-item .it-thumb { width: 40px; height: 40px }
/// .it-list-wrapper .it-list .list-item .it-thumb img
///   { object-fit: cover; width: 100%; height: 100% }
/// ```
///
/// Carries no semantics of its own: `object-fit: cover` is a layout instruction,
/// not a description. The docs' `<img alt="descrizione immagine">` is the
/// caller's to supply, on the [child] — an `Image` takes `semanticLabel`, and a
/// decorative one should say so with [ExcludeSemantics] rather than be silently
/// stripped here.
class ItListThumb extends StatelessWidget {
  /// The image, or anything else that should be cropped to the 40px box.
  final Widget child;

  /// Creates a thumbnail leading slot.
  const ItListThumb({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ContentTokens.leadingBox,
      height: _ContentTokens.leadingBox,
      child: ClipRect(
        child: FittedBox(fit: BoxFit.cover, child: child),
      ),
    );
  }
}

class _ItContentTile extends StatelessWidget {
  final ItContentListItem item;

  const _ItContentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    // `@media (min-width: 1200px) { .it-list-wrapper .it-list a.list-item:hover
    //   { … } }` — the whole-row hover only exists from `xl` up, and only for a
    // row that is a link. Below it, and for a row whose text alone is the link,
    // there is nothing to track.
    final width =
        MediaQuery.maybeSizeOf(context)?.width ?? ItBreakpoint.md.minWidth;
    final wholeRowLink = item.onTap != null && item.actions.isEmpty;
    final hoverable = wholeRowLink && width >= ItBreakpoint.xl.minWidth;

    return ItHoverBuilder(
      enabled: hoverable,
      cursor: item.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      builder: (context, hovered) => _build(context, hovered, width: width),
    );
  }

  Widget _build(BuildContext context, bool hovered, {required double width}) {
    final colors = resolveColorScheme(context);
    final isLink = item.onTap != null;

    // `a { color: var(--bs-link-color) }` with
    // `--bs-link-color: hsl(210,100%,40%)`, byte-identical to `--bs-primary`
    // and in the role the token names. A row that is not a link is body copy.
    //
    // `a.list-item:hover { color: rgb(0, 76.5, 153) }` = 0.75 x primary, so a
    // 25% shade; and `text-decoration: none`, which REMOVES the resting
    // underline rather than adding one — the opposite of what the `.link-list`
    // next door does on hover.
    final textColor = !isLink
        ? colors.bodyColor
        : hovered
            ? itShade(colors.primary, 0.25)
            : colors.primary;

    // `.it-list a .text { text-decoration: underline }`, dropped on hover.
    final decoration =
        isLink && !hovered ? TextDecoration.underline : TextDecoration.none;

    final textStyle = TextStyle(
      fontFamily: BootstrapItaliaFontFamily.sansSerif,
      package: BootstrapItaliaFontFamily.package,
      // `.text { font-size: 1rem }`, `1.125rem` from `lg` up.
      fontSize: width >= ItBreakpoint.lg.minWidth
          ? _ContentTokens.textSizeLg
          : _ContentTokens.textSize,
      fontWeight: FontWeight.w600,
      color: textColor,
      decoration: decoration,
      decorationColor: textColor,
    );

    // ── The `.it-right-zone`'s left half: text over description ──────────
    final textBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.text, style: textStyle),
        if (item.description != null)
          Text(
            item.description!,
            style: const TextStyle(
              fontFamily: BootstrapItaliaFontFamily.sansSerif,
              package: BootstrapItaliaFontFamily.package,
              fontSize: _ContentTokens.descriptionSize,
              fontWeight: FontWeight.w400,
              // `hsl(210,17%,44%)`. Referenced by the name the stylesheet also
              // gives it — `--bs-gray-secondary` — rather than written as a
              // literal or resolved from the scheme's `secondary`. It is the
              // same reasoning as the card date: an administration retinting
              // `secondary` wants its buttons recoloured, not its descriptions.
              // Naming the token constant says that once, where the value is
              // defined, instead of restating the hex here.
              color: BootstrapItaliaColors.graySecondary,
            ),
          ),
      ],
    );

    // ── Its right half: metadata, a single icon, or `.it-multiple` ───────
    final Widget? tail = _tail(context, colors);

    // `.it-right-zone { padding: 16px 0; flex-grow: 1; display: flex;
    //   justify-content: space-between; align-items: center }`
    final rightZone = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _ContentTokens.zonePaddingY,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: textBlock),
          if (tail != null) tail,
        ],
      ),
    );

    // `.list-item { display: flex; align-items: center;
    //   border-bottom: 1px solid hsl(210,4%,78%) }`
    final Widget row = DecoratedBox(
      decoration: BoxDecoration(
        // `a.list-item:hover { background: #fff;
        //   box-shadow: 0 2px 20px 0 rgba(0,0,0,.1) }` — the row lifts off the
        // page rather than tinting, which is why there is no fill at rest.
        color: hovered ? colors.white : null,
        boxShadow: hovered
            ? const [
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 2),
                  blurRadius: 20,
                ),
              ]
            : null,
        border: const Border(
          bottom: BorderSide(color: _ContentTokens.borderColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (item.leading != null) ...[
            item.leading!,
            const SizedBox(width: _ContentTokens.leadingGap),
          ],
          Expanded(child: rightZone),
        ],
      ),
    );

    if (!isLink) return row;

    // With actions present the row is a `<div>` and only the text is the link —
    // see [ItContentListItem.onTap]. Wrapping the whole row instead would make
    // the actions descendants of a link: a Flutter `Semantics` node with an
    // action swallows its subtree's controls, so the three buttons the docs
    // give distinct names would become unreachable.
    if (item.actions.isNotEmpty) return row;

    // §2.4.3 / §4.1.2: text and description are two text nodes in one link, so
    // they are merged into a single named node. The trailing chevron is
    // decoration and is excluded with them.
    return MergeSemantics(
      child: Semantics(
        link: true,
        label: item.description == null
            ? item.text
            : '${item.text}. ${item.description}',
        child: ItActivatable(
          onPressed: item.onTap,
          child: ExcludeSemantics(child: row),
        ),
      ),
    );
  }

  /// The right-hand end of `.it-right-zone`.
  Widget? _tail(BuildContext context, BootstrapItaliaColorScheme colors) {
    final metadata = item.metadata == null
        ? null
        : Text(
            item.metadata!,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: BootstrapItaliaFontFamily.sansSerif,
              package: BootstrapItaliaFontFamily.package,
              fontSize: _ContentTokens.metadataSize,
              letterSpacing: _ContentTokens.metadataTracking,
              fontWeight: FontWeight.w400,
              // `hsl(210,17%,44%)` again — see the description above.
              color: BootstrapItaliaColors.graySecondary,
            ),
          );

    if (item.actions.isEmpty) {
      // `.it-right-zone svg { fill: #06c; width: 24px; height: 24px }` — the
      // single trailing glyph follows the primary token.
      final trailing = item.trailing == null
          ? null
          : IconTheme.merge(
              data: IconThemeData(
                color: colors.primary,
                size: _ContentTokens.iconSize,
              ),
              child: ExcludeSemantics(child: item.trailing!),
            );
      if (metadata == null && trailing == null) return null;
      if (metadata != null && trailing != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            metadata,
            const SizedBox(width: _ContentTokens.actionGap),
            trailing,
          ],
        );
      }
      return metadata ?? trailing;
    }

    // `.it-multiple { display: flex; justify-content: flex-end;
    //   flex-wrap: wrap }` with `.it-multiple .metadata { width: 100%;
    //   text-align: right }` — a metadata string inside the group claims a full
    // line, so the wrap pushes the icons onto the next one. A Column with
    // right-aligned children is what that lays out.
    final icons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final action in item.actions) ...[
          const SizedBox(width: _ContentTokens.actionGap),
          _ItListActionButton(action: action),
        ],
      ],
    );

    if (metadata == null) return icons;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [metadata, icons],
    );
  }
}

/// One `.it-multiple` icon button.
class _ItListActionButton extends StatelessWidget {
  final ItListAction action;

  const _ItListActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return ItHoverBuilder(
      enabled: action.onPressed != null,
      cursor: action.onPressed == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      builder: (context, hovered) => Semantics(
        button: true,
        enabled: action.onPressed != null,
        label: action.label,
        child: ItActivatable(
          onPressed: action.onPressed,
          child: ExcludeSemantics(
            child: Icon(
              action.icon,
              size: _ContentTokens.iconSize,
              // `.it-right-zone svg { fill: #06c }`, and
              // `span.it-multiple a:hover svg { fill: #036 }` = 0.5 x primary.
              color: hovered ? itShade(colors.primary, 0.5) : colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
