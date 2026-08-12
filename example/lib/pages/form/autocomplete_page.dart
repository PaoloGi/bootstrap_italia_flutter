import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/form/autocompletamento/
///
/// Section for section, in the docs' own order and with its headings. The
/// docs' page is built around a JavaScript plugin, so several of its sections
/// are about wiring rather than about the control; those are listed at the
/// bottom with the Flutter equivalent named, not silently dropped.
class AutocompletePage extends StatefulWidget {
  const AutocompletePage({super.key});

  @override
  State<AutocompletePage> createState() => _AutocompletePageState();
}

class _AutocompletePageState extends State<AutocompletePage> {
  static const _regioni = [
    'Abruzzo',
    'Basilicata',
    'Calabria',
    'Campania',
    'Emilia Romagna',
    'Friuli Venezia Giulia',
    'Lazio',
    'Liguria',
    'Lombardia',
    'Marche',
    'Molise',
    'Piemonte',
    'Puglia',
    'Sardegna',
    'Sicilia',
    'Toscana',
    'Trentino Alto Adige',
    'Umbria',
    "Valle d'Aosta",
    'Veneto',
  ];

  /// A stand-in for the docs' `comuni.json`: enough to show the dependency,
  /// not enough to pretend to be a data set.
  static const _comuni = <String, List<String>>{
    'Lazio': ['Roma', 'Latina', 'Frosinone', 'Rieti', 'Viterbo'],
    'Lombardia': ['Milano', 'Bergamo', 'Brescia', 'Como', 'Pavia'],
    'Toscana': ['Firenze', 'Pisa', 'Siena', 'Livorno', 'Arezzo'],
    'Campania': ['Napoli', 'Salerno', 'Caserta', 'Avellino', 'Benevento'],
  };

  /// The docs' "categoria alimento" example: two lists behind one select.
  static const _alimenti = <String, List<String>>{
    'Frutta': ['Albicocca', 'Banana', 'Ciliegia', 'Fragola', 'Mela', 'Pera'],
    'Verdura': ['Bietola', 'Carota', 'Melanzana', 'Spinacio', 'Zucchina'],
  };

  String? _categoria;
  String? _regione;
  String? _comuneScelto;
  String? _erroreComune = 'Seleziona un comune dall’elenco';

  static Future<List<String>> _cercaRegioni(String query) async {
    final lower = query.toLowerCase();
    return _regioni.where((r) => r.toLowerCase().contains(lower)).toList();
  }

  /// `source` as a *function* rather than an array — the docs' own answer to
  /// "populate this control from another field's value".
  Future<List<String>> _cercaAlimenti(String query) async {
    final lista = _alimenti[_categoria] ?? const <String>[];
    final lower = query.toLowerCase();
    return lista.where((a) => a.toLowerCase().contains(lower)).toList();
  }

  Future<List<String>> _cercaComuni(String query) async {
    final lista = _comuni[_regione] ?? const <String>[];
    final lower = query.toLowerCase();
    return lista.where((c) => c.toLowerCase().contains(lower)).toList();
  }

  /// The docs' `minLength: 3` example, over a deliberately large-feeling set.
  static Future<List<String>> _cercaComuniTutti(String query) async {
    final lower = query.toLowerCase();
    return _comuni.values
        .expand((l) => l)
        .where((c) => c.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Autocompletamento',
      children: [
        // ── Esempio di autocompletamento ───────────────────────────────────
        ExampleSection(
          title: 'Esempio di autocompletamento',
          description:
              'Il completamento automatico aiuta a scegliere una risposta da '
              'un elenco. Nel kit la sorgente è un array o una funzione '
              '(l’opzione source); qui è onSearch, che restituisce una Future '
              'e può quindi interrogare anche un servizio remoto. Quando i '
              'suggerimenti arrivano, il loro numero viene annunciato senza '
              'spostare il focus, come richiede il criterio 4.1.3.',
          code: 'ItAutocomplete<String>(\n'
              "  label: 'Regione',\n"
              '  onSearch: cercaRegioni,\n'
              '  displayStringForOption: (r) => r,\n'
              '  onSelected: (r) => print(r),\n'
              ')',
          child: ItAutocomplete<String>(
            label: 'Regione',
            onSearch: _cercaRegioni,
            displayStringForOption: (r) => r,
          ),
        ),

        // ── Cambiare i valori dinamicamente ────────────────────────────────
        ExampleSection(
          title: 'Cambiare i valori dinamicamente',
          description: 'Per popolare il controllo in base a un altro campo, la '
              'documentazione consiglia di passare a source una funzione che '
              'filtri i dati. In Flutter non serve nulla di più: onSearch è '
              'una chiusura, quindi legge lo stato corrente della pagina a '
              'ogni ricerca. Cambiando la categoria, i suggerimenti seguono.',
          code: 'ItSelect<String>(\n'
              "  label: 'Categoria alimento',\n"
              '  items: [\n'
              "    ItSelectItem(value: 'Frutta', label: 'Frutta'),\n"
              "    ItSelectItem(value: 'Verdura', label: 'Verdura'),\n"
              '  ],\n'
              '  value: categoria,\n'
              '  onChanged: (v) => setState(() => categoria = v),\n'
              ')\n\n'
              'ItAutocomplete<String>(\n'
              "  label: 'Alimento',\n"
              '  // legge `categoria` a ogni chiamata\n'
              '  onSearch: cercaAlimenti,\n'
              '  displayStringForOption: (a) => a,\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItSelect<String>(
                label: 'Categoria alimento',
                hint: 'Scegli una categoria',
                items: const [
                  ItSelectItem(value: 'Frutta', label: 'Frutta'),
                  ItSelectItem(value: 'Verdura', label: 'Verdura'),
                ],
                value: _categoria,
                onChanged: (v) => setState(() => _categoria = v),
              ),
              const SizedBox(height: 40),
              ItAutocomplete<String>(
                label: 'Alimento',
                onSearch: _cercaAlimenti,
                displayStringForOption: (a) => a,
                helperText: _categoria == null
                    ? 'Scegli prima una categoria'
                    : 'Cerca fra ${_alimenti[_categoria]!.length} elementi',
              ),
            ],
          ),
        ),

        ExampleSection(
          title: 'Esempio Regioni e Comuni',
          description:
              'Lo stesso schema applicato al caso che la documentazione porta '
              'per esteso: scelta la regione, il campo dei comuni cerca solo '
              'fra quelli che le appartengono.',
          code: 'ItSelect<String>(\n'
              "  label: 'Regione',\n"
              '  items: regioni,\n'
              '  value: regione,\n'
              '  onChanged: (v) => setState(() => regione = v),\n'
              ')\n\n'
              'ItAutocomplete<String>(\n'
              "  label: 'Comune',\n"
              '  onSearch: cercaComuni,\n'
              '  displayStringForOption: (c) => c,\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItSelect<String>(
                label: 'Regione',
                hint: 'Scegli una regione',
                items: [
                  for (final r in _comuni.keys)
                    ItSelectItem(value: r, label: r),
                ],
                value: _regione,
                onChanged: (v) => setState(() => _regione = v),
              ),
              const SizedBox(height: 40),
              ItAutocomplete<String>(
                label: 'Comune',
                onSearch: _cercaComuni,
                displayStringForOption: (c) => c,
              ),
            ],
          ),
        ),

        // ── Validazione ────────────────────────────────────────────────────
        ExampleSection(
          title: 'Validazione',
          description:
              'La documentazione insiste su un punto: quando si sceglie un '
              'valore dalla tendina, la validazione va rieseguita, perché il '
              'campo non ha ricevuto una digitazione. È quello che fa '
              'onSelected, l’equivalente del callback onConfirm del kit. '
              'L’esempio usa anche minQueryLength: 3, come il minLength della '
              'documentazione, per non proporre suggerimenti prima di tre '
              'caratteri.',
          code: 'ItAutocomplete<String>(\n'
              "  label: 'Comune di residenza',\n"
              '  minQueryLength: 3,\n'
              '  onSearch: cercaComuni,\n'
              '  displayStringForOption: (c) => c,\n'
              '  required: true,\n'
              '  errorText: errore,\n'
              '  // rivalida alla scelta, non solo alla digitazione\n'
              '  onSelected: (c) => setState(() => errore = null),\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItAutocomplete<String>(
                label: 'Comune di residenza',
                minQueryLength: 3,
                onSearch: _cercaComuniTutti,
                displayStringForOption: (c) => c,
                required: true,
                errorText: _erroreComune,
                onSelected: (c) => setState(() {
                  _comuneScelto = c;
                  _erroreComune = null;
                }),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: ItButton(
                  onPressed: () => setState(() {
                    _erroreComune = _comuneScelto == null
                        ? 'Seleziona un comune dall’elenco'
                        : null;
                  }),
                  child: const Text('Invia form'),
                ),
              ),
            ],
          ),
        ),

        // ── Internazionalizzazione (i18n) ──────────────────────────────────
        ExampleSection(
          title: 'Internazionalizzazione (i18n)',
          description:
              'Il kit passa le proprie stringhe al plugin per configurazione, '
              'con l’italiano come impostazione predefinita. Qui valgono le '
              'stesse regole del resto del pacchetto: senza alcun delegato '
              'installato tutto è in italiano, e ItLocalizations permette di '
              'sostituire le singole stringhe. Le due che questo controllo '
              'pronuncia sono l’annuncio dei risultati e il messaggio di '
              'elenco vuoto; entrambe si possono anche passare direttamente al '
              'widget.',
          code: 'ItAutocomplete<String>(\n'
              "  label: 'Regione',\n"
              '  onSearch: cercaRegioni,\n'
              '  displayStringForOption: (r) => r,\n'
              "  noResultsText: 'Nessuna regione corrisponde',\n"
              '  resultsAnnouncement: (n) =>\n'
              "      n == 1 ? '1 regione disponibile' : "
              "'\$n regioni disponibili',\n"
              ')',
          child: ItAutocomplete<String>(
            label: 'Regione',
            onSearch: _cercaRegioni,
            displayStringForOption: (r) => r,
            noResultsText: 'Nessuna regione corrisponde',
            resultsAnnouncement: _annuncioRegioni,
          ),
        ),

        // ── Beyond the docs ────────────────────────────────────────────────
        ExampleSection(
          title: 'Oltre la documentazione',
          description:
              'La pagina Autocompletamento non mostra né la variante grande né '
              'lo stato disabilitato, ma il primo è documentato nella pagina '
              'Input (.autocomplete-wrapper-big) e il secondo vale per tutti i '
              'controlli. Entrambi sono raccolti qui perché non vengano '
              'scambiati per riferimento.',
          code: 'ItAutocomplete<String>(large: true, …)\n'
              'ItAutocomplete<String>(enabled: false, …)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItAutocomplete<String>(
                label: 'Regione',
                icon: BootstrapItaliaIcons.it_search,
                large: true,
                onSearch: _cercaRegioni,
                displayStringForOption: (r) => r,
              ),
              const SizedBox(height: 40),
              ItAutocomplete<String>(
                label: 'Regione',
                icon: BootstrapItaliaIcons.it_search,
                enabled: false,
                onSearch: _cercaRegioni,
                displayStringForOption: (r) => r,
              ),
            ],
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Attivazione tramite codice — l’inizializzazione JavaScript del '
              'plugin SelectAutocomplete, con i metodi getInstance, '
              'getOrCreateInstance e dispose, che in Flutter non hanno '
              'equivalente. La tabella delle opzioni ha però una traduzione '
              'quasi esatta, ed è utile conoscerla: source diventa onSearch, '
              'minLength diventa minQueryLength, defaultValue diventa il testo '
              'iniziale del controller, required resta required, onConfirm '
              'diventa onSelected. Non hanno corrispettivo id e name, che '
              'servono a collegare l’input generato al form HTML che lo '
              'contiene.\n\n'
              'Breaking change — le modifiche introdotte dalla versione 2.14.0 '
              'nel modo di istanziare il componente via codice. Riguardano '
              'quella stessa API JavaScript.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// The plural form the "i18n" example passes to [ItAutocomplete].
///
/// A top-level function so the section above can stay `const`-friendly and so
/// the point it makes is visible: the announcement selects a form, it does not
/// interpolate one template.
String _annuncioRegioni(int count) =>
    count == 1 ? '1 regione disponibile' : '$count regioni disponibili';
