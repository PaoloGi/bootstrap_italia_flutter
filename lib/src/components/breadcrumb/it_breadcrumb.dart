import 'package:flutter/widgets.dart';
import 'package:flutter/semantics.dart';

import '../../l10n/it_localizations.dart';
import '../../a11y/it_activatable.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/typography.dart';

/// A single item within an [ItBreadcrumb].
class ItBreadcrumbItem {
  /// The display label.
  final String label;

  /// Called when tapped. Null for the current (last) item.
  ///
  /// There was an `href` field beside this one, never read by anything: the
  /// package does not own a router, so a URL string had nothing to navigate.
  /// Callers wire their own navigation through [onTap].
  final VoidCallback? onTap;

  /// Optional leading icon rendered before the label.
  ///
  /// Falls back to [ItBreadcrumb.icon] when null.
  final IconData? icon;

  /// Creates a breadcrumb item.
  const ItBreadcrumbItem({
    required this.label,
    this.onTap,
    this.icon,
  });
}

/// A Bootstrap Italia breadcrumb navigation.
///
/// Shows a trail of navigation links with separators. The last item is
/// rendered as the current page (non-interactive).
///
/// ```dart
/// ItBreadcrumb(
///   items: [
///     ItBreadcrumbItem(label: 'Home', onTap: () => navigate('/')),
///     ItBreadcrumbItem(label: 'Servizi', onTap: () => navigate('/servizi')),
///     ItBreadcrumbItem(label: 'Anagrafe'),
///   ],
/// )
/// ```
class ItBreadcrumb extends StatelessWidget {
  /// The breadcrumb items.
  final List<ItBreadcrumbItem> items;

  /// Default leading icon applied to every item that does not define its own.
  final IconData? icon;

  /// Whether to use the dark background variant (light text).
  final bool dark;

  /// The separator rendered between items.
  final String separator;

  /// Creates a Bootstrap Italia breadcrumb.
  const ItBreadcrumb({
    super.key,
    required this.items,
    this.icon,
    this.dark = false,
    this.separator = '/',
  });

  // ── Bootstrap Italia `.breadcrumb-container` metrics ──────────────
  // .breadcrumb-container            { --bs-breadcrumb-font-size: 1rem }
  // .breadcrumb-container .breadcrumb{ padding: .5em 0 }
  //   -> computed line-height 28px, font-size 16px, box height 44px
  static const double _fontSize = 16;
  static const double _lineHeight = 28;
  static const double _paddingY = 8;

  // .breadcrumb.dark          { background: hsl(210,25%,35.2%) }  #435A70
  static const Color _darkBg = Color(0xFF435A70);
  // .breadcrumb-item a        { color: hsl(210,33%,28%) }         #30475F
  static const Color _linkColor = Color(0xFF30475F);
  // --bs-breadcrumb-item-active-color: hsl(0,0%,32%)              #525252
  static const Color _activeColor = Color(0xFF525252);
  // .breadcrumb.dark .breadcrumb-item i { color: rgb(11,217,210) } #0BD9D2
  static const Color _darkIconColor = Color(0xFF0BD9D2);

  TextStyle get _base => const TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        fontSize: _fontSize,
        height: _lineHeight / _fontSize,
        leadingDistribution: TextLeadingDistribution.even,
      );

  @override
  Widget build(BuildContext context) {
    final linkColor = dark ? const Color(0xFFFFFFFF) : _linkColor;
    final activeColor = dark ? const Color(0xFFFFFFFF) : _activeColor;
    // `span.separator { color: hsl(210,17%,44%) }` is the secondary token.
    final separatorColor =
        dark ? const Color(0xFFFFFFFF) : resolveColorScheme(context).secondary;
    final iconColor = dark ? _darkIconColor : null;

    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isCurrent = i == items.length - 1;
      final itemIcon = item.icon ?? icon;
      if (itemIcon != null) {
        children.add(
          Padding(
            // .breadcrumb-item svg { margin-right: 4px }
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              itemIcon,
              size: 24,
              color: iconColor ?? (isCurrent ? activeColor : linkColor),
            ),
          ),
        );
      }
      children.add(
        _buildItem(item, isCurrent, linkColor, activeColor),
      );
      if (!isCurrent) {
        children.add(
          // The "/" is presentational punctuation; announcing it between every
          // crumb is noise, so hide it from AT (§1.3.1).
          ExcludeSemantics(
            child: Padding(
              // span.separator { padding: 0 .5em }
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                separator,
                style: _base.copyWith(
                  fontWeight: FontWeight.w600,
                  color: separatorColor,
                ),
              ),
            ),
          ),
        );
      }
    }

    // §1.3.1 Info and Relationships: expose the trail as a navigation landmark
    // so AT can offer it as a jump target, and `explicitChildNodes` so each
    // crumb stays its own node instead of collapsing into one run-on string.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.navigation,
      // Routed through the localisations even though every bundled locale
      // spells it the same way — `<nav aria-label="breadcrumb">` is what
      // Bootstrap Italia itself emits in an Italian page. Routing it anyway is
      // what makes the value overridable by an administration whose style guide
      // says "Percorso di navigazione"; a literal would not be.
      label: ItLocalizations.of(context).breadcrumb,
      child: DecoratedBox(
        decoration: BoxDecoration(color: dark ? _darkBg : null),
        child: Padding(
          // .breadcrumb { padding: .5em 0 }; the dark story adds `px-3`.
          padding: EdgeInsets.symmetric(
            vertical: _paddingY,
            horizontal: dark ? 16 : 0,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    ItBreadcrumbItem item,
    bool isCurrent,
    Color linkColor,
    Color activeColor,
  ) {
    if (isCurrent) {
      // §2.4.8 Location: the last crumb is the current page. `selected` is
      // Flutter's `aria-current` equivalent — without it AT announces the trail
      // as a flat list and never says where the user actually is.
      return Semantics(
        selected: true,
        label: item.label,
        child: ExcludeSemantics(
          child: SizedBox(
            height: _lineHeight,
            // .breadcrumb-item.active a { font-weight: 400 }
            child: Text(
              item.label,
              style: _base.copyWith(
                fontWeight: FontWeight.w400,
                color: activeColor,
              ),
            ),
          ),
        ),
      );
    }

    // §2.4.4 Link Purpose / §2.1.1 Keyboard: each crumb is a real link, so it
    // must carry the link role and be reachable by keyboard.
    return Semantics(
      link: true,
      label: item.label,
      child: ItActivatable(
        onPressed: item.onTap,
        child: ExcludeSemantics(
          child: SizedBox(
            height: _lineHeight,
            child: Text(
              item.label,
              style: _base.copyWith(
                // .breadcrumb-item a { font-weight: 600; text-decoration: underline }
                fontWeight: FontWeight.w600,
                color: linkColor,
                decoration: TextDecoration.underline,
                decorationColor: linkColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
