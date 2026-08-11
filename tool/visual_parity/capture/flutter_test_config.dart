import 'dart:async';

import '../../../test/support/parity_fonts.dart';

/// These capture jobs live outside `test/`, so they get no configuration from
/// it — including the font registration, without which every glyph rasterises
/// as a tofu box and every capture scores against the wrong pixels. Flutter
/// finds this file by walking up from the test's own directory, so it must sit
/// here rather than being inherited.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadTestFonts();
  await testMain();
}
