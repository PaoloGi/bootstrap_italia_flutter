// Pins the meaning of "responsive" in this package.
//
// CSS `@media` queries are VIEWPORT-based. A Flutter `LayoutBuilder` is
// CONTAINER-based — it switches on the width the parent happens to give a
// widget. The two agree only when a component is full-bleed, which is why the
// difference went unnoticed: every parity capture renders components at full
// width.
//
// Measured against the official React kit before this was fixed: at a 1280px
// viewport with the nav band constrained to 375px, React kept the desktop nav
// (letting the links wrap) while Flutter collapsed to the hamburger. The package
// was also internally inconsistent — `context.breakpoint` and the responsive
// typography used MediaQuery while these two components used LayoutBuilder, so
// two components in one layout could disagree about the current breakpoint.
//
// Decision: viewport-based everywhere, resolved through
// `BootstrapItaliaTheme.breakpointOf`. `ItResponsiveBuilder` remains available
// for the cases where container-based behaviour is genuinely what you want.
//
// These tests exist so that reverting a component to `LayoutBuilder` fails
// loudly rather than silently re-introducing the divergence.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _items = [
  ItNavItem(label: 'Link 1', active: true),
  ItNavItem(label: 'Link 2'),
];

/// Pumps [child] at a real viewport, optionally constrained to a narrower box —
/// the situation that separates the two rules.
///
/// The surface size must be set as well as MediaQuery: MediaQuery.size is only
/// metadata, so setting it alone leaves layout on the test's default 800x600 and
/// a container-based widget would silently disagree with a viewport-based one
/// for the wrong reason.
Future<void> _pumpAt(
  WidgetTester tester, {
  required double viewport,
  double? constrainTo,
  required Widget child,
}) async {
  await tester.binding.setSurfaceSize(Size(viewport, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(BootstrapItaliaTheme(
    data: BootstrapItaliaThemeData.standard(),
    child: MediaQuery(
      data: MediaQueryData(size: Size(viewport, 800)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: constrainTo == null
              ? child
              : SizedBox(width: constrainTo, child: child),
        ),
      ),
    ),
  ));
  await tester.pump();
}

/// The mobile band collapses behind a toggler; the desktop band has none.
/// Checking for the toggler is more reliable than looking for link text, which
/// the mobile band also renders inside its collapsed menu.
bool _isDesktop(WidgetTester tester) =>
    find.byType(ItIconAction).evaluate().isEmpty;

void main() {
  group('breakpoints follow the viewport, not the container', () {
    testWidgets('ItNavHeader: wide viewport, full width -> desktop',
        (tester) async {
      await _pumpAt(tester,
          viewport: 1280, child: const ItNavHeader(items: _items));
      expect(_isDesktop(tester), isTrue);
    });

    testWidgets(
        'ItNavHeader: wide viewport but NARROW container -> still desktop',
        (tester) async {
      await _pumpAt(tester,
          viewport: 1280,
          constrainTo: 375,
          child: const ItNavHeader(items: _items));

      expect(
        _isDesktop(tester),
        isTrue,
        reason: 'this is the case that diverged: the reference implementation '
            'keeps the desktop nav at a 1280px viewport regardless of the '
            'container, because @media queries are viewport-based. A '
            'LayoutBuilder here would collapse to the hamburger.',
      );
    });

    testWidgets('ItNavHeader: narrow viewport -> mobile', (tester) async {
      await _pumpAt(tester,
          viewport: 375, child: const ItNavHeader(items: _items));
      expect(_isDesktop(tester), isFalse);
    });

    testWidgets('ItNavHeader: below the lg breakpoint (992) -> mobile',
        (tester) async {
      await _pumpAt(tester,
          viewport: 768, child: const ItNavHeader(items: _items));
      expect(_isDesktop(tester), isFalse,
          reason: 'lg is 992px, so 768 is mobile');
    });

    testWidgets('the whole package agrees on the current breakpoint',
        (tester) async {
      // The internal inconsistency mattered as much as the divergence: with two
      // rules in play, responsive typography could report "desktop" while the
      // nav beside it rendered "mobile".
      late bool ctxIsDesktop;
      await _pumpAt(tester, viewport: 1280, constrainTo: 375,
          child: Builder(builder: (context) {
        ctxIsDesktop = context.isDesktop;
        return const ItNavHeader(items: _items);
      }));

      expect(ctxIsDesktop, isTrue);
      expect(_isDesktop(tester), equals(ctxIsDesktop),
          reason: 'context.isDesktop and the nav band must never disagree');
    });
  });

  group('ItResponsiveBuilder is the container-based escape hatch', () {
    testWidgets('it switches on the container, not the viewport',
        (tester) async {
      await _pumpAt(tester,
          viewport: 1280,
          constrainTo: 375,
          child: ItResponsiveBuilder(
            xs: (_) => const Text('narrow'),
            lg: (_) => const Text('wide'),
          ));

      expect(
        find.text('narrow'),
        findsOneWidget,
        reason: 'ItResponsiveBuilder deliberately keeps LayoutBuilder '
            'semantics — it is how a caller opts into container-based '
            'behaviour now that the components themselves are viewport-based. '
            'At a 1280px viewport it still reports narrow, because its box is 375.',
      );
    });

    testWidgets('unconstrained, it agrees with the viewport', (tester) async {
      await _pumpAt(tester,
          viewport: 1280,
          child: ItResponsiveBuilder(
            xs: (_) => const Text('narrow'),
            lg: (_) => const Text('wide'),
          ));

      expect(find.text('wide'), findsOneWidget);
    });
  });
}
