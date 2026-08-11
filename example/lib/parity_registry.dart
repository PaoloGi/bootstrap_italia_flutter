// Maps a parity key to the widget under test.
//
// Deliberately mirrors the `captureWidget` calls in
// tool/visual_parity/capture/parity_*.dart:
// the same component, same props, same text. Keys that exist in both places
// must render identically, so a disagreement between the golden capture and
// the web capture is itself a signal worth investigating.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';

class ParityEntry {
  const ParityEntry(this.build, {this.width});

  /// Builds the component under test.
  final WidgetBuilder build;

  /// Optional fixed width, for block-level components whose reference fills
  /// its container (alerts, footers, headers).
  final double? width;
}

/// Interaction states a key can be driven into by the capture script.
/// Hover/focus/press are applied from the browser side; `expanded` and the
/// disabled variants are separate entries because they change the widget tree.
const kInteractionStates = <String>['default', 'hover', 'focus', 'active'];

final Map<String, ParityEntry> parityRegistry = {
  // ── Buttons ────────────────────────────────────────────────────────
  'button_primary': ParityEntry(
    (c) => ItButton(onPressed: () {}, child: const Text('Bottone')),
  ),
  'button_primary_outline': ParityEntry(
    (c) =>
        ItButton(outline: true, onPressed: () {}, child: const Text('Bottone')),
  ),
  'button_secondary_solid': ParityEntry(
    (c) => ItButton(
      variant: ItButtonVariant.secondary,
      onPressed: () {},
      child: const Text('Bottone'),
    ),
  ),
  'button_disabled': ParityEntry(
    (c) => const ItButton(
      disabled: true,
      onPressed: null,
      child: Text('Bottone'),
    ),
  ),

  // ── Badge / Chip ───────────────────────────────────────────────────
  'badge_primary': ParityEntry((c) => const ItBadge(child: Text('Primary'))),
  'chip_simple': ParityEntry((c) => const ItChip(label: 'Label')),

  // ── Alert ──────────────────────────────────────────────────────────
  'alert_success': ParityEntry(
    (c) => const ItAlert(
      variant: ItAlertVariant.success,
      icon: BootstrapItaliaIcons.it_check_circle,
      body: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Questo è un alert di '),
            TextSpan(
                text: 'success', style: TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: '!'),
          ],
        ),
      ),
    ),
    width: 868,
  ),

  // ── Form controls: the richest source of interaction states ────────
  'input_default': ParityEntry(
    (c) => const SizedBox(width: 320, child: ItInput(label: 'Etichetta')),
  ),
  'checkbox_unchecked': ParityEntry(
    (c) => ItCheckbox(label: 'Checkbox', value: false, onChanged: (_) {}),
  ),
  'checkbox_checked': ParityEntry(
    (c) => ItCheckbox(label: 'Checkbox', value: true, onChanged: (_) {}),
  ),
  'toggle_off': ParityEntry(
    (c) => ItToggle(label: 'Toggle', value: false, onChanged: (_) {}),
  ),
  'toggle_on': ParityEntry(
    (c) => ItToggle(label: 'Toggle', value: true, onChanged: (_) {}),
  ),
  // A field whose validation message must be programmatically tied to it
  // (WCAG 3.3.1) — the case axe reports as "Form elements must have labels"
  // when the message and the label are only visually adjacent.
  'input_invalid': ParityEntry(
    (c) => const SizedBox(
      width: 320,
      child: ItInput(
        label: 'Etichetta',
        errorText: 'Messaggio di errore',
        required: true,
      ),
    ),
  ),
  'radio_unchecked': ParityEntry(
    (c) => ItRadioGroup<String>(
      label: 'Gruppo',
      value: 'a',
      options: const [
        ItRadioOption(value: 'a', label: 'Opzione uno'),
        ItRadioOption(value: 'b', label: 'Opzione due'),
      ],
      onChanged: (_) {},
    ),
  ),
  'select_default': ParityEntry(
    (c) => SizedBox(
      width: 320,
      child: ItSelect<String>(
        label: 'Etichetta',
        value: 'a',
        items: const [
          ItSelectItem(value: 'a', label: 'Opzione uno'),
          ItSelectItem(value: 'b', label: 'Opzione due'),
        ],
        onChanged: (_) {},
      ),
    ),
  ),
  'autocomplete_default': ParityEntry(
    (c) => SizedBox(
      width: 320,
      child: ItAutocomplete<String>(
        label: 'Etichetta',
        onSearch: (q) async => const ['Opzione uno'],
        displayStringForOption: (s) => s,
      ),
    ),
  ),

  // ── Components with genuine expand/collapse behaviour ──────────────
  'accordion_collapsed': ParityEntry(
    (c) => const ItAccordion(
      items: [
        ItAccordionItem(
          title: 'Accordion Item #1',
          body: Text('Contenuto del primo elemento.'),
        ),
      ],
    ),
    width: 700,
  ),
  // The expanded panel has no React story to diff against (every Accordion
  // story mounts collapsed), but it exercises the toggle behaviour and gives
  // the interaction pass something real to drive.
  'accordion_expanded': ParityEntry(
    (c) => const ItAccordion(
      items: [
        ItAccordionItem(
          title: 'Accordion Item #1',
          initiallyExpanded: true,
          body: Text('Contenuto del primo elemento.'),
        ),
      ],
    ),
    width: 700,
  ),

  // ── Responsive: these branch on breakpoint ─────────────────────────
  'nav_header_nav': ParityEntry(
    (c) => const ItNavHeader(
      items: [
        ItNavItem(label: 'Link 1', active: true),
        ItNavItem(label: 'Link 2'),
        ItNavItem(label: 'Link 3'),
      ],
    ),
  ),
  'breadcrumb': ParityEntry(
    (c) => const ItBreadcrumb(
      items: [
        ItBreadcrumbItem(label: 'Home'),
        ItBreadcrumbItem(label: 'Categoria'),
        ItBreadcrumbItem(label: 'Pagina'),
      ],
    ),
  ),
};
