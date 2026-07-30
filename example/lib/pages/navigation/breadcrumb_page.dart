import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class BreadcrumbPage extends StatelessWidget {
  const BreadcrumbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Breadcrumb',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItBreadcrumb(
            items: [
              ItBreadcrumbItem(label: 'Home', onTap: () {}),
              ItBreadcrumbItem(label: 'Servizi', onTap: () {}),
              ItBreadcrumbItem(label: 'Anagrafe'),
            ],
          ),
        ),
        ExampleSection(
          title: 'Con icona',
          child: ItBreadcrumb(
            icon: Icons.home,
            items: [
              ItBreadcrumbItem(label: 'Home', onTap: () {}),
              ItBreadcrumbItem(label: 'Documenti', onTap: () {}),
              ItBreadcrumbItem(label: 'Modulistica'),
            ],
          ),
        ),
        ExampleSection(
          title: 'Dark',
          child: Container(
            color: const Color(0xFF17324D),
            padding: const EdgeInsets.all(16),
            child: ItBreadcrumb(
              dark: true,
              items: [
                ItBreadcrumbItem(label: 'Home', onTap: () {}),
                ItBreadcrumbItem(label: 'Amministrazione', onTap: () {}),
                ItBreadcrumbItem(label: 'Giunta comunale'),
              ],
            ),
          ),
        ),
        ExampleSection(
          title: 'Separatore personalizzato',
          child: ItBreadcrumb(
            separator: '>',
            items: [
              ItBreadcrumbItem(label: 'Home', onTap: () {}),
              ItBreadcrumbItem(label: 'Novità', onTap: () {}),
              ItBreadcrumbItem(label: 'Comunicati stampa'),
            ],
          ),
        ),
      ],
    );
  }
}
