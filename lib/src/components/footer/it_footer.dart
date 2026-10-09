import 'package:flutter/widgets.dart';
import 'package:flutter/semantics.dart';

import '../../l10n/it_localizations.dart';
import '../../a11y/it_activatable.dart';
import '../../tokens/typography.dart';
import '../../utilities/interaction_states.dart';
import '../social_link/it_social_link.dart';

/// A link within a footer section.
class ItFooterLink {
  /// The link label.
  final String label;

  /// Called when tapped.
  final VoidCallback? onTap;

  /// Creates a footer link.
  const ItFooterLink({required this.label, this.onTap});
}

/// A column of links in the footer.
class ItFooterSection {
  /// The column heading (rendered uppercase).
  final String title;

  /// Called when the heading itself is tapped.
  final VoidCallback? onTitleTap;

  /// The links in this column.
  final List<ItFooterLink> links;

  /// Free content between the heading and the links.
  ///
  /// The kit's contacts column is `<h4>Contatti</h4>` followed by a `<p>` —
  /// the administration's postal address and tax code — and only then the link
  /// list. A `Widget` rather than a `String` because that paragraph is not
  /// plain: the docs set the institution's name in `<strong>` on its own line,
  /// which no single styled run can express. Same reason
  /// [ItMegamenuSection.image] is a widget.
  final Widget? content;

  /// Creates a footer section.
  const ItFooterSection({
    required this.title,
    required this.links,
    this.onTitleTap,
    this.content,
  });
}

// ── Bootstrap Italia footer tokens ────────────────────────────────

/// `.it-footer-main { background-color: rgb(0,76.5,153) }`
const Color _footerMainBg = Color(0xFF004D99);

/// `.it-footer-small-prints { background-color: #036 }`
const Color _footerSmallPrintsBg = Color(0xFF003366);

/// `.container` max-width at the `xl` breakpoint.
const double _containerMaxWidth = 1176;

/// `.container` horizontal padding.
const double _containerPadding = 12;

/// `.it-footer-main section { padding: 0 16px }`
const double _sectionPadding = 16;

/// `.row` negative gutter / `.col` padding pair.
const double _gutter = 12;

/// `.it-footer a:hover { color: hsl(0, 0%, 90%) }`
///
/// The footer sits on a dark blue, so here the design system genuinely does
/// move *lighter* on hover — but to a specific `rgb(230, 230, 230)`, and by
/// recolouring the text rather than by tinting the background the way Material
/// would. Measured on the React kit for the hover and the pressed state alike.
const Color _footerLinkHoverColor = Color(0xFFE6E6E6);

TextStyle _style({
  required double size,
  required double lineHeight,
  FontWeight weight = FontWeight.w400,
  bool underline = false,
  Color color = const Color(0xFFFFFFFF),
}) {
  return TextStyle(
    fontFamily: BootstrapItaliaFontFamily.sansSerif,
    package: BootstrapItaliaFontFamily.package,
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
    color: color,
    decoration: underline ? TextDecoration.underline : TextDecoration.none,
    decorationColor: color,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

/// The footer's branding block (`.it-footer-main .it-brand-wrapper`).
///
/// Rendered by [ItFooter]; public so it can be placed on its own.
class ItFooterBrand extends StatelessWidget {
  /// The institution logo, laid out in a 48x48 box.
  final Widget? logo;

  /// The institution name.
  final String institutionName;

  /// Optional tag line rendered beneath the name.
  final String? description;

  /// Creates the footer brand block.
  const ItFooterBrand({
    super.key,
    this.logo,
    required this.institutionName,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // `.it-footer-main section { padding: 0 16px }`; the row's -12px
      // margin cancels the column's 12px padding, so 16px is the net inset.
      padding: const EdgeInsets.symmetric(horizontal: _sectionPadding),
      child: Padding(
        // `.it-brand-wrapper { padding: 32px 0 }`
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (logo != null)
              Padding(
                // `.it-brand-wrapper a .icon { width/height: 48px;
                //   margin-right: 8px }`
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: IconTheme.merge(
                    data:
                        const IconThemeData(color: Color(0xFFFFFFFF), size: 48),
                    child: logo!,
                  ),
                ),
              ),
            Padding(
              // `.it-brand-text { padding-right: 24px }`
              padding: const EdgeInsets.only(right: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // §1.3.1: the kit marks these up as <h2>/<h3>. Carrying the
                  // real heading levels lets AT build a document outline and
                  // lets users navigate the footer by heading.
                  Semantics(
                    header: true,
                    headingLevel: 2,
                    child: Text(
                      // `h2 { font-size: 1.25rem; font-weight: 600;
                      //   line-height: 1.1 }`
                      institutionName,
                      style: _style(
                        size: 20,
                        lineHeight: 22,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (description != null)
                    Semantics(
                      header: true,
                      headingLevel: 3,
                      child: Text(
                        // `h3 { font-size: .875rem; font-weight: normal }`,
                        // inheriting the base `h3` 40px line-height.
                        description!,
                        style: _style(size: 14, lineHeight: 40),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The footer's grid of link columns (`.it-footer-main section .row`).
class ItFooterLinkColumns extends StatelessWidget {
  /// The link columns.
  final List<ItFooterSection> sections;

  /// Creates the footer link grid.
  const ItFooterLinkColumns({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _sectionPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            // `.row { margin: 0 -12px }` cancels the outer `.col` padding, so
            // the columns sit flush with the section and are separated by
            // 2 x 12px of gutter.
            if (i > 0) const SizedBox(width: _gutter * 2),
            Expanded(child: _Column(section: sections[i])),
          ],
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  final ItFooterSection section;

  const _Column({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // The story's `pb-2` (8px) on each column.
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // `h4 { font-size: 1rem; font-weight: 600; line-height: 32px;
          //   text-transform: uppercase; margin-bottom: 8px }`
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              header: true,
              headingLevel: 4,
              link: section.onTitleTap != null,
              label: section.title,
              child: ItHoverBuilder(
                enabled: section.onTitleTap != null,
                cursor: section.onTitleTap == null
                    ? MouseCursor.defer
                    : SystemMouseCursors.click,
                builder: (context, hovered) => ItActivatable(
                  onPressed: section.onTitleTap,
                  child: ExcludeSemantics(
                    child: Text(
                      section.title.toUpperCase(),
                      style: _style(
                        size: 16,
                        lineHeight: 32,
                        weight: FontWeight.w600,
                        underline: true,
                        color: hovered
                            ? _footerLinkHoverColor
                            : const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (section.content != null)
            Padding(
              // `.it-footer-main p { margin-bottom: 16px }` — the paragraph
              // clears the link list beneath it.
              padding: const EdgeInsets.only(bottom: 16),
              child: DefaultTextStyle(
                // `.it-footer-main { color: #fff }` with the body's 1rem/1.5
                // paragraph scale; caller content inherits it rather than
                // having to restate white on a dark blue band.
                style: _style(size: 16, lineHeight: 24),
                child: section.content!,
              ),
            ),
          // §2.4.4 / §2.1.1: every footer link needs the link role, its own
          // accessible name and keyboard reachability.
          for (final link in section.links)
            Semantics(
              link: true,
              label: link.label,
              child: ItHoverBuilder(
                cursor: SystemMouseCursors.click,
                builder: (context, hovered) => ItActivatable(
                  onPressed: link.onTap,
                  child: ExcludeSemantics(
                    child: SizedBox(
                      // `.link-list-wrapper ul li a { line-height: 2rem }`
                      height: 32,
                      width: double.infinity,
                      child: Text(
                        link.label,
                        style: _style(
                          size: 16,
                          lineHeight: 32,
                          underline: true,
                          color: hovered
                              ? _footerLinkHoverColor
                              : const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // `ul.link-list { margin-bottom: 16px }`
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// The footer's bottom legal bar (`.it-footer-small-prints`).
class ItFooterSmallPrints extends StatelessWidget {
  /// The legal links.
  final List<ItFooterLink> links;

  /// Creates the small-prints bar.
  const ItFooterSmallPrints({super.key, required this.links});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _footerSmallPrintsBg,
      child: Align(
        // Shrink-wrap vertically; `Center` alone would fill the parent.
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _containerMaxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _containerPadding),
            child: Padding(
              // `ul.it-footer-small-prints-list { padding: 1.5rem 1rem }`
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              // `ul.it-footer-small-prints-list` is
              // `d-flex flex-column flex-md-row`: a column on a narrow screen,
              // a row from `md` up, and even then a flex row whose items shrink
              // rather than overflow. A [Row] does neither — it lays every link
              // out at natural width and reports an overflow for the surplus,
              // which is what the docs' own five links do, the last of them
              // being "Dichiarazione di accessibilità (link esterno su sito
              // AgID)". A [Wrap] is the closest honest equivalent: it keeps the
              // single-line layout while the links fit, and moves the surplus
              // onto another line instead of off the band.
              // Full width, explicitly. A `Wrap` shrink-wraps under the loose
              // constraints the enclosing container passes down, so the `Align`
              // above then centres it — where the `Row` this replaced filled
              // the band and started at the left edge, as the reference does.
              // That alone took `nav_footer_smallprints` to 87.6%.
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 40,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < links.length; i++) ...[
                      Semantics(
                        link: true,
                        label: links[i].label,
                        child: ItHoverBuilder(
                          cursor: SystemMouseCursors.click,
                          builder: (context, hovered) => ItActivatable(
                            onPressed: links[i].onTap,
                            child: ExcludeSemantics(
                              child: Text(
                                links[i].label,
                                style: _style(
                                  size: 16,
                                  lineHeight: 28,
                                  underline: true,
                                  color: hovered
                                      ? _footerLinkHoverColor
                                      : const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The contacts band's social column: `<h4>Seguici su</h4>` over a row of
/// icon links.
///
/// `.it-footer-main h4 { font-size: 1rem; font-weight: 600; line-height: 32px;
///   text-transform: uppercase; margin-bottom: 8px }` — the same heading the
/// link columns use, so it is rendered from the same metrics rather than a
/// second set that could drift.
class _SocialColumn extends StatelessWidget {
  final ItFooter footer;

  const _SocialColumn({required this.footer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Semantics(
            header: true,
            headingLevel: 4,
            child: Text(
              (footer.socialsLabel ?? ItLocalizations.of(context).followUs)
                  .toUpperCase(),
              style: _style(size: 16, lineHeight: 32, weight: FontWeight.w600),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // `<ul class="list-inline social"> … <a class="p-2 text-white">`:
            // the glyph carries no text, so `social.label` — which the kit
            // supplies as a `.visually-hidden` span — is the only accessible
            // name this control will ever have (§2.4.4). The 8px `p-2` inset
            // makes the target 40x40 around a 24px glyph, clearing §2.5.8.
            for (final social in footer.socialLinks)
              Semantics(
                label: social.label,
                link: true,
                child: ItHoverBuilder(
                  cursor: SystemMouseCursors.click,
                  builder: (context, hovered) => ItActivatable(
                    onPressed: social.onTap,
                    child: ExcludeSemantics(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          social.icon,
                          size: 24,
                          // The socials are anchors, so `.it-footer a:hover`
                          // applies to their glyph too.
                          color: hovered
                              ? _footerLinkHoverColor
                              : const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A Bootstrap Italia footer.
///
/// A standard Bootstrap Italia footer with a branding block, columns of links,
/// optional social links and a bottom legal bar.
///
/// ```dart
/// ItFooter(
///   logo: Icon(BootstrapItaliaIcons.it_pa),
///   institutionName: 'Nome del Comune',
///   description: 'Uno dei tanti Comuni d Italia',
///   sections: [
///     ItFooterSection(title: 'Amministrazione', links: [...]),
///     ItFooterSection(title: 'Servizi', links: [...]),
///   ],
///   legalInfo: [
///     ItFooterLink(label: 'Media policy'),
///     ItFooterLink(label: 'Note legali'),
///   ],
/// )
/// ```
class ItFooter extends StatelessWidget {
  /// The institution logo.
  final Widget? logo;

  /// The institution name.
  final String institutionName;

  /// Optional tag line beneath the institution name.
  final String? description;

  /// Link sections.
  final List<ItFooterSection> sections;

  /// Columns for the footer's contacts band.
  ///
  /// Bootstrap Italia closes the footer with a second `<section>` —
  /// `class="py-4 border-white border-top"` — holding the administration's
  /// contact details and the social links. It is a band, not just another row:
  /// a 1px white rule across the top and 24px of padding separate it from the
  /// link columns above.
  ///
  /// [socialLinks] joins this band as its last column when it is non-empty,
  /// under a `Seguici su` heading, which is where the kit puts them. With no
  /// contact columns there is no band to join, so they keep the inline row
  /// beneath the link grid that this component has always rendered.
  final List<ItFooterSection> contactSections;

  /// Social media links.
  final List<ItSocialLink> socialLinks;

  /// Label rendered before the social icons.
  ///
  /// Defaults to `'Seguici su'`, with no
  /// installed. Shares the key with [ItCenterHeader.socialsLabel]: the same
  /// phrase on the same page, so one string.
  final String? socialsLabel;

  /// Bottom bar legal links.
  final List<ItFooterLink> legalInfo;

  /// Background color for the main block. Defaults to `#004D99`.
  final Color? backgroundColor;

  /// An accessible name for the `contentinfo` landmark this footer publishes.
  ///
  /// Null by default, which is right for a real page: there is one footer, and
  /// naming a landmark that has no sibling only adds an announcement. Two on
  /// one page — which is what the docs' *"footer completo"* and *"footer solo
  /// contatti"* are, side by side — have to be told apart, and Flutter asserts
  /// on it: *"the contentInfo landmark role should have a unique label as it is
  /// used more than once"*.
  final String? semanticsLabel;

  /// Creates a Bootstrap Italia footer.
  const ItFooter({
    super.key,
    this.logo,
    required this.institutionName,
    this.description,
    this.sections = const [],
    this.contactSections = const [],
    this.socialLinks = const [],
    this.socialsLabel,
    this.legalInfo = const [],
    this.backgroundColor,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    // §1.3.1 Info and Relationships: a footer is the `contentinfo` landmark.
    // Exposing it lets AT users jump straight to (or past) the legal block
    // instead of arrowing through it.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.contentInfo,
      label: semanticsLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: backgroundColor ?? _footerMainBg,
            child: Align(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _containerMaxWidth),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: _containerPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ItFooterBrand(
                        logo: logo,
                        institutionName: institutionName,
                        description: description,
                      ),
                      if (sections.isNotEmpty)
                        ItFooterLinkColumns(sections: sections),
                      if (contactSections.isNotEmpty)
                        _buildContactsBand(context)
                      else if (socialLinks.isNotEmpty)
                        _buildSocials(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (legalInfo.isNotEmpty) ItFooterSmallPrints(links: legalInfo),
        ],
      ),
    );
  }

  /// `<section class="py-4 border-white border-top">` — the contacts band.
  ///
  /// `.py-4 { padding-top: 24px; padding-bottom: 24px }` and
  /// `.border-top.border-white { border-top: 1px solid #fff }`. The social
  /// column is appended rather than being a caller-supplied section, because
  /// its heading and its icon row are the component's, not the caller's.
  Widget _buildContactsBand(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFFFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _sectionPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < contactSections.length; i++) ...[
              if (i > 0) const SizedBox(width: _gutter * 2),
              Expanded(child: _Column(section: contactSections[i])),
            ],
            if (socialLinks.isNotEmpty) ...[
              if (contactSections.isNotEmpty)
                const SizedBox(width: _gutter * 2),
              Expanded(child: _SocialColumn(footer: this)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSocials(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _sectionPadding,
        0,
        _sectionPadding,
        24,
      ),
      child: Row(
        children: [
          Text(
            (socialsLabel ?? ItLocalizations.of(context).followUs)
                .toUpperCase(),
            style: _style(size: 16, lineHeight: 32, weight: FontWeight.w600),
          ),
          // The glyph carries no text, so `social.label` is the only accessible
          // name this control will ever have (§2.4.4). §2.5.8: the painted
          // glyph is 24x24 and the 16px lead-in padding is part of the hit
          // target, so the real target is 40x24 — at the minimum on the short
          // axis without touching the artwork.
          for (final social in socialLinks)
            Semantics(
              label: social.label,
              link: true,
              child: ItHoverBuilder(
                cursor: SystemMouseCursors.click,
                builder: (context, hovered) => ItActivatable(
                  onPressed: social.onTap,
                  child: ExcludeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Icon(
                        social.icon,
                        size: 24,
                        // The socials are anchors, so `.it-footer a:hover`
                        // applies to their glyph too.
                        color: hovered
                            ? _footerLinkHoverColor
                            : const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
