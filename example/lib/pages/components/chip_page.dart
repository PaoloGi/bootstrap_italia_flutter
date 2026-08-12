import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

/// Mirrors https://italia.github.io/bootstrap-italia/docs/componenti/chips/
///
/// Section for section, in the docs' own order and with its headings. Two of the
/// four shapes «Varianti standard e grandi» shows — the avatar ones — and the
/// whole of «Varianti di colore» needed new parameters on [ItChip] first.
class ChipPage extends StatefulWidget {
  const ChipPage({super.key});

  @override
  State<ChipPage> createState() => _ChipPageState();
}

class _ChipPageState extends State<ChipPage> {
  /// Which chips of the removable group are still present.
  final Set<String> _removed = <String>{};

  bool _selected = false;

  /// The five colour variants the docs list, in their order.
  static const _variants = <ItChipVariant, String>{
    ItChipVariant.primary: 'Primary',
    ItChipVariant.secondary: 'Secondary',
    ItChipVariant.success: 'Success',
    ItChipVariant.danger: 'Danger',
    ItChipVariant.warning: 'Warning',
  };

  /// Stands in for the docs' `<img>` avatar, which needs a network fetch this
  /// catalogue does not make.
  Widget _avatar() => const DecoratedBox(
        decoration: BoxDecoration(
          color: BootstrapItaliaColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'MR',
            style: TextStyle(
              color: BootstrapItaliaColors.white,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              fontFamily: BootstrapItaliaFontFamily.sansSerif,
              package: BootstrapItaliaFontFamily.package,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Chip',
      children: [
        // ── Varianti standard e grandi ─────────────────────────────────────
        ExampleSection(
          title: 'Varianti standard e grandi',
          description:
              'Le quattro forme della documentazione: solo testo, testo e '
              'chiusura, icona con testo e chiusura, avatar con testo e '
              'chiusura. large: true dà la versione grande (.chip-lg). La '
              'chip con la sola etichetta corrisponde a .chip-simple, che qui '
              'non è un parametro: si ottiene semplicemente non chiedendo il '
              'pulsante di chiusura, che è la stessa condizione.',
          code: "ItChip(label: 'Label')\n"
              "ItChip(label: 'Label', dismissible: true, onDismiss: () {})\n"
              'ItChip(\n'
              "  label: 'Label',\n"
              '  icon: BootstrapItaliaIcons.it_github,\n'
              '  dismissible: true,\n'
              '  onDismiss: () {},\n'
              ')\n'
              'ItChip(\n'
              "  label: 'Label',\n"
              '  leading: CircleAvatar(...),\n'
              '  dismissible: true,\n'
              '  onDismiss: () {},\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final large in [false, true]) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: BootstrapItaliaSpacing.space3,
                    bottom: BootstrapItaliaSpacing.space2,
                  ),
                  child: Text(
                    large ? 'Grandi' : 'Standard',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Wrap(
                  spacing: BootstrapItaliaSpacing.space2,
                  runSpacing: BootstrapItaliaSpacing.space2,
                  children: [
                    ItChip(label: 'Solo testo', large: large),
                    ItChip(
                      label: 'Testo e chiusura',
                      large: large,
                      dismissible: true,
                      onDismiss: () {},
                    ),
                    ItChip(
                      label: 'Icona',
                      large: large,
                      icon: BootstrapItaliaIcons.it_github,
                      dismissible: true,
                      onDismiss: () {},
                    ),
                    ItChip(
                      label: 'Avatar',
                      large: large,
                      leading: _avatar(),
                      dismissible: true,
                      onDismiss: () {},
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // ── Varianti di colore ─────────────────────────────────────────────
        ExampleSection(
          title: 'Varianti di colore',
          description:
              'Le classi .chip-* non funzionano come quelle di badge o '
              'pulsanti: una chip colorata è un contorno a riposo — sfondo '
              'trasparente, bordo ed etichetta del colore — e si riempie solo '
              'al passaggio del puntatore, quando l\'etichetta diventa bianca. '
              'È il comportamento inverso rispetto a un badge colorato.',
          code: 'ItChip(\n'
              "  label: 'Primary',\n"
              '  variant: ItChipVariant.primary,\n'
              '  large: true,\n'
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              for (final entry in _variants.entries)
                ItChip(
                  label: entry.value,
                  variant: entry.key,
                  large: true,
                ),
            ],
          ),
        ),

        // ── Varianti di colore link ────────────────────────────────────────
        ExampleSection(
          title: 'Varianti di colore link',
          description:
              'Le stesse varianti su un <a>. In Flutter la differenza è '
              'onTap: la chip diventa attivabile, riceve il fuoco da tastiera '
              'e il suo anello. Da notare che si annuncia come pulsante e non '
              'come link, perché ItChip.onTap non porta con sé una '
              'destinazione: dove il ruolo di link è quello corretto, va '
              'dichiarato dal chiamante.',
          code: 'ItChip(\n'
              "  label: 'Primary',\n"
              '  variant: ItChipVariant.primary,\n'
              '  large: true,\n'
              '  onTap: () {},\n'
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              for (final entry in _variants.entries)
                ItChip(
                  label: entry.value,
                  variant: entry.key,
                  large: true,
                  onTap: () {},
                ),
            ],
          ),
        ),

        // ── Chip Disabilitata ──────────────────────────────────────────────
        ExampleSection(
          title: 'Chip Disabilitata',
          description:
              'disabled: true corrisponde a .chip-disabled: fondo bianco, '
              'etichetta e glifi grigi, nessuna interazione. Una differenza '
              'voluta dal foglio di stile: nella cascata CSS .chip-disabled è '
              'dichiarata prima di .chip-primary a pari specificità, quindi in '
              'un browser una chip colorata e disabilitata si vede come una '
              'chip colorata normale. Qui vince disabled, perché un controllo '
              'inattivo che sembra attivo è una trappola.',
          code: "ItChip(label: 'Label disabilitata', disabled: true)",
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              const ItChip(
                  label: 'Label disabilitata', large: true, disabled: true),
              const ItChip(
                label: 'Label disabilitata',
                large: true,
                disabled: true,
                dismissible: true,
              ),
              const ItChip(
                label: 'Label disabilitata',
                large: true,
                disabled: true,
                icon: BootstrapItaliaIcons.it_github,
                dismissible: true,
              ),
              ItChip(
                label: 'Label disabilitata',
                large: true,
                disabled: true,
                leading: _avatar(),
                dismissible: true,
              ),
            ],
          ),
        ),

        // ── Gruppi di Chip ─────────────────────────────────────────────────
        ExampleSection(
          title: 'Gruppi di Chip',
          description:
              'I gruppi si dispongono in linea. Il Wrap è l\'equivalente '
              'Flutter: manda a capo quando lo spazio finisce, cosa che il '
              'display inline fa da sé. Ogni chiusura è una richiesta al '
              'genitore — onDismiss non rimuove la chip, la lista qui sopra '
              'decide se lasciarla cadere.',
          code: 'Wrap(\n'
              '  spacing: 8,\n'
              '  children: [\n'
              '    for (final tag in tags)\n'
              '      ItChip(\n'
              '        label: tag,\n'
              '        dismissible: true,\n'
              '        onDismiss: () => setState(() => tags.remove(tag)),\n'
              '      ),\n'
              '  ],\n'
              ')',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: BootstrapItaliaSpacing.space2,
                runSpacing: BootstrapItaliaSpacing.space2,
                children: [
                  for (final tag in const [
                    'Lazio',
                    'Lombardia',
                    'Sicilia',
                    'Veneto',
                  ])
                    if (!_removed.contains(tag))
                      ItChip(
                        label: tag,
                        dismissible: true,
                        onDismiss: () => setState(() => _removed.add(tag)),
                      ),
                  if (_removed.isNotEmpty)
                    ItButton(
                      size: ItButtonSize.small,
                      variant: ItButtonVariant.secondary,
                      outline: true,
                      onPressed: () => setState(_removed.clear),
                      child: const Text('Ripristina'),
                    ),
                ],
              ),
              const SizedBox(height: BootstrapItaliaSpacing.space3),
              Wrap(
                spacing: BootstrapItaliaSpacing.space2,
                runSpacing: BootstrapItaliaSpacing.space2,
                children: [
                  const ItChip(label: 'Label', large: true),
                  ItChip(
                      label: 'Label',
                      large: true,
                      dismissible: true,
                      onDismiss: () {}),
                  ItChip(
                    label: 'Label',
                    large: true,
                    icon: BootstrapItaliaIcons.it_github,
                    dismissible: true,
                    onDismiss: () {},
                  ),
                  ItChip(
                    label: 'Label',
                    large: true,
                    leading: _avatar(),
                    dismissible: true,
                    onDismiss: () {},
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Gruppi di Chip con link ────────────────────────────────────────
        ExampleSection(
          title: 'Gruppi di Chip con link',
          description:
              'Lo stesso gruppo con la variante di colore e onTap su ogni '
              'chip. Attenzione a un conflitto di autore che il markup della '
              'documentazione contiene: un <button> di chiusura dentro un <a> '
              'annida due bersagli. Qui i due controlli sono fratelli e non '
              'annidati, quindi ognuno ha il proprio nodo semantico e il '
              'proprio bersaglio.',
          code: 'ItChip(\n'
              "  label: 'Label',\n"
              '  variant: ItChipVariant.primary,\n'
              '  onTap: () {},\n'
              '  dismissible: true,\n'
              '  onDismiss: () {},\n'
              ')',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space2,
            runSpacing: BootstrapItaliaSpacing.space2,
            children: [
              ItChip(
                label: 'Label',
                variant: ItChipVariant.primary,
                onTap: () {},
              ),
              ItChip(
                label: 'Label',
                variant: ItChipVariant.primary,
                onTap: () {},
                dismissible: true,
                onDismiss: () {},
              ),
              ItChip(
                label: 'Label',
                variant: ItChipVariant.primary,
                icon: BootstrapItaliaIcons.it_github,
                onTap: () {},
                dismissible: true,
                onDismiss: () {},
              ),
              ItChip(
                label: 'Label',
                variant: ItChipVariant.primary,
                leading: _avatar(),
                onTap: () {},
                dismissible: true,
                onDismiss: () {},
              ),
            ],
          ),
        ),

        // Not a docs section: `selected` predates this page.
        ExampleSection(
          title: 'selected (aggiunta di questo pacchetto)',
          description:
              'Non è una sezione della documentazione. selected ispessisce il '
              'bordo e tinge etichetta e fondo con il colore primario, per una '
              'chip che rappresenta un filtro attivo. Il foglio di stile non '
              'definisce uno stato selezionato per .chip.',
          code: 'ItChip(\n'
              "  label: 'Solo aperti',\n"
              '  selected: _selected,\n'
              '  onTap: () => setState(() => _selected = !_selected),\n'
              ')',
          child: ItChip(
            label: _selected ? 'Solo aperti (attivo)' : 'Solo aperti',
            selected: _selected,
            onTap: () => setState(() => _selected = !_selected),
          ),
        ),

        // ── What is deliberately absent ────────────────────────────────────
        const ExampleSection(
          title: 'Sezioni della documentazione non riprodotte',
          description:
              'Nessuna sezione è stata omessa: la pagina Chips non ha né '
              'attivazione tramite codice né metodi JavaScript.\n\n'
              'Restano tre differenze da dichiarare. Lo hover, che nella '
              'documentazione è metà del comportamento delle varianti di '
              'colore, è implementato ma non mostrato come esempio: non ha '
              'equivalente sui dispositivi tattili.\n\n'
              'L\'avatar della documentazione è un <img> con testo '
              'alternativo; qui il posto è un widget qualsiasi (leading), e '
              'questa pagina ci mette un segnaposto invece di scaricare '
              'un\'immagine. Il ritaglio circolare è a carico di chi lo passa: '
              'border-radius: 50% appartiene al componente avatar, che questo '
              'pacchetto non fornisce.\n\n'
              'Infine il glifo di chiusura: il foglio di stile lo tinge di '
              'hsl(210, 17%, 44%), un gradino più chiaro dell\'etichetta, '
              'mentre qui prende il colore dell\'etichetta. Quel valore '
              'coincide byte per byte con il token secondary, e farlo passare '
              'dal tema sarebbe peggio — una amministrazione che ritinge '
              'secondary di viola non vuole i pulsanti di chiusura viola.',
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
