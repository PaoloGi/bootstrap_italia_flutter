import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/dropdown/
///
/// The docs draw every "Dropdown menu" example as a panel already open, with no
/// button above it, because the panel is what those sections are about. The
/// same split is available here: [ItDropdownMenu] is the panel on its own and
/// [ItDropdown] is the panel plus the trigger that opens it, so the sections
/// below use whichever the docs use.
class DropdownPage extends StatelessWidget {
  const DropdownPage({super.key});

  static List<ItDropdownEntry> _actions({
    bool large = false,
    bool rightIcon = false,
    IconData? icon,
  }) =>
      [
        for (var i = 1; i <= 3; i++)
          ItDropdownItem(
            label: 'Azione $i',
            icon: icon,
            large: large,
            rightIcon: rightIcon,
            onTap: () {},
          ),
      ];

  /// The panels below are shown open and out of an overlay, so each needs the
  /// room the floating version would have taken.
  static Widget _panel(Widget child) => Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(width: 260, child: child),
      );

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Dropdown',
      children: [
        // ── Accessibilità ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Accessibilità',
          description:
              'Il kit avverte che i suoi dropdown non applicano da sé gli '
              "attributi ARIA, e che l'integrazione spetta a chi li usa. Qui "
              'invece il widget se ne occupa: il pulsante dichiara il ruolo di '
              "pulsante e lo stato aperto/chiuso — l'equivalente di "
              'aria-expanded — e ogni voce del menu porta il proprio ruolo, il '
              'proprio nome e, se attiva, lo stato «selected». Le frecce su e '
              'giù scorrono le voci, Esc chiude il menu e Tab lo abbandona; in '
              'tutti e tre i casi il focus torna al pulsante che lo ha aperto.',
          code: 'ItDropdown(\n'
              "  trigger: ItButton(child: Text('Apri dropdown')),\n"
              '  items: [...],\n'
              ')\n'
              '// Nessun attributo ARIA da aggiungere: ruolo, nome, stato\n'
              '// e tastiera sono già a carico del widget.',
          child: ItDropdown(
            trigger:
                ItButton(onPressed: () {}, child: const Text('Apri dropdown')),
            items: _actions(),
          ),
        ),

        // ── Dropdown button ────────────────────────────────────────────────
        ExampleSection(
          title: 'Dropdown button',
          description:
              'Qualunque widget può fare da apritore: si passa a trigger. '
              'Le voci del menu si descrivono con ItDropdownItem, che è la '
              'controparte degli elementi di una .link-list.',
          code: 'ItDropdown(\n'
              '  trigger: ItButton(\n'
              '    onPressed: () {},\n'
              "    child: const Text('Apri dropdown'),\n"
              '  ),\n'
              '  items: [\n'
              "    ItDropdownItem(label: 'Azione 1', onTap: () {}),\n"
              "    ItDropdownItem(label: 'Azione 2', onTap: () {}),\n"
              "    ItDropdownItem(label: 'Azione 3', onTap: () {}),\n"
              '  ],\n'
              ')',
          child: ItDropdown(
            trigger:
                ItButton(onPressed: () {}, child: const Text('Apri dropdown')),
            items: _actions(),
          ),
        ),

        // ── Dropdown button varianti ───────────────────────────────────────
        ExampleSection(
          title: 'Dropdown button varianti',
          description:
              'Sono disponibili tutte le varianti dei pulsanti, perché il '
              'trigger è un widget qualsiasi e non una proprietà del dropdown: '
              'basta costruire il pulsante che serve e passarlo.',
          code: 'for (final variant in [\n'
              '  ItButtonVariant.primary,\n'
              '  ItButtonVariant.secondary,\n'
              '  ItButtonVariant.danger,\n'
              '])\n'
              '  ItDropdown(\n'
              '    trigger: ItButton(\n'
              '      variant: variant,\n'
              '      onPressed: () {},\n'
              "      child: const Text('Apri dropdown'),\n"
              '    ),\n'
              '    items: [...],\n'
              '  )',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space3,
            runSpacing: BootstrapItaliaSpacing.space3,
            children: [
              for (final variant in [
                ItButtonVariant.primary,
                ItButtonVariant.secondary,
                ItButtonVariant.danger,
              ])
                ItDropdown(
                  trigger: ItButton(
                    variant: variant,
                    onPressed: () {},
                    child: const Text('Apri dropdown'),
                  ),
                  items: _actions(),
                ),
            ],
          ),
        ),

        // ── Dropdown link ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Dropdown link',
          description:
              'Nella documentazione lo stesso menu si apre anche da un tag '
              "<a>. Qui la distinzione fra <a> e <button> non è un tag ma un "
              'ruolo semantico, ed è già deciso: il trigger dichiara sempre il '
              'ruolo di pulsante, perché apre un menu nella stessa pagina e '
              "non porta altrove. È la stessa raccomandazione che chiude la "
              'sezione Accessibilità del kit, applicata di default.',
          code:
              '// Un trigger dall\'aspetto testuale, con il ruolo di pulsante:\n'
              'ItDropdown(\n'
              '  trigger: ItButton(\n'
              '    variant: ItButtonVariant.primary,\n'
              '    outline: true,\n'
              '    onPressed: () {},\n'
              "    child: const Text('Apri dropdown'),\n"
              '  ),\n'
              '  items: [...],\n'
              ')',
          child: ItDropdown(
            trigger: ItButton(
              variant: ItButtonVariant.primary,
              outline: true,
              onPressed: () {},
              child: const Text('Apri dropdown'),
            ),
            items: _actions(),
          ),
        ),

        // ── Dropup / Dropend / Dropstart ───────────────────────────────────
        ExampleSection(
          title: 'Dropup, Dropend, Dropstart',
          description:
              'Il menu può aprirsi verso l\'alto, a destra o a sinistra del '
              'pulsante. Le quattro classi .dropup, .dropend, .dropstart e il '
              'comportamento predefinito corrispondono ai quattro valori di '
              'ItDropdownDirection: up, right, left e down.',
          code: 'ItDropdown(\n'
              '  direction: ItDropdownDirection.up, // .dropup\n'
              '  trigger: ItButton(\n'
              '    onPressed: () {},\n'
              "    child: const Text('Apri dropup'),\n"
              '  ),\n'
              '  items: [...],\n'
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space3,
            runSpacing: BootstrapItaliaSpacing.space3,
            children: [
              for (final (direction, label) in const [
                (ItDropdownDirection.up, 'Apri dropup'),
                (ItDropdownDirection.right, 'Apri dropend'),
                (ItDropdownDirection.left, 'Apri dropstart'),
              ])
                ItDropdown(
                  direction: direction,
                  trigger: ItButton(onPressed: () {}, child: Text(label)),
                  items: _actions(),
                ),
            ],
          ),
        ),

        // ── Menu voci attive ───────────────────────────────────────────────
        ExampleSection(
          title: 'Menu voci attive',
          description:
              'La voce corrente si segnala con active. La documentazione '
              'suggerisce di aggiungere al testo un «attivo» nascosto per gli '
              'screen reader: qui non serve, perché la voce dichiara lo stato '
              'di selezione al posto di ripeterlo nel nome — e solo la voce '
              'attiva lo fa, per non far annunciare «non selezionato» su tutte '
              'le altre.',
          code: 'ItDropdownMenu(\n'
              '  items: [\n'
              "    ItDropdownItem(label: 'Azione 1', active: true, onTap: () {}),\n"
              "    ItDropdownItem(label: 'Azione 2', onTap: () {}),\n"
              "    ItDropdownItem(label: 'Azione 3', onTap: () {}),\n"
              '  ],\n'
              ')',
          child: _panel(
            ItDropdownMenu(
              items: [
                ItDropdownItem(label: 'Azione 1', active: true, onTap: () {}),
                ItDropdownItem(label: 'Azione 2', onTap: () {}),
                ItDropdownItem(label: 'Azione 3', onTap: () {}),
              ],
            ),
          ),
        ),

        // ── Menu voci disabilitate ─────────────────────────────────────────
        ExampleSection(
          title: 'Menu voci disabilitate',
          description:
              'Una voce disabilitata resta raggiungibile con le frecce e viene '
              'annunciata come disabilitata: toglierla dal giro del focus la '
              'renderebbe invisibile a chi usa uno screen reader, che è '
              "l'opposto di ciò che l'attributo aria-disabled della "
              'documentazione chiede.',
          code: 'ItDropdownMenu(\n'
              '  items: [\n'
              "    ItDropdownItem(label: 'Azione 1', onTap: () {}),\n"
              "    ItDropdownItem(label: 'Azione 2', disabled: true),\n"
              "    ItDropdownItem(label: 'Azione 3', onTap: () {}),\n"
              '  ],\n'
              ')',
          child: _panel(
            ItDropdownMenu(
              items: [
                ItDropdownItem(label: 'Azione 1', onTap: () {}),
                const ItDropdownItem(label: 'Azione 2', disabled: true),
                ItDropdownItem(label: 'Azione 3', onTap: () {}),
              ],
            ),
          ),
        ),

        // ── Menu con voci grandi ───────────────────────────────────────────
        ExampleSection(
          title: 'Menu con voci grandi',
          description:
              'Con large le voci passano da 16 a 18 pixel e la riga guadagna '
              'quattro pixel di respiro sopra e sotto. È il modificatore '
              '.large del kit, che agisce sulla singola voce e non sul menu, '
              'quindi si può applicare anche solo ad alcune.',
          code: 'ItDropdownMenu(\n'
              '  items: [\n'
              "    ItDropdownItem(label: 'Azione 1', large: true, onTap: () {}),\n"
              '  ],\n'
              ')',
          child: _panel(ItDropdownMenu(items: _actions(large: true))),
        ),

        // ── Menu a tutta larghezza ─────────────────────────────────────────
        ExampleSection(
          title: 'Menu a tutta larghezza',
          description:
              'Con fullWidth il pannello prende la larghezza del pulsante che '
              'lo apre e le voci si dispongono in orizzontale, andando a capo '
              'quando lo spazio finisce. Il parametro width viene ignorato: '
              'la regola .full-width fissa la larghezza al contenitore del '
              'dropdown, che qui è il trigger stesso.',
          code: 'ItDropdown(\n'
              '  fullWidth: true,\n'
              '  trigger: SizedBox(\n'
              '    width: double.infinity,\n'
              '    child: ItButton(\n'
              '      onPressed: () {},\n'
              "      child: const Text('Apri dropdown'),\n"
              '    ),\n'
              '  ),\n'
              '  items: [...],\n'
              ')',
          child: ItDropdown(
            fullWidth: true,
            trigger: SizedBox(
              width: double.infinity,
              child: ItButton(
                onPressed: () {},
                child: const Text('Apri dropdown'),
              ),
            ),
            items: [
              for (var i = 1; i <= 5; i++)
                ItDropdownItem(label: 'Azione $i', onTap: () {}),
            ],
          ),
        ),

        // ── Menu con icona a destra ────────────────────────────────────────
        ExampleSection(
          title: 'Menu con icona a destra',
          description:
              'Con rightIcon l\'icona passa dopo l\'etichetta e viene spinta '
              'al bordo della riga, come fa la regola .right-icon con il suo '
              'justify-content: space-between.',
          code: 'ItDropdownItem(\n'
              "  label: 'Azione 1',\n"
              '  icon: BootstrapItaliaIcons.it_star_outline,\n'
              '  rightIcon: true,\n'
              '  onTap: () {},\n'
              ')',
          child: _panel(
            ItDropdownMenu(
              items: _actions(
                rightIcon: true,
                icon: BootstrapItaliaIcons.it_star_outline,
              ),
            ),
          ),
        ),

        // ── Menu con icona a sinistra ──────────────────────────────────────
        ExampleSection(
          title: 'Menu con icona a sinistra',
          description:
              "È la disposizione predefinita: l'icona precede l'etichetta e le "
              'sta accanto, senza spazio intermedio.',
          code: 'ItDropdownItem(\n'
              "  label: 'Azione 1',\n"
              '  icon: BootstrapItaliaIcons.it_star_outline,\n'
              '  onTap: () {},\n'
              ')',
          child: _panel(
            ItDropdownMenu(
              items: _actions(icon: BootstrapItaliaIcons.it_star_outline),
            ),
          ),
        ),

        // ── Menu dark ──────────────────────────────────────────────────────
        ExampleSection(
          title: 'Menu dark',
          description:
              'Con dark il pannello passa a una fascia ardesia con contenuti '
              'bianchi: intestazione, voci, separatori e stati attivo e '
              'disabilitato hanno tutti una loro dichiarazione nel foglio di '
              'stile. La voce attiva vira al ciano invece che al blu scuro, '
              'perché su questo fondo il blu scuro sarebbe illeggibile.',
          code: 'ItDropdownMenu(\n'
              '  dark: true,\n'
              '  items: [\n'
              "    ItDropdownHeader(label: 'Intestazione'),\n"
              "    ItDropdownItem(label: 'Azione 1 (attivo)', active: true),\n"
              "    ItDropdownItem(label: 'Azione 2', onTap: () {}),\n"
              '    ItDropdownDivider(),\n'
              "    ItDropdownItem(label: 'Azione 5 (disabilitato)',\n"
              '        disabled: true),\n'
              '  ],\n'
              ')',
          child: _panel(
            ItDropdownMenu(
              dark: true,
              items: [
                const ItDropdownHeader(label: 'Intestazione'),
                ItDropdownItem(
                  label: 'Azione 1 (attivo)',
                  icon: BootstrapItaliaIcons.it_star_outline,
                  rightIcon: true,
                  active: true,
                  onTap: () {},
                ),
                ItDropdownItem(
                  label: 'Azione 2',
                  icon: BootstrapItaliaIcons.it_star_outline,
                  rightIcon: true,
                  onTap: () {},
                ),
                const ItDropdownDivider(),
                ItDropdownItem(
                  label: 'Azione 4',
                  icon: BootstrapItaliaIcons.it_star_outline,
                  rightIcon: true,
                  onTap: () {},
                ),
                const ItDropdownItem(
                  label: 'Azione 5 (disabilitato)',
                  icon: BootstrapItaliaIcons.it_star_outline,
                  rightIcon: true,
                  disabled: true,
                ),
              ],
            ),
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Attivazione tramite codice, con le sue tabelle di opzioni, '
              'metodi ed eventi — riguarda il plugin JavaScript del kit e la '
              'libreria Popper.js che ne calcola il posizionamento. In Flutter '
              'non esiste una fase di inizializzazione: il widget è attivo '
              "appena costruito, e la direzione di apertura è un parametro "
              'invece che il risultato di un calcolo a tempo di esecuzione.\n\n'
              'Gli stati al passaggio del mouse (la sottolineatura delle voci) '
              'sono implementati ma non hanno una sezione propria da '
              'riprodurre, e sui dispositivi tattili non hanno equivalente.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
