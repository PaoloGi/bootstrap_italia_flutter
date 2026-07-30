import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  String? _baseValue;
  String? _inlineValue;
  String? _labelValue;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Radio',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItRadioGroup<String>(
            options: const [
              ItRadioOption(value: 'opzione1', label: 'Opzione 1'),
              ItRadioOption(value: 'opzione2', label: 'Opzione 2'),
              ItRadioOption(value: 'opzione3', label: 'Opzione 3'),
            ],
            value: _baseValue,
            onChanged: (value) => setState(() => _baseValue = value),
          ),
        ),
        ExampleSection(
          title: 'Inline',
          child: ItRadioGroup<String>(
            options: const [
              ItRadioOption(value: 'si', label: 'Sì'),
              ItRadioOption(value: 'no', label: 'No'),
              ItRadioOption(value: 'forse', label: 'Forse'),
            ],
            value: _inlineValue,
            inline: true,
            onChanged: (value) => setState(() => _inlineValue = value),
          ),
        ),
        ExampleSection(
          title: 'Con label',
          child: ItRadioGroup<String>(
            label: 'Metodo di pagamento',
            options: const [
              ItRadioOption(value: 'carta', label: 'Carta di credito'),
              ItRadioOption(value: 'bonifico', label: 'Bonifico bancario'),
              ItRadioOption(value: 'paypal', label: 'PayPal'),
            ],
            value: _labelValue,
            onChanged: (value) => setState(() => _labelValue = value),
          ),
        ),
      ],
    );
  }
}
