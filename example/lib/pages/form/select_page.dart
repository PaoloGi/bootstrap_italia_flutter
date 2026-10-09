import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/form/select/
///
/// The docs page is short — three sections — so the extras this package offers
/// beyond it are gathered at the end and labelled as such, rather than mixed in
/// where a reader would take them for part of the reference.
class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  String? _base;
  String? _gruppi;
  String? _ricerca;
  String? _obbligatoria;
  Set<String> _multipla = {};

  /// The docs' own five options.
  static const _opzioni = [
    ItSelectItem(value: '1', label: 'Opzione 1'),
    ItSelectItem(value: '2', label: 'Opzione 2'),
    ItSelectItem(value: '3', label: 'Opzione 3'),
    ItSelectItem(value: '4', label: 'Opzione 4'),
    ItSelectItem(value: '5', label: 'Opzione 5'),
  ];

  /// The docs' `<optgroup>` example: two captions over four options.
  static const _opzioniRaggruppate = [
    ItSelectItem(value: '1', label: 'Opzione 1', group: 'Gruppo 1'),
    ItSelectItem(value: '2', label: 'Opzione 2', group: 'Gruppo 1'),
    ItSelectItem(value: '3', label: 'Opzione 3', group: 'Gruppo 2'),
    ItSelectItem(value: '4', label: 'Opzione 4', group: 'Gruppo 2'),
  ];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Select',
      children: [
        // ── Select ─────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Select',
          description:
              "Il classico menu a tendina. L'etichetta sta sempre sollevata "
              'sopra il controllo — nel kit .select-wrapper label ha una '
              'translazione incondizionata, a differenza del campo di testo — '
              'e il valore scelto è scritto in grassetto.',
          code: 'ItSelect<String>(\n'
              "  label: 'Etichetta',\n"
              "  hint: \"Scegli un'opzione\",\n"
              '  items: [\n'
              "    ItSelectItem(value: '1', label: 'Opzione 1'),\n"
              "    ItSelectItem(value: '2', label: 'Opzione 2'),\n"
              '  ],\n'
              '  value: valore,\n'
              '  onChanged: (v) => setState(() => valore = v),\n'
              ')',
          child: ItSelect<String>(
            label: 'Etichetta',
            hint: "Scegli un'opzione",
            items: _opzioni,
            value: _base,
            onChanged: (v) => setState(() => _base = v),
          ),
        ),

        // ── Select disabilitata ────────────────────────────────────────────
        const ExampleSection(
          title: 'Select disabilitata',
          description:
              'Una select disabilitata non si apre, non viene raggiunta dal '
              'tasto Tab e prende lo sfondo grigio del kit. Continua a '
              'dichiarare alla tecnologia assistiva sia il proprio valore sia '
              'il proprio stato.',
          code: 'ItSelect<String>(\n'
              "  label: 'Etichetta',\n"
              "  hint: \"Scegli un'opzione\",\n"
              '  items: opzioni,\n'
              '  enabled: false,\n'
              ')',
          child: ItSelect<String>(
            label: 'Etichetta',
            hint: "Scegli un'opzione",
            items: _opzioni,
            enabled: false,
          ),
        ),

        // ── Select con gruppi ──────────────────────────────────────────────
        ExampleSection(
          title: 'Select con gruppi',
          description:
              "L'equivalente di <optgroup>: si indica group sulle singole "
              'opzioni e la tendina stampa la didascalia ogni volta che il '
              'valore cambia. Le opzioni di uno stesso gruppo vanno quindi '
              'tenute vicine, come nel markup. La didascalia è un intestazione '
              'anche per la tecnologia assistiva, non solo una riga in '
              'maiuscolo: senza un nodo proprio arriverebbe a un lettore di '
              'schermo come testo sciolto fra due opzioni.',
          code: 'ItSelect<String>(\n'
              "  label: 'Etichetta',\n"
              "  hint: \"Scegli un'opzione\",\n"
              '  items: [\n'
              "    ItSelectItem(value: '1', label: 'Opzione 1', "
              "group: 'Gruppo 1'),\n"
              "    ItSelectItem(value: '2', label: 'Opzione 2', "
              "group: 'Gruppo 1'),\n"
              "    ItSelectItem(value: '3', label: 'Opzione 3', "
              "group: 'Gruppo 2'),\n"
              '  ],\n'
              ')',
          child: ItSelect<String>(
            label: 'Etichetta',
            hint: "Scegli un'opzione",
            items: _opzioniRaggruppate,
            value: _gruppi,
            onChanged: (v) => setState(() => _gruppi = v),
          ),
        ),

        // ── Beyond the docs ────────────────────────────────────────────────
        const ExampleSection(
          title: 'Oltre la documentazione',
          description:
              'Le tre sezioni qui sopra sono tutta la pagina Select della '
              'documentazione. Quello che segue non ha un corrispettivo in '
              'quella pagina: sono capacità che il widget offre in più, '
              'raccolte qui perché non vengano scambiate per riferimento.',
          child: SizedBox.shrink(),
        ),

        ExampleSection(
          title: 'Selezione multipla',
          description:
              'ItMultiSelect è un widget distinto, non un flag. Prende '
              'un insieme di valori e una sola callback: la versione con un '
              'interruttore multiple accettava quattro parametri combinabili '
              'fra loro, e la combinazione sbagliata compilava e non emetteva '
              'nulla. Ora è un errore di compilazione.',
          code: 'ItMultiSelect<String>(\n'
              "  label: 'Etichetta',\n"
              '  items: opzioni,\n'
              '  values: valori,\n'
              '  onChanged: (v) => setState(() => valori = v),\n'
              ')',
          child: ItMultiSelect<String>(
            label: 'Etichetta',
            hint: "Scegli una o più opzioni",
            items: _opzioni,
            values: _multipla,
            onChanged: (v) => setState(() => _multipla = v),
          ),
        ),

        ExampleSection(
          title: 'Con ricerca',
          description:
              'Aggiunge un campo di filtro in cima alla tendina, utile quando '
              'le opzioni sono molte. Corrisponde al .bs-searchbox del plugin '
              'JavaScript che il kit usa per le select avanzate.',
          code: 'ItSelect<String>(\n'
              "  label: 'Etichetta',\n"
              '  items: opzioni,\n'
              '  searchable: true,\n'
              ')',
          child: ItSelect<String>(
            label: 'Etichetta',
            hint: "Cerca un'opzione",
            items: _opzioni,
            searchable: true,
            value: _ricerca,
            onChanged: (v) => setState(() => _ricerca = v),
          ),
        ),

        ExampleSection(
          title: 'Testo di aiuto e validazione',
          description:
              'Le convenzioni descritte in docs/form/introduzione/ valgono '
              'anche qui: helperText per l’istruzione, errorText per il '
              'messaggio di errore. Entrambi vengono riportati sul nodo del '
              'controllo, così un lettore di schermo li legge quando il campo '
              'prende il focus invece di incontrarli come testo sciolto.',
          code: 'ItSelect<String>(\n'
              "  label: 'Etichetta',\n"
              '  items: opzioni,\n'
              '  required: true,\n'
              "  errorText: 'Questo campo è obbligatorio',\n"
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItSelect<String>(
                label: 'Etichetta',
                hint: "Scegli un'opzione",
                items: _opzioni,
                helperText: 'Scegli il comune di residenza',
                onChanged: (_) {},
              ),
              const SizedBox(height: 40),
              ItSelect<String>(
                label: 'Etichetta',
                hint: "Scegli un'opzione",
                items: _opzioni,
                required: true,
                errorText: 'Questo campo è obbligatorio',
                value: _obbligatoria,
                onChanged: (v) => setState(() => _obbligatoria = v),
              ),
            ],
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Nessuna. La pagina Select della documentazione ha tre sezioni — '
              'Select, Select disabilitata e Select con gruppi — e sono tutte '
              'e tre riprodotte sopra.\n\n'
              'Va però segnalata una differenza rispetto al kit: sul web la '
              'select di base è un <select> nativo, quindi la tendina è quella '
              'del sistema operativo e non è disegnata dal foglio di stile. '
              'Qui la tendina è disegnata dal widget, e prende i suoi valori '
              'dalle regole che il kit dedica alla select avanzata '
              '(.bootstrap-select-wrapper): ombra 0 2px 10px, angoli da 4px, '
              'righe con 8px e 24px di spaziatura interna.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
