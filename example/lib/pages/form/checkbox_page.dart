import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class CheckboxPage extends StatefulWidget {
  const CheckboxPage({super.key});

  @override
  State<CheckboxPage> createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  bool _singleValue = false;
  Set<String> _groupValues = {};
  Set<String> _inlineValues = {};
  List<bool> _childSelections = [true, false, false];

  bool get _allSelected => _childSelections.every((v) => v);
  bool get _someSelected => _childSelections.any((v) => v);

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Checkbox',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItCheckbox(
            value: _singleValue,
            label: 'Accetto i termini e le condizioni',
            onChanged: (value) => setState(() => _singleValue = value),
          ),
        ),
        ExampleSection(
          title: 'Gruppo',
          child: ItCheckboxGroup<String>(
            label: 'Interessi',
            options: const [
              ItCheckboxOption(value: 'sport', label: 'Sport'),
              ItCheckboxOption(value: 'musica', label: 'Musica'),
              ItCheckboxOption(value: 'cinema', label: 'Cinema'),
            ],
            values: _groupValues,
            onChanged: (values) => setState(() => _groupValues = values),
          ),
        ),
        ExampleSection(
          title: 'Inline',
          child: ItCheckboxGroup<String>(
            label: 'Lingue parlate',
            options: const [
              ItCheckboxOption(value: 'it', label: 'Italiano'),
              ItCheckboxOption(value: 'en', label: 'Inglese'),
              ItCheckboxOption(value: 'fr', label: 'Francese'),
            ],
            values: _inlineValues,
            inline: true,
            onChanged: (values) => setState(() => _inlineValues = values),
          ),
        ),
        ExampleSection(
          title: 'Indeterminate ("seleziona tutto")',
          child: ItCheckbox(
            value: _allSelected,
            // Computed from the children, not cycled by tapping — which is what
            // `input.semi-checked` means in Bootstrap Italia.
            indeterminate: _someSelected && !_allSelected,
            label: 'Seleziona tutto',
            onChanged: (value) => setState(() {
              _childSelections =
                  List.filled(_childSelections.length, value);
            }),
          ),
        ),
      ],
    );
  }
}
