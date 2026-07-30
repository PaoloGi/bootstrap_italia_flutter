import 'package:flutter/material.dart';

import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/spacing.dart';

/// A link within a footer section.
class ItFooterLink {
  /// The link label.
  final String label;

  /// Called when tapped.
  final VoidCallback? onTap;

  /// Creates a footer link.
  const ItFooterLink({required this.label, this.onTap});
}

/// A section of links in the footer.
class ItFooterSection {
  /// The section title.
  final String title;

  /// The links in this section.
  final List<ItFooterLink> links;

  /// Creates a footer section.
  const ItFooterSection({required this.title, required this.links});
}

/// A social link in the footer.
class ItFooterSocialLink {
  /// The icon.
  final IconData icon;

  /// Accessibility label.
  final String label;

  /// Called when tapped.
  final VoidCallback? onTap;

  /// Creates a footer social link.
  const ItFooterSocialLink({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

/// A Bootstrap Italia footer.
///
/// A standard PA-compliant footer with logo, sections of links, social
/// media links, and a bottom legal bar.
///
/// ```dart
/// ItFooter(
///   logo: Image.asset('assets/logo.png', height: 48),
///   institutionName: 'Comune di Roma',
///   description: 'Piazza del Campidoglio, 1 - 00186 Roma',
///   sections: [
///     ItFooterSection(title: 'Amministrazione', links: [...]),
///     ItFooterSection(title: 'Servizi', links: [...]),
///   ],
///   socialLinks: [
///     ItFooterSocialLink(icon: Icons.facebook, label: 'Facebook'),
///   ],
///   legalInfo: [
///     ItFooterLink(label: 'Privacy policy'),
///     ItFooterLink(label: 'Note legali'),
///   ],
/// )
/// ```
class ItFooter extends StatelessWidget {
  /// The institution logo.
  final Widget? logo;

  /// The institution name.
  final String institutionName;

  /// Optional description text (address, contacts, etc.).
  final String? description;

  /// Link sections.
  final List<ItFooterSection> sections;

  /// Social media links.
  final List<ItFooterSocialLink> socialLinks;

  /// Bottom bar legal links.
  final List<ItFooterLink> legalInfo;

  /// Background color. Defaults to dark.
  final Color? backgroundColor;

  /// Creates a Bootstrap Italia footer.
  const ItFooter({
    super.key,
    this.logo,
    required this.institutionName,
    this.description,
    this.sections = const [],
    this.socialLinks = const [],
    this.legalInfo = const [],
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final bgColor = backgroundColor ?? colors.dark;

    return Container(
      width: double.infinity,
      color: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main footer content
          Padding(
            padding: const EdgeInsets.all(BootstrapItaliaSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo + institution name
                Row(
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
                            institutionName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.white,
                            ),
                          ),
                          if (description != null) ...[
                            const SizedBox(
                                height: BootstrapItaliaSpacing.space1),
                            Text(
                              description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.neutral2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Link sections
                if (sections.isNotEmpty) ...[
                  const SizedBox(height: BootstrapItaliaSpacing.space4),
                  Wrap(
                    spacing: BootstrapItaliaSpacing.space5,
                    runSpacing: BootstrapItaliaSpacing.space4,
                    children: sections.map((s) => _buildSection(s, colors)).toList(),
                  ),
                ],

                // Social links
                if (socialLinks.isNotEmpty) ...[
                  const SizedBox(height: BootstrapItaliaSpacing.space4),
                  Row(
                    children: [
                      Text(
                        'Seguici su',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.white,
                        ),
                      ),
                      const SizedBox(width: BootstrapItaliaSpacing.space3),
                      ...socialLinks.map((social) {
                        return Semantics(
                          label: social.label,
                          child: GestureDetector(
                            onTap: social.onTap,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                social.icon,
                                size: 24,
                                color: colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Bottom legal bar
          if (legalInfo.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: BootstrapItaliaSpacing.space4,
                vertical: BootstrapItaliaSpacing.space2 + 4,
              ),
              color: colors.black.withAlpha(51),
              child: Wrap(
                spacing: BootstrapItaliaSpacing.space3,
                runSpacing: BootstrapItaliaSpacing.space1,
                children: legalInfo.map((link) {
                  return GestureDetector(
                    onTap: link.onTap,
                    child: Text(
                      link.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.neutral2,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(ItFooterSection section, BootstrapItaliaColorScheme colors) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.white,
            ),
          ),
          const SizedBox(height: BootstrapItaliaSpacing.space2),
          ...section.links.map((link) {
            return GestureDetector(
              onTap: link.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  link.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.neutral2,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
