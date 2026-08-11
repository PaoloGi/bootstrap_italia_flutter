import 'package:flutter/widgets.dart';

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

  /// Deprecated and ignored.
  ///
  /// This never worked: setting it made [build] return a [SliverAppBar] from a
  /// box context, so the widget threw wherever it was placed —
  /// *"RenderCustomMultiChildLayoutBox expected a child of type RenderBox but
  /// received _RenderSliverPinnedPersistentHeaderForWidgets"*. Pinning requires
  /// a scroll context, which a plain widget cannot create for itself.
  ///
  /// Use [ItSliverHeader] inside a [CustomScrollView] instead. The flag is kept
  /// so existing call sites still compile, but it now renders a normal
  /// (non-pinned) header rather than crashing.
  @Deprecated(
    'Never functioned: returned a sliver from a box build and threw at runtime. '
    'Use ItSliverHeader inside a CustomScrollView. '
    'This flag is ignored and will be removed.',
  )
  final bool sticky;

  /// Creates a composed Bootstrap Italia header.
  const ItHeader({
    super.key,
    this.slimHeader,
    this.centerHeader,
    this.navHeader,
    @Deprecated(
      'Never functioned; ignored. Use ItSliverHeader inside a CustomScrollView.',
    )
    this.sticky = false,
  });

  /// The three bands, in order.
  List<Widget> _bands() => <Widget>[
        if (slimHeader != null) slimHeader!,
        if (centerHeader != null) centerHeader!,
        if (navHeader != null) navHeader!,
      ];

  @override
  Widget build(BuildContext context) {
    assert(() {
      // ignore: deprecated_member_use_from_same_package
      if (sticky) {
        debugPrint(
          'ItHeader(sticky: true) is ignored. Wrap ItSliverHeader in a '
          'CustomScrollView to pin the header while scrolling.',
        );
      }
      return true;
    }());

    return Column(mainAxisSize: MainAxisSize.min, children: _bands());
  }
}

/// A composed Bootstrap Italia header that pins to the top of a scroll view.
///
/// This is a **sliver**: place it in [CustomScrollView.slivers], not in a
/// [Column] or [Scaffold.body]. That constraint is the whole reason
/// [ItHeader.sticky] could not work — pinning needs a scroll context, so the
/// caller has to supply one.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     ItSliverHeader(
///       slimHeader: ItSlimHeader(institutionName: 'Ente'),
///       navHeader: ItNavHeader(items: items),
///     ),
///     SliverList(delegate: ...),
///   ],
/// )
/// ```
class ItSliverHeader extends StatelessWidget {
  /// The top institutional bar.
  final ItSlimHeader? slimHeader;

  /// The center section with logo and title.
  final ItCenterHeader? centerHeader;

  /// The navigation bar.
  final ItNavHeader? navHeader;

  /// Whether the header stays visible while scrolling. When false it scrolls
  /// away like ordinary content.
  final bool pinned;

  /// Creates a pinnable Bootstrap Italia header sliver.
  const ItSliverHeader({
    super.key,
    this.slimHeader,
    this.centerHeader,
    this.navHeader,
    this.pinned = true,
  });

  @override
  Widget build(BuildContext context) {
    // The header's height is content-driven (band count, breakpoint, wrapping
    // nav links), and SliverPersistentHeader requires a fixed extent. Measuring
    // the child and feeding its height back is what SliverAppBar does
    // internally; SliverToBoxAdapter + a pinned overlay would double-paint.
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _ItHeaderDelegate(
        child: ItHeader(
          slimHeader: slimHeader,
          centerHeader: centerHeader,
          navHeader: navHeader,
        ),
      ),
    );
  }
}

class _ItHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ItHeaderDelegate({required this.child});

  final Widget child;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Aligned to the top so the header keeps its intrinsic height instead of
    // being stretched to maxExtent.
    return Align(alignment: Alignment.topCenter, child: child);
  }

  // Bootstrap Italia's bands have fixed heights: slim 48, center 120, nav 57.
  // Using the sum keeps the sliver's extent stable, which is what pinning needs.
  static const double _slim = 48;
  static const double _center = 120;
  static const double _nav = 57;

  double get _extent {
    final header = child as ItHeader;
    return (header.slimHeader != null ? _slim : 0) +
        (header.centerHeader != null ? _center : 0) +
        (header.navHeader != null ? _nav : 0);
  }

  @override
  double get maxExtent => _extent;

  @override
  double get minExtent => _extent;

  @override
  bool shouldRebuild(_ItHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}
