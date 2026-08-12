import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../utilities/interaction_states.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../spinner/progress_spinner.dart';

/// Color variants for [ItButton].
enum ItButtonVariant {
  /// Primary blue button.
  primary,

  /// Secondary gray button.
  secondary,

  /// Green success button.
  success,

  /// Danger red button.
  danger,

  /// Warning orange button.
  warning,

  /// Info button.
  info,

  /// Light button.
  light,

  /// Dark button.
  dark,
}

/// Maps [ItButtonVariant] onto the shared semantic colour roles.
///
/// Exhaustive by construction — Dart requires every value to be handled, so
/// adding a variant here without giving it a colour will not compile. The
/// string-keyed lookup this replaced silently rendered such a variant as
/// primary.
extension ItButtonVariantColor on ItButtonVariant {
  /// The semantic colour role this variant paints with.
  ItVariantColor get variantColor => switch (this) {
        ItButtonVariant.primary => ItVariantColor.primary,
        ItButtonVariant.secondary => ItVariantColor.secondary,
        ItButtonVariant.success => ItVariantColor.success,
        ItButtonVariant.danger => ItVariantColor.danger,
        ItButtonVariant.warning => ItVariantColor.warning,
        ItButtonVariant.info => ItVariantColor.info,
        ItButtonVariant.light => ItVariantColor.light,
        ItButtonVariant.dark => ItVariantColor.dark,
      };
}

/// Size variants for [ItButton].
///
/// Spelled out rather than carrying the CSS suffix. `.btn-xs` / `.btn-lg` are
/// cited on the metrics below, where the class name is evidence; as identifiers
/// they were a third spelling of a concept this package already names two ways
/// (`ItChip.large`, `ItAutocomplete.large`), and one concept gets one name.
///
/// ## Three values for the docs' four headings
///
/// «Varianti di dimensione» offers `.btn-lg`, `.btn-sm` and `.btn-xs` under the
/// headings *Large*, *Small* and *Mini*. Only three distinct renderings exist,
/// because in v2.18.0 `.btn-sm` resolves to the default button exactly:
///
/// ```css
/// .btn      { padding: 12px 24px; font-size: 1rem }            /* base */
/// .btn-sm,
/// .btn-group-sm > .btn { padding: 12px 24px; font-size: 1rem;
///                        line-height: 1.5rem }
/// ```
///
/// with `--bs-btn-line-height: 1.5` on the base making the line box 24px there
/// too, and a later `.btn-xs, .btn-sm, … { border-radius: 4px }` undoing the
/// 2px radius `.btn-sm` asks for. Italia overrides Bootstrap's compact metrics
/// back to the default ones and leaves nothing behind — so "Small" and the
/// default are the same button, and adding a fourth value would only give this
/// enum two names for one rendering.
///
/// [small] is therefore `.btn-xs`, the docs' *Mini*: the one genuinely smaller
/// button the stylesheet defines.
enum ItButtonSize {
  /// Small button: reduced padding and font size (`.btn-xs`, docs *Mini*).
  small,

  /// Medium button: default size (`.btn`, and equally the docs' *Small*).
  medium,

  /// Large button: increased padding and font size (`.btn-lg`).
  large,
}

/// The `.bg-dark` overrides, for [ItButton.onDark].
///
/// `.bg-dark` redeclares only `.btn-primary`, `.btn-outline-primary`,
/// `.btn-secondary`, `.btn-outline-secondary` and `.btn-link`. Every other
/// variant renders exactly as it does on a light page — the stylesheet says so
/// by omission, and the docs' dark example shows only those two colours.
abstract final class _DarkTokens {
  /// `.bg-dark .btn-outline-primary:hover { box-shadow: inset 0 0 0 2px
  /// hsl(0, 0%, 90%) }`
  ///
  /// The ring is a box-shadow and `--bs-btn-border-width` is 0, so this rule —
  /// not the `--bs-btn-hover-border-color: #cccccc` declared beside it — is what
  /// actually paints. White at 90%, where the light-page ring shades to 80%.
  static const Color outlineHoverRing = Color(0xFFE6E6E6);
}

/// A Bootstrap Italia styled button.
///
/// Supports all color variants, sizes, outline mode, block (full-width) mode,
/// loading state with spinner, and leading/trailing icons.
///
/// ```dart
/// ItButton(
///   variant: ItButtonVariant.primary,
///   onPressed: () {},
///   child: Text('Conferma'),
/// )
///
/// ItButton(
///   variant: ItButtonVariant.danger,
///   outline: true,
///   icon: BootstrapItaliaIcons.it_delete,
///   onPressed: () {},
///   child: Text('Elimina'),
/// )
/// ```
class ItButton extends StatefulWidget {
  /// The button color variant.
  final ItButtonVariant variant;

  /// The button size.
  final ItButtonSize size;

  /// Whether to use the outline style.
  final bool outline;

  /// Renders the button as a link (`.btn-link`).
  ///
  /// ```css
  /// .btn-link { --bs-btn-font-weight: 400;
  ///             --bs-btn-color: var(--bs-link-color);
  ///             --bs-btn-bg: transparent;
  ///             --bs-btn-hover-color: var(--bs-link-hover-color);
  ///             --bs-btn-disabled-color: hsl(0, 0%, 32%);
  ///             text-decoration: underline }
  /// ```
  ///
  /// It keeps `.btn`'s box — the padding and the hit target are unchanged — and
  /// drops only the fill, the 600 weight and the ring. That matters for §2.5.8
  /// Target Size: a link button is still a 48px control, not a run of text.
  ///
  /// [variant] is ignored while this is set, because `.btn-link` declares its
  /// own colour and there are no `.btn-link-success` style modifiers in the
  /// stylesheet.
  final bool link;

  /// Applies the `.bg-dark` treatment, for a button placed on a dark surface.
  ///
  /// The design system does not simply flip a foreground: `.bg-dark
  /// .btn-primary` becomes a *white* button with blue text, and the outline
  /// variants take a white ring and white label. Only primary and secondary are
  /// redeclared — see [_DarkTokens].
  ///
  /// This does NOT paint a dark background; it assumes one is already there.
  /// Nothing in the stylesheet gives `.btn` a backdrop either — `.bg-dark` is a
  /// utility applied to an ancestor.
  ///
  /// Known gap: the stylesheet also inverts the focus indicator on a dark
  /// surface (`.bg-dark .btn:focus:not([data-focus-mouse=true])
  /// { box-shadow: 0 0 0 2px #000, 0 0 0 5px #fff }` — black inside, white
  /// outside). `ItFocusRing` paints the light-page order for every control in
  /// the package, so a dark button's ring is currently white-on-dark at the
  /// outer band. It stays visible, but at lower contrast than the design system
  /// intends; fixing it belongs with the focus-ring consolidation, not here.
  final bool onDark;

  /// Whether the button takes the full width of its parent.
  final bool block;

  /// Whether the button is disabled.
  final bool disabled;

  /// Whether to show a loading spinner.
  final bool loading;

  /// Leading icon data.
  final IconData? icon;

  /// Draws [icon] inside `.rounded-icon`'s circle.
  ///
  /// ```css
  /// .btn-icon .rounded-icon { width: 1.5em; height: 1.5em;
  ///                           border-radius: 12px;
  ///                           display: flex; justify-content: center;
  ///                           align-items: center;
  ///                           background-color: #fff }
  /// .btn-icon .rounded-icon .icon { margin-right: 0 }
  /// ```
  ///
  /// The `em` is the button's own font size, so the circle is 24px on a medium
  /// button and 27px on a large one, and it scales with [size] without a table.
  ///
  /// Only the leading [icon] is circled: `.rounded-icon` is a wrapper the author
  /// puts around one glyph, and every example in the docs puts it first.
  /// [trailingIcon] is left bare.
  final bool roundedIcon;

  /// Fill of the [roundedIcon] circle — the `.rounded-*` modifier.
  ///
  /// `.btn-icon .rounded-icon { background-color: #fff }` is the default, and
  /// `.rounded-primary`, `.rounded-success`, `.rounded-100` … replace it. Pass
  /// a scheme colour rather than a literal so the circle re-themes with
  /// everything else.
  final Color? roundedIconColor;

  /// Colour of the glyph inside the [roundedIcon] circle — `.icon.icon-*`.
  ///
  /// Defaults to the button's own variant colour, which is what every example in
  /// «Pulsante con icona cerchiata» does: a `.btn-success` carries an
  /// `.icon-success`, a `.btn-primary` an `.icon-primary`. On the default white
  /// circle that is also the only choice with any contrast — the button's
  /// foreground is white there too.
  final Color? roundedIconForegroundColor;

  /// Trailing icon data.
  final IconData? trailingIcon;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// Custom background color override.
  final Color? backgroundColor;

  /// Custom foreground color override.
  final Color? foregroundColor;

  /// The button content.
  final Widget child;

  /// Creates a Bootstrap Italia button.
  const ItButton({
    super.key,
    this.variant = ItButtonVariant.primary,
    this.size = ItButtonSize.medium,
    this.outline = false,
    this.link = false,
    this.onDark = false,
    this.block = false,
    this.disabled = false,
    this.loading = false,
    this.icon,
    this.roundedIcon = false,
    this.roundedIconColor,
    this.roundedIconForegroundColor,
    this.trailingIcon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    required this.child,
  })  : assert(
          !(outline && link),
          'ItButton: `outline` and `link` are alternative renderings of the '
          'same slot — .btn-outline-* draws a ring, .btn-link draws none at '
          'all. Setting both would silently pick one.',
        ),
        assert(
          !roundedIcon || icon != null,
          'ItButton: `roundedIcon` circles the leading `icon`, and none was '
          'given, so it would paint an empty disc. Pass `icon:` too, or drop '
          '`roundedIcon`.',
        );

  @override
  State<ItButton> createState() => _ItButtonState();

  Widget _buildContent({
    required Color fgColor,
    required double iconSize,
    required double fontSize,
    required Color accentColor,
    required Color surfaceColor,
  }) {
    final children = <Widget>[];

    if (loading) {
      children.add(
        // Bootstrap Italia has no `.progress-spinner` element inside a `.btn`,
        // so the track ring the standalone spinner carries is suppressed: on a
        // filled button the fill already reads as the track, and a grey CSS
        // ring over the brand blue would be a colour the design system never
        // declares here.
        ItProgressSpinner(
          diameter: iconSize,
          strokeWidth: 2,
          color: fgColor,
          trackColor: const Color(0x00000000),
        ),
      );
    } else if (icon != null) {
      children.add(
        roundedIcon
            ? _RoundedIcon(
                icon: icon!,
                // `width: 1.5em; height: 1.5em`, the em being the button's own
                // font size — so the disc grows with `size` on its own.
                diameter: 1.5 * fontSize,
                background: roundedIconColor ?? surfaceColor,
                foreground: roundedIconForegroundColor ?? accentColor,
                fontSize: fontSize,
              )
            : Icon(icon, size: iconSize),
      );
    }

    children.add(child);

    if (trailingIcon != null && !loading) {
      children.add(Icon(trailingIcon, size: iconSize));
    }

    if (children.length == 1) return children.first;

    // A Wrap, not a Row. `.btn { white-space: initial }` — Italia undoes
    // Bootstrap's `nowrap`, so a long label wraps inside the button rather than
    // running past its edge. A label on its own gets that for free (it is the
    // Container's only child and inherits its width); a label beside an icon is
    // a flex item, and a flex item's main axis is unbounded, so a Row sized the
    // text to its natural width and overflowed by up to 69px on a phone.
    //
    // `Flexible` in a Row would need a bounded width, which an ItButton dropped
    // into a plain Row has not got, and a LayoutBuilder to supply the bound
    // cannot answer intrinsic queries — which breaks the moment a button sits
    // inside an `IntrinsicWidth` or `IntrinsicHeight`. A Wrap has neither
    // problem: it hands its own width down, so the label wraps, and it answers
    // intrinsics. On a single line it lays out exactly as the Row did, which is
    // what the parity captures render.
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      // The 8px that used to be explicit SizedBox spacers. As Wrap items those
      // would have been free to end a line on their own.
      spacing: BootstrapItaliaSpacing.space2,
      runSpacing: BootstrapItaliaSpacing.space2,
      children: children,
    );
  }

  /// `.btn:disabled { --bs-btn-disabled-opacity: 0.65 }`
  static const double _disabledOpacity = 0.65;

  // Matches Bootstrap Italia's .btn (base/md), .btn-lg, and .btn-xs padding
  // and font-size, extracted from bootstrap-italia.min.css.
  static EdgeInsetsGeometry _padding(ItButtonSize size) {
    return switch (size) {
      ItButtonSize.small =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ItButtonSize.medium =>
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ItButtonSize.large =>
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    };
  }

  static double _fontSize(ItButtonSize size) {
    return switch (size) {
      ItButtonSize.small => 14,
      ItButtonSize.medium => 16,
      ItButtonSize.large => 18,
    };
  }

  static double _iconSize(ItButtonSize size) {
    return switch (size) {
      ItButtonSize.small => 16,
      ItButtonSize.medium => 20,
      ItButtonSize.large => 24,
    };
  }
}

/// The `.rounded-icon` disc and the glyph inside it.
///
/// Private, so it needs no accessibility contract of its own: the disc is
/// decoration on a button that already carries the role and the name, and the
/// glyph inside it is never the only thing that says what the button does —
/// every example in the docs pairs it with a `<span>` label.
class _RoundedIcon extends StatelessWidget {
  const _RoundedIcon({
    required this.icon,
    required this.diameter,
    required this.background,
    required this.foreground,
    required this.fontSize,
  });

  final IconData icon;
  final double diameter;
  final Color background;
  final Color foreground;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        // `border-radius: 12px` on a 1.5em box — at the default 16px font that
        // is exactly half the 24px side, i.e. a circle. Expressed as half the
        // diameter rather than as the literal 12 so a large button's 27px disc
        // stays round instead of turning into a squircle.
        borderRadius: BorderRadius.circular(diameter / 2),
      ),
      child: Icon(
        icon,
        color: foreground,
        // NOT verified against a rendered reference. The stylesheet sizes the
        // disc but says nothing about the glyph inside it beyond
        // `.btn-icon .rounded-icon .icon { margin-right: 0 }`, leaving `.icon`
        // at its 32px default inside a 24px flex box — a value the browser then
        // shrinks by rules that have no Flutter equivalent. 1em is the largest
        // glyph that keeps a visible ring of disc around it at every button
        // size, which is what the published examples show.
        size: fontSize,
      ),
    );
  }
}

class _ItButtonState extends State<ItButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final w = widget;
    // The variant's own colour: the fill of a solid button, and the ring and
    // label of an outline or link one.
    var bgColor =
        w.backgroundColor ?? colors.forVariant(w.variant.variantColor);
    var fgColor = w.foregroundColor ??
        colors.foregroundForVariant(w.variant.variantColor);

    if (w.link) {
      // `.btn-link { --bs-btn-color: var(--bs-link-color) }`, and
      // `--bs-link-color: hsl(210, 100%, 40%)` is `--bs-primary` byte for byte
      // in a role — the colour of a link — where the brand blue is what is
      // meant. So it re-themes, unlike the greys elsewhere in this package.
      // `.bg-dark .btn-link { color: #fff }` is the one dark override.
      bgColor = w.onDark ? colors.white : colors.primary;
      fgColor = bgColor;
    } else if (w.onDark && w.backgroundColor == null) {
      switch (w.variant) {
        // `.bg-dark .btn-primary { --bs-btn-bg: hsl(0, 0%, 100%);
        //   --bs-btn-color: hsl(210, 100%, 40%) }` — the solid primary inverts
        // outright. Its hover and active fills, `rgb(216.75, 216.75, 216.75)`
        // and `#cccccc`, are white at 85% and 80%, which is exactly what the
        // shared shading below produces once the accent is white.
        case ItButtonVariant.primary when !w.outline:
          bgColor = colors.white;
          fgColor = colors.primary;
        // `.bg-dark .btn-outline-primary`, `.bg-dark .btn-outline-secondary`
        // { --bs-btn-color: hsl(0, 0%, 100%);
        //   --bs-btn-border-color: hsl(0, 0%, 100%) } — ring and label both go
        // white. The outline path below paints with `bgColor`, so setting it is
        // enough.
        case ItButtonVariant.primary || ItButtonVariant.secondary
            when w.outline:
          bgColor = colors.white;
        // `.bg-dark .btn-secondary` restates the light-page colours and adds
        // only `color: #fff`, which `foregroundForVariant` already gives. Every
        // other variant is absent from `.bg-dark` entirely and renders
        // unchanged — the stylesheet's omission, not ours.
        default:
          break;
      }
    }

    final isDisabled = w.disabled || w.loading;
    final onPressed = isDisabled ? null : w.onPressed;

    final padding = ItButton._padding(w.size);
    final fontSize = ItButton._fontSize(w.size);
    final iconSize = ItButton._iconSize(w.size);
    final radius = BorderRadius.circular(BootstrapItaliaBorders.radius);

    // `.btn-*` fills and shades toward black on hover/active; `.btn-outline-*`
    // keeps `--bs-btn-hover-bg: transparent` and darkens only its border.
    // Material would instead paint a translucent overlay — lighter on a filled
    // button, darker on a white one — in both cases inventing a state change the
    // design system does not specify. See doc/adr/0001.
    // The shade factors below are read off the CSS: `.btn-primary` sets
    // `--bs-btn-hover-bg: rgb(0, 86.7, 173.4)` and
    // `--bs-btn-active-bg: rgb(0, 81.6, 163.2)` against a `#0066CC` base — i.e.
    // exactly 85% and 80% of the base channel values, hence 0.15 and 0.20.
    final Color fill;
    final Color edge;
    if (w.link) {
      // `.btn-link { --bs-btn-bg: transparent; --bs-btn-border-color:
      // transparent }` — no fill and no ring in any state, including hover:
      // `.btn-link:hover` changes only `color`.
      fill = const Color(0x00000000);
      edge = const Color(0x00000000);
    } else if (w.outline) {
      fill = const Color(0x00000000);
      edge = _pressed
          ? itShade(bgColor, 0.30)
          : _hovered
              ? (w.onDark
                  ? _DarkTokens.outlineHoverRing
                  : itShade(bgColor, 0.20))
              : bgColor;
    } else {
      edge = const Color(0x00000000);
      fill = isDisabled
          ? bgColor.withValues(alpha: ItButton._disabledOpacity)
          : _pressed
              ? itShade(bgColor, 0.20)
              : _hovered
                  ? itShade(bgColor, 0.15)
                  : bgColor;
    }

    // `.btn-link` colours the label rather than the box, so its states live
    // here instead of in the fill: `--bs-btn-hover-color: var(
    // --bs-link-hover-color)` is `rgb(0, 81.6, 163.2)`, the link colour at 80%,
    // and `--bs-btn-disabled-color: hsl(0, 0%, 32%)` replaces it outright.
    final Color labelColor;
    if (w.link) {
      labelColor = isDisabled
          ? BootstrapItaliaColors.gray600
          : (_pressed || _hovered)
              ? itShade(fgColor, 0.20)
              : fgColor;
    } else {
      labelColor = w.outline ? bgColor : fgColor;
    }

    final content = w._buildContent(
      fgColor: labelColor,
      iconSize: iconSize,
      fontSize: fontSize,
      // The disc's glyph takes the button's variant colour (`.btn-success` +
      // `.icon-success`), which on an outline or link button is already the
      // label colour.
      accentColor: bgColor,
      surfaceColor: colors.white,
    );

    Widget button = Container(
      padding: padding,
      decoration: BoxDecoration(color: fill, borderRadius: radius),
      // `.btn-outline-*` draws its ring as `box-shadow: inset 0 0 0 2px`, which
      // in CSS consumes NO layout space. A `border` in the decoration would be
      // laid out, growing the button by 2px a side and making an outline button
      // larger than the solid one it must match — measured at 215x106 against a
      // 206x96 reference. `foregroundDecoration` paints over the child instead,
      // which is the faithful analogue of an inset shadow.
      foregroundDecoration: w.outline
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: edge,
                width: BootstrapItaliaBorders.widthThick,
              ),
            )
          : null,
      child: DefaultTextStyle.merge(
        // .merge, never the default constructor: a plain DefaultTextStyle
        // REPLACES the ambient style and drops the font family, rendering every
        // glyph as a missing-character box.
        style: TextStyle(
          fontSize: fontSize,
          // `.btn { --bs-btn-font-weight: 600 }`, which `.btn-link` alone
          // relaxes to 400 — a link inside prose should not read as bolder than
          // the sentence around it.
          fontWeight: w.link ? FontWeight.w400 : FontWeight.w600,
          color: labelColor,
          // `.btn-link { text-decoration: underline }`, and the underline is
          // load-bearing: it is what tells a colour-blind reader this is a link
          // rather than emphasised text (WCAG §1.4.1 Use of Color). Every other
          // `.btn` sets `text-decoration: none`.
          decoration: w.link ? TextDecoration.underline : TextDecoration.none,
          decorationColor: labelColor,
          letterSpacing: 0,
          // `.btn { line-height: 1.5 }`. Material's button applied this via its
          // own text theme; stating it explicitly keeps the control box at the
          // CSS height instead of whatever the font's default metrics give.
          height: 1.5,
          leadingDistribution: TextLeadingDistribution.even,
          fontFamily: BootstrapItaliaFontFamily.sansSerif,
          package: BootstrapItaliaFontFamily.package,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: labelColor, size: iconSize),
          child: content,
        ),
      ),
    );

    // Bootstrap Italia's keyboard focus indicator (2px white, then 3px black).
    // Suppressing Material's overlay removed the only focus cue this button had,
    // so without this it would be a WCAG 2.4.7 regression. Uses the shared
    // ItFocusRing rather than a local copy, and is mounted unconditionally: a
    // ring that appears and disappears from the tree remounts the focus node and
    // destroys the very focus it is meant to show.
    button = Semantics(
      button: true,
      enabled: !isDisabled,
      // Delegates to ItActivatable rather than wiring its own
      // FocusableActionDetector, per ADR 0001. It used to do the latter, and
      // bound only `ActivateIntent` where ItActivatable binds that AND
      // `ButtonActivateIntent` — so the flagship button answered a different
      // set of keys from every other control in the package. Which intent
      // `WidgetsApp` dispatches varies by platform, so the difference was
      // latent rather than visible, which is the kind that ships.
      //
      // The focus ring is left to ItActivatable too (`showFocusRing` defaults
      // true); this file no longer paints one.
      child: ItActivatable(
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(BootstrapItaliaBorders.radius),
        // `.bg-dark .btn:focus:not([data-focus-mouse=true])
        //   { box-shadow: 0 0 0 2px #000, 0 0 0 5px #fff }` — the same two
        // bands as the light ring, in the opposite order. Without this an
        // `onDark` button kept the light order, putting its black outer band
        // against a near-black surface (§2.4.11 Focus Appearance).
        onDark: w.onDark,
        onHoverChanged: (v) => setState(() => _hovered = v),
        onPressedChanged: (v) => setState(() => _pressed = v),
        child: button,
      ),
    );

    if (w.block) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
