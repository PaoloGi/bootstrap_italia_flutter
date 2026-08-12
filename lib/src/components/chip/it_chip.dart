import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/it_localizations.dart';
import '../../a11y/it_activatable.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';

/// `.chip { background: hsl(0, 0%, 96%) }`
const Color _chipBackground = Color(0xFFF5F5F5);

/// `.chip { border: 1px solid hsl(210, 4%, 78%) }`
const Color _chipBorderColor = Color(0xFFC5C7C9);

/// `.chip .chip-label { color: rgb(48, 71, 95) }`
const Color _chipLabelColor = Color(0xFF30475F);

/// `.chip:hover:not(.chip-disabled)
///   { background: hsl(210,33%,28%); border-color: hsl(210,33%,28%) }`
///
/// One of the few Bootstrap Italia hovers that *does* repaint the fill — and it
/// jumps straight to the dark slate, not to a shade of the resting grey.
/// Measured on the React kit: `rgb(245,245,245)` at rest, `rgb(48,71,95)` on
/// hover and while pressed.
const Color _chipHoverBackground = Color(0xFF30475F);

/// `.chip:hover:not(.chip-disabled) .chip-label { color: #fff }` (and the same
/// for `> .icon` / `button .icon`).
const Color _chipHoverForeground = Color(0xFFFFFFFF);

/// `.chip.chip-disabled { background: #fff; color: hsl(210,12%,44%) }` — the
/// disabled chip has explicit colours rather than `--bs-btn-disabled-opacity`.
const Color _chipDisabledBackground = Color(0xFFFFFFFF);

/// `.chip.chip-disabled .chip-label { color: hsl(210,12%,44%) }`
const Color _chipDisabledLabelColor = Color(0xFF63707E);

/// `.chip.chip-disabled button .icon,
///  .chip.chip-disabled > .icon { fill: hsl(210,3%,85%) }`
const Color _chipDisabledIconColor = Color(0xFFD8D9DA);

/// Colour variants for [ItChip] — the `.chip-*` modifiers.
///
/// These do NOT work like the fills on [ItBadge] or [ItButton]. A coloured chip
/// is an *outline* at rest and fills only on hover:
///
/// ```css
/// .chip.chip-primary        { background-color: rgba(0,0,0,0);
///                             border-color: #06c; color: #06c }
/// .chip.chip-primary > .chip-label { color: #06c }
/// .chip.chip-primary:hover  { background-color: #06c; border-color: #06c }
/// .chip.chip-primary:hover > .chip-label { color: #fff }
/// ```
///
/// with the same four rules repeated for `secondary`, `success`, `danger`,
/// `info` and `warning`. «Varianti di colore» shows five of them; `info` exists
/// in the stylesheet too and is included here for completeness — it resolves to
/// the same `hsl(210, 17%, 44%)` as `secondary`, exactly as `--bs-info` and
/// `--bs-secondary` do.
enum ItChipVariant {
  /// `.chip-primary`.
  primary,

  /// `.chip-secondary`.
  secondary,

  /// `.chip-success`.
  success,

  /// `.chip-danger`.
  danger,

  /// `.chip-warning`.
  warning,

  /// `.chip-info` — the same grey-blue as [secondary], as in the palette.
  info,
}

/// Maps [ItChipVariant] onto the shared semantic colour roles.
///
/// Exhaustive by construction, as on [ItButton] and [ItBadge]: a new variant
/// with no colour will not compile.
extension ItChipVariantColor on ItChipVariant {
  /// The semantic colour role this variant paints with.
  ItVariantColor get variantColor => switch (this) {
        ItChipVariant.primary => ItVariantColor.primary,
        ItChipVariant.secondary => ItVariantColor.secondary,
        ItChipVariant.success => ItVariantColor.success,
        ItChipVariant.danger => ItVariantColor.danger,
        ItChipVariant.warning => ItVariantColor.warning,
        ItChipVariant.info => ItVariantColor.info,
      };
}

/// A Bootstrap Italia chip component.
///
/// Chips are compact elements that represent an input, attribute, or action.
///
/// ```dart
/// ItChip(label: 'Flutter')
/// ItChip(label: 'Tag', icon: BootstrapItaliaIcons.it_pa, dismissible: true, onDismiss: () {})
/// ItChip(label: 'Attivo', selected: true)
/// ```
class ItChip extends StatelessWidget {
  /// The chip label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Arbitrary leading content, in place of [icon].
  ///
  /// «Varianti standard e grandi» shows four shapes for a chip — label alone,
  /// label + close, icon + label + close, and **avatar** + label + close — and
  /// the last of those is an `<img>`, not a glyph:
  ///
  /// ```html
  /// <div class="chip">
  ///   <div class="avatar size-xs"><img src="…" alt="Mario Rossi"></div>
  ///   <span class="chip-label">Label</span>
  ///   <button>…</button>
  /// </div>
  /// ```
  ///
  /// [icon] cannot express that, so this slot takes any widget and lays it out
  /// where the glyph would go, in the box the stylesheet gives the avatar:
  /// 16x16 on a standard chip and `.chip.chip-lg .avatar { width: 24px;
  /// height: 24px }` on a large one. Clip it yourself if it should be round —
  /// `.avatar img { border-radius: 50% }` lives on the avatar component, which
  /// this package does not ship.
  ///
  /// Give the image an accessible name only if it carries information the label
  /// does not; the chip already announces [label].
  final Widget? leading;

  /// The colour variant, or null for the default grey chip.
  ///
  /// Null is not "no colour": it is `.chip` on its own, the filled grey chip
  /// with the slate hover that every ungarnished example in the docs uses.
  final ItChipVariant? variant;

  /// Whether the chip shows a dismiss button.
  final bool dismissible;

  /// Called when the dismiss button is tapped, asking you to remove the chip.
  ///
  /// A *request*, not a notification: the chip does not remove itself, so
  /// nothing happens until the parent drops it from its list. Present tense
  /// marks that throughout this package, following Bootstrap's own event pairs
  /// (`hide.bs.*` fires before, `hidden.bs.*` after) — compare
  /// [ItNotification.onDismissed], which reports a removal that has already
  /// happened.
  final VoidCallback? onDismiss;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  /// Whether the chip is in a selected state.
  final bool selected;

  /// Whether the chip uses the large variant.
  final bool large;

  /// Whether the chip is disabled.
  final bool disabled;

  /// Custom background color.
  final Color? color;

  /// Accessible name for the dismiss control.
  ///
  /// An icon-only button with no name is announced as just "button", which
  /// tells a screen-reader user nothing (WCAG 4.1.2). Defaults to
  /// `'Rimuovi'` — a
  /// different word from the alert's `'Chiudi'` because the chip leaves the
  /// list rather than closing a surface. Mirrors [ItAlert.dismissLabel].
  final String? dismissLabel;

  /// Creates a Bootstrap Italia chip.
  const ItChip({
    super.key,
    required this.label,
    this.icon,
    this.leading,
    this.variant,
    this.dismissible = false,
    this.onDismiss,
    this.onTap,
    this.selected = false,
    this.large = false,
    this.disabled = false,
    this.color,
    this.dismissLabel,
  }) : assert(
          icon == null || leading == null,
          'ItChip: `icon` and `leading` both fill the slot before the label. '
          'Pass one — `leading` if it is an avatar or anything that is not a '
          'glyph.',
        );

  @override
  Widget build(BuildContext context) {
    return ItHoverBuilder(
      enabled: !disabled,
      cursor: disabled
          ? SystemMouseCursors.forbidden
          : (onTap != null ? SystemMouseCursors.click : MouseCursor.defer),
      builder: _build,
    );
  }

  Widget _build(BuildContext context, bool hovered) {
    final colors = resolveColorScheme(context);
    final bgColor = _resolveBackgroundColor(colors, hovered);
    final fgColor = _resolveForegroundColor(colors, hovered);
    final borderColor = _resolveBorderColor(colors, hovered);
    // `.chip > .icon { fill: hsl(210,33%,28%) }` — the leading glyph takes the
    // label's colour, and `.chip:hover:not(.chip-disabled) > .icon
    // { fill: #fff }` follows the label through hover too.
    final iconColor = disabled ? _chipDisabledIconColor : fgColor;
    // `.chip button .icon { fill: hsl(210,17%,44%) }` — the dismiss glyph is one
    // step lighter than the label's `hsl(210,33%,28%)`. A literal, not the
    // scheme: the value is byte-identical to `--bs-secondary`, but a close
    // button is chrome, and an administration retinting `secondary` to purple
    // does not want purple close buttons. `token_hygiene_test.dart` carries the
    // matching entry.
    //
    // Disabled keeps the label's own disabled grey: `.chip-disabled` recolours
    // the whole chip, and a lighter close glyph inside an already-greyed chip
    // would fall below 3:1 against its fill.
    final dismissIconColor =
        disabled ? _chipDisabledIconColor : const Color(0xFF5D7083);
    // Geometry from bootstrap-italia.min.css:
    //   .chip     { height: 24px; min-width: 100px; border-radius: 12px;
    //               padding: 0 4px 2px 8px; background: hsl(0,0%,96%);
    //               border: 1px solid hsl(210,4%,78%) }
    //   .chip-lg  { height: 32px; min-width: 120px; border-radius: 16px;
    //               padding: 2px 4px 0 16px }
    final height = large ? 32.0 : 24.0;
    final minWidth = large ? 120.0 : 100.0;
    final radius = large ? 16.0 : 12.0;
    // `.chip.chip-simple` (no dismiss button) overrides padding-right to 8px;
    // chips with a trailing button keep the tighter 4px.
    final rightPadding = dismissible ? 4.0 : 8.0;
    final fontSize = large ? 16.0 : 14.0;
    // The leading glyph and the dismiss glyph are NOT the same size, and used
    // to share one value here:
    //   `.chip.chip-lg > .icon      { width: 24px; height: 24px }`
    //   `.chip button .icon         { width: 22px; height: 22px }`
    //   `.chip.chip-lg button .icon { width: 28px; height: 28px }`
    // The standard chip's leading glyph has no rule of its own — the docs'
    // markup carries `class="icon icon-xs"`, i.e. `.icon.icon-xs { width: 16px }`
    // — so 16px is the authored size rather than a stylesheet default.
    final iconSize = large ? 24.0 : 16.0;
    final dismissGlyphSize = large ? 28.0 : 22.0;
    // `.chip button { width: 24px; height: 24px }`, `.chip.chip-lg button
    // { width: 32px; height: 32px }` — a fixed box, which is also what keeps the
    // dismiss target at the chip's full height for §2.5.8.
    final dismissBoxSize = large ? 32.0 : 24.0;
    // Room for the dismiss button the Stack overlays on the right edge.
    final dismissInset = dismissible ? rightPadding : 0.0;
    final reserved = rightPadding + (dismissible ? dismissBoxSize : 0.0);
    final padding = large
        ? EdgeInsets.fromLTRB(16, 2, reserved, 0)
        : EdgeInsets.fromLTRB(8, 0, reserved, 2);

    // IntrinsicWidth pins the chip to its content width; without it the
    // Container's `alignment` makes it expand to every available pixel,
    // since a Container with an alignment fills its constraints.
    final chip = IntrinsicWidth(
      child: Container(
        height: height,
        constraints: BoxConstraints(minWidth: minWidth),
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          border: selected
              ? Border.all(color: borderColor, width: 2)
              : Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: iconColor),
              const SizedBox(width: 4),
            ] else if (leading != null) ...[
              // `.chip .avatar` gets no size of its own on a standard chip (the
              // markup uses `.avatar.size-xs`, 16px); `.chip.chip-lg .avatar
              // { width: 24px; height: 24px }`. Same box as the glyph, so an
              // avatar and an icon put the label in the same place.
              SizedBox(width: iconSize, height: iconSize, child: leading),
              const SizedBox(width: 4),
            ],
            // `.chip .chip-label` is always 600 weight with its own colour.
            // CSS also applies transform: translateY(-2px), but that only
            // compensates for how flexbox baseline-aligns the span inside a
            // content box shorter than the 21px line box. Flutter centres
            // the text outright, so replicating the nudge here would shift
            // the label 2px too high — measured against the reference.
            // Flexible, and ellipsised rather than wrapped. `.chip` is a
            // fixed-height pill (24px, 32px for `.chip-lg`), so a second line
            // has nowhere to go: the choice is between shortening the label and
            // spilling it past the border, which is what happened before —
            // measured at 32px on a phone, where a group of chips is squeezed
            // narrower than the widest of them.
            //
            // Nothing is lost to assistive technology: the chip's Semantics
            // carries the full `label`, so an ellipsis is a visual truncation
            // only. The Flexible is unconditionally safe here because the
            // IntrinsicWidth below always hands this Row a tight width, even
            // where the chip's own parent gives it none.
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  // Named explicitly: with no ambient Material,
                  // DefaultTextStyle.fallback() applies and carries NO font
                  // family, so the label renders in the platform default.
                  fontFamily: BootstrapItaliaFontFamily.sansSerif,
                  package: BootstrapItaliaFontFamily.package,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // §2.1.1 Keyboard / §2.4.7 Focus Visible: the chip was a bare
    // [GestureDetector], so it could neither be reached nor seen from the
    // keyboard. ItActivatable supplies both, and paints the design system's
    // own ring rather than a Material highlight.
    //
    // Both cursors defer to the [ItHoverBuilder] above, which is what resolves
    // `.chip-disabled`'s `not-allowed` and the plain chip's inherited arrow.
    final body = Semantics(
      button: onTap != null,
      enabled: !disabled,
      label: label,
      child: ItActivatable(
        onPressed: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(radius),
        cursor: MouseCursor.defer,
        disabledCursor: MouseCursor.defer,
        child: ExcludeSemantics(child: chip),
      ),
    );

    if (!dismissible) return body;

    // The dismiss control is a SIBLING of the chip body, not a child of it.
    // Nested inside, it sat under the body's ExcludeSemantics and was a bare
    // GestureDetector besides: pointer-only, and announced as nothing at all
    // (WCAG 2.1.1 Keyboard, 4.1.2 Name/Role/Value). ItAlert already models this
    // correctly. A Stack keeps the button visually inside the chip's rounded
    // box while leaving it a separate hit target and a separate semantics node,
    // which is also how a chip's delete affordance is expected to behave.
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        body,
        Padding(
          padding: EdgeInsets.only(right: dismissInset),
          child: Semantics(
            button: true,
            enabled: !disabled,
            label:
                dismissLabel ?? ItLocalizations.of(context).removeNamed(label),
            child: ItActivatable(
              onPressed: disabled ? null : onDismiss,
              // `.chip button:focus:not([data-focus-mouse=true])
              //  { border-radius: 50% }` — the one control in the kit whose
              // focus ring is a circle rather than the chip's own rounded box.
              borderRadius: BorderRadius.circular(dismissBoxSize / 2),
              cursor: MouseCursor.defer,
              disabledCursor: MouseCursor.defer,
              child: ExcludeSemantics(
                child: SizedBox(
                  width: dismissBoxSize,
                  height: dismissBoxSize,
                  child: Icon(
                    BootstrapItaliaIcons.it_close,
                    size: dismissGlyphSize,
                    color: dismissIconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The variant's accent, or null on the default grey chip.
  ///
  /// Deliberately ordered after `disabled`. The stylesheet declares
  /// `.chip.chip-disabled` *before* `.chip.chip-primary` at equal specificity,
  /// so in a browser `class="chip chip-primary chip-disabled"` renders as a
  /// perfectly ordinary coloured chip — an inoperable control that looks
  /// operable. The docs never write that combination, and reproducing it would
  /// mean shipping a §1.4.1-shaped trap for the one caller who does. Disabled
  /// wins here.
  Color? _accent(BootstrapItaliaColorScheme colors) =>
      (disabled || variant == null)
          ? null
          : colors.forVariant(variant!.variantColor);

  Color _resolveBackgroundColor(
    BootstrapItaliaColorScheme colors,
    bool hovered,
  ) {
    if (disabled) return _chipDisabledBackground;
    // A caller-supplied fill owns the chip outright: shading or replacing it
    // would contradict the colour they asked for.
    if (color != null) return color!;
    final accent = _accent(colors);
    if (accent != null) {
      // `.chip.chip-primary { background-color: rgba(0,0,0,0) }` — a coloured
      // chip is an outline at rest and fills only on hover, the opposite way
      // round from a coloured badge or button.
      return hovered ? accent : const Color(0x00000000);
    }
    // `.chip.chip-primary:hover { background-color: #06c }` — the coloured
    // chip fills with its own accent, the plain one with the dark slate.
    if (hovered) return selected ? colors.primary : _chipHoverBackground;
    if (selected) return colors.primary.withAlpha(26);
    return _chipBackground;
  }

  Color _resolveBorderColor(BootstrapItaliaColorScheme colors, bool hovered) {
    // `.chip.chip-disabled` leaves `border-color` at the resting value.
    if (disabled) return _chipBorderColor;
    // `.chip.chip-primary { border-color: #06c }` and `:hover` keeps it there —
    // the ring is the one thing a coloured chip never changes.
    final accent = _accent(colors);
    if (accent != null) return accent;
    if (hovered && color == null) {
      return selected ? colors.primary : _chipHoverBackground;
    }
    if (selected) return colors.primary;
    return _chipBorderColor;
  }

  Color _resolveForegroundColor(
    BootstrapItaliaColorScheme colors,
    bool hovered,
  ) {
    if (disabled) return _chipDisabledLabelColor;
    final accent = _accent(colors);
    if (accent != null) {
      // `.chip.chip-primary > .chip-label { color: #06c }`, and
      // `.chip.chip-primary:hover > .chip-label { color: #fff }` once the accent
      // has filled the box behind it.
      return hovered ? colors.white : accent;
    }
    if (hovered && color == null) return _chipHoverForeground;
    if (selected) return colors.primary;
    return _chipLabelColor;
  }
}
