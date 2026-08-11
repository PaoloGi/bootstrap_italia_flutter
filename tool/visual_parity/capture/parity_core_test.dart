import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
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

  // ── Badge ────────────────────────────────────────────────────────
  // Labels must match the reference story's text exactly: different text
  // means different width, which dominates the similarity score.

  testWidgets('capture: badge_primary', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/badge_primary.png',
      child: const ItBadge(child: Text('Primary')),
    );
  });

  testWidgets('capture: badge_secondary', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/badge_secondary.png',
      child: const ItBadge(
        variant: ItBadgeVariant.secondary,
        child: Text('Secondary'),
      ),
    );
  });

  testWidgets('capture: badge_success', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/badge_success.png',
      child: const ItBadge(
        variant: ItBadgeVariant.success,
        child: Text('Success'),
      ),
    );
  });

  testWidgets('capture: badge_danger', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/badge_danger.png',
      child: const ItBadge(
        variant: ItBadgeVariant.danger,
        child: Text('Danger'),
      ),
    );
  });

  testWidgets('capture: badge_pill', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/badge_pill.png',
      child: const ItBadge(
        variant: ItBadgeVariant.secondary,
        pill: true,
        child: Text('Badge'),
      ),
    );
  });

  // ── Alert ────────────────────────────────────────────────────────
  // The reference alert is a block element 868px wide in the story; it must be
  // given the same width constraint or the width difference dominates the diff.
  testWidgets('capture: alert_success', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/alert_success.png',
      surfaceSize: const Size(1000, 400),
      child: const SizedBox(
        width: 868,
        child: ItAlert(
          variant: ItAlertVariant.success,
          // CSS paints a 32px success glyph via background-image. Use the real
          // Italia icon set rather than a Material lookalike — the stroke
          // weights differ noticeably otherwise.
          icon: BootstrapItaliaIcons.it_check_circle,
          body: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Questo è un alert di '),
                TextSpan(
                  text: 'success',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '!'),
              ],
            ),
          ),
        ),
      ),
    );
  });

  // ── Chip ─────────────────────────────────────────────────────────
  testWidgets('capture: chip_simple', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/chip_simple.png',
      child: const ItChip(label: 'Label'),
    );
  });

  // ── Spinner ──────────────────────────────────────────────────────
  // Only the resting ring is diffed: the animating variant would depend on
  // which frame the harness happened to sample. `animating: false` is now
  // explicit — the default spins, as a loading indicator must.
  testWidgets('capture: spinner_default', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/spinner_default.png',
      child: const ItSpinner(animating: false),
    );
  });
}
