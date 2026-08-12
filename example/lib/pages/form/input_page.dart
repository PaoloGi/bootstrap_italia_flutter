import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/form/input/
///
/// Section for section, in the docs' own order and with its headings. The
/// sections that are deliberately absent are listed at the bottom of the page
/// with the reason, rather than left for a reader to wonder about.
class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  /// Pre-filled fields need a controller each; the read-only examples are the
  /// only ones the docs show with a value already in them.
  final _readOnly = TextEditingController(text: 'Sola lettura');
  final _plaintext = TextEditingController(text: 'Sola lettura');

  /// The twenty Italian regions, the data set the docs' own autocomplete uses.
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

  static Future<List<String>> _cercaRegioni(String query) async {
    final lower = query.toLowerCase();
    return _regioni.where((r) => r.toLowerCase().contains(lower)).toList();
  }

  /// The docs' "autocompletamento e dati" set: a label and an icon per result.
  static const _risultati = [
    _Risultato('Paola Pistoia', 'Profilo', BootstrapItaliaIcons.it_user),
    _Risultato('Pierluigi Rossi', 'Profilo', BootstrapItaliaIcons.it_user),
    _Risultato('Comune di Pisa', 'Amministrazione', BootstrapItaliaIcons.it_pa),
    _Risultato(
      'Linee guida per i cataloghi',
      'Documento',
      BootstrapItaliaIcons.it_file,
    ),
  ];

  static Future<List<_Risultato>> _cercaRisultati(String query) async {
    final lower = query.toLowerCase();
    return _risultati
        .where((r) => r.testo.toLowerCase().contains(lower))
        .toList();
  }

  @override
  void dispose() {
    _readOnly.dispose();
    _plaintext.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Input',
      children: [
        // ── Esempi di campi di input ───────────────────────────────────────
        ExampleSection(
          title: 'Esempi di campi di input',
          description:
              "La documentazione insiste sull'attributo type: è quello che "
              'attiva i controlli nativi del browser. In Flutter la scelta '
              'equivalente è keyboardType, che decide quale tastiera compare '
              "sul dispositivo — ed è l'unica cosa che distingue questi cinque "
              'campi fra loro.',
          code: "ItInput(label: 'Campo di tipo testuale')\n"
              "ItInput(\n"
              "  label: 'Campo di tipo email',\n"
              '  keyboardType: TextInputType.emailAddress,\n'
              ')\n'
              "ItInput(\n"
              "  label: 'Campo di tipo numerico',\n"
              '  keyboardType: TextInputType.number,\n'
              ')\n'
              "ItInput(\n"
              "  label: 'Campo di tipo telefono',\n"
              '  keyboardType: TextInputType.phone,\n'
              ')',
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItInput(label: 'Campo di tipo testuale'),
              SizedBox(height: 32),
              ItInput(
                label: 'Campo di tipo email',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 32),
              ItInput(
                label: 'Campo di tipo numerico',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 32),
              ItInput(
                label: 'Campo di tipo telefono',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 32),
              ItInput(
                label: 'Campo di tipo ora',
                hint: 'hh:mm',
                keyboardType: TextInputType.datetime,
              ),
            ],
          ),
        ),

        // ── Utilizzo di placeholder e label ────────────────────────────────
        const ExampleSection(
          title: 'Utilizzo di placeholder e label',
          description:
              "L'etichetta si riposiziona da sola quando il campo riceve il "
              'focus o contiene un valore. Indicando anche un hint '
              "(il placeholder della documentazione) l'etichetta parte già "
              'sollevata, così i due testi non si sovrappongono mai.',
          code: "ItInput(label: 'Etichetta di esempio')\n\n"
              'ItInput(\n'
              "  label: 'Etichetta di esempio',\n"
              "  hint: 'Testo di esempio',\n"
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItInput(label: 'Etichetta di esempio'),
              SizedBox(height: 32),
              ItInput(
                label: 'Etichetta di esempio',
                hint: 'Testo di esempio',
              ),
            ],
          ),
        ),

        const ExampleSection(
          title: 'Accessibilità: associazione del testo di aiuto con i campi',
          description:
              'La documentazione chiede di collegare il testo di aiuto al '
              'campo con aria-describedby, perché un lettore di schermo lo '
              'legga quando il campo prende il focus. Qui non serve un '
              'attributo: helperText viene escluso dalla riga di testo e '
              'riportato come hint sul nodo del campo stesso, che è '
              "l'associazione di cui la tecnologia assistiva ha bisogno.",
          code: 'ItInput(\n'
              "  label: 'Etichetta di esempio',\n"
              "  hint: 'Testo di esempio',\n"
              "  helperText: 'Ulteriore testo informativo',\n"
              ')',
          child: ItInput(
            label: 'Etichetta di esempio',
            hint: 'Testo di esempio',
            helperText: 'Ulteriore testo informativo',
          ),
        ),

        // ── Input con icona o pulsanti ─────────────────────────────────────
        ExampleSection(
          title: 'Input con icona o pulsanti',
          description:
              "L'icona sta in un contenitore da 40px alla sinistra del campo "
              '(.input-group-text) e il pulsante alla sua destra '
              '(.input-group-append). Con icona e senza hint, l\'etichetta a '
              'riposo rientra di 2.25rem per non finire sotto l\'icona.',
          code: 'ItInput(\n'
              "  label: 'Con etichetta',\n"
              '  icon: BootstrapItaliaIcons.it_pencil,\n'
              ')\n\n'
              'ItInput(\n'
              "  label: 'Con etichetta e pulsante \"primary\"',\n"
              '  icon: BootstrapItaliaIcons.it_pencil,\n'
              '  trailingAction: ItButton(\n'
              '    onPressed: () {},\n'
              "    child: Text('Invio'),\n"
              '  ),\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ItInput(
                label: 'Con Etichetta',
                icon: BootstrapItaliaIcons.it_pencil,
              ),
              const SizedBox(height: 32),
              const ItInput(
                label: 'Con Etichetta e placeholder',
                icon: BootstrapItaliaIcons.it_pencil,
                hint: 'Lorem Ipsum',
              ),
              const SizedBox(height: 32),
              ItInput(
                label: 'Con Etichetta e pulsante "primary"',
                icon: BootstrapItaliaIcons.it_pencil,
                trailingAction: ItButton(
                  onPressed: () {},
                  child: const Text('Invio'),
                ),
              ),
            ],
          ),
        ),

        const ExampleSection(
          title: 'Accessibilità delle icone',
          description:
              "La documentazione distingue due casi. Se l'icona è decorativa — "
              'come la matita qui sopra, che ripete quello che il campo già '
              "dice — va nascosta alla tecnologia assistiva, ed è ciò che "
              "ItInput fa di default. Se invece l'icona porta un significato "
              "che il testo accanto non spiega, il posto dove dirlo è "
              'semanticLabel del campo: un nome sul campo, non un secondo nodo '
              'accanto ad esso.',
          code: 'ItInput(\n'
              "  label: 'Importo',\n"
              '  icon: BootstrapItaliaIcons.it_warning_circle,\n'
              "  semanticLabel: 'Importo, campo con avviso di soglia',\n"
              ')',
          child: ItInput(
            label: 'Importo',
            icon: BootstrapItaliaIcons.it_warning_circle,
            semanticLabel: 'Importo, campo con avviso di soglia',
          ),
        ),

        // ── Disabilitato ───────────────────────────────────────────────────
        const ExampleSection(
          title: 'Disabilitato',
          description:
              'Un campo disabilitato non è modificabile, non viene raggiunto '
              'dal tasto Tab e prende lo sfondo grigio previsto dal kit. '
              'Resta però nella struttura semantica della pagina, dichiarando '
              'il proprio stato: inerte non vuol dire assente.',
          code: "ItInput(label: 'Contenuto disabilitato', enabled: false)",
          child: ItInput(label: 'Contenuto disabilitato', enabled: false),
        ),

        // ── Readonly ───────────────────────────────────────────────────────
        ExampleSection(
          title: 'Readonly',
          description: 'A differenza di disabled, readOnly lascia il campo '
              'selezionabile e copiabile: cambia solo la possibilità di '
              "modificarne il valore. Lo sfondo resta bianco, perché il grigio "
              'del kit è riservato ai campi disabilitati.',
          code: 'ItInput(\n'
              "  label: 'Contenuto in sola lettura',\n"
              '  controller: TextEditingController(text: \'Sola lettura\'),\n'
              '  readOnly: true,\n'
              ')',
          child: ItInput(
            label: 'Contenuto in sola lettura',
            controller: _readOnly,
            readOnly: true,
          ),
        ),

        ExampleSection(
          title: 'Readonly normalizzato',
          description:
              'La classe .form-control-plaintext della documentazione. '
              "Attenzione a cosa cambia davvero: nel foglio di stile compilato "
              "la regola che toglierebbe il bordo perde di specificità contro "
              "il selettore d'elemento, quindi anche sul kit di riferimento la "
              'riga inferiore rimane. Quello che sparisce è il min-height di '
              '2.5rem, e il campo si stringe sul proprio contenuto.',
          code: 'ItInput(\n'
              "  label: 'Contenuto in sola lettura',\n"
              '  controller: TextEditingController(text: \'Sola lettura\'),\n'
              '  plaintext: true,\n'
              ')',
          child: ItInput(
            label: 'Contenuto in sola lettura',
            controller: _plaintext,
            plaintext: true,
          ),
        ),

        // ── Input password ─────────────────────────────────────────────────
        const ExampleSection(
          title: 'Input password',
          description:
              'Il campo password ha un pulsante che mostra e nasconde i '
              'caratteri inseriti. Il pulsante è un controllo a sé: ha un nome '
              'accessibile che cambia con lo stato, si raggiunge con il tasto '
              'Tab e si attiva con Invio o barra spaziatrice. Con helperText '
              "si ottiene la variante «con descrizione estesa».",
          code: 'ItInput(\n'
              "  label: 'Password',\n"
              '  obscureText: true,\n'
              '  showPasswordToggle: true,\n'
              ')\n\n'
              'ItInput(\n'
              "  label: 'Password',\n"
              '  obscureText: true,\n'
              '  showPasswordToggle: true,\n'
              "  helperText: 'Inserisci almeno 8 caratteri e alcuni "
              "caratteri speciali.',\n"
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItInput(
                label: 'Password',
                obscureText: true,
                showPasswordToggle: true,
              ),
              SizedBox(height: 32),
              ItInput(
                label: 'Password',
                obscureText: true,
                showPasswordToggle: true,
                helperText:
                    'Inserisci almeno 8 caratteri e alcuni caratteri speciali.',
              ),
            ],
          ),
        ),

        // ── Ricerca con autocompletamento ──────────────────────────────────
        ExampleSection(
          title: 'Ricerca con autocompletamento',
          description:
              'La documentazione tratta questa variante nella pagina Input, '
              "ma il widget è ItAutocomplete. La lente sta fuori dal campo "
              "(.autocomplete-icon) ed è decorativa: il nome accessibile "
              "arriva dall'etichetta, che nel kit è nascosta con "
              '.visually-hidden e qui si ottiene con semanticLabel.',
          code: 'ItAutocomplete<String>(\n'
              "  semanticLabel: 'Cerca nel sito',\n"
              '  icon: BootstrapItaliaIcons.it_search,\n'
              '  onSearch: cercaRegioni,\n'
              '  displayStringForOption: (r) => r,\n'
              ')',
          child: ItAutocomplete<String>(
            semanticLabel: 'Cerca nel sito',
            hint: 'Cerca nel sito',
            icon: BootstrapItaliaIcons.it_search,
            onSearch: _cercaRegioni,
            displayStringForOption: (r) => r,
          ),
        ),

        ExampleSection(
          title: 'Ricerca con autocompletamento grande',
          description:
              'La versione ingrandita, indicata per intestazioni di pagina e '
              'overlay dedicati (.autocomplete-wrapper-big). Il parametro si '
              'chiama large e non big: ItChip e ItButton usano già la stessa '
              'parola per la stessa idea.',
          code: 'ItAutocomplete<String>(\n'
              "  semanticLabel: 'Cerca nel sito',\n"
              '  icon: BootstrapItaliaIcons.it_search,\n'
              '  large: true,\n'
              '  onSearch: cercaRegioni,\n'
              '  displayStringForOption: (r) => r,\n'
              ')',
          child: ItAutocomplete<String>(
            semanticLabel: 'Cerca nel sito',
            hint: 'Cerca nel sito',
            icon: BootstrapItaliaIcons.it_search,
            large: true,
            onSearch: _cercaRegioni,
            displayStringForOption: (r) => r,
          ),
        ),

        ExampleSection(
          title: 'Ricerca con autocompletamento e dati',
          description:
              'Nel kit i risultati arrivano da un JSON con i campi text, link, '
              'icon e label. Qui la sorgente è una funzione che restituisce '
              "oggetti tipizzati, e itemBuilder decide come disegnarli: "
              "un'icona, il testo e la label in corsivo, come nel markup di "
              'riferimento.',
          code: 'ItAutocomplete<Risultato>(\n'
              '  onSearch: cercaRisultati,\n'
              '  displayStringForOption: (r) => r.testo,\n'
              '  itemBuilder: (context, r, evidenziato) => Row(\n'
              '    children: [\n'
              '      Icon(r.icona),\n'
              '      Text(r.testo),\n'
              '      Text(r.etichetta),\n'
              '    ],\n'
              '  ),\n'
              ')',
          child: ItAutocomplete<_Risultato>(
            semanticLabel: 'Cerca nel sito',
            hint: 'Cerca nel sito',
            icon: BootstrapItaliaIcons.it_search,
            onSearch: _cercaRisultati,
            displayStringForOption: (r) => r.testo,
            itemBuilder: (context, r, evidenziato) => _RisultatoTile(
              risultato: r,
              evidenziato: evidenziato,
            ),
          ),
        ),

        // ── Area di testo ──────────────────────────────────────────────────
        const ExampleSection(
          title: 'Area di testo',
          description:
              'Con maxLines maggiore di 1 il campo diventa una textarea, e '
              'cambia la sua cornice: il kit disegna un bordo su tutti e '
              "quattro i lati (textarea.form-control) invece della sola riga "
              "inferiore, e l'altezza segue il contenuto anziché essere fissata "
              "a 2.5rem. L'etichetta si comporta esattamente come sui campi a "
              'riga singola.',
          code: 'ItInput(\n'
              "  label: 'Esempio di area di testo',\n"
              '  maxLines: 3,\n'
              ')',
          child: ItInput(label: 'Esempio di area di testo', maxLines: 3),
        ),

        // ── Dimensione ─────────────────────────────────────────────────────
        const ExampleSection(
          title: 'Dimensione',
          description:
              'Le classi .form-control-sm e .form-control-lg diventano il '
              'parametro size. Cambiano la grandezza del carattere e '
              "l'altezza minima ovunque; la spaziatura interna si muove solo "
              "sulle aree di testo, perché su un input a riga singola il "
              "selettore d'elemento del kit vince sulla classe di dimensione.",
          code: 'ItInput(\n'
              "  label: 'Area di testo piccola',\n"
              '  maxLines: 3,\n'
              '  size: ItInputSize.small,\n'
              ')\n\n'
              'ItInput(\n'
              "  label: 'Area di testo grande',\n"
              '  maxLines: 3,\n'
              '  size: ItInputSize.large,\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItInput(
                label: 'Area di testo piccola',
                maxLines: 3,
                size: ItInputSize.small,
              ),
              SizedBox(height: 32),
              ItInput(label: 'Area di testo normale', maxLines: 3),
              SizedBox(height: 32),
              ItInput(
                label: 'Area di testo grande',
                maxLines: 3,
                size: ItInputSize.large,
              ),
            ],
          ),
        ),

        // ── Validazione ────────────────────────────────────────────────────
        // Non è una sezione della pagina Input: la validazione dei campi è
        // descritta in docs/form/introduzione/, e vale per tutti i controlli.
        const ExampleSection(
          title: 'Stati di validazione',
          description: "Non è una sezione della pagina Input: la validazione è "
              'descritta in docs/form/introduzione/ e vale per tutti i '
              'controlli. Il colore del bordo segue il tema — è il token '
              'danger — mentre il rosso del messaggio è un valore a sé che il '
              'kit dichiara solo lì. Indicare errorText implica lo stato di '
              'errore: non serve dirlo due volte.',
          code: 'ItInput(\n'
              "  label: 'Campo valido',\n"
              '  validationState: ItValidationState.success,\n'
              ')\n\n'
              'ItInput(\n'
              "  label: 'Campo con errore',\n"
              "  errorText: 'Questo campo è obbligatorio',\n"
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItInput(
                label: 'Campo valido',
                validationState: ItValidationState.success,
              ),
              SizedBox(height: 32),
              ItInput(
                label: 'Campo con avviso',
                validationState: ItValidationState.warning,
              ),
              SizedBox(height: 32),
              ItInput(
                label: 'Campo con errore',
                required: true,
                errorText: 'Questo campo è obbligatorio',
              ),
            ],
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description: 'Attivazione tramite codice (per Input, InputPassword e '
              'InputSearch) — riguarda l’inizializzazione JavaScript del kit e '
              'i metodi getInstance / getOrCreateInstance / dispose, che in '
              'Flutter non hanno equivalente: il widget è attivo appena '
              'costruito e viene smontato dal framework.\n\n'
              'Password con misuratore sicurezza e suggerimenti — la '
              'documentazione stessa avverte, sotto il titolo «Importante '
              "sulla sicurezza per l'uso in produzione», che le due varianti "
              '«sono da considerarsi esempi da usare per studio e ricerca» e '
              'consiglia di riscrivere le funzioni di calcolo del punteggio '
              'prima di usarle davvero. Incorporare qui un algoritmo di '
              'valutazione della robustezza significherebbe fissarne uno per '
              "tutte le amministrazioni che usano il pacchetto, che è "
              'esattamente ciò che quel paragrafo sconsiglia. La variante «con '
              'descrizione estesa», che non calcola nulla, è riprodotta sopra '
              'con helperText.\n\n'
              'Breaking change — un registro delle modifiche alle classi HTML '
              'fra le versioni del kit (2.2.0, 2.8.0, 2.10.0, 2.11.0). '
              'Riguarda chi aggiorna il foglio di stile, non chi usa questi '
              'widget.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// One row of the docs' "autocompletamento e dati" example: text, a label and
/// an icon, which is the shape their JSON carries.
class _Risultato {
  const _Risultato(this.testo, this.etichetta, this.icona);

  final String testo;
  final String etichetta;
  final IconData icona;
}

/// `<li><a>…<span class="autocomplete-list-text"><span>text</span><em>label</em>`
class _RisultatoTile extends StatelessWidget {
  const _RisultatoTile({required this.risultato, required this.evidenziato});

  final _Risultato risultato;
  final bool evidenziato;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        evidenziato ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BootstrapItaliaSpacing.space3,
        vertical: BootstrapItaliaSpacing.space2,
      ),
      child: Row(
        children: [
          Icon(risultato.icona, size: 24, color: color),
          const SizedBox(width: BootstrapItaliaSpacing.space2),
          Expanded(
            child: Text(
              risultato.testo,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
          Text(
            risultato.etichetta,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
