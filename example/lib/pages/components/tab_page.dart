import 'dart:math' as math;

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/tab/
///
/// The docs page runs to some two dozen headings, most of which are the same
/// four icon treatments repeated under each layout. They are grouped here by
/// *capability* — one section per thing the widget can do, showing the variants
/// inside it — rather than transcribed one heading at a time. Nothing the docs
/// demonstrate is dropped; what is not reproduced is listed at the bottom.
class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  /// One selected index per example, keyed by the example's name.
  ///
  /// Fifteen separate `int` fields would say nothing that the key does not.
  final Map<String, int> _index = {};

  int _at(String key) => _index[key] ?? 0;
  ValueChanged<int> _set(String key) => (i) => setState(() => _index[key] = i);

  /// The docs' own editable-card example starts with four tabs and lets you
  /// add and remove them, so this one has to be real state rather than a list
  /// literal.
  List<String> _cards = ['Tab 1', 'Tab 2', 'Tab 3'];
  int _nextCard = 4;

  static const _textual = [
    ItTabItem(label: 'Attivo'),
    ItTabItem(label: 'Link'),
    ItTabItem(label: 'Link'),
    ItTabItem(label: 'Disattivo', disabled: true),
  ];

  static const _iconTabs = [
    ItTabItem(label: 'Tab titolo 1', icon: BootstrapItaliaIcons.it_link),
    ItTabItem(label: 'Tab titolo 2', icon: BootstrapItaliaIcons.it_calendar),
    ItTabItem(label: 'Tab titolo 3', icon: BootstrapItaliaIcons.it_comment),
    ItTabItem(
      label: 'Tab titolo 4',
      icon: BootstrapItaliaIcons.it_close,
      disabled: true,
    ),
  ];

  static const _iconTextTabs = [
    ItTabItem(label: 'Tab 1', icon: BootstrapItaliaIcons.it_link),
    ItTabItem(label: 'Tab 2', icon: BootstrapItaliaIcons.it_calendar),
    ItTabItem(label: 'Tab 3', icon: BootstrapItaliaIcons.it_comment),
    ItTabItem(
      label: 'Tab 4',
      icon: BootstrapItaliaIcons.it_close,
      disabled: true,
    ),
  ];

  static const _verticalTabs = [
    ItTabItem(label: 'Tab 1'),
    ItTabItem(label: 'Tab 2'),
    ItTabItem(label: 'Tab 3'),
  ];

  static const _verticalIconTabs = [
    ItTabItem(label: 'Tab 1', icon: BootstrapItaliaIcons.it_link),
    ItTabItem(label: 'Tab 2', icon: BootstrapItaliaIcons.it_calendar),
    ItTabItem(label: 'Tab 3', icon: BootstrapItaliaIcons.it_comment),
  ];

  /// `.tab-pane.p-4` — the panes in the docs are padded, not flush.
  Widget _pane(String text) => Padding(
        padding: const EdgeInsets.all(BootstrapItaliaSpacing.space3),
        child: Text(text),
      );

  List<Widget> _panes(int count) =>
      [for (var i = 1; i <= count; i++) _pane('Contenuto $i')];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Tab',
      children: [
        // ── Tab orizzontali a tutta larghezza ──────────────────────────────
        ExampleSection(
          title: 'Tab orizzontali a tutta larghezza',
          description:
              'Con fullWidth ogni tab occupa una frazione uguale della '
              'larghezza disponibile, indipendentemente dalla lunghezza '
              "dell'etichetta. È la classe .auto della documentazione. Un tab "
              'disabilitato resta visibile ma non è selezionabile né '
              'raggiungibile da tastiera.',
          code: 'ItTabBar(\n'
              '  fullWidth: true,\n'
              '  tabs: [\n'
              "    ItTabItem(label: 'Attivo'),\n"
              "    ItTabItem(label: 'Disattivo', disabled: true),\n"
              '  ],\n'
              '  selectedIndex: _index,\n'
              '  onChanged: (i) => setState(() => _index = i),\n'
              ')',
          child: ItTabBar(
            fullWidth: true,
            tabs: _textual,
            selectedIndex: _at('auto'),
            onChanged: _set('auto'),
          ),
        ),

        // ── Tab con icona ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Tab con icona',
          description:
              "Con layout iconOnly l'etichetta non viene disegnata ma resta "
              'obbligatoria: diventa il nome accessibile del tab, esattamente '
              'come lo span .visually-hidden della documentazione. Un tab che '
              "mostra solo un'icona senza nome è annunciato come un pulsante "
              'senza etichetta, quindi label non è un parametro facoltativo.',
          code: 'ItTabBar(\n'
              '  layout: ItTabLayout.iconOnly,\n'
              '  fullWidth: true,\n'
              '  tabs: [\n'
              '    ItTabItem(\n'
              "      label: 'Tab titolo 1', // non disegnata: è il nome accessibile\n"
              '      icon: BootstrapItaliaIcons.it_link,\n'
              '    ),\n'
              '  ],\n'
              ')',
          child: ItTabBar(
            layout: ItTabLayout.iconOnly,
            fullWidth: true,
            tabs: _iconTabs,
            selectedIndex: _at('icon'),
            onChanged: _set('icon'),
          ),
        ),

        // ── Tab con icona grande ───────────────────────────────────────────
        ExampleSection(
          title: 'Tab con icona grande',
          description:
              "iconOnlyLarge porta l'icona da 32 a 48 pixel e allarga il "
              'padding orizzontale del tab da 1.333em a 1.778em, perché senza '
              'quello spazio le icone grandi si toccherebbero.',
          code: 'ItTabBar(\n'
              '  layout: ItTabLayout.iconOnlyLarge,\n'
              '  fullWidth: true,\n'
              '  tabs: [...],\n'
              ')',
          child: ItTabBar(
            layout: ItTabLayout.iconOnlyLarge,
            fullWidth: true,
            tabs: _iconTabs,
            selectedIndex: _at('iconLg'),
            onChanged: _set('iconLg'),
          ),
        ),

        // ── Tab con testo e icona ──────────────────────────────────────────
        ExampleSection(
          title: 'Tab con testo e icona',
          description: "iconAndText disegna l'icona, mezzo rem di spazio e poi "
              "l'etichetta. Lo spazio arriva dalla classe .nav-tabs-icon-text: "
              'il layout standard accosta icona ed etichetta senza margine, ed '
              'è ciò che il kit rende in assenza di quella classe.',
          code: 'ItTabBar(\n'
              '  layout: ItTabLayout.iconAndText,\n'
              '  fullWidth: true,\n'
              '  tabs: [\n'
              "    ItTabItem(label: 'Tab 1', icon: BootstrapItaliaIcons.it_link),\n"
              '  ],\n'
              ')',
          child: ItTabBar(
            layout: ItTabLayout.iconAndText,
            fullWidth: true,
            tabs: _iconTextTabs,
            selectedIndex: _at('iconText'),
            onChanged: _set('iconText'),
          ),
        ),

        // ── Tab orizzontali ────────────────────────────────────────────────
        ExampleSection(
          title: 'Tab orizzontali',
          description:
              'Senza fullWidth ogni tab è largo quanto il suo contenuto e la '
              'barra si allinea a sinistra. È il comportamento predefinito, e '
              'vale per tutti e quattro i layout visti sopra.',
          code: 'ItTabBar(\n'
              '  tabs: [...],\n'
              '  selectedIndex: _index,\n'
              '  onChanged: (i) => setState(() => _index = i),\n'
              ')',
          child: ItTabBar(
            tabs: _textual,
            selectedIndex: _at('horizontal'),
            onChanged: _set('horizontal'),
          ),
        ),

        // ── Rimozione delle scrollbar su dispositivi touch ─────────────────
        ExampleSection(
          title: 'Rimozione delle scrollbar su dispositivi touch',
          description:
              'Quando i tab non entrano nella larghezza disponibile la barra '
              'scorre orizzontalmente, come la regola overflow-x: auto del '
              'kit. Non serve alcun contenitore aggiuntivo: le classi '
              '.nav-tabs-hidescroll servono a nascondere la scrollbar del '
              'browser, e Flutter non ne disegna una su un contenitore '
              'scorrevole al tocco. Provate a trascinare la barra qui sotto.',
          code: '// Nessun parametro: la barra scorre da sola quando serve.\n'
              'ItTabBar(\n'
              '  tabs: [ /* sette voci */ ],\n'
              ')',
          child: ItTabBar(
            layout: ItTabLayout.iconAndText,
            tabs: const [
              ItTabItem(label: 'Anagrafe', icon: BootstrapItaliaIcons.it_user),
              ItTabItem(label: 'Tributi', icon: BootstrapItaliaIcons.it_card),
              ItTabItem(
                  label: 'Edilizia', icon: BootstrapItaliaIcons.it_settings),
              ItTabItem(
                  label: 'Ambiente', icon: BootstrapItaliaIcons.it_calendar),
              ItTabItem(
                  label: 'Cultura', icon: BootstrapItaliaIcons.it_comment),
              ItTabItem(
                  label: 'Sport', icon: BootstrapItaliaIcons.it_star_full),
              ItTabItem(label: 'Trasporti', icon: BootstrapItaliaIcons.it_link),
            ],
            selectedIndex: _at('scroll'),
            onChanged: _set('scroll'),
          ),
        ),

        // ── Controllo dei pannelli associati ───────────────────────────────
        ExampleSection(
          title: 'Controllo dei pannelli associati',
          description:
              'ItTabView mostra il pannello del tab selezionato. Il legame fra '
              "i due si dichiara con panelId e identifier: è l'equivalente di "
              'aria-controls, e la documentazione spiega perché conta — i '
              'lettori di schermo lo usano per offrire una scorciatoia che '
              'porta direttamente al contenuto del tab.',
          code: 'Column(\n'
              '  children: [\n'
              '    ItTabBar(\n'
              "      panelId: 'pannello-servizi',\n"
              '      tabs: [...],\n'
              '      selectedIndex: _index,\n'
              '      onChanged: (i) => setState(() => _index = i),\n'
              '    ),\n'
              '    ItTabView(\n'
              "      identifier: 'pannello-servizi',\n"
              '      selectedIndex: _index,\n'
              '      children: [...],\n'
              '    ),\n'
              '  ],\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItTabBar(
                panelId: 'pannello-servizi',
                tabs: _textual,
                selectedIndex: _at('panels'),
                onChanged: _set('panels'),
              ),
              ItTabView(
                identifier: 'pannello-servizi',
                selectedIndex: _at('panels'),
                children: _panes(4),
              ),
            ],
          ),
        ),

        // ── Tab verticali ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Tab verticali',
          description:
              'Con placement start i tab si impilano in colonna a sinistra del '
              'pannello, la riga di separazione passa sul lato destro e '
              "l'indicatore del tab attivo diventa spesso 2 pixel invece di 3. "
              'Su una barra verticale le frecce che spostano la selezione sono '
              'Su e Giù, non Sinistra e Destra.',
          code: 'Row(\n'
              '  children: [\n'
              '    SizedBox(\n'
              '      width: 240,\n'
              '      child: ItTabBar(\n'
              '        placement: ItTabPlacement.start,\n'
              '        tabs: [...],\n'
              '      ),\n'
              '    ),\n'
              '    Expanded(child: ItTabView(selectedIndex: _index, ...)),\n'
              '  ],\n'
              ')',
          child: _VerticalExample(
            bar: ItTabBar(
              placement: ItTabPlacement.start,
              tabs: _verticalTabs,
              selectedIndex: _at('vertical'),
              onChanged: _set('vertical'),
            ),
            view: ItTabView(
              selectedIndex: _at('vertical'),
              children: _panes(3),
            ),
          ),
        ),

        // ── Tab testuale con colore di sfondo ──────────────────────────────
        ExampleSection(
          title: 'Tab testuale con colore di sfondo',
          description:
              'verticalBackground riempie il tab attivo di hsl(210, 62%, 97%), '
              'una tinta quasi bianca. Non segue il tema: nel kit è dichiarata '
              'fra le tinte di grigio chiaro e non fra i colori semantici, '
              "quindi un'amministrazione che ricolora primary vede cambiare "
              "l'indicatore ma non questa fascia.",
          code: 'ItTabBar(\n'
              '  placement: ItTabPlacement.start,\n'
              '  verticalBackground: true,\n'
              '  tabs: [...],\n'
              ')',
          child: _VerticalExample(
            bar: ItTabBar(
              placement: ItTabPlacement.start,
              verticalBackground: true,
              tabs: _verticalTabs,
              selectedIndex: _at('verticalBg'),
              onChanged: _set('verticalBg'),
            ),
            view: ItTabView(
              selectedIndex: _at('verticalBg'),
              children: _panes(3),
            ),
          ),
        ),

        // ── Tab verticali con icona ────────────────────────────────────────
        ExampleSection(
          title: 'Tab verticali con testo e icona, e con sola icona',
          description:
              "Su una barra verticale a sinistra l'etichetta sta sul bordo "
              "interno e l'icona su quello esterno: è la regola "
              'justify-content: space-between del kit. Con layout iconOnly '
              "restano le sole icone, allineate al bordo destro, e l'etichetta "
              'continua a fare da nome accessibile.',
          code: '// testo e icona\n'
              'ItTabBar(\n'
              '  placement: ItTabPlacement.start,\n'
              '  tabs: [ItTabItem(label: ..., icon: ...)],\n'
              ')\n\n'
              '// sola icona\n'
              'ItTabBar(\n'
              '  placement: ItTabPlacement.start,\n'
              '  layout: ItTabLayout.iconOnly,\n'
              '  tabs: [...],\n'
              ')',
          // WCAG 1.4.4. These two columns were a flat `width: 220` and
          // `width: 100`. A vertical tab puts its label against the inner edge
          // and its icon against the outer one, so the pair needs more room as
          // the text grows — and at iOS's `accessibility-large` (194%, which is
          // INSIDE the 200% the criterion requires) the first column overflowed
          // by 25px.
          //
          // Scaling the widths alone is NOT the fix, and was tried: 220 at 194%
          // is 427pt on a 393pt screen, so the row then overflowed by 326px —
          // a worse failure than the one being repaired. The width has to be
          // both scaled AND bounded by what is actually available, and the two
          // columns have to be allowed to stack when they no longer fit side
          // by side. That is the general shape of the fix wherever a caller
          // pins a width around text it does not control.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scaler = MediaQuery.textScalerOf(context);
              double fit(double base) =>
                  math.min(scaler.scale(base), constraints.maxWidth);
              return Wrap(
                spacing: BootstrapItaliaSpacing.space3,
                runSpacing: BootstrapItaliaSpacing.space3,
                children: [
                  SizedBox(
                    width: fit(220),
                    child: ItTabBar(
                      placement: ItTabPlacement.start,
                      tabs: _verticalIconTabs,
                      selectedIndex: _at('verticalIconText'),
                      onChanged: _set('verticalIconText'),
                    ),
                  ),
                  SizedBox(
                    width: fit(100),
                    child: ItTabBar(
                      placement: ItTabPlacement.start,
                      layout: ItTabLayout.iconOnly,
                      tabs: _verticalIconTabs,
                      selectedIndex: _at('verticalIconOnly'),
                      onChanged: _set('verticalIconOnly'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // ── Posizione dei Tab: orizzontale in fondo ────────────────────────
        ExampleSection(
          title: 'Orizzontale in fondo',
          description:
              'placement bottom porta la barra sotto il pannello: la riga di '
              "separazione passa in alto e l'indicatore del tab attivo con "
              "essa. L'ordine di lettura e di tabulazione non cambia — la "
              'barra resta prima del pannello, come nel kit, dove lo '
              'spostamento è ottenuto con flex-column-reverse e non '
              "riordinando il markup.",
          code: 'Column(\n'
              '  children: [\n'
              '    ItTabView(selectedIndex: _index, children: [...]),\n'
              '    ItTabBar(\n'
              '      placement: ItTabPlacement.bottom,\n'
              '      tabs: [...],\n'
              '    ),\n'
              '  ],\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItTabView(
                selectedIndex: _at('bottom'),
                children: _panes(4),
              ),
              ItTabBar(
                placement: ItTabPlacement.bottom,
                tabs: _textual,
                selectedIndex: _at('bottom'),
                onChanged: _set('bottom'),
              ),
            ],
          ),
        ),

        // ── Posizione dei Tab: verticale a destra ──────────────────────────
        ExampleSection(
          title: 'Verticale a destra',
          description:
              'placement end mette la colonna di tab a destra del pannello. '
              "Rispetto alla variante a sinistra l'icona passa davanti "
              "all'etichetta, con .889rem di spazio, e la riga di separazione "
              'si sposta sul lato sinistro.',
          code: 'Row(\n'
              '  children: [\n'
              '    Expanded(child: ItTabView(...)),\n'
              '    SizedBox(\n'
              '      width: 240,\n'
              '      child: ItTabBar(\n'
              '        placement: ItTabPlacement.end,\n'
              '        tabs: [...],\n'
              '      ),\n'
              '    ),\n'
              '  ],\n'
              ')',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ItTabView(
                  selectedIndex: _at('right'),
                  children: _panes(3),
                ),
              ),
              SizedBox(
                width: 240,
                child: ItTabBar(
                  placement: ItTabPlacement.end,
                  tabs: _verticalIconTabs,
                  selectedIndex: _at('right'),
                  onChanged: _set('right'),
                ),
              ),
            ],
          ),
        ),

        // ── Tab con sfondo scuro ───────────────────────────────────────────
        ExampleSection(
          title: 'Tab con sfondo scuro',
          description:
              'dark sostituisce tutta la scala di colori: fascia scura, '
              'etichette chiare, indicatore ciano. Non è una variante '
              'ricolorata ma un blocco a sé, e non segue il tema: nessuna delle '
              'quattro tinte è un colore semantico dello schema. Ricolorare '
              "l'etichetta seguendo un primary personalizzato lasciando ferma "
              'la fascia sarebbe il modo più rapido per perdere il contrasto.',
          code: 'ItTabBar(\n'
              '  dark: true,\n'
              '  fullWidth: true,\n'
              '  tabs: [...],\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItTabBar(
                dark: true,
                fullWidth: true,
                tabs: _textual,
                selectedIndex: _at('dark'),
                onChanged: _set('dark'),
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space3),
              ItTabBar(
                dark: true,
                layout: ItTabLayout.iconAndText,
                tabs: _iconTextTabs,
                selectedIndex: _at('darkIcon'),
                onChanged: _set('darkIcon'),
              ),
            ],
          ),
        ),

        // ── Tab con sfondo scuro, verticali ────────────────────────────────
        ExampleSection(
          title: 'Tab verticali con sfondo scuro',
          description: 'Le due varianti si combinano: la colonna scura porta '
              "l'indicatore ciano sul bordo destro.",
          code: 'ItTabBar(\n'
              '  dark: true,\n'
              '  placement: ItTabPlacement.start,\n'
              '  tabs: [...],\n'
              ')',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 240,
                child: ItTabBar(
                  dark: true,
                  placement: ItTabPlacement.start,
                  tabs: _verticalIconTabs,
                  selectedIndex: _at('darkVertical'),
                  onChanged: _set('darkVertical'),
                ),
              ),
              Expanded(
                child: ItTabView(
                  selectedIndex: _at('darkVertical'),
                  children: _panes(3),
                ),
              ),
            ],
          ),
        ),

        // ── Tab tipo Card ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Tab tipo Card',
          description:
              'Con ItTabStyle.card il tab attivo prende la forma di una scheda '
              'con gli angoli superiori arrotondati e il bordo inferiore '
              'aperto verso il pannello, mentre gli altri restano appoggiati '
              'alla riga di separazione.',
          code: 'ItTabBar(\n'
              '  style: ItTabStyle.card,\n'
              '  tabs: [...],\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItTabBar(
                style: ItTabStyle.card,
                tabs: _textual,
                selectedIndex: _at('cards'),
                onChanged: _set('cards'),
              ),
              ItTabView(
                selectedIndex: _at('cards'),
                children: _panes(4),
              ),
            ],
          ),
        ),

        // ── Tab tipo Card con pulsanti aggiungi/elimina ────────────────────
        ExampleSection(
          title: 'Tab tipo Card con pulsanti aggiungi/elimina',
          description:
              'onClose su un tab aggiunge il pulsante di chiusura; onAddTab '
              'sulla barra aggiunge il pulsante «più» in coda. Entrambi '
              'richiedono un nome accessibile, e quello di chiusura va '
              'intitolato alla scheda che chiude: cinque pulsanti chiamati '
              'tutti «Chiudi» sono indistinguibili nella lista degli elementi '
              'di un lettore di schermo.',
          code: 'ItTabBar(\n'
              '  style: ItTabStyle.card,\n'
              '  tabs: [\n'
              '    for (final nome in _schede)\n'
              '      ItTabItem(\n'
              '        label: nome,\n'
              '        onClose: () => setState(() => _schede.remove(nome)),\n'
              "        closeLabel: 'Chiudi la scheda \$nome',\n"
              '      ),\n'
              '  ],\n'
              '  onAddTab: () => setState(() => _schede.add(...)),\n'
              "  addTabLabel: 'Aggiungi una scheda',\n"
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItTabBar(
                style: ItTabStyle.card,
                tabs: [
                  for (final name in _cards)
                    ItTabItem(
                      label: name,
                      onClose: _cards.length > 1 ? () => _close(name) : null,
                      closeLabel:
                          _cards.length > 1 ? 'Chiudi la scheda $name' : null,
                    ),
                ],
                selectedIndex: _at('editable').clamp(0, _cards.length - 1),
                onChanged: _set('editable'),
                onAddTab: _add,
                addTabLabel: 'Aggiungi una scheda',
              ),
              ItTabView(
                selectedIndex: _at('editable').clamp(0, _cards.length - 1),
                children: [
                  for (final name in _cards) _pane('Contenuto di $name'),
                ],
              ),
            ],
          ),
        ),

        // ── Effetto «a comparsa» ───────────────────────────────────────────
        ExampleSection(
          title: 'Effetto «a comparsa»',
          description:
              'ItTabView incrocia in dissolvenza il pannello uscente e quello '
              'entrante, come la classe .fade del kit. Si disattiva con '
              'animated: false, che è la scelta giusta quando il pannello '
              'contiene un campo con il focus.',
          code: 'ItTabView(\n'
              '  selectedIndex: _index,\n'
              '  animated: true, // predefinito\n'
              '  duration: Duration(milliseconds: 200),\n'
              '  children: [...],\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItTabBar(
                tabs: _verticalTabs,
                selectedIndex: _at('fade'),
                onChanged: _set('fade'),
              ),
              ItTabView(
                selectedIndex: _at('fade'),
                duration: const Duration(milliseconds: 400),
                children: _panes(3),
              ),
            ],
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Attivazione tramite codice — riguarda l’inizializzazione '
              'JavaScript del kit (data-bs-toggle, il costruttore Tab, i suoi '
              'eventi), che in Flutter non esiste: il widget è attivo appena '
              'costruito e lo stato vive nel chiamante. La parte utile di '
              'quella sezione è però la navigazione da tastiera, e quella è '
              'implementata: con il focus su un tab le frecce spostano la '
              'selezione lungo l’asse della barra — Sinistra e Destra se è '
              'orizzontale, Su e Giù se è verticale — ciclando agli estremi e '
              'saltando i tab disabilitati; Home e Fine vanno al primo e '
              'all’ultimo. Il tasto Tab entra nella barra una volta sola e ne '
              'esce: dentro si naviga con le frecce.\n\n'
              'Breaking change dalla versione 2.13.0 — è una nota di rilascio '
              'sulla rimozione della classe nav-item-filler dal markup dei tab '
              'tipo Card. Riguarda chi aggiorna il kit HTML, non questa API.\n\n'
              'Le classi .nav-tabs-hidescroll — servono a nascondere la '
              'scrollbar del browser su una barra che scorre. Flutter non ne '
              'disegna una su un contenitore scorrevole al tocco, quindi il '
              'contenitore aggiuntivo non ha nulla da fare: la sezione '
              '«Rimozione delle scrollbar» qui sopra mostra lo scorrimento '
              'senza di esse.\n\n'
              'Hover — un effetto legato al passaggio del mouse, che non ha '
              'equivalente sui dispositivi tattili e non è un parametro del '
              'componente. È comunque implementato: un tab inattivo scurisce '
              'verso rgb(0, 76.5, 153), mentre quello attivo non reagisce.\n\n'
              'A schermi molto larghi (da 1200px) il kit sostituisce lo '
              'scorrimento con flex-wrap: wrap, mandando i tab a capo su una '
              'seconda riga. Non è riprodotto: quale larghezza debba governare '
              'il cambio — quella della finestra o quella della barra — è una '
              'decisione di progettazione ancora aperta in questo port, e lo '
              'scorrimento è corretto a tutte le larghezze intermedie.\n\n'
              'Infine, una raccomandazione della documentazione che non è una '
              'sezione ma vale qui: le interfacce a tab non devono contenere '
              'menu a discesa. Il trigger del tab visualizzato finirebbe '
              'dentro un menu chiuso, e quindi invisibile.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  void _close(String name) {
    setState(() {
      final removed = _cards.indexOf(name);
      _cards = List.of(_cards)..remove(name);
      // Keep the selection on a tab that still exists, and prefer the one that
      // took the closed tab's place over silently jumping to the first.
      final current = _at('editable');
      if (current >= _cards.length || current == removed) {
        _index['editable'] = (removed - 1).clamp(0, _cards.length - 1);
      } else if (current > removed) {
        _index['editable'] = current - 1;
      }
    });
  }

  void _add() {
    setState(() {
      _cards = List.of(_cards)..add('Tab $_nextCard');
      _nextCard++;
      _index['editable'] = _cards.length - 1;
    });
  }
}

/// A vertical bar beside the pane it drives, as the docs lay it out in a grid.
class _VerticalExample extends StatelessWidget {
  const _VerticalExample({required this.bar, required this.view});

  final Widget bar;
  final Widget view;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 240, child: bar),
        Expanded(child: view),
      ],
    );
  }
}
