import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';

/// Shared geometry and colour tokens for the Bootstrap Italia `.it-card`.
///
/// Values are taken from the compiled `bootstrap-italia.min.css`
/// (`--bs-it-card-*` custom properties) so every sub-widget stays in sync.
/// Card measurements and colours, quoted from `bootstrap-italia.min.css` 2.18.0.
///
/// On which of these re-theme: v2.18.0 resolves its semantic tokens to literals
/// at build time — `var(--bs-primary)` appears zero times in the whole
/// stylesheet — so "does the CSS derive this from a token?" answers no for
/// every value here and is the wrong question. The test applied instead is
/// semantic identity: a value re-themes when it is byte-identical to a declared
/// palette token AND sits in a role where that token is what is meant.
///
/// Only [linkColor] passes both. In particular [metaColor] is byte-identical to
/// `--bs-secondary` and still does not move, because `hsl(210, 17%, 44%)` is
/// also declared as `--bs-gray-secondary`, and on a category or a date it is
/// the neutral grey that is meant. An administration retinting `secondary` to
/// purple wants its buttons purple, not its publication dates.
abstract final class _CardTokens {
  /// `--bs-it-card-spacer-x: 1rem`
  static const double spacerX = 16;

  /// `--bs-it-card-spacer-y: 0.5rem`
  static const double spacerY = 8;

  /// `.it-card { padding-bottom: 8px }` (computed)
  static const double paddingBottom = 8;

  /// `--bs-it-card-border-color: hsl(210, 4%, 78%)`
  static const Color borderColor = Color(0xFFC5C7C9);

  /// `--bs-it-card-color` / `--bs-it-card-p-color`: hsl(210, 33%, 28%)
  static const Color textColor = Color(0xFF30475F);

  /// `--bs-it-card-category-color` / `--bs-it-card-date-color`:
  /// hsl(210, 17%, 44%)
  static const Color metaColor = Color(0xFF5D7083);

  /// Hover colour of a linked category, `hsl(210, 17%, 35.2%)` — Bootstrap's
  /// 20% shade applied to the HSL lightness. Measured on the React kit as
  /// `rgb(75, 90, 105)` for both hover and press; a linear RGB mix would give
  /// `rgb(74, 90, 105)`, so the literal is used.
  static const Color metaHoverColor = Color(0xFF4B5A69);

  /// The link colour of a tappable card's title.
  ///
  /// This is `--bs-primary` (`hsl(210, 100%, 40%)` = #0066CC) and it is the one
  /// colour in this class that re-themes. Note that `--bs-it-card-link-color`
  /// is a DIFFERENT and misleading-looking variable: it resolves to
  /// `hsl(210, 33%, 28%)` and governs `.it-card-link`, the footer links — not
  /// the title anchor. Reading that variable and concluding the title is
  /// #30475F would be wrong. Confirmed against the reference capture, which
  /// contains 12,974 pixels of exactly rgb(0, 102, 204) in the title band.
  ///
  /// Kept as a function rather than a `static const` precisely so it cannot be
  /// used without a context, which is how it came to be hardcoded.
  static Color linkColor(BuildContext context) =>
      resolveColorScheme(context).primary;

  /// `.shadow-sm { box-shadow: 0 .125rem .25rem rgba(0,0,0,.075) }`
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x13000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// `--bs-it-card-border-top-width: 6px`
  static const double borderTopWidth = 6;
}

/// A Bootstrap Italia card component.
///
/// A flexible content container with optional image, title, body, footer
/// category and date, mirroring the `.it-card` markup of the design system.
///
/// ```dart
/// ItCard(
///   title: 'Titolo del contenuto',
///   body: Text('Descrizione del contenuto.'),
///   category: ItCardCategory(label: 'Categoria'),
///   date: '22 aprile 2025',
///   onTap: () {},
/// )
/// ```
class ItCard extends StatelessWidget {
  /// Optional image at the top of the card.
  final Widget? image;

  /// Optional category label, shown in the footer's taxonomy zone.
  final ItCardCategory? category;

  /// The card title.
  final String? title;

  /// A glyph shown at the **end** of the title row — `.it-card-title-icon`.
  ///
  /// ```css
  /// .it-card .it-card-title.it-card-title-icon {
  ///   display: flex; flex-direction: row; justify-content: space-between }
  /// @supports (gap: 0.5rem) {
  ///   .it-card .it-card-title.it-card-title-icon { gap: 0.5rem } }
  /// .it-card .it-card-title.it-card-title-icon .it-card-title-icon-wrapper {
  ///   margin-left: 0.5rem }
  /// ```
  ///
  /// Trailing, not leading — `space-between` pushes it to the far edge, and the
  /// wrapper's margin is on its *left*. Getting that backwards is easy: every
  /// other icon slot in this package leads.
  ///
  /// «Card per media» and «Card per documenti e allegati» use it to mark what
  /// the card links to — a video, an audio file, a PDF. Where the glyph carries
  /// that meaning and the text does not, say it in the text as well: «Accessibilità:
  /// valore semantico delle icone» is unambiguous that an icon alone does not
  /// reach a screen reader, and this one is excluded from the semantics tree.
  final IconData? titleIcon;

  /// The heading level [title] announces as, 1–6.
  ///
  /// The docs give this two sections of its own — «Accessibilità titoli» and
  /// «Gerarchia dei titoli» — because a card's title is a heading in the page
  /// outline, and which level depends on where the card sits, not on what a card
  /// is. A grid of cards under an `h2` section heading wants `h3`; the same card
  /// under an `h3` wants `h4`.
  ///
  /// Defaults to 3, matching both the level the kit's own examples use most and
  /// the `h3` typography this widget already paints (2rem / 2.5rem, weight 700).
  /// The visual size does NOT follow this parameter — Bootstrap Italia separates
  /// the two deliberately, which is what its `.h1`…`.h6` classes are for.
  ///
  /// Before this existed the title carried no heading role at all: a page of
  /// cards was a flat run of text to anyone navigating by headings, which is a
  /// §1.3.1 Info and Relationships failure and one that no automated checker
  /// reports, because nothing is *wrong* — something is merely absent.
  final int titleHeadingLevel;

  /// Optional subtitle below the title.
  final String? subtitle;

  /// The card body content.
  final Widget? body;

  /// Optional signature/author text.
  final String? signature;

  /// Optional date, shown at the right of the footer.
  final String? date;

  /// Optional extra footer content, shown at the right of the footer.
  final Widget? footer;

  /// Optional coloured top border.
  final Color? borderTopColor;

  /// Whether to use horizontal layout (image left, content right).
  final bool horizontal;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Custom padding for the card body area.
  final EdgeInsetsGeometry? padding;

  /// Overrides the accessible name of a tappable card.
  ///
  /// Only consulted when [onTap] is set. Use it when the card's visible text
  /// would not make sense read on its own — an image-led card whose title is
  /// "Leggi di piu", say, which tells a screen-reader user nothing about where
  /// the link goes (WCAG §2.4.4 Link Purpose).
  final String? semanticLabel;

  /// Creates a Bootstrap Italia card.
  const ItCard({
    super.key,
    this.image,
    this.category,
    this.title,
    this.titleIcon,
    this.titleHeadingLevel = 3,
    this.subtitle,
    this.body,
    this.signature,
    this.date,
    this.footer,
    this.borderTopColor,
    this.horizontal = false,
    this.onTap,
    this.padding,
    this.semanticLabel,
  }) : assert(
          titleHeadingLevel >= 1 && titleHeadingLevel <= 6,
          'ItCard: titleHeadingLevel must be 1–6. HTML has six heading levels '
          'and Flutter asserts the same range; pick the one that fits the '
          'page outline where this card is used.',
        );

  bool get _hasFooter => category != null || date != null || footer != null;

  /// The accessible name of a tappable card: the visible text, in reading
  /// order, joined into the single name the whole control announces.
  ///
  /// Empty when the card carries none of these slots — `ItCard(body: ..., onTap:
  /// ...)` is entirely legal and was producing a focusable button announced as
  /// nothing at all. [build] falls back to the merged descendants in that case,
  /// so the body text becomes the name rather than the name being blank.
  String get _stringSlotName => <String?>[
        title,
        subtitle,
        signature,
        date,
      ].whereType<String>().where((s) => s.isNotEmpty).join('. ');

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(
          color: _CardTokens.borderColor,
          width: BootstrapItaliaBorders.width,
        ),
        borderRadius: BorderRadius.circular(BootstrapItaliaBorders.radius),
        boxShadow: _CardTokens.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: horizontal ? _buildHorizontal(context) : _buildVertical(context),
    );

    // A non-tappable card is plain content: leave its text as separate nodes so
    // a screen reader can still read and navigate it normally.
    if (onTap == null) return card;

    // §4.1.2 requires a control to have a name. A card built only from widget
    // slots has no string to take one from, and there is no way to read text out
    // of an arbitrary `Widget` at build time — so the only honest options are to
    // harvest it from the rendered subtree, or to fail loudly. This does both:
    // it harvests where a subtree exists, and asserts where provably nothing
    // could be harvested.
    final name = semanticLabel ?? _stringSlotName;
    assert(
      name.isNotEmpty || body != null || footer != null || category != null,
      'A tappable ItCard has no accessible name. This card sets onTap but none '
      'of title, subtitle, signature, date, body, footer or category, so screen '
      'readers announce an unlabelled button (WCAG 2.1 SC 4.1.2 Name, Role, '
      'Value). Pass semanticLabel: to name it — an image-only card in '
      'particular must be named explicitly, since its alt text cannot be '
      'reached from here.',
    );

    // §2.4.3 Focus Order / §4.1.2: a tappable card is ONE control. Without
    // merging, AT walks title, subtitle, body, category and date as separate
    // stops with no indication any of them activate anything. MergeSemantics
    // collapses them into a single focusable node carrying one name, and
    // ItActivatable makes that node keyboard-operable (§2.1.1).
    return MergeSemantics(
      child: Semantics(
        button: true,
        // With an explicit label the descendants must be excluded, or the merge
        // appends them to it and the name is said twice. With no label they are
        // exactly what the name has to come from, so they stay in the tree and
        // MergeSemantics concatenates them in reading order.
        label: name.isEmpty ? null : name,
        child: ItActivatable(
          onPressed: onTap,
          borderRadius: BorderRadius.circular(BootstrapItaliaBorders.radius),
          child: name.isEmpty ? card : ExcludeSemantics(child: card),
        ),
      ),
    );
  }

  Widget _buildVertical(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (borderTopColor != null)
          Container(height: _CardTokens.borderTopWidth, color: borderTopColor),
        if (image != null) image!,
        ..._content(context),
      ],
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image != null) SizedBox(width: 160, child: image!),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _content(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context) {
    return [
      if (title != null)
        Padding(
          // `.it-card .it-card-title { margin-top: calc(2 * spacer-y);
          //   margin-bottom: 0; padding: 0 spacer-x }`
          padding: const EdgeInsets.fromLTRB(
            _CardTokens.spacerX,
            2 * _CardTokens.spacerY,
            _CardTokens.spacerX,
            0,
          ),
          // §1.3.1 Info and Relationships: the card title heads the card's
          // content, so it is a heading — see [titleHeadingLevel].
          child: Semantics(
            header: true,
            headingLevel: titleHeadingLevel,
            child: Row(
              // `.it-card-title.it-card-title-icon { display: flex;
              //   justify-content: space-between }` — the glyph goes to the far
              // end. With no glyph this is a one-child Row, which lays out
              // identically to the bare Text it replaced.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontFamily: BootstrapItaliaFontFamily.sansSerif,
                      package: BootstrapItaliaFontFamily.package,
                      // The design kit renders the card title as an <h3>:
                      // 2rem / 2.5rem, weight 700 at >= 576px.
                      fontSize: 32,
                      height: 40 / 32,
                      fontWeight: FontWeight.w700,
                      // A tappable card renders its title as a link: `a`
                      // inherits Bootstrap's underlined link styling and the
                      // primary link colour. The non-tappable title is body
                      // text, not a link, so it keeps the literal #30475F and
                      // does NOT re-theme.
                      color: onTap != null
                          ? _CardTokens.linkColor(context)
                          : _CardTokens.textColor,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: _CardTokens.linkColor(context),
                    ),
                  ),
                ),
                if (titleIcon != null) ...[
                  // `gap: 0.5rem`, plus `.it-card-title-icon-wrapper
                  // { margin-left: 0.5rem }`.
                  const SizedBox(width: _CardTokens.spacerY),
                  ExcludeSemantics(
                    child: Icon(
                      titleIcon,
                      // `.icon.icon-sm { width: 24px; height: 24px }`, the size
                      // the media and document cards mark their type with.
                      size: 24,
                      color: onTap != null
                          ? _CardTokens.linkColor(context)
                          : _CardTokens.textColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      if (subtitle != null || body != null || signature != null)
        ItCardBody(
          subtitle: subtitle,
          signature: signature,
          padding: padding,
          child: body,
        ),
      if (_hasFooter)
        Padding(
          // `.it-card .it-card-footer { margin: 0 cap-padding-x }` — the
          // horizontal inset is a margin on the footer, not padding, so it
          // lives outside ItCardFooter's own box.
          padding: const EdgeInsets.symmetric(horizontal: _CardTokens.spacerX),
          child: ItCardFooter(category: category, date: date, trailing: footer),
        ),
      SizedBox(
        height:
            _hasFooter ? _CardTokens.paddingBottom : 2 * _CardTokens.spacerY,
      ),
    ];
  }
}

/// The content zone of an [ItCard] (`.it-card-body`).
class ItCardBody extends StatelessWidget {
  /// Optional subtitle shown above [child].
  final String? subtitle;

  /// Optional signature/author text shown below [child].
  final String? signature;

  /// Overrides the default `.it-card-body` padding.
  final EdgeInsetsGeometry? padding;

  /// The body content.
  ///
  /// Stays `child` rather than joining the `body` slots on [ItAlert],
  /// [ItCallout] and [ItModal]: those name the content that sits *beside* a
  /// title the widget also renders, whereas this widget is itself the body
  /// zone — `ItCardBody(body: …)` would say it twice. [ItCard.body] is the
  /// slot callers normally reach for.
  final Widget? child;

  /// Creates a Bootstrap Italia card body.
  const ItCardBody({
    super.key,
    this.subtitle,
    this.signature,
    this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    // `.it-card .it-card-body { padding: spacer-y spacer-x }`
    final effectivePadding = padding ??
        const EdgeInsets.symmetric(
          horizontal: _CardTokens.spacerX,
          vertical: _CardTokens.spacerY,
        );

    return Padding(
      padding: effectivePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle!,
              // `.it-card-subtitle { margin-bottom: spacer-y; font-weight: 600;
              //   font-size: 1.25rem; line-height: 1.5rem }`
              style: const TextStyle(
                fontFamily: BootstrapItaliaFontFamily.sansSerif,
                package: BootstrapItaliaFontFamily.package,
                fontSize: 20,
                height: 24 / 20,
                fontWeight: FontWeight.w600,
                color: _CardTokens.textColor,
              ),
            ),
            const SizedBox(height: _CardTokens.spacerY),
          ],
          if (child != null)
            DefaultTextStyle.merge(
              // `.it-card-text { font-size: 1rem; line-height: 1.5rem;
              //   color: var(--bs-it-card-p-color) }`
              style: const TextStyle(
                fontFamily: BootstrapItaliaFontFamily.sansSerif,
                package: BootstrapItaliaFontFamily.package,
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w400,
                color: _CardTokens.textColor,
              ),
              child: child!,
            ),
          if (signature != null) ...[
            const SizedBox(height: _CardTokens.spacerY),
            Text(
              signature!,
              // `.it-card-signature { font-family: "Roboto Mono";
              //   font-size: var(--bs-it-card-signature-size) }`
              style: const TextStyle(
                fontFamily: BootstrapItaliaFontFamily.monospace,
                package: BootstrapItaliaFontFamily.package,
                fontSize: 16,
                height: 24 / 16,
                color: _CardTokens.textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The footer zone of an [ItCard] (`footer.it-card-related.it-card-footer`).
///
/// Lays the taxonomy zone (typically an [ItCardCategory]) on the left and the
/// date / trailing content on the right.
class ItCardFooter extends StatelessWidget {
  /// Left-hand taxonomy zone, usually an [ItCardCategory].
  final Widget? category;

  /// Right-hand date text.
  final String? date;

  /// Extra right-hand content, shown after [date].
  final Widget? trailing;

  /// Creates a Bootstrap Italia card footer.
  const ItCardFooter({
    super.key,
    this.category,
    this.date,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // `footer.it-card-related.it-card-footer {
      //    padding: calc(cap-padding-y * .5) 0 cap-padding-y;
      //    border-top: none }`
      // with `--bs-it-card-cap-padding-y: calc(spacer-y * 2)` = 16px. The
      // horizontal inset is a margin applied by [ItCard], not padding.
      padding: const EdgeInsets.only(
        top: _CardTokens.spacerY,
        bottom: 2 * _CardTokens.spacerY,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // `.it-card footer .it-card-taxonomy { flex-grow: 1 }`
          Expanded(child: category ?? const SizedBox.shrink()),
          if (date != null)
            // Flexible, because a date is not always short. «Accessibilità date
            // e orari eventi» asks for them spelled out — "martedì 22 aprile
            // 2025, ore 10:30", not "22/04" — and a spelled-out date beside a
            // category overflowed a phone-width card by 140px. The date wraps
            // now rather than running off the edge.
            Flexible(
              // Right-aligned INSIDE its share. `Expanded` and `Flexible` are
              // both flex children, so Flutter splits the row equally between
              // them rather than letting the category's `flex-grow: 1` push the
              // date to the edge as CSS does — which left the date sitting at
              // the 50% mark and took this capture to 89.5%. Aligning within
              // the half puts it back on the right edge, because the two halves
              // tile the full width, while keeping the shrink that stops a
              // spelled-out date running off a phone-width card.
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  date!,
                  // `.it-card-date { color: hsl(210,17%,44%);
                  //   font-size: 0.875rem }`
                  style: const TextStyle(
                    fontFamily: BootstrapItaliaFontFamily.sansSerif,
                    package: BootstrapItaliaFontFamily.package,
                    fontSize: 14,
                    height: 24 / 14,
                    fontWeight: FontWeight.w400,
                    color: _CardTokens.metaColor,
                  ),
                ),
              ),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A category label for [ItCard].
///
/// Displays an uppercase styled text label inside the card footer.
class ItCardCategory extends StatelessWidget {
  /// The category text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the category is tapped. When set the label renders as a
  /// link (underlined), matching `a.it-card-category.it-card-link`.
  final VoidCallback? onTap;

  /// Creates a card category label.
  const ItCardCategory({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return _label(_CardTokens.metaColor);
    // A tappable category is a link, so it needs a role, an accessible name and
    // keyboard operability. It was previously a bare GestureDetector: reachable
    // by pointer only, and invisible to focus traversal (WCAG 2.1.1 Keyboard,
    // 2.4.4 Link Purpose, 4.1.2 Name/Role/Value).
    //
    // NOTE: when this sits inside a tappable ItCard, the card's MergeSemantics
    // collapses it into the card's single node — one control, one name, which is
    // the correct reading of 2.4.3. Nesting two independent tap targets is an
    // authoring conflict, not something this widget can resolve.
    return Semantics(
      link: true,
      label: label,
      child: ItActivatable(
        onPressed: onTap,
        borderRadius: BorderRadius.zero,
        child: ItHoverBuilder(
          cursor: SystemMouseCursors.click,
          builder: (context, hovered) => _label(
            hovered ? _CardTokens.metaHoverColor : _CardTokens.metaColor,
          ),
        ),
      ),
    );
  }

  Widget _label(Color color) {
    final text = Text(
      label.toUpperCase(),
      // `.it-card footer .it-card-category { text-transform: uppercase;
      //   color: hsl(210,17%,44%); font-size: 1rem; font-weight: 600;
      //   letter-spacing: 0.5px }`
      style: TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color,
        decoration:
            onTap != null ? TextDecoration.underline : TextDecoration.none,
        decorationColor: color,
      ),
    );

    if (icon == null) return text;

    // A Wrap, not a Row. An uppercase category beside its glyph is a flex item,
    // and a flex item's main axis is unbounded, so a `Row` sized the label to
    // its natural width and ran it past the card's edge — 52px on a phone.
    //
    // `Flexible` would fix that and needs a bounded width, which a category
    // used outside the footer may not have; a `LayoutBuilder` guard would
    // supply the bound and cost more than it is worth, because a LayoutBuilder
    // cannot answer intrinsic queries, and `IntrinsicHeight` around a row of
    // cards — the way «Altezze delle card» equalises them — is exactly what
    // asks. A Wrap has neither problem: it passes its own width down, so the
    // label wraps, and it answers intrinsics.
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      // `.it-card-category .icon { margin-right: 4px }`
      spacing: 4,
      children: [Icon(icon, size: 16, color: color), text],
    );
  }
}
