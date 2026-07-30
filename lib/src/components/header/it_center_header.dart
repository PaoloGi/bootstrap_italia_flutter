import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/spacing.dart';

/// A social link in the center header.
class ItSocialLink {
  /// The social platform icon.
  final IconData icon;

  /// Accessibility label.
  final String label;

  /// Called when tapped.
  final VoidCallback? onTap;

  /// Creates a social link.
  const ItSocialLink({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

/// The center section of a Bootstrap Italia header.
///
/// Displays the logo, site title, subtitle, and optionally social links
/// and a search button.
///
/// ```dart
/// ItCenterHeader(
///   logo: Image.asset('assets/logo.png', height: 48),
///   title: 'Comune di Roma',
///   subtitle: 'Segui su',
///   socialLinks: [
///     ItSocialLink(icon: Icons.facebook, label: 'Facebook'),
///   ],
///   showSearch: true,
///   onSearchTap: () {},
/// )
/// ```
class ItCenterHeader extends StatelessWidget {
  /// The logo widget.
  final Widget? logo;

  /// The main site title.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Social media links.
  final List<ItSocialLink> socialLinks;

  /// Whether to show the search icon.
  final bool showSearch;

  /// Called when the search icon is tapped.
  final VoidCallback? onSearchTap;

  /// Background color. Defaults to white.
  final Color? backgroundColor;

  /// Creates a Bootstrap Italia center header.
  const ItCenterHeader({
    super.key,
    this.logo,
    required this.title,
    this.subtitle,
    this.socialLinks = const [],
    this.showSearch = false,
    this.onSearchTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    return Container(
      width: double.infinity,
      color: backgroundColor ?? colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: BootstrapItaliaSpacing.space3,
        vertical: BootstrapItaliaSpacing.space3,
      ),
      child: Row(
        children: [
          if (logo != null) ...[
            logo!,
            const SizedBox(width: BootstrapItaliaSpacing.space3),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.neutral1,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.secondary,
                    ),
                  ),
              ],
            ),
          ),
          if (socialLinks.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: socialLinks.map((social) {
                return Semantics(
                  label: social.label,
                  child: GestureDetector(
                    onTap: social.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        social.icon,
                        size: 20,
                        color: colors.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          if (showSearch) ...[
            const SizedBox(width: BootstrapItaliaSpacing.space2),
            GestureDetector(
              onTap: onSearchTap,
              child: Semantics(
                label: 'Cerca',
                button: true,
                child: Icon(
                  Icons.search,
                  size: 24,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
