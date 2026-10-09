// Contracts for components the coverage guard found untested.
//
// `test/a11y_coverage_test.dart` requires every exported component to appear
// somewhere in this directory. Adding it flagged sixteen, and the flags were
// not noise: among them was **`ItActivatable`** — the widget that supplies
// focus, keyboard activation and the focus ring to most of the package, and the
// thing ADR 0001 is built around. It had been driven indirectly by dozens of
// tests and asserted directly by none, which is exactly the state a coverage
// check exists to surface.
//
// The rest of the flags split cleanly into "genuinely untested" (here) and
// "paints pixels, carries no semantics" (exempted in the guard, with reasons).
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        home: Scaffold(body: Center(child: child)),
      ),
    );

SemanticsNode? _find(WidgetTester tester, bool Function(SemanticsData) test) {
  SemanticsNode? found;
  void walk(SemanticsNode node) {
    if (found != null) return;
    if (test(node.getSemanticsData())) found = node;
    node.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

void main() {
  _offcanvasContract();
  _sidebarContract();
  _bottomNavContract();
  group('ItActivatable — the keyboard foundation', () {
    testWidgets('4.1.2: it does not invent a role', (tester) async {
      // Deliberately NOT a button. ItActivatable supplies operability, and the
      // caller supplies the role — ItCard is a button, ItCardCategory a link,
      // ItBreadcrumb a link. Baking `button: true` in here would mislabel every
      // one of them, so the contract is that it stays silent about role.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItActivatable(onPressed: () {}, child: const Text('Voce')),
      ));

      expect(_find(tester, (d) => d.hasFlag(SemanticsFlag.isButton)), isNull,
          reason:
              'the wrapper must not assert a role its caller has not chosen');
      handle.dispose();
    });

    testWidgets('2.1.1: Enter and Space both activate', (tester) async {
      var fired = 0;
      await tester.pumpWidget(_host(
        ItActivatable(onPressed: () => fired++, child: const Text('Voce')),
      ));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(fired, 1, reason: 'Enter activates');

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(fired, 2, reason: 'Space activates');
    });

    testWidgets('2.4.7: the ring paints only after keyboard focus',
        (tester) async {
      await tester.pumpWidget(_host(
        ItActivatable(onPressed: () {}, child: const Text('Voce')),
      ));
      expect(
        tester.widget<ItFocusRing>(find.byType(ItFocusRing)).visible,
        isFalse,
        reason: 'nothing is painted before focus arrives',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        tester.widget<ItFocusRing>(find.byType(ItFocusRing)).visible,
        isTrue,
        reason: 'a keyboard user must be able to see where they are',
      );
    });

    testWidgets('2.1.1: a disabled control leaves the tab order',
        (tester) async {
      await tester.pumpWidget(_host(
        const ItActivatable(onPressed: null, child: Text('Inerte')),
      ));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final focused = primaryFocus;
      var insideControl = false;
      focused?.context?.visitAncestorElements((e) {
        if (e.widget is ItActivatable) insideControl = true;
        return true;
      });
      expect(insideControl, isFalse,
          reason: 'a control that cannot be activated must not be a tab stop, '
              'or keyboard users pay for it on every traversal');
    });
  });

  group('ItIconAction — label is required on principle', () {
    testWidgets('4.1.2: the glyph-only button is named', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(
        ItIconAction(
          icon: BootstrapItaliaIcons.it_close,
          color: const Color(0xFF0066CC),
          label: 'Chiudi il pannello',
          onPressed: () {},
        ),
      ));

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isButton));
      expect(node, isNotNull);
      expect(node!.getSemanticsData().label, 'Chiudi il pannello',
          reason: 'an icon carries no text, so the name is the only thing a '
              'screen-reader user gets — which is why `label` is required here '
              'rather than optional');
      handle.dispose();
    });
  });

  group('ItBadge — its content must reach AT', () {
    testWidgets('1.1.1: the badge text is announced', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const ItBadge(child: Text('Nuovo'))));

      expect(_find(tester, (d) => d.label.contains('Nuovo')), isNotNull,
          reason: 'a badge that is only painted tells a screen-reader user '
              'nothing, and a badge exists to say something');
      handle.dispose();
    });
  });

  group('ItBackToTop — the positioned wrapper, not just its button', () {
    testWidgets('4.1.2: it is a named control inside a Stack', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_host(
        Stack(
          children: [
            ListView(
                controller: controller,
                children: const [SizedBox(height: 2000)]),
            ItBackToTop(scrollController: controller),
          ],
        ),
      ));

      // It stays hidden until the page has scrolled past `showAfter`, so the
      // control only exists to assert once scrolling has happened — which is
      // also the only state in which a user ever meets it.
      controller.jumpTo(600);
      await tester.pumpAndSettle();

      final node = _find(tester, (d) => d.hasFlag(SemanticsFlag.isButton));
      expect(node, isNotNull, reason: 'the control is a button once revealed');
      expect(node!.getSemanticsData().label, isNotEmpty,
          reason: 'an unnamed icon button is announced as just "button"');
      handle.dispose();
    });
  });
}

// ── ItBottomNav ─────────────────────────────────────────────────────────
//
// A row of four icons is read one item at a time, so each destination has to
// say what it is, whether it is the current one, and where it sits in the bar.
// "Storico, pulsante" alone leaves a screen-reader user with no idea how many
// destinations there are or which one they are on.
void _bottomNavContract() {
  group('ItBottomNav §4.1.2', () {
    Widget host(Widget child) => BootstrapItaliaTheme(
          data: BootstrapItaliaThemeData.standard(),
          child: MaterialApp(home: Scaffold(body: child)),
        );

    const items = [
      ItBottomNavItem(label: 'Crea', icon: Icons.add),
      ItBottomNavItem(label: 'Da Evadere', icon: Icons.edit),
      ItBottomNavItem(label: 'Storico', icon: Icons.history),
    ];

    testWidgets('each destination is named, positioned and states selection',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(ItBottomNav(
        items: items,
        selectedIndex: 2,
        onSelected: (_) {},
        semanticLabel: 'Navigazione principale',
      )));

      final storico = tester.getSemantics(find.text('Storico'));
      expect(storico.label, contains('Storico'));
      expect(storico.value, '3 di 3',
          reason: 'position must be announced — one icon in a row of four '
              'says nothing about where the user is');
      expect(
          storico.getSemanticsData().hasFlag(SemanticsFlag.isSelected), isTrue);

      final crea = tester.getSemantics(find.text('Crea'));
      expect(
          crea.getSemanticsData().hasFlag(SemanticsFlag.isSelected), isFalse);
      handle.dispose();
    });

    testWidgets('the rule slides between destinations', (tester) async {
      Widget bar(int selected) => host(ItBottomNav(
            selectedIndex: selected,
            onSelected: (_) {},
            items: const [
              ItBottomNavItem(label: 'Uno', icon: BootstrapItaliaIcons.it_file),
              ItBottomNavItem(
                  label: 'Due', icon: BootstrapItaliaIcons.it_pencil),
              ItBottomNavItem(
                  label: 'Tre', icon: BootstrapItaliaIcons.it_clock),
            ],
          ));

      double ruleLeft() {
        final finder = find.descendant(
          of: find.byType(ItBottomNav),
          matching: find.byType(ColoredBox),
        );
        for (var i = 0; i < finder.evaluate().length; i++) {
          if (tester.getSize(finder.at(i)).height == ItBottomNav.activeRule) {
            return tester.getRect(finder.at(i)).left;
          }
        }
        return double.nan;
      }

      await tester.pumpWidget(bar(0));
      await tester.pumpAndSettle();
      final from = ruleLeft();

      await tester.pumpWidget(bar(2));
      // Half way through the animation the rule must be BETWEEN the two, not
      // already arrived: that is the difference between moving and jumping.
      await tester.pump(ItBottomNav.activeRuleDuration ~/ 2);
      final midway = ruleLeft();

      await tester.pumpAndSettle();
      final to = ruleLeft();

      expect(to, greaterThan(from), reason: 'it ends over the third item');
      expect(midway, greaterThan(from));
      expect(midway, lessThan(to),
          reason: 'a rule that is already at its destination one frame in is '
              'not animating, it is jumping');
    });

    testWidgets('and does not slide when the platform asks for less motion',
        (tester) async {
      // WCAG 2.3.3. The marker is decorative; a user who has told the OS that
      // movement makes the interface harder to use should get the new position
      // immediately, not a slide.
      Widget bar(int selected) => BootstrapItaliaTheme(
            data: BootstrapItaliaThemeData.standard(),
            child: MaterialApp(
              home: MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: Scaffold(
                  body: const SizedBox.shrink(),
                  bottomNavigationBar: ItBottomNav(
                    selectedIndex: selected,
                    onSelected: (_) {},
                    items: const [
                      ItBottomNavItem(
                          label: 'Uno', icon: BootstrapItaliaIcons.it_file),
                      ItBottomNavItem(
                          label: 'Due', icon: BootstrapItaliaIcons.it_pencil),
                    ],
                  ),
                ),
              ),
            ),
          );

      double ruleLeft() {
        final finder = find.descendant(
          of: find.byType(ItBottomNav),
          matching: find.byType(ColoredBox),
        );
        for (var i = 0; i < finder.evaluate().length; i++) {
          if (tester.getSize(finder.at(i)).height == ItBottomNav.activeRule) {
            return tester.getRect(finder.at(i)).left;
          }
        }
        return double.nan;
      }

      await tester.pumpWidget(bar(0));
      await tester.pumpAndSettle();
      final from = ruleLeft();

      await tester.pumpWidget(bar(1));
      await tester.pump();
      expect(ruleLeft(), greaterThan(from),
          reason: 'with animations disabled the rule is simply already there');
    });

    testWidgets('the home indicator does not sit on top of the labels',
        (tester) async {
      // Reported from a real iPhone: the labels rendered underneath the home
      // indicator. `.bottom-nav` is `position: fixed; bottom: 0`, so the bar
      // is the thing that has to clear it.
      const inset = 34.0; // an iPhone's bottom safe-area inset
      await tester.pumpWidget(BootstrapItaliaTheme(
        data: BootstrapItaliaThemeData.standard(),
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: inset),
            ),
            child: Scaffold(
              body: const SizedBox.shrink(),
              bottomNavigationBar: ItBottomNav(
                selectedIndex: 0,
                onSelected: (_) {},
                items: const [
                  ItBottomNavItem(
                      label: 'Crea', icon: BootstrapItaliaIcons.it_file),
                  ItBottomNavItem(
                      label: 'Storico', icon: BootstrapItaliaIcons.it_clock),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final bar = tester.getRect(find.byType(ItBottomNav));
      final label = tester.getRect(find.text('Crea'));

      // The bar grows by the inset rather than the content shifting down…
      expect(bar.height, ItBottomNav.barHeight + inset,
          reason: 'the background must still reach the screen edge');
      // …and the label clears it.
      expect(label.bottom, lessThanOrEqualTo(bar.bottom - inset),
          reason: 'the labels must sit above the home indicator');
      expect(tester.takeException(), isNull);
    });

    testWidgets('with no inset the bar is exactly the CSS height',
        (tester) async {
      // The other half: on a device with no home indicator nothing is added,
      // so `.bottom-nav ul { height: 64px }` still holds exactly.
      await tester.pumpWidget(host(ItBottomNav(
        selectedIndex: 0,
        onSelected: (_) {},
        items: const [
          ItBottomNavItem(label: 'Crea', icon: BootstrapItaliaIcons.it_file),
        ],
      )));
      await tester.pump();
      expect(tester.getSize(find.byType(ItBottomNav)).height,
          ItBottomNav.barHeight);
    });

    testWidgets('§1.4.1 the active item is marked by shape, not only colour',
        (tester) async {
      // Upstream marks the active item with `color: #06c` and nothing else.
      // That is fine against Blu Italia and fails outright for an
      // administration whose brand sits near the inactive colour — measured at
      // 1.18:1 for one real palette, i.e. the same colour to a sighted user.
      //
      // The rule is present on exactly one item and transparent on the rest,
      // so the state survives greyscale.
      await tester.pumpWidget(host(ItBottomNav(
        selectedIndex: 1,
        onSelected: (_) {},
        items: const [
          ItBottomNavItem(label: 'Uno', icon: BootstrapItaliaIcons.it_file),
          ItBottomNavItem(label: 'Due', icon: BootstrapItaliaIcons.it_pencil),
          ItBottomNavItem(label: 'Tre', icon: BootstrapItaliaIcons.it_clock),
        ],
      )));
      await tester.pump();

      // Scoped by height: the bar paints its own white ColoredBox background
      // too, so matching on the type alone counts that as a rule.
      final finder = find.descendant(
        of: find.byType(ItBottomNav),
        matching: find.byType(ColoredBox),
      );
      final rules = <Rect>[];
      for (var i = 0; i < finder.evaluate().length; i++) {
        if (tester.getSize(finder.at(i)).height == ItBottomNav.activeRule) {
          rules.add(tester.getRect(finder.at(i)));
        }
      }

      // ONE rule for the whole bar, not one per item. It used to be per item —
      // transparent on the inactive ones — which meant its width was the
      // item's, and an item is as wide as its label: 32px over "Crea" and
      // 50.7px over "Da Evadere". A marker that changes size with the length
      // of a word reads as a fault, and a per-item rule cannot slide.
      expect(rules, hasLength(1),
          reason: 'the bar draws a single rule and moves it');
      expect(rules.single.width, ItBottomNav.activeRuleWidth,
          reason: 'the same width on every destination');

      // Above the icon, not across it. The two used to share a top edge.
      final icon = tester.getRect(find
          .descendant(
            of: find.byType(ItBottomNav),
            matching: find.byType(Icon),
          )
          .at(1));
      expect(icon.top - rules.single.bottom, ItBottomNav.activeRuleGap,
          reason: 'the rule must clear the glyph beneath it');

      // And it occupies no layout height — the bar is exactly 64px and its
      // content already fills it, so a rule that took space would clip the
      // label underneath.
      expect(tester.getSize(find.byType(ItBottomNav)).height,
          ItBottomNav.barHeight);
      expect(tester.takeException(), isNull);
    });

    testWidgets('onSelected fires with the tapped index', (tester) async {
      int? tapped;
      await tester.pumpWidget(host(ItBottomNav(
        items: items,
        selectedIndex: 0,
        onSelected: (i) => tapped = i,
      )));

      await tester.tap(find.text('Da Evadere'));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('a null callback disables every destination', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const ItBottomNav(items: items)));

      final crea = tester.getSemantics(find.text('Crea')).getSemanticsData();
      expect(crea.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(crea.hasFlag(SemanticsFlag.isEnabled), isFalse,
          reason: 'the same convention ItSelect had to be taught: no callback '
              'means read-only, and the control must say so');
      handle.dispose();
    });

    testWidgets('a badge is announced, not just painted', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(ItBottomNav(
        items: const [
          ItBottomNavItem(
            label: 'Messaggi',
            icon: Icons.mail,
            badge: 3,
            semanticSuffix: '3 non letti',
          ),
        ],
        onSelected: (_) {},
      )));

      expect(tester.getSemantics(find.text('Messaggi')).label,
          contains('3 non letti'),
          reason: 'a count drawn on the icon is invisible to a screen reader '
              'unless the name carries it');
      handle.dispose();
    });
  });
}

// ── ItSidebar ───────────────────────────────────────────────────────────
//
// A navigation panel that arrives unnamed is a region a screen-reader user has
// to read into before knowing what it is. The heading also has to survive the
// CSS uppercase: upstream transforms it in presentation, and doing that in
// Dart instead would change the string assistive technology reads.
void _sidebarContract() {
  group('ItSidebar §1.3.1 / §4.1.2', () {
    Widget host(Widget child) => BootstrapItaliaTheme(
          data: BootstrapItaliaThemeData.standard(),
          child: MaterialApp(home: Scaffold(body: child)),
        );

    testWidgets('the panel is a named region', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const ItSidebar(
        semanticLabel: 'Navigazione principale',
        child: Text('voci'),
      )));

      expect(
        find.bySemanticsLabel('Navigazione principale'),
        findsOneWidget,
        reason: 'without a name the drawer is an anonymous region',
      );
      handle.dispose();
    });

    testWidgets('the heading is a heading, and AT reads the original casing',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const ItSidebar(
        title: 'Navigazione',
        child: Text('voci'),
      )));

      // Painted uppercase, exactly as `text-transform: uppercase` does.
      expect(find.text('NAVIGAZIONE'), findsOneWidget);

      final node = tester.getSemantics(find.text('NAVIGAZIONE'));
      expect(node.label, 'Navigazione',
          reason: 'uppercasing the accessible name too would have a screen '
              'reader spell or shout it — the transform is presentation only');
      expect(node.getSemanticsData().hasFlag(SemanticsFlag.isHeader), isTrue);
      handle.dispose();
    });

    testWidgets('the dark theme keeps its heading legible', (tester) async {
      await tester.pumpWidget(host(const ItSidebar(
        dark: true,
        title: 'Navigazione',
        child: Text('voci'),
      )));

      final text = tester.widget<Text>(find.text('NAVIGAZIONE'));
      expect(text.style?.color, const Color(0xFFFFFFFF),
          reason: 'body colour on the dark band would be unreadable — the '
              'inverse of the contrast bug this kit already fixed once');
    });
  });
}

// ── ItOffcanvas ─────────────────────────────────────────────────────────
//
// A sliding panel is a focus trap by design. That is correct — a user must not
// wander out of a dialog — but it makes the way OUT the safety-critical part
// (WCAG 2.1.2 No Keyboard Trap), and it is easier to remove by accident than
// to notice missing.
void _offcanvasContract() {
  group('ItOffcanvas §2.1.2 / §4.1.2', () {
    Widget host(Widget child) => BootstrapItaliaTheme(
          data: BootstrapItaliaThemeData.standard(),
          child: MaterialApp(home: Scaffold(body: child)),
        );

    Widget opener({
      String? title,
      bool dismissible = true,
      bool hasOwnCloseAction = false,
      bool showCloseButton = true,
      Widget body = const Text('contenuto del pannello'),
    }) =>
        host(Builder(
          builder: (context) => ItButton(
            onPressed: () => ItOffcanvas.show<void>(
              context: context,
              title: title,
              dismissible: dismissible,
              hasOwnCloseAction: hasOwnCloseAction,
              showCloseButton: showCloseButton,
              body: body,
            ),
            child: const Text('apri'),
          ),
        ));

    testWidgets('it opens, names its route, and shows its body',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(opener(title: 'Menu di navigazione'));

      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();

      expect(find.text('contenuto del pannello'), findsOneWidget);
      expect(find.bySemanticsLabel('Menu di navigazione'), findsWidgets,
          reason: 'a panel that opens unnamed drops the user into an '
              'anonymous layer with no idea what it is');
      handle.dispose();
    });

    testWidgets('the page behind it leaves the tree', (tester) async {
      await tester.pumpWidget(opener(title: 'Menu'));
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();

      // The strongest property of a modal layer, and the one worth testing on
      // every one of them: the content behind is GONE, not merely covered, so
      // a screen-reader user cannot swipe out of the panel into the page.
      final panel = tester.getSemantics(find.text('contenuto del pannello'));
      expect(panel, isNotNull);
      expect(find.text('apri').hitTestable(), findsNothing);
    });

    testWidgets('tapping the barrier closes it', (tester) async {
      await tester.pumpWidget(opener(title: 'Menu'));
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      expect(find.text('contenuto del pannello'), findsOneWidget);

      await tester.tapAt(const Offset(760, 20));
      await tester.pumpAndSettle();
      expect(find.text('contenuto del pannello'), findsNothing);
    });

    testWidgets('the title is painted, not only announced', (tester) async {
      await tester.pumpWidget(opener(title: 'Menu di navigazione'));
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();

      // `.offcanvas-header` is `display:flex` on a plain `.offcanvas` — it is
      // hidden only inside `.navbar-expand*` and the responsive
      // `.offcanvas-{bp}` variants. A title that exists solely as a route name
      // is invisible to everyone who is not using a screen reader.
      expect(find.text('Menu di navigazione'), findsOneWidget,
          reason: 'the panel heading must be on screen, not only in semantics');

      // And painted exactly once. The route already names the layer for AT via
      // `namesRoute`, so a header Text that also carried semantics would make
      // a screen reader say the title twice on open.
      await tester.pumpWidget(opener(title: 'Menu di navigazione'));
      final handle = tester.ensureSemantics();
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Menu di navigazione'), findsOneWidget,
          reason: 'the visible heading must not add a second named node');
      handle.dispose();
    });

    testWidgets('the close button closes it and is named for a panel',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(opener(title: 'Menu'));
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      expect(find.text('contenuto del pannello'), findsOneWidget);

      // Named for what it closes. `closeModal` would tell the user they are
      // leaving a dialog they never entered.
      final close = find.bySemanticsLabel(ItLocalizations.italian.closePanel);
      expect(close, findsOneWidget);

      await tester.tap(close, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('contenuto del pannello'), findsNothing,
          reason: 'the header close button must actually pop the route');
      handle.dispose();
    });

    testWidgets('a tall body scrolls instead of overflowing', (tester) async {
      // `.offcanvas-body { overflow-y: auto }`. Without it the panel is a
      // fixed-height box whose content has nowhere to go, and the first user
      // to hit it is the one at 200% text (WCAG 1.4.4).
      await tester.pumpWidget(opener(
        title: 'Menu',
        body: Column(
          children: List<Widget>.generate(
            40,
            (i) => SizedBox(height: 40, child: Text('riga $i')),
          ),
        ),
      ));
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: '1600px of content in a 600px panel must scroll, not throw');
      expect(find.byType(Scrollable), findsWidgets);
    });

    testWidgets('the panel supplies a text style, not the debug fallback',
        (tester) async {
      // A pushed route sits above the host Scaffold, so it inherits no
      // Material text style. What is left is `DefaultTextStyle.fallback`: no
      // font family, and a **yellow double underline** under every glyph.
      //
      // Nothing asserted about semantics or layout can see this. It was found
      // by rendering the panel to a PNG and looking at it.
      await tester.pumpWidget(opener(title: 'Menu di navigazione'));
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();

      final style = DefaultTextStyle.of(
        tester.element(find.text('contenuto del pannello')),
      ).style;

      expect(style.decoration, isNot(TextDecoration.underline),
          reason: 'the debug fallback underlines everything it touches');
      expect(style.fontFamily, isNotNull,
          reason: 'without a family every glyph falls back to the platform '
              'font, which is the missing-glyph trap from ADR 0001');
      expect(style.fontFamily, contains('Titillium'));
    });

    test('a trap with no exit is asserted against, not shipped', () {
      // `dismissible: false` removes the barrier tap AND Escape together. The
      // header close button is the remaining exit, so the trap only exists
      // once that is turned off too. The assert is the guard; this pins that
      // it exists.
      expect(
        () => ItOffcanvas.show<void>(
          context: _DeadContext(),
          body: const Text('x'),
          dismissible: false,
          showCloseButton: false,
        ),
        throwsA(isA<AssertionError>()),
        reason: 'a non-dismissible panel with no close button and no stated '
            'close action is a keyboard trap and must not be constructible '
            'by accident',
      );

      // The mirror of the above, and the reason it cannot pass vacuously:
      // each of the three exits on its own has to be enough. If the assert
      // ever tightened to demand `dismissible`, this would go red.
      for (final exit in <String>['closeButton', 'ownAction']) {
        expect(
          () => ItOffcanvas.show<void>(
            context: _DeadContext(),
            body: const Text('x'),
            dismissible: false,
            showCloseButton: exit == 'closeButton',
            hasOwnCloseAction: exit == 'ownAction',
          ),
          isNot(throwsA(isA<AssertionError>())),
          reason: '$exit is a way out, so the panel is not a trap',
        );
      }
    });
  });
}

/// Only ever used to reach the assert above, which fires before the context is
/// touched.
class _DeadContext extends StatelessWidget implements BuildContext {
  const _DeadContext();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
