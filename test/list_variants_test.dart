// The list capabilities the Bootstrap Italia docs page shows and this package
// could not express.
//
// Two families share that page. `.link-list` — the navigation menu rows — was
// here but had no heading, no hand-placed divider, no `.large`/`.medium`
// modifiers and no `.link-sublist`, so four of its six documented sections had
// no equivalent. `.it-list` — the content rows, with a leading avatar or
// thumbnail, a paragraph, metadata and per-row actions — was absent entirely,
// which is the whole first half of the page.
//
// Values are asserted against `bootstrap-italia.min.css` v2.18.0, cited at each
// expectation.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double width = 800}) {
  final data = BootstrapItaliaThemeData.standard();
  return BootstrapItaliaTheme(
    data: data,
    child: MaterialApp(
      theme: data.toThemeData(),
      home: MediaQuery(
        // The row size modifiers and the content list's type scale are both
        // breakpoint-dependent, so the viewport has to be stated rather than
        // inherited from whatever the test binding defaults to.
        data: MediaQueryData(size: Size(width, 900)),
        child: Scaffold(body: SizedBox(width: width, child: child)),
      ),
    ),
  );
}

TextStyle _style(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!;

/// The divider rules currently painted, by their [ColoredBox]es.
int _rules(WidgetTester tester) => tester
    .widgetList<ColoredBox>(find.byType(ColoredBox))
    .where((b) => b.color == const Color(0xFFC5C7C9))
    .length;

void main() {
  group('.link-list-heading — an optional heading above the list', () {
    testWidgets('unlinked, it is 1.125rem semibold in the body colour',
        (t) async {
      await t.pumpWidget(_host(const ItList(
        heading: 'Intestazione',
        items: [ItListItem(title: 'Voce')],
      )));

      final s = _style(t, 'Intestazione');
      expect(s.fontSize, 18,
          reason: '`.link-list-wrapper .list-item-title, .link-list-heading '
              '{ font-size: 1.125rem }`');
      expect(s.fontWeight, FontWeight.w600, reason: '`font-weight: 600`');
      expect(s.color, BootstrapItaliaColors.bodyColor,
          reason: '`color: hsl(0,0%,10%)`, byte-identical to --bs-body-color '
              'and in the role that token names');
    });

    testWidgets('linked, it drops to 1rem and takes the link colour',
        (t) async {
      // Not a decoration that can be bolted on: `.link-list-heading a` restates
      // both the size and the line box, so the linked heading is a different
      // object from the unlinked one.
      await t.pumpWidget(_host(ItList(
        heading: 'Intestazione',
        onHeadingTap: () {},
        items: const [ItListItem(title: 'Voce')],
      )));

      final s = _style(t, 'Intestazione');
      expect(s.fontSize, 16,
          reason: '`.link-list-heading a { font-size: 1rem }`');
      expect(s.color, BootstrapItaliaColors.primary);
    });

    testWidgets('the heading re-themes with the scheme', (t) async {
      const paper = Color(0xFF2B2B2B);
      await t.pumpWidget(BootstrapItaliaTheme(
        data: BootstrapItaliaThemeData(
          colors:
              BootstrapItaliaColorScheme.standard.copyWith(bodyColor: paper),
        ),
        child: const MaterialApp(
          home: Scaffold(
            body: ItList(
              heading: 'Intestazione',
              items: [ItListItem(title: 'Voce')],
            ),
          ),
        ),
      ));
      expect(_style(t, 'Intestazione').color, paper);
    });
  });

  group('ItListDivider — a rule where the docs put one', () {
    testWidgets('an explicit divider paints one rule', (t) async {
      await t.pumpWidget(_host(const ItList(
        showDividers: false,
        items: [
          ItListItem(title: 'Uno'),
          ItListDivider(),
          ItListItem(title: 'Due'),
        ],
      )));
      expect(_rules(t), 1);
    });

    testWidgets('an explicit divider never doubles with an automatic one',
        (t) async {
      // With `showDividers` left on, the naive implementation rules between
      // every pair AND paints the hand-placed one, giving two lines 8px apart
      // where the docs show one.
      await t.pumpWidget(_host(const ItList(
        items: [
          ItListItem(title: 'Uno'),
          ItListDivider(),
          ItListItem(title: 'Due'),
        ],
      )));
      expect(_rules(t), 1);
    });

    testWidgets('automatic dividers still rule between plain rows', (t) async {
      await t.pumpWidget(_host(const ItList(items: [
        ItListItem(title: 'Uno'),
        ItListItem(title: 'Due'),
        ItListItem(title: 'Tre'),
      ])));
      expect(_rules(t), 2, reason: 'unchanged default — three rows, two rules');
    });
  });

  group('.large and .medium', () {
    testWidgets('.large is 1.125rem', (t) async {
      await t.pumpWidget(_host(const ItList(items: [
        ItListItem(title: 'Grande', large: true),
      ])));
      expect(_style(t, 'Grande').fontSize, 18,
          reason: '`.link-list-wrapper ul li a.large { font-size: 1.125rem }`');
    });

    testWidgets('.large gains its taller padding only from sm up', (t) async {
      // `@media (min-width: 576px) { … a.large { padding-top: .5rem;
      // padding-bottom: .5rem } }` — below the breakpoint the label grows and
      // the padding does not.
      await t.pumpWidget(_host(
        const ItList(items: [ItListItem(title: 'Grande', large: true)]),
        width: 400,
      ));
      final narrow = t.getSize(find.byType(ItList)).height;

      await t.pumpWidget(_host(
        const ItList(items: [ItListItem(title: 'Grande', large: true)]),
        width: 800,
      ));
      final wide = t.getSize(find.byType(ItList)).height;

      expect(wide - narrow, 8,
          reason: '4px of extra padding top and bottom at sm and up');
    });

    testWidgets('.medium is a weight, not a size', (t) async {
      // The kit's own nested-list markup is `class="large medium"`, which only
      // makes sense once you know the second is a font weight.
      await t.pumpWidget(_host(const ItList(items: [
        ItListItem(title: 'Semigrassetto', medium: true),
      ])));
      final s = _style(t, 'Semigrassetto');
      expect(s.fontWeight, FontWeight.w600,
          reason: '`.link-list-wrapper ul li a.medium { font-weight: 600 }`');
      expect(s.fontSize, 16, reason: 'the base size is untouched');
    });

    testWidgets('the two compose', (t) async {
      await t.pumpWidget(_host(const ItList(items: [
        ItListItem(title: 'Entrambi', large: true, medium: true),
      ])));
      final s = _style(t, 'Entrambi');
      expect(s.fontSize, 18);
      expect(s.fontWeight, FontWeight.w600);
    });
  });

  group('.link-sublist — nested navigation', () {
    testWidgets('a sublist is indented 24px under a plain parent', (t) async {
      await t.pumpWidget(_host(const ItList(showDividers: false, items: [
        ItListItem(
          title: 'Genitore',
          children: [ItListItem(title: 'Figlio')],
        ),
      ])));

      expect(t.getTopLeft(find.text('Genitore')).dx, 24,
          reason: "the parent's own gutter, `padding: .25rem 24px`");
      expect(t.getTopLeft(find.text('Figlio')).dx, 48,
          reason: '`.link-list-wrapper ul.link-sublist { padding-left: 24px }` '
              "on top of the child's own 24px gutter");
    });

    testWidgets('an icon-bearing parent drops the sublist indent', (t) async {
      // `.link-list-wrapper ul li a.icon-right + ul { padding-left: 0 }` — the
      // parent already gave up its own 24px gutter to align the icon with the
      // list edge, so indenting the children a second time would step them
      // twice for one level of nesting. Asserted as absolute positions rather
      // than as a parent/child delta: the delta is 24 either way, and only the
      // absolute values show which of the two 24s is missing.
      await t.pumpWidget(_host(const ItList(showDividers: false, items: [
        ItListItem(
          title: 'Genitore',
          trailing: Icon(Icons.link, size: 32),
          children: [ItListItem(title: 'Figlio')],
        ),
      ])));

      expect(t.getTopLeft(find.text('Genitore')).dx, 0,
          reason: '`a.icon-right { padding-left: 0 }`');
      expect(t.getTopLeft(find.text('Figlio')).dx, 24,
          reason: "only the child's own gutter — the sublist adds nothing");
    });

    testWidgets('a collapsible group opens and closes on tap', (t) async {
      await t.pumpWidget(_host(const ItList(showDividers: false, items: [
        ItListItem(
          title: 'Genitore',
          collapsible: true,
          trailing: Icon(Icons.expand_more, size: 32),
          children: [ItListItem(title: 'Figlio')],
        ),
      ])));

      expect(find.text('Figlio'), findsNothing);
      await t.tap(find.text('Genitore'));
      await t.pumpAndSettle();
      expect(find.text('Figlio'), findsOneWidget);
      await t.tap(find.text('Genitore'));
      await t.pumpAndSettle();
      expect(find.text('Figlio'), findsNothing);
    });

    testWidgets('an open group turns its indicator through a half turn',
        (t) async {
      // `.link-list-wrapper ul li a[aria-expanded=true] .icon
      // { transform: scale(-1) }` — both axes, so a chevron pointing down comes
      // back pointing up rather than mirrored.
      await t.pumpWidget(_host(const ItList(showDividers: false, items: [
        ItListItem(
          title: 'Genitore',
          collapsible: true,
          initiallyExpanded: true,
          trailing: Icon(Icons.expand_more, size: 32),
          children: [ItListItem(title: 'Figlio')],
        ),
      ])));

      final transform = t.widget<Transform>(find.ancestor(
        of: find.byIcon(Icons.expand_more),
        matching: find.byType(Transform),
      ));
      expect(transform.transform.getColumn(0).x, -1);
      expect(transform.transform.getColumn(1).y, -1);
    });

    testWidgets('initiallyExpanded opens the group from the first frame',
        (t) async {
      await t.pumpWidget(_host(const ItList(showDividers: false, items: [
        ItListItem(
          title: 'Genitore',
          collapsible: true,
          initiallyExpanded: true,
          children: [ItListItem(title: 'Figlio')],
        ),
      ])));
      expect(find.text('Figlio'), findsOneWidget);
    });
  });

  group('.icon-left', () {
    testWidgets('a leading icon sits 8px from the label, not 24', (t) async {
      // `.link-list-wrapper ul li a.list-item.icon-left .icon
      // { margin-right: 8px }`. This gap was 24 — the row's own gutter — for
      // the whole of the pixel-parity pass, because all three list captures put
      // their icon on the right and nothing exercised `leading`.
      await t.pumpWidget(_host(const ItList(items: [
        ItListItem(title: 'Voce', leading: Icon(Icons.link, size: 32)),
      ])));

      final iconRight = t.getBottomRight(find.byIcon(Icons.link)).dx;
      final labelLeft = t.getTopLeft(find.text('Voce')).dx;
      expect(labelLeft - iconRight, 8);
    });

    testWidgets('a disabled row greys its glyph as well as its label',
        (t) async {
      // `.link-list-wrapper ul li a.disabled svg { fill: hsl(210,3%,85%) }`.
      // Supplied through IconTheme, so an icon that names its own colour still
      // wins — which is what the parity captures do.
      await t.pumpWidget(_host(const ItList(items: [
        ItListItem(
          title: 'Voce',
          disabled: true,
          trailing: Icon(Icons.link, size: 32),
        ),
      ])));

      final theme = IconTheme.of(
        t.element(find.byIcon(Icons.link)),
      );
      expect(theme.color, const Color(0xFFD8D9DA));
    });
  });

  group('ItListCustom — a form control in a list of links', () {
    testWidgets('it gets the list gutter and nothing else', (t) async {
      await t.pumpWidget(_host(ItList(showDividers: false, items: [
        ItListCustom(
          child: ItToggle(value: false, label: 'Toggle', onChanged: (_) {}),
        ),
      ])));

      // `.link-list-wrapper ul .toggles label { padding: 0 24px }` and
      // `.link-list-wrapper ul .form-check.form-check-group { padding: 0 24px }`
      // — one gutter, two kinds of control.
      expect(t.getTopLeft(find.byType(ItToggle)).dx, 24);
    });

    testWidgets('gutter: false leaves the row flush', (t) async {
      await t.pumpWidget(_host(ItList(showDividers: false, items: [
        ItListCustom(
          gutter: false,
          child: ItToggle(value: false, label: 'Toggle', onChanged: (_) {}),
        ),
      ])));
      expect(t.getTopLeft(find.byType(ItToggle)).dx, 0);
    });
  });

  // ── `.it-list` — the content family, which did not exist ────────────────
  group('ItContentList — `.it-list`', () {
    testWidgets('the title is 1rem semibold, 1.125rem from lg up', (t) async {
      await t.pumpWidget(_host(
        const ItContentList(items: [ItContentListItem(text: 'Testo')]),
        width: 800,
      ));
      expect(_style(t, 'Testo').fontSize, 16,
          reason: '`.it-right-zone .text { font-size: 1rem }`');
      expect(_style(t, 'Testo').fontWeight, FontWeight.w600,
          reason: '`font-weight: 600` — heavier than the link list next door, '
              'which is 400');

      await t.pumpWidget(_host(
        const ItContentList(items: [ItContentListItem(text: 'Testo')]),
        width: 1000,
      ));
      expect(_style(t, 'Testo').fontSize, 18,
          reason: '`@media (min-width: 992px) { … { font-size: 1.125rem } }`');
    });

    testWidgets('a linked row is primary and underlined at rest', (t) async {
      await t.pumpWidget(_host(ItContentList(items: [
        ItContentListItem(text: 'Link', onTap: () {}),
      ])));
      final s = _style(t, 'Link');
      expect(s.color, BootstrapItaliaColors.primary,
          reason: '`a { color: var(--bs-link-color) }` with '
              '`--bs-link-color: hsl(210,100%,40%)`');
      expect(s.decoration, TextDecoration.underline,
          reason: '`.it-list a .text { text-decoration: underline }`');
    });

    testWidgets('a static row is body copy with no underline', (t) async {
      await t.pumpWidget(_host(const ItContentList(items: [
        ItContentListItem(text: 'Testo'),
      ])));
      final s = _style(t, 'Testo');
      expect(s.color, BootstrapItaliaColors.bodyColor);
      expect(s.decoration, TextDecoration.none);
    });

    testWidgets('hover removes the underline and darkens, from xl up',
        (t) async {
      // The opposite of the link list, which *adds* an underline on hover.
      // `@media (min-width: 1200px) { .it-list a.list-item:hover
      // { color: rgb(0,76.5,153); text-decoration: none } }`
      await t.pumpWidget(_host(
        ItContentList(items: [ItContentListItem(text: 'Link', onTap: () {})]),
        width: 1300,
      ));

      final gesture =
          await t.createGesture(kind: PointerDeviceKind.mouse, pointer: 1);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(t.getCenter(find.text('Link')));
      await t.pumpAndSettle();

      final s = _style(t, 'Link');
      expect(s.decoration, TextDecoration.none);
      expect(s.color, itShade(BootstrapItaliaColors.primary, 0.25),
          reason: 'rgb(0, 76.5, 153) is exactly 0.75 x primary');
    });

    testWidgets('the description and the metadata are the declared grey',
        (t) async {
      await t.pumpWidget(_host(const ItContentList(items: [
        ItContentListItem(
          text: 'Testo',
          description: 'Lorem ipsum',
          metadata: 'metadata testo',
        ),
      ])));

      // Both `hsl(210,17%,44%)`. Muted metadata, so the grey the stylesheet
      // also declares as --bs-gray-secondary, NOT the themeable accent.
      expect(
          _style(t, 'Lorem ipsum').color, BootstrapItaliaColors.graySecondary);
      expect(_style(t, 'Lorem ipsum').fontSize, 14,
          reason: '`.text + p { font-size: .875rem }`');
      expect(_style(t, 'metadata testo').color,
          BootstrapItaliaColors.graySecondary);
      expect(_style(t, 'metadata testo').fontSize, 12,
          reason: '`.metadata { font-size: .75rem }`');
      expect(_style(t, 'metadata testo').letterSpacing, 0.5,
          reason: '`letter-spacing: .5px`');
    });

    testWidgets('the grey does NOT follow a retinted secondary', (t) async {
      await t.pumpWidget(BootstrapItaliaTheme(
        data: BootstrapItaliaThemeData(
          colors: BootstrapItaliaColorScheme.standard
              .copyWith(secondary: const Color(0xFF7A1FA2)),
        ),
        child: const MaterialApp(
          home: Scaffold(
            body: ItContentList(items: [
              ItContentListItem(text: 'Testo', metadata: 'metadata'),
            ]),
          ),
        ),
      ));
      expect(_style(t, 'metadata').color, BootstrapItaliaColors.graySecondary,
          reason: 'an administration retinting secondary wants its buttons '
              'recoloured, not its metadata — the same call the card date '
              'makes');
    });

    testWidgets('every row carries the bottom rule', (t) async {
      await t.pumpWidget(_host(const ItContentList(items: [
        ItContentListItem(text: 'Uno'),
        ItContentListItem(text: 'Due'),
      ])));

      final boxes = t
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => b.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.border?.bottom.color == const Color(0xFFC5C7C9));
      expect(boxes, hasLength(2),
          reason: '`.list-item { border-bottom: 1px solid hsl(210,4%,78%) }` '
              'is on every row, the last one included');
    });

    testWidgets('metadata inside .it-multiple takes its own line', (t) async {
      // `.it-multiple { flex-wrap: wrap }` with `.it-multiple .metadata
      // { width: 100%; text-align: right }` — the full-width metadata forces
      // the wrap, so the icons land on the line below it.
      await t.pumpWidget(_host(ItContentList(items: [
        ItContentListItem(
          text: 'Testo',
          metadata: 'metadata',
          actions: [
            ItListAction(
                icon: Icons.code, label: 'Testo - Azione', onPressed: () {}),
          ],
        ),
      ])));

      expect(t.getCenter(find.byIcon(Icons.code)).dy,
          greaterThan(t.getCenter(find.text('metadata')).dy));
    });

    testWidgets('an action glyph is 24px and follows primary', (t) async {
      await t.pumpWidget(_host(ItContentList(items: [
        ItContentListItem(
          text: 'Testo',
          actions: [
            ItListAction(
                icon: Icons.code, label: 'Testo - Azione', onPressed: () {}),
          ],
        ),
      ])));

      final icon = t.widget<Icon>(find.byIcon(Icons.code));
      expect(icon.size, 24,
          reason: '`.it-right-zone svg { width: 24px; height: 24px }`');
      expect(icon.color, BootstrapItaliaColors.primary,
          reason: '`.it-right-zone svg { fill: #06c }`');
    });

    testWidgets('actions fire', (t) async {
      var fired = 0;
      await t.pumpWidget(_host(ItContentList(items: [
        ItContentListItem(
          text: 'Testo',
          actions: [
            ItListAction(
                icon: Icons.code,
                label: 'Testo - Azione',
                onPressed: () => fired++),
          ],
        ),
      ])));
      await t.tap(find.byIcon(Icons.code));
      expect(fired, 1);
    });

    testWidgets('ItRoundedIcon is a 40px box holding a 32px glyph', (t) async {
      await t.pumpWidget(_host(const ItContentList(items: [
        ItContentListItem(
          leading: ItRoundedIcon(icon: Icons.folder),
          text: 'Testo',
        ),
      ])));

      expect(t.getSize(find.byType(ItRoundedIcon)), const Size(40, 40),
          reason: '`.it-rounded-icon { width: 40px }` beside a 40px avatar '
              'and thumbnail');
      final icon = t.widget<Icon>(find.byIcon(Icons.folder));
      expect(icon.size, 32, reason: "Bootstrap Italia's `.icon` default");
      expect(icon.color, const Color(0xFF207BD6),
          reason: '`.it-rounded-icon svg { fill: rgb(32.13,123.165,214.2) }` — '
              'the kit\'s .primary-color-a5, which is about the brand blue but '
              'is not derivable from it: it lightens AND desaturates');
    });

    testWidgets('the leading slot sits 16px from the text', (t) async {
      await t.pumpWidget(_host(const ItContentList(items: [
        ItContentListItem(
          leading: ItRoundedIcon(icon: Icons.folder),
          text: 'Testo',
        ),
      ])));

      final leadingRight = t.getBottomRight(find.byType(ItRoundedIcon)).dx;
      expect(t.getTopLeft(find.text('Testo')).dx - leadingRight, 16,
          reason: '`.list-item .avatar, .it-rounded-icon, .it-thumb '
              '{ margin-right: 16px }`');
    });

    testWidgets('ItListThumb crops to the 40px box', (t) async {
      await t.pumpWidget(_host(const ItContentList(items: [
        ItContentListItem(
          leading: ItListThumb(
            child: SizedBox(
              width: 120,
              height: 80,
              child: ColoredBox(color: Color(0xFF999999)),
            ),
          ),
          text: 'Testo',
        ),
      ])));

      expect(t.getSize(find.byType(ItListThumb)), const Size(40, 40),
          reason: '`.it-thumb { width: 40px; height: 40px }` with '
              '`img { object-fit: cover }`');
    });

    testWidgets('the row tap fires when there are no actions', (t) async {
      var tapped = false;
      await t.pumpWidget(_host(ItContentList(items: [
        ItContentListItem(text: 'Testo', onTap: () => tapped = true),
      ])));
      await t.tap(find.text('Testo'));
      expect(tapped, isTrue);
    });
  });
}
