import 'package:flutter/widgets.dart';

/// A horizontal rule between blocks of content.
///
/// ```
/// .divider { display:block; height:1px; background:hsl(210,4%,78%); margin:8px 0 }
/// ```
///
/// The stylesheet's own element, not Material's `Divider`: that one is 16px
/// tall by default and draws its line in the Material theme's divider colour,
/// so a page mixing the two gets two different rules.
///
/// Decorative by definition — a line carries no information a screen reader
/// can use — so it is hidden from assistive technology. Where a rule separates
/// *groups* that AT should be able to tell apart, the grouping belongs in the
/// semantics tree instead.
class ItDivider extends StatelessWidget {
  /// Creates the rule.
  const ItDivider({super.key});

  /// `background: hsl(210,4%,78%)`.
  static const Color color = Color(0xFFC5C7C9);

  /// `margin: 8px 0`.
  static const double margin = 8;

  /// `height: 1px`.
  static const double thickness = 1;

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: margin),
        child: SizedBox(
          height: thickness,
          width: double.infinity,
          child: ColoredBox(color: color),
        ),
      ),
    );
  }
}
