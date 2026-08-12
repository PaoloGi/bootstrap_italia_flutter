import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors
/// https://italia.github.io/bootstrap-italia/docs/menu-di-navigazione/breadcrumbs/
///
/// Section for section, in the docs' own order and with its headings. The
/// docs' first code block carries two navs — one separated by `/`, one by `>` —
/// under a single heading, so they stay in a single section here too.
class BreadcrumbPage extends StatelessWidget {
  const BreadcrumbPage({super.key});

  static List<ItBreadcrumbItem> _items() => [
        ItBreadcrumbItem(label: 'Home', onTap: () {}),
        ItBreadcrumbItem(label: 'Sottosezione', onTap: () {}),
        const ItBreadcrumbItem(label: 'Nome pagina'),
      ];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Breadcrumbs',
      children: [
        // ── Breadcrumbs ────────────────────────────────────────────────────
        ExampleSection(
          title: 'Breadcrumbs',
          description:
              'Le breadcrumbs mostrano la pagina corrente e permettono di '
              'risalire nella gerarchia attraverso i link ai livelli '
              "superiori. L'ultima voce è la pagina corrente e non è "
              'cliccabile: basta ometterne onTap. Il carattere separatore si '
              'sceglie con separator, che vale «/» per impostazione '
              'predefinita.',
          code: 'ItBreadcrumb(\n'
              '  items: [\n'
              "    ItBreadcrumbItem(label: 'Home', onTap: () {}),\n"
              "    ItBreadcrumbItem(label: 'Sottosezione', onTap: () {}),\n"
              "    ItBreadcrumbItem(label: 'Nome pagina'),\n"
              '  ],\n'
              ')\n\n'
              '// Con un separatore diverso:\n'
              "ItBreadcrumb(separator: '>', items: [...])",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItBreadcrumb(items: _items()),
              ItBreadcrumb(separator: '>', items: _items()),
            ],
          ),
        ),

        // ── Accessibilità ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Accessibilità',
          description: 'Il widget applica da sé le tre indicazioni della '
              'documentazione, senza che il chiamante debba ricordarsene. '
              'Il percorso è esposto come landmark di navigazione con '
              "un'etichetta — l'equivalente di aria-label — presa da "
              'ItLocalizations.breadcrumb e quindi sovrascrivibile. '
              "L'ultima voce dichiara lo stato «selected», che è come Flutter "
              'esprime aria-current="page". I separatori sono esclusi '
              "dall'albero semantico: sono punteggiatura visiva e leggerli fra "
              'una voce e l\'altra sarebbe solo rumore.',
          code: '// Per cambiare l\'etichetta del landmark:\n'
              'ItLocalizationsDelegate(\n'
              '  resolve: (locale) => switch (locale.languageCode) {\n'
              "    'it' => ItLocalizations.italian\n"
              "        .copyWith(breadcrumb: 'Percorso di navigazione'),\n"
              '    _ => null,\n'
              '  },\n'
              ')',
          child: ItBreadcrumb(items: _items()),
        ),

        // ── Con icona ──────────────────────────────────────────────────────
        ExampleSection(
          title: 'Con icona',
          description:
              "Un'icona può precedere ogni voce. Si imposta una volta sola "
              'con il parametro icon del breadcrumb, oppure voce per voce con '
              'ItBreadcrumbItem.icon, che ha la precedenza. Nella versione '
              "chiara l'icona assume il colore della voce che accompagna: "
              'quello dei link per le voci navigabili, quello della pagina '
              "corrente per l'ultima.",
          code: 'ItBreadcrumb(\n'
              '  icon: BootstrapItaliaIcons.it_link,\n'
              '  items: [\n'
              "    ItBreadcrumbItem(label: 'Home', onTap: () {}),\n"
              "    ItBreadcrumbItem(label: 'Sottosezione', onTap: () {}),\n"
              "    ItBreadcrumbItem(label: 'Nome pagina'),\n"
              '  ],\n'
              ')',
          child: ItBreadcrumb(
            icon: BootstrapItaliaIcons.it_link,
            items: _items(),
          ),
        ),

        // ── Su sfondo scuro ────────────────────────────────────────────────
        ExampleSection(
          title: 'Su sfondo scuro',
          description:
              'Con dark impostato a true il percorso viene disegnato su una '
              'fascia ardesia con testo bianco. La documentazione consiglia di '
              'aggiungere una spaziatura laterale quando la fascia poggia su '
              'un fondo di colore diverso: il widget la applica da sé, quindi '
              "non c'è nulla da impostare. In questa variante l'icona assume "
              'il colore acquamarina previsto dal kit per le breadcrumb scure.',
          code: 'ItBreadcrumb(\n'
              '  dark: true,\n'
              '  items: [...],\n'
              ')',
          child: ColoredBox(
            color: const Color(0xFF17324D),
            child: Padding(
              padding: const EdgeInsets.all(BootstrapItaliaSpacing.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItBreadcrumb(dark: true, items: _items()),
                  const SizedBox(height: BootstrapItaliaSpacing.space3),
                  ItBreadcrumb(
                    dark: true,
                    icon: BootstrapItaliaIcons.it_link,
                    items: _items(),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Nessuna sezione della pagina è stata omessa: le breadcrumbs '
              'sono uno dei pochi componenti che il kit descrive per intero '
              'senza JavaScript, effetti al passaggio del mouse o schemi '
              'sconsigliati.\n\n'
              "Una divergenza però esiste, ed è nell'icona su sfondo scuro. "
              'La documentazione usa lì la classe di utilità .icon-white, '
              "cioè un'icona bianca; questo pacchetto disegna invece il "
              'colore della regola .breadcrumb.dark .breadcrumb-item i, che è '
              'un acquamarina. Sono due dichiarazioni diverse dello stesso '
              'kit — una scelta per esempio, una scritta nel foglio di stile — '
              "e la seconda è quella che il componente ha sempre applicato: "
              'cambiarla ora sposterebbe il rendering predefinito.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
