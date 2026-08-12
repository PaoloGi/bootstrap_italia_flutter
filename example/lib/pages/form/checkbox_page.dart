import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/form/checkbox/
///
/// Section for section, in the docs' own order and with its headings.
class CheckboxPage extends StatefulWidget {
  const CheckboxPage({super.key});

  @override
  State<CheckboxPage> createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  static const _lorem = 'Lorem ipsum dolor sit amet, consectetur adipiscing '
      'elit. Maecenas molestie libero';

  bool _base = false;
  Set<String> _inline = {'selezionato'};
  Set<String> _raggruppati = {'a'};
  Set<String> _conDescrizione = {'a'};

  /// The children behind the "seleziona tutto" box in the Mixed Button
  /// example: the parent's state is computed from them, never cycled.
  List<bool> _figli = [true, false, false];

  bool get _tuttiSelezionati => _figli.every((v) => v);
  bool get _alcuniSelezionati => _figli.any((v) => v);

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Checkbox',
      children: [
        // ── Checkbox ───────────────────────────────────────────────────────
        ExampleSection(
          title: 'Checkbox',
          description:
              'Il riquadro è disegnato dal foglio di stile, non dal browser: '
              'un quadrato di 20px con bordo di 2px e angoli da 4px, e il '
              'segno di spunta è un rettangolo ruotato di 40 gradi con due '
              'soli bordi. Tutta la riga — non solo il riquadro — è un unico '
              'bersaglio, operabile con il tasto Tab e con la barra '
              'spaziatrice.',
          code: 'ItCheckbox(\n'
              '  value: valore,\n'
              "  label: 'Checkbox di esempio',\n"
              '  onChanged: (v) => setState(() => valore = v),\n'
              ')',
          child: ItCheckbox(
            value: _base,
            label: 'Checkbox di esempio',
            onChanged: (v) => setState(() => _base = v),
          ),
        ),

        // ── Inline ─────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Inline',
          description: 'Con inline le caselle si dispongono orizzontalmente '
              '(.form-check-inline). Il gruppo resta un <fieldset> con la sua '
              '<legend>: la didascalia è il nome del gruppo per la tecnologia '
              'assistiva, non una riga di testo che la precede.',
          code: 'ItCheckboxGroup<String>(\n'
              "  label: 'Gruppo di checkbox',\n"
              '  inline: true,\n'
              '  options: [\n'
              "    ItCheckboxOption(value: 'a', label: 'Checkbox non "
              "selezionato'),\n"
              "    ItCheckboxOption(value: 'b', label: 'Checkbox "
              "selezionato'),\n"
              '  ],\n'
              '  values: valori,\n'
              '  onChanged: (v) => setState(() => valori = v),\n'
              ')',
          child: ItCheckboxGroup<String>(
            label: 'Gruppo di checkbox',
            inline: true,
            options: const [
              ItCheckboxOption(
                value: 'non_selezionato',
                label: 'Checkbox non selezionato',
              ),
              ItCheckboxOption(
                value: 'selezionato',
                label: 'Checkbox selezionato',
              ),
            ],
            values: _inline,
            onChanged: (v) => setState(() => _inline = v),
          ),
        ),

        // ── Disabilitato ───────────────────────────────────────────────────
        const ExampleSection(
          title: 'Disabilitato',
          description:
              'Una casella disabilitata non si attiva né con il puntatore né '
              'con la tastiera e viene saltata dal tasto Tab, ma resta nella '
              'struttura semantica dichiarando sia di essere selezionata o no, '
              'sia di essere disabilitata. Il colore di validazione non la '
              'raggiunge: è lo stato disabilitato a impedire la risposta, e '
              'segnalarla come errata sarebbe una richiesta senza rimedio.',
          code: "ItCheckbox(\n"
              '  value: false,\n'
              '  enabled: false,\n'
              "  label: 'Checkbox disabilitato non selezionato',\n"
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItCheckbox(
                value: false,
                enabled: false,
                label: 'Checkbox disabilitato non selezionato',
              ),
              SizedBox(height: 8),
              ItCheckbox(
                value: true,
                enabled: false,
                label: 'Checkbox disabilitato selezionato',
              ),
            ],
          ),
        ),

        // ── Raggruppati visivamente ────────────────────────────────────────
        ExampleSection(
          title: 'Raggruppati visivamente',
          description:
              'Con visuallyGrouped la riga occupa tutta la larghezza, il '
              'riquadro passa a destra del testo e sotto compare una linea di '
              'separazione (.form-check-group). Solo l’ancoraggio del riquadro '
              'cambia lato: le misure interne restano quelle della variante '
              'normale.',
          code: 'ItCheckboxGroup<String>(\n'
              "  label: 'Gruppo di checkbox',\n"
              '  visuallyGrouped: true,\n'
              '  options: [\n'
              "    ItCheckboxOption(value: 'a', label: 'Checkbox "
              "selezionato'),\n"
              "    ItCheckboxOption(value: 'b', label: 'Checkbox non "
              "selezionato'),\n"
              '  ],\n'
              '  values: valori,\n'
              '  onChanged: (v) => setState(() => valori = v),\n'
              ')',
          child: ItCheckboxGroup<String>(
            label: 'Gruppo di checkbox',
            visuallyGrouped: true,
            options: const [
              ItCheckboxOption(value: 'a', label: 'Checkbox selezionato'),
              ItCheckboxOption(value: 'b', label: 'Checkbox non selezionato'),
              ItCheckboxOption(
                value: 'c',
                label: 'Checkbox disabilitato non selezionato',
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
              'Nella seconda variante della documentazione ogni opzione ha una '
              'propria descrizione. È helperText sulla singola opzione, non '
              'sul gruppo: viene letta come parte di quella riga — è '
              "l'aria-describedby che il kit mette su ciascun input — mentre "
              'quello del gruppo descrive tutto l’insieme.',
          code: 'ItCheckboxGroup<String>(\n'
              "  label: 'Gruppo di checkbox',\n"
              '  visuallyGrouped: true,\n'
              '  options: [\n'
              '    ItCheckboxOption(\n'
              "      value: 'a',\n"
              "      label: 'Checkbox selezionato',\n"
              "      helperText: 'Lorem ipsum dolor sit amet…',\n"
              '    ),\n'
              '  ],\n'
              '  values: valori,\n'
              '  onChanged: (v) => setState(() => valori = v),\n'
              ')',
          child: ItCheckboxGroup<String>(
            label: 'Gruppo di checkbox',
            visuallyGrouped: true,
            options: const [
              ItCheckboxOption(
                value: 'a',
                label: 'Checkbox selezionato',
                helperText: _lorem,
              ),
              ItCheckboxOption(
                value: 'b',
                label: 'Checkbox non selezionato',
                helperText: _lorem,
              ),
              ItCheckboxOption(
                value: 'c',
                label: 'Checkbox disabilitato non selezionato',
                helperText: _lorem,
                enabled: false,
              ),
            ],
            values: _conDescrizione,
            onChanged: (v) => setState(() => _conDescrizione = v),
          ),
        ),

        // ── Mixed Button ───────────────────────────────────────────────────
        ExampleSection(
          title: 'Mixed Button',
          description:
              'Lo stato intermedio (.semi-checked). Non è un terzo passo di un '
              'ciclo che si ottiene toccando la casella: è uno stato calcolato '
              'da altre caselle — «seleziona tutto», soddisfatto solo in parte '
              '— e per questo indeterminate lo decide chi usa il widget. Il '
              'riquadro prende un azzurro diverso da quello dello stato '
              'selezionato, ed è voluto: è la distinzione che questo stato '
              'esiste per mostrare.',
          code: 'ItCheckbox(\n'
              '  value: tuttiSelezionati,\n'
              '  indeterminate: alcuniSelezionati && !tuttiSelezionati,\n'
              "  label: 'Mixed button attivo',\n"
              '  onChanged: (v) => setState(\n'
              '    () => figli = List.filled(figli.length, v),\n'
              '  ),\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItCheckbox(
                value: _tuttiSelezionati,
                indeterminate: _alcuniSelezionati && !_tuttiSelezionati,
                label: 'Mixed button attivo',
                onChanged: (v) => setState(
                  () => _figli = List.filled(_figli.length, v),
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < _figli.length; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 8),
                  child: ItCheckbox(
                    value: _figli[i],
                    label: 'Elemento ${i + 1}',
                    onChanged: (v) => setState(() => _figli[i] = v),
                  ),
                ),
            ],
          ),
        ),

        // ── Beyond the docs ────────────────────────────────────────────────
        ExampleSection(
          title: 'Validazione',
          description:
              'Non è una sezione della pagina Checkbox: la validazione è '
              'descritta in docs/form/introduzione/. Il colore tinge il '
              'riquadro e l’etichetta di ogni casella del gruppo, perché lo '
              'stato appartiene all’insieme, mentre il messaggio compare una '
              'volta sola sotto di esso.',
          code: 'ItCheckboxGroup<String>(\n'
              "  label: 'Gruppo di checkbox',\n"
              '  options: opzioni,\n'
              '  values: valori,\n'
              '  required: true,\n'
              "  errorText: 'Seleziona almeno un’opzione',\n"
              ')',
          child: ItCheckboxGroup<String>(
            label: 'Gruppo di checkbox',
            options: const [
              ItCheckboxOption(value: 'a', label: 'Prima opzione'),
              ItCheckboxOption(value: 'b', label: 'Seconda opzione'),
            ],
            values: const {},
            required: true,
            errorText: 'Seleziona almeno un’opzione',
            onChanged: (_) {},
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Breaking change — le modifiche introdotte dalla versione 2.10.0 '
              'del kit: usare <fieldset> per raggruppare i campi e sostituire '
              'aria-labelledby con aria-describedby. Riguardano il markup HTML '
              'di chi aggiorna il foglio di stile; qui sono già il '
              'comportamento predefinito di ItCheckboxGroup, che espone il '
              'gruppo come contenitore con nome proprio e riporta le '
              'descrizioni sul nodo del controllo.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
