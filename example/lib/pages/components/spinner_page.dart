import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class SpinnerPage extends StatelessWidget {
  const SpinnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Spinner',
      children: [
        ExampleSection(
          title: 'Standard',
          child: const ItSpinner(),
        ),
        ExampleSection(
          title: 'Piccolo',
          child: const ItSpinner(size: ItSpinnerSize.small),
        ),
        ExampleSection(
          title: 'Attivo',
          child: const ItSpinner(doubleRing: true),
        ),
        ExampleSection(
          title: 'Colori',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              ItSpinner(color: Colors.blue),
              ItSpinner(color: Colors.green),
              ItSpinner(color: Colors.red),
              ItSpinner(color: Colors.orange),
            ],
          ),
        ),
      ],
    );
  }
}
