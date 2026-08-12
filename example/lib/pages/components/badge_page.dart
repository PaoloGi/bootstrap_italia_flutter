import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/badge/
///
/// The docs page opens with two examples under no heading of their own — the
/// badge inside headings of different sizes, and the badge as a counter inside a
/// button. Both are reproduced, under descriptive titles, because they carry the
/// component's defining behaviour rather than being decorative.
class BadgePage extends StatelessWidget {
  const BadgePage({super.key});

  /// The five contextual variants the docs list, in their order.
  static const _variants = <ItBadgeVariant, String>{
    ItBadgeVariant.primary: 'Primary',
    ItBadgeVariant.secondary: 'Secondary',
    ItBadgeVariant.success: 'Success',
    ItBadgeVariant.danger: 'Danger',
    ItBadgeVariant.warning: 'Warning',
  };

  /// `.text-secondary` — `hsl(210, 33%, 28%)`.
  ///
  /// NOT `--bs-secondary`, which is `hsl(210, 17%, 44%)`. The utility class and
  /// the palette token disagree despite the shared name, which is exactly why
  /// [ItBadge.foregroundColor] takes a colour rather than a variant.
  static const _textSecondary = Color(0xFF30475F);

  @override
  Widget build(BuildContext context) {
    final typography = BootstrapItaliaTheme.typographyOf(context);

    return ComponentPage(
      title: 'Badge',
      children: [
        // ── Badge (the untitled opening example) ───────────────────────────
        ExampleSection(
          title: 'Badge',
          description:
              'La grandezza di ogni badge si adatta a quella del testo in cui '
              'è contenuto: --bs-badge-font-size vale 0.875em, non 14px. '
              'ItBadge legge quindi la dimensione dallo stile di testo '
              'circostante, come qui, dove lo stesso widget cambia scala '
              'seguendo il titolo. Senza uno stile ambientale usa 1rem, cioè '
              'la radice del foglio di stile.',
          code: 'DefaultTextStyle.merge(\n'
              '  style: typography.h1,\n'
              '  child: Row(children: [\n'
              "    Text('Titolo di esempio h1'),\n"
              '    ItBadge(\n'
              '      variant: ItBadgeVariant.secondary,\n'
              "      child: Text('New'),\n"
              '    ),\n'
              '  ]),\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final style in <(String, TextStyle)>[
                ('h1', typography.h1),
                ('h3', typography.h3),
                ('h5', typography.h5),
                ('h6', typography.h6),
              ])
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: BootstrapItaliaSpacing.space2),
                  child: DefaultTextStyle.merge(
                    style: style.$2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(child: Text('Titolo di esempio ${style.$1}')),
                        const SizedBox(width: BootstrapItaliaSpacing.space2),
                        const ItBadge(
                          variant: ItBadgeVariant.secondary,
                          child: Text('New'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Badge come contatore (the second untitled example) ─────────────
        ExampleSection(
          title: 'Badge come contatore in un pulsante',
          description:
              'Il badge può fare da contatore dentro un link o un pulsante. La '
              'documentazione usa qui le utility .bg-white e .text-secondary, '
              'che non sono varianti: sono classi di sfondo e di colore. Il '
              'corrispettivo sono backgroundColor e foregroundColor. Da notare '
              'che .text-secondary vale #30475F e non è il token secondary del '
              'tema — le due cose condividono il nome e non il valore.',
          code: 'ItButton(\n'
              '  onPressed: () {},\n'
              '  child: Row(\n'
              '    mainAxisSize: MainAxisSize.min,\n'
              '    children: [\n'
              "      Text('Notifiche'),\n"
              '      SizedBox(width: 8),\n'
              '      ItBadge(\n'
              '        backgroundColor: BootstrapItaliaColors.white,\n'
              '        foregroundColor: Color(0xFF30475F),\n'
              "        child: Text('4'),\n"
              '      ),\n'
              '    ],\n'
              '  ),\n'
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space3,
            runSpacing: BootstrapItaliaSpacing.space3,
            children: [
              ItButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Notifiche'),
                    SizedBox(width: BootstrapItaliaSpacing.space2),
                    ItBadge(
                      backgroundColor: BootstrapItaliaColors.white,
                      foregroundColor: _textSecondary,
                      child: Text('4'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Accessibilità ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Accessibilità',
          description:
              'Fuori contesto un badge può sembrare «una parola o un numero '
              'aggiuntivo casuale alla fine di una frase». Dove il contesto non '
              'basta — «Profilo 9» non dice che cosa siano i nove — si passa '
              'semanticLabel: sostituisce ciò che viene letto, senza cambiare '
              'ciò che si vede. È la controparte del <span class="visually-'
              'hidden"> della documentazione.',
          code: 'ItBadge(\n'
              '  backgroundColor: BootstrapItaliaColors.white,\n'
              '  foregroundColor: BootstrapItaliaColors.primary,\n'
              "  semanticLabel: '9 messaggi non letti',\n"
              "  child: Text('9'),\n"
              ')',
          child: ItButton(
            onPressed: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Profilo'),
                SizedBox(width: BootstrapItaliaSpacing.space2),
                ItBadge(
                  backgroundColor: BootstrapItaliaColors.white,
                  foregroundColor: BootstrapItaliaColors.primary,
                  semanticLabel: '9 messaggi non letti',
                  child: Text('9'),
                ),
              ],
            ),
          ),
        ),

        // ── Variazioni contestuali ─────────────────────────────────────────
        ExampleSection(
          title: 'Variazioni contestuali',
          description: 'Le classi .bg-* diventano qui il parametro variant. La '
              'documentazione ne elenca cinque; ItBadgeVariant ne offre otto, '
              'aggiungendo info, light e dark che il foglio di stile definisce '
              'ugualmente.',
          code: 'ItBadge(\n'
              '  variant: ItBadgeVariant.success,\n'
              "  child: Text('Success'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              for (final entry in _variants.entries)
                ItBadge(variant: entry.key, child: Text(entry.value)),
            ],
          ),
        ),

        // ── Trasmettere significato alle tecnologie assistive ──────────────
        ExampleSection(
          title: 'Trasmettere significato alle tecnologie assistive',
          description:
              'Il colore da solo è una indicazione visiva e non raggiunge le '
              'tecnologie assistive: un badge rosso e uno verde si annunciano '
              'allo stesso modo. Il significato va quindi messo nel testo, '
              'come qui, dove «Scaduto» e «Attivo» dicono da soli quello che '
              'il colore ripete.',
          code:
              "ItBadge(variant: ItBadgeVariant.danger, child: Text('Scaduto'))\n"
              "ItBadge(variant: ItBadgeVariant.success, child: Text('Attivo'))",
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: const [
              ItBadge(variant: ItBadgeVariant.danger, child: Text('Scaduto')),
              ItBadge(variant: ItBadgeVariant.success, child: Text('Attivo')),
              ItBadge(
                  variant: ItBadgeVariant.warning, child: Text('In scadenza')),
            ],
          ),
        ),

        // ── Badges arrotondati ─────────────────────────────────────────────
        ExampleSection(
          title: 'Badges arrotondati',
          description:
              'pill: true corrisponde a .rounded-pill. Oltre al raggio cambia '
              'anche il rientro orizzontale, che passa da 0.4em a 0.6em: senza '
              'quello il testo toccherebbe la curva.',
          code: 'ItBadge(\n'
              '  variant: ItBadgeVariant.primary,\n'
              '  pill: true,\n'
              "  child: Text('Primary'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              for (final entry in _variants.entries)
                ItBadge(
                  variant: entry.key,
                  pill: true,
                  child: Text(entry.value),
                ),
            ],
          ),
        ),

        // ── Link ───────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Link',
          description:
              'Con onTap il badge diventa un link: prende il ruolo, il fuoco '
              'da tastiera e lo stato hover, che scurisce lo sfondo al 80% del '
              'colore di partenza. Il ruolo annunciato è «link» e non '
              '«pulsante», perché la documentazione mette la classe su un <a>.',
          code: 'ItBadge(\n'
              '  variant: ItBadgeVariant.primary,\n'
              '  onTap: () => Navigator.pushNamed(context, ...),\n'
              "  child: Text('Primary'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              for (final entry in _variants.entries)
                ItBadge(
                  variant: entry.key,
                  onTap: () {},
                  child: Text(entry.value),
                ),
            ],
          ),
        ),

        // Not a docs section: ItNotificationBadge is this package's own, and a
        // reader arriving from the docs will not find it there.
        const ExampleSection(
          title: 'ItNotificationBadge (aggiunta di questo pacchetto)',
          description:
              'Non è una sezione della documentazione: è un badge posizionato '
              'sopra un altro elemento, che il kit ottiene con il markup '
              '.badge-wrapper della bottom-nav. Il conteggio annunciato è '
              'quello visualizzato, tetto compreso — se lo screen reader '
              'dicesse 250 dove lo schermo mostra 99+, due persone davanti '
              'allo stesso badge leggerebbero numeri diversi.',
          code: 'ItNotificationBadge(\n'
              '  count: 5,\n'
              "  semanticLabel: '5 messaggi non letti',\n"
              '  child: Icon(BootstrapItaliaIcons.it_mail),\n'
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space4,
            runSpacing: BootstrapItaliaSpacing.space3,
            children: [
              ItNotificationBadge(
                count: 5,
                semanticLabel: '5 messaggi non letti',
                child: Icon(BootstrapItaliaIcons.it_mail, size: 32),
              ),
              ItNotificationBadge(
                count: 250,
                semanticLabel: '250 notifiche',
                child: Icon(BootstrapItaliaIcons.it_mail_open, size: 32),
              ),
              ItNotificationBadge(
                count: 0,
                child: Icon(BootstrapItaliaIcons.it_comment, size: 32),
              ),
            ],
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Nessuna sezione è stata omessa: la pagina Badge non ha né '
              'attivazione tramite codice né metodi JavaScript.\n\n'
              'Due dettagli però cambiano forma. Gli stati :hover e :focus '
              'della sezione Link: il fuoco è reso dallo stesso anello che '
              'usano tutti i controlli del pacchetto, mentre lo hover non ha '
              'equivalente sui dispositivi tattili e resta visibile solo con '
              'un puntatore. E i badge outline (.badge-outline-*) esistono nel '
              'foglio di stile ma non compaiono in questa pagina, quindi non '
              'sono riprodotti qui.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
