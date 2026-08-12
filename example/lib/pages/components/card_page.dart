import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/card/
///
/// The longest page in the component documentation, and the one where the gap
/// between the kit and this widget is widest: the card was redesigned in 2.16.0
/// into a family of a dozen named layouts (`.it-card-profile`,
/// `.it-card-inline-mini`, `.it-card-banner`, …), each with its own markup.
/// [ItCard] is one widget with slots, so the sections below reproduce the ones
/// its slots can express, and the closing section lists — by name — every one
/// they cannot, rather than leaving a reader to work out what is missing.
class CardPage extends StatelessWidget {
  const CardPage({super.key});

  static const _body =
      'Questo è un testo breve che riassume il contenuto della card e ne '
      'anticipa il senso.';

  /// A stand-in for the docs' photographic `<img>`, which would need a network
  /// fetch this catalogue does not make.
  static Widget _image({Color color = BootstrapItaliaColors.primary}) =>
      Container(
        height: 160,
        color: color,
        child: const Center(
          child: Icon(
            BootstrapItaliaIcons.it_camera,
            size: 48,
            color: BootstrapItaliaColors.white,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Card',
      children: [
        // ── Quick start ────────────────────────────────────────────────────
        ExampleSection(
          title: 'Quick start',
          description:
              'La card minima è un titolo e un corpo. Tutto il resto — '
              'immagine, categoria, data, firma, piede — sono slot opzionali, '
              'e la struttura HTML (.it-card, .it-card-body, .it-card-footer) '
              'è interna al widget.',
          code: 'ItCard(\n'
              "  title: 'Titolo del contenuto',\n"
              "  body: Text('…'),\n"
              ')',
          child: const ItCard(
            title: 'Titolo del contenuto',
            body: Text(_body),
          ),
        ),

        // ── Struttura base della card ──────────────────────────────────────
        ExampleSection(
          title: 'Struttura base della card',
          description:
              'La card completa: categoria e data nel piede, titolo, corpo. '
              'La categoria sta a sinistra e la data a destra, come '
              '.it-card-taxonomy e .it-card-date. Con onTap la card diventa un '
              'unico controllo: il titolo si rende come link e tutto il '
              'contenuto viene unito in un solo nodo semantico, perché una '
              'card cliccabile è un bersaglio, non cinque.',
          code: 'ItCard(\n'
              "  category: ItCardCategory(label: 'Categoria'),\n"
              "  title: 'Titolo del contenuto',\n"
              "  body: Text('…'),\n"
              "  date: '22 aprile 2025',\n"
              '  onTap: () {},\n'
              ')',
          child: ItCard(
            category: const ItCardCategory(label: 'Categoria'),
            title: 'Titolo del contenuto',
            body: const Text(_body),
            date: '22 aprile 2025',
            onTap: () {},
          ),
        ),

        // ── Accessibilità titoli ───────────────────────────────────────────
        ExampleSection(
          title: 'Accessibilità titoli',
          description:
              'Il titolo di una card è un titolo nella struttura della '
              'pagina, e ora lo dichiara: titleHeadingLevel vale 3 per '
              'impostazione predefinita e si porta al livello giusto per il '
              'punto in cui la card si trova. La dimensione del testo non lo '
              'segue, ed è voluto — la documentazione separa i due, che è a '
              'cosa servono le classi .h1…​.h6.\n\n'
              'Prima di questa revisione il titolo non aveva alcun ruolo di '
              'intestazione: una pagina di card era un blocco di testo piatto '
              'per chi naviga per titoli, e nessun controllo automatico lo '
              'segnala, perché non c\'è niente di sbagliato — manca e basta.',
          code: 'ItCard(\n'
              "  title: 'Titolo del contenuto',\n"
              '  titleHeadingLevel: 4, // sotto una sezione h3\n'
              "  body: Text('…'),\n"
              ')',
          child: const ItCard(
            title: 'Titolo del contenuto',
            titleHeadingLevel: 4,
            body: Text(_body),
          ),
        ),

        // ── Card editoriali standard ───────────────────────────────────────
        ExampleSection(
          title: 'Card editoriali standard',
          description: 'La card per un contenuto editoriale: immagine in cima, '
              'categoria e data nel piede. L\'immagine è un widget qualsiasi, '
              'quindi può essere una Image.network, un segnaposto come qui, o '
              'un carosello.',
          code: 'ItCard(\n'
              '  image: Image.network(...),\n'
              "  category: ItCardCategory(label: 'Notizie'),\n"
              "  title: 'Titolo del contenuto',\n"
              "  body: Text('…'),\n"
              "  date: '22 aprile 2025',\n"
              '  onTap: () {},\n'
              ')',
          child: ItCard(
            image: _image(),
            category: const ItCardCategory(label: 'Notizie'),
            title: 'Titolo del contenuto',
            body: const Text(_body),
            date: '22 aprile 2025',
            onTap: () {},
          ),
        ),

        // ── Card editoriali featured ───────────────────────────────────────
        ExampleSection(
          title: 'Card editoriali featured',
          description: 'La variante in evidenza aggiunge sottotitolo e firma: '
              'subtitle è .it-card-subtitle e signature è '
              '.it-card-signature, che il foglio di stile compone in Roboto '
              'Mono. La categoria qui è cliccabile e si rende come link, con '
              'ruolo e fuoco propri.',
          code: 'ItCard(\n'
              '  category: ItCardCategory(\n'
              "    label: 'Approfondimenti',\n"
              '    onTap: () {},\n'
              '  ),\n'
              "  title: 'Titolo contenuto featured',\n"
              "  subtitle: 'Un sottotitolo che estende il titolo',\n"
              "  body: Text('…'),\n"
              "  signature: 'di Maria Bianchi',\n"
              "  date: '22 aprile 2025',\n"
              ')',
          child: ItCard(
            category: ItCardCategory(label: 'Approfondimenti', onTap: () {}),
            title: 'Titolo contenuto featured',
            subtitle: 'Un sottotitolo che estende il titolo',
            body: const Text(_body),
            signature: 'di Maria Bianchi',
            date: '22 aprile 2025',
          ),
        ),

        // ── Accessibilità link per contenuti esterni ───────────────────────
        ExampleSection(
          title: 'Accessibilità link per contenuti esterni',
          description:
              'Quando una card porta fuori dal sito, la destinazione va detta '
              'nel nome accessibile e non solo nell\'icona. semanticLabel '
              'sostituisce il nome che la card comporrebbe dai suoi testi, ed '
              'è il posto dove aggiungere «link esterno» e la piattaforma.',
          code: 'ItCard(\n'
              "  title: 'Titolo contenuto featured',\n"
              '  titleIcon: BootstrapItaliaIcons.it_external_link,\n'
              "  semanticLabel: 'Titolo contenuto featured. "
              "Link esterno su Designers Italia.',\n"
              '  onTap: () {},\n'
              ')',
          child: ItCard(
            category: const ItCardCategory(label: 'Risorse'),
            title: 'Titolo contenuto featured',
            titleIcon: BootstrapItaliaIcons.it_external_link,
            body: const Text(_body),
            semanticLabel: 'Titolo contenuto featured. '
                'Link esterno su Designers Italia.',
            onTap: () {},
          ),
        ),

        // ── Card inline ────────────────────────────────────────────────────
        ExampleSection(
          title: 'Card inline',
          description:
              'horizontal: true mette l\'immagine a sinistra e il contenuto a '
              'destra, come .it-card-inline. La colonna dell\'immagine è '
              'larga 160px e il resto si adatta.',
          code: 'ItCard(\n'
              '  horizontal: true,\n'
              '  image: Image.network(...),\n'
              "  title: 'Titolo contenuto editoriale',\n"
              "  body: Text('…'),\n"
              "  date: '22 aprile 2025',\n"
              ')',
          child: ItCard(
            horizontal: true,
            image: _image(color: BootstrapItaliaColors.analogue2),
            category: const ItCardCategory(label: 'Notizie'),
            title: 'Titolo contenuto editoriale',
            body: const Text(_body),
            date: '22 aprile 2025',
            onTap: () {},
          ),
        ),

        // ── Card per eventi ────────────────────────────────────────────────
        ExampleSection(
          title: 'Card per eventi',
          description:
              'Una card per un evento è la card editoriale con la data che '
              'diventa la data dell\'evento. La documentazione dedica una '
              'sezione all\'accessibilità di date e orari: vanno scritti per '
              'esteso e non abbreviati, perché uno screen reader legge '
              '«22/04» come due numeri.',
          code: 'ItCard(\n'
              "  category: ItCardCategory(label: 'Incontri'),\n"
              "  title: 'Titolo evento',\n"
              "  body: Text('…'),\n"
              "  date: 'martedì 22 aprile 2025, ore 10:30',\n"
              '  onTap: () {},\n'
              ')',
          child: ItCard(
            category: const ItCardCategory(label: 'Incontri'),
            title: 'Titolo evento',
            body: const Text(
              'Presentazione pubblica del piano di rigenerazione urbana, con '
              'interventi dei progettisti e spazio per le domande.',
            ),
            date: 'martedì 22 aprile 2025, ore 10:30',
            onTap: () {},
          ),
        ),

        // ── Card per media (video, audio) ──────────────────────────────────
        ExampleSection(
          title: 'Card per media (video, audio)',
          description:
              'titleIcon segnala il tipo di contenuto. Sta in fondo alla riga '
              'del titolo e non davanti — .it-card-title-icon usa '
              'justify-content: space-between, e il rientro del contenitore è '
              'a sinistra del glifo. È l\'unico slot icona di questo pacchetto '
              'che segue invece di precedere.\n\n'
              'Il glifo però è decorativo e non raggiunge le tecnologie '
              'assistive: se dice «questo è un video», va detto anche nel '
              'testo, come qui nel corpo.',
          code: 'ItCard(\n'
              "  title: 'Titolo contenuto video',\n"
              '  titleIcon: BootstrapItaliaIcons.it_video,\n'
              "  body: Text('Tipo: Video. …'),\n"
              '  onTap: () {},\n'
              ')',
          child: Column(
            children: [
              ItCard(
                image: _image(color: BootstrapItaliaColors.dark),
                title: 'Titolo contenuto video',
                titleIcon: BootstrapItaliaIcons.it_video,
                body: const Text('Tipo: Video. Durata 4 minuti. $_body'),
                date: '22 aprile 2025',
                onTap: () {},
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space3),
              ItCard(
                title: 'Titolo contenuto audio',
                titleIcon: BootstrapItaliaIcons.it_file_audio,
                body: const Text('Tipo: Audio. Durata 12 minuti. $_body'),
                date: '22 aprile 2025',
                onTap: () {},
              ),
            ],
          ),
        ),

        // ── Card per servizi e bandi ───────────────────────────────────────
        ExampleSection(
          title: 'Card per servizi e bandi',
          description:
              'La card di servizio porta nel piede lo stato della pratica, '
              'che la documentazione rende con una chip colorata. Il piede '
              'accetta un widget qualsiasi, quindi la chip ci sta come '
              'qualunque altra cosa.',
          code: 'ItCard(\n'
              "  category: ItCardCategory(label: 'Bandi'),\n"
              "  title: 'Titolo del bando',\n"
              "  body: Text('…'),\n"
              '  footer: ItChip(\n'
              "    label: 'Aperto',\n"
              '    variant: ItChipVariant.success,\n'
              '  ),\n'
              ')',
          child: ItCard(
            category: const ItCardCategory(label: 'Bandi'),
            title: 'Titolo del bando',
            body: const Text(
              'Contributi per la riqualificazione energetica degli edifici '
              'residenziali. Scadenza per la presentazione: 30 giugno 2025.',
            ),
            footer: const ItChip(
              label: 'Aperto',
              variant: ItChipVariant.success,
            ),
            onTap: () {},
          ),
        ),

        // ── Card per documenti e allegati ──────────────────────────────────
        ExampleSection(
          title: 'Card per documenti e allegati',
          description:
              'Per un allegato, titleIcon indica il formato. Formato e peso '
              'vanno però anche nel testo: «Titolo del file allegato (Formato '
              'ODT, 200Kb)» è il titolo che usa la documentazione, e la '
              'parentesi non è decorativa — è quello che permette di sapere '
              'cosa si sta per scaricare prima di scaricarlo.',
          code: 'ItCard(\n'
              "  title: 'Titolo del file allegato (Formato ODT, 200Kb)',\n"
              '  titleIcon: BootstrapItaliaIcons.it_file_odt,\n'
              '  onTap: () {},\n'
              ')',
          child: ItCard(
            category: const ItCardCategory(label: 'Documenti'),
            title: 'Titolo del file allegato (Formato ODT, 200Kb)',
            titleIcon: BootstrapItaliaIcons.it_file_odt,
            body: const Text(_body),
            date: '22 aprile 2025',
            onTap: () {},
          ),
        ),

        // ── Bordi e ombre ──────────────────────────────────────────────────
        ExampleSection(
          title: 'Bordi e ombre',
          description: 'borderTopColor aggiunge la banda superiore di '
              '.it-card-border-top, spessa 6px. La documentazione la offre '
              'nelle varianti semantiche (.it-card-border-top-primary e '
              'compagnia): qui si passa direttamente il colore, quindi '
              'prenderlo dal tema è ciò che la fa seguire una '
              'personalizzazione.\n\n'
              'L\'ombra (.shadow-sm) è sempre presente e non è un parametro: '
              'la card del kit la porta sempre.',
          code: 'ItCard(\n'
              '  borderTopColor: BootstrapItaliaColors.success,\n'
              "  title: 'Titolo h3',\n"
              "  body: Text('…'),\n"
              ')',
          child: Column(
            children: [
              for (final color in const [
                BootstrapItaliaColors.primary,
                BootstrapItaliaColors.success,
                BootstrapItaliaColors.warning,
              ])
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: BootstrapItaliaSpacing.space3),
                  child: ItCard(
                    borderTopColor: color,
                    title: 'Titolo h3',
                    body: const Text(_body),
                  ),
                ),
            ],
          ),
        ),

        // ── Immagini ───────────────────────────────────────────────────────
        ExampleSection(
          title: 'Immagini',
          description:
              'Lo slot image accetta qualunque widget e la card lo ritaglia '
              'agli angoli arrotondati. Il rapporto di forma è a carico di chi '
              'lo passa: AspectRatio dove la documentazione usa le utility '
              '.img-fluid e le proporzioni fisse. Il testo alternativo di una '
              'immagine informativa si dà con Semantics(label: …).',
          code: 'ItCard(\n'
              '  image: AspectRatio(\n'
              '    aspectRatio: 16 / 9,\n'
              '    child: Image.network(..., fit: BoxFit.cover),\n'
              '  ),\n'
              "  title: 'Titolo del contenuto',\n"
              ')',
          child: ItCard(
            image: AspectRatio(
              aspectRatio: 16 / 9,
              child: _image(color: BootstrapItaliaColors.analogue1),
            ),
            title: 'Titolo del contenuto',
            body: const Text(_body),
          ),
        ),

        // ── Altezze delle card ─────────────────────────────────────────────
        ExampleSection(
          title: 'Altezze delle card',
          description:
              'Due card affiancate con testi di lunghezza diversa hanno '
              'altezze diverse. La documentazione le pareggia con .h-100; qui '
              'lo fa IntrinsicHeight su una Row, che dà a entrambe l\'altezza '
              'della più alta. Su liste lunghe conviene invece una griglia con '
              'childAspectRatio, perché IntrinsicHeight misura due volte ogni '
              'figlio.',
          code: 'IntrinsicHeight(\n'
              '  child: Row(\n'
              '    crossAxisAlignment: CrossAxisAlignment.stretch,\n'
              '    children: [\n'
              "      Expanded(child: ItCard(title: 'Breve', body: ...)),\n"
              '      SizedBox(width: 16),\n'
              "      Expanded(child: ItCard(title: 'Lungo', body: ...)),\n"
              '    ],\n'
              '  ),\n'
              ')',
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(
                  child: ItCard(
                    title: 'Titolo breve',
                    body: Text('Poche parole.'),
                  ),
                ),
                const SizedBox(width: BootstrapItaliaSpacing.space3),
                Expanded(
                  child: ItCard(
                    title: 'Titolo del contenuto',
                    body: const Text('$_body $_body'),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Uso della griglia ──────────────────────────────────────────────
        ExampleSection(
          title: 'Uso della griglia',
          description:
              'La documentazione dispone le card con la griglia a 12 colonne '
              'di Bootstrap. Questo pacchetto non la porta: la disposizione è '
              'quella nativa di Flutter, quindi ItResponsiveBuilder decide '
              'quante colonne stanno nello spazio disponibile. Da notare che '
              'il breakpoint qui è calcolato sulla larghezza data al widget e '
              'non sulla finestra, quindi una colonna stretta si comporta '
              'come uno schermo stretto.',
          code: 'ItResponsiveBuilder(\n'
              '  xs: (context) => Column(children: cards),\n'
              '  md: (context) => Row(\n'
              '    crossAxisAlignment: CrossAxisAlignment.stretch,\n'
              '    children: [for (final c in cards) Expanded(child: c)],\n'
              '  ),\n'
              ')',
          child: ItResponsiveBuilder(
            xs: (context) => Column(
              children: [
                for (final n in const ['Primo', 'Secondo'])
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: BootstrapItaliaSpacing.space3),
                    child: ItCard(
                      title: '$n risultato',
                      body: const Text(_body),
                      onTap: () {},
                    ),
                  ),
              ],
            ),
            md: (context) => IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ItCard(
                      title: 'Primo risultato',
                      body: const Text(_body),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: BootstrapItaliaSpacing.space3),
                  Expanded(
                    child: ItCard(
                      title: 'Secondo risultato',
                      body: const Text(_body),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Liste per gruppi numerosi di card ──────────────────────────────
        ExampleSection(
          title: 'Liste per gruppi numerosi di card',
          description:
              'Per un elenco di risultati la documentazione racchiude le card '
              'in una <ul>, così che uno screen reader annunci quante sono. '
              'La controparte Flutter è un Semantics con container e un nome '
              'che dice il conteggio, attorno alla colonna: senza, le card '
              'sono una fila di controlli senza inizio né fine.',
          code: 'Semantics(\n'
              '  container: true,\n'
              "  label: '3 risultati',\n"
              '  child: Column(children: cards),\n'
              ')',
          child: Semantics(
            container: true,
            label: '3 risultati',
            child: Column(
              children: [
                for (final n in const ['Primo', 'Secondo', 'Terzo'])
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: BootstrapItaliaSpacing.space3),
                    child: ItCard(
                      title: '$n risultato',
                      titleHeadingLevel: 3,
                      body: const Text(_body),
                      date: '22 aprile 2025',
                      onTap: () {},
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Gerarchia dei titoli ───────────────────────────────────────────
        ExampleSection(
          title: 'Gerarchia dei titoli',
          description:
              'Il livello dipende da dove sta la card, non da che cosa sia '
              'una card. Sotto una sezione h2 le card vogliono h3; dentro una '
              'sottosezione h3, h4. La stessa card qui compare due volte a '
              'livelli diversi e ha esattamente lo stesso aspetto: la '
              'dimensione non segue il livello.',
          code: 'ItCard(title: ..., titleHeadingLevel: 3)  // sotto un h2\n'
              'ItCard(title: ..., titleHeadingLevel: 4)  // sotto un h3',
          child: Column(
            children: [
              const ItCard(
                title: 'Card a livello 3',
                titleHeadingLevel: 3,
                body: Text(_body),
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space3),
              const ItCard(
                title: 'Card a livello 4',
                titleHeadingLevel: 4,
                body: Text(_body),
              ),
            ],
          ),
        ),

        // ── Contrasto e visibilità ─────────────────────────────────────────
        ExampleSection(
          title: 'Contrasto e visibilità',
          description:
              'I colori della card sono quelli del design system e superano '
              'la soglia AA. Le due parti che vale la pena conoscere: il '
              'titolo di una card cliccabile è il colore primario e segue il '
              'tema, mentre categoria e data restano '
              'hsl(210, 17%, 44%) e non lo seguono. Quel valore è dichiarato '
              'sia come secondary sia come gray-secondary, e su un metadato è '
              'il grigio a essere inteso: chi ritinge secondary di viola vuole '
              'i pulsanti viola, non le date di pubblicazione.',
          code: 'BootstrapItaliaTheme(\n'
              '  data: BootstrapItaliaThemeData(\n'
              '    colors: BootstrapItaliaColorScheme.standard\n'
              '        .copyWith(primary: Color(0xFF7A1FA2)),\n'
              '  ),\n'
              '  child: ItCard(title: ..., onTap: () {}),\n'
              ')',
          child: BootstrapItaliaTheme(
            data: BootstrapItaliaThemeData(
              colors: BootstrapItaliaColorScheme.standard
                  .copyWith(primary: const Color(0xFF7A1FA2)),
            ),
            child: ItCard(
              category: const ItCardCategory(label: 'Categoria'),
              title: 'Titolo del contenuto',
              body: const Text(_body),
              date: '22 aprile 2025',
              onTap: () {},
            ),
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description: 'Questa è la pagina con il divario più ampio fra la '
              'documentazione e il widget, e vale la pena essere espliciti sul '
              'perché. Dalla versione 2.16.0 la card non è più un componente '
              'ma una famiglia: ogni layout ha il proprio markup e le proprie '
              'classi. ItCard è invece un widget con slot, quindi riproduce i '
              'layout che i suoi slot sanno comporre.\n\n'
              'Layout non riproducibili con gli slot attuali, per nome: '
              'Card inline mini (.it-card-inline-mini), Card per profili '
              'personali (.it-card-profile, che richiede un componente avatar '
              'che questo pacchetto non fornisce), Card per luoghi '
              '(.it-card-description-list), Card con liste di contenuti '
              'affini (.list-group), Card banner e Card banner inline '
              '(.it-card-banner, centrata e con icona sopra il titolo). '
              'Ognuno richiede un parametro nuovo o un widget nuovo, non una '
              'combinazione diversa di quelli esistenti.\n\n'
              'Organizzazione e layout — Uso di contenitori responsive, Uso '
              'di classi dedicate, Numero di colonne specifiche, Uso di '
              'classi rispetto al contenitore (sperimentale, con le container '
              'queries): sono tutte tecniche di griglia CSS. Questo pacchetto '
              'non porta la griglia a 12 colonne, per scelta: il layout è '
              'quello nativo di Flutter. Le due sezioni riprodotte sopra '
              'mostrano come si ottiene lo stesso risultato.\n\n'
              'Pulsanti a tutta larghezza su mobile — è la stessa tecnica '
              'della sezione «Larghezza fluida» della pagina Button, applicata '
              'dentro una card.\n\n'
              'Funzionalità future e Breaking change dalla versione 2.16.0 — '
              'sono note di roadmap e di migrazione del markup HTML.\n\n'
              'Test e validazione — descrive come verificare '
              'l\'accessibilità con strumenti per il web. L\'equivalente qui '
              'sono i contratti in test/a11y/, ed è una differenza che conta: '
              'una revisione precedente di questo pacchetto ha distrutto la '
              'semantica di alcuni controlli senza che axe-core se ne '
              'accorgesse.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
