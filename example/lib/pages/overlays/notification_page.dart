import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/notifiche/
///
/// The docs freeze their notifications in place — *"gli esempi di questa pagina
/// sono stati resi statici per facilitare un confronto fra le varie
/// tipologie"* — so the comparison sections below place [ItNotification]
/// directly, and only the placement sections go through [ItNotification.show].
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
      'eiusmod tempor…';

  /// A notification shown as a specimen rather than as a notification.
  ///
  /// [ItNotification] is a WCAG 4.1.3 status message: it announces itself the
  /// moment it appears, which is the whole point of the component and exactly
  /// wrong for a page that shows nine of them side by side. Frozen samples are
  /// pictures of notifications, so they are kept out of the accessibility tree;
  /// the live behaviour is demonstrated by the buttons further down, one
  /// announcement at a time.
  static Widget _specimen(Widget child) => ExcludeSemantics(child: child);

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Notifiche',
      children: [
        // ── Accessibilità ──────────────────────────────────────────────────
        const ExampleSection(
          title: 'Accessibilità',
          description:
              'La documentazione chiede tre cose: che il titolo abbia un id '
              'univoco, che la notifica lo indichi con aria-labelledby e che '
              'porti role="alert". Il widget le assolve senza parametri: la '
              'scheda è un nodo semantico a sé, dichiarato come regione viva, '
              'con per nome il titolo e il messaggio uniti. In più annuncia '
              "esplicitamente il proprio testo alla comparsa, perché una "
              'regione viva che nasce già piena spesso non viene letta.\n\n'
              'Il titolo è disegnato in maiuscolo ma annunciato come è stato '
              'scritto: la maiuscoletta è presentazione, e uno screen reader '
              'la leggerebbe lettera per lettera.',
          code: 'ItNotification.show(\n'
              '  context: context,\n'
              "  title: 'Titolo notifica',\n"
              "  body: 'Lorem ipsum…',\n"
              ')\n'
              '// Annunciato come: «Titolo notifica. Lorem ipsum…»',
          child: SizedBox.shrink(),
        ),

        // ── Esempio ────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Esempio',
          description: 'La notifica può avere il solo titolo, oppure un titolo '
              "accompagnato da un'icona. Passando icon si ottiene la variante "
              'with-icon del kit: icona colorata secondo la variante e bordo '
              'di accento di quattro pixel sul lato sinistro.',
          code: "ItNotification(title: 'Titolo notifica')\n\n"
              'ItNotification(\n'
              "  title: 'Titolo notifica',\n"
              '  icon: BootstrapItaliaIcons.it_info_circle,\n'
              ')',
          child: _specimen(
            Wrap(
              spacing: BootstrapItaliaSpacing.space3,
              runSpacing: BootstrapItaliaSpacing.space3,
              children: const [
                ItNotification(title: 'Titolo notifica'),
                ItNotification(
                  title: 'Titolo notifica',
                  icon: BootstrapItaliaIcons.it_info_circle,
                ),
              ],
            ),
          ),
        ),

        // ── Notifica con messaggio ─────────────────────────────────────────
        ExampleSection(
          title: 'Notifica con messaggio',
          description:
              'Sotto il titolo si può aggiungere un breve testo. È una String '
              'e non un widget, a differenza degli altri corpi di questo '
              'pacchetto: il paragrafo della notifica ha un solo stile, e il '
              "widget deve poterlo unire al titolo per l'annuncio.",
          code: 'ItNotification(\n'
              "  title: 'Titolo notifica',\n"
              "  body: 'Lorem ipsum dolor sit amet…',\n"
              ')',
          child: _specimen(
            Wrap(
              spacing: BootstrapItaliaSpacing.space3,
              runSpacing: BootstrapItaliaSpacing.space3,
              children: const [
                ItNotification(title: 'Titolo notifica', body: _lorem),
                ItNotification(
                  title: 'Titolo notifica',
                  body: _lorem,
                  icon: BootstrapItaliaIcons.it_info_circle,
                ),
              ],
            ),
          ),
        ),

        // ── Eliminabili ────────────────────────────────────────────────────
        ExampleSection(
          title: 'Eliminabili',
          description:
              'Le notifiche eliminabili non scompaiono da sole: restano finché '
              'non si preme il pulsante di chiusura. È il comportamento '
              'predefinito qui — dismissible vale true e duration vale null — '
              "e non è una scelta estetica: una notifica che si toglie di "
              'mezzo a tempo impone un limite di lettura, cioè il criterio '
              'WCAG 2.2.1. Passare una duration trasferisce a chi chiama '
              "l'obbligo di verificare che l'informazione resti disponibile "
              'altrove.',
          code: 'ItNotification(\n'
              "  title: 'Titolo notifica',\n"
              "  body: 'Lorem ipsum dolor sit amet…',\n"
              '  dismissible: true, // predefinito\n'
              '  duration: null,    // predefinito: nessuna scadenza\n'
              ')',
          child: _specimen(
            Wrap(
              spacing: BootstrapItaliaSpacing.space3,
              runSpacing: BootstrapItaliaSpacing.space3,
              children: const [
                ItNotification(title: 'Titolo notifica', body: _lorem),
                ItNotification(
                  title: 'Titolo notifica',
                  body: _lorem,
                  icon: BootstrapItaliaIcons.it_check_circle,
                  variant: ItNotificationVariant.success,
                ),
              ],
            ),
          ),
        ),

        // ── Stati ──────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Stati',
          description:
              'Quattro varianti cambiano il colore del bordo e dell\'icona: '
              'success per le procedure andate a buon fine, danger per gli '
              'errori (la classe .error del kit), info per le informazioni '
              'generiche e warning per gli avvisi di precauzione. Da notare '
              'che info non usa il grigio informativo ma il blu primario: è '
              "quanto dichiara la regola .notification.with-icon.info, ed è "
              'una delle divergenze di Bootstrap Italia rispetto a Bootstrap 5.',
          code: 'ItNotification(\n'
              '  variant: ItNotificationVariant.success,\n'
              "  title: 'Titolo notifica',\n"
              '  icon: BootstrapItaliaIcons.it_check_circle,\n'
              ')',
          child: _specimen(
            Wrap(
              spacing: BootstrapItaliaSpacing.space3,
              runSpacing: BootstrapItaliaSpacing.space3,
              children: const [
                ItNotification(
                  variant: ItNotificationVariant.success,
                  title: 'Titolo notifica',
                  icon: BootstrapItaliaIcons.it_check_circle,
                ),
                ItNotification(
                  variant: ItNotificationVariant.danger,
                  title: 'Titolo notifica',
                  icon: BootstrapItaliaIcons.it_close_circle,
                ),
                ItNotification(
                  variant: ItNotificationVariant.info,
                  title: 'Titolo notifica',
                  icon: BootstrapItaliaIcons.it_info_circle,
                ),
                ItNotification(
                  variant: ItNotificationVariant.warning,
                  title: 'Titolo notifica',
                  icon: BootstrapItaliaIcons.it_warning_circle,
                ),
              ],
            ),
          ),
        ),

        // ── Posizione e arrotondamento degli angoli ────────────────────────
        ExampleSection(
          title: 'Posizione e arrotondamento degli angoli',
          description:
              'Le quattro posizioni fisse appoggiano la scheda contro un bordo '
              'della finestra e ne squadrano i due angoli che lo toccano. '
              'Nella variante leftFix il bordo di accento passa a destra, '
              "perché a sinistra c'è il margine della finestra. Le altre "
              'posizioni lasciano tutti e quattro gli angoli arrotondati.',
          code: 'ItNotification(\n'
              '  position: ItNotificationPosition.topFix,\n'
              "  title: 'Titolo notifica',\n"
              '  icon: BootstrapItaliaIcons.it_info_circle,\n'
              ')',
          child: _specimen(
            Wrap(
              spacing: BootstrapItaliaSpacing.space3,
              runSpacing: BootstrapItaliaSpacing.space3,
              children: const [
                ItNotification(
                  title: 'Basico',
                  icon: BootstrapItaliaIcons.it_info_circle,
                ),
                ItNotification(
                  position: ItNotificationPosition.topFix,
                  title: 'top-fix',
                  icon: BootstrapItaliaIcons.it_info_circle,
                ),
                ItNotification(
                  position: ItNotificationPosition.bottomFix,
                  title: 'bottom-fix',
                  icon: BootstrapItaliaIcons.it_info_circle,
                ),
                ItNotification(
                  position: ItNotificationPosition.leftFix,
                  title: 'left-fix',
                  icon: BootstrapItaliaIcons.it_info_circle,
                ),
                ItNotification(
                  position: ItNotificationPosition.rightFix,
                  title: 'right-fix',
                  icon: BootstrapItaliaIcons.it_info_circle,
                ),
              ],
            ),
          ),
        ),

        // ── Posizione predefinita ──────────────────────────────────────────
        ExampleSection(
          title: 'Posizione predefinita',
          description:
              'ItNotification.show mostra la notifica in sovrimpressione. '
              'Senza indicare una posizione la scheda compare in basso a '
              'destra, come da documentazione. Le altre cinque posizioni '
              "libere la staccano dai bordi di un margine, così che l'ombra "
              'resti visibile.',
          code: 'ItNotification.show(\n'
              '  context: context,\n'
              '  variant: ItNotificationVariant.info,\n'
              "  title: 'Titolo notifica',\n"
              "  body: 'Lorem ipsum dolor sit amet…',\n"
              '  icon: BootstrapItaliaIcons.it_info_circle,\n'
              ')',
          child: Builder(
            builder: (context) => Wrap(
              spacing: BootstrapItaliaSpacing.space2,
              runSpacing: BootstrapItaliaSpacing.space2,
              children: [
                for (final position in const [
                  ItNotificationPosition.bottomRight,
                  ItNotificationPosition.bottomLeft,
                  ItNotificationPosition.bottomCenter,
                  ItNotificationPosition.topRight,
                  ItNotificationPosition.topLeft,
                  ItNotificationPosition.topCenter,
                ])
                  ItButton(
                    size: ItButtonSize.small,
                    onPressed: () => ItNotification.show(
                      context: context,
                      variant: ItNotificationVariant.info,
                      title: 'Titolo notifica',
                      body: _lorem,
                      icon: BootstrapItaliaIcons.it_info_circle,
                      position: position,
                    ),
                    child: Text(position.name),
                  ),
              ],
            ),
          ),
        ),

        // ── Posizione fissa ────────────────────────────────────────────────
        ExampleSection(
          title: 'Posizione fissa',
          description: 'Le quattro posizioni fisse, questa volta davvero in '
              'sovrimpressione. La scheda si appoggia al bordo indicato senza '
              'margine né area sicura: aggiungere uno scarto vanificherebbe '
              'gli angoli squadrati che il modificatore esiste per ottenere.',
          code: 'ItNotification.show(\n'
              '  context: context,\n'
              "  title: 'Top fix',\n"
              '  position: ItNotificationPosition.topFix,\n'
              ')',
          child: Builder(
            builder: (context) => Wrap(
              spacing: BootstrapItaliaSpacing.space2,
              runSpacing: BootstrapItaliaSpacing.space2,
              children: [
                for (final (position, label) in const [
                  (ItNotificationPosition.topFix, 'Top fix'),
                  (ItNotificationPosition.bottomFix, 'Bottom fix'),
                  (ItNotificationPosition.leftFix, 'Left fix'),
                  (ItNotificationPosition.rightFix, 'Right fix'),
                ])
                  ItButton(
                    size: ItButtonSize.small,
                    onPressed: () => ItNotification.show(
                      context: context,
                      variant: ItNotificationVariant.info,
                      title: label,
                      body: _lorem,
                      icon: BootstrapItaliaIcons.it_info_circle,
                      position: position,
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
              'Attivazione tramite codice, con le sue tabelle di opzioni e '
              'metodi (show, hide, toggle, data-bs-timeout) — descrive il '
              'plugin JavaScript. Qui la notifica si mostra chiamando '
              'ItNotification.show, che restituisce la voce di overlay '
              'inserita: rimuoverla è il corrispettivo di hide.\n\n'
              'La nota sul comportamento su dispositivo mobile — dove il kit '
              "porta ogni notifica a piede della finestra e a tutta larghezza, "
              'ignorando le classi di posizione. Qui la larghezza è un '
              'parametro (width) e la posizione viene rispettata a ogni '
              "dimensione: imporre una regola di viewport dentro il widget "
              "gli toglierebbe la possibilità di essere usato in un pannello "
              'laterale o in una finestra ridotta.\n\n'
              'Gli esempi statici di questa pagina sono tenuti fuori '
              "dall'albero di accessibilità di proposito: sono immagini di "
              'notifiche, e nove regioni vive che si annunciano insieme '
              "all'apertura della pagina sarebbero il contrario di ciò che il "
              'componente serve a fare. Le due sezioni sulle posizioni ne '
              'mostrano una per volta, davvero.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
