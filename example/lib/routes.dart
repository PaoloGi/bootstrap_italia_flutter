import 'package:flutter/material.dart';

import 'pages/theme/colors_page.dart';
import 'pages/theme/typography_page.dart';
import 'pages/theme/spacing_page.dart';
import 'pages/components/button_page.dart';
import 'pages/components/badge_page.dart';
import 'pages/components/alert_page.dart';
import 'pages/components/spinner_page.dart';
import 'pages/components/chip_page.dart';
import 'pages/components/card_page.dart';
import 'pages/components/accordion_page.dart';
import 'pages/components/collapse_page.dart';
import 'pages/components/tab_page.dart';
import 'pages/components/list_page.dart';
import 'pages/components/callout_page.dart';
import 'pages/form/input_page.dart';
import 'pages/form/autocomplete_page.dart';
import 'pages/form/select_page.dart';
import 'pages/form/checkbox_page.dart';
import 'pages/form/radio_page.dart';
import 'pages/form/toggle_page.dart';
import 'pages/navigation/header_page.dart';
import 'pages/navigation/footer_page.dart';
import 'pages/navigation/breadcrumb_page.dart';
import 'pages/navigation/megamenu_page.dart';
import 'pages/navigation/back_to_top_page.dart';
import 'pages/overlays/modal_page.dart';
import 'pages/overlays/dropdown_page.dart';
import 'pages/overlays/notification_page.dart';

/// A single route entry in the catalog.
class CatalogRoute {
  /// The display title for the route.
  final String title;

  /// The icon shown beside the route title.
  final IconData icon;

  /// Builder that creates the page widget.
  final WidgetBuilder builder;

  const CatalogRoute({
    required this.title,
    required this.icon,
    required this.builder,
  });
}

/// A group of related routes under a section heading.
class CatalogSection {
  /// The section heading.
  final String title;

  /// The routes in this section.
  final List<CatalogRoute> routes;

  const CatalogSection({
    required this.title,
    required this.routes,
  });
}

/// All catalog sections and their routes.
final List<CatalogSection> catalogSections = [
  CatalogSection(title: 'Theme', routes: [
    CatalogRoute(
      title: 'Colori',
      icon: Icons.palette,
      builder: (_) => const ColorsPage(),
    ),
    CatalogRoute(
      title: 'Tipografia',
      icon: Icons.text_fields,
      builder: (_) => const TypographyPage(),
    ),
    CatalogRoute(
      title: 'Spaziatura',
      icon: Icons.space_bar,
      builder: (_) => const SpacingPage(),
    ),
  ]),
  CatalogSection(title: 'Componenti', routes: [
    CatalogRoute(
      title: 'Button',
      icon: Icons.smart_button,
      builder: (_) => const ButtonPage(),
    ),
    CatalogRoute(
      title: 'Badge',
      icon: Icons.verified,
      builder: (_) => const BadgePage(),
    ),
    CatalogRoute(
      title: 'Alert',
      icon: Icons.warning_amber,
      builder: (_) => const AlertPage(),
    ),
    CatalogRoute(
      title: 'Spinner',
      icon: Icons.refresh,
      builder: (_) => const SpinnerPage(),
    ),
    CatalogRoute(
      title: 'Chip',
      icon: Icons.label,
      builder: (_) => const ChipPage(),
    ),
    CatalogRoute(
      title: 'Card',
      icon: Icons.credit_card,
      builder: (_) => const CardPage(),
    ),
    CatalogRoute(
      title: 'Accordion',
      icon: Icons.expand_more,
      builder: (_) => const AccordionPage(),
    ),
    CatalogRoute(
      title: 'Collapse',
      icon: Icons.unfold_more,
      builder: (_) => const CollapsePage(),
    ),
    CatalogRoute(
      title: 'Tab',
      icon: Icons.tab,
      builder: (_) => const TabPage(),
    ),
    CatalogRoute(
      title: 'Liste',
      icon: Icons.list,
      builder: (_) => const ListPage(),
    ),
    CatalogRoute(
      title: 'Callout',
      icon: Icons.info_outline,
      builder: (_) => const CalloutPage(),
    ),
  ]),
  CatalogSection(title: 'Form', routes: [
    CatalogRoute(
      title: 'Input',
      icon: Icons.text_fields,
      builder: (_) => const InputPage(),
    ),
    CatalogRoute(
      title: 'Autocompletamento',
      icon: Icons.search,
      builder: (_) => const AutocompletePage(),
    ),
    CatalogRoute(
      title: 'Select',
      icon: Icons.arrow_drop_down,
      builder: (_) => const SelectPage(),
    ),
    CatalogRoute(
      title: 'Checkbox',
      icon: Icons.check_box,
      builder: (_) => const CheckboxPage(),
    ),
    CatalogRoute(
      title: 'Radio',
      icon: Icons.radio_button_checked,
      builder: (_) => const RadioPage(),
    ),
    CatalogRoute(
      title: 'Toggle',
      icon: Icons.toggle_on,
      builder: (_) => const TogglePage(),
    ),
  ]),
  CatalogSection(title: 'Navigazione', routes: [
    CatalogRoute(
      title: 'Header',
      icon: Icons.web,
      builder: (_) => const HeaderPage(),
    ),
    CatalogRoute(
      title: 'Footer',
      icon: Icons.web,
      builder: (_) => const FooterPage(),
    ),
    CatalogRoute(
      title: 'Breadcrumb',
      icon: Icons.arrow_forward,
      builder: (_) => const BreadcrumbPage(),
    ),
    CatalogRoute(
      title: 'Megamenu',
      icon: Icons.menu_open,
      builder: (_) => const MegamenuPage(),
    ),
    CatalogRoute(
      title: 'Torna su',
      icon: Icons.arrow_upward,
      builder: (_) => const BackToTopPage(),
    ),
  ]),
  CatalogSection(title: 'Overlay', routes: [
    CatalogRoute(
      title: 'Modal',
      icon: Icons.open_in_new,
      builder: (_) => const ModalPage(),
    ),
    CatalogRoute(
      title: 'Dropdown',
      icon: Icons.arrow_drop_down_circle,
      builder: (_) => const DropdownPage(),
    ),
    CatalogRoute(
      title: 'Notification',
      icon: Icons.notifications,
      builder: (_) => const NotificationPage(),
    ),
  ]),
];
