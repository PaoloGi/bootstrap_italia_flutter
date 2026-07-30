import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class DropdownPage extends StatelessWidget {
  const DropdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Dropdown',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItDropdown(
            trigger: ItButton(
              onPressed: () {},
              child: const Text('Apri menu'),
            ),
            items: [
              ItDropdownItem(label: 'Voce 1', onTap: () {}),
              ItDropdownItem(label: 'Voce 2', onTap: () {}),
              ItDropdownItem(label: 'Voce 3', onTap: () {}),
            ],
          ),
        ),
        ExampleSection(
          title: 'Con icone',
          child: ItDropdown(
            trigger: ItButton(
              onPressed: () {},
              child: const Text('Azioni'),
            ),
            items: [
              ItDropdownItem(
                  label: 'Modifica', icon: Icons.edit, onTap: () {}),
              ItDropdownItem(
                  label: 'Duplica', icon: Icons.copy, onTap: () {}),
              ItDropdownItem(
                  label: 'Scarica', icon: Icons.download, onTap: () {}),
            ],
          ),
        ),
        ExampleSection(
          title: 'Con header e divisore',
          child: ItDropdown(
            trigger: ItButton(
              onPressed: () {},
              child: const Text('Opzioni'),
            ),
            items: [
              const ItDropdownHeader(label: 'Operazioni'),
              ItDropdownItem(label: 'Modifica', onTap: () {}),
              ItDropdownItem(label: 'Condividi', onTap: () {}),
              const ItDropdownDivider(),
              ItDropdownItem(
                  label: 'Elimina', onTap: () {}, danger: true),
            ],
          ),
        ),
        ExampleSection(
          title: 'Direzioni',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final direction in ItDropdownDirection.values)
                ItDropdown(
                  direction: direction,
                  trigger: ItButton(
                    onPressed: () {},
                    child: Text(direction.name),
                  ),
                  items: [
                    ItDropdownItem(label: 'Voce A', onTap: () {}),
                    ItDropdownItem(label: 'Voce B', onTap: () {}),
                    ItDropdownItem(label: 'Voce C', onTap: () {}),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
