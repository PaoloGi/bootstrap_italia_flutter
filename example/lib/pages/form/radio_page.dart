import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/form/radio-button/
///
/// Section for section, in the docs' own order and with its headings.
class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  static const _lorem = 'Lorem ipsum dolor sit amet, consectetur adipiscing '
      'elit. Maecenas molestie libero';

  String? _base;
  String? _inline;
  String? _raggruppati = 'a';
  String? _conDescrizione = 'a';
  String? _obbligatorio;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Radio Button',
      children: [
        // ── Radio Button ───────────────────────────────────────────────────
        ExampleSection(
          title: 'Radio Button',
          description:
              'I radio sono mutuamente esclusivi, e il gruppo è ciò che li '
              'rende tali: ItRadioGroup lega più cerchi a un solo valore, '
              'muove la selezione con le frecce e fa annunciare «1 di 3». Un '
              'ItRadio da solo non può spegnersi da sé — come in HTML, dove '
              'un radio già selezionato non emette alcun evento se lo si '
              'tocca di nuovo.',
          code: 'ItRadioGroup<String>(\n'
              "  label: 'Gruppo di radio',\n"
              '  options: [\n'
              "    ItRadioOption(value: 'a', label: 'Radio di esempio 1'),\n"
              "    ItRadioOption(value: 'b', label: 'Radio di esempio 2'),\n"
              '  ],\n'
              '  value: valore,\n'
              '  onChanged: (v) => setState(() => valore = v),\n'
              ')',
          child: ItRadioGroup<String>(
            label: 'Gruppo di radio',
            options: const [
              ItRadioOption(value: 'a', label: 'Radio di esempio 1'),
              ItRadioOption(value: 'b', label: 'Radio di esempio 2'),
            ],
            value: _base,
            onChanged: (v) => setState(() => _base = v),
          ),
        ),

        // ── Inline ─────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Inline',
          description: 'Con inline le opzioni si dispongono orizzontalmente '
              '(.form-check-inline), utile per scelte brevi. Cambia solo la '
              'disposizione: la navigazione con le frecce e l’annuncio della '
              'posizione restano identici.',
          code: 'ItRadioGroup<String>(\n'
              "  label: 'Gruppo di radio',\n"
              '  inline: true,\n'
              '  options: [\n'
              "    ItRadioOption(value: 'a', label: 'Opzione 1'),\n"
              "    ItRadioOption(value: 'b', label: 'Opzione 2'),\n"
              '  ],\n'
              '  value: valore,\n'
              '  onChanged: (v) => setState(() => valore = v),\n'
              ')',
          child: ItRadioGroup<String>(
            label: 'Gruppo di radio',
            inline: true,
            options: const [
              ItRadioOption(value: 'a', label: 'Opzione 1'),
              ItRadioOption(value: 'b', label: 'Opzione 2'),
            ],
            value: _inline,
            onChanged: (v) => setState(() => _inline = v),
          ),
        ),

        // ── Disabilitato ───────────────────────────────────────────────────
        ExampleSection(
          title: 'Disabilitato',
          description:
              'Un’opzione disabilitata viene saltata sia dal tasto Tab sia '
              'dalla navigazione con le frecce, ma continua a dichiarare se è '
              'la scelta corrente. Cerchio e pallino passano al grigio chiaro '
              'previsto dal kit, che non è lo stesso grigio del bordo a '
              'riposo.',
          code: 'ItRadioGroup<String>(\n'
              "  label: 'Gruppo di radio',\n"
              '  options: [\n'
              '    ItRadioOption(\n'
              "      value: 'a',\n"
              "      label: 'Opzione 1 selezionato',\n"
              '      enabled: false,\n'
              '    ),\n'
              '  ],\n'
              "  value: 'a',\n"
              ')',
          child: ItRadioGroup<String>(
            label: 'Gruppo di radio',
            options: const [
              ItRadioOption(
                value: 'a',
                label: 'Opzione 1 selezionato',
                enabled: false,
              ),
              ItRadioOption(
                value: 'b',
                label: 'Opzione 2 non selezionato',
                enabled: false,
              ),
            ],
            value: 'a',
            onChanged: (_) {},
          ),
        ),

        // ── Raggruppati visivamente ────────────────────────────────────────
        ExampleSection(
          title: 'Raggruppati visivamente',
          description:
              'Con visuallyGrouped la riga occupa tutta la larghezza, il '
              'cerchio passa a destra del testo e sotto compare una linea di '
              'separazione (.form-check-group). Cambia solo il lato a cui il '
              'cerchio è ancorato: il margine di 5px, il diametro di 20px e il '
              'pallino ridotto al 64% restano quelli della variante normale.',
          code: 'ItRadioGroup<String>(\n'
              "  label: 'Gruppo di radio',\n"
              '  visuallyGrouped: true,\n'
              '  options: [\n'
              "    ItRadioOption(value: 'a', label: 'Opzione 1'),\n"
              "    ItRadioOption(value: 'b', label: 'Opzione 2'),\n"
              '  ],\n'
              '  value: valore,\n'
              '  onChanged: (v) => setState(() => valore = v),\n'
              ')',
          child: ItRadioGroup<String>(
            label: 'Gruppo di radio',
            visuallyGrouped: true,
            options: const [
              ItRadioOption(value: 'a', label: 'Opzione 1'),
              ItRadioOption(value: 'b', label: 'Opzione 2'),
              ItRadioOption(value: 'c', label: 'Opzione 3'),
            ],
            value: _raggruppati,
            onChanged: (v) => setState(() => _raggruppati = v),
          ),
        ),

        ExampleSection(
          title: 'Raggruppati visivamente, con testo descrittivo',
          description:
              'Nella seconda variante della documentazione ogni opzione porta '
              'la propria descrizione. È helperText sulla singola opzione: '
              'viene letta come parte di quella riga — è l’aria-describedby '
              'che il kit mette su ciascun input — mentre quello del gruppo '
              'descrive tutto l’insieme.',
          code: 'ItRadioGroup<String>(\n'
              "  label: 'Gruppo di radio',\n"
              '  visuallyGrouped: true,\n'
              '  options: [\n'
              '    ItRadioOption(\n'
              "      value: 'a',\n"
              "      label: 'Opzione 1',\n"
              "      helperText: 'Lorem ipsum dolor sit amet…',\n"
              '    ),\n'
              '  ],\n'
              '  value: valore,\n'
              '  onChanged: (v) => setState(() => valore = v),\n'
              ')',
          child: ItRadioGroup<String>(
            label: 'Gruppo di radio',
            visuallyGrouped: true,
            options: const [
              ItRadioOption(value: 'a', label: 'Opzione 1', helperText: _lorem),
              ItRadioOption(value: 'b', label: 'Opzione 2', helperText: _lorem),
              ItRadioOption(value: 'c', label: 'Opzione 3', helperText: _lorem),
            ],
            value: _conDescrizione,
            onChanged: (v) => setState(() => _conDescrizione = v),
          ),
        ),

        // ── Beyond the docs ────────────────────────────────────────────────
        ExampleSection(
          title: 'Validazione',
          description:
              'Non è una sezione della pagina Radio Button: la validazione è '
              'descritta in docs/form/introduzione/. Lo stato di errore vive '
              'sul gruppo, non sulle singole opzioni — è l’insieme a non aver '
              'ricevuto risposta — quindi il messaggio compare una volta sola '
              'e il colore tinge tutti i cerchi.',
          code: 'ItRadioGroup<String>(\n'
              "  label: 'Gruppo di radio',\n"
              '  options: opzioni,\n'
              '  required: true,\n'
              "  errorText: 'Scegli un’opzione',\n"
              ')',
          child: ItRadioGroup<String>(
            label: 'Gruppo di radio',
            options: const [
              ItRadioOption(value: 'a', label: 'Opzione 1'),
              ItRadioOption(value: 'b', label: 'Opzione 2'),
            ],
            required: true,
            errorText: 'Scegli un’opzione',
            value: _obbligatorio,
            onChanged: (v) => setState(() => _obbligatorio = v),
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
              'comportamento predefinito di ItRadioGroup, che espone il gruppo '
              'con il ruolo radiogroup e un nome proprio, e riporta le '
              'descrizioni sul nodo del controllo.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
