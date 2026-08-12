import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/callout/
///
/// Section for section, in the docs' own order and with its headings. Two of the
/// page's three H2 examples — «Callout Highlights» and «Callout Approfondimento»
/// — needed a new [ItCalloutStyle] before they could be shown at all, and the
/// danger variant's glyph was corrected against the markup the docs publish.
class CalloutPage extends StatelessWidget {
  const CalloutPage({super.key});

  static const _lorem =
      'Maecenas vulputate ante dictum vestibulum volutpat. Lorem ipsum dolor '
      'sit amet, consectetur adipiscing elit. Aenean non augue non purus '
      'vestibulum varius.';

  static const _lorem2 =
      'Quisque ex eros, pellentesque vitae enim sed, pharetra tempus dolor. '
      'Donec eu nibh ac lacus luctus pellentesque. Duis interdum scelerisque '
      'magna nec malesuada.';

  /// The five coloured variants, with the title each one carries in the docs.
  static const _variants = <ItCalloutVariant, (String, String)>{
    ItCalloutVariant.success: ('Titolo di conferma', 'success'),
    ItCalloutVariant.warning: ('Titolo di attenzione', 'warning'),
    ItCalloutVariant.danger: ('Titolo di allerta', 'danger'),
    ItCalloutVariant.important: ('Importante', 'important'),
    ItCalloutVariant.note: ('Note a riguardo', 'note'),
  };

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Callout',
      children: [
        // ── Esempi ─────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Esempi',
          description:
              'Il callout di base è un riquadro con bordo di 2px, un titolo '
              'in maiuscolo con la sua icona e il testo. In HTML si compone di '
              '.callout, .callout-inner e .callout-title; qui i tre livelli '
              'sono interni al widget e si passano solo title e body.',
          code: 'ItCallout(\n'
              "  title: 'Titolo callout',\n"
              "  body: Text('…'),\n"
              ')',
          child: const ItCallout(
            title: 'Titolo callout',
            body: Text(_lorem),
          ),
        ),

        // ── Accessibilità (h4 sotto Esempi) ────────────────────────────────
        ExampleSection(
          title: 'Accessibilità',
          description:
              "L'icona del titolo è decorativa e va nascosta agli screen "
              'reader: qui lo è già, perché ripete quello che dicono il titolo '
              'e il colore. Quando invece comunica visivamente qualcosa che '
              'nel testo non c\'è — un allarme, una conferma — la '
              'documentazione chiede di affiancarle un testo riservato agli '
              'screen reader. Il corrispettivo di <span class="visually-'
              'hidden"> è un Semantics con label attorno a un contenuto '
              'escluso.',
          code: 'Semantics(\n'
              "  label: 'Confermato.',\n"
              '  child: ExcludeSemantics(\n'
              '    child: ItCallout(\n'
              '      variant: ItCalloutVariant.success,\n'
              "      title: 'Titolo callout',\n"
              "      body: Text('…'),\n"
              '    ),\n'
              '  ),\n'
              ')\n\n'
              '// Meglio ancora: dire «Confermato» nel testo,\n'
              '// così lo legge chiunque.',
          child: const ItCallout(
            variant: ItCalloutVariant.success,
            title: 'Domanda confermata',
            body: Text(
              'La domanda è stata registrata con il numero 2025/00184. '
              'Non sono necessarie ulteriori azioni.',
            ),
          ),
        ),

        // ── Callout Success / Warning / Danger / Important / Note ──────────
        for (final entry in _variants.entries)
          ExampleSection(
            title: 'Callout ${_capitalise(entry.value.$2)}',
            description: _variantDescription(entry.key),
            code: 'ItCallout(\n'
                '  variant: ItCalloutVariant.${entry.value.$2},\n'
                "  title: '${entry.value.$1}',\n"
                "  body: Text('…'),\n"
                ')',
            child: ItCallout(
              variant: entry.key,
              title: entry.value.$1,
              body: Text(
                entry.key == ItCalloutVariant.success ? _lorem : _lorem2,
              ),
            ),
          ),

        // ── Callout Highlights ─────────────────────────────────────────────
        ExampleSection(
          title: 'Callout Highlights',
          description:
              'ItCalloutStyle.highlight sostituisce il riquadro con una riga '
              'verticale sul solo lato sinistro. Cambia anche la struttura: '
              'la variante highlight non ha .callout-inner, quindi bordo e '
              'rientro passano sul contenitore esterno e il rientro verticale '
              'sparisce — il testo comincia in cima alla riga.',
          code: 'ItCallout(\n'
              '  style: ItCalloutStyle.highlight,\n'
              "  title: 'Titolo callout',\n"
              "  body: Text('…'),\n"
              ')',
          child: const ItCallout(
            style: ItCalloutStyle.highlight,
            title: 'Titolo callout',
            showIcon: false,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // `.callout p.callout-big-text { font-size: 1.125rem }` — che
                // è già la dimensione di `.callout p`. Nella 2.18.0 la classe
                // non cambia nulla, e per questo qui non c'è un parametro.
                Text(
                  'Maecenas at erat id sem interdum efficitur eu sed nunc. '
                  'Mauris sit amet erat eget augue molestie malesuada ut sed '
                  'ex. In sed dignissim elit.',
                ),
                SizedBox(height: BootstrapItaliaSpacing.space3),
                Text(_lorem),
              ],
            ),
          ),
        ),

        ExampleSection(
          title: 'Highlight — le varianti di colore',
          description:
              'Le sottosezioni Highlight Success, Warning, Danger, Important e '
              'Note della documentazione sono la stessa combinazione: lo stile '
              'highlight più la variante. Sono raccolte qui invece che in '
              'cinque sezioni separate, perché la sola differenza è il colore '
              'e la si legge meglio in fila.',
          code: 'ItCallout(\n'
              '  style: ItCalloutStyle.highlight,\n'
              '  variant: ItCalloutVariant.success,\n'
              "  title: 'Titolo di conferma',\n"
              "  body: Text('…'),\n"
              ')',
          child: Column(
            children: [
              for (final entry in _variants.entries)
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: BootstrapItaliaSpacing.space4),
                  child: ItCallout(
                    style: ItCalloutStyle.highlight,
                    variant: entry.key,
                    title: entry.value.$1,
                    body: const Text(_lorem2),
                  ),
                ),
            ],
          ),
        ),

        // ── Callout Approfondimento ────────────────────────────────────────
        ExampleSection(
          title: 'Callout Approfondimento',
          description:
              'ItCalloutStyle.more è la variante per testi lunghi: sfondo '
              'crema, nessun bordo, angolo piegato in alto a destra e titolo '
              'sottolineato invece che in maiuscolo. Il corpo scende a 16px di '
              'carattere senza grazie: lo stile esiste proprio per allontanarsi '
              'dal Lora a 18px degli altri due.\n\n'
              'La sua apertura sta in fondo, non sul titolo: moreContent '
              'aggiunge il pulsante «Leggi tutto» sotto una riga di '
              'separazione, con accanto un eventuale link di download.',
          code: 'ItCallout(\n'
              '  style: ItCalloutStyle.more,\n'
              '  variant: ItCalloutVariant.note,\n'
              "  title: 'Approfondimento',\n"
              "  body: Text('…'),\n"
              "  moreContent: Text('…'),\n"
              "  downloadLabel: 'Scarica la scheda in PDF, 200Kb',\n"
              '  onDownload: () {},\n'
              ')',
          child: ItCallout(
            style: ItCalloutStyle.more,
            variant: ItCalloutVariant.note,
            title: 'Approfondimento',
            body: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Quisque suscipit interdum augue non volutpat. Cras '
                  'tristique arcu tortor. Mauris eu magna nibh. Curabitur '
                  'malesuada neque in lectus sagittis accumsan. In vitae justo '
                  'eros.',
                ),
                SizedBox(height: BootstrapItaliaSpacing.space3),
                Text(_lorem),
              ],
            ),
            moreContent: const Text(
              'Aenean tortor enim, suscipit eget commodo at, imperdiet quis '
              'diam. Vestibulum non accumsan felis, at ultrices lorem. '
              'Pellentesque ac diam a ipsum cursus interdum id nec odio. '
              'Vestibulum nec congue mauris. Aliquam et dui purus.',
            ),
            downloadLabel: 'Scarica la scheda in PDF, 200Kb',
            onDownload: () {},
          ),
        ),

        // Not a docs section, but the parameter predates this page and a reader
        // will meet it in the API.
        ExampleSection(
          title: 'collapsible (aggiunta di questo pacchetto)',
          description:
              'Non è una sezione della documentazione, e non va confusa con '
              'Approfondimento: collapsible: true rende il titolo stesso un '
              'pulsante che chiude tutto il corpo, mentre «Leggi tutto» apre '
              'un contenuto aggiuntivo in fondo. Il primo esiste da prima di '
              'questa revisione ed è mantenuto; per riprodurre la '
              'documentazione si usa il secondo.',
          code: 'ItCallout(\n'
              '  collapsible: true,\n'
              '  initiallyExpanded: false,\n'
              "  title: 'Dettagli aggiuntivi',\n"
              "  body: Text('…'),\n"
              ')',
          child: const ItCallout(
            variant: ItCalloutVariant.note,
            title: 'Dettagli aggiuntivi',
            collapsible: true,
            initiallyExpanded: false,
            body: Text(_lorem2),
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Breaking change dalla versione 2.4.0 — dice che .callout deve '
              'contenere un .callout-inner. È una nota di migrazione del '
              'markup HTML: qui la struttura è interna al widget e chi lo usa '
              'non la scrive, quindi non c\'è nulla da migrare.\n\n'
              '.callout-big-text — la classe esiste ed è mostrata negli '
              'esempi Highlight, ma nella 2.18.0 vale font-size: 1.125rem, '
              'che è già la dimensione di .callout p. Non cambia nulla, e per '
              'questo non è diventata un parametro: sarebbe stato un\'opzione '
              'senza effetto.\n\n'
              'Va segnalata infine una correzione, non un\'omissione: l\'icona '
              'della variante danger era it-error, l\'esclamativo in un '
              'ottagono. Il markup della documentazione usa it-close-circle. '
              'it-error resta corretto per l\'alert danger, il cui SVG in linea '
              'corrisponde esattamente a quell\'ottagono — stessa parola, due '
              'glifi diversi.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  static String _capitalise(String s) => s[0].toUpperCase() + s.substring(1);

  static String _variantDescription(ItCalloutVariant variant) =>
      switch (variant) {
        ItCalloutVariant.success =>
          'Indica una procedura andata a buon fine. Icona it-check-circle.',
        ItCalloutVariant.warning =>
          "Indica una procedura o un testo che richiede l'attenzione "
              "dell'utente. Icona it-help-circle — non il cerchio con "
              "l'esclamativo che usa l'alert warning.",
        ItCalloutVariant.danger =>
          'Indica un errore o una procedura pericolosa o non consentita. '
              'Icona it-close-circle.',
        ItCalloutVariant.important =>
          "Attira ulteriormente l'attenzione. Usa il verde di success: nel "
              'foglio di stile .important e .success hanno lo stesso colore.',
        ItCalloutVariant.note =>
          'Caratterizza il callout come una nota. Usa il colore primario, '
              'quindi segue il tema di una amministrazione che lo '
              'personalizza.',
        ItCalloutVariant.neutral => '',
      };
}
