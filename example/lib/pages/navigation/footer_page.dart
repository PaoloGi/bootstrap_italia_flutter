import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class FooterPage extends StatelessWidget {
  const FooterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Footer',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItFooter(
            institutionName: 'Comune di Roma',
            description: 'Piazza del Campidoglio, 1 - 00186 Roma\nTel. 06 0606',
          ),
        ),
        ExampleSection(
          title: 'Con sezioni',
          child: ItFooter(
            institutionName: 'Comune di Roma',
            sections: [
              ItFooterSection(
                title: 'Amministrazione',
                links: [
                  ItFooterLink(label: 'Giunta e consiglio', onTap: () {}),
                  ItFooterLink(label: 'Aree di competenza', onTap: () {}),
                  ItFooterLink(label: 'Dipendenti', onTap: () {}),
                ],
              ),
              ItFooterSection(
                title: 'Servizi',
                links: [
                  ItFooterLink(label: 'Anagrafe', onTap: () {}),
                  ItFooterLink(label: 'Tributi', onTap: () {}),
                  ItFooterLink(label: 'Cultura e tempo libero', onTap: () {}),
                ],
              ),
              ItFooterSection(
                title: 'Novità',
                links: [
                  ItFooterLink(label: 'Notizie', onTap: () {}),
                  ItFooterLink(label: 'Eventi', onTap: () {}),
                  ItFooterLink(label: 'Comunicati stampa', onTap: () {}),
                ],
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Con social',
          child: ItFooter(
            institutionName: 'Comune di Roma',
            description: 'Seguici sui social per restare aggiornato.',
            socialLinks: [
              ItSocialLink(
                  icon: Icons.facebook, label: 'Facebook', onTap: () {}),
              ItSocialLink(
                  icon: Icons.camera_alt, label: 'Instagram', onTap: () {}),
              ItSocialLink(
                  icon: Icons.play_circle, label: 'YouTube', onTap: () {}),
            ],
          ),
        ),
        ExampleSection(
          title: 'Con info legali',
          child: ItFooter(
            institutionName: 'Comune di Roma',
            description: 'Piazza del Campidoglio, 1 - 00186 Roma',
            legalInfo: [
              ItFooterLink(label: 'Privacy policy', onTap: () {}),
              ItFooterLink(label: 'Note legali', onTap: () {}),
              ItFooterLink(label: 'Accessibilità', onTap: () {}),
              ItFooterLink(label: 'Cookie policy', onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
