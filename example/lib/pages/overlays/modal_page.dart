import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/modale/
///
/// The docs split into "Esempi" — static panels frozen inside an
/// `.it-example-modal` so the anatomy can be read — and "Demo", where the same
/// dialogs are actually launched. Both halves are here, but every section
/// launches its dialog for real: a modal is a focus trap, and a frozen picture
/// of one would be the one part of the component that cannot be shown honestly
/// without opening it.
class ModalPage extends StatefulWidget {
  const ModalPage({super.key});

  @override
  State<ModalPage> createState() => _ModalPageState();
}

class _ModalPageState extends State<ModalPage> {
  static const _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
      'ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut '
      'aliquip ex ea commodo consequat.';

  /// The choice made in the "Modale con elementi form" example, kept on the
  /// page rather than in the dialog: the dialog is torn down when it closes,
  /// and a form that forgets its answer the moment you confirm it is not a
  /// form.
  String _option = 'opzione1';

  ItButton _launch(String label, VoidCallback onPressed) =>
      ItButton(onPressed: onPressed, child: Text(label));

  ItButton _close(BuildContext dialogContext, {String label = 'Ok'}) =>
      ItButton(
        variant: ItButtonVariant.primary,
        onPressed: () => Navigator.pop(dialogContext),
        child: Text(label),
      );

  ItButton _cancel(BuildContext dialogContext, {String label = 'Annulla'}) =>
      ItButton(
        variant: ItButtonVariant.secondary,
        outline: true,
        onPressed: () => Navigator.pop(dialogContext),
        child: Text(label),
      );

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Finestre modali',
      children: [
        // ── Accessibilità ──────────────────────────────────────────────────
        const ExampleSection(
          title: 'Accessibilità',
          description:
              'La documentazione chiede role="dialog", un aria-labelledby '
              'legato al titolo e, in mancanza di titolo, un aria-label '
              'esplicito. Il widget li applica da sé: la modale è un nodo di '
              'rotta con nome, e il nome è il titolo visibile — il che '
              'soddisfa anche il criterio «etichetta nel nome». Senza titolo '
              "il nome diventa «Finestra di dialogo», preso da "
              'ItLocalizations.dialog e quindi tradotto.\n\n'
              'Il focus entra nella modale alla comparsa e vi resta '
              'imprigionato, come deve essere per un dialogo. Proprio per '
              'questo deve sempre esistere una via di uscita da tastiera: Esc '
              'chiude la modale finché dismissible resta true. Impostarlo a '
              'false toglie la X, il tocco sullo sfondo e Esc insieme, e '
              'allora almeno una azione che chiuda la modale diventa '
              'obbligatoria — il widget lo verifica con una assert.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              "  title: 'Intestazione modale', // diventa il nome della rotta\n"
              "  body: Text('…'),\n"
              ')',
          child: SizedBox.shrink(),
        ),

        // ── Componenti della modale ────────────────────────────────────────
        ExampleSection(
          title: 'Componenti della modale',
          description: 'La modale è composta da intestazione, corpo e piede. '
              "L'intestazione compare quando si passa un title, il piede "
              'quando si passano delle actions: sono le due condizioni che '
              'decidono la struttura, non due parametri booleani a parte.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              "  title: 'Intestazione modale',\n"
              "  body: const Text('Descrizione scopo della modale.'),\n"
              '  actions: [\n'
              "    ItButton(variant: ItButtonVariant.secondary, outline: true,\n"
              "        onPressed: …, child: const Text('Azione 2')),\n"
              "    ItButton(onPressed: …, child: const Text('Azione 1')),\n"
              '  ],\n'
              ')',
          child: Builder(
            builder: (context) => _launch('Apri la modale', () {
              ItModal.show(
                context: context,
                title: 'Intestazione modale',
                body: const Text(
                  'Descrizione scopo della modale. Font Titillium 16px. '
                  'Leading 24px. omnis iste natus error.',
                ),
                actions: [
                  _cancel(context, label: 'Azione 2'),
                  _close(context, label: 'Azione 1'),
                ],
              );
            }),
          ),
        ),

        // ── Modale con pulsante di chiusura ────────────────────────────────
        ExampleSection(
          title: 'Modale con pulsante di chiusura',
          description:
              "Il pulsante di chiusura compare nell'intestazione quando "
              'dismissible vale true, che è il valore predefinito. La '
              'documentazione ricorda di dargli un testo per gli screen '
              'reader: qui il nome arriva da ItLocalizations.closeModal ed è '
              'volutamente diverso da quello dello sfondo cliccabile, perché '
              'due bersagli con lo stesso nome nello stesso dialogo sono '
              'indistinguibili.\n\n'
              'La X disegnata misura 16 pixel, sotto il minimo di 24 richiesto '
              'per le dimensioni del bersaglio: il widget riproduce '
              "l'imbottitura di 12 pixel che il kit annulla con margini "
              'negativi, così la superficie sensibile è molto più grande di '
              'quella dipinta.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              "  title: 'Intestazione modale',\n"
              '  dismissible: true, // predefinito\n'
              "  body: const Text('…'),\n"
              "  actions: [ItButton(onPressed: …, child: const Text('Ok'))],\n"
              ')',
          child: Builder(
            builder: (context) => _launch('Apri la modale', () {
              ItModal.show(
                context: context,
                title: 'Questo è un messaggio di notifica',
                body: const Text(
                  'In questo caso vengono forniti un pulsante di conferma e '
                  'uno di chiusura della modale.',
                ),
                actions: [_close(context)],
              );
            }),
          ),
        ),

        // ── Modale con icona ───────────────────────────────────────────────
        ExampleSection(
          title: 'Modale con icona',
          description:
              "Passando icon si ottiene il layout alert-modal: un'icona di 32 "
              'pixel nel colore primario, allineata in alto accanto al titolo. '
              "La documentazione dedica un riquadro all'accessibilità "
              "dell'icona e conclude che, quando il significato è già "
              'nel testo, la si nasconde alle tecnologie assistive. È quello '
              'che fa il widget: il titolo dice già di che avviso si tratta.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              '  icon: BootstrapItaliaIcons.it_warning_circle,\n'
              "  title: 'Questo è un messaggio di notifica…',\n"
              "  body: const Text('…'),\n"
              ')',
          child: Builder(
            builder: (context) => _launch('Apri la modale', () {
              ItModal.show(
                context: context,
                icon: BootstrapItaliaIcons.it_warning_circle,
                title:
                    'Questo è un messaggio di notifica più esteso del solito',
                body: const Text(
                  'In questo caso viene fornito solo un pulsante di conferma '
                  'della modale.',
                ),
                actions: [_close(context)],
              );
            }),
          ),
        ),

        // ── Modale con elementi form ───────────────────────────────────────
        ExampleSection(
          title: 'Modale con elementi form',
          description:
              'Il corpo è un widget qualunque, quindi può contenere elementi '
              'di modulo. Qui un ItRadioGroup, che porta con sé la navigazione '
              'con le frecce e la semantica di scelta esclusiva — quella che '
              'fa annunciare «1 di 3». Lo stato vive nella pagina, non nella '
              'modale, perché la modale viene smontata alla chiusura.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              "  title: 'Scegli una opzione',\n"
              '  body: ItRadioGroup<String>(\n'
              '    value: option,\n'
              '    options: const [\n'
              "      ItRadioOption(value: 'opzione1', label: 'Opzione 1'),\n"
              '    ],\n'
              '    onChanged: (value) => setState(() => option = value),\n'
              '  ),\n'
              ')',
          child: Builder(
            builder: (context) => _launch('Apri la modale', () {
              ItModal.show(
                context: context,
                title: 'Scegli una opzione',
                body: StatefulBuilder(
                  builder: (context, setInner) => ItRadioGroup<String>(
                    value: _option,
                    options: const [
                      ItRadioOption(value: 'opzione1', label: 'Opzione 1'),
                      ItRadioOption(value: 'opzione2', label: 'Opzione 2'),
                      ItRadioOption(value: 'opzione3', label: 'Opzione 3'),
                    ],
                    onChanged: (value) {
                      setState(() => _option = value);
                      setInner(() {});
                    },
                  ),
                ),
                actions: [_close(context)],
              );
            }),
          ),
        ),

        // ── Modale con Link List ───────────────────────────────────────────
        ExampleSection(
          title: 'Modale con Link List',
          description:
              'Allo stesso modo il corpo può contenere una lista di link. '
              "Nel kit questo richiede la classe it-dialog-link-list "
              "sull'elemento della modale, che azzera l'imbottitura laterale "
              'del corpo perché le righe della lista hanno già la propria; qui '
              "la lista è semplicemente il corpo, e ItList porta con sé le "
              'proprie spaziature.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              "  title: '1. Lorem ipsum dolor sit amet…',\n"
              '  body: ItList(\n'
              '    items: [\n'
              "      ItListItem(title: 'Link lista 1', onTap: () {}),\n"
              '    ],\n'
              '  ),\n'
              ')',
          child: Builder(
            builder: (context) => _launch('Apri la modale', () {
              ItModal.show(
                context: context,
                title: '1. Lorem ipsum dolor sit amet, consectetur '
                    'adipiscing elit.',
                body: ItList(
                  items: [
                    for (var i = 1; i <= 3; i++)
                      ItListItem(title: 'Link lista $i', onTap: () {}),
                  ],
                ),
                actions: [_close(context, label: 'Chiudi')],
              );
            }),
          ),
        ),

        // ── Modale popconfirm ──────────────────────────────────────────────
        ExampleSection(
          title: 'Modale popconfirm',
          description:
              'La variante popconfirm serve per brevi messaggi di conferma: '
              'pannello di 300 pixel, angoli arrotondati, intestazione e corpo '
              'più stretti e messaggio a 16 pixel invece che a 18. Il titolo è '
              'facoltativo — ometterlo rimuove tutta la fascia di '
              "intestazione, ed è quello che dice la documentazione.\n\n"
              'Senza intestazione non c\'è pulsante di chiusura, quindi le '
              'azioni diventano la sola via di uscita: è esattamente il caso '
              'previsto dalla assert su dismissible.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              '  popconfirm: true,\n'
              '  dismissible: false, // nessuna X, come nel markup del kit\n'
              "  body: const Text('Font Titillium 14px. Leading 21px.'),\n"
              '  actions: [\n'
              "    ItButton(onPressed: …, child: const Text('Azione 1')),\n"
              '    ItButton(variant: ItButtonVariant.secondary, outline: true,\n'
              "        onPressed: …, child: const Text('Azione 2')),\n"
              '  ],\n'
              ')',
          child: Builder(
            builder: (context) => Wrap(
              spacing: BootstrapItaliaSpacing.space2,
              runSpacing: BootstrapItaliaSpacing.space2,
              children: [
                _launch('Basico', () {
                  ItModal.show(
                    context: context,
                    popconfirm: true,
                    dismissible: false,
                    body: const Text('Font Titillium 14px. Leading 21px.'),
                    actions: [
                      _close(context, label: 'Azione 1'),
                      _cancel(context, label: 'Azione 2'),
                    ],
                  );
                }),
                _launch('Con Header', () {
                  ItModal.show(
                    context: context,
                    popconfirm: true,
                    dismissible: false,
                    title: 'Intestazione Popconfirm',
                    body: const Text('Font Titillium 14px. Leading 21px.'),
                    actions: [
                      _close(context, label: 'Azione 1'),
                      _cancel(context, label: 'Azione 2'),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),

        // ── Modale semplice ────────────────────────────────────────────────
        ExampleSection(
          title: 'Modale semplice',
          description:
              'La demo della documentazione: una modale con intestazione, un '
              'paragrafo e un solo pulsante di chiusura.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              "  title: 'Intestazione modale',\n"
              "  body: const Text('…'),\n"
              '  actions: [\n'
              "    ItButton(onPressed: …, child: const Text('Chiudi modale')),\n"
              '  ],\n'
              ')',
          child: Builder(
            builder: (context) => _launch('Lancia la demo della modale', () {
              ItModal.show(
                context: context,
                title: 'Intestazione modale',
                body: const Text(
                  'Font Titillium 16px. Leading 24px. omnis iste natus error.',
                ),
                actions: [_close(context, label: 'Chiudi modale')],
              );
            }),
          ),
        ),

        // ── Scroll di contenuti lunghi ─────────────────────────────────────
        ExampleSection(
          title: 'Scroll di contenuti lunghi',
          description:
              'Quando il contenuto supera l\'altezza della finestra, il corpo '
              'scorre. Con footerShadow il piede prende un\'ombra che lo '
              'stacca dal testo che gli passa sotto: è la classe '
              'modal-footer-shadow, e ha senso solo insieme a scrollable.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              "  title: 'Intestazione modale',\n"
              '  scrollable: true,\n'
              '  footerShadow: true,\n'
              '  body: Column(children: [...]),\n'
              ')',
          child: Builder(
            builder: (context) => _launch('Lancia la demo della modale', () {
              ItModal.show(
                context: context,
                title: 'Intestazione modale',
                scrollable: true,
                footerShadow: true,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 6; i++)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(_lorem),
                      ),
                  ],
                ),
                actions: [
                  _cancel(context),
                  _close(context, label: 'Azione 1'),
                ],
              );
            }),
          ),
        ),

        // ── Scroll di contenuti all'interno della modale ───────────────────
        ExampleSection(
          title: 'Scroll di contenuti all’interno della modale',
          description:
              'È la stessa cosa vista dal verso opposto: con scrollable '
              "l'intestazione e il piede restano fermi e scorre solo il corpo. "
              "Nel kit questo si ottiene con la classe it-dialog-scrollable; "
              'qui non esiste una seconda modalità, perché il pannello è già '
              'una colonna con il corpo flessibile in mezzo.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              "  title: 'Intestazione modale',\n"
              '  scrollable: true,\n'
              '  size: ItModalSize.large,\n'
              '  body: Column(children: [...]),\n'
              ')',
          child: Builder(
            builder: (context) => _launch('Lancia la demo della modale', () {
              ItModal.show(
                context: context,
                title: 'Intestazione modale',
                scrollable: true,
                size: ItModalSize.large,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 8; i++)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(_lorem),
                      ),
                  ],
                ),
                actions: [
                  _cancel(context),
                  _close(context, label: 'Azione 1'),
                ],
              );
            }),
          ),
        ),

        // ── Posizionamento ─────────────────────────────────────────────────
        ExampleSection(
          title: 'Posizionamento',
          description:
              'Quattro collocazioni, riunite in ItModalAlignment. center è la '
              'centratura verticale ed è il valore predefinito; top appoggia '
              'la modale in alto. left e right sono i pannelli laterali: '
              "occupano tutta l'altezza della finestra, entrano scorrendo dal "
              'proprio bordo invece che in dissolvenza, e tengono il piede '
              'ancorato in basso.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              '  alignment: ItModalAlignment.left,\n'
              '  scrollable: true,\n'
              "  title: 'Questo è un messaggio di notifica',\n"
              '  body: Column(children: [...]),\n'
              ')',
          child: Builder(
            builder: (context) => Wrap(
              spacing: BootstrapItaliaSpacing.space2,
              runSpacing: BootstrapItaliaSpacing.space2,
              children: [
                for (final (alignment, label) in const [
                  (ItModalAlignment.center, 'Centratura verticale'),
                  (ItModalAlignment.top, 'In alto'),
                  (ItModalAlignment.left, 'Allineamento a sinistra'),
                  (ItModalAlignment.right, 'Allineamento a destra'),
                ])
                  ItButton(
                    size: ItButtonSize.small,
                    onPressed: () => ItModal.show(
                      context: context,
                      alignment: alignment,
                      scrollable: true,
                      title: 'Questo è un messaggio di notifica',
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < 5; i++)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text(_lorem),
                            ),
                        ],
                      ),
                      actions: [_close(context)],
                    ),
                    child: Text(label),
                  ),
              ],
            ),
          ),
        ),

        // ── Rimuovere l'animazione ─────────────────────────────────────────
        ExampleSection(
          title: 'Rimuovere l’animazione',
          description: 'Con animated impostato a false la modale compare senza '
              'dissolvenza né scorrimento, che è quanto si ottiene togliendo '
              'la classe .fade dal markup del kit.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              '  animated: false,\n'
              "  title: 'Intestazione modale',\n"
              "  body: const Text('…'),\n"
              ')',
          child: Builder(
            builder: (context) => _launch('Apri senza animazione', () {
              ItModal.show(
                context: context,
                animated: false,
                title: 'Intestazione modale',
                body: const Text(
                  'Questa modale appare senza dissolvenza.',
                ),
                actions: [_close(context, label: 'Chiudi modale')],
              );
            }),
          ),
        ),

        // ── Dimensioni opzionali ───────────────────────────────────────────
        ExampleSection(
          title: 'Dimensioni opzionali',
          description:
              'Quattro larghezze massime: 300, 500, 800 e 1140 pixel. Sono le '
              'stesse dei modificatori .modal-sm, del valore predefinito, di '
              '.modal-lg e di .modal-xl. La larghezza è un massimo, non una '
              'misura fissa: su una finestra stretta il pannello si adatta e '
              'non produce scorrimento orizzontale.',
          code: 'ItModal.show(\n'
              '  context: context,\n'
              '  size: ItModalSize.large,\n'
              "  title: 'Modale grande',\n"
              "  body: const Text('…'),\n"
              ')',
          child: Builder(
            builder: (context) => Wrap(
              spacing: BootstrapItaliaSpacing.space2,
              runSpacing: BootstrapItaliaSpacing.space2,
              children: [
                for (final (size, label) in const [
                  (ItModalSize.small, 'Modale piccola'),
                  (ItModalSize.medium, 'Modale media'),
                  (ItModalSize.large, 'Modale grande'),
                  (ItModalSize.extraLarge, 'Modale molto grande'),
                ])
                  ItButton(
                    size: ItButtonSize.small,
                    onPressed: () => ItModal.show(
                      context: context,
                      size: size,
                      title: label,
                      body: Text(
                        'Larghezza massima ${size.maxWidth.toInt()} pixel.',
                      ),
                      actions: [_close(context)],
                    ),
                    child: Text(label),
                  ),
              ],
            ),
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Implementazione e Attivazione tramite codice, con le tabelle di '
              'opzioni, metodi ed eventi (data-bs-toggle, backdrop, keyboard, '
              'show.bs.modal e simili) — descrivono il plugin JavaScript. Qui '
              'la modale si apre chiamando ItModal.show, che restituisce un '
              'Future completato con il valore passato a Navigator.pop: è quel '
              'Future a fare da evento di chiusura.\n\n'
              "Il paragrafo sull'attributo autofocus, che HTML5 ignora nelle "
              'modali e che il kit consiglia di sostituire con JavaScript. '
              'Non ha corrispettivo: il focus entra nel dialogo da sé alla '
              "comparsa, ed è un requisito di accessibilità prima che una "
              'comodità.\n\n'
              'La nota secondo cui la modale rimuove lo scorrimento dal body '
              'della pagina. In Flutter una rotta modale copre già la pagina '
              'sottostante, che quindi non riceve eventi di scorrimento: non '
              "c'è nulla da disattivare.",
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
