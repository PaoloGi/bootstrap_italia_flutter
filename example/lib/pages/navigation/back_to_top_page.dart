import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/menu-di-navigazione/torna-su/
///
/// The one page in the catalogue that does not use `ComponentPage`. The
/// component's whole behaviour is "appear once the page has scrolled", so it
/// needs the page's own `ScrollController` and a `Stack` to float in —
/// `ComponentPage` owns its scroll view and exposes neither. The docs page has
/// exactly the same problem and solves it the same way: its live example is the
/// documentation page itself, and every other variant is shown inline.
class BackToTopPage extends StatefulWidget {
  /// Creates the back-to-top catalogue page.
  const BackToTopPage({super.key});

  @override
  State<BackToTopPage> createState() => _BackToTopPageState();
}

class _BackToTopPageState extends State<BackToTopPage> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Torna su')),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _controller,
            padding: const EdgeInsets.all(BootstrapItaliaSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Esempio ────────────────────────────────────────────────
                const ExampleSection(
                  title: 'Esempio',
                  description:
                      'Il pulsante consente di risalire agevolmente alla parte '
                      'superiore della pagina. Compare da solo dopo che si è '
                      'scorso oltre showAfter e si posiziona in basso a destra, '
                      'a 16 pixel dai bordi e a 32 dal breakpoint xl in su. '
                      'Per vederlo, scorrere questa pagina: come nella '
                      'documentazione, è visibile solo a scorrimento avvenuto.',
                  code: 'Stack(\n'
                      '  children: [\n'
                      '    SingleChildScrollView(controller: controller, ...),\n'
                      '    ItBackToTop(scrollController: controller),\n'
                      '  ],\n'
                      ')',
                  child: _Hint(),
                ),

                // ── Versione ridotta ───────────────────────────────────────
                ExampleSection(
                  title: 'Versione ridotta',
                  description:
                      'Il parametro small corrisponde alla classe '
                      '.back-to-top-small e fissa il cerchio a 40 pixel a '
                      'ogni breakpoint, invece dei 56 che la versione normale '
                      'assume da md in su. Anche la freccia si riduce di '
                      'conseguenza, da 32 a 24 pixel.',
                  code: 'ItBackToTopButton(small: true, onPressed: () {})',
                  child: _Row(children: [
                    ItBackToTopButton(onPressed: () {}),
                    ItBackToTopButton(small: true, onPressed: () {}),
                  ]),
                ),

                // ── Versione con ombra ─────────────────────────────────────
                ExampleSection(
                  title: 'Versione con ombra',
                  description:
                      'Il parametro shadow aggiunge l\'ombra .shadow di '
                      'Bootstrap: 0 .5rem 1rem rgba(0,0,0,.15). Si combina con '
                      'entrambe le dimensioni.',
                  code: 'ItBackToTopButton(shadow: true, onPressed: () {})\n'
                      'ItBackToTopButton(shadow: true, small: true, '
                      'onPressed: () {})',
                  child: _Row(children: [
                    ItBackToTopButton(shadow: true, onPressed: () {}),
                    ItBackToTopButton(
                      shadow: true,
                      small: true,
                      onPressed: () {},
                    ),
                  ]),
                ),

                // ── Versione per sfondo scuro ──────────────────────────────
                ExampleSection(
                  title: 'Versione per sfondo scuro',
                  description:
                      'Il parametro dark inverte il controllo: cerchio bianco '
                      'e freccia hsl(210,25%,35.2%). Il bianco qui non è un '
                      'colore di accento ma la carta su cui sta la freccia, '
                      'quindi resta bianco anche con un tema diverso — mentre '
                      'la versione normale, il cui cerchio è #06c, segue '
                      'primary.',
                  code: 'ItBackToTopButton(dark: true, onPressed: () {})',
                  child: _DarkRow(children: [
                    ItBackToTopButton(dark: true, onPressed: () {}),
                    ItBackToTopButton(
                      dark: true,
                      small: true,
                      onPressed: () {},
                    ),
                  ]),
                ),

                // ── Ombra su sfondo scuro ──────────────────────────────────
                ExampleSection(
                  title: 'Ombra su sfondo scuro',
                  description:
                      'Le due varianti si combinano, come nella '
                      'documentazione.',
                  code: 'ItBackToTopButton(dark: true, shadow: true, '
                      'onPressed: () {})',
                  child: _DarkRow(children: [
                    ItBackToTopButton(
                      dark: true,
                      shadow: true,
                      onPressed: () {},
                    ),
                    ItBackToTopButton(
                      dark: true,
                      shadow: true,
                      small: true,
                      onPressed: () {},
                    ),
                  ]),
                ),

                // Not a docs section: the theme claim above, shown.
                ExampleSection(
                  title: 'Con tema personalizzato',
                  description:
                      'Lo stesso pulsante sotto uno schema colori diverso. '
                      'Nessun parametro è cambiato: il cerchio è il token '
                      "primary, quindi un'amministrazione che lo ridefinisce "
                      'ottiene il proprio colore invece del Blu Italia. La '
                      'variante scura non si muove, perché il suo bianco non è '
                      'un accento.',
                  code: 'BootstrapItaliaTheme(\n'
                      '  data: BootstrapItaliaThemeData(\n'
                      '    colors: BootstrapItaliaColorScheme.standard\n'
                      "        .copyWith(primary: Color(0xFF7A1FA2)),\n"
                      '  ),\n'
                      '  child: ItBackToTopButton(onPressed: () {}),\n'
                      ')',
                  child: BootstrapItaliaTheme(
                    data: BootstrapItaliaThemeData(
                      colors: BootstrapItaliaColorScheme.standard
                          .copyWith(primary: const Color(0xFF7A1FA2)),
                    ),
                    child: _Row(children: [
                      ItBackToTopButton(onPressed: () {}),
                      ItBackToTopButton(shadow: true, small: true,
                          onPressed: () {}),
                    ]),
                  ),
                ),

                // ── What is deliberately absent ────────────────────────────
                const ExampleSection(
                  title: 'Sezioni della documentazione non riprodotte',
                  description:
                      'Attivazione tramite codice e Metodi — riguardano '
                      "l'inizializzazione JavaScript del plugin BackToTop e i "
                      'suoi metodi show(), hide() e scrollToTop(). In Flutter '
                      'non esiste un passaggio di inizializzazione: il widget è '
                      'attivo appena costruito, si mostra e si nasconde da solo '
                      'osservando lo ScrollController, e scrollToTop() è il '
                      'controller stesso. La sezione non descrive alcun '
                      'comportamento da tastiera, quindi non resta nulla da '
                      'implementare — il pulsante è comunque raggiungibile con '
                      'Tab e attivabile con Invio e Spazio.\n\n'
                      'Opzioni — la tabella elenca positionTop (0), scrollLimit '
                      '(100), duration (800) ed easing (easeInOutSine). Tre '
                      'sono qui: scrollLimit è showAfter, duration è '
                      'scrollDuration, easing è scrollCurve, il cui valore '
                      'predefinito è ora esattamente Curves.easeInOutSine. Due '
                      'differenze restano dichiarate: showAfter vale 200 e non '
                      '100, e scrollDuration 500 millisecondi e non 800 — '
                      'valori storici di questo pacchetto, che un passaggio di '
                      'parità documentale non è il posto giusto per cambiare, '
                      "visto che cambierebbero il comportamento di chi l'ha già "
                      'adottato. positionTop non ha equivalente: si torna '
                      'sempre a zero.\n\n'
                      'Breaking change dalla versione 2.12.0 — chiede di '
                      'togliere tabindex="-1" e aria-hidden="true" e di '
                      'aggiungere aria-label="Torna su". È già così: il '
                      'controllo è un pulsante con nome accessibile, '
                      'localizzato in italiano, tedesco e francese.',
                  child: SizedBox.shrink(),
                ),

                // Enough height to make the live example above reachable even
                // on a tall window.
                const SizedBox(height: 600),
              ],
            ),
          ),
          ItBackToTop(scrollController: _controller),
        ],
      ),
    );
  }
}

/// Lays several buttons out side by side, as the docs' inline examples do.
class _Row extends StatelessWidget {
  const _Row({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: BootstrapItaliaSpacing.space3,
      runSpacing: BootstrapItaliaSpacing.space3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// The same row on the docs' `.neutral-1-bg-a8` panel.
class _DarkRow extends StatelessWidget {
  const _DarkRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      // `.neutral-1-bg-a8 { background-color: hsl(210,25%,35.2%) }` — the panel
      // the docs put the dark variant on.
      color: const Color(0xFF435A70),
      child: Padding(
        padding: const EdgeInsets.all(BootstrapItaliaSpacing.space4),
        child: _Row(children: children),
      ),
    );
  }
}

/// Tells the reader where to look for the live control.
class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.south_east, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: BootstrapItaliaSpacing.space2),
        Expanded(
          child: Text(
            'Scorri verso il basso: il pulsante compare in basso a destra.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
