import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Notifiche',
      children: [
        ExampleSection(
          title: 'Varianti',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _variantButton(
                context,
                variant: ItNotificationVariant.success,
                label: 'Successo',
                title: 'Operazione completata',
                message: 'Il documento è stato salvato correttamente.',
                icon: Icons.check_circle,
              ),
              const SizedBox(height: 8),
              _variantButton(
                context,
                variant: ItNotificationVariant.warning,
                label: 'Attenzione',
                title: 'Attenzione',
                message:
                    'Alcune informazioni potrebbero non essere aggiornate.',
                icon: Icons.warning,
              ),
              const SizedBox(height: 8),
              _variantButton(
                context,
                variant: ItNotificationVariant.danger,
                label: 'Errore',
                title: 'Errore',
                message: 'Si è verificato un errore durante il salvataggio.',
                icon: Icons.error,
              ),
              const SizedBox(height: 8),
              _variantButton(
                context,
                variant: ItNotificationVariant.info,
                label: 'Informazione',
                title: 'Informazione',
                message: 'La sessione scadrà tra 5 minuti.',
                icon: Icons.info,
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Posizioni',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final position in ItNotificationPosition.values)
                ItButton(
                  onPressed: () {
                    ItNotification.show(
                      context: context,
                      variant: ItNotificationVariant.info,
                      title: position.name,
                      body: 'Notifica in posizione ${position.name}.',
                      icon: Icons.place,
                      position: position,
                    );
                  },
                  child: Text(position.name),
                ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Persistente',
          child: ItButton(
            onPressed: () {
              ItNotification.show(
                context: context,
                variant: ItNotificationVariant.warning,
                title: 'Notifica persistente',
                body: 'Questa notifica non scompare automaticamente. '
                    'Premi la X per chiuderla.',
                icon: Icons.push_pin,
                duration: null,
              );
            },
            child: const Text('Mostra notifica persistente'),
          ),
        ),
      ],
    );
  }

  Widget _variantButton(
    BuildContext context, {
    required ItNotificationVariant variant,
    required String label,
    required String title,
    required String message,
    required IconData icon,
  }) {
    return ItButton(
      onPressed: () {
        ItNotification.show(
          context: context,
          variant: variant,
          title: title,
          body: message,
          icon: icon,
        );
      },
      child: Text(label),
    );
  }
}
