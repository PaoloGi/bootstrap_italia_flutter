import 'package:flutter/material.dart';
import 'package:bootstrap_italia/bootstrap_italia.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class CalloutPage extends StatelessWidget {
  const CalloutPage({super.key});

  static const _variantLabels = {
    ItCalloutVariant.success: 'Operazione completata',
    ItCalloutVariant.warning: 'Attenzione',
    ItCalloutVariant.danger: 'Errore',
    ItCalloutVariant.important: 'Importante',
    ItCalloutVariant.note: 'Nota',
  };

  static const _variantDescriptions = {
    ItCalloutVariant.success:
        'Il servizio è stato attivato correttamente. Non sono necessarie ulteriori azioni.',
    ItCalloutVariant.warning:
        'Alcuni dati potrebbero non essere aggiornati. Verificare prima di procedere.',
    ItCalloutVariant.danger:
        'Si è verificato un errore durante l\'elaborazione della richiesta.',
    ItCalloutVariant.important:
        'Questa funzionalità è disponibile per tutti gli utenti registrati.',
    ItCalloutVariant.note:
        'Per ulteriori informazioni consultare la documentazione ufficiale.',
  };

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Callout',
      children: [
        ExampleSection(
          title: 'Varianti',
          child: Column(
            children: ItCalloutVariant.values.map((variant) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: BootstrapItaliaSpacing.space3,
                ),
                child: ItCallout(
                  variant: variant,
                  title: _variantLabels[variant],
                  child: Text(_variantDescriptions[variant]!),
                ),
              );
            }).toList(),
          ),
        ),
        ExampleSection(
          title: 'Collassabile',
          child: ItCallout(
            variant: ItCalloutVariant.note,
            title: 'Dettagli aggiuntivi',
            collapsible: true,
            initiallyExpanded: false,
            child: const Text(
              'Questo callout può essere espanso o compresso cliccando '
              'sul titolo. Utile per contenuti opzionali che non devono '
              'occupare spazio in modo permanente.',
            ),
          ),
        ),
      ],
    );
  }
}
