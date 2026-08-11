import 'dart:async';

import 'support/parity_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadTestFonts();
  await testMain();
}
