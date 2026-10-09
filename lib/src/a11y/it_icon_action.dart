import 'package:flutter/widgets.dart';

import 'it_activatable.dart';

/// An icon-only button, built on the widgets layer.
///
/// Replaces Material's `IconButton`, whose behaviour this package overrode
/// anyway (`.custom-navbar-toggler { background: none; border: none }` and
/// `.close-div .close-menu { background: rgba(0,0,0,0) }` have no hover or
/// press fill, so every call site passed `kItNoOverlay`). What is left of
/// `IconButton` after that is a sized box, a focus node and an accessible
/// name — all of which this states explicitly.
///
/// [label] is **required**, and that is the point: an icon-only control with no
/// accessible name is a WCAG 4.1.2 (Name, Role, Value) failure, and it is
/// exactly the kind of regression that going to the widgets layer invites,
/// because Material used to supply the name from `IconButton.tooltip`.
class ItIconAction extends StatelessWidget {
  /// The glyph.
  ///
  /// `.custom-navbar-toggler svg { width: 24px; height: 24px }`.
  final IconData icon;

  /// Glyph colour.
  final Color color;

  /// Accessible name. Announced in place of the glyph, which carries none.
  final String label;

  /// Invoked on tap, and on Enter/Space while focused.
  final VoidCallback? onPressed;

  /// Painted glyph size.
  final double iconSize;

  /// Side of the square hit target.
  ///
  /// Defaults to 48 — the box Material's `IconButton` laid out, kept so that
  /// removing it does not change the height of the bar it sits in, and
  /// comfortably past the 24x24 of WCAG 2.5.8 Target Size.
  final double size;

  /// Creates an icon-only button with an explicit accessible name.
  const ItIconAction({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
    this.iconSize = 24,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: ItActivatable(
        onPressed: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: Icon(icon, size: iconSize, color: color)),
        ),
      ),
    );
  }
}
