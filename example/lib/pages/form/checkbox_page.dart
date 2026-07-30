import 'package:bootstrap_italia/bootstrap_italia.dart';
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
  bool _tristateValue = false;

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
            onChanged: (value) =>
                setState(() => _singleValue = value ?? false),
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
          title: 'Tristate',
          child: ItCheckbox(
            value: _tristateValue,
            tristate: true,
            label: 'Seleziona tutto',
            onChanged: (value) =>
                setState(() => _tristateValue = value ?? false),
          ),
        ),
      ],
    );
  }
}
