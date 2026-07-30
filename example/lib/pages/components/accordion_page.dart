import 'package:flutter/material.dart';
import 'package:bootstrap_italia/bootstrap_italia.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class AccordionPage extends StatefulWidget {
  const AccordionPage({super.key});

  @override
  State<AccordionPage> createState() => _AccordionPageState();
}

class _AccordionPageState extends State<AccordionPage> {
  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Accordion',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItAccordion(
            items: [
              ItAccordionItem(
                title: 'Sezione 1',
                child: const Text(
                  'Contenuto della prima sezione. In modalità base, '
                  'solo un pannello alla volta può essere aperto.',
                ),
              ),
              ItAccordionItem(
                title: 'Sezione 2',
                child: const Text(
                  'Contenuto della seconda sezione. '
                  'Aprendo questo pannello, gli altri si chiuderanno automaticamente.',
                ),
              ),
              ItAccordionItem(
                title: 'Sezione 3',
                child: const Text(
                  'Contenuto della terza sezione. '
                  'Ogni pannello può contenere qualsiasi widget.',
                ),
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Multiplo',
          child: ItAccordion(
            allowMultipleOpen: true,
            items: [
              ItAccordionItem(
                title: 'Informazioni generali',
                initiallyExpanded: true,
                child: const Text(
                  'Con allowMultipleOpen attivo, è possibile tenere aperti '
                  'più pannelli contemporaneamente.',
                ),
              ),
              ItAccordionItem(
                title: 'Dettagli aggiuntivi',
                child: const Text(
                  'Questo pannello può essere aperto insieme agli altri '
                  'senza che si chiudano automaticamente.',
                ),
              ),
              ItAccordionItem(
                title: 'Note e riferimenti',
                child: const Text(
                  'Utile quando l\'utente ha bisogno di consultare '
                  'più sezioni contemporaneamente.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
