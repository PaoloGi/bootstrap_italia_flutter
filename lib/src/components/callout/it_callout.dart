import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/typography.dart';
import '../collapse/it_collapse.dart';

/// Color variants for [ItCallout].
///
/// Matches Bootstrap Italia's `_callout.scss` variants: the base callout has
/// no colour modifier, and `success` / `warning` / `danger` / `important` /
/// `note` recolour the border, title and icon.
enum ItCalloutVariant {
  /// Default callout — grey-blue border, dark blue-grey title.
  neutral,

  /// Green success callout.
  success,

  /// Orange warning callout.
  warning,

  /// Red danger callout.
  danger,

  /// Green important callout (uses the success colour).
  important,

  /// Blue note callout (uses the primary colour).
  note,
}

/// The three shapes a callout can take.
///
/// Orthogonal to [ItCalloutVariant], which only chooses the accent. These
/// change the box itself, and the docs give each one its own H2.
enum ItCalloutStyle {
  /// `.callout` + `.callout-inner` — the default: a 2px box on all four sides.
  ///
  /// ```css
  /// .callout .callout-inner { padding: 1.5rem;
  ///                           border: 2px solid hsl(210, 17%, 44%);
  ///                           margin: 2rem 0 }
  /// ```
  standard,

  /// `.callout-highlight` — a rule down the left edge instead of a box.
  ///
  /// ```css
  /// .callout.callout-highlight { border: none;
  ///                              border-left: 2px solid hsl(210, 17%, 44%);
  ///                              border-radius: 0;
  ///                              padding: 0 1.5rem }
  /// ```
  ///
  /// Note the markup difference the CSS implies and the docs confirm: a
  /// highlight callout has **no** `.callout-inner`. The border and padding move
  /// onto the outer element, so the vertical padding disappears entirely — the
  /// text starts at the top of the rule.
  highlight,

  /// `.callout-more` — the *Approfondimento*, for long-form text.
  ///
  /// ```css
  /// .callout.callout-more { background: #f9f9f5; border: none;
  ///                         border-radius: 0; padding: 2.222rem;
  ///                         position: relative }
  /// .callout.callout-more p { font-size: 1rem; line-height: 1.5rem;
  ///                           color: hsl(210, 33%, 28%) }
  /// ```
  ///
  /// Two things about it are easy to miss. Its body text is **not** the Lora
  /// 18px the other two styles use — it drops to 16px sans, because the style
  /// exists for text long enough that the serif face would tire. And its
  /// disclosure sits at the *bottom*, under a rule, as a "Leggi tutto" toggle:
  /// see [moreContent]. That is a different control from [collapsible], which
  /// folds the whole body away from the title and appears nowhere in the docs.
  more,
}

/// A Bootstrap Italia callout component.
///
/// Highlights important information inside a 2px coloured border, with an
/// optional uppercase title and icon. Can be made collapsible.
///
/// ```dart
/// ItCallout(
///   variant: ItCalloutVariant.success,
///   title: 'Nota bene',
///   body: Text('Testo importante da evidenziare.'),
/// )
/// ```
class ItCallout extends StatefulWidget {
  /// The callout colour variant.
  final ItCalloutVariant variant;

  /// The shape of the box — see [ItCalloutStyle].
  final ItCalloutStyle style;

  /// Optional title text. Rendered uppercase, as Bootstrap Italia does.
  final String? title;

  /// Extra content revealed by the *Leggi tutto* toggle of an
  /// [ItCalloutStyle.more] callout.
  ///
  /// ```html
  /// <div class="collapse-div">
  ///   <div class="collapse-header">
  ///     <button class="callout-more-toggle" aria-expanded="false"
  ///             aria-controls="collapse1">Leggi tutto <span></span></button>
  ///     <a class="callout-more-download" href="#">…Download</a>
  ///   </div>
  ///   <div class="collapse" id="collapse1"><div class="collapse-body">…</div></div>
  /// </div>
  /// ```
  ///
  /// Only [ItCalloutStyle.more] renders it — the other two styles have no
  /// collapse in the docs, and the CSS puts every `.callout-more-toggle` rule
  /// behind `.callout .collapse-div .collapse-header`.
  final Widget? moreContent;

  /// Label of the *Leggi tutto* toggle.
  ///
  /// Content rather than chrome: the docs' own example says «Leggi tutto», but
  /// what is being read is the author's to name, so it is not in
  /// [ItLocalizations] — the same reasoning as [ItBadge.semanticLabel].
  final String moreLabel;

  /// Optional download link beside the toggle (`.callout-more-download`).
  ///
  /// The docs pair the toggle with a document link, and prefix its name with a
  /// hidden format: `<span class="visually-hidden">PDF </span>Download`. Say the
  /// format and, where you can, the size — a link named just "Download" tells a
  /// screen-reader user nothing about what it fetches (§2.4.4 Link Purpose).
  final String? downloadLabel;

  /// Called when [downloadLabel] is activated.
  final VoidCallback? onDownload;

  /// Whether the callout body is collapsible.
  ///
  /// Not from the docs, and not the same control as [moreContent]: this folds
  /// the whole body away behind the title. Kept because it predates this pass
  /// and callers rely on it; prefer [moreContent] when reproducing
  /// «Callout Approfondimento».
  final bool collapsible;

  /// Whether a collapsible callout starts expanded.
  final bool initiallyExpanded;

  /// Whether to show the variant icon next to the title.
  final bool showIcon;

  /// The callout content, rendered beneath [title] (`.callout-text`).
  final Widget body;

  /// Creates a Bootstrap Italia callout.
  const ItCallout({
    super.key,
    this.variant = ItCalloutVariant.neutral,
    this.style = ItCalloutStyle.standard,
    this.title,
    this.moreContent,
    this.moreLabel = 'Leggi tutto',
    this.downloadLabel,
    this.onDownload,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.showIcon = true,
    required this.body,
  }) : assert(
          moreContent == null || style == ItCalloutStyle.more,
          'ItCallout: `moreContent` is the "Leggi tutto" disclosure of a '
          '.callout-more, and the stylesheet defines .callout-more-toggle only '
          'inside one. Pass `style: ItCalloutStyle.more`, or use `collapsible` '
          'to fold the body from the title instead.',
        );

  @override
  State<ItCallout> createState() => _ItCalloutState();
}

class _ItCalloutState extends State<ItCallout> {
  // `.callout .callout-inner { padding: 1.5rem; border: 2px solid ... }`
  static const double _padding = 24;
  static const double _borderWidth = 2;

  // `.callout .callout-title { margin-bottom: 1rem }`
  static const double _titleGap = 16;

  // `.callout .callout-title .icon { margin-right: .5rem }` and the shared
  // `.icon` sizing (32x32).
  static const double _iconSize = 32;
  static const double _iconGap = 8;

  // `.callout .callout-title` / `.callout p` colour: hsl(210, 33%, 28%).
  // Not available as a theme token, so it is taken straight from the CSS.
  static const Color _defaultText = Color(0xFF30475F);

  // `.callout.callout-more { background: #f9f9f5; padding: 2.222rem }` — a warm
  // off-white that is in no palette; the folded corner is `#e4e4db`, likewise.
  static const Color _moreBackground = Color(0xFFF9F9F5);
  static const Color _moreFoldShadow = Color(0xFFE4E4DB);
  static const double _morePadding = 2.222 * 16;

  // `.callout.callout-more:before,:after { border-width: 0 48px 48px 0 } /
  // { border-width: 48px 0 0 48px }` — the two CSS triangles that fake the
  // dog-ear.
  static const double _moreFoldSize = 48;

  // `.callout .collapse-div .collapse-header { border-top: 1px solid
  //   hsl(210, 3%, 85%); padding: 1.333rem 0 0 }`
  static const Color _collapseRule = Color(0xFFD8D9DA);
  static const double _collapseHeaderGap = 1.333 * 16;

  // `.callout .collapse-div .collapse-header .callout-more-toggle span
  //   { height: 15px; width: 15px; margin-left: .444rem; border: 1px solid;
  //     border-radius: 50% }`
  static const double _toggleGlyphSize = 15;
  static const double _toggleGlyphGap = 0.444 * 16;

  late bool _expanded;

  /// Whether the *Leggi tutto* disclosure is open. Separate from [_expanded],
  /// which belongs to the (non-docs) whole-body [ItCallout.collapsible].
  bool _moreExpanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.collapsible ? widget.initiallyExpanded : true;
  }

  /// The accent used for the border, title and icon.
  ///
  /// `.callout.<variant>` recolours the callout with the semantic palette;
  /// the un-modified callout uses the secondary grey-blue.
  static Color _accent(
    ItCalloutVariant variant,
    BootstrapItaliaColorScheme colors,
  ) {
    return switch (variant) {
      // rgb(0, 127.5, 85)
      ItCalloutVariant.success || ItCalloutVariant.important => colors.success,
      // rgb(153, 91.8, 0)
      ItCalloutVariant.warning => colors.warning,
      // rgb(204, 51, 76.5)
      ItCalloutVariant.danger => colors.danger,
      // #06c
      ItCalloutVariant.note => colors.primary,
      // hsl(210, 17%, 44%)
      ItCalloutVariant.neutral => colors.secondary,
    };
  }

  /// The title text, and — on `.callout-more` — the rule drawn under it.
  Widget _titleText({
    required bool isMore,
    required Color titleColor,
    required Color ruleColor,
  }) {
    final text = Text(
      // `.callout-more` does not uppercase its title: «Approfondimento» is set
      // as written, unlike the standard callout's `text-transform: uppercase`.
      isMore ? widget.title! : widget.title!.toUpperCase(),
      style: TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        // 1.125rem / 1.5 at >= 992px
        fontSize: 18,
        height: 27 / 18,
        fontWeight: FontWeight.w600,
        color: titleColor,
      ),
    );
    if (!isMore) return text;

    // `.callout.callout-more .callout-title span { border-bottom: 2px solid
    //   hsl(0, 0%, 10%); padding-bottom: .1rem; display: inline-block }`,
    // recoloured per variant by `.callout.<variant> .callout-title span
    //   { border-color: … }`. `hsl(0, 0%, 10%)` is `--bs-body-color` byte for
    // byte, in a role — a rule under running text — where the body ink is what
    // is meant, so it follows the theme.
    //
    // `display: inline-block` is why the Align is here: the rule is as wide as
    // the words, not as wide as the callout. Without it the border would run
    // the full content width and read as a section divider.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.only(bottom: 0.1 * 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ruleColor, width: _borderWidth),
          ),
        ),
        child: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variant = widget.variant;
    final colors = resolveColorScheme(context);
    final borderColor = _accent(variant, colors);
    // The un-modified callout keeps the neutral text colour even though its
    // border is grey-blue; coloured variants tint the title too.
    final titleColor =
        variant == ItCalloutVariant.neutral ? _defaultText : borderColor;
    final isMore = widget.style == ItCalloutStyle.more;

    Widget box = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isMore ? _moreBackground : null,
        // `.callout.callout-highlight { border: none; border-left: 2px solid }`
        // and `.callout.callout-more { border: none }`. The 2px box belongs to
        // `.callout-inner`, which only the standard style has.
        border: switch (widget.style) {
          ItCalloutStyle.standard =>
            Border.all(color: borderColor, width: _borderWidth),
          ItCalloutStyle.highlight =>
            Border(left: BorderSide(color: borderColor, width: _borderWidth)),
          ItCalloutStyle.more => null,
        },
      ),
      // `.callout-highlight { padding: 0 1.5rem }` — horizontal only, so its
      // first line sits level with the top of the rule; `.callout-more` pads
      // 2.222rem all round.
      padding: switch (widget.style) {
        ItCalloutStyle.standard => const EdgeInsets.all(_padding),
        ItCalloutStyle.highlight =>
          const EdgeInsets.symmetric(horizontal: _padding),
        ItCalloutStyle.more => const EdgeInsets.all(_morePadding),
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) ...[
            // §1.3.1: the callout title heads its content, so it is a heading.
            // When collapsible it is *also* the disclosure button, and §4.1.2
            // requires the expanded state; §2.1.1 requires it be operable from
            // the keyboard, which the bare GestureDetector was not.
            Semantics(
              header: true,
              headingLevel: 3,
              button: widget.collapsible,
              expanded: widget.collapsible ? _expanded : null,
              label: widget.title,
              child: ItActivatable(
                onPressed: widget.collapsible
                    ? () => setState(() => _expanded = !_expanded)
                    : null,
                showFocusRing: widget.collapsible,
                child: ExcludeSemantics(
                  child: Row(
                    children: [
                      // The variant glyph duplicates information already in the
                      // title and border colour; announcing it would be noise.
                      if (widget.showIcon) ...[
                        Icon(_icon(variant),
                            size: _iconSize, color: titleColor),
                        const SizedBox(width: _iconGap),
                      ],
                      Expanded(
                        child: _titleText(
                          isMore: isMore,
                          titleColor: titleColor,
                          ruleColor: variant == ItCalloutVariant.neutral
                              ? colors.bodyColor
                              : titleColor,
                        ),
                      ),
                      if (widget.collapsible)
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            BootstrapItaliaIcons.it_expand,
                            color: titleColor,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // `.callout .callout-title { margin-bottom: 1rem }`, which
            // `.callout.callout-more .callout-title` raises to 2.222rem.
            SizedBox(height: isMore ? _morePadding : _titleGap),
          ],
          ItCollapse(
            isExpanded: _expanded,
            child: DefaultTextStyle.merge(
              style: isMore
                  // `.callout.callout-more p { font-size: 1rem;
                  //   line-height: 1.5rem; color: hsl(210, 33%, 28%) }` — sans
                  // at 16px, NOT the Lora 18px the other styles set. The style
                  // is for long text, and the serif face at 18px is what it is
                  // getting away from.
                  ? const TextStyle(
                      fontFamily: BootstrapItaliaFontFamily.sansSerif,
                      package: BootstrapItaliaFontFamily.package,
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w400,
                      color: _defaultText,
                    )
                  // `.callout p { font-family: "Lora"; font-size: 1.125rem;
                  //   line-height: 1.75rem; color: hsl(210, 33%, 28%) }`
                  : const TextStyle(
                      fontFamily: BootstrapItaliaFontFamily.serif,
                      package: BootstrapItaliaFontFamily.package,
                      fontSize: 18,
                      height: 28 / 18,
                      fontWeight: FontWeight.w400,
                      color: _defaultText,
                    ),
              child: widget.body,
            ),
          ),
          if (widget.moreContent != null)
            _buildMoreDisclosure(context, borderColor),
        ],
      ),
    );

    if (!isMore) return box;

    // `.callout.callout-more:before { border-width: 0 48px 48px 0;
    //    border-color: transparent #fff transparent transparent }` and
    // `:after { border-width: 48px 0 0 48px;
    //    border-color: transparent transparent transparent #e4e4db }` — the
    // classic two-triangle dog-ear, pinned to the top-right corner. The first
    // cuts the corner out in the page colour; the second lays the darker fold
    // under the cut.
    box = Stack(
      children: [
        box,
        Positioned(
          top: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(_moreFoldSize, _moreFoldSize),
            painter: _FoldedCornerPainter(
              cut: resolveColorScheme(context).white,
              fold: _moreFoldShadow,
            ),
          ),
        ),
      ],
    );
    return box;
  }

  /// `.collapse-div` / `.collapse-header` — the *Leggi tutto* disclosure at the
  /// foot of a `.callout-more`.
  Widget _buildMoreDisclosure(BuildContext context, Color accent) {
    return Padding(
      // `.callout .collapse-div .collapse-header { border-top: 1px solid
      //   hsl(210, 3%, 85%); padding: 1.333rem 0 0; margin-top: 0 }`
      padding: const EdgeInsets.only(top: _collapseHeaderGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _collapseRule)),
            ),
            padding: const EdgeInsets.only(top: _collapseHeaderGap),
            // `.collapse-header { display: flex;
            // justify-content: space-between }` — a Wrap rather than a Row.
            // Two long labels ("Leggi tutto" and a download link named with its
            // format and size, as §2.4.4 asks) are both flex items on an
            // unbounded main axis, and overflowed a phone-width callout by
            // 455px. A Wrap lays them out identically while they fit and drops
            // the second onto its own line when they do not; `spaceBetween`
            // keeps the alignment the stylesheet asks for on the single-line
            // case, which is the one it was written for.
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: _iconGap,
              runSpacing: _iconGap,
              children: [
                // §4.1.2: `aria-expanded` and `aria-controls` are on the button
                // in the docs' own markup, so the state and the relationship
                // both belong on this node — not on the panel.
                Semantics(
                  button: true,
                  expanded: _moreExpanded,
                  label: widget.moreLabel,
                  child: ItActivatable(
                    onPressed: () =>
                        setState(() => _moreExpanded = !_moreExpanded),
                    child: ExcludeSemantics(
                      // Wrap, for the reason given on the header above: the
                      // label is a flex item with an unbounded main axis, so a
                      // Row would size it to its natural width whatever the
                      // callout's own width is.
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: _toggleGlyphGap,
                        children: [
                          Text(
                            widget.moreLabel,
                            style: TextStyle(
                              fontFamily: BootstrapItaliaFontFamily.sansSerif,
                              package: BootstrapItaliaFontFamily.package,
                              fontSize: 16,
                              height: 24 / 16,
                              // `.callout-more-toggle { font-weight: normal }`
                              // — it is a link in prose, not a button label.
                              fontWeight: FontWeight.w400,
                              color: accent,
                            ),
                          ),
                          _ToggleGlyph(color: accent, expanded: _moreExpanded),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.downloadLabel != null)
                  // `.callout-more-download` is an `<a>`, so it announces as a
                  // link; the glyph beside it is decoration.
                  Semantics(
                    link: true,
                    label: widget.downloadLabel,
                    child: ItActivatable(
                      onPressed: widget.onDownload,
                      child: ExcludeSemantics(
                        // Wrap again, and this is the one that needed it: a
                        // download link named with its format and size — which
                        // §2.4.4 asks for, and «Scarica la scheda in PDF, 200Kb»
                        // is — overflowed a phone-width callout by 223px as a
                        // Row.
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          // `.callout-more-download .icon.me-2` — 0.5rem gap.
                          spacing: _iconGap,
                          children: [
                            Icon(BootstrapItaliaIcons.it_download,
                                size: 20, color: accent),
                            Text(
                              widget.downloadLabel!,
                              style: TextStyle(
                                fontFamily: BootstrapItaliaFontFamily.sansSerif,
                                package: BootstrapItaliaFontFamily.package,
                                fontSize: 16,
                                height: 24 / 16,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ItCollapse(
            isExpanded: _moreExpanded,
            child: Padding(
              padding: const EdgeInsets.only(top: _collapseHeaderGap),
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  fontFamily: BootstrapItaliaFontFamily.sansSerif,
                  package: BootstrapItaliaFontFamily.package,
                  fontSize: 16,
                  height: 24 / 16,
                  color: _defaultText,
                ),
                child: widget.moreContent!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The default glyph per variant.
  ///
  /// These are semantic choices made by the design system, NOT a mechanical
  /// rename of the Material equivalents — the two that were checked against the
  /// live reference both contradicted the obvious guess:
  ///
  ///  * a plain callout uses `it-ban`, not an info glyph;
  ///  * "approfondimento" (note / read-more) uses `it-zoom-in` — look closer —
  ///    again not an info glyph.
  ///
  /// Verified by extracting the rendered `<path d>` from the design-react-kit
  /// story and matching it against `bootstrap-italia/svg/sprites.svg`, which is
  /// the only way to recover a glyph name from the kit (it inlines its SVGs
  /// rather than referencing the sprite by id).
  static IconData _icon(ItCalloutVariant variant) {
    return switch (variant) {
      // All six are now verified, and from a better source than a screenshot:
      // the docs page publishes the markup for every variant, and each
      // `<use href="…#it-…">` names the sprite symbol outright. No path
      // matching, no attribution risk. From «Esempi» and its five subsections:
      //
      //   .callout            → #it-info-circle
      //   .callout.success    → #it-check-circle
      //   .callout.warning    → #it-help-circle
      //   .callout.danger     → #it-close-circle
      //   .callout.important  → #it-info-circle
      //   .callout.note       → #it-info-circle
      //
      // One correction came out of that. `danger` was `it-error` here — the
      // exclamation-in-an-octagon — where the docs use `it-close-circle`, a
      // cross in a circle. It was a reasonable guess and it was wrong; note
      // that `it-error` IS right for the danger *alert*, whose inline SVG
      // matches that octagon exactly. Two components, same word, different
      // glyphs.
      ItCalloutVariant.neutral => BootstrapItaliaIcons.it_info_circle,
      ItCalloutVariant.success => BootstrapItaliaIcons.it_check_circle,
      ItCalloutVariant.warning => BootstrapItaliaIcons.it_help_circle,
      ItCalloutVariant.danger => BootstrapItaliaIcons.it_close_circle,
      ItCalloutVariant.important => BootstrapItaliaIcons.it_info_circle,
      ItCalloutVariant.note => BootstrapItaliaIcons.it_info_circle,
    };
  }
}

/// The `+` / `−` disc of the *Leggi tutto* toggle.
///
/// ```css
/// .callout .collapse-div .collapse-header .callout-more-toggle span {
///   height: 15px; width: 15px; border: 1px solid #06c; border-radius: 50% }
/// .callout .collapse-div .collapse-header .callout-more-toggle span:before,
/// .callout … span:after { background: #06c }
/// ```
///
/// The two pseudo-elements are the bars of a plus sign; the open state drops the
/// vertical one. Drawn rather than iconised because the design system builds it
/// out of borders and backgrounds — there is no sprite symbol for it, and the
/// nearest glyph would be a different weight inside a 15px disc.
class _ToggleGlyph extends StatelessWidget {
  const _ToggleGlyph({required this.color, required this.expanded});

  final Color color;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ItCalloutState._toggleGlyphSize,
      height: _ItCalloutState._toggleGlyphSize,
      child: CustomPaint(
        painter: _ToggleGlyphPainter(color: color, expanded: expanded),
      ),
    );
  }
}

class _ToggleGlyphPainter extends CustomPainter {
  const _ToggleGlyphPainter({required this.color, required this.expanded});

  final Color color;
  final bool expanded;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // `border: 1px solid; border-radius: 50%` — the stroke is centred on the
    // path, so the radius is inset by half of it to keep the disc 15px overall.
    canvas.drawCircle(centre, size.width / 2 - 0.5, stroke);

    final bar = Paint()..color = color;
    const arm = 3.5;
    canvas.drawRect(
      Rect.fromLTRB(
          centre.dx - arm, centre.dy - 0.5, centre.dx + arm, centre.dy + 0.5),
      bar,
    );
    if (!expanded) {
      canvas.drawRect(
        Rect.fromLTRB(
            centre.dx - 0.5, centre.dy - arm, centre.dx + 0.5, centre.dy + arm),
        bar,
      );
    }
  }

  @override
  bool shouldRepaint(_ToggleGlyphPainter old) =>
      old.color != color || old.expanded != expanded;
}

/// The dog-ear at the top-right of a `.callout-more`.
class _FoldedCornerPainter extends CustomPainter {
  const _FoldedCornerPainter({required this.cut, required this.fold});

  /// The page colour showing through the cut corner (`:before`, `#fff`).
  final Color cut;

  /// The turned-back paper beneath it (`:after`, `#e4e4db`).
  final Color fold;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // `:before { border-width: 0 48px 48px 0 }` with only the right border
    // coloured: a triangle above the box's leading diagonal.
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(w, 0)
        ..lineTo(w, h)
        ..close(),
      Paint()..color = cut,
    );
    // `:after { border-width: 48px 0 0 48px }` with only the left border
    // coloured: the triangle below it.
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = fold,
    );
  }

  @override
  bool shouldRepaint(_FoldedCornerPainter old) =>
      old.cut != cut || old.fold != fold;
}
