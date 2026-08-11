import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/widgets.dart';

import '../../a11y/it_activatable.dart';
import '../../l10n/it_localizations.dart';
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
  /// [ItLocalizations.remove] — `'Rimuovi'` with no delegate installed, and a
  /// different word from the alert's `'Chiudi'` because the chip leaves the
  /// list rather than closing a surface. Mirrors [ItAlert.dismissLabel].
  final String? dismissLabel;

  /// Creates a Bootstrap Italia chip.
  const ItChip({
    super.key,
    required this.label,
    this.icon,
    this.dismissible = false,
    this.onDismiss,
    this.onTap,
    this.selected = false,
    this.large = false,
    this.disabled = false,
    this.color,
    this.dismissLabel,
  });

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
    final iconColor = disabled ? _chipDisabledIconColor : fgColor;
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
    final iconSize = large ? 20.0 : 16.0;
    // Room for the dismiss button the Stack overlays on the right edge.
    final dismissInset = dismissible ? rightPadding : 0.0;
    final padding = large
        ? EdgeInsets.fromLTRB(
            16, 2, rightPadding + (dismissible ? iconSize + 4 : 0), 0)
        : EdgeInsets.fromLTRB(
            8, 0, rightPadding + (dismissible ? iconSize + 4 : 0), 2);

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
            ],
            // `.chip .chip-label` is always 600 weight with its own colour.
            // CSS also applies transform: translateY(-2px), but that only
            // compensates for how flexbox baseline-aligns the span inside a
            // content box shorter than the 21px line box. Flutter centres
            // the text outright, so replicating the nudge here would shift
            // the label 2px too high — measured against the reference.
            Text(
              label,
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
            label: dismissLabel ?? ItLocalizations.of(context).remove,
            child: ItActivatable(
              onPressed: disabled ? null : onDismiss,
              borderRadius: BorderRadius.circular(iconSize),
              cursor: MouseCursor.defer,
              disabledCursor: MouseCursor.defer,
              child: ExcludeSemantics(
                child: Icon(
                  BootstrapItaliaIcons.it_close,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _resolveBackgroundColor(
    BootstrapItaliaColorScheme colors,
    bool hovered,
  ) {
    if (disabled) return _chipDisabledBackground;
    // A caller-supplied fill owns the chip outright: shading or replacing it
    // would contradict the colour they asked for.
    if (color != null) return color!;
    // `.chip.chip-primary:hover { background-color: #06c }` — the coloured
    // chip fills with its own accent, the plain one with the dark slate.
    if (hovered) return selected ? colors.primary : _chipHoverBackground;
    if (selected) return colors.primary.withAlpha(26);
    return _chipBackground;
  }

  Color _resolveBorderColor(BootstrapItaliaColorScheme colors, bool hovered) {
    // `.chip.chip-disabled` leaves `border-color` at the resting value.
    if (disabled) return _chipBorderColor;
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
    if (hovered && color == null) return _chipHoverForeground;
    if (selected) return colors.primary;
    return _chipLabelColor;
  }
}
