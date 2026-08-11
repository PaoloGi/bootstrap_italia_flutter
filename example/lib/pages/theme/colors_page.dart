import 'package:flutter/material.dart';
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class ColorsPage extends StatelessWidget {
  const ColorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Colors',
      children: [
        ExampleSection(
          title: 'Primary & Semantic',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space3,
            runSpacing: BootstrapItaliaSpacing.space3,
            children: const [
              _ColorSwatch(
                  color: BootstrapItaliaColors.primary, label: 'primary'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.secondary, label: 'secondary'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.success, label: 'success'),
              _ColorSwatch(color: BootstrapItaliaColors.info, label: 'info'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.warning, label: 'warning'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.danger, label: 'danger'),
              _ColorSwatch(color: BootstrapItaliaColors.light, label: 'light'),
              _ColorSwatch(color: BootstrapItaliaColors.dark, label: 'dark'),
            ],
          ),
        ),
        ExampleSection(
          title: 'Gray Scale',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space3,
            runSpacing: BootstrapItaliaSpacing.space3,
            children: const [
              _ColorSwatch(
                  color: BootstrapItaliaColors.gray100, label: 'gray100'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.gray200, label: 'gray200'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.gray300, label: 'gray300'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.gray400, label: 'gray400'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.gray500, label: 'gray500'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.gray600, label: 'gray600'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.gray700, label: 'gray700'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.gray800, label: 'gray800'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.gray900, label: 'gray900'),
            ],
          ),
        ),
        ExampleSection(
          title: 'Italia-Specific',
          child: Wrap(
            spacing: BootstrapItaliaSpacing.space3,
            runSpacing: BootstrapItaliaSpacing.space3,
            children: const [
              _ColorSwatch(
                  color: BootstrapItaliaColors.neutral1, label: 'neutral1'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.neutral2, label: 'neutral2'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.analogue1, label: 'analogue1'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.analogue2, label: 'analogue2'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.complementary1,
                  label: 'complementary1'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.complementary2,
                  label: 'complementary2'),
              _ColorSwatch(
                  color: BootstrapItaliaColors.complementary3,
                  label: 'complementary3'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorSwatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    // `Color.value` is deprecated; toARGB32() is the explicit replacement.
    final hex =
        '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: BootstrapItaliaColors.gray300),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          Text(
            hex,
            style: const TextStyle(
                fontSize: 10, color: BootstrapItaliaColors.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
