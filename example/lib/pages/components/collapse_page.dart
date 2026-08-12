import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/collapse/
///
/// The docs page is short and unusually weighted towards the *trigger* rather
/// than the panel: its longest passage is the accessibility note about
/// `aria-expanded`, `aria-controls` and `role="button"`. That is what
/// [ItCollapseToggle] exists for, and it is the through-line of every section
/// below.
class CollapsePage extends StatefulWidget {
  const CollapsePage({super.key});

  @override
  State<CollapsePage> createState() => _CollapsePageState();
}

class _CollapsePageState extends State<CollapsePage> {
  static const _lorem =
      'Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus '
      'terry richardson ad squid. Nihil anim keffiyeh helvetica, craft beer '
      'labore wes anderson cred nesciunt sapiente ea proident.';

  bool _simple = false;
  bool _first = false;
  bool _second = false;

  /// `.card.card-body` — the docs wrap every collapsible body in a card.
  Widget _body() => const ItCard(body: Text(_lorem));

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Collapse',
      children: [
        // ── Come funziona ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Come funziona',
          description:
              'Un elemento richiudibile è un pannello che appare e scompare in '
              'transizione, comandato da un controllo esterno. Qui il pannello '
              'è ItCollapse e lo stato vive nel chiamante: nel kit sono le '
              'classi .collapse, .collapsing e .collapse.show a rappresentare '
              'i tre momenti, e la transizione dura .35s con curva ease.\n\n'
              'Più controlli possono comandare lo stesso pannello. Nella '
              'documentazione sono un link e un pulsante; qui sono due '
              'pulsanti, perché la differenza fra i due nel kit è di markup e '
              'non di comportamento.',
          code: 'bool _aperto = false;\n\n'
              'ItCollapseToggle(\n'
              '  expanded: _aperto,\n'
              "  controls: const {'esempio'},\n"
              '  child: ItButton(\n'
              '    onPressed: () => setState(() => _aperto = !_aperto),\n'
              "    child: const Text('Mostra il contenuto'),\n"
              '  ),\n'
              ')\n'
              'ItCollapse(\n'
              '  isExpanded: _aperto,\n'
              "  semanticsIdentifier: 'esempio',\n"
              '  child: ItCard(body: Text('
              "'…')),\n"
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: BootstrapItaliaSpacing.space2,
                runSpacing: BootstrapItaliaSpacing.space2,
                children: [
                  ItCollapseToggle(
                    expanded: _simple,
                    controls: const {'collapse-esempio'},
                    child: ItButton(
                      onPressed: () => setState(() => _simple = !_simple),
                      child: const Text('Primo controllo'),
                    ),
                  ),
                  ItCollapseToggle(
                    expanded: _simple,
                    controls: const {'collapse-esempio'},
                    child: ItButton(
                      onPressed: () => setState(() => _simple = !_simple),
                      child: const Text('Secondo controllo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space3),
              ItCollapse(
                isExpanded: _simple,
                semanticsIdentifier: 'collapse-esempio',
                child: _body(),
              ),
            ],
          ),
        ),

        // ── Attivazione di elementi richiudibili ───────────────────────────
        ExampleSection(
          title: 'Attivazione di elementi richiudibili',
          description:
              'Un controllo può comandare più pannelli insieme. Nel kit lo fa '
              'elencando più identificatori in aria-controls; qui controls è '
              "un insieme, e il terzo pulsante ne nomina due. L'insieme non è "
              'decorativo: è quello che permette a un lettore di schermo di '
              'offrire una scorciatoia verso i pannelli comandati.',
          code: 'ItCollapseToggle(\n'
              '  expanded: _primo && _secondo,\n'
              "  controls: const {'primo', 'secondo'},\n"
              '  child: ItButton(\n'
              '    onPressed: _attivaEntrambi,\n'
              "    child: const Text('Attiva/disattiva entrambi gli elementi'),\n"
              '  ),\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: BootstrapItaliaSpacing.space2,
                runSpacing: BootstrapItaliaSpacing.space2,
                children: [
                  ItCollapseToggle(
                    expanded: _first,
                    controls: const {'multi-primo'},
                    child: ItButton(
                      onPressed: () => setState(() => _first = !_first),
                      child: const Text('Attiva/disattiva primo elemento'),
                    ),
                  ),
                  ItCollapseToggle(
                    expanded: _second,
                    controls: const {'multi-secondo'},
                    child: ItButton(
                      onPressed: () => setState(() => _second = !_second),
                      child: const Text('Attiva/disattiva secondo elemento'),
                    ),
                  ),
                  ItCollapseToggle(
                    // Both open counts as expanded; anything else does not.
                    // A single flag would drift out of step with the two
                    // panels the moment one of them was toggled on its own.
                    expanded: _first && _second,
                    controls: const {'multi-primo', 'multi-secondo'},
                    child: ItButton(
                      variant: ItButtonVariant.secondary,
                      onPressed: () {
                        final open = !(_first && _second);
                        setState(() {
                          _first = open;
                          _second = open;
                        });
                      },
                      child: const Text('Attiva/disattiva entrambi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ItCollapse(
                      isExpanded: _first,
                      semanticsIdentifier: 'multi-primo',
                      child: _body(),
                    ),
                  ),
                  const SizedBox(width: BootstrapItaliaSpacing.space3),
                  Expanded(
                    child: ItCollapse(
                      isExpanded: _second,
                      semanticsIdentifier: 'multi-secondo',
                      child: _body(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Accessibilità ──────────────────────────────────────────────────
        const ExampleSection(
          title: 'Accessibilità',
          description:
              'La documentazione chiede tre cose al controllo, e '
              'ItCollapseToggle le fornisce tutte e tre.\n\n'
              'aria-expanded, che comunica lo stato corrente: chiuso in '
              'partenza vuol dire expanded: false, non un attributo assente. '
              'Senza di esso chi usa un lettore di schermo preme il pulsante e '
              "non viene informato di nulla, perché ciò che cambia è un altro "
              'elemento.\n\n'
              'aria-controls, cioè il nome del pannello comandato: la '
              'documentazione spiega che i lettori di schermo moderni lo usano '
              "per offrire una scorciatoia che porta direttamente all'elemento "
              'richiudibile. È il parametro controls, e corrisponde al '
              'semanticsIdentifier del pannello.\n\n'
              'role="button" quando il controllo non è un pulsante — un link o '
              'un div. È il parametro isButton, attivo per impostazione '
              'predefinita.\n\n'
              'Le tre informazioni finiscono su un unico nodo insieme al nome '
              'del controllo. Tenerle separate significherebbe far annunciare '
              'un contenitore e poi un pulsante, senza che nessuno dei due dica '
              'sia che cosa fa sia in che stato si trova.',
          child: SizedBox.shrink(),
        ),

        // ── Il rapporto con Accordion ──────────────────────────────────────
        const ExampleSection(
          title: 'Il componente Accordion è basato su Collapse',
          description:
              'Nel kit un accordion è un gruppo di collapse legati fra loro '
              "dall'attributo data-bs-parent, che chiude gli altri quando se ne "
              'apre uno. Qui quel legame è ItAccordion, con '
              'allowMultipleOpen a false: non serve costruirlo a mano a partire '
              'da ItCollapse, ed è la pagina Accordion a documentarlo.',
          code: '// esclusivi (fisarmonica)\n'
              'ItAccordion(items: [...])\n\n'
              '// indipendenti\n'
              'ItAccordion(allowMultipleOpen: true, items: [...])',
          child: ItAccordion(
            items: [
              ItAccordionItem(title: 'Sezione 1', body: Text(_lorem)),
              ItAccordionItem(title: 'Sezione 2', body: Text(_lorem)),
            ],
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Implementazione / Tramite data attributes — descrive come il kit '
              'collega un controllo al suo pannello scrivendo '
              'data-bs-toggle="collapse" e data-bs-target nel markup, senza '
              'scrivere JavaScript. In Flutter non c\'è markup da annotare: il '
              'collegamento è il campo di stato che entrambi leggono, e '
              'ItCollapseToggle serve a dichiararne la parte accessibile.\n\n'
              'Attivazione tramite codice — il costruttore Collapse, le sue '
              'opzioni (parent, toggle), i suoi metodi (toggle, show, hide, '
              'dispose) e i suoi eventi (show.bs.collapse e gli altri tre). '
              "Sono l'interfaccia JavaScript di un plugin che qui non esiste: "
              'lo stato è del chiamante, quindi mostrare o nascondere è un '
              'setState e non una chiamata al componente. L\'opzione parent, '
              "che è l'unica con un effetto strutturale, corrisponde a "
              'ItAccordion.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
