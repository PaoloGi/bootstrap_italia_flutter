import 'package:flutter/material.dart';
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class MegamenuPage extends StatelessWidget {
  const MegamenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Megamenu',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItMegamenu(
            sections: [
              ItMegamenuSection(
                label: 'Amministrazione',
                active: true,
                columns: [
                  ItMegamenuColumn(
                    heading: 'Organi di governo',
                    links: [
                      ItMegamenuLink(label: 'Sindaco', onTap: () {}),
                      ItMegamenuLink(label: 'Giunta comunale', onTap: () {}),
                      ItMegamenuLink(label: 'Consiglio comunale', onTap: () {}),
                    ],
                  ),
                  ItMegamenuColumn(
                    heading: 'Aree amministrative',
                    links: [
                      ItMegamenuLink(label: 'Segreteria', onTap: () {}),
                      ItMegamenuLink(label: 'Area finanziaria', onTap: () {}),
                      ItMegamenuLink(label: 'Area tecnica', onTap: () {}),
                    ],
                  ),
                  ItMegamenuColumn(
                    heading: 'Uffici',
                    links: [
                      ItMegamenuLink(label: 'Ufficio anagrafe', onTap: () {}),
                      ItMegamenuLink(label: 'Ufficio tributi', onTap: () {}),
                    ],
                  ),
                ],
              ),
              ItMegamenuSection(
                label: 'Servizi',
                columns: [
                  ItMegamenuColumn(
                    links: [
                      ItMegamenuLink(label: 'Anagrafe', onTap: () {}),
                      ItMegamenuLink(label: 'Tributi', onTap: () {}),
                      ItMegamenuLink(label: 'Edilizia', onTap: () {}),
                      ItMegamenuLink(label: 'Cultura', onTap: () {}),
                    ],
                  ),
                  ItMegamenuColumn(
                    links: [
                      ItMegamenuLink(label: 'Ambiente', onTap: () {}),
                      ItMegamenuLink(label: 'Sociale', onTap: () {}),
                      ItMegamenuLink(label: 'Turismo', onTap: () {}),
                    ],
                  ),
                ],
              ),
              ItMegamenuSection(
                label: 'Novità',
                columns: [
                  ItMegamenuColumn(
                    links: [
                      ItMegamenuLink(label: 'Notizie', onTap: () {}),
                      ItMegamenuLink(label: 'Comunicati', onTap: () {}),
                      ItMegamenuLink(label: 'Avvisi', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: BootstrapItaliaSpacing.space4),
        ExampleSection(
          title: 'Con CTA e descrizione',
          child: ItMegamenu(
            sections: [
              ItMegamenuSection(
                label: 'Sezione completa',
                active: true,
                description:
                    'Tutto sulla struttura amministrativa del Comune e le sue attività.',
                headerCta: ItMegamenuCta(
                  label: 'Esplora la sezione',
                  onTap: () {},
                ),
                footerCta: ItMegamenuCta(
                  label: 'Esplora tutti i contenuti',
                  onTap: () {},
                ),
                columns: [
                  ItMegamenuColumn(
                    heading: 'Primo gruppo',
                    links: [
                      ItMegamenuLink(label: 'Link 1', onTap: () {}),
                      ItMegamenuLink(label: 'Link 2', onTap: () {}),
                      ItMegamenuLink(label: 'Link 3', onTap: () {}),
                    ],
                  ),
                  ItMegamenuColumn(
                    heading: 'Secondo gruppo',
                    links: [
                      ItMegamenuLink(label: 'Link 4', onTap: () {}),
                      ItMegamenuLink(label: 'Link 5', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
