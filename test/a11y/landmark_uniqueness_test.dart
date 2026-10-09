// Landmarks are only wrong in company.
//
// Every other test in this suite mounts ONE component. A navigation landmark
// with no label is perfectly well-formed on its own — the defect appears the
// moment a second one shares the page, and then it is both a Flutter assertion
// ("The navigation landmark role should have a unique label as it is used more
// than once") and a real problem: a screen-reader user listing landmarks gets
// a row of entries they cannot tell apart.
//
// Found by running the whole component set on a device in debug. The release
// web build could not see it — assertions are compiled out — and no widget
// test could, because none of them put two landmarks together.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoLocalizations, DefaultCupertinoLocalizations;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Supplies Material's own strings for any locale.
///
/// The package does not depend on `flutter_localizations`, and `MaterialApp`'s
/// built-in delegate covers only `en` — so declaring an Italian locale without
/// one throws "A MaterialLocalizations delegate that supports the it locale
/// was not found". `test/l10n_test.dart` solves it the same way.
class _AnyLocaleMaterial extends LocalizationsDelegate<MaterialLocalizations> {
  const _AnyLocaleMaterial();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
          const DefaultMaterialLocalizations());
  @override
  bool shouldReload(_AnyLocaleMaterial old) => false;
}

class _AnyLocaleCupertino
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _AnyLocaleCupertino();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
          const DefaultCupertinoLocalizations());
  @override
  bool shouldReload(_AnyLocaleCupertino old) => false;
}

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        localizationsDelegates: const [
          ItLocalizationsDelegate(),
          _AnyLocaleMaterial(),
          _AnyLocaleCupertino(),
        ],
        supportedLocales: ItLocalizations.supportedLocales,
        locale: const Locale('it'),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

/// Every navigation landmark's label, in tree order.
List<String> _navigationLabels(WidgetTester tester) {
  final out = <String>[];
  void walk(SemanticsNode n) {
    if (n.role == SemanticsRole.navigation) out.add(n.label);
    n.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return out;
}

void main() {
  group('§1.3.1 landmarks are distinguishable from one another', () {
    testWidgets('a page with several navigation landmarks names each one',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(Column(
        children: [
          ItNavHeader(items: const [
            ItNavItem(label: 'Uno'),
            ItNavItem(label: 'Due'),
          ]),
          const ItBreadcrumb(items: [
            ItBreadcrumbItem(label: 'Home'),
            ItBreadcrumbItem(label: 'Sezione'),
          ]),
          ItBottomNav(
            selectedIndex: 0,
            onSelected: (_) {},
            items: const [
              ItBottomNavItem(label: 'Uno', icon: BootstrapItaliaIcons.it_file),
              ItBottomNavItem(
                  label: 'Due', icon: BootstrapItaliaIcons.it_pencil),
            ],
          ),
        ],
      )));
      await tester.pumpAndSettle();

      final labels = _navigationLabels(tester);
      expect(labels, isNotEmpty, reason: 'sanity: landmarks are being found');
      expect(labels.where((l) => l.isEmpty), isEmpty,
          reason: 'an unnamed navigation landmark announces as "navigation" '
              'and nothing else: $labels');
      expect(labels.toSet().length, labels.length,
          reason: 'two landmarks share a name, so listing them is useless: '
              '$labels');
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('the defaults are the localised ones', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItNavHeader(items: const [ItNavItem(label: 'Uno')]),
      ));
      await tester.pumpAndSettle();
      expect(_navigationLabels(tester),
          contains(ItLocalizations.italian.mainNavigation));
      handle.dispose();
    });

    testWidgets('and a caller can still override them', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItNavHeader(
          semanticsLabel: 'Navigazione di sezione',
          items: const [ItNavItem(label: 'Uno')],
        ),
      ));
      await tester.pumpAndSettle();
      expect(_navigationLabels(tester), contains('Navigazione di sezione'));
      handle.dispose();
    });
  });
}
