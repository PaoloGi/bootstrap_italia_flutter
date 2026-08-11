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

  /// Optional title text. Rendered uppercase, as Bootstrap Italia does.
  final String? title;

  /// Whether the callout body is collapsible.
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
    this.title,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.showIcon = true,
    required this.body,
  });

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

  late bool _expanded;

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

  @override
  Widget build(BuildContext context) {
    final variant = widget.variant;
    final borderColor = _accent(variant, resolveColorScheme(context));
    // The un-modified callout keeps the neutral text colour even though its
    // border is grey-blue; coloured variants tint the title too.
    final titleColor =
        variant == ItCalloutVariant.neutral ? _defaultText : borderColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: _borderWidth),
      ),
      padding: const EdgeInsets.all(_padding),
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
                        child: Text(
                          widget.title!.toUpperCase(),
                          style: TextStyle(
                            fontFamily: BootstrapItaliaFontFamily.sansSerif,
                            package: BootstrapItaliaFontFamily.package,
                            // 1.125rem / 1.5 at >= 992px
                            fontSize: 18,
                            height: 27 / 18,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
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
            const SizedBox(height: _titleGap),
          ],
          ItCollapse(
            isExpanded: _expanded,
            child: DefaultTextStyle.merge(
              // `.callout p { font-family: "Lora"; font-size: 1.125rem;
              //   line-height: 1.75rem; color: hsl(210, 33%, 28%) }`
              style: const TextStyle(
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
      // Verified against captured references.
      ItCalloutVariant.success => BootstrapItaliaIcons.it_check_circle,
      ItCalloutVariant.neutral => BootstrapItaliaIcons.it_info_circle,

      // NOT verified: no captured reference renders these variants, so each is
      // the closest same-set equivalent rather than an observed value.
      //
      // Be careful here. Matching a rendered `<path d>` against the sprite does
      // identify a glyph correctly, but only for the callout you actually
      // sampled — an earlier pass matched `it-ban` and `it-zoom-in` from other
      // stories and mis-attributed them to these variants, which put a
      // circle-with-slash where the reference shows an info circle. Confirm the
      // variant as well as the glyph before promoting anything to "verified".
      ItCalloutVariant.note => BootstrapItaliaIcons.it_info_circle,
      ItCalloutVariant.warning => BootstrapItaliaIcons.it_help_circle,
      ItCalloutVariant.danger => BootstrapItaliaIcons.it_error,
      ItCalloutVariant.important => BootstrapItaliaIcons.it_info_circle,
    };
  }
}
