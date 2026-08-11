import 'package:flutter/material.dart';
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Card',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItCard(
            title: 'Titolo della card',
            body: const Text(
              'Questa è una card semplice con titolo e corpo di testo. '
              'Il contenuto può essere di qualsiasi tipo.',
            ),
          ),
        ),
        ExampleSection(
          title: 'Con immagine',
          child: ItCard(
            image: Container(
              height: 160,
              color: BootstrapItaliaColors.primary,
              child: const Center(
                child: Icon(Icons.image, size: 48, color: Colors.white),
              ),
            ),
            title: 'Card con immagine',
            body: const Text(
              'Una card con un\'immagine posizionata in alto. '
              'L\'immagine può essere qualsiasi widget.',
            ),
          ),
        ),
        ExampleSection(
          title: 'Con categoria',
          child: ItCard(
            category: const ItCardCategory(
              label: 'Servizi',
              icon: Icons.category,
            ),
            title: 'Card con categoria',
            body: const Text(
              'La categoria viene visualizzata sopra il titolo per '
              'classificare il contenuto della card.',
            ),
          ),
        ),
        ExampleSection(
          title: 'Orizzontale',
          child: ItCard(
            horizontal: true,
            image: Container(
              color: BootstrapItaliaColors.analogue2,
              child: const Center(
                child: Icon(Icons.landscape, size: 48, color: Colors.white),
              ),
            ),
            title: 'Card orizzontale',
            body: const Text(
              'Layout orizzontale con immagine a sinistra e contenuto a destra.',
            ),
          ),
        ),
        ExampleSection(
          title: 'Con bordo colorato',
          child: ItCard(
            borderTopColor: BootstrapItaliaColors.success,
            title: 'Card con bordo superiore',
            body: const Text(
              'Un bordo colorato in alto evidenzia la card. '
              'Utile per distinguere tipologie di contenuto.',
            ),
          ),
        ),
        ExampleSection(
          title: 'Con footer',
          child: ItCard(
            title: 'Card con footer',
            body: const Text(
              'Questa card include un\'area footer separata dal corpo '
              'da un divisore.',
            ),
            footer: const Padding(
              padding: EdgeInsets.all(BootstrapItaliaSpacing.space3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ultimo aggiornamento: oggi',
                    style: TextStyle(
                        fontSize: 12, color: BootstrapItaliaColors.gray600),
                  ),
                  Icon(Icons.arrow_forward,
                      size: 16, color: BootstrapItaliaColors.primary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
