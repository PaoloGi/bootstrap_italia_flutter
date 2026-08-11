import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class ButtonPage extends StatelessWidget {
  const ButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Button',
      children: [
        ExampleSection(
          title: 'Varianti',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ItButtonVariant.values
                .map((v) => ItButton(
                      variant: v,
                      onPressed: () {},
                      child: Text(v.name),
                    ))
                .toList(),
          ),
        ),
        ExampleSection(
          title: 'Outline',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ItButtonVariant.primary,
              ItButtonVariant.secondary,
              ItButtonVariant.success,
              ItButtonVariant.danger,
            ]
                .map((v) => ItButton(
                      variant: v,
                      outline: true,
                      onPressed: () {},
                      child: Text(v.name),
                    ))
                .toList(),
          ),
        ),
        ExampleSection(
          title: 'Dimensioni',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ItButton(
                size: ItButtonSize.small,
                onPressed: () {},
                child: const Text('Small'),
              ),
              ItButton(
                size: ItButtonSize.medium,
                onPressed: () {},
                child: const Text('Medium'),
              ),
              ItButton(
                size: ItButtonSize.large,
                onPressed: () {},
                child: const Text('Large'),
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Con icone',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ItButton(
                icon: Icons.favorite,
                onPressed: () {},
                child: const Text('Preferiti'),
              ),
              ItButton(
                variant: ItButtonVariant.success,
                trailingIcon: Icons.arrow_forward,
                onPressed: () {},
                child: const Text('Avanti'),
              ),
              ItButton(
                variant: ItButtonVariant.info,
                icon: Icons.download,
                trailingIcon: Icons.open_in_new,
                onPressed: () {},
                child: const Text('Scarica'),
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Loading',
          child: ItButton(
            loading: true,
            onPressed: () {},
            child: const Text('Caricamento'),
          ),
        ),
        ExampleSection(
          title: 'Disabilitato',
          child: ItButton(
            disabled: true,
            onPressed: () {},
            child: const Text('Non disponibile'),
          ),
        ),
        ExampleSection(
          title: 'Block',
          child: ItButton(
            block: true,
            onPressed: () {},
            child: const Text('Bottone full-width'),
          ),
        ),
      ],
    );
  }
}
