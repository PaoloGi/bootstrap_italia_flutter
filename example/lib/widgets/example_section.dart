import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';

/// A reusable section that groups an example with a bold title.
///
/// Renders a card-like container with a [title] header and a [child] widget
/// below, providing visual separation between examples on a page.
class ExampleSection extends StatelessWidget {
  /// The section heading.
  final String title;

  /// The example content.
  final Widget child;

  /// Creates an [ExampleSection].
  const ExampleSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(
        bottom: BootstrapItaliaSpacing.space4,
      ),
      padding: const EdgeInsets.all(BootstrapItaliaSpacing.space3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(BootstrapItaliaBorders.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: BootstrapItaliaSpacing.space3),
          child,
        ],
      ),
    );
  }
}
