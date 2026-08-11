import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class HeaderPage extends StatelessWidget {
  const HeaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Header',
      children: [
        ExampleSection(
          title: 'Slim Header',
          child: ItSlimHeader(
            institutionName: 'Repubblica Italiana',
            links: [
              ItSlimHeaderLink(label: 'ITA', active: true),
              ItSlimHeaderLink(label: 'ENG', onTap: () {}),
              ItSlimHeaderLink(label: 'Accedi', onTap: () {}),
            ],
          ),
        ),
        ExampleSection(
          title: 'Center Header',
          child: ItCenterHeader(
            title: 'Comune di Roma',
            subtitle: 'Portale istituzionale',
            showSearch: true,
            onSearchTap: () {},
          ),
        ),
        ExampleSection(
          title: 'Nav Header',
          child: ItNavHeader(
            items: [
              ItNavItem(label: 'Amministrazione', active: true, onTap: () {}),
              ItNavItem(label: 'Servizi', onTap: () {}),
              ItNavItem(label: 'Novità', onTap: () {}),
              ItNavItem(label: 'Documenti', onTap: () {}),
            ],
          ),
        ),
        ExampleSection(
          title: 'Header completo',
          child: ItHeader(
            slimHeader: ItSlimHeader(
              institutionName: 'Repubblica Italiana',
              links: [
                ItSlimHeaderLink(label: 'ITA', active: true),
                ItSlimHeaderLink(label: 'ENG', onTap: () {}),
              ],
            ),
            centerHeader: ItCenterHeader(
              title: 'Comune di Roma',
              subtitle: 'Portale istituzionale del Comune',
              showSearch: true,
              onSearchTap: () {},
            ),
            navHeader: ItNavHeader(
              items: [
                ItNavItem(label: 'Amministrazione', active: true, onTap: () {}),
                ItNavItem(label: 'Servizi', onTap: () {}),
                ItNavItem(label: 'Novità', onTap: () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
