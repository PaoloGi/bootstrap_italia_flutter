// The suggestion list is an overlay, and an overlay inherits nothing.
//
// `ItAutocomplete`'s panel is an `OverlayEntry`, so there is no Material and
// no page above it to supply a font: it wraps itself in `ItDefaultTextStyle`
// for exactly that reason. But `DefaultTextStyle` only reaches widgets that
// read it, and the highlighted row was a `RichText`, which does not. Every row
// matching the query — all of them, since `highlightMatch` is on by default —
// rendered in the platform font while the field above it rendered in
// Titillium.
//
// It was found by looking rather than by testing: a README screenshot of an
// open autocomplete came back with the suggestions drawn as filled boxes,
// because on a test binding "no family" means the test font. The same code
// path on a phone means San Francisco or Roboto in the middle of a Bootstrap
// Italia form, which no screenshot in CI would have caught either.
//
// Material is imported here because the control keeps Material's `TextField`
// — the one exception the import-hygiene allow-list records — which is why
// this is not in `no_ambient_material_test.dart`, whose premise is that
// nothing Material is imported at all.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// A host whose ambient text style is Material's own — the font a suggestion
/// row falls back to when it inherits from the page instead of from the
/// panel's own [ItDefaultTextStyle].
Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 400, child: child),
          ),
        ),
      ),
    );

/// Opens the suggestion list on [query] and returns the row's paragraph.
Future<RenderParagraph> _openAndFind(
  WidgetTester tester,
  String query,
  String expected,
) async {
  await tester.enterText(find.byType(EditableText), query);
  // The field debounces before searching, and `onSearch` is asynchronous.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
  return tester
      .renderObjectList<RenderParagraph>(find.byType(RichText))
      .firstWhere(
        (p) => p.text.toPlainText().contains(expected),
        orElse: () => throw StateError(
          'the suggestion list never opened: no text on screen contains '
          '"$expected"',
        ),
      );
}

void main() {
  testWidgets('a highlighted suggestion renders in the package font',
      (tester) async {
    await tester.pumpWidget(_host(
      ItAutocomplete<String>(
        label: 'Comune',
        displayStringForOption: (s) => s,
        onSearch: (q) async => const ['Ancona'],
      ),
    ));

    final suggestion = await _openAndFind(tester, 'Anc', 'Ancona');

    expect(
      suggestion.text.style?.fontFamily,
      'packages/${BootstrapItaliaFontFamily.package}/'
      '${BootstrapItaliaFontFamily.sansSerif}',
      reason: 'a suggestion list in the platform font, under a field in '
          'Titillium, is the font-dropping bug one overlay deeper',
    );

    // And the match is still emphasised — the rich span is what it is for.
    // Searched recursively: `Text.rich` wraps the caller's span in one of its
    // own carrying the resolved style, so the emphasised run sits a level
    // deeper than it did under `RichText`.
    final bold = <TextSpan>[];
    suggestion.text.visitChildren((span) {
      if (span is TextSpan && span.style?.fontWeight == FontWeight.w700) {
        bold.add(span);
      }
      return true;
    });
    expect(bold.single.text, 'Anc');
  });

  testWidgets('an unhighlighted suggestion renders in it too', (tester) async {
    // The other branch: `highlightMatch: false` builds a plain `Text`, which
    // does read DefaultTextStyle. It passed throughout, and pinning it is what
    // makes the test above a statement about the rich span rather than about
    // the panel.
    await tester.pumpWidget(_host(
      ItAutocomplete<String>(
        label: 'Comune',
        highlightMatch: false,
        displayStringForOption: (s) => s,
        onSearch: (q) async => const ['Ancona'],
      ),
    ));

    final suggestion = await _openAndFind(tester, 'Anc', 'Ancona');
    expect(
      suggestion.text.style?.fontFamily,
      'packages/${BootstrapItaliaFontFamily.package}/'
      '${BootstrapItaliaFontFamily.sansSerif}',
    );
  });
}
