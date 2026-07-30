import 'package:flutter/material.dart';
import 'package:bootstrap_italia/bootstrap_italia.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'List',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItList(
            items: const [
              ItListItem(title: 'Elemento uno'),
              ItListItem(title: 'Elemento due'),
              ItListItem(title: 'Elemento tre'),
              ItListItem(title: 'Elemento quattro'),
            ],
          ),
        ),
        ExampleSection(
          title: 'Con leading/trailing',
          child: ItList(
            items: const [
              ItListItem(
                title: 'Documenti',
                subtitle: '12 file disponibili',
                leading: Icon(Icons.folder, color: BootstrapItaliaColors.primary),
                trailing: Icon(Icons.chevron_right, color: BootstrapItaliaColors.gray500),
              ),
              ItListItem(
                title: 'Impostazioni',
                subtitle: 'Gestisci le preferenze',
                leading: Icon(Icons.settings, color: BootstrapItaliaColors.primary),
                trailing: Icon(Icons.chevron_right, color: BootstrapItaliaColors.gray500),
              ),
              ItListItem(
                title: 'Notifiche',
                subtitle: '3 nuove notifiche',
                leading: Icon(Icons.notifications, color: BootstrapItaliaColors.primary),
                trailing: Icon(Icons.chevron_right, color: BootstrapItaliaColors.gray500),
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Stato attivo',
          child: ItList(
            items: const [
              ItListItem(title: 'Dashboard'),
              ItListItem(title: 'Servizi', active: true),
              ItListItem(title: 'Anagrafica'),
              ItListItem(title: 'Assistenza'),
            ],
          ),
        ),
        ExampleSection(
          title: 'Senza divisori',
          child: ItList(
            showDividers: false,
            items: const [
              ItListItem(title: 'Primo elemento'),
              ItListItem(title: 'Secondo elemento'),
              ItListItem(title: 'Terzo elemento'),
            ],
          ),
        ),
      ],
    );
  }
}
