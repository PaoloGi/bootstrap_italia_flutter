import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class ChipPage extends StatefulWidget {
  const ChipPage({super.key});

  @override
  State<ChipPage> createState() => _ChipPageState();
}

class _ChipPageState extends State<ChipPage> {
  bool _selected = false;
  bool _showDismissible = true;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Chip',
      children: [
        ExampleSection(
          title: 'Base',
          child: const ItChip(label: 'Flutter'),
        ),
        ExampleSection(
          title: 'Con icona',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              ItChip(label: 'Tag', icon: Icons.label),
              ItChip(label: 'Utente', icon: Icons.person),
            ],
          ),
        ),
        ExampleSection(
          title: 'Selezionabile',
          child: ItChip(
            label: _selected ? 'Selezionato' : 'Selezionami',
            selected: _selected,
            onTap: () => setState(() => _selected = !_selected),
          ),
        ),
        ExampleSection(
          title: 'Dismissibile',
          child: _showDismissible
              ? ItChip(
                  label: 'Rimuovimi',
                  dismissible: true,
                  onDismissed: () =>
                      setState(() => _showDismissible = false),
                )
              : ItButton(
                  variant: ItButtonVariant.secondary,
                  size: ItButtonSize.sm,
                  onPressed: () =>
                      setState(() => _showDismissible = true),
                  child: const Text('Mostra di nuovo'),
                ),
        ),
        ExampleSection(
          title: 'Grande',
          child: const ItChip(label: 'Chip grande', large: true),
        ),
        ExampleSection(
          title: 'Disabilitato',
          child: const ItChip(label: 'Non attivo', disabled: true),
        ),
      ],
    );
  }
}
