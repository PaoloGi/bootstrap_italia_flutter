import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

const _fontFiles = <String, List<String>>{
  'TitilliumWeb': [
    'fonts/TitilliumWeb-Light.ttf',
    'fonts/TitilliumWeb-Regular.ttf',
    'fonts/TitilliumWeb-SemiBold.ttf',
    'fonts/TitilliumWeb-Bold.ttf',
    'fonts/TitilliumWeb-LightItalic.ttf',
    'fonts/TitilliumWeb-Italic.ttf',
    'fonts/TitilliumWeb-SemiBoldItalic.ttf',
    'fonts/TitilliumWeb-BoldItalic.ttf',
  ],
  'Lora': [
    'fonts/Lora-Regular.ttf',
    'fonts/Lora-Italic.ttf',
  ],
  'RobotoMono': [
    'fonts/RobotoMono-Regular.ttf',
    'fonts/RobotoMono-Italic.ttf',
  ],
};

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await _loadPackageFonts();
  await testMain();
}

Future<void> _loadPackageFonts() async {
  for (final entry in _fontFiles.entries) {
    // Register under both the bare family name and the package-qualified
    // name so tests match regardless of how the TextStyle references it.
    for (final family in [entry.key, 'packages/bootstrap_italia/${entry.key}']) {
      final loader = FontLoader(family);
      for (final path in entry.value) {
        loader.addFont(_loadFontFile(path));
      }
      await loader.load();
    }
  }
}

Future<ByteData> _loadFontFile(String path) async {
  final bytes = await File(path).readAsBytes();
  return ByteData.sublistView(Uint8List.fromList(bytes));
}
