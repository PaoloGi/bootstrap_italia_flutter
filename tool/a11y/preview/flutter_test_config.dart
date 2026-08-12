import 'dart:async';

import '../../../test/support/parity_fonts.dart';

/// Fonts, for the same reason the parity captures need them: a component that
/// measures text differently lays out differently, and layout drives the order
/// nodes are reported in.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadTestFonts();
  await testMain();
}
