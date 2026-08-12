import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/organizzare-i-contenuti/liste/
///
/// That page documents **two** families under one title, and they share nothing
/// but a `.list-item` class name: `.it-list`, rows of content with a leading
/// avatar or thumbnail, a paragraph, metadata and per-row actions; and
/// `.link-list`, the menu rows that Dropdown, Megamenu, Sidebar and Navscroll
/// are built out of. Here they are `ItContentList` and `ItList`, in the docs'
/// order — the content family first, the navigation family under *Liste per
/// menu di navigazione*.
class ListPage extends StatefulWidget {
  /// Creates the list catalogue page.
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  static const _lorem = 'Lorem ipsum dolor sit amet.';
  static const _abstract =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
      'eiusmod tempor incididunt ut labore.';

  bool _toggle1 = false;
  bool _checkbox1 = true;
  bool _checkbox2 = false;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Liste',
      children: [
        // ══ Tipologie di lista ═══════════════════════════════════════════
        // ── Lista semplice solo testo ────────────────────────────────────
        ExampleSection(
          title: 'Lista semplice solo testo',
          description:
              'Le liste di contenuto — .it-list nel foglio di stile — possono '
              'contenere testi, link, icone, avatar, immagini o una '
              'combinazione di questi elementi. Una riga senza onTap è testo '
              'statico; una riga con onTap diventa un link, in blu e '
              'sottolineato, e viene annunciata come un unico controllo.',
          code: 'ItContentList(\n'
              '  items: [\n'
              "    ItContentListItem(text: 'Testo'),\n"
              "    ItContentListItem(text: 'Link', onTap: () {}),\n"
              '  ],\n'
              ')',
          child: ItContentList(
            items: [
              const ItContentListItem(text: 'Testo'),
              ItContentListItem(text: 'Link', onTap: () {}),
              const ItContentListItem(text: 'Testo'),
            ],
          ),
        ),

        // ── Lista con icona ──────────────────────────────────────────────
        ExampleSection(
          title: 'Lista con icona',
          description:
              "L'elemento .it-rounded-icon precede la zona di destra che "
              'contiene il testo. ItRoundedIcon è una casella di 40 pixel con '
              'una glifo di 32: nonostante il nome, la versione 2.18.0 del '
              'foglio di stile non dichiara nessun cerchio attorno '
              "all'icona.",
          code: 'ItContentListItem(\n'
              '  leading: ItRoundedIcon(icon: BootstrapItaliaIcons.it_folder),\n'
              "  text: 'Testo',\n"
              ')',
          child: ItContentList(
            items: [
              const ItContentListItem(
                leading: ItRoundedIcon(icon: BootstrapItaliaIcons.it_folder),
                text: 'Testo',
              ),
              ItContentListItem(
                leading:
                    const ItRoundedIcon(icon: BootstrapItaliaIcons.it_folder),
                text: 'Link',
                onTap: () {},
              ),
            ],
          ),
        ),

        // ── Lista con immagine ───────────────────────────────────────────
        ExampleSection(
          title: 'Lista con immagine',
          description:
              "L'elemento .it-thumb ritaglia l'immagine in un quadrato di 40 "
              'pixel con object-fit: cover. ItListThumb non inventa un testo '
              "alternativo: la descrizione appartiene all'immagine che gli si "
              'passa, quindi va indicata lì con semanticLabel, oppure va detto '
              "esplicitamente che l'immagine è decorativa.",
          code: 'ItContentListItem(\n'
              '  leading: ItListThumb(\n'
              "    child: Image.asset('foto.png', semanticLabel: 'Ritratto'),\n"
              '  ),\n'
              "  text: 'Testo',\n"
              ')',
          child: ItContentList(
            items: [
              const ItContentListItem(
                leading: ItListThumb(child: _Placeholder()),
                text: 'Testo',
              ),
              ItContentListItem(
                leading: const ItListThumb(child: _Placeholder()),
                text: 'Link',
                onTap: () {},
              ),
            ],
          ),
        ),

        // ══ Lista con azioni ═════════════════════════════════════════════
        // ── Con freccia ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Con freccia',
          description:
              "Un'icona segue il testo per indicare che la riga porta "
              'altrove. È decorativa: la riga è già un link e annunciare anche '
              'la freccia darebbe due nomi a un solo controllo. Per una icona '
              'che sia essa stessa un comando si usa invece actions.',
          code: 'ItContentListItem(\n'
              "  text: 'Link',\n"
              '  trailing: Icon(BootstrapItaliaIcons.it_chevron_right),\n'
              '  onTap: () {},\n'
              ')',
          child: ItContentList(
            items: [
              ItContentListItem(
                text: 'Link',
                trailing: const Icon(BootstrapItaliaIcons.it_chevron_right),
                onTap: () {},
              ),
              ItContentListItem(
                text: 'Link',
                trailing: const Icon(BootstrapItaliaIcons.it_chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),

        // ── Con azioni multiple ──────────────────────────────────────────
        ExampleSection(
          title: 'Con azioni multiple',
          description:
              "L'elemento .it-multiple raccoglie più comandi in fondo alla "
              'riga. Ogni azione ha una label obbligatoria, e la '
              'documentazione stessa la scrive nominando la riga — «Testo - '
              'Azione 1», non «Azione 1»: una pagina di otto righe con tre '
              'comandi ciascuna produrrebbe altrimenti ventiquattro pulsanti '
              'con nomi ripetuti a gruppi di tre. Quando ci sono azioni, il '
              'link è il solo testo e non tutta la riga, esattamente come nel '
              'markup della documentazione.',
          code: 'ItContentListItem(\n'
              "  text: 'Testo',\n"
              '  onTap: () {},\n'
              '  actions: [\n'
              '    ItListAction(\n'
              '      icon: BootstrapItaliaIcons.it_code_circle,\n'
              "      label: 'Testo - Azione 1',\n"
              '      onPressed: () {},\n'
              '    ),\n'
              '  ],\n'
              ')',
          child: ItContentList(
            items: [
              ItContentListItem(
                text: 'Testo',
                actions: _actions('Testo'),
              ),
              ItContentListItem(
                text: 'Link',
                onTap: () {},
                actions: _actions('Link'),
              ),
            ],
          ),
        ),

        // ══ Altre variazioni ═════════════════════════════════════════════
        // ── Con metadata ─────────────────────────────────────────────────
        ExampleSection(
          title: 'Con metadata',
          description:
              'Un campo testuale breve segue il testo principale, in grigio e '
              'in corpo minore. Il grigio è hsl(210,17%,44%), lo stesso valore '
              'che il foglio di stile dichiara anche come --bs-secondary: qui '
              'però è il grigio neutro, non il colore di accento, quindi non '
              'segue un tema che ridefinisca secondary.',
          code: 'ItContentListItem(\n'
              "  text: 'Testo',\n"
              "  metadata: 'metadata testo',\n"
              ')',
          child: ItContentList(
            items: [
              const ItContentListItem(
                leading: ItRoundedIcon(icon: BootstrapItaliaIcons.it_user),
                text: 'Testo',
                metadata: 'metadata testo',
              ),
              ItContentListItem(
                leading: const ItRoundedIcon(icon: BootstrapItaliaIcons.it_user),
                text: 'Link',
                metadata: 'metadata testo',
                onTap: () {},
              ),
            ],
          ),
        ),

        // ── Con testo aggiuntivo, azioni multiple e metadata ─────────────
        ExampleSection(
          title: 'Con testo aggiuntivo, azioni multiple e metadata',
          description:
              'Per un paragrafo di testo aggiuntivo la documentazione chiede '
              'un titolo e un <p> dentro un unico contenitore, per il corretto '
              'allineamento: qui sono text e description. Con le azioni '
              'presenti, il metadata scende dentro .it-multiple e occupa una '
              'riga intera, spingendo le icone sotto di sé — è il '
              'flex-wrap del foglio di stile, non una scelta di questo '
              'pacchetto.',
          code: 'ItContentListItem(\n'
              "  text: 'Testo',\n"
              "  description: 'Lorem ipsum dolor sit amet.',\n"
              "  metadata: 'metadata testo',\n"
              '  actions: [...],\n'
              ')',
          child: ItContentList(
            items: [
              ItContentListItem(
                text: 'Testo',
                description: _lorem,
                metadata: 'metadata testo',
                actions: _actions('Testo'),
              ),
              ItContentListItem(
                text: 'Link',
                description: _lorem,
                metadata: 'metadata link',
                onTap: () {},
                actions: _actions('Link'),
              ),
            ],
          ),
        ),

        // ══ Liste per menu di navigazione ════════════════════════════════
        // ── Linea singola ────────────────────────────────────────────────
        ExampleSection(
          title: 'Linea singola',
          description:
              'Le liste per menu di navigazione — .link-list — sono le voci '
              'con cui si costruiscono Dropdown, Megamenu, Sidebar e '
              'Navscroll. Nella forma base non hanno divisori: showDividers va '
              'messo a false, perché il valore predefinito di ItList traccia '
              'una riga fra tutte le voci.',
          code: 'ItList(\n'
              '  showDividers: false,\n'
              '  items: [\n'
              "    ItListItem(title: 'Link lista 1', onTap: () {}),\n"
              '  ],\n'
              ')',
          child: ItList(
            showDividers: false,
            items: [
              ItListItem(title: 'Link lista 1', onTap: () {}),
              ItListItem(title: 'Link lista 2', onTap: () {}),
              ItListItem(title: 'Link lista 3', onTap: () {}),
            ],
          ),
        ),

        // ── Elemento con stato attivo ────────────────────────────────────
        ExampleSection(
          title: 'Elemento con stato attivo',
          description:
              'La voce attiva è più scura del blu di collegamento — il foglio '
              'di stile dichiara rgb(0, 38.25, 76.5), cioè 0,375 volte '
              'primary, quindi il colore segue il tema. Lo stato non è solo '
              'cromatico: la riga viene annunciata come selezionata, altrimenti '
              "chi non vede il colore non ha modo di sapere dov'è.",
          code: "ItListItem(title: 'Link lista 2 attivo', active: true, "
              'onTap: () {})',
          child: ItList(
            showDividers: false,
            items: [
              ItListItem(title: 'Link lista 1', onTap: () {}),
              ItListItem(
                title: 'Link lista 2 attivo',
                active: true,
                onTap: () {},
              ),
              ItListItem(title: 'Link lista 3', onTap: () {}),
            ],
          ),
        ),

        // ── Elemento con stato disabilitato ──────────────────────────────
        ExampleSection(
          title: 'Elemento con stato disabilitato',
          description:
              'La voce disabilitata resta nella lista e nella struttura '
              'annunciata, ma non è attivabile e non riceve il focus da '
              'tastiera. Anche qui lo stato viene esposto: inerte non è la '
              'stessa cosa di assente.',
          code: "ItListItem(title: 'Link lista 2 disabilitato', "
              'disabled: true, onTap: () {})',
          child: ItList(
            showDividers: false,
            items: [
              ItListItem(title: 'Link lista 1', onTap: () {}),
              ItListItem(
                title: 'Link lista 2 disabilitato',
                disabled: true,
                onTap: () {},
              ),
              ItListItem(title: 'Link lista 3', onTap: () {}),
            ],
          ),
        ),

        // ── Intestazione e divisore ──────────────────────────────────────
        ExampleSection(
          title: 'Intestazione e divisore',
          description:
              "Una lista può avere un'intestazione, con o senza link, e "
              'divisori per separare gruppi di voci. Le due forme '
              "dell'intestazione non differiscono solo per il colore: senza "
              'link è 1.125rem sul colore del testo, con link scende a 1rem e '
              "prende il colore di collegamento. In entrambi i casi l'elemento "
              "è un'intestazione anche per uno screen reader, perché nel kit è "
              'un <h4>.',
          code: 'ItList(\n'
              "  heading: 'Intestazione senza link',\n"
              '  showDividers: false,\n'
              '  items: [\n'
              "    ItListItem(title: 'Link lista 1', onTap: () {}),\n"
              '    ItListDivider(),\n'
              "    ItListItem(title: 'Link lista 2', onTap: () {}),\n"
              '  ],\n'
              ')\n\n'
              '// con link\n'
              'ItList(\n'
              "  heading: 'Intestazione con link',\n"
              '  onHeadingTap: () {},\n'
              '  ...\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItList(
                heading: 'Intestazione senza link',
                showDividers: false,
                items: [
                  ItListItem(title: 'Link lista 1', onTap: () {}),
                  ItListItem(title: 'Link lista 2', onTap: () {}),
                  const ItListDivider(),
                  ItListItem(title: 'Link lista 3', onTap: () {}),
                ],
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space4),
              ItList(
                heading: 'Intestazione con link',
                onHeadingTap: () {},
                showDividers: false,
                items: [
                  ItListItem(title: 'Link lista 1', onTap: () {}),
                  ItListItem(title: 'Link lista 2', onTap: () {}),
                  const ItListDivider(),
                  ItListItem(title: 'Link lista 3', onTap: () {}),
                ],
              ),
            ],
          ),
        ),

        // ── Dimensioni ───────────────────────────────────────────────────
        ExampleSection(
          title: 'Dimensioni',
          description:
              'La classe .large porta la voce a 1.125rem e, dal breakpoint sm '
              'in su, ne aumenta anche la spaziatura verticale. Esiste inoltre '
              '.medium, che nonostante il nome non è una dimensione intermedia '
              'ma il peso semigrassetto: nel kit le due si combinano, e '
              'infatti le liste annidate più sotto usano large e medium '
              'insieme.',
          code: "ItListItem(title: 'Link lista 1', large: true, onTap: () {})\n"
              "ItListItem(title: 'Link lista 2', large: true, medium: true, "
              'onTap: () {})',
          child: ItList(
            heading: 'Intestazione',
            showDividers: false,
            items: [
              ItListItem(title: 'Link lista 1', large: true, onTap: () {}),
              ItListItem(title: 'Link lista 2', large: true, onTap: () {}),
              const ItListDivider(),
              ItListItem(
                title: 'Link lista 3 semigrassetto',
                large: true,
                medium: true,
                onTap: () {},
              ),
            ],
          ),
        ),

        // ── Multiline con icona ──────────────────────────────────────────
        ExampleSection(
          title: 'Multiline con icona',
          description:
              "Ogni voce può avere un'icona e un abstract. Il testo di "
              'descrizione fa parte dello stesso link del titolo: i due '
              'vengono uniti in un solo nome, altrimenti uno screen reader '
              'attraverserebbe titolo e paragrafo come due fermate distinte, '
              "nessuna delle quali dice che c'è qualcosa da attivare.",
          code: 'ItListItem(\n'
              "  title: 'Link lista 1 attivo',\n"
              "  subtitle: 'Lorem ipsum…',\n"
              '  trailing: Icon(BootstrapItaliaIcons.it_code_circle, '
              'size: 32),\n'
              '  active: true,\n'
              '  onTap: () {},\n'
              ')',
          child: ItList(
            items: [
              ItListItem(
                title: 'Link lista 1 attivo',
                subtitle: _abstract,
                trailing: const Icon(
                  BootstrapItaliaIcons.it_code_circle,
                  size: 32,
                ),
                active: true,
                onTap: () {},
              ),
              ItListItem(
                title: 'Link lista 2',
                subtitle: _abstract,
                trailing: const Icon(
                  BootstrapItaliaIcons.it_code_circle,
                  size: 32,
                ),
                onTap: () {},
              ),
              ItListItem(
                title: 'Link lista 3 disabilitato',
                subtitle: _abstract,
                trailing: const Icon(
                  BootstrapItaliaIcons.it_code_circle,
                  size: 32,
                ),
                disabled: true,
                onTap: () {},
              ),
            ],
          ),
        ),

        // ── Lista con controlli ──────────────────────────────────────────
        ExampleSection(
          title: 'Lista con controlli',
          description:
              "L'icona a destra è descrittiva, quella a sinistra può essere "
              "un'azione aggiuntiva. Qui sono i parametri trailing e leading: "
              'una voce che ne porta almeno una perde il proprio margine '
              'orizzontale, così che la glifo si allinei al bordo della lista. '
              "Il margine fra l'icona di sinistra e il testo è 8 pixel, non i "
              '24 del margine di riga — un dettaglio che era sbagliato finché '
              "nessun esempio ha usato l'icona a sinistra.",
          code: '// azione primaria: icona a sinistra\n'
              'ItListItem(\n'
              "  title: 'Link lista 1 attivo',\n"
              '  leading: Icon(BootstrapItaliaIcons.it_chevron_right, '
              'size: 32),\n'
              '  active: true,\n'
              '  onTap: () {},\n'
              ')\n\n'
              '// azione secondaria: icona a destra\n'
              'ItListItem(\n'
              "  title: 'Link lista 2',\n"
              '  trailing: Icon(BootstrapItaliaIcons.it_link, size: 32),\n'
              '  onTap: () {},\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Caption('Azione primaria — icona a sinistra'),
              ItList(
                showDividers: false,
                items: [
                  ItListItem(
                    title: 'Link lista 1 attivo',
                    leading: const Icon(
                      BootstrapItaliaIcons.it_chevron_right,
                      size: 32,
                    ),
                    active: true,
                    onTap: () {},
                  ),
                  ItListItem(
                    title: 'Link lista 2',
                    leading: const Icon(
                      BootstrapItaliaIcons.it_chevron_right,
                      size: 32,
                    ),
                    onTap: () {},
                  ),
                  ItListItem(
                    title: 'Link lista 3 disabilitato',
                    leading: const Icon(
                      BootstrapItaliaIcons.it_chevron_right,
                      size: 32,
                    ),
                    disabled: true,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space4),
              const _Caption('Azione secondaria — icona a destra'),
              ItList(
                showDividers: false,
                items: [
                  ItListItem(
                    title: 'Link lista 1 attivo',
                    trailing:
                        const Icon(BootstrapItaliaIcons.it_link, size: 32),
                    active: true,
                    onTap: () {},
                  ),
                  ItListItem(
                    title: 'Link lista 2',
                    trailing:
                        const Icon(BootstrapItaliaIcons.it_link, size: 32),
                    onTap: () {},
                  ),
                  ItListItem(
                    title: 'Link lista 3 disabilitato',
                    trailing:
                        const Icon(BootstrapItaliaIcons.it_link, size: 32),
                    disabled: true,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space4),
              const _Caption('Azioni primaria e secondaria'),
              ItList(
                showDividers: false,
                items: [
                  ItListItem(
                    title: 'Link lista 1 attivo',
                    leading:
                        const Icon(BootstrapItaliaIcons.it_link, size: 32),
                    active: true,
                    onTap: () {},
                  ),
                  ItListItem(
                    title: 'Link lista 2',
                    leading:
                        const Icon(BootstrapItaliaIcons.it_link, size: 32),
                    onTap: () {},
                  ),
                  ItListItem(
                    title: 'Link lista 3 disabilitato con icona a destra',
                    trailing:
                        const Icon(BootstrapItaliaIcons.it_link, size: 32),
                    disabled: true,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Lista con toggle ─────────────────────────────────────────────
        ExampleSection(
          title: 'Lista con toggle',
          description:
              'Una riga può ospitare un controllo di form invece di un link. '
              'ItListCustom gli dà il margine orizzontale della lista e nulla '
              'altro: il controllo conserva il proprio ruolo, perché un '
              'interruttore annunciato come link direbbe la cosa sbagliata su '
              'che cosa succede attivandolo.',
          code: 'ItList(\n'
              '  showDividers: false,\n'
              '  items: [\n'
              '    ItListCustom(\n'
              '      child: ItToggle(\n'
              '        value: value,\n'
              "        label: 'Label per toggle',\n"
              '        onChanged: (v) => setState(() => value = v),\n'
              '      ),\n'
              '    ),\n'
              '  ],\n'
              ')',
          child: ItList(
            showDividers: false,
            items: [
              ItListCustom(
                child: ItToggle(
                  value: _toggle1,
                  label: 'Label per toggle',
                  onChanged: (v) => setState(() => _toggle1 = v),
                ),
              ),
              const ItListCustom(
                child: ItToggle(
                  value: false,
                  label: 'Label per toggle disabilitato',
                  enabled: false,
                ),
              ),
            ],
          ),
        ),

        // ── Lista con checkbox ───────────────────────────────────────────
        ExampleSection(
          title: 'Lista con checkbox',
          description:
              'Lo stesso contenitore accoglie una casella di spunta. Il '
              'margine di 24 pixel è dichiarato una sola volta nel foglio di '
              'stile e vale per entrambi i controlli, quindi ItListCustom lo '
              'applica senza sapere che cosa contiene.',
          code: 'ItListCustom(\n'
              '  child: ItCheckbox(\n'
              '    value: value,\n'
              "    label: 'Checkbox selezionato',\n"
              '    onChanged: (v) => setState(() => value = v),\n'
              '  ),\n'
              ')',
          child: ItList(
            showDividers: false,
            items: [
              ItListCustom(
                child: ItCheckbox(
                  value: _checkbox1,
                  label: 'Checkbox selezionato',
                  onChanged: (v) => setState(() => _checkbox1 = v),
                ),
              ),
              ItListCustom(
                child: ItCheckbox(
                  value: _checkbox2,
                  label: 'Checkbox non selezionato',
                  onChanged: (v) => setState(() => _checkbox2 = v),
                ),
              ),
              const ItListCustom(
                child: ItCheckbox(
                  value: false,
                  label: 'Checkbox disabilitato non selezionato',
                  enabled: false,
                ),
              ),
            ],
          ),
        ),

        // ── Liste annidate ───────────────────────────────────────────────
        ExampleSection(
          title: 'Liste annidate',
          description:
              'Una voce può contenere una sottolista, espansa o collassabile. '
              'Le due forme non sono la stessa cosa con un interruttore in '
              'più: nella forma espansa la voce resta un link e porta '
              'altrove, in quella collassabile diventa un pulsante che apre e '
              'chiude il gruppo — è quello che dice anche il markup del kit, '
              'con role="button" e aria-expanded. Le voci chiuse escono '
              "dall'albero invece di restare nascoste, così non capita di "
              'raggiungerle con il focus senza vederle.',
          code: '// espansa\n'
              'ItListItem(\n'
              "  title: 'Link lista 2',\n"
              '  large: true,\n'
              '  medium: true,\n'
              '  onTap: () {},\n'
              "  children: [ItListItem(title: 'Link lista 1', onTap: () {})],\n"
              ')\n\n'
              '// collassabile\n'
              'ItListItem(\n'
              "  title: 'Link lista 1',\n"
              '  large: true,\n'
              '  medium: true,\n'
              '  collapsible: true,\n'
              '  trailing: Icon(BootstrapItaliaIcons.it_expand, size: 32),\n'
              "  children: [ItListItem(title: 'Link lista 1', onTap: () {})],\n"
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Caption('Espansa'),
              ItList(
                showDividers: false,
                items: [
                  ItListItem(
                    title: 'Link lista 1',
                    large: true,
                    medium: true,
                    trailing:
                        const Icon(BootstrapItaliaIcons.it_link, size: 32),
                    onTap: () {},
                  ),
                  ItListItem(
                    title: 'Link lista 2',
                    large: true,
                    medium: true,
                    trailing:
                        const Icon(BootstrapItaliaIcons.it_link, size: 32),
                    onTap: () {},
                    children: [
                      ItListItem(title: 'Link lista 1', onTap: () {}),
                      ItListItem(title: 'Link lista 2', onTap: () {}),
                      ItListItem(title: 'Link lista 3', onTap: () {}),
                    ],
                  ),
                  ItListItem(
                    title: 'Link lista 3',
                    large: true,
                    medium: true,
                    trailing:
                        const Icon(BootstrapItaliaIcons.it_link, size: 32),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space4),
              const _Caption('Collassabile'),
              ItList(
                showDividers: false,
                items: [
                  for (var group = 1; group <= 3; group++)
                    ItListItem(
                      title: 'Link lista $group',
                      large: true,
                      medium: true,
                      collapsible: true,
                      trailing: const Icon(
                        BootstrapItaliaIcons.it_expand,
                        size: 32,
                      ),
                      children: [
                        ItListItem(title: 'Link lista 1', onTap: () {}),
                        ItListItem(title: 'Link lista 2', onTap: () {}),
                        ItListItem(title: 'Link lista 3', onTap: () {}),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),

        // ── What is deliberately absent ──────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Lista con avatar — .avatar è un componente a sé, che questo '
              'pacchetto non implementa: non è una sezione saltata ma una '
              "funzionalità assente, come il carosello. Lo spazio c'è già — "
              'leading accetta qualsiasi widget di 40 pixel e lo distanzia dal '
              'testo dei 16 richiesti dal foglio di stile — quindi un avatar '
              'preso altrove si inserisce senza modifiche.\n\n'
              'Breaking change (dalle versioni 2.8.0, 2.10.0 e 2.11.0) — sono '
              'note di migrazione del markup HTML fra versioni del kit: '
              "riguardano l'aggiunta di role=\"button\" ai collapse e la "
              'gerarchia dei titoli. Qui non esiste markup da migrare, e i '
              'ruoli che quelle note chiedono di aggiungere sono già quelli '
              'che i widget dichiarano.\n\n'
              'Nota su una differenza reale: nel kit il titolo di una voce con '
              "icona (.list-item-title) è 1.125rem, mentre qui resta a 1rem se "
              'non si passa large. È una divergenza nota e non corretta in '
              'questo passaggio, perché cambierebbe le catture di parità '
              'visiva esistenti; large permette intanto di ottenere la stessa '
              'dimensione.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  /// The docs' three `.it-multiple` actions, each named after its row.
  List<ItListAction> _actions(String row) => [
        for (var n = 1; n <= 3; n++)
          ItListAction(
            icon: BootstrapItaliaIcons.it_code_circle,
            label: '$row - Azione $n',
            onPressed: () {},
          ),
      ];
}

/// Stands in for the docs' 40x40 placeholder image.
///
/// Deliberately wider than the box it goes in, so the `object-fit: cover` crop
/// ItListThumb performs is visible rather than assumed.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 96,
      height: 40,
      child: ColoredBox(color: Color(0xFFB0BEC5)),
    );
  }
}

/// A small caption above one of a section's several examples.
///
/// The docs give these their own h4/h5 headings; here they group examples that
/// belong to one capability without inflating the page into a heading per
/// example.
class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BootstrapItaliaSpacing.space2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
