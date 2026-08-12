import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/accordion/
///
/// Section for section, in the docs' own order and with its headings. Two of
/// the docs' sections are deliberately absent, and why is recorded at the
/// bottom of the page rather than left for a reader to wonder about.
class AccordionPage extends StatefulWidget {
  const AccordionPage({super.key});

  @override
  State<AccordionPage> createState() => _AccordionPageState();
}

class _AccordionPageState extends State<AccordionPage> {
  static const _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua.';

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Accordion',
      children: [
        // ── Gruppi di elementi richiudibili ────────────────────────────────
        ExampleSection(
          title: 'Gruppi di elementi richiudibili',
          description:
              'Ogni elemento si apre e si chiude in modo indipendente: '
              'aprirne uno non chiude gli altri. È il comportamento che si '
              'ottiene con allowMultipleOpen impostato a true.',
          code: 'ItAccordion(\n'
              '  allowMultipleOpen: true,\n'
              '  items: [\n'
              "    ItAccordionItem(title: 'Sezione 1', body: Text('…')),\n"
              '  ],\n'
              ')',
          child: const ItAccordion(
            allowMultipleOpen: true,
            items: [
              ItAccordionItem(
                title: 'Sezione 1',
                body: Text(_lorem),
                initiallyExpanded: true,
              ),
              ItAccordionItem(title: 'Sezione 2', body: Text(_lorem)),
              ItAccordionItem(title: 'Sezione 3', body: Text(_lorem)),
            ],
          ),
        ),

        // ── Accordion ──────────────────────────────────────────────────────
        ExampleSection(
          title: 'Accordion',
          description:
              'Nella variante ad accordion gli elementi sono mutuamente '
              'esclusivi: aprendone uno si chiude quello aperto in '
              'precedenza. È il valore predefinito di allowMultipleOpen.',
          code: 'ItAccordion(\n'
              '  items: [\n'
              "    ItAccordionItem(title: 'Sezione 1', body: Text('…')),\n"
              '  ],\n'
              ')',
          child: const ItAccordion(
            items: [
              ItAccordionItem(
                title: 'Sezione 1',
                body: Text(_lorem),
                initiallyExpanded: true,
              ),
              ItAccordionItem(title: 'Sezione 2', body: Text(_lorem)),
              ItAccordionItem(title: 'Sezione 3', body: Text(_lorem)),
            ],
          ),
        ),

        // ── Header attivi ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Header attivi',
          description:
              "L'header dell'elemento aperto assume lo sfondo del colore "
              'primario, con etichetta e freccia in bianco. Il colore non è '
              'fisso: viene risolto dal tema, quindi una amministrazione che '
              'personalizza primary vede cambiare anche questa variante — e '
              "l'etichetta lo segue, altrimenti si perderebbe il contrasto.",
          code: 'ItAccordion(\n'
              '  backgroundActive: true,\n'
              '  items: [...],\n'
              ')\n\n'
              '// Per cambiare il colore, agire sul tema:\n'
              'BootstrapItaliaTheme(\n'
              '  data: BootstrapItaliaThemeData(\n'
              '    colors: BootstrapItaliaColorScheme.standard\n'
              "        .copyWith(primary: Color(0xFF7A1FA2)),\n"
              '  ),\n'
              '  child: ...,\n'
              ')',
          child: const ItAccordion(
            backgroundActive: true,
            items: [
              ItAccordionItem(
                title: 'Sezione 1',
                body: Text(_lorem),
                initiallyExpanded: true,
              ),
              ItAccordionItem(title: 'Sezione 2', body: Text(_lorem)),
              ItAccordionItem(title: 'Sezione 3', body: Text(_lorem)),
            ],
          ),
        ),

        // The same widget under a retinted scheme — the claim above, shown.
        ExampleSection(
          title: 'Header attivi, con tema personalizzato',
          description:
              'Lo stesso accordion sotto uno schema colori diverso. Nessun '
              'parametro del componente è cambiato: è cambiato solo il tema.',
          code: 'BootstrapItaliaTheme(\n'
              '  data: BootstrapItaliaThemeData(\n'
              '    colors: BootstrapItaliaColorScheme.standard\n'
              '        .copyWith(primary: Color(0xFF7A1FA2)),\n'
              '  ),\n'
              '  child: ItAccordion(backgroundActive: true, items: [...]),\n'
              ')',
          child: BootstrapItaliaTheme(
            data: BootstrapItaliaThemeData(
              colors: BootstrapItaliaColorScheme.standard
                  .copyWith(primary: const Color(0xFF7A1FA2)),
            ),
            child: const ItAccordion(
              backgroundActive: true,
              items: [
                ItAccordionItem(
                  title: 'Sezione 1',
                  body: Text(_lorem),
                  initiallyExpanded: true,
                ),
                ItAccordionItem(title: 'Sezione 2', body: Text(_lorem)),
              ],
            ),
          ),
        ),

        // ── Icona a sinistra ───────────────────────────────────────────────
        ExampleSection(
          title: 'Icona a sinistra',
          description:
              'La freccia a destra viene sostituita da un segno + / − alla '
              "sinistra del titolo. È un carattere tipografico, non un'icona: "
              'il kit lo disegna in Titillium Web con peso 300, e una glifo '
              'del set icone avrebbe forma e peso ottico diversi.',
          code: 'ItAccordion(\n'
              '  leftIcon: true,\n'
              '  items: [...],\n'
              ')',
          child: const ItAccordion(
            leftIcon: true,
            items: [
              ItAccordionItem(
                title: 'Sezione 1',
                body: Text(_lorem),
                initiallyExpanded: true,
              ),
              ItAccordionItem(title: 'Sezione 2', body: Text(_lorem)),
              ItAccordionItem(title: 'Sezione 3', body: Text(_lorem)),
            ],
          ),
        ),

        // Not in the docs, but the two variants compose, and a reader will ask.
        ExampleSection(
          title: 'Header attivi e icona a sinistra insieme',
          description:
              'Le due varianti sono indipendenti e si possono combinare.',
          code: 'ItAccordion(\n'
              '  backgroundActive: true,\n'
              '  leftIcon: true,\n'
              '  items: [...],\n'
              ')',
          child: const ItAccordion(
            backgroundActive: true,
            leftIcon: true,
            items: [
              ItAccordionItem(
                title: 'Sezione 1',
                body: Text(_lorem),
                initiallyExpanded: true,
              ),
              ItAccordionItem(title: 'Sezione 2', body: Text(_lorem)),
            ],
          ),
        ),

        // ── Con icona nel titolo ───────────────────────────────────────────
        ExampleSection(
          title: 'Con icona nel titolo',
          description: "Un'icona può precedere il titolo, indipendentemente "
              "dall'indicatore di apertura.",
          code: 'ItAccordionItem(\n'
              "  title: 'Sezione 1',\n"
              '  icon: BootstrapItaliaIcons.it_info_circle,\n'
              "  body: Text('…'),\n"
              ')',
          child: const ItAccordion(
            items: [
              ItAccordionItem(
                title: 'Informazioni generali',
                icon: Icons.info_outline,
                body: Text(_lorem),
                initiallyExpanded: true,
              ),
              ItAccordionItem(
                title: 'Documenti richiesti',
                icon: Icons.description_outlined,
                body: Text(_lorem),
              ),
            ],
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Hover degli Header — un effetto legato al passaggio del mouse, '
              'che non ha equivalente sui dispositivi tattili e non è un '
              'parametro del componente.\n\n'
              'Accordion annidati — la documentazione stessa segnala che '
              'questo schema «non è ottimale dal punto di vista '
              "dell'accessibilità»: annidare gruppi di header rende la "
              'struttura difficile da percorrere con uno screen reader. '
              'Tecnicamente è possibile, passando un ItAccordion come body di '
              'un ItAccordionItem, ma non lo mostriamo come esempio da '
              'seguire.\n\n'
              'Attivazione tramite codice — riguarda l’inizializzazione '
              'JavaScript del kit, che in Flutter non esiste: il widget è già '
              'attivo appena costruito. La parte utile di quella sezione, però, '
              'non è il codice ma la navigazione da tastiera che descrive, e '
              'quella è implementata: con il focus su un header, le frecce su e '
              'giù spostano il focus tra gli header (ciclando agli estremi), '
              'Home e End vanno al primo e all’ultimo. Le frecce spostano solo '
              'il focus e non aprono il pannello: un header è un pulsante di '
              'apertura, non una tab.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
