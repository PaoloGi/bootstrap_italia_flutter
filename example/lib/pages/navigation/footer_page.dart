import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors
/// https://italia.github.io/bootstrap-italia/docs/menu-di-navigazione/footer/
///
/// The docs show two footers and nothing else — the complete one and the
/// contacts-only one — so this page is short by design. Both are full-bleed
/// bands, and both are shown at their real width rather than shrunk to fit a
/// card: a footer that has been squeezed is a different component.
class FooterPage extends StatelessWidget {
  const FooterPage({super.key});

  static List<ItFooterSection> _sections() => [
        ItFooterSection(
          title: 'Amministrazione',
          onTitleTap: () {},
          links: [
            ItFooterLink(label: 'Giunta e consiglio', onTap: () {}),
            ItFooterLink(label: 'Aree di competenza', onTap: () {}),
            ItFooterLink(label: 'Dipendenti', onTap: () {}),
            ItFooterLink(label: 'Luoghi', onTap: () {}),
            ItFooterLink(
                label: 'Associazioni e società partecipate', onTap: () {}),
          ],
        ),
        ItFooterSection(
          title: 'Servizi',
          onTitleTap: () {},
          links: [
            ItFooterLink(label: 'Pagamenti', onTap: () {}),
            ItFooterLink(label: 'Sostegno', onTap: () {}),
            ItFooterLink(label: 'Domande e iscrizioni', onTap: () {}),
            ItFooterLink(label: 'Segnalazioni', onTap: () {}),
            ItFooterLink(label: 'Autorizzazioni e concessioni', onTap: () {}),
            ItFooterLink(label: 'Certificati e dichiarazioni', onTap: () {}),
          ],
        ),
        ItFooterSection(
          title: 'Novità',
          onTitleTap: () {},
          links: [
            ItFooterLink(label: 'Notizie', onTap: () {}),
            ItFooterLink(label: 'Eventi', onTap: () {}),
            ItFooterLink(label: 'Comunicati stampa', onTap: () {}),
          ],
        ),
        ItFooterSection(
          title: 'Documenti',
          onTitleTap: () {},
          links: [
            ItFooterLink(label: 'Progetti e attività', onTap: () {}),
            ItFooterLink(
                label: 'Delibere, determine e ordinanze', onTap: () {}),
            ItFooterLink(label: 'Bandi', onTap: () {}),
            ItFooterLink(label: 'Concorsi', onTap: () {}),
            ItFooterLink(label: 'Albo pretorio', onTap: () {}),
          ],
        ),
      ];

  static List<ItFooterSection> _contacts() => [
        ItFooterSection(
          title: 'Contatti',
          // The kit's `<p>` sets the institution's name in `<strong>` on its
          // own line and the address beneath it — one paragraph, two weights,
          // which is why this slot takes a widget rather than a string.
          content: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Comune di Lorem Ipsum\n',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: 'Via Roma 0 - 00000 Lorem Ipsum\n'
                      'Codice fiscale / P. IVA: 000000000',
                ),
              ],
            ),
          ),
          links: [
            ItFooterLink(label: 'Posta Elettronica Certificata', onTap: () {}),
            ItFooterLink(
              label: 'URP - Ufficio Relazioni con il Pubblico',
              onTap: () {},
            ),
          ],
        ),
        const ItFooterSection(title: 'Lorem Ipsum', links: []),
      ];

  static List<ItSocialLink> _socials() => [
        ItSocialLink(
          icon: BootstrapItaliaIcons.it_designers_italia,
          label: 'Designers Italia (link esterno)',
          onTap: () {},
        ),
        ItSocialLink(
          icon: BootstrapItaliaIcons.it_twitter,
          label: 'X (link esterno)',
          onTap: () {},
        ),
        ItSocialLink(
          icon: BootstrapItaliaIcons.it_medium,
          label: 'Medium (link esterno)',
          onTap: () {},
        ),
        ItSocialLink(
          icon: BootstrapItaliaIcons.it_behance,
          label: 'Behance (link esterno)',
          onTap: () {},
        ),
      ];

  static List<ItFooterLink> _legal() => [
        ItFooterLink(label: 'Media policy', onTap: () {}),
        ItFooterLink(label: 'Note legali', onTap: () {}),
        ItFooterLink(label: 'Privacy policy', onTap: () {}),
        ItFooterLink(label: 'Mappa del sito', onTap: () {}),
        ItFooterLink(
          label: 'Dichiarazione di accessibilità (link esterno su sito AgID)',
          onTap: () {},
        ),
      ];

  /// A band shown at its own width, scrolling sideways rather than reflowing.
  ///
  /// The footer's columns are a fixed-count row, as the kit's `.col-lg-3` grid
  /// is on desktop. Letting the page squeeze them would show a layout the docs
  /// never produce.
  static Widget _band(Widget child) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: 1176, child: child),
      );

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Footer',
      children: [
        // ── Introduzione ───────────────────────────────────────────────────
        const ExampleSection(
          title: 'Introduzione',
          description: 'Il footer raccoglie i riferimenti al sito e alla '
              'amministrazione che rappresenta: i servizi, le pagine utili '
              'alla cittadinanza, i riferimenti alla privacy, il collegamento '
              "alla Dichiarazione di accessibilità sul form AgID e i recapiti "
              "dell'ente.\n\n"
              "Il componente si espone come landmark contentinfo, così che chi "
              'usa uno screen reader possa saltarci dentro o oltre senza '
              'attraversare decine di link. Le intestazioni delle colonne '
              'sono h4 veri, con il livello dichiarato, e il nome '
              "dell'istituzione è un h2: la navigazione per intestazioni "
              'funziona anche qui.',
          child: SizedBox.shrink(),
        ),

        // ── Footer completo ────────────────────────────────────────────────
        ExampleSection(
          title: 'Footer completo',
          description:
              'Quattro colonne di link, una fascia contatti separata da un '
              'filo bianco e la barra delle informazioni legali in fondo. '
              'Le colonne si descrivono con sections, la fascia contatti con '
              'contactSections: quando quest\'ultima è presente i social la '
              'raggiungono come ultima colonna, sotto un «Seguici su», che è '
              'dove il kit li mette.',
          code: 'ItFooter(\n'
              '  logo: const Icon(BootstrapItaliaIcons.it_pa),\n'
              "  institutionName: 'Lorem Ipsum',\n"
              "  description: 'Inserire qui la tag line',\n"
              '  sections: [\n'
              "    ItFooterSection(title: 'Amministrazione', links: [...]),\n"
              '  ],\n'
              '  contactSections: [\n'
              '    ItFooterSection(\n'
              "      title: 'Contatti',\n"
              "      content: const Text.rich(...), // indirizzo e P. IVA\n"
              '      links: [...],\n'
              '    ),\n'
              '  ],\n'
              '  socialLinks: [...],\n'
              '  legalInfo: [...],\n'
              ')',
          child: _band(
            ItFooter(
              // Two footers on one page is not something a real service has,
              // and Flutter asserts on repeated landmarks that share a name.
              semanticsLabel: 'Footer completo',
              logo: const Icon(BootstrapItaliaIcons.it_pa),
              institutionName: 'Lorem Ipsum',
              description: 'Inserire qui la tag line',
              sections: _sections(),
              contactSections: _contacts(),
              socialLinks: _socials(),
              legalInfo: _legal(),
            ),
          ),
        ),

        // ── Footer solo contatti ───────────────────────────────────────────
        ExampleSection(
          title: 'Footer solo contatti',
          description:
              'La stessa struttura senza le colonne di link: restano la '
              "testata con logo e tag line, la fascia contatti con i social e "
              'la barra legale. Basta omettere sections — non serve un '
              'parametro che spenga qualcosa, perché ogni blocco compare solo '
              'se gli si passa del contenuto.',
          code: 'ItFooter(\n'
              '  logo: const Icon(BootstrapItaliaIcons.it_pa),\n'
              "  institutionName: 'Lorem Ipsum',\n"
              "  description: 'Inserire qui la tag line',\n"
              '  contactSections: [...],\n'
              '  socialLinks: [...],\n'
              '  legalInfo: [...],\n'
              ')',
          child: _band(
            ItFooter(
              semanticsLabel: 'Footer solo contatti',
              logo: const Icon(BootstrapItaliaIcons.it_pa),
              institutionName: 'Lorem Ipsum',
              description: 'Inserire qui la tag line',
              contactSections: _contacts(),
              socialLinks: _socials(),
              legalInfo: _legal(),
            ),
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'La pagina del kit contiene solo i due footer riprodotti qui '
              'sopra: non ha sezioni su hover, su inizializzazione JavaScript '
              'né schemi sconsigliati.\n\n'
              'Restano due divergenze da segnalare. La prima: le intestazioni '
              'di colonna sono sempre disegnate sottolineate, perché nel kit '
              'sono ancore — <h4><a href="#">Amministrazione</a></h4> — e '
              'questo è il rendering verificato a confronto con il riferimento '
              'React. Nella fascia contatti però il kit scrive <h4>Contatti</h4> '
              'senza ancora, quindi qui quella voce appare sottolineata pur '
              'non essendo un link. Legarne la sottolineatura alla presenza di '
              'onTitleTap sposterebbe il rendering predefinito delle colonne '
              'principali, che è confrontato pixel a pixel.\n\n'
              'La seconda: senza contactSections i social restano nella riga in '
              'linea sotto le colonne, che è la disposizione che questo '
              "componente ha sempre avuto. È una via di mezzo che il kit non "
              'ha, tenuta per non cambiare aspetto alle applicazioni che già '
              'passano solo socialLinks.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
