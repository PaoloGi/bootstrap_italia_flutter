import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_helpers.dart';

const _outDir = 'tool/visual_parity/flutter_captures';

void main() {
  testWidgets('capture: button_primary', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/button_primary.png',
      child: ItButton(
        onPressed: () {},
        child: const Text('Bottone'),
      ),
    );
  });

  testWidgets('capture: button_primary_outline', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/button_primary_outline.png',
      child: ItButton(
        outline: true,
        onPressed: () {},
        child: const Text('Bottone'),
      ),
    );
  });

  testWidgets('capture: button_secondary_solid', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/button_secondary_solid.png',
      child: ItButton(
        variant: ItButtonVariant.secondary,
        onPressed: () {},
        child: const Text('Bottone'),
      ),
    );
  });

  testWidgets('capture: button_secondary_outline', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/button_secondary_outline.png',
      child: ItButton(
        variant: ItButtonVariant.secondary,
        outline: true,
        onPressed: () {},
        child: const Text('Bottone'),
      ),
    );
  });
}
