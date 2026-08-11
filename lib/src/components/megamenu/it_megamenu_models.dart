// The megamenu's data model — the four value types a caller assembles a menu
// out of, with no widget, layout or painting code among them.
//
// Its own file because it is the whole of the component's authoring vocabulary:
// somebody wiring up a menu reads only this, and never has to scroll past the
// three renderers to find it. All three of those renderers — the desktop bar,
// the desktop panel and the mobile overlay — consume these types, so the model
// belongs to none of them individually.

import 'package:flutter/widgets.dart';

/// A single link within a megamenu column.
class ItMegamenuLink {
  /// The link label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the link is tapped.
  final VoidCallback? onTap;

  /// Optional description text shown below the label.
  final String? description;

  /// Creates a megamenu link.
  const ItMegamenuLink({
    required this.label,
    this.icon,
    this.onTap,
    this.description,
  });
}

/// A column of links within a megamenu section.
class ItMegamenuColumn {
  /// Optional heading displayed above the links.
  final String? heading;

  /// The links in this column.
  final List<ItMegamenuLink> links;

  /// Creates a megamenu column.
  const ItMegamenuColumn({
    this.heading,
    required this.links,
  });
}

/// A call-to-action link in the megamenu header or footer area.
class ItMegamenuCta {
  /// The CTA label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the CTA is tapped.
  final VoidCallback? onTap;

  /// Creates a megamenu CTA.
  const ItMegamenuCta({
    required this.label,
    this.icon,
    this.onTap,
  });
}

/// A top-level section in the megamenu.
///
/// Each section appears as a nav item in the bar. When expanded, it shows
/// its [columns] of links along with optional description, image, and CTAs.
class ItMegamenuSection {
  /// The section label shown in the nav bar.
  final String label;

  /// Optional icon shown beside the label.
  final IconData? icon;

  /// The link columns displayed when this section is open.
  final List<ItMegamenuColumn> columns;

  /// Optional description text shown in the left panel (desktop).
  final String? description;

  /// Optional image widget shown in the left panel (desktop).
  final Widget? image;

  /// Optional header CTA (e.g. "Esplora la sezione").
  final ItMegamenuCta? headerCta;

  /// Optional footer CTA (e.g. "Esplora tutti").
  final ItMegamenuCta? footerCta;

  /// Whether this section is currently active.
  final bool active;

  /// Creates a megamenu section.
  const ItMegamenuSection({
    required this.label,
    this.icon,
    required this.columns,
    this.description,
    this.image,
    this.headerCta,
    this.footerCta,
    this.active = false,
  });
}
