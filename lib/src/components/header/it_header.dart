import 'package:flutter/material.dart';

import 'it_center_header.dart';
import 'it_nav_header.dart';
import 'it_slim_header.dart';

/// A composed Bootstrap Italia header.
///
/// Combines [ItSlimHeader], [ItCenterHeader], and [ItNavHeader] into a
/// complete institutional header.
///
/// Each sub-header is optional. You can also use the individual components
/// directly for more control.
///
/// ```dart
/// ItHeader(
///   slimHeader: ItSlimHeader(institutionName: 'Repubblica Italiana'),
///   centerHeader: ItCenterHeader(title: 'Comune di Roma'),
///   navHeader: ItNavHeader(items: [...]),
/// )
/// ```
class ItHeader extends StatelessWidget {
  /// The top institutional bar.
  final ItSlimHeader? slimHeader;

  /// The center section with logo and title.
  final ItCenterHeader? centerHeader;

  /// The navigation bar.
  final ItNavHeader? navHeader;

  /// Whether the header sticks to the top on scroll.
  final bool sticky;

  /// Creates a composed Bootstrap Italia header.
  const ItHeader({
    super.key,
    this.slimHeader,
    this.centerHeader,
    this.navHeader,
    this.sticky = false,
  });

  @override
  Widget build(BuildContext context) {
    final header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (slimHeader != null) slimHeader!,
        if (centerHeader != null) centerHeader!,
        if (navHeader != null) navHeader!,
      ],
    );

    if (!sticky) return header;

    return SliverAppBar(
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
      toolbarHeight: 0,
      expandedHeight: 0,
      flexibleSpace: header,
    );
  }
}
