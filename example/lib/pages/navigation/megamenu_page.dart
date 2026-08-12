import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors
/// https://italia.github.io/bootstrap-italia/docs/menu-di-navigazione/megamenu/
///
/// Two kinds of example, matching what each docs section is about. Where the
/// section is about the *bar* — which sections there are, which theme it
/// carries — the example is a live [ItMegamenu]: click a label to open it.
/// Where the section is about the panel's own layout, the example is an
/// [ItMegamenuPanel] on its own, already open, because that is how the docs
/// draw it and because a layout you have to click to see is not being shown.
class MegamenuPage extends StatelessWidget {
  const MegamenuPage({super.key});

  /// `.container-xxl` at the `xxl` breakpoint — see [HeaderPage] for why the
  /// bands are hosted at their own width rather than squeezed into a card.
  static const double _containerWidth = 1176;

  /// A host for the bar, which has a mobile layout of its own.
  static Widget _band(BuildContext context, Widget child) {
    if (!context.isDesktop) return child;
    return _fixedBand(child);
  }

  /// A host for the panel, which does not.
  ///
  /// [ItMegamenuPanel] is the desktop dropdown: three columns of links laid
  /// out side by side, with no narrow-window arrangement — below `lg` the
  /// component shows the full-screen overlay instead, which is a different
  /// widget. So the panel is always hosted at the container width and the
  /// strip scrolls sideways.
  static Widget _fixedBand(Widget child) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: _containerWidth, child: child),
      );

  static ItMegamenuColumn _column(int from, int to) => ItMegamenuColumn(
        links: [
          for (var i = from; i <= to; i++)
            ItMegamenuLink(label: 'Link lista $i', onTap: () {}),
        ],
      );

  /// The "Megamenu completo" section: description column, an
  /// "Esplora la sezione" heading link, and one list of links.
  static ItMegamenuSection _complete({
    required String label,
    required int from,
    bool active = false,
  }) =>
      ItMegamenuSection(
        label: label,
        active: active,
        description: 'Testo utile a fornire una descrizione dei contenuti '
            'della sezione $label.',
        headerCta: ItMegamenuCta(
          label: 'Esplora la sezione $label',
          onTap: () {},
        ),
        columns: [_column(from, from + 2), _column(from + 3, from + 5)],
      );

  /// The "Megamenu base" section: three columns of links, nothing else.
  static ItMegamenuSection _base({
    ItMegamenuCta? headerCta,
    ItMegamenuCta? footerCta,
    List<ItMegamenuCta> footerCtas = const [],
    List<ItMegamenuCta> sideCtas = const [],
    int columns = 3,
  }) =>
      ItMegamenuSection(
        label: 'Megamenu',
        active: true,
        headerCta: headerCta,
        footerCta: footerCta,
        footerCtas: footerCtas,
        sideCtas: sideCtas,
        columns: [
          for (var c = 0; c < columns; c++) _column(c * 3 + 1, c * 3 + 3),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Megamenu',
      children: [
        // ── Introduzione ───────────────────────────────────────────────────
        const ExampleSection(
          title: 'Introduzione',
          description:
              'Il megamenu è una variazione del dropdown per la barra di '
              'navigazione: permette di esplorare elenchi di link e '
              'informazioni correlate senza lasciare la pagina. Il tema '
              'predefinito è chiaro; i due temi scuri si attivano con '
              'lightDesk su desktop e darkMobile su mobile.\n\n'
              'Sopra il breakpoint lg il componente disegna una barra con un '
              'pannello che scende sotto la voce aperta; sotto, un pulsante '
              'burger che apre un pannello a tutto schermo — il modello a '
              'dialogo che il kit ha adottato dalla versione 2.15.0, con '
              'trappola del focus e chiusura con Esc.',
          child: SizedBox.shrink(),
        ),

        // ── Accessibilità ──────────────────────────────────────────────────
        const ExampleSection(
          title: 'Accessibilità',
          description:
              'La documentazione elenca cinque attenzioni. Quattro sono a '
              'carico del widget: i pulsanti di apertura hanno davvero il '
              'ruolo di pulsante e dichiarano lo stato aperto/chiuso; ogni '
              'link porta una freccia oltre al colore, così da restare '
              'distinguibile anche senza percepirlo; Esc chiude il pannello e '
              'riporta il focus sulla voce che lo ha aperto; e la tabulazione '
              'passa dalla voce al suo pannello, non a tutte le altre voci '
              "prima.\n\n"
              'La quinta resta a chi scrive i contenuti: due link «Esplora '
              'tutti» in menu diversi hanno lo stesso nome e sono '
              "indistinguibili nell'elenco dei link di uno screen reader. "
              'Per questo gli esempi qui sotto scrivono «Esplora la sezione '
              'megamenu 1» e non «Esplora la sezione».',
          child: SizedBox.shrink(),
        ),

        // ── Megamenu completo ──────────────────────────────────────────────
        ExampleSection(
          title: 'Megamenu completo',
          description:
              'La variante completa dà accesso a una intera sezione del sito: '
              'testo introduttivo nella colonna di sinistra, un link «Esplora '
              'la sezione» in cima e gli elenchi a fianco. Più megamenu '
              'possono affiancarsi nella barra; active segnala quello che '
              'corrisponde alla sezione corrente. Le voci si aprono con un '
              'clic.',
          code: 'ItMegamenu(\n'
              '  sections: [\n'
              '    ItMegamenuSection(\n'
              "      label: 'Megamenu 1',\n"
              '      active: true,\n'
              "      description: 'Testo utile a fornire una descrizione…',\n"
              '      headerCta: ItMegamenuCta(\n'
              "        label: 'Esplora la sezione megamenu 1',\n"
              '        onTap: () {},\n'
              '      ),\n'
              '      columns: [\n'
              '        ItMegamenuColumn(links: [...]),\n'
              '      ],\n'
              '    ),\n'
              '  ],\n'
              ')',
          child: _band(
            context,
            ItMegamenu(
              semanticsLabel: 'Megamenu completo',
              sections: [
                _complete(label: 'megamenu 1', from: 1, active: true),
                _complete(label: 'megamenu 2', from: 7),
              ],
            ),
          ),
        ),

        // ── Completo scuro desktop ─────────────────────────────────────────
        ExampleSection(
          title: 'Completo scuro desktop',
          description:
              'Con lightDesk la barra passa a fondo bianco con voci nel '
              'colore primario e il pannello fa il contrario: fondo primario '
              'con contenuti bianchi. Il nome della classe del kit è '
              'fuorviante — .theme-light-desk descrive la barra, non il menu — '
              'e un solo parametro imposta entrambe le metà, perché separarle '
              'permetterebbe combinazioni che il kit non ha.',
          code: 'ItMegamenu(\n'
              '  lightDesk: true,\n'
              '  sections: [...],\n'
              ')',
          child: _band(
            context,
            ItMegamenu(
              semanticsLabel: 'Megamenu, tema scuro su desktop',
              lightDesk: true,
              sections: [_complete(label: 'megamenu', from: 1, active: true)],
            ),
          ),
        ),

        // ── Completo scuro mobile ──────────────────────────────────────────
        ExampleSection(
          title: 'Completo scuro mobile',
          description:
              'Con darkMobile il pannello a tutto schermo passa a fondo '
              'primario, con il pulsante di chiusura, i titoli di sezione e il '
              'filo della sezione attiva in bianco. Il corpo che si apre sotto '
              'ogni titolo resta invece sul suo azzurrino: la regola '
              '.it-vertical non ha una variante scura nel foglio di stile, e i '
              'link al suo interno restano quindi leggibili in blu. Per '
              'vederlo, restringere la finestra sotto i 992 pixel e premere il '
              'burger.',
          code: 'ItMegamenu(\n'
              '  darkMobile: true,\n'
              '  sections: [...],\n'
              ')',
          child: _band(
            context,
            ItMegamenu(
              semanticsLabel: 'Megamenu, tema scuro su mobile',
              darkMobile: true,
              sections: [_complete(label: 'megamenu', from: 1, active: true)],
            ),
          ),
        ),

        // ── Megamenu base ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Megamenu base',
          description:
              'La variante base contiene solo elenchi di link, organizzati in '
              'colonne. È il pannello mostrato aperto, come nella '
              'documentazione.',
          code: 'ItMegamenuPanel(\n'
              '  section: ItMegamenuSection(\n'
              "    label: 'Megamenu',\n"
              '    columns: [\n'
              '      ItMegamenuColumn(links: [...]),\n'
              '      ItMegamenuColumn(links: [...]),\n'
              '      ItMegamenuColumn(links: [...]),\n'
              '    ],\n'
              '  ),\n'
              ')',
          child: _fixedBand(ItMegamenuPanel(section: _base())),
        ),

        // ── Con link "Esplora la sezione" ──────────────────────────────────
        ExampleSection(
          title: 'Con link «Esplora la sezione»',
          description:
              'headerCta aggiunge in cima al pannello un link alla copertina '
              'della sezione, separato dagli elenchi da un filo. Nel kit è '
              'la .it-heading-link-wrapper.',
          code: 'ItMegamenuSection(\n'
              "  label: 'Megamenu',\n"
              '  headerCta: ItMegamenuCta(\n'
              "    label: 'Esplora la sezione megamenu',\n"
              '    onTap: () {},\n'
              '  ),\n'
              '  columns: [...],\n'
              ')',
          child: _fixedBand(
            ItMegamenuPanel(
              section: _base(
                headerCta: ItMegamenuCta(
                  label: 'Esplora la sezione megamenu',
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),

        // ── Con link "Esplora tutti" ───────────────────────────────────────
        ExampleSection(
          title: 'Con link «Esplora tutti»',
          description:
              'footerCta chiude il pannello con un link a una lista completa, '
              'allineato a destra sopra il proprio filo. Serve quando le voci '
              'sono troppe per stare tutte nel menu.',
          code: 'ItMegamenuSection(\n'
              "  label: 'Megamenu',\n"
              '  footerCta: ItMegamenuCta(\n'
              "    label: 'Esplora tutti i contenuti del megamenu',\n"
              '    onTap: () {},\n'
              '  ),\n'
              '  columns: [...],\n'
              ')',
          child: _fixedBand(
            ItMegamenuPanel(
              section: _base(
                columns: 4,
                footerCta: ItMegamenuCta(
                  label: 'Esplora tutti i contenuti del megamenu',
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),

        // ── Con call to action in basso ────────────────────────────────────
        ExampleSection(
          title: 'Con call to action in basso',
          description:
              'footerCtas dispone più link correlati in una riga sotto le '
              'colonne, sopra il filo che li separa dagli elenchi. Sono pari '
              'fra loro, a differenza del footerCta singolo che è allineato a '
              'destra; se non entrano su una riga vanno a capo.',
          code: 'ItMegamenuSection(\n'
              "  label: 'Megamenu',\n"
              '  footerCtas: [\n'
              "    ItMegamenuCta(label: 'Call to action 1', onTap: () {}),\n"
              "    ItMegamenuCta(label: 'Call to action 2', onTap: () {}),\n"
              '  ],\n'
              '  columns: [...],\n'
              ')',
          child: _fixedBand(
            ItMegamenuPanel(
              section: _base(
                footerCtas: [
                  ItMegamenuCta(label: 'Call to action 1', onTap: () {}),
                  ItMegamenuCta(label: 'Call to action 2', onTap: () {}),
                ],
              ),
            ),
          ),
        ),

        // ── Con call to action a destra ────────────────────────────────────
        ExampleSection(
          title: 'Con call to action a destra',
          description:
              'sideCtas impila gli stessi link in una colonna a destra degli '
              'elenchi, con il filo sul fianco invece che sopra. È la '
              '.it-footer-link-wrapper-vertical del kit, che dichiara per il '
              'proprio bordo un grigio di una sfumatura diverso da quello di '
              'tutti gli altri fili del pannello: qui è riprodotto così '
              "com'è, invece di essere silenziosamente uniformato.",
          code: 'ItMegamenuSection(\n'
              "  label: 'Megamenu',\n"
              '  sideCtas: [\n'
              "    ItMegamenuCta(label: 'Call to action 1', onTap: () {}),\n"
              "    ItMegamenuCta(label: 'Call to action 2', onTap: () {}),\n"
              '  ],\n'
              '  columns: [...],\n'
              ')',
          child: _fixedBand(
            ItMegamenuPanel(
              section: _base(
                columns: 2,
                sideCtas: [
                  ItMegamenuCta(label: 'Call to action 1', onTap: () {}),
                  ItMegamenuCta(label: 'Call to action 2', onTap: () {}),
                ],
              ),
            ),
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Attivazione tramite codice — la pagina del kit rimanda alla '
              'sezione corrispondente del dropdown, cioè al suo plugin '
              'JavaScript. Qui il megamenu è attivo appena costruito.\n\n'
              'Breaking change dalle versioni 2.15.0 e 2.8.0 — è la cronologia '
              'del kit. La 2.15.0 però ha deciso qualcosa che questo widget '
              'applica: la navigazione mobile è un dialogo con sfondo, '
              'trappola del focus e gestione di inert, ed è esattamente come è '
              'costruito il pannello a tutto schermo.\n\n'
              "Una precisazione sulla variante «completo»: l'immagine "
              "introduttiva prevista dal kit è supportata (ItMegamenuSection.image), "
              'ma qui gli esempi ne fanno a meno per non incorporare un file '
              "binario nell'app di esempio.",
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
