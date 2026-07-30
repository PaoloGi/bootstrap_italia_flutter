import 'package:flutter/painting.dart';

/// Bootstrap Italia shadow definitions.
abstract final class BootstrapItaliaShadows {
  /// Small shadow.
  static const BoxShadow sm = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  /// Default shadow.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Large shadow.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}
