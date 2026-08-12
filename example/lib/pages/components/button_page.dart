import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/buttons/
///
/// Section for section, in the docs' own order and with its headings. Two of the
/// sections needed new parameters on [ItButton] before they could be shown at
/// all — `onDark` for «Varianti colore su sfondo scuro` and `roundedIcon` for
/// «Pulsante con icona cerchiata» — and a third, «Utilizzo», needed `link`.
class ButtonPage extends StatelessWidget {
  const ButtonPage({super.key});

  /// The five variants the «Varianti di colore» matrix shows, in its order.
  static const _colourMatrix = <ItButtonVariant, String>{
    ItButtonVariant.primary: 'Primary',
    ItButtonVariant.secondary: 'Secondary',
    ItButtonVariant.success: 'Success',
    ItButtonVariant.danger: 'Danger',
    ItButtonVariant.warning: 'Warning',
  };

  /// `.bg-dark` — `rgba(var(--bs-dark-rgb), 1)`, i.e. `hsl(210, 54%, 20%)`.
  ///
  /// The band, not the button. `.bg-dark` is a utility applied to an ancestor;
  /// [ItButton.onDark] adapts to it but does not paint it.
  static const _bgDark = Color(0xFF17334F);

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Button',
      children: [
        // ── Utilizzo ───────────────────────────────────────────────────────
        ExampleSection(
          title: 'Utilizzo',
          description:
              'Il pulsante di base è ItButton con onPressed e un contenuto. '
              'Le varianti di stile, dimensione e colore sono parametri: '
              'variant, size, outline e link corrispondono alle classi .btn-*, '
              '.btn-outline-* e .btn-link. In HTML lo stesso aspetto si può '
              'applicare a <button>, <a> o <input>; in Flutter esiste un solo '
              'widget, e per questo annuncia sempre il ruolo «pulsante».',
          code: 'ItButton(\n'
              '  onPressed: () {},\n'
              "  child: Text('Etichetta pulsante'),\n"
              ')',
          child: ItButton(
            onPressed: () {},
            child: const Text('Etichetta pulsante'),
          ),
        ),

        ExampleSection(
          title: 'Utilizzo — le varianti di stile insieme',
          description:
              'Gli stessi cinque elementi della documentazione: link, pieno, '
              'due contorni e un pieno danger. Il pulsante link mantiene il '
              'riempimento vuoto ma non il rientro: .btn-link non tocca '
              'padding: 12px 24px, quindi resta un bersaglio grande come gli '
              'altri e non una riga di testo.',
          code:
              "ItButton(link: true, onPressed: () {}, child: Text('Pulsante link'))\n"
              'ItButton(\n'
              '  variant: ItButtonVariant.secondary,\n'
              '  onPressed: () {},\n'
              "  child: Text('Pulsante button'),\n"
              ')\n'
              'ItButton(\n'
              '  variant: ItButtonVariant.secondary,\n'
              '  outline: true,\n'
              '  onPressed: () {},\n'
              "  child: Text('Pulsante input'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              ItButton(
                link: true,
                onPressed: () {},
                child: const Text('Pulsante link'),
              ),
              ItButton(
                variant: ItButtonVariant.secondary,
                onPressed: () {},
                child: const Text('Pulsante button'),
              ),
              ItButton(
                variant: ItButtonVariant.secondary,
                outline: true,
                onPressed: () {},
                child: const Text('Pulsante input'),
              ),
              ItButton(
                variant: ItButtonVariant.success,
                outline: true,
                onPressed: () {},
                child: const Text('Pulsante submit'),
              ),
              ItButton(
                variant: ItButtonVariant.danger,
                onPressed: () {},
                child: const Text('Pulsante reset'),
              ),
            ],
          ),
        ),

        // ── Accessibilità ──────────────────────────────────────────────────
        const ExampleSection(
          title: 'Accessibilità',
          description:
              'In HTML le classi .btn danno a un <a> o a uno <span> l\'aspetto '
              'di un pulsante senza dargliene il significato, e la '
              'documentazione avverte che da lì nascono problemi complessi di '
              'accessibilità: dove il clic non porta a un\'altra pagina va '
              'usato <button>, altrimenti serve role="button".\n\n'
              'Questa classe di errori qui non è possibile: ItButton dichiara '
              'sempre Semantics(button: true) e non esiste un modo di ottenere '
              'il suo aspetto senza il suo ruolo. Il caso simmetrico invece '
              'esiste — un ItButton che naviga verso un\'altra schermata si '
              'annuncia come pulsante e non come link. Se il ruolo di link è '
              'quello corretto, va usato un controllo che lo dichiari.',
          child: SizedBox.shrink(),
        ),

        // ── Varianti di dimensione ─────────────────────────────────────────
        const ExampleSection(
          title: 'Varianti di dimensione',
          description:
              'La documentazione elenca .btn-lg, .btn-sm e .btn-xs sotto tre '
              'titoli — Large, Small e Mini — ma le rese distinte sono due più '
              'quella predefinita. Nella versione 2.18.0 .btn-sm ridichiara '
              'padding: 12px 24px e font-size: 1rem, cioè esattamente il '
              'pulsante di base, e un\'altra regola gli riporta il raggio a '
              '4px: Small e il valore predefinito sono lo stesso pulsante.\n\n'
              'ItButtonSize ha quindi tre valori e non quattro, e small è '
              '.btn-xs, il Mini della documentazione — l\'unico pulsante '
              'davvero più piccolo che il foglio di stile definisca.',
          child: SizedBox.shrink(),
        ),

        ExampleSection(
          title: 'Large',
          description: '.btn-lg — padding 16px 24px e font-size 1.125rem.',
          code: 'ItButton(\n'
              '  size: ItButtonSize.large,\n'
              '  onPressed: () {},\n'
              "  child: Text('Primary large'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              ItButton(
                size: ItButtonSize.large,
                onPressed: () {},
                child: const Text('Primary large'),
              ),
              ItButton(
                size: ItButtonSize.large,
                variant: ItButtonVariant.secondary,
                onPressed: () {},
                child: const Text('Secondary large'),
              ),
            ],
          ),
        ),

        ExampleSection(
          title: 'Small',
          description:
              'ItButtonSize.medium. Non è un ripiego: .btn-sm in questa '
              'versione del foglio di stile è il pulsante predefinito, quindi '
              'questa riga e la successiva della documentazione producono lo '
              'stesso rendering.',
          code: 'ItButton(\n'
              '  size: ItButtonSize.medium,\n'
              '  onPressed: () {},\n'
              "  child: Text('Primary small'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              ItButton(
                onPressed: () {},
                child: const Text('Primary small'),
              ),
              ItButton(
                variant: ItButtonVariant.secondary,
                onPressed: () {},
                child: const Text('Secondary small'),
              ),
            ],
          ),
        ),

        ExampleSection(
          title: 'Mini',
          description: '.btn-xs — padding 12px 16px e font-size 0.875rem. In '
              'ItButtonSize si chiama small.',
          code: 'ItButton(\n'
              '  size: ItButtonSize.small,\n'
              '  onPressed: () {},\n'
              "  child: Text('Primary mini'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              ItButton(
                size: ItButtonSize.small,
                onPressed: () {},
                child: const Text('Primary mini'),
              ),
              ItButton(
                size: ItButtonSize.small,
                variant: ItButtonVariant.secondary,
                onPressed: () {},
                child: const Text('Secondary mini'),
              ),
            ],
          ),
        ),

        // ── Larghezza fluida ───────────────────────────────────────────────
        ExampleSection(
          title: 'Larghezza fluida',
          description:
              'La documentazione ottiene i pulsanti a tutta larghezza con le '
              'utility .d-grid e .gap-2 invece del vecchio block button. In '
              'Flutter il contenitore è già una Column: block: true dà al '
              'singolo pulsante la larghezza disponibile, e la spaziatura la '
              'decide la Column.',
          code: 'Column(\n'
              '  crossAxisAlignment: CrossAxisAlignment.stretch,\n'
              '  children: [\n'
              "    ItButton(block: true, onPressed: () {}, child: Text('Primary')),\n"
              '    SizedBox(height: 8),\n'
              '    ItButton(\n'
              '      block: true,\n'
              '      variant: ItButtonVariant.secondary,\n'
              '      onPressed: () {},\n'
              "      child: Text('Secondary'),\n"
              '    ),\n'
              '  ],\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItButton(
                block: true,
                onPressed: () {},
                child: const Text('Primary'),
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space2),
              ItButton(
                block: true,
                variant: ItButtonVariant.secondary,
                onPressed: () {},
                child: const Text('Secondary'),
              ),
            ],
          ),
        ),

        ExampleSection(
          title: 'Larghezza fluida — variante responsive',
          description: 'La seconda variante della documentazione (.d-md-block) '
              'impila i pulsanti a tutta larghezza su mobile e li affianca dal '
              'breakpoint md in su. Qui lo fa ItResponsiveBuilder, che riceve '
              'il breakpoint corrente. Attenzione: il breakpoint è calcolato '
              'sulla larghezza disponibile al widget, non su quella della '
              'finestra, quindi dentro un riquadro stretto la resa è quella '
              'mobile anche su desktop.',
          code: 'ItResponsiveBuilder(\n'
              '  // < 768px: impilati e a tutta larghezza\n'
              '  xs: (context) => Column(\n'
              '    crossAxisAlignment: CrossAxisAlignment.stretch,\n'
              '    children: [...],\n'
              '  ),\n'
              '  // >= 768px: affiancati\n'
              '  md: (context) => Wrap(spacing: 8, children: [...]),\n'
              ')',
          child: ItResponsiveBuilder(
            xs: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ItButton(
                  block: true,
                  onPressed: () {},
                  child: const Text('Primary'),
                ),
                const SizedBox(height: BootstrapItaliaSpacing.space2),
                ItButton(
                  block: true,
                  variant: ItButtonVariant.secondary,
                  onPressed: () {},
                  child: const Text('Secondary'),
                ),
              ],
            ),
            md: (context) => Wrap(
              spacing: BootstrapItaliaSpacing.space2,
              runSpacing: BootstrapItaliaSpacing.space2,
              children: [
                ItButton(
                  onPressed: () {},
                  child: const Text('Primary'),
                ),
                ItButton(
                  variant: ItButtonVariant.secondary,
                  onPressed: () {},
                  child: const Text('Secondary'),
                ),
              ],
            ),
          ),
        ),

        // ── Varianti di colore ─────────────────────────────────────────────
        ExampleSection(
          title: 'Varianti di colore',
          description:
              'Per ogni variante: pieno, contorno, pieno disabilitato e '
              'contorno disabilitato, come nella matrice della '
              'documentazione. Il contorno è disegnato come box-shadow inset, '
              'che in CSS non occupa spazio: qui è un foregroundDecoration e '
              'non un border, altrimenti il pulsante con contorno sarebbe più '
              'grande di 2px per lato di quello pieno che deve affiancare.',
          code: 'ItButton(variant: v, onPressed: () {}, child: Text(...))\n'
              'ItButton(variant: v, outline: true, onPressed: () {}, child: ...)\n'
              'ItButton(variant: v, disabled: true, child: ...)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry in _colourMatrix.entries)
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: BootstrapItaliaSpacing.space3),
                  child: Wrap(
                    spacing: BootstrapItaliaSpacing.space2,
                    runSpacing: BootstrapItaliaSpacing.space2,
                    children: [
                      ItButton(
                        variant: entry.key,
                        onPressed: () {},
                        child: Text(entry.value),
                      ),
                      ItButton(
                        variant: entry.key,
                        outline: true,
                        onPressed: () {},
                        child: Text('${entry.value} outline'),
                      ),
                      ItButton(
                        variant: entry.key,
                        disabled: true,
                        child: Text('${entry.value} disabled'),
                      ),
                      ItButton(
                        variant: entry.key,
                        outline: true,
                        disabled: true,
                        child: Text('${entry.value} outline disabled'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // ── Varianti colore su sfondo scuro ────────────────────────────────
        ExampleSection(
          title: 'Varianti colore su sfondo scuro',
          description: 'onDark: true applica il trattamento .bg-dark. Non è un '
              'semplice scambio di primo piano: il primary pieno diventa un '
              'pulsante bianco con testo blu, e i contorni prendono anello ed '
              'etichetta bianchi. Il foglio di stile ridichiara solo primary e '
              'secondary — ogni altra variante su fondo scuro resta identica a '
              'com\'è su fondo chiaro, per omissione dichiarata.\n\n'
              'onDark non disegna lo sfondo: presuppone che ci sia già, come '
              '.bg-dark che è una utility applicata a un antenato.',
          code: 'ColoredBox(\n'
              '  color: Color(0xFF17334F), // .bg-dark\n'
              '  child: ItButton(\n'
              '    onDark: true,\n'
              '    onPressed: () {},\n'
              "    child: Text('Primary'),\n"
              '  ),\n'
              ')',
          child: Container(
            color: _bgDark,
            padding: const EdgeInsets.all(BootstrapItaliaSpacing.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final variant in [
                  ItButtonVariant.primary,
                  ItButtonVariant.secondary,
                ])
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: BootstrapItaliaSpacing.space2),
                    child: Wrap(
                      spacing: BootstrapItaliaSpacing.space2,
                      runSpacing: BootstrapItaliaSpacing.space2,
                      children: [
                        ItButton(
                          variant: variant,
                          onDark: true,
                          onPressed: () {},
                          child: Text(_colourMatrix[variant]!),
                        ),
                        ItButton(
                          variant: variant,
                          onDark: true,
                          outline: true,
                          onPressed: () {},
                          child: Text('${_colourMatrix[variant]!} outline'),
                        ),
                        ItButton(
                          variant: variant,
                          onDark: true,
                          disabled: true,
                          child: Text('${_colourMatrix[variant]!} disabled'),
                        ),
                        ItButton(
                          variant: variant,
                          onDark: true,
                          outline: true,
                          disabled: true,
                          child: Text(
                              '${_colourMatrix[variant]!} outline disabled'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Trasmettere significato alle tecnologie assistive ──────────────
        ExampleSection(
          title: 'Trasmettere significato alle tecnologie assistive',
          description:
              'Il colore è una indicazione solo visiva. Un pulsante danger e '
              'uno primary si annunciano allo stesso modo, quindi la gravità '
              'di un\'azione va detta nell\'etichetta — «Elimina '
              'definitivamente», non «Elimina» in rosso. Dove serve un testo '
              'aggiuntivo per il solo screen reader, la controparte di '
              '.visually-hidden è Semantics(label: …) attorno a un contenuto '
              'escluso.',
          code: 'ItButton(\n'
              '  variant: ItButtonVariant.danger,\n'
              '  onPressed: () {},\n'
              "  child: Text('Elimina definitivamente la domanda'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              ItButton(
                variant: ItButtonVariant.danger,
                onPressed: () {},
                child: const Text('Elimina definitivamente la domanda'),
              ),
            ],
          ),
        ),

        // ── Note sullo stato disabilitato ──────────────────────────────────
        ExampleSection(
          title: 'Note sullo stato disabilitato',
          description:
              'disabled: true riduce il riempimento al 65% (--bs-btn-disabled-'
              'opacity) e stacca onPressed. In HTML lo stato disabilitato di '
              'un <a> è un problema aperto — la documentazione dedica un '
              'paragrafo al fatto che .disabled usa pointer-events: none, che '
              'alcuni browser ignorano, e che la navigazione da tastiera resta '
              'comunque attiva, tanto da consigliare tabindex="-1".\n\n'
              'Qui quel problema non si presenta: senza onPressed il controllo '
              'esce dall\'ordine di tabulazione e non risponde né al puntatore '
              'né alla tastiera, e continua ad annunciarsi come disabilitato.',
          code: 'ItButton(\n'
              '  disabled: true,\n'
              "  child: Text('Pulsante disabilitato'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              const ItButton(
                disabled: true,
                child: Text('Pulsante disabilitato'),
              ),
              ItButton(
                onPressed: () {},
                child: const Text('Pulsante attivo, per confronto'),
              ),
            ],
          ),
        ),

        // ── Pulsante con icona ─────────────────────────────────────────────
        ExampleSection(
          title: 'Pulsante con icona',
          description:
              'icon mette il glifo prima dell\'etichetta, trailingIcon dopo. '
              'La dimensione segue quella del pulsante: 16, 20 e 24px per '
              'small, medium e large. Il glifo è decorativo — il nome '
              'accessibile resta l\'etichetta.',
          code: 'ItButton(\n'
              '  variant: ItButtonVariant.success,\n'
              '  size: ItButtonSize.large,\n'
              '  icon: BootstrapItaliaIcons.it_star_full,\n'
              '  onPressed: () {},\n'
              "  child: Text('Etichetta pulsante'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ItButton(
                variant: ItButtonVariant.success,
                size: ItButtonSize.large,
                trailingIcon: BootstrapItaliaIcons.it_star_full,
                onPressed: () {},
                child: const Text('Etichetta pulsante'),
              ),
              ItButton(
                trailingIcon: BootstrapItaliaIcons.it_star_full,
                onPressed: () {},
                child: const Text('Etichetta pulsante'),
              ),
              ItButton(
                variant: ItButtonVariant.danger,
                size: ItButtonSize.small,
                trailingIcon: BootstrapItaliaIcons.it_star_full,
                onPressed: () {},
                child: const Text('Etichetta pulsante'),
              ),
            ],
          ),
        ),

        // ── Allineamento e spaziatura dell'icona ───────────────────────────
        const ExampleSection(
          title: 'Allineamento e spaziatura dell’icona',
          description:
              'In HTML il testo del pulsante va racchiuso in uno <span> '
              'perché icona e testo si allineino e si distanzino '
              'correttamente. In Flutter non serve: icon e trailingIcon '
              'costruiscono già una Row con uno spazio di 8px, e '
              'l\'allineamento verticale è quello della Row. Passare un Text '
              'nudo come child è quindi corretto.',
          child: SizedBox.shrink(),
        ),

        // ── Pulsante con icona cerchiata ───────────────────────────────────
        ExampleSection(
          title: 'Pulsante con icona cerchiata',
          description: 'roundedIcon: true racchiude il glifo nel disco di '
              '.rounded-icon: 1.5em di lato, quindi 24px su un pulsante medio '
              'e 27px su uno grande, senza tabelle di dimensioni. Il disco è '
              'bianco e il glifo prende il colore della variante, come negli '
              'esempi della documentazione, dove un .btn-success porta una '
              '.icon-success. Entrambi si possono cambiare con '
              'roundedIconColor e roundedIconForegroundColor, i modificatori '
              '.rounded-* e .icon-*.',
          code: 'ItButton(\n'
              '  variant: ItButtonVariant.success,\n'
              '  size: ItButtonSize.large,\n'
              '  icon: BootstrapItaliaIcons.it_user,\n'
              '  roundedIcon: true,\n'
              '  onPressed: () {},\n'
              "  child: Text('Etichetta pulsante'),\n"
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ItButton(
                variant: ItButtonVariant.success,
                size: ItButtonSize.large,
                icon: BootstrapItaliaIcons.it_user,
                roundedIcon: true,
                onPressed: () {},
                child: const Text('Etichetta pulsante'),
              ),
              ItButton(
                icon: BootstrapItaliaIcons.it_user,
                roundedIcon: true,
                onPressed: () {},
                child: const Text('Etichetta pulsante'),
              ),
              ItButton(
                variant: ItButtonVariant.secondary,
                size: ItButtonSize.small,
                icon: BootstrapItaliaIcons.it_user,
                roundedIcon: true,
                onPressed: () {},
                child: const Text('Etichetta pulsante'),
              ),
            ],
          ),
        ),

        // Not a docs section: loading is this package's own addition.
        ExampleSection(
          title: 'Stato di caricamento (aggiunta di questo pacchetto)',
          description:
              'Non è una sezione della documentazione. loading: true sostituisce '
              'l\'icona iniziale con un indicatore e disattiva onPressed. '
              'L\'anello di sfondo del progress spinner qui è soppresso: dentro '
              'un pulsante pieno è il riempimento a fare da traccia, e un anello '
              'grigio sul blu sarebbe un colore che il design system non '
              'dichiara in questo punto.',
          code: 'ItButton(\n'
              '  loading: true,\n'
              '  onPressed: () {},\n'
              "  child: Text('Invio in corso'),\n"
              ')',
          child: ItButton(
            loading: true,
            onPressed: () {},
            child: const Text('Invio in corso'),
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description: 'Approfondimento — è un rimando alla pagina buttons di '
              'Bootstrap, non un esempio.\n\n'
              'Attivazione tramite codice e Metodi — riguardano '
              'l\'inizializzazione JavaScript del kit (new Button(element), '
              'toggle(), dispose(), getInstance()). In Flutter il widget è '
              'attivo appena costruito e non c\'è istanza da recuperare: lo '
              'stato si cambia ricostruendolo.\n\n'
              'Stato disabilitato su elemento link — è una avvertenza sui '
              'limiti di .disabled su un <a>, cioè su un problema del DOM. '
              'Il paragrafo che precede lo riprende e spiega perché qui non '
              'si presenta.\n\n'
              'Gli stati :hover, infine, sono implementati ma non mostrati '
              'come esempi: non hanno equivalente sui dispositivi tattili e '
              'non sono un parametro del componente. Vale la pena notare che '
              'su fondo scuro l\'anello di fuoco della documentazione si '
              'inverte (nero all\'interno, bianco all\'esterno) mentre qui '
              'resta quello chiaro: l\'anello è condiviso da tutti i controlli '
              'del pacchetto e non è ancora sensibile allo sfondo.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
