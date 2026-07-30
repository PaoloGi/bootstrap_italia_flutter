import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  bool _showDismissible = true;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Alert',
      children: [
        ExampleSection(
          title: 'Varianti',
          child: Column(
            children: ItAlertVariant.values
                .map((v) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ItAlert(
                        variant: v,
                        child: Text('Questo è un alert ${v.name}.'),
                      ),
                    ))
                .toList(),
          ),
        ),
        ExampleSection(
          title: 'Con icona e titolo',
          child: ItAlert(
            variant: ItAlertVariant.success,
            icon: Icons.check_circle,
            title: 'Operazione completata',
            child: const Text('Il documento è stato salvato con successo.'),
          ),
        ),
        ExampleSection(
          title: 'Dismissibile',
          child: _showDismissible
              ? ItAlert(
                  variant: ItAlertVariant.warning,
                  icon: Icons.warning_amber,
                  title: 'Attenzione',
                  dismissible: true,
                  onDismissed: () => setState(() => _showDismissible = false),
                  child: const Text(
                      'Questo alert può essere chiuso. Premi la X.'),
                )
              : ItButton(
                  variant: ItButtonVariant.secondary,
                  onPressed: () => setState(() => _showDismissible = true),
                  child: const Text('Mostra di nuovo'),
                ),
        ),
      ],
    );
  }
}
