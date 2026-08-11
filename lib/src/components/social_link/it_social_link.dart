import 'package:flutter/widgets.dart';

/// A link to a social media profile, used by [ItCenterHeader] and [ItFooter].
///
/// Bootstrap Italia renders the same `.it-socials` list in both bands —
/// `.it-header-center-content-wrapper .it-socials` and
/// `.it-footer-main .it-socials` differ only in the colour they inherit — so
/// the two carry one description between them.
///
/// This class had a field-identical twin, `ItFooterSocialLink`, declared in
/// `it_footer.dart`. Two names for one record is two things to keep in step,
/// and they had already drifted apart in their doc comments. It lives in its
/// own file rather than in either component so that neither the header nor the
/// footer has to import the other to describe its own socials.
class ItSocialLink {
  /// The social platform icon.
  final IconData icon;

  /// Accessible name for the link.
  ///
  /// An icon-only link with no name is announced as just "link", which tells a
  /// screen-reader user nothing about where it goes (WCAG 2.4.4, 4.1.2). Name
  /// the platform: 'Facebook', 'GitHub'.
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
