import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/spacing.dart';

/// A link in the slim header.
class ItSlimHeaderLink {
  /// The link label.
  final String label;

  /// Called when the link is tapped.
  final VoidCallback? onTap;

  /// Whether this link is active.
  final bool active;

  /// Creates a slim header link.
  const ItSlimHeaderLink({
    required this.label,
    this.onTap,
    this.active = false,
  });
}

/// The top-most institutional slim bar of Bootstrap Italia headers.
///
/// Displays the institutional name (e.g., "Repubblica Italiana") with
/// optional right-aligned links and a hamburger toggle on mobile.
///
/// ```dart
/// ItSlimHeader(
///   institutionName: 'Repubblica Italiana',
///   links: [
///     ItSlimHeaderLink(label: 'ITA', active: true),
///     ItSlimHeaderLink(label: 'ENG', onTap: () => switchLang('en')),
///   ],
/// )
/// ```
class ItSlimHeader extends StatelessWidget {
  /// The institution name displayed on the left.
  final String institutionName;

  /// Optional links displayed on the right.
  final List<ItSlimHeaderLink> links;

  /// Background color. Defaults to primary.
  final Color? backgroundColor;

  /// Creates a Bootstrap Italia slim header.
  const ItSlimHeader({
    super.key,
    required this.institutionName,
    this.links = const [],
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final bgColor = backgroundColor ?? colors.primary;

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(
        horizontal: BootstrapItaliaSpacing.space3,
        vertical: BootstrapItaliaSpacing.space1 + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              institutionName,
              style: TextStyle(
                fontSize: 13,
                color: colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (links.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: links.map((link) {
                return GestureDetector(
                  onTap: link.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      link.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.white,
                        fontWeight:
                            link.active ? FontWeight.w700 : FontWeight.w400,
                        decoration: link.active
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationColor: colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
