import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Input',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItInput(
            label: 'Nome',
            onChanged: (_) {},
          ),
        ),
        ExampleSection(
          title: 'Con icona',
          child: ItInput(
            label: 'Campo con icona',
            icon: Icons.edit,
            onChanged: (_) {},
          ),
        ),
        ExampleSection(
          title: 'Con icona e azione',
          child: ItInput(
            label: 'Campo con azione',
            icon: Icons.edit,
            trailingAction: ItButton(
              variant: ItButtonVariant.primary,
              size: ItButtonSize.small,
              onPressed: () {},
              child: const Text('Invio'),
            ),
            onChanged: (_) {},
          ),
        ),
        ExampleSection(
          title: 'Helper text',
          child: ItInput(
            label: 'Codice fiscale',
            helperText: 'Inserisci il tuo codice fiscale alfanumerico',
            onChanged: (_) {},
          ),
        ),
        ExampleSection(
          title: 'Validazione',
          child: Column(
            children: [
              ItInput(
                label: 'Campo valido',
                validationState: ItValidationState.success,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              ItInput(
                label: 'Campo con avviso',
                validationState: ItValidationState.warning,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              ItInput(
                label: 'Campo con errore',
                validationState: ItValidationState.danger,
                errorText: 'Questo campo è obbligatorio',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Validazione con icona',
          child: Column(
            children: [
              ItInput(
                label: 'Campo valido',
                icon: Icons.edit,
                validationState: ItValidationState.success,
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              ItInput(
                label: 'Campo con errore',
                icon: Icons.edit,
                validationState: ItValidationState.danger,
                errorText: 'Questo campo è obbligatorio',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Password',
          child: ItInput(
            label: 'Password',
            obscureText: true,
            showPasswordToggle: true,
            onChanged: (_) {},
          ),
        ),
        ExampleSection(
          title: 'Disabilitato',
          child: ItInput(
            label: 'Contenuto disabilitato',
            controller: TextEditingController(text: 'Contenuto disabilitato'),
            enabled: false,
          ),
        ),
        ExampleSection(
          title: 'Multilinea',
          child: ItInput(
            label: 'Messaggio',
            maxLines: 4,
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}
