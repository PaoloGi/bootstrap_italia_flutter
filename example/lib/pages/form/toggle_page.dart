import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class TogglePage extends StatefulWidget {
  const TogglePage({super.key});

  @override
  State<TogglePage> createState() => _TogglePageState();
}

class _TogglePageState extends State<TogglePage> {
  bool _baseValue = false;
  bool _noLabelValue = false;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Toggle',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItToggle(
            value: _baseValue,
            label: 'Notifiche email',
            onChanged: (value) => setState(() => _baseValue = value),
          ),
        ),
        ExampleSection(
          title: 'Senza label',
          child: ItToggle(
            value: _noLabelValue,
            onChanged: (value) => setState(() => _noLabelValue = value),
          ),
        ),
        const ExampleSection(
          title: 'Disabilitato',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItToggle(
                value: false,
                label: 'Disattivato (off)',
                disabled: true,
              ),
              SizedBox(height: 16),
              ItToggle(
                value: true,
                label: 'Disattivato (on)',
                disabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
