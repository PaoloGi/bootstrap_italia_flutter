import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class BadgePage extends StatelessWidget {
  const BadgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Badge',
      children: [
        ExampleSection(
          title: 'Varianti',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ItBadgeVariant.values
                .map((v) => ItBadge(
                      variant: v,
                      child: Text(v.name),
                    ))
                .toList(),
          ),
        ),
        ExampleSection(
          title: 'Pill',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ItBadge(
                variant: ItBadgeVariant.primary,
                pill: true,
                child: const Text('Nuovo'),
              ),
              ItBadge(
                variant: ItBadgeVariant.danger,
                pill: true,
                child: const Text('3'),
              ),
              ItBadge(
                variant: ItBadgeVariant.success,
                pill: true,
                child: const Text('Attivo'),
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Notification Badge',
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              ItNotificationBadge(
                count: 5,
                child: Icon(Icons.notifications, size: 32),
              ),
              ItNotificationBadge(
                count: 100,
                child: Icon(Icons.mail, size: 32),
              ),
              ItNotificationBadge(
                count: 0,
                child: Icon(Icons.chat, size: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
