import 'package:flutter/material.dart';
import 'package:bootstrap_italia/bootstrap_italia.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class TypographyPage extends StatelessWidget {
  const TypographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final typo = BootstrapItaliaTypography.desktop;

    return ComponentPage(
      title: 'Typography',
      children: [
        ExampleSection(
          title: 'Display',
          child: _TypographySample(style: typo.display1, name: 'Display 1'),
        ),
        ExampleSection(
          title: 'Headings',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypographySample(style: typo.h1, name: 'H1'),
              _TypographySample(style: typo.h2, name: 'H2'),
              _TypographySample(style: typo.h3, name: 'H3'),
              _TypographySample(style: typo.h4, name: 'H4'),
              _TypographySample(style: typo.h5, name: 'H5'),
              _TypographySample(style: typo.h6, name: 'H6'),
            ],
          ),
        ),
        ExampleSection(
          title: 'Body & Lead',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypographySample(style: typo.lead, name: 'Lead'),
              _TypographySample(style: typo.bodyText, name: 'Body Text'),
              _TypographySample(style: typo.bodySmall, name: 'Body Small'),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypographySample extends StatelessWidget {
  final TextStyle style;
  final String name;

  const _TypographySample({required this.style, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BootstrapItaliaSpacing.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: BootstrapItaliaColors.gray600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text('The quick brown fox jumps over the lazy dog', style: style),
          const SizedBox(height: 4),
          Text(
            'fontSize: ${style.fontSize}, fontWeight: ${style.fontWeight}, height: ${style.height?.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 11, color: BootstrapItaliaColors.gray500),
          ),
        ],
      ),
    );
  }
}
