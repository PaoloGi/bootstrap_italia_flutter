import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../routes.dart';

/// The home page of the catalog app.
///
/// Shows all component sections as expandable groups. On wide screens
/// (>= lg breakpoint), displays a master-detail layout with the catalog
/// list on the left and the selected component page on the right.
class HomePage extends StatefulWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// The currently selected route for the detail pane (desktop layout).
  CatalogRoute? _selectedRoute;

  @override
  Widget build(BuildContext context) {
    final biTheme = BootstrapItaliaTheme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= ItBreakpoint.lg.minWidth;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 320,
              child: _buildCatalogPanel(biTheme, isDesktop: true),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _selectedRoute != null
                  ? _selectedRoute!.builder(context)
                  : _buildWelcome(biTheme),
            ),
          ],
        ),
      );
    }

    return _buildCatalogPanel(biTheme, isDesktop: false);
  }

  Widget _buildCatalogPanel(
    BootstrapItaliaThemeData biTheme, {
    required bool isDesktop,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bootstrap Italia Flutter',
              style: TextStyle(
                color: biTheme.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Catalogo componenti',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: biTheme.colors.secondary,
                  ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(
          bottom: BootstrapItaliaSpacing.space5,
        ),
        itemCount: catalogSections.length,
        itemBuilder: (context, sectionIndex) {
          final section = catalogSections[sectionIndex];
          return _SectionGroup(
            section: section,
            selectedRoute: _selectedRoute,
            onRouteTap: (route) {
              if (isDesktop) {
                setState(() => _selectedRoute = route);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: route.builder),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildWelcome(BootstrapItaliaThemeData biTheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.widgets_outlined,
            size: 64,
            color: biTheme.colors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: BootstrapItaliaSpacing.space3),
          Text(
            'Seleziona un componente',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: biTheme.colors.secondary,
                ),
          ),
        ],
      ),
    );
  }
}

/// An expandable section group in the catalog list.
class _SectionGroup extends StatelessWidget {
  final CatalogSection section;
  final CatalogRoute? selectedRoute;
  final ValueChanged<CatalogRoute> onRouteTap;

  const _SectionGroup({
    required this.section,
    required this.selectedRoute,
    required this.onRouteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      title: Text(
        section.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      initiallyExpanded: true,
      children: section.routes.map((route) {
        final isSelected = route == selectedRoute;
        return ListTile(
          leading: Icon(route.icon, size: 20),
          title: Text(route.title),
          selected: isSelected,
          onTap: () => onRouteTap(route),
        );
      }).toList(),
    );
  }
}
