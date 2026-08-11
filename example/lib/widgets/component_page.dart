import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

/// A reusable page template for showcasing a component.
///
/// Provides a [Scaffold] with an [AppBar] showing the [title] and a scrollable
/// body that lays out [children] vertically with Bootstrap Italia spacing.
class ComponentPage extends StatelessWidget {
  /// The title shown in the AppBar.
  final String title;

  /// The content widgets displayed in a vertical column.
  final List<Widget> children;

  /// Creates a [ComponentPage].
  const ComponentPage({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BootstrapItaliaSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
