import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class ModalPage extends StatelessWidget {
  const ModalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Modal',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItButton(
            onPressed: () {
              ItModal.show(
                context: context,
                title: 'Titolo modale',
                body: const Text(
                  'Questa è una modale di base con titolo, corpo e azioni.',
                ),
                actions: [
                  ItButton(
                    variant: ItButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annulla'),
                  ),
                  ItButton(
                    variant: ItButtonVariant.primary,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Conferma'),
                  ),
                ],
              );
            },
            child: const Text('Apri modale'),
          ),
        ),
        ExampleSection(
          title: 'Dimensioni',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final size in ItModalSize.values)
                ItButton(
                  onPressed: () {
                    ItModal.show(
                      context: context,
                      size: size,
                      title: 'Modale ${size.name.toUpperCase()}',
                      body: Text(
                        'Questa modale ha dimensione ${size.name} '
                        '(max ${size.maxWidth.toInt()}px).',
                      ),
                      actions: [
                        ItButton(
                          variant: ItButtonVariant.primary,
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Chiudi'),
                        ),
                      ],
                    );
                  },
                  child: Text(size.name.toUpperCase()),
                ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Scrollabile',
          child: ItButton(
            onPressed: () {
              ItModal.show(
                context: context,
                title: 'Contenuto lungo',
                scrollable: true,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 1; i <= 20; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Paragrafo $i: Lorem ipsum dolor sit amet, '
                          'consectetur adipiscing elit. Sed do eiusmod '
                          'tempor incididunt ut labore et dolore magna aliqua.',
                        ),
                      ),
                  ],
                ),
                actions: [
                  ItButton(
                    variant: ItButtonVariant.primary,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Chiudi'),
                  ),
                ],
              );
            },
            child: const Text('Apri modale scrollabile'),
          ),
        ),
        ExampleSection(
          title: 'Senza titolo',
          child: ItButton(
            onPressed: () {
              ItModal.show(
                context: context,
                body: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Questa modale non ha un titolo. '
                    'Il contenuto viene mostrato direttamente.',
                  ),
                ),
                actions: [
                  ItButton(
                    variant: ItButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annulla'),
                  ),
                  ItButton(
                    variant: ItButtonVariant.primary,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Conferma'),
                  ),
                ],
              );
            },
            child: const Text('Apri modale senza titolo'),
          ),
        ),
      ],
    );
  }
}
