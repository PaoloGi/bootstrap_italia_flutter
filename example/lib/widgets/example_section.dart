import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

/// A reusable section that groups an example with a bold title.
///
/// Renders a card-like container with a [title] header, an optional
/// [description], and a [child] widget below.
///
/// The sections mirror the Bootstrap Italia documentation page for each
/// component, heading for heading, so that a developer reading the docs can
/// find the same example here. [description] carries the docs' explanation,
/// adapted to this package's API — it is the difference between a gallery and
/// a reference.
class ExampleSection extends StatelessWidget {
  /// The section heading.
  final String title;

  /// The example content.
  final Widget child;

  /// What this example demonstrates, in Italian, as the docs put it.
  ///
  /// Null for a section whose title is self-explanatory; prose for its own sake
  /// is noise on a reference page.
  final String? description;

  /// The Dart that produces [child], shown beneath it.
  ///
  /// The docs show the HTML for every example. The equivalent here is the
  /// Flutter call, and without it a reader has to guess which parameter
  /// produced what they are looking at.
  final String? code;

  /// Creates an [ExampleSection].
  const ExampleSection({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.code,
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
          if (description != null) ...[
            const SizedBox(height: BootstrapItaliaSpacing.space2),
            Text(
              description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: BootstrapItaliaSpacing.space3),
          child,
          if (code != null) ...[
            const SizedBox(height: BootstrapItaliaSpacing.space3),
            _CodeBlock(code!),
          ],
        ],
      ),
    );
  }
}

/// The Dart behind an example, in the monospace face the package bundles.
class _CodeBlock extends StatelessWidget {
  const _CodeBlock(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BootstrapItaliaSpacing.space2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(BootstrapItaliaBorders.radius),
      ),
      // Horizontal scrolling rather than wrapping: a wrapped code sample reads
      // as a different shape from the one you would type.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: TextStyle(
            fontFamily: BootstrapItaliaFontFamily.monospace,
            package: BootstrapItaliaFontFamily.package,
            fontSize: 13,
            height: 1.6,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
