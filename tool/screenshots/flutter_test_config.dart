import 'dart:async';

import '../../test/support/parity_fonts.dart';

/// These shots live outside `test/`, so they inherit no configuration from it
/// — including the font registration, without which every glyph rasterises as
/// a filled box and the screenshots show the layout with the words blacked
/// out. Flutter finds this file by walking up from the test's own directory,
/// so it has to sit here.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadTestFonts();
  await testMain();
}
