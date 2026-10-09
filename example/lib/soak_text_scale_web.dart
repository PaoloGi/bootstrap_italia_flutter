import 'dart:js_interop';

@JS('window.location.search')
external String get _search;

/// Reads `?textScale=2` from the URL.
///
/// The browser driver needs to exercise 200% text (WCAG 1.4.4) and cannot set
/// Flutter's text scaler from outside the app — it comes from the platform,
/// not from CSS. A query parameter is the smallest hole to open for it.
double urlTextScale() {
  try {
    final m = RegExp(r'textScale=([0-9.]+)').firstMatch(_search);
    final v = m == null ? null : double.tryParse(m.group(1)!);
    return (v == null || v < 0.5 || v > 4) ? 1.0 : v;
  } catch (_) {
    return 1.0;
  }
}
