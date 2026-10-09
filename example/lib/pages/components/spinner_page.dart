import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors the Spinner half of
/// https://italia.github.io/bootstrap-italia/docs/componenti/progress-indicators/
///
/// That page documents four things: Donuts, Progress Bar, a button with an
/// embedded progress bar, and Spinner. Only the last one is a component this
/// package ships, so only the last one is here; the other three are recorded at
/// the bottom as components we do not implement, which is a different statement
/// from a section we chose to skip.
class SpinnerPage extends StatelessWidget {
  /// Creates the spinner catalogue page.
  const SpinnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Spinner',
      children: [
        // ── Spinner ────────────────────────────────────────────────────────
        ExampleSection(
          title: 'Spinner',
          description:
              "Lo spinner comunica che un'operazione è in corso ma non il suo "
              "avanzamento: si usa quando non è possibile determinare quanto "
              'manchi alla fine. Le quattro dimensioni della documentazione '
              '(32, 48, 64 e 80 pixel) sono i valori di ItSpinnerSize, e la '
              'classe .progress-spinner-active corrisponde ad animating. I due '
              'parametri sono indipendenti: lo spinner a riposo è il solo '
              'anello grigio, senza arco colorato.',
          code: 'ItSpinner()                               // 48px, in moto\n'
              'ItSpinner(size: ItSpinnerSize.small)      // 32px\n'
              'ItSpinner(size: ItSpinnerSize.large)      // 64px\n'
              'ItSpinner(size: ItSpinnerSize.extraLarge) // 80px\n'
              'ItSpinner(animating: false)               // solo la traccia',
          child: const _SpinnerMatrix(doubleRing: false),
        ),

        // ── Spinner doppio ─────────────────────────────────────────────────
        ExampleSection(
          title: 'Spinner doppio',
          description:
              'La classe .progress-spinner-double sostituisce il singolo arco '
              'con due archi che oscillano in direzioni opposte. È '
              "un'animazione alternativa, non una dimensione né uno stato: si "
              'combina liberamente con size e con animating.',
          code: 'ItSpinner(doubleRing: true)\n'
              'ItSpinner(doubleRing: true, size: ItSpinnerSize.extraLarge)\n'
              'ItSpinner(doubleRing: true, animating: false)',
          child: const _SpinnerMatrix(doubleRing: true),
        ),

        // Not a docs section. It is here because the docs' own spinners are
        // grey-blue and ours are Blu Italia, and a reader comparing the two
        // pages deserves to be told why rather than left to wonder.
        ExampleSection(
          title: 'Colore',
          description:
              'Il foglio di stile colora l\'arco attivo con hsl(210,17%,44%), '
              'cioè --bs-secondary. ItSpinner passa invece primary: è una '
              'scelta di questo pacchetto per un indicatore a sé stante, non '
              'un errore di lettura del CSS. Il parametro color permette di '
              "tornare al valore dichiarato, e in entrambi i casi l'arco segue "
              'il tema — la traccia grigia no, perché #D8D9DA non corrisponde '
              'a nessun token della palette.',
          code: '// il valore dichiarato dal foglio di stile\n'
              'ItSpinner(color: BootstrapItaliaColors.secondary)\n\n'
              "// l'arco segue il tema\n"
              'BootstrapItaliaTheme(\n'
              '  data: BootstrapItaliaThemeData(\n'
              '    colors: BootstrapItaliaColorScheme.standard\n'
              '        .copyWith(primary: Color(0xFF7A1FA2)),\n'
              '  ),\n'
              '  child: ItSpinner(),\n'
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space4,
            runSpacing: BootstrapItaliaSpacing.space3,
            children: [
              const _Labelled(
                label: 'primary (predefinito)',
                child: ItSpinner(),
              ),
              const _Labelled(
                label: 'secondary (CSS)',
                child: ItSpinner(color: BootstrapItaliaColors.secondary),
              ),
              _Labelled(
                label: 'tema personalizzato',
                child: BootstrapItaliaTheme(
                  data: BootstrapItaliaThemeData(
                    colors: BootstrapItaliaColorScheme.standard
                        .copyWith(primary: const Color(0xFF7A1FA2)),
                  ),
                  child: const ItSpinner(),
                ),
              ),
            ],
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Donuts, Progress Bar (con le sue sotto-sezioni Esempio, '
              'Etichette, Progresso Indeterminato e Colori) e Pulsante con '
              'Progress Bar — non sono varianti dello spinner ma componenti '
              'distinti, che questo pacchetto non implementa. La differenza '
              'conta: non sono sezioni che abbiamo scelto di saltare, sono '
              'funzionalità assenti, come il carosello e l\'avatar. Chi ha '
              'bisogno di una barra di avanzamento oggi deve costruirla.\n\n'
              'Attivazione tramite codice, Opzioni e Metodi — riguardano '
              "l'inizializzazione JavaScript del plugin ProgressDonut, che in "
              'Flutter non esiste: un widget è attivo appena costruito. Non '
              'descrivono comportamenti da tastiera, quindi non resta nulla da '
              'implementare.\n\n'
              'Accessibilità — la documentazione chiede uno <span> nascosto '
              'con il testo «Caricamento...» accanto allo spinner. Qui è già '
              'incluso: ItSpinner porta sempre un nome accessibile, '
              'localizzato in italiano, tedesco e francese, e semanticLabel '
              'permette di dire che cosa si sta caricando invece del solo che '
              'qualcosa lo sta facendo.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// The docs' 4 x 2 grid: every size, at rest and active.
class _SpinnerMatrix extends StatelessWidget {
  const _SpinnerMatrix({required this.doubleRing});

  final bool doubleRing;

  static const _sizes = <(String, ItSpinnerSize)>[
    ('Standard', ItSpinnerSize.medium),
    ('Small', ItSpinnerSize.small),
    ('Large', ItSpinnerSize.large),
    ('Extra-large', ItSpinnerSize.extraLarge),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: BootstrapItaliaSpacing.space4,
      runSpacing: BootstrapItaliaSpacing.space4,
      children: [
        for (final (label, size) in _sizes) ...[
          _Labelled(
            label: label,
            child: ItSpinner(
              size: size,
              doubleRing: doubleRing,
              animating: false,
            ),
          ),
          _Labelled(
            label: '$label attivo',
            child: ItSpinner(size: size, doubleRing: doubleRing),
          ),
        ],
      ],
    );
  }
}

/// A spinner under its caption, as the docs lay the grid out.
class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: BootstrapItaliaSpacing.space2),
          // The 80px extra-large spinner is the tallest cell; a fixed box keeps
          // the captions on one baseline instead of stepping down with the
          // diameter.
          SizedBox(
              height: 88,
              child: Align(alignment: Alignment.centerLeft, child: child)),
        ],
      ),
    );
  }
}
