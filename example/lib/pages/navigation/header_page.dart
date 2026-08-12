import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors
/// https://italia.github.io/bootstrap-italia/docs/menu-di-navigazione/header/
///
/// Every band here is full-bleed: the kit lays them out inside a
/// `.container-xxl`, and a header squeezed into a 600px card is a different
/// component from the one being documented. So each example is hosted in a
/// 1176px strip that scrolls sideways rather than reflowing — but only at a
/// desktop viewport. Below `lg` the bands collapse to their own mobile layouts,
/// which is what they are supposed to do, and forcing a desktop width there
/// would hide exactly that.
class HeaderPage extends StatelessWidget {
  const HeaderPage({super.key});

  /// `.container-xxl` at the `xxl` breakpoint.
  static const double _containerWidth = 1176;

  /// A host for a band that has a mobile layout of its own.
  ///
  /// `context.isDesktop` is the same breakpoint resolver [ItNavHeader] itself
  /// consults, so the host and the band can never disagree about which layout
  /// is on screen: above `lg` the band gets the container width it was
  /// designed for, below it the band collapses and takes the page's.
  static Widget _band(BuildContext context, Widget child) {
    if (!context.isDesktop) return child;
    return _fixedBand(child);
  }

  /// A host for a band that has no mobile layout at all.
  ///
  /// [ItSlimHeader] and [ItCenterHeader] render one row at every width — the
  /// kit collapses them into the burger menu, and this package does not — so a
  /// narrow window gives them less room than their content needs. Hosting them
  /// at the container width and letting the strip scroll sideways shows what
  /// the band actually is; letting the page squeeze them would show an
  /// overflow, which is not a layout the docs have.
  static Widget _fixedBand(Widget child) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: _containerWidth, child: child),
      );

  static List<ItSlimHeaderLink> _slimLinks() => [
        ItSlimHeaderLink(label: 'Link 1', onTap: () {}),
        ItSlimHeaderLink(label: 'Link 2 (Attivo)', active: true, onTap: () {}),
      ];

  static List<ItSocialLink> _socials() => [
        ItSocialLink(
          icon: BootstrapItaliaIcons.it_facebook,
          label: 'Facebook',
          onTap: () {},
        ),
        ItSocialLink(
          icon: BootstrapItaliaIcons.it_github,
          label: 'GitHub',
          onTap: () {},
        ),
        ItSocialLink(
          icon: BootstrapItaliaIcons.it_twitter,
          label: 'X',
          onTap: () {},
        ),
      ];

  static List<ItNavItem> _navItems() => [
        ItNavItem(label: 'Link 1 (attivo)', active: true, onTap: () {}),
        const ItNavItem(label: 'Link 2 (disabilitato)', disabled: true),
        ItNavItem(label: 'Link 3', onTap: () {}),
        ItNavItem(label: 'Link 4', onTap: () {}),
        ItNavItem(label: 'Menu Dropdown', hasDropdown: true, onTap: () {}),
        ItNavItem(label: 'Megamenu', megamenu: true, onTap: () {}),
      ];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Header',
      children: [
        // ── Accessibilità ──────────────────────────────────────────────────
        const ExampleSection(
          title: 'Accessibilità',
          description:
              "Il titolo del sito è un h2 e non un h1, per non entrare in "
              "conflitto con l'h1 delle singole pagine: è la stessa scelta "
              'della documentazione, qui espressa dichiarando il livello di '
              "intestazione all'albero semantico invece che scegliendo un tag. "
              'La tag line lo segue come h3.\n\n'
              'La fascia di navigazione si espone come landmark di '
              'navigazione, con ogni voce come nodo a sé; le voci attive '
              'dichiarano lo stato di selezione, che altrimenti sarebbe '
              'affidato al solo bordo bianco di tre pixel, e quelle '
              'disabilitate restano annunciate come tali. Il pulsante burger '
              'ha un nome che cambia con lo stato — «Apri menu» / «Chiudi '
              'menu» — e arriva da ItLocalizations.',
          child: SizedBox.shrink(),
        ),

        // ── Slim Header ────────────────────────────────────────────────────
        ExampleSection(
          title: 'Slim Header',
          description:
              "La fascia sottile in cima mostra l'ente di appartenenza, "
              'eventuali link utili, il cambio lingua e l\'accesso all\'area '
              'riservata. Il cambio lingua è reso come pulsante con stato '
              'aperto/chiuso: dropdownExpanded ne governa il verso della '
              'freccia e, insieme, lo stato annunciato.',
          code: 'ItSlimHeader(\n'
              "  institutionName: 'Ente appartenenza',\n"
              '  links: [\n'
              "    ItSlimHeaderLink(label: 'Link 1', onTap: () {}),\n"
              "    ItSlimHeaderLink(label: 'Link 2 (Attivo)', active: true),\n"
              '  ],\n'
              "  dropdownLabel: 'ITA',\n"
              '  onDropdownTap: () {},\n'
              "  accessLabel: 'Accedi',\n"
              '  onAccessTap: () {},\n'
              ')',
          child: _fixedBand(
            ItSlimHeader(
              institutionName: 'Ente appartenenza',
              links: _slimLinks(),
              dropdownLabel: 'ITA',
              onDropdownTap: () {},
              accessLabel: 'Accedi',
              onAccessTap: () {},
            ),
          ),
        ),

        // ── Zona destra con pulsante full-responsive ───────────────────────
        ExampleSection(
          title: 'Zona destra con pulsante full-responsive',
          description:
              'Con accessButtonFull il pulsante di accesso perde gli angoli '
              "arrotondati e si stira a tutta l'altezza della fascia. È il "
              'modificatore .btn-full: su una barra stretta è quello che tiene '
              "l'azione raggiungibile, perché una pillola sospesa in 48 pixel "
              'non ha più dove andare.',
          code: 'ItSlimHeader(\n'
              "  institutionName: 'Ente appartenenza',\n"
              "  dropdownLabel: 'ITA',\n"
              '  onDropdownTap: () {},\n'
              "  accessLabel: 'Accedi all\\'area personale',\n"
              '  accessButtonFull: true,\n'
              '  onAccessTap: () {},\n'
              ')',
          child: _fixedBand(
            ItSlimHeader(
              institutionName: 'Ente appartenenza',
              dropdownLabel: 'ITA',
              onDropdownTap: () {},
              accessLabel: "Accedi all'area personale",
              accessButtonFull: true,
              onAccessTap: () {},
            ),
          ),
        ),

        // ── Slim Header, versione chiara ───────────────────────────────────
        ExampleSection(
          title: 'Slim Header — versione chiara',
          description:
              'Con light la fascia passa a fondo bianco con contenuti nel '
              'colore primario, e guadagna il filo inferiore che la stacca '
              'dalla pagina. A differenza della fascia scura, questa variante '
              'segue il tema: bianco e primario sono qui esattamente i ruoli '
              'che quei due token nominano, quindi una amministrazione che '
              'personalizza primary vede cambiare testi, filo e pulsante '
              'insieme.',
          code: 'ItSlimHeader(\n'
              '  light: true,\n'
              "  institutionName: 'Ente appartenenza',\n"
              '  links: [...],\n'
              "  dropdownLabel: 'ITA',\n"
              "  accessLabel: 'Accedi',\n"
              ')',
          child: _fixedBand(
            ItSlimHeader(
              light: true,
              institutionName: 'Ente appartenenza',
              links: _slimLinks(),
              dropdownLabel: 'ITA',
              onDropdownTap: () {},
              accessLabel: 'Accedi',
              onAccessTap: () {},
            ),
          ),
        ),

        // ── Header Centrale ────────────────────────────────────────────────
        ExampleSection(
          title: 'Header Centrale',
          description:
              "Mostra il logo dell'ente, il nome, la tag line, i link ai "
              'social e l\'accesso alla ricerca. L\'etichetta «Cerca» e il '
              'nome accessibile del pulsante sono la stessa stringa per '
              'contratto: se divergessero, il criterio «etichetta nel nome» '
              'sarebbe violato.',
          code: 'ItCenterHeader(\n'
              '  logo: const Icon(BootstrapItaliaIcons.it_pa),\n'
              "  title: 'Nome dell\\'Istituzione',\n"
              "  subtitle: 'Tag line dell\\'Istituzione',\n"
              '  socialLinks: [\n'
              "    ItSocialLink(icon: …, label: 'Facebook', onTap: () {}),\n"
              '  ],\n'
              '  showSearch: true,\n'
              '  onSearchTap: () {},\n'
              ')',
          child: _fixedBand(
            ItCenterHeader(
              logo: const Icon(BootstrapItaliaIcons.it_pa),
              title: "Nome dell'Istituzione",
              subtitle: "Tag line dell'Istituzione",
              socialLinks: _socials(),
              showSearch: true,
              onSearchTap: () {},
            ),
          ),
        ),

        // ── Header Centrale, versione compatta ─────────────────────────────
        ExampleSection(
          title: 'Header Centrale — versione compatta',
          description: 'Con small la fascia scende da 120 a 104 pixel e le due '
              'intestazioni rimpiccioliscono. È il modificatore '
              'it-small-header, pensato per quando sopra e sotto ci sono già '
              'le altre due fasce.',
          code: 'ItCenterHeader(\n'
              '  small: true,\n'
              "  title: 'Nome dell\\'Istituzione',\n"
              "  subtitle: 'Tag line dell\\'Istituzione',\n"
              '  showSearch: true,\n'
              ')',
          child: _fixedBand(
            ItCenterHeader(
              small: true,
              logo: const Icon(BootstrapItaliaIcons.it_pa),
              title: "Nome dell'Istituzione",
              subtitle: "Tag line dell'Istituzione",
              socialLinks: _socials(),
              showSearch: true,
              onSearchTap: () {},
            ),
          ),
        ),

        // ── Header Centrale, versione chiara ───────────────────────────────
        ExampleSection(
          title: 'Header Centrale — versione chiara',
          description:
              'Con light fondo e contenuti si scambiano: bianco sotto, '
              'primario sopra, e il tondo della ricerca fa lo stesso scambio '
              'al proprio interno. Anche qui il tema comanda: sono i token '
              'white e primary nei ruoli che nominano.',
          code: 'ItCenterHeader(\n'
              '  light: true,\n'
              "  title: 'Nome dell\\'Istituzione',\n"
              "  subtitle: 'Tag line dell\\'Istituzione',\n"
              '  showSearch: true,\n'
              ')',
          child: _fixedBand(
            ItCenterHeader(
              light: true,
              logo: const Icon(BootstrapItaliaIcons.it_pa),
              title: "Nome dell'Istituzione",
              subtitle: "Tag line dell'Istituzione",
              socialLinks: _socials(),
              showSearch: true,
              onSearchTap: () {},
            ),
          ),
        ),

        // ── Header Nav ─────────────────────────────────────────────────────
        ExampleSection(
          title: 'Header Nav',
          description:
              'La fascia di navigazione elenca le voci del menu. Sopra il '
              'breakpoint lg è una barra orizzontale; sotto si richiude su un '
              'pulsante burger. La decisione dipende dalla larghezza della '
              'finestra e non da quella del contenitore, perché è così che '
              'funzionano le media query — ed è per questo che questa pagina '
              'ospita le fasce in una striscia che scorre invece di '
              'stringerle.',
          code: 'ItNavHeader(\n'
              '  items: [\n'
              "    ItNavItem(label: 'Link 1 (attivo)', active: true, onTap: () {}),\n"
              "    ItNavItem(label: 'Link 2 (disabilitato)', disabled: true),\n"
              "    ItNavItem(label: 'Menu Dropdown', hasDropdown: true),\n"
              "    ItNavItem(label: 'Megamenu', megamenu: true),\n"
              '  ],\n'
              ')',
          child: _band(
            context,
            ItNavHeader(
              semanticsLabel: 'Navigazione principale',
              items: _navItems(),
            ),
          ),
        ),

        // ── Header Nav standard ────────────────────────────────────────────
        ExampleSection(
          title: 'Header Nav standard',
          description:
              'Il tema predefinito: su desktop fondo primario e link bianchi. '
              'Su mobile la documentazione prevede invece fondo bianco e '
              'contenuti primari — questo pacchetto ha sempre disegnato il '
              'pannello scuro, quindi darkMobile vale true di partenza e la '
              'sezione qui sotto mostra come tornare al comportamento del kit.',
          code:
              'ItNavHeader(items: [...]) // darkMobile: true, lightDesk: false',
          child: _band(
            context,
            ItNavHeader(
              semanticsLabel: 'Navigazione, tema standard',
              items: _navItems(),
            ),
          ),
        ),

        // ── Header Nav mobile scura ────────────────────────────────────────
        ExampleSection(
          title: 'Header Nav mobile scura',
          description:
              'La classe .theme-dark-mobile porta il pannello mobile a fondo '
              'primario con testi e link bianchi, e la voce attiva a un filo '
              'bianco sul fianco sinistro. Riguarda solo la resa sotto il '
              'breakpoint lg: su desktop non cambia nulla. Per vederla '
              'restringere la finestra sotto i 992 pixel.',
          code: 'ItNavHeader(\n'
              '  darkMobile: true, // già il predefinito in questo pacchetto\n'
              '  items: [...],\n'
              ')\n\n'
              '// Il tema chiaro del kit, per confronto:\n'
              'ItNavHeader(darkMobile: false, items: [...])',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _band(
                context,
                ItNavHeader(
                  semanticsLabel: 'Navigazione, tema mobile scuro',
                  items: _navItems(),
                ),
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space3),
              _band(
                context,
                ItNavHeader(
                  semanticsLabel: 'Navigazione, tema mobile chiaro',
                  darkMobile: false,
                  items: _navItems(),
                ),
              ),
            ],
          ),
        ),

        // ── Header Nav desktop chiara ──────────────────────────────────────
        ExampleSection(
          title: 'Header Nav desktop chiara',
          description:
              'La classe .theme-light-desk porta la fascia desktop a fondo '
              'bianco con testi e link primari, e le dà l\'ombra che la '
              'stacca dalla pagina — una barra bianca su una pagina bianca '
              'altrimenti non avrebbe bordo. La voce attiva porta il proprio '
              'filo inferiore nello stesso colore del testo.',
          code: 'ItNavHeader(\n'
              '  lightDesk: true,\n'
              '  items: [...],\n'
              ')',
          child: _band(
            context,
            ItNavHeader(
              semanticsLabel: 'Navigazione, tema desktop chiaro',
              lightDesk: true,
              items: _navItems(),
            ),
          ),
        ),

        // ── Navigazione secondaria ─────────────────────────────────────────
        ExampleSection(
          title: 'Navigazione secondaria',
          description:
              'Al menu principale si può affiancare un secondo elenco, '
              'allineato a destra e in corpo più piccolo. È la lista '
              '.navbar-nav.navbar-secondary: il contenitore dei due elenchi '
              'distribuisce lo spazio fra loro, quindi il primo tiene la '
              'sinistra e il secondo la destra. Su mobile confluiscono nello '
              'stesso pannello, come nel kit.',
          code: 'ItNavHeader(\n'
              '  items: [...],\n'
              '  secondaryItems: [\n'
              "    ItNavItem(label: 'Link 5', onTap: () {}),\n"
              "    ItNavItem(label: 'Link 6', onTap: () {}),\n"
              '  ],\n'
              ')',
          child: _band(
            context,
            ItNavHeader(
              semanticsLabel: 'Navigazione con menu secondario',
              items: [
                ItNavItem(label: 'Link 1 (attivo)', active: true, onTap: () {}),
                const ItNavItem(label: 'Link 2 (disabilitato)', disabled: true),
                ItNavItem(label: 'Link 3', onTap: () {}),
                ItNavItem(label: 'Link 4', onTap: () {}),
              ],
              secondaryItems: [
                for (var i = 5; i <= 8; i++)
                  ItNavItem(label: 'Link $i', onTap: () {}),
              ],
            ),
          ),
        ),

        // ── Header Completa ────────────────────────────────────────────────
        ExampleSection(
          title: 'Header Completa',
          description:
              'Le tre fasce impilate. ItHeader non fa altro che comporle '
              'nell\'ordine, e ognuna resta facoltativa. Per una testata che '
              'resti in cima mentre la pagina scorre serve ItSliverHeader '
              'dentro una CustomScrollView: fissare una fascia richiede un '
              'contesto di scorrimento, che un widget qualsiasi non può darsi '
              'da solo.',
          code: 'ItHeader(\n'
              '  slimHeader: ItSlimHeader(...),\n'
              '  centerHeader: ItCenterHeader(small: true, ...),\n'
              '  navHeader: ItNavHeader(items: [...]),\n'
              ')\n\n'
              '// Fissata in cima mentre la pagina scorre:\n'
              'CustomScrollView(\n'
              '  slivers: [\n'
              '    ItSliverHeader(navHeader: ItNavHeader(items: [...])),\n'
              '    SliverList(...),\n'
              '  ],\n'
              ')',
          child: _fixedBand(
            ItHeader(
              slimHeader: ItSlimHeader(
                institutionName: 'Ente appartenenza',
                links: _slimLinks(),
                dropdownLabel: 'ITA',
                onDropdownTap: () {},
                accessLabel: 'Accedi',
                onAccessTap: () {},
              ),
              centerHeader: ItCenterHeader(
                small: true,
                logo: const Icon(BootstrapItaliaIcons.it_pa),
                title: "Nome dell'Istituzione",
                subtitle: "Tag line dell'Istituzione",
                socialLinks: _socials(),
                showSearch: true,
                onSearchTap: () {},
              ),
              navHeader: ItNavHeader(
                semanticsLabel: 'Navigazione della header completa',
                items: _navItems(),
              ),
            ),
          ),
        ),

        // ── Header Completa, versione chiara ───────────────────────────────
        ExampleSection(
          title: 'Header Completa — versione chiara',
          description:
              'Le stesse tre fasce con i rispettivi temi chiari. Sono tre '
              'parametri distinti e non uno solo, esattamente come nel kit '
              'sono tre classi su tre elementi diversi: una amministrazione '
              'può volere la fascia centrale chiara e la navigazione scura.',
          code: 'ItHeader(\n'
              '  slimHeader: ItSlimHeader(light: true, ...),\n'
              '  centerHeader: ItCenterHeader(light: true, ...),\n'
              '  navHeader: ItNavHeader(lightDesk: true, items: [...]),\n'
              ')',
          child: _fixedBand(
            ItHeader(
              slimHeader: ItSlimHeader(
                light: true,
                institutionName: 'Ente appartenenza',
                links: _slimLinks(),
                dropdownLabel: 'ITA',
                onDropdownTap: () {},
                accessLabel: 'Accedi',
                onAccessTap: () {},
              ),
              centerHeader: ItCenterHeader(
                light: true,
                small: true,
                logo: const Icon(BootstrapItaliaIcons.it_pa),
                title: "Nome dell'Istituzione",
                subtitle: "Tag line dell'Istituzione",
                socialLinks: _socials(),
                showSearch: true,
                onSearchTap: () {},
              ),
              navHeader: ItNavHeader(
                semanticsLabel: 'Navigazione della header completa chiara',
                lightDesk: true,
                items: _navItems(),
              ),
            ),
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Attivazione tramite codice, con inizializzazione automatica e '
              'manuale e la tabella dei metodi — riguarda il JavaScript del '
              'kit. Le fasce qui sono attive appena costruite.\n\n'
              'Breaking change dalle versioni 2.15.0 e 2.8.0 — è la '
              'cronologia del kit, non una funzionalità da mostrare. Vale '
              'però la pena sapere che la 2.15.0 ha reimplementato la navbar '
              'mobile come modale con trappola del focus: è il modello che '
              'ItMegamenu segue sul suo pannello mobile.\n\n'
              'Due divergenze da segnalare. La prima: nelle sezioni del kit '
              'le voci «Menu Dropdown» e «Megamenu» aprono davvero un '
              'pannello. ItNavHeader disegna la freccia ma non possiede '
              'nessun pannello da aprire, e per questo non dichiara uno stato '
              'aperto/chiuso — annunciarlo significherebbe promettere un '
              'comando che non esiste. Per un megamenu funzionante si usa '
              'ItMegamenu, che quello stato lo possiede.\n\n'
              'La seconda: la documentazione dice che su mobile il tema '
              'predefinito della fascia di navigazione è chiaro. Qui '
              'darkMobile vale true, perché il pannello scuro è quello che '
              'questo pacchetto ha sempre disegnato e cambiarne il valore '
              'predefinito ridipingerebbe le applicazioni esistenti senza '
              'preavviso. La resa del kit si ottiene con darkMobile: false.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
