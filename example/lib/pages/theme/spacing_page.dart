import 'package:flutter/material.dart';
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class SpacingPage extends StatelessWidget {
  const SpacingPage({super.key});

  static const _spacings = <String, double>{
    'space0': BootstrapItaliaSpacing.space0,
    'space1': BootstrapItaliaSpacing.space1,
    'space2': BootstrapItaliaSpacing.space2,
    'space3': BootstrapItaliaSpacing.space3,
    'space4': BootstrapItaliaSpacing.space4,
    'space5': BootstrapItaliaSpacing.space5,
  };

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Spacing',
      children: [
        ExampleSection(
          title: 'Spacing Scale',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _spacings.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(
                    bottom: BootstrapItaliaSpacing.space3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      width: entry.value == 0 ? 2 : entry.value * 3,
                      height: 24,
                      decoration: BoxDecoration(
                        color: BootstrapItaliaColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: BootstrapItaliaSpacing.space2),
                    Text(
                      '${entry.value.toInt()} px',
                      style: const TextStyle(
                        fontSize: 13,
                        color: BootstrapItaliaColors.gray600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
