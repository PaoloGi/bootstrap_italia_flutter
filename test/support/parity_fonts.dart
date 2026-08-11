// Font registration for every test that rasterises text.
//
// Shared by `test/flutter_test_config.dart` and
// `tool/visual_parity/capture/flutter_test_config.dart`. It is one file on
// purpose: font registration has broken this package twice — once when a
// `ButtonStyle.textStyle` dropped the family and every glyph became a tofu box,
// and once when the harness registered fonts under a stale package name, which
// masked the very bug it should have caught. Two copies of this list would
// drift, and the drift would be invisible in the parity numbers.
import 'dart:convert';
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

/// Registers the bundled and icon fonts. Call before any test that renders.
Future<void> loadTestFonts() async {
  await _loadPackageFonts();
  await _loadIconFonts();
}

/// Icon fonts are not registered in widget tests by default, so every `Icon`
/// renders as blank space and any capture containing one silently compares an
/// empty region against a real glyph. Load them from the Flutter SDK cache and
/// the pub cache so icons actually rasterise.
Future<void> _loadIconFonts() async {
  final flutterRoot = _flutterRoot();
  final candidates = <String, String?>{
    'MaterialIcons': flutterRoot == null
        ? null
        : '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    'BootstrapItaliaIcons': _resolvePackageFont(
        'bootstrap_italia_icons', 'fonts/BootstrapItaliaIcons.ttf'),
    'BootstrapIcons':
        _resolvePackageFont('bootstrap_icons', 'fonts/BootstrapIcons.ttf'),
  };

  // Icons from a dependency carry fontPackage, so Flutter looks them up under
  // 'packages/<pkg>/<family>'. Register both spellings.
  const packageOf = <String, String>{
    'BootstrapItaliaIcons': 'bootstrap_italia_icons',
    'BootstrapIcons': 'bootstrap_icons',
  };

  for (final entry in candidates.entries) {
    final path = entry.value;
    if (path == null || !File(path).existsSync()) continue;
    final families = <String>[
      entry.key,
      if (packageOf.containsKey(entry.key))
        'packages/${packageOf[entry.key]}/${entry.key}',
    ];
    for (final family in families) {
      final loader = FontLoader(family)..addFont(_loadFontFile(path));
      await loader.load();
    }
  }
}

String? _flutterRoot() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  // resolvedExecutable is <flutter>/bin/cache/dart-sdk/bin/dart
  final sep = Platform.pathSeparator;
  final marker = '${sep}bin${sep}cache${sep}dart-sdk';
  final exe = Platform.resolvedExecutable;
  final idx = exe.indexOf(marker);
  return idx > 0 ? exe.substring(0, idx) : null;
}

/// Locates a font inside a dependency by reading this package's
/// .dart_tool/package_config.json, so it works regardless of pub cache layout.
String? _resolvePackageFont(String package, String relativePath) {
  final configFile = File('.dart_tool/package_config.json');
  if (!configFile.existsSync()) return null;
  final config =
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  for (final entry
      in (config['packages'] as List).cast<Map<String, dynamic>>()) {
    if (entry['name'] != package) continue;
    final rootUri = Uri.parse(entry['rootUri'] as String);
    final root = rootUri.isAbsolute
        ? rootUri.toFilePath()
        : File('.dart_tool/${rootUri.toFilePath()}').absolute.path;
    return '$root${Platform.pathSeparator}$relativePath'.replaceAll(
        '${Platform.pathSeparator}.${Platform.pathSeparator}',
        Platform.pathSeparator);
  }
  return null;
}

Future<void> _loadPackageFonts() async {
  for (final entry in _fontFiles.entries) {
    // Register under both the bare family name and the package-qualified
    // name so tests match regardless of how the TextStyle references it.
    for (final family in [
      entry.key,
      'packages/bootstrap_italia_flutter/${entry.key}'
    ]) {
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
