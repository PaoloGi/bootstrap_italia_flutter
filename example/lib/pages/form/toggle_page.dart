import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/form/toggles/
///
/// Section for section, in the docs' own order and with its headings.
class TogglePage extends StatefulWidget {
  const TogglePage({super.key});

  @override
  State<TogglePage> createState() => _TogglePageState();
}

class _TogglePageState extends State<TogglePage> {
  static const _lorem = 'Lorem ipsum dolor sit amet, consectetur adipiscing '
      'elit. Maecenas molestie libero';

  bool _base = false;
  Set<String> _inline = {};
  Set<String> _raggruppati = {'acceso'};
  Set<String> _conDescrizione = {'acceso'};

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Toggles',
      children: [
        // ── Toggles ────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Toggles',
          description:
              'Un campo di tipo interruttore. La levetta è larga 46px e alta '
              '16px, e galleggia a destra di una riga che occupa tutta la '
              'larghezza; il pomello che vi scorre sopra è più grande della '
              'levetta stessa, come nel kit. Alla tecnologia assistiva il '
              'controllo si presenta come un interruttore con il proprio '
              'stato acceso o spento, non come un pulsante.',
          code: 'ItToggle(\n'
              '  value: valore,\n'
              "  label: \"Label dell'interruttore 1\",\n"
              '  onChanged: (v) => setState(() => valore = v),\n'
              ')',
          child: ItToggle(
            value: _base,
            label: "Label dell'interruttore 1",
            onChanged: (v) => setState(() => _base = v),
          ),
        ),

        // ── Disabilitato ───────────────────────────────────────────────────
        const ExampleSection(
          title: 'Disabilitato',
          description:
              'Un interruttore disabilitato non si aziona e viene saltato dal '
              'tasto Tab, ma continua a dichiarare la propria posizione: chi '
              'usa un lettore di schermo deve poter sapere se l’impostazione '
              'è attiva anche quando non può cambiarla. La levetta e il '
              'pomello passano entrambi al grigio chiaro del kit.',
          code: 'ItToggle(\n'
              '  value: false,\n'
              "  label: \"Label dell'interruttore 1\",\n"
              '  enabled: false,\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItToggle(
                value: false,
                label: "Label dell'interruttore 1",
                enabled: false,
              ),
              SizedBox(height: 8),
              ItToggle(
                value: true,
                label: "Label dell'interruttore 2",
                enabled: false,
              ),
            ],
          ),
        ),

        // ── Inline ─────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Inline',
          description:
              'Con inline gli interruttori si dispongono orizzontalmente '
              '(.form-check-inline). Ciascuno prende la larghezza della '
              'propria etichetta più la levetta, invece della riga intera.\n\n'
              'La documentazione mostra qui anche una classe .leverRight sul '
              'secondo interruttore. Non è riprodotta perché nel foglio di '
              'stile compilato della versione 2.18.0 quella classe non esiste: '
              'non c’è alcuna regola .leverRight, e .lever ha già float:right, '
              'quindi sul kit di riferimento i due interruttori sono identici.',
          code: 'ItToggleGroup<String>(\n'
              "  label: 'Gruppo di toggle',\n"
              '  inline: true,\n'
              '  options: [\n'
              "    ItToggleOption(value: 'a', label: \"Label "
              "dell'interruttore 1\"),\n"
              "    ItToggleOption(value: 'b', label: \"Label "
              "dell'interruttore 2\"),\n"
              '  ],\n'
              '  values: valori,\n'
              '  onChanged: (v) => setState(() => valori = v),\n'
              ')',
          child: ItToggleGroup<String>(
            label: 'Gruppo di toggle',
            inline: true,
            options: const [
              ItToggleOption(value: 'a', label: "Label dell'interruttore 1"),
              ItToggleOption(value: 'b', label: "Label dell'interruttore 2"),
            ],
            values: _inline,
            onChanged: (v) => setState(() => _inline = v),
          ),
        ),

        // ── Raggruppati visivamente ────────────────────────────────────────
        ExampleSection(
          title: 'Raggruppati visivamente',
          description:
              'Con visuallyGrouped ogni riga prende una linea di separazione '
              'sotto di sé e la spaziatura del kit (.form-check-group). '
              'Sull’interruttore cambia meno che sulle altre due caselle, ed è '
              'il punto: quella classe sposta l’indicatore a destra, e la '
              'levetta è già lì.',
          code: 'ItToggleGroup<String>(\n'
              "  label: 'Gruppo di toggle',\n"
              '  visuallyGrouped: true,\n'
              '  options: [\n'
              "    ItToggleOption(value: 'acceso', label: 'Toggle acceso'),\n"
              "    ItToggleOption(value: 'spento', label: 'Toggle spento'),\n"
              '  ],\n'
              '  values: valori,\n'
              '  onChanged: (v) => setState(() => valori = v),\n'
              ')',
          child: ItToggleGroup<String>(
            label: 'Gruppo di toggle',
            visuallyGrouped: true,
            options: const [
              ItToggleOption(value: 'acceso', label: 'Toggle acceso'),
              ItToggleOption(value: 'spento', label: 'Toggle spento'),
              ItToggleOption(
                value: 'disabilitato',
                label: 'Toggle disabilitato',
                enabled: false,
              ),
            ],
            values: _raggruppati,
            onChanged: (v) => setState(() => _raggruppati = v),
          ),
        ),

        ExampleSection(
          title: 'Raggruppati visivamente, con testo descrittivo',
          description:
              'La seconda variante della documentazione dà a ogni interruttore '
              'una descrizione. È helperText sulla singola opzione: viene '
              'letta come parte di quella riga, mentre quello del gruppo '
              'descrive tutto l’insieme.',
          code: 'ItToggleGroup<String>(\n'
              "  label: 'Gruppo di toggle',\n"
              '  visuallyGrouped: true,\n'
              '  options: [\n'
              '    ItToggleOption(\n'
              "      value: 'acceso',\n"
              "      label: 'Toggle acceso',\n"
              "      helperText: 'Lorem ipsum dolor sit amet…',\n"
              '    ),\n'
              '  ],\n'
              '  values: valori,\n'
              '  onChanged: (v) => setState(() => valori = v),\n'
              ')',
          child: ItToggleGroup<String>(
            label: 'Gruppo di toggle',
            visuallyGrouped: true,
            options: const [
              ItToggleOption(
                value: 'acceso',
                label: 'Toggle acceso',
                helperText: _lorem,
              ),
              ItToggleOption(
                value: 'spento',
                label: 'Toggle spento',
                helperText: _lorem,
              ),
              ItToggleOption(
                value: 'disabilitato',
                label: 'Toggle disabilitato',
                helperText: _lorem,
                enabled: false,
              ),
            ],
            values: _conDescrizione,
            onChanged: (v) => setState(() => _conDescrizione = v),
          ),
        ),

        // ── Beyond the docs ────────────────────────────────────────────────
        const ExampleSection(
          title: 'Senza etichetta',
          description:
              'Non è una sezione della documentazione, ma capita di dover '
              'mettere un interruttore in una cella o in una barra di '
              'strumenti dove l’etichetta è altrove. In quel caso serve '
              'semanticLabel: senza un nome il controllo non è conforme al '
              'criterio 4.1.2, e nessuno può sapere che cosa accende.',
          code: 'ItToggle(\n'
              '  value: valore,\n'
              "  semanticLabel: 'Notifiche via email',\n"
              '  onChanged: (v) => setState(() => valore = v),\n'
              ')',
          child: ItToggle(
            value: true,
            semanticLabel: 'Notifiche via email',
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              '.leverRight — la classe compare nell’esempio «Inline» della '
              'documentazione, ma il foglio di stile della versione 2.18.0 non '
              'la dichiara da nessuna parte. Non ha quindi alcun effetto '
              'neppure sul kit di riferimento, e riprodurla qui vorrebbe dire '
              'inventare un comportamento che il design system non ha.\n\n'
              'Breaking change — le modifiche introdotte dalla versione 2.10.0 '
              'del kit: usare <fieldset> per raggruppare i campi e sostituire '
              'aria-labelledby con aria-describedby. Riguardano il markup HTML '
              'di chi aggiorna il foglio di stile; qui sono già il '
              'comportamento predefinito di ItToggleGroup.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
