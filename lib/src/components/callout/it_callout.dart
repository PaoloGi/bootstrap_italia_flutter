import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/spacing.dart';
import '../collapse/it_collapse.dart';

/// Color variants for [ItCallout].
///
/// Matches Bootstrap Italia's callout variants from _callout.scss:
/// success, warning, danger, important (→ $success), note (→ $primary).
enum ItCalloutVariant {
  /// Green success callout.
  success,

  /// Orange warning callout.
  warning,

  /// Red danger callout.
  danger,

  /// Green important callout (uses success color).
  important,

  /// Blue note callout (uses primary color).
  note,
}

/// A Bootstrap Italia callout component.
///
/// Highlights important information with a colored left border and
/// optional title. Can be made collapsible.
///
/// ```dart
/// ItCallout(
///   variant: ItCalloutVariant.success,
///   title: 'Nota bene',
///   child: Text('Testo importante da evidenziare.'),
/// )
/// ```
class ItCallout extends StatefulWidget {
  /// The callout color variant.
  final ItCalloutVariant variant;

  /// Optional title text.
  final String? title;

  /// Whether the callout body is collapsible.
  final bool collapsible;

  /// Whether a collapsible callout starts expanded.
  final bool initiallyExpanded;

  /// The callout content.
  final Widget child;

  /// Creates a Bootstrap Italia callout.
  const ItCallout({
    super.key,
    this.variant = ItCalloutVariant.note,
    this.title,
    this.collapsible = false,
    this.initiallyExpanded = true,
    required this.child,
  });

  @override
  State<ItCallout> createState() => _ItCalloutState();
}

class _ItCalloutState extends State<ItCallout> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.collapsible ? widget.initiallyExpanded : true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final calloutColors = colors.calloutColorsForVariant(widget.variant.name);
    final accentColor = calloutColors.accent;
    final bgColor = calloutColors.background;
    final iconData = _icon(widget.variant);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(BootstrapItaliaBorders.radius),
          bottomRight: Radius.circular(BootstrapItaliaBorders.radius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            GestureDetector(
              onTap: widget.collapsible
                  ? () => setState(() => _expanded = !_expanded)
                  : null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  BootstrapItaliaSpacing.space3,
                  BootstrapItaliaSpacing.space3,
                  BootstrapItaliaSpacing.space3,
                  BootstrapItaliaSpacing.space1,
                ),
                child: Row(
                  children: [
                    Icon(iconData, size: 20, color: accentColor),
                    const SizedBox(width: BootstrapItaliaSpacing.space2),
                    Expanded(
                      child: Text(
                        widget.title!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ),
                    if (widget.collapsible)
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ItCollapse(
            isExpanded: _expanded,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                BootstrapItaliaSpacing.space3,
                widget.title != null
                    ? BootstrapItaliaSpacing.space2
                    : BootstrapItaliaSpacing.space3,
                BootstrapItaliaSpacing.space3,
                BootstrapItaliaSpacing.space3,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 14,
                  color: colors.neutral1,
                  height: 1.5,
                ),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _icon(ItCalloutVariant variant) {
    return switch (variant) {
      ItCalloutVariant.success => Icons.check_circle_outline,
      ItCalloutVariant.warning => Icons.help_outline,
      ItCalloutVariant.danger => Icons.error_outline,
      ItCalloutVariant.important => Icons.info_outline,
      ItCalloutVariant.note => Icons.info_outline,
    };
  }
}
