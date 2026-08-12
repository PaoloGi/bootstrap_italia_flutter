import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/alert/
///
/// Section for section, in the docs' own order and with its headings. The three
/// JavaScript sections at the foot of the page have no Flutter equivalent and
/// are accounted for at the bottom rather than left unexplained.
class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  bool _showDismissible = true;

  /// The five variants the docs list, in their order. `secondary` is absent on
  /// purpose: the compiled stylesheet has no `.alert-secondary` rule at all.
  static const _variants = <ItAlertVariant, String>{
    ItAlertVariant.primary: 'primary',
    ItAlertVariant.info: 'info',
    ItAlertVariant.success: 'success',
    ItAlertVariant.warning: 'warning',
    ItAlertVariant.danger: 'danger',
  };

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Alert',
      children: [
        // ── Esempi ─────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Esempi',
          description:
              'Gli avvisi sono disponibili in cinque tipologie e si adattano a '
              'qualsiasi lunghezza di testo. Ogni variante porta con sé la '
              'propria icona: il foglio di stile la disegna come immagine di '
              'sfondo e riserva comunque il rientro di 4em che le serve, '
              "quindi l'icona non è opzionale ma predefinita. Non esiste una "
              'variante secondary — la documentazione ne elenca cinque.',
          code: 'ItAlert(\n'
              '  variant: ItAlertVariant.primary,\n'
              "  body: Text('Questo è un alert di tipo primary.'),\n"
              ')',
          child: Column(
            children: [
              for (final entry in _variants.entries)
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: BootstrapItaliaSpacing.space3),
                  child: ItAlert(
                    variant: entry.key,
                    body: Text.rich(
                      TextSpan(children: [
                        const TextSpan(text: 'Questo è un alert di tipo "'),
                        TextSpan(
                          text: entry.value,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: '".'),
                      ]),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Trasmettere significato alle tecnologie assistive ──────────────
        ExampleSection(
          title: 'Trasmettere significato alle tecnologie assistive',
          description:
              "L'uso del colore aggiunge un significato solo visivo, che non "
              'raggiunge chi usa uno screen reader. Il colore e la relativa '
              "icona vanno quindi considerati ridondanti: qui l'informazione "
              '«questa è una scadenza superata» è nel testo. Se il testo non '
              'la contiene, si può aggiungere con Semantics(label: …) senza '
              'mostrarla a schermo — è la controparte Flutter della classe '
              '.visually-hidden.',
          code: 'ItAlert(\n'
              '  variant: ItAlertVariant.danger,\n'
              "  body: Text('Errore: la domanda non è stata inviata.'),\n"
              ')\n\n'
              '// Testo per il solo screen reader:\n'
              'Semantics(\n'
              "  label: 'Errore. La domanda non è stata inviata.',\n"
              "  child: ExcludeSemantics(child: Text('Non inviata')),\n"
              ')',
          child: const ItAlert(
            variant: ItAlertVariant.danger,
            body: Text(
              'Errore: la domanda non è stata inviata. Il termine per la '
              'presentazione è scaduto il 30 giugno.',
            ),
          ),
        ),

        // ── Link evidenziato ───────────────────────────────────────────────
        ExampleSection(
          title: 'Link evidenziato',
          description: "ItAlertLink dà risalto a un collegamento all'interno "
              "dell'avviso: colore primario, peso 600 e sottolineatura. È un "
              'widget e non uno stile perché un TextSpan con un riconoscitore '
              'di tap risponde solo al puntatore — non riceve il fuoco, non si '
              'attiva da tastiera e non viene annunciato come link. Si inserisce '
              'nel testo con un WidgetSpan allineato alla linea di base.',
          code: 'Text.rich(TextSpan(children: [\n'
              "  TextSpan(text: 'Questo è un alert con un esempio di '),\n"
              '  WidgetSpan(\n'
              '    alignment: PlaceholderAlignment.baseline,\n'
              '    baseline: TextBaseline.alphabetic,\n'
              "    child: ItAlertLink(label: 'link', onPressed: () {}),\n"
              '  ),\n'
              "  TextSpan(text: ' evidenziato.'),\n"
              ']))',
          child: ItAlert(
            variant: ItAlertVariant.danger,
            body: Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Questo è un alert con un esempio di '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: ItAlertLink(
                    label: 'link',
                    semanticLabel: 'Leggi le istruzioni per la compilazione',
                    onPressed: () {},
                  ),
                ),
                const TextSpan(text: ' evidenziato.'),
              ]),
            ),
          ),
        ),

        // ── Contenuto aggiuntivo ───────────────────────────────────────────
        ExampleSection(
          title: 'Contenuto aggiuntivo',
          description:
              'Un avviso può contenere una intestazione, più paragrafi e dei '
              'divisori. Il titolo si passa a title, che corrisponde a '
              '.alert-heading; il resto è un widget qualsiasi in body, quindi '
              'un Column con Divider dove la documentazione mette un <hr>.',
          code: 'ItAlert(\n'
              '  variant: ItAlertVariant.success,\n'
              "  title: 'Avviso di successo!',\n"
              '  body: Column(\n'
              '    crossAxisAlignment: CrossAxisAlignment.start,\n'
              '    children: [\n'
              "      Text('…'),\n"
              '      Divider(),\n'
              "      Text('…'),\n"
              '    ],\n'
              '  ),\n'
              ')',
          child: const ItAlert(
            variant: ItAlertVariant.success,
            title: 'Avviso di successo!',
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stai leggendo questo importante messaggio di avviso di '
                  'successo. Questo testo di esempio sarà più lungo in modo da '
                  'poter vedere come funzioni la spaziatura all\'interno di un '
                  'avviso con questo tipo di contenuto.',
                ),
                Divider(height: 32),
                Text(
                  'Quando necessario, assicurati di inserire le utilità di '
                  'margine per mantenere gli spazi equilibrati.',
                ),
              ],
            ),
          ),
        ),

        // ── Chiusura ───────────────────────────────────────────────────────
        ExampleSection(
          title: 'Chiusura',
          description: 'Con dismissible: true compare il pulsante di chiusura. '
              "L'avviso qui si gestisce da sé e avvisa a cose fatte con "
              'onDismissed; passando visible il controllo torna al genitore e '
              'la richiesta arriva invece su onDismiss. I due non convivono, e '
              "un assert lo ricorda a chi prova: sarebbero due sorgenti di "
              'verità sulla stessa visibilità.',
          code: 'ItAlert(\n'
              '  variant: ItAlertVariant.warning,\n'
              '  dismissible: true,\n'
              '  onDismissed: () => setState(() => _visible = false),\n'
              "  body: Text('Alcuni campi inseriti sono da controllare.'),\n"
              ')',
          child: _showDismissible
              ? ItAlert(
                  variant: ItAlertVariant.warning,
                  dismissible: true,
                  onDismissed: () => setState(() => _showDismissible = false),
                  body: const Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: 'Attenzione ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                          text: 'Alcuni campi inseriti sono da controllare.'),
                    ]),
                  ),
                )
              : ItButton(
                  variant: ItButtonVariant.secondary,
                  onPressed: () => setState(() => _showDismissible = true),
                  child: const Text('Mostra di nuovo'),
                ),
        ),

        // ── Accessibilità (sotto Chiusura) ─────────────────────────────────
        ExampleSection(
          title: 'Accessibilità',
          description:
              'Il nome accessibile del pulsante di chiusura va riferito al '
              'contesto. Senza dismissLabel viene usato «Chiudi», che è '
              "corretto ma generico: in una pagina con più avvisi non "
              'distingue quale si sta chiudendo. Qui è «Chiudi l\'avviso di '
              'manutenzione».',
          code: 'ItAlert(\n'
              '  dismissible: true,\n'
              "  dismissLabel: \"Chiudi l'avviso di manutenzione\",\n"
              '  onDismissed: () {},\n'
              "  body: Text('…'),\n"
              ')',
          child: ItAlert(
            variant: ItAlertVariant.info,
            dismissible: true,
            dismissLabel: "Chiudi l'avviso di manutenzione",
            onDismissed: () {},
            body: const Text(
              'Il servizio sarà sospeso per manutenzione domenica 14 dalle '
              '2:00 alle 6:00.',
            ),
          ),
        ),

        // Not a docs section: the icon is normally the variant's own, and this
        // shows the two ways of departing from that.
        ExampleSection(
          title: 'Icona: sostituirla o toglierla',
          description:
              "L'icona predefinita segue la variante. Con icon si sostituisce "
              'il glifo, con showIcon: false si toglie del tutto — il rientro '
              'di 64px resta comunque, perché il foglio di stile non lo riduce '
              "quando l'immagine manca. Sono le due uscite dal comportamento "
              'predefinito, non una impostazione da usare abitualmente.',
          code: 'ItAlert(icon: BootstrapItaliaIcons.it_calendar, body: …)\n'
              'ItAlert(showIcon: false, body: …)',
          child: Column(
            children: [
              const ItAlert(
                variant: ItAlertVariant.info,
                icon: BootstrapItaliaIcons.it_calendar,
                body: Text('Icona sostituita: it_calendar.'),
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space3),
              const ItAlert(
                variant: ItAlertVariant.info,
                showIcon: false,
                body: Text('Nessuna icona, rientro invariato.'),
              ),
            ],
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              "Attivazione tramite codice — riguarda l'inizializzazione "
              'JavaScript del kit (new Alert(element), data-bs-dismiss), che '
              'in Flutter non esiste: il widget è già attivo appena costruito '
              'e il pulsante di chiusura è cablato da dismissible.\n\n'
              'Metodi — close(), dispose(), getInstance() e '
              "getOrCreateInstance() sono l'API JavaScript dell'istanza. "
              "L'equivalente qui è ricostruire il widget: visible: false lo "
              'nasconde, visible: true lo rimostra.\n\n'
              'Eventi — close.bs.alert e closed.bs.alert. Hanno però un '
              'corrispettivo esatto, ed è la ragione dei due callback: '
              'onDismiss è il tempo presente (la richiesta, prima del fatto) e '
              'onDismissed il participio (a chiusura avvenuta), esattamente '
              'come la coppia Bootstrap.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
