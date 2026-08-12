// The variants added so the example app can mirror the official docs.
//
// Every one of these exists because a section of
// https://italia.github.io/bootstrap-italia/docs/componenti/… shows something
// the widget could not express: `.btn-link` and `.rounded-icon` and the
// `.bg-dark` treatment for Buttons, the automatic variant glyph and
// `.alert-link` for Alert, `.chip-*` for Chips, `.callout-highlight` and
// `.callout-more` for Callout, `.it-card-title-icon` and the heading level for
// Card, and the em-relative sizing the Badge page opens with.
//
// Each group asserts three things, in the shape `accordion_variants_test.dart`
// established: the colour or metric the CSS specifies, that the variant is off
// by default, and — where the value is a palette token in a role that means it —
// that it follows a retinted scheme.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {BootstrapItaliaColorScheme? colors}) {
  final data = BootstrapItaliaThemeData(
      colors: colors ?? BootstrapItaliaColorScheme.standard);
  return BootstrapItaliaTheme(
    data: data,
    child: MaterialApp(
      theme: data.toThemeData(),
      home: Scaffold(body: Center(child: SizedBox(width: 700, child: child))),
    ),
  );
}

/// The [BoxDecoration] of the nearest decorated [Container] above [of].
BoxDecoration _boxAbove(WidgetTester tester, Finder of) {
  final container = tester
      .widgetList<Container>(
          find.ancestor(of: of, matching: find.byType(Container)))
      .firstWhere((c) => c.decoration is BoxDecoration);
  return container.decoration! as BoxDecoration;
}

/// The style [label] is actually painted with.
///
/// Reads the [RichText] the [Text] resolves to, not `Text.style`. Most labels in
/// this package take their colour, weight and size from a surrounding
/// [DefaultTextStyle] — `ItButton` sets none on its child at all — so asserting
/// on `Text.style` would read null and tell you nothing.
TextStyle _styleOf(WidgetTester tester, String label) {
  final rich = tester.widget<RichText>(
    find.descendant(of: find.text(label), matching: find.byType(RichText)),
  );
  return (rich.text as TextSpan).style!;
}

/// The rendered height of the [SizeTransition] wrapping [label].
///
/// `ItCollapse` keeps its subtree mounted and *clips* it, so the child's own
/// size never changes — a collapsed panel's Text still measures its full
/// height. The visible height is the transition's.
double _collapsedHeight(WidgetTester tester, String label) => tester
    .getSize(find
        .ancestor(of: find.text(label), matching: find.byType(SizeTransition))
        .first)
    .height;

void main() {
  // ── ItButton ──────────────────────────────────────────────────────────────

  group('ItButton.link — `.btn-link`', () {
    testWidgets('is transparent, underlined, and the link colour', (t) async {
      await t.pumpWidget(_host(
        ItButton(link: true, onPressed: () {}, child: const Text('Vai')),
      ));

      expect(_boxAbove(t, find.text('Vai')).color, const Color(0x00000000),
          reason: '`--bs-btn-bg: transparent`');
      final style = _styleOf(t, 'Vai');
      expect(style.color, BootstrapItaliaColors.primary,
          reason: '`--bs-btn-color: var(--bs-link-color)`, '
              'itself `hsl(210, 100%, 40%)`');
      expect(style.decoration, TextDecoration.underline,
          reason: '`text-decoration: underline` — and §1.4.1, since the colour '
              'alone would not mark it as a link');
      expect(style.fontWeight, FontWeight.w400,
          reason: '`--bs-btn-font-weight: 400`, against the 600 every other '
              'button uses');
    });

    testWidgets('goes grey when disabled, not translucent', (t) async {
      await t.pumpWidget(_host(
        const ItButton(link: true, disabled: true, child: Text('Vai')),
      ));
      expect(_styleOf(t, 'Vai').color, BootstrapItaliaColors.gray600,
          reason: '`--bs-btn-disabled-color: hsl(0, 0%, 32%)` replaces the '
              'colour outright, where a filled button fades its fill');
    });

    testWidgets('off by default: a plain button is filled and not underlined',
        (t) async {
      await t.pumpWidget(_host(
        ItButton(onPressed: () {}, child: const Text('Vai')),
      ));
      expect(
          _boxAbove(t, find.text('Vai')).color, BootstrapItaliaColors.primary);
      expect(_styleOf(t, 'Vai').decoration, TextDecoration.none);
      expect(_styleOf(t, 'Vai').fontWeight, FontWeight.w600);
    });

    testWidgets('re-themes: the link colour IS the primary token', (t) async {
      const purple = Color(0xFF7A1FA2);
      await t.pumpWidget(_host(
        ItButton(link: true, onPressed: () {}, child: const Text('Vai')),
        colors: BootstrapItaliaColorScheme.standard.copyWith(primary: purple),
      ));
      expect(_styleOf(t, 'Vai').color, purple);
    });
  });

  group('ItButton.onDark — `.bg-dark .btn-*`', () {
    testWidgets('the solid primary inverts to white on blue', (t) async {
      await t.pumpWidget(_host(
        ItButton(onDark: true, onPressed: () {}, child: const Text('Primary')),
      ));
      expect(
          _boxAbove(t, find.text('Primary')).color, BootstrapItaliaColors.white,
          reason: '`.bg-dark .btn-primary { --bs-btn-bg: hsl(0, 0%, 100%) }`');
      expect(_styleOf(t, 'Primary').color, BootstrapItaliaColors.primary,
          reason: '`--bs-btn-color: hsl(210, 100%, 40%)` — inverted, not just '
              'lightened');
    });

    testWidgets('the outline variants take a white ring and label', (t) async {
      await t.pumpWidget(_host(
        ItButton(
          onDark: true,
          outline: true,
          variant: ItButtonVariant.secondary,
          onPressed: () {},
          child: const Text('Secondary outline'),
        ),
      ));
      expect(
          _styleOf(t, 'Secondary outline').color, BootstrapItaliaColors.white,
          reason: '`.bg-dark .btn-outline-secondary '
              '{ --bs-btn-color: hsl(0, 0%, 100%) }`');
    });

    testWidgets('leaves every variant the stylesheet does not redeclare alone',
        (t) async {
      // `.bg-dark` defines overrides for primary, secondary and their outlines
      // and nothing else. A success button on a dark band is an ordinary
      // success button, by the stylesheet's omission.
      await t.pumpWidget(_host(
        ItButton(
          onDark: true,
          variant: ItButtonVariant.success,
          onPressed: () {},
          child: const Text('Success'),
        ),
      ));
      expect(_boxAbove(t, find.text('Success')).color,
          BootstrapItaliaColors.success);
    });

    testWidgets('off by default', (t) async {
      await t.pumpWidget(_host(
        ItButton(onPressed: () {}, child: const Text('Primary')),
      ));
      expect(_boxAbove(t, find.text('Primary')).color,
          BootstrapItaliaColors.primary);
      expect(_styleOf(t, 'Primary').color, BootstrapItaliaColors.white);
    });

    testWidgets('both halves of the inversion re-theme together', (t) async {
      // The fill is `white` and the label is `primary`; retinting one without
      // the other is how this variant would lose its contrast.
      const purple = Color(0xFF7A1FA2);
      const paper = Color(0xFFFFF8E1);
      await t.pumpWidget(_host(
        ItButton(onDark: true, onPressed: () {}, child: const Text('Primary')),
        colors: BootstrapItaliaColorScheme.standard
            .copyWith(primary: purple, white: paper),
      ));
      expect(_boxAbove(t, find.text('Primary')).color, paper);
      expect(_styleOf(t, 'Primary').color, purple);
    });
  });

  group('ItButton.roundedIcon — `.rounded-icon`', () {
    testWidgets('draws a 1.5em disc, white, with the variant glyph inside',
        (t) async {
      await t.pumpWidget(_host(
        ItButton(
          variant: ItButtonVariant.success,
          icon: BootstrapItaliaIcons.it_user,
          roundedIcon: true,
          onPressed: () {},
          child: const Text('Etichetta'),
        ),
      ));

      final disc = _disc(t);
      expect(disc.constraints?.maxWidth, 24,
          reason: '`width: 1.5em` on a 16px medium button');
      expect((disc.decoration! as BoxDecoration).color,
          BootstrapItaliaColors.white,
          reason: '`.btn-icon .rounded-icon { background-color: #fff }`');
      expect(
        t.widget<Icon>(find.byIcon(BootstrapItaliaIcons.it_user)).color,
        BootstrapItaliaColors.success,
        reason: 'the docs pair `.btn-success` with `.icon-success`',
      );
    });

    testWidgets('the disc scales with the button size', (t) async {
      await t.pumpWidget(_host(
        ItButton(
          size: ItButtonSize.large,
          icon: BootstrapItaliaIcons.it_user,
          roundedIcon: true,
          onPressed: () {},
          child: const Text('Etichetta'),
        ),
      ));
      expect(_disc(t).constraints?.maxWidth, 1.5 * 18,
          reason: 'the `em` is the button font size — 1.125rem on `.btn-lg`');
    });

    testWidgets('off by default: a bare glyph, no disc', (t) async {
      await t.pumpWidget(_host(
        ItButton(
          icon: BootstrapItaliaIcons.it_user,
          onPressed: () {},
          child: const Text('Etichetta'),
        ),
      ));
      expect(_disc(t).constraints, isNull,
          reason: 'the nearest Container above the glyph is the button box '
              'itself — padded and decorated, but not sized — so no disc was '
              'drawn');
    });

    testWidgets('the disc re-themes with the scheme', (t) async {
      const paper = Color(0xFFFFF8E1);
      await t.pumpWidget(_host(
        ItButton(
          icon: BootstrapItaliaIcons.it_user,
          roundedIcon: true,
          onPressed: () {},
          child: const Text('Etichetta'),
        ),
        colors: BootstrapItaliaColorScheme.standard.copyWith(white: paper),
      ));
      expect((_disc(t).decoration! as BoxDecoration).color, paper);
    });
  });

  test('ItButtonSize.small is `.btn-xs`, the docs\' Mini', () {
    // Not a rendering test — a note the compiler can hold. The docs offer four
    // size headings and the stylesheet has three renderings, because `.btn-sm`
    // resolves to `padding: 12px 24px; font-size: 1rem`, which is the default
    // button exactly. If a fourth value ever appears here, someone has either
    // found a difference this comment missed or duplicated `medium`.
    expect(ItButtonSize.values, hasLength(3));
  });

  // ── ItAlert ───────────────────────────────────────────────────────────────

  group('ItAlert — the variant glyph the stylesheet paints', () {
    testWidgets('each variant draws its own, matched to the sprite', (t) async {
      // Recovered by matching `.alert-*`'s inline `background-image` SVG paths
      // against `bootstrap-italia/svg/sprites.svg`.
      const expected = {
        ItAlertVariant.primary: BootstrapItaliaIcons.it_info_circle,
        ItAlertVariant.info: BootstrapItaliaIcons.it_info_circle,
        ItAlertVariant.success: BootstrapItaliaIcons.it_check_circle,
        ItAlertVariant.warning: BootstrapItaliaIcons.it_warning_circle,
        ItAlertVariant.danger: BootstrapItaliaIcons.it_error,
      };
      for (final entry in expected.entries) {
        await t.pumpWidget(_host(
          ItAlert(variant: entry.key, body: const Text('Testo')),
        ));
        expect(find.byIcon(entry.value), findsOneWidget,
            reason: '${entry.key} must paint ${entry.value}');
      }
    });

    testWidgets('warning is NOT the callout\'s help circle', (t) async {
      // The two components use the same word and different glyphs: the alert's
      // inline SVG is an exclamation in a circle, the callout's markup names
      // `#it-help-circle`. Assert the distinction so a future tidy-up cannot
      // quietly unify them.
      await t.pumpWidget(_host(
        const ItAlert(variant: ItAlertVariant.warning, body: Text('Testo')),
      ));
      expect(find.byIcon(BootstrapItaliaIcons.it_help_circle), findsNothing);
    });

    testWidgets('secondary paints none — there is no .alert-secondary',
        (t) async {
      await t.pumpWidget(_host(
        const ItAlert(variant: ItAlertVariant.secondary, body: Text('Testo')),
      ));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('an explicit icon overrides it; showIcon: false removes it',
        (t) async {
      await t.pumpWidget(_host(
        const ItAlert(
          variant: ItAlertVariant.success,
          icon: BootstrapItaliaIcons.it_star_full,
          body: Text('Testo'),
        ),
      ));
      expect(find.byIcon(BootstrapItaliaIcons.it_star_full), findsOneWidget);
      expect(find.byIcon(BootstrapItaliaIcons.it_check_circle), findsNothing);

      await t.pumpWidget(_host(
        const ItAlert(
          variant: ItAlertVariant.success,
          showIcon: false,
          body: Text('Testo'),
        ),
      ));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('the glyph is decoration and announces nothing', (t) async {
      await t.pumpWidget(_host(
        const ItAlert(variant: ItAlertVariant.danger, body: Text('Testo')),
      ));
      // The alert is a live region carrying its text; the glyph restates the
      // colour, which restates the text. Announcing it would be noise, and the
      // docs say as much under «Trasmettere significato alle tecnologie
      // assistive».
      expect(
        find.ancestor(
          of: find.byIcon(BootstrapItaliaIcons.it_error),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the glyph takes the variant accent, and re-themes', (t) async {
      const purple = Color(0xFF7A1FA2);
      await t.pumpWidget(_host(
        const ItAlert(variant: ItAlertVariant.primary, body: Text('Testo')),
        colors: BootstrapItaliaColorScheme.standard.copyWith(primary: purple),
      ));
      expect(
        t.widget<Icon>(find.byIcon(BootstrapItaliaIcons.it_info_circle)).color,
        purple,
        reason: 'the inline SVG is filled with the same colour as the 8px left '
            'border, so the two must move together',
      );
    });
  });

  group('ItAlertLink — `.alert-link`', () {
    testWidgets('is 600 weight, underlined, and the link colour', (t) async {
      await t.pumpWidget(_host(
        ItAlert(
          body: Text.rich(TextSpan(children: [
            const TextSpan(text: 'Vedi il '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: ItAlertLink(label: 'documento', onPressed: () {}),
            ),
          ])),
        ),
      ));

      final style = _styleOf(t, 'documento');
      expect(style.color, BootstrapItaliaColors.primary, reason: 'color: #06c');
      expect(style.fontWeight, FontWeight.w600, reason: 'font-weight: 600');
      expect(style.decoration, TextDecoration.underline);
    });

    testWidgets('re-themes with primary', (t) async {
      const purple = Color(0xFF7A1FA2);
      await t.pumpWidget(_host(
        ItAlert(body: ItAlertLink(label: 'documento', onPressed: () {})),
        colors: BootstrapItaliaColorScheme.standard.copyWith(primary: purple),
      ));
      expect(_styleOf(t, 'documento').color, purple);
    });
  });

  // ── ItBadge ───────────────────────────────────────────────────────────────

  group('ItBadge — `--bs-badge-font-size: 0.875em`', () {
    testWidgets('takes its size from the text it sits in', (t) async {
      await t.pumpWidget(_host(
        const DefaultTextStyle(
          style: TextStyle(fontSize: 40),
          child: ItBadge(child: Text('New')),
        ),
      ));
      expect(_styleOf(t, 'New').fontSize, 0.875 * 40,
          reason: '«La grandezza di ogni badge si adatta come dimensione a '
              "quella del font dell'elemento in cui è contenuto»");
    });

    testWidgets('falls back to the CSS root, not Flutter\'s 14px', (t) async {
      await t.pumpWidget(
        const BootstrapItaliaTheme(
          data: BootstrapItaliaThemeData(
            colors: BootstrapItaliaColorScheme.standard,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: ItBadge(child: Text('New'))),
          ),
        ),
      );
      expect(_styleOf(t, 'New').fontSize, 14,
          reason: 'no ambient style means `DefaultTextStyle.fallback()`, whose '
              'fontSize is null — `--bs-body-font-size: 1rem` stands in, so '
              'the badge is 14px and not 12.25px');
    });

    testWidgets('padding scales with it', (t) async {
      await t.pumpWidget(_host(
        const DefaultTextStyle(
          style: TextStyle(fontSize: 32),
          child: ItBadge(child: Text('New')),
        ),
      ));
      final padding = _badgePadding(t);
      expect(padding.top, 0.25 * 0.875 * 32, reason: 'padding-y: 0.25em');
      expect(padding.left, 0.4 * 0.875 * 32, reason: 'padding-x: 0.4em');
    });
  });

  group('ItBadge — the `.bg-*` / `.text-*` overrides and the link role', () {
    testWidgets('backgroundColor and foregroundColor win over the variant',
        (t) async {
      // «Accessibilità»: `<span class="badge bg-white text-secondary">4</span>`
      // inside a primary button.
      const textSecondary = Color(0xFF30475F);
      await t.pumpWidget(_host(
        const ItBadge(
          backgroundColor: BootstrapItaliaColors.white,
          foregroundColor: textSecondary,
          child: Text('4'),
        ),
      ));
      expect(_boxAbove(t, find.text('4')).color, BootstrapItaliaColors.white);
      expect(_styleOf(t, '4').color, textSecondary);
    });

    testWidgets('off by default: the variant still decides', (t) async {
      await t.pumpWidget(_host(
          const ItBadge(variant: ItBadgeVariant.danger, child: Text('4'))));
      expect(_boxAbove(t, find.text('4')).color, BootstrapItaliaColors.danger);
    });

    testWidgets('onTap makes it a link, and only then', (t) async {
      final handle = t.ensureSemantics();

      await t.pumpWidget(_host(const ItBadge(child: Text('Primary'))));
      expect(
        t.getSemantics(find.text('Primary')).getSemanticsData().hasFlag(
              SemanticsFlag.isLink,
            ),
        isFalse,
        reason: 'a plain `<span class="badge">` is content, not a control',
      );

      await t.pumpWidget(_host(
        ItBadge(onTap: () {}, child: const Text('Primary')),
      ));
      final data = t.getSemantics(find.text('Primary')).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isLink), isTrue,
          reason: 'the docs put the class on an `<a>`');
      expect(data.hasAction(SemanticsAction.tap), isTrue);

      handle.dispose();
    });

    testWidgets('semanticLabel replaces the bare number', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(
        const ItBadge(semanticLabel: '9 messaggi non letti', child: Text('9')),
      ));
      expect(find.bySemanticsLabel('9 messaggi non letti'), findsOneWidget);
      // Not "9, 9 messaggi non letti": the hidden text stands IN PLACE of the
      // digit, which is what `.visually-hidden` beside it achieves in HTML.
      expect(
        t
            .getSemantics(find.bySemanticsLabel('9 messaggi non letti'))
            .getSemanticsData()
            .label,
        '9 messaggi non letti',
      );
      handle.dispose();
    });
  });

  // ── ItChip ────────────────────────────────────────────────────────────────

  group('ItChip colour variants — `.chip-*`', () {
    testWidgets('are outlines at rest, not fills', (t) async {
      await t.pumpWidget(_host(
        const ItChip(label: 'Primary', variant: ItChipVariant.primary),
      ));
      final box = _boxAbove(t, find.text('Primary'));
      expect(box.color, const Color(0x00000000),
          reason: '`.chip.chip-primary { background-color: rgba(0,0,0,0) }` — '
              'the opposite of a coloured badge, which fills');
      expect((box.border! as Border).top.color, BootstrapItaliaColors.primary,
          reason: '`border-color: #06c`');
      expect(_styleOf(t, 'Primary').color, BootstrapItaliaColors.primary,
          reason: '`.chip.chip-primary > .chip-label { color: #06c }`');
    });

    testWidgets('off by default: the plain chip keeps its grey fill',
        (t) async {
      await t.pumpWidget(_host(const ItChip(label: 'Label')));
      expect(_boxAbove(t, find.text('Label')).color, const Color(0xFFF5F5F5),
          reason: '`.chip { background: hsl(0, 0%, 96%) }`');
    });

    testWidgets('re-theme with the scheme', (t) async {
      const purple = Color(0xFF7A1FA2);
      await t.pumpWidget(
        _host(
          const ItChip(label: 'Primary', variant: ItChipVariant.primary),
          colors: BootstrapItaliaColorScheme.standard.copyWith(primary: purple),
        ),
      );
      expect(_styleOf(t, 'Primary').color, purple);
    });

    testWidgets('disabled wins over the variant, unlike the cascade',
        (t) async {
      // `.chip-disabled` is declared before `.chip-primary` at equal
      // specificity, so a browser would paint this chip as a perfectly ordinary
      // coloured one — an inoperable control that looks operable. Deliberately
      // not reproduced.
      await t.pumpWidget(_host(const ItChip(
        label: 'Primary',
        variant: ItChipVariant.primary,
        disabled: true,
      )));
      expect(_styleOf(t, 'Primary').color, const Color(0xFF63707E),
          reason:
              '`.chip.chip-disabled .chip-label { color: hsl(210,12%,44%) }`');
    });
  });

  group('ItChip.leading — the avatar slot', () {
    testWidgets('sits in the glyph\'s box, and grows with .chip-lg', (t) async {
      const avatar = Key('avatar');
      await t.pumpWidget(_host(const ItChip(
        label: 'Mario',
        leading: ColoredBox(key: avatar, color: Color(0xFF123456)),
      )));
      expect(t.getSize(find.byKey(avatar)), const Size(16, 16),
          reason: '`.avatar.size-xs` — 16px on a standard chip');

      await t.pumpWidget(_host(const ItChip(
        label: 'Mario',
        large: true,
        leading: ColoredBox(key: avatar, color: Color(0xFF123456)),
      )));
      expect(t.getSize(find.byKey(avatar)), const Size(24, 24),
          reason: '`.chip.chip-lg .avatar { width: 24px; height: 24px }`');
    });
  });

  // ── ItCallout ─────────────────────────────────────────────────────────────

  group('ItCallout styles', () {
    testWidgets('highlight draws a left rule only', (t) async {
      await t.pumpWidget(_host(const ItCallout(
        style: ItCalloutStyle.highlight,
        title: 'Titolo',
        body: Text('Testo'),
      )));
      final border = _boxAbove(t, find.text('Testo')).border! as Border;
      expect(border.left.width, 2);
      expect(border.top, BorderSide.none, reason: '`border: none`');
      expect(border.right, BorderSide.none);
      expect(border.bottom, BorderSide.none);
    });

    testWidgets('more drops the border, fills #f9f9f5, and drops to 16px sans',
        (t) async {
      await t.pumpWidget(_host(const ItCallout(
        style: ItCalloutStyle.more,
        title: 'Approfondimento',
        body: Text('Testo'),
      )));
      final box = _boxAbove(t, find.text('Testo'));
      expect(box.color, const Color(0xFFF9F9F5),
          reason: '`.callout.callout-more { background: #f9f9f5 }`');
      expect(box.border, isNull, reason: '`border: none`');

      final body = DefaultTextStyle.of(
        t.element(find.text('Testo')),
      ).style;
      expect(body.fontSize, 16,
          reason: '`.callout.callout-more p { font-size: 1rem }` — NOT the '
              'Lora 18px the other styles use');
      expect(
        body.fontFamily,
        'packages/${BootstrapItaliaFontFamily.package}/'
        '${BootstrapItaliaFontFamily.sansSerif}',
      );
    });

    testWidgets('off by default: the standard style keeps its 2px box and Lora',
        (t) async {
      await t.pumpWidget(_host(
        const ItCallout(title: 'Titolo', body: Text('Testo')),
      ));
      final border = _boxAbove(t, find.text('Testo')).border! as Border;
      expect(border.top.width, 2);
      expect(border.left.width, 2);
      expect(
        DefaultTextStyle.of(t.element(find.text('Testo'))).style.fontFamily,
        'packages/${BootstrapItaliaFontFamily.package}/'
        '${BootstrapItaliaFontFamily.serif}',
      );
    });

    testWidgets('the border re-themes on every style', (t) async {
      const purple = Color(0xFF7A1FA2);
      await t.pumpWidget(_host(
        const ItCallout(
          style: ItCalloutStyle.highlight,
          variant: ItCalloutVariant.note,
          body: Text('Testo'),
        ),
        colors: BootstrapItaliaColorScheme.standard.copyWith(primary: purple),
      ));
      expect((_boxAbove(t, find.text('Testo')).border! as Border).left.color,
          purple);
    });
  });

  group('ItCallout icons, from the docs\' own markup', () {
    testWidgets('danger is it-close-circle, not it-error', (t) async {
      // The correction this pass made. `it-error` is the octagon the danger
      // *alert* uses; the callout markup names `#it-close-circle`.
      await t.pumpWidget(_host(const ItCallout(
        variant: ItCalloutVariant.danger,
        title: 'Errore',
        body: Text('Testo'),
      )));
      expect(find.byIcon(BootstrapItaliaIcons.it_close_circle), findsOneWidget);
      expect(find.byIcon(BootstrapItaliaIcons.it_error), findsNothing);
    });

    testWidgets('every variant matches the `<use href>` in the docs',
        (t) async {
      const expected = {
        ItCalloutVariant.neutral: BootstrapItaliaIcons.it_info_circle,
        ItCalloutVariant.success: BootstrapItaliaIcons.it_check_circle,
        ItCalloutVariant.warning: BootstrapItaliaIcons.it_help_circle,
        ItCalloutVariant.danger: BootstrapItaliaIcons.it_close_circle,
        ItCalloutVariant.important: BootstrapItaliaIcons.it_info_circle,
        ItCalloutVariant.note: BootstrapItaliaIcons.it_info_circle,
      };
      for (final e in expected.entries) {
        await t.pumpWidget(_host(ItCallout(
          variant: e.key,
          title: 'Titolo',
          body: const Text('Testo'),
        )));
        expect(find.byIcon(e.value), findsOneWidget,
            reason: '${e.key} must paint ${e.value}');
      }
    });
  });

  group('ItCallout.moreContent — the «Leggi tutto» disclosure', () {
    testWidgets('starts closed and reveals on activation', (t) async {
      await t.pumpWidget(_host(const ItCallout(
        style: ItCalloutStyle.more,
        title: 'Approfondimento',
        body: Text('Testo'),
        moreContent: Text('Il resto'),
      )));

      // ItCollapse keeps the subtree mounted and clips it, so presence is not
      // the test — visible height is.
      expect(_collapsedHeight(t, 'Il resto'), 0);

      await t.tap(find.text('Leggi tutto'));
      await t.pumpAndSettle();
      expect(_collapsedHeight(t, 'Il resto'), greaterThan(0));
    });

    testWidgets('is absent without moreContent', (t) async {
      await t.pumpWidget(_host(const ItCallout(
        style: ItCalloutStyle.more,
        title: 'Approfondimento',
        body: Text('Testo'),
      )));
      expect(find.text('Leggi tutto'), findsNothing);
    });

    testWidgets('the download link is optional and separate', (t) async {
      var downloaded = false;
      await t.pumpWidget(_host(ItCallout(
        style: ItCalloutStyle.more,
        title: 'Approfondimento',
        body: const Text('Testo'),
        moreContent: const Text('Il resto'),
        downloadLabel: 'Scarica il PDF, 200Kb',
        onDownload: () => downloaded = true,
      )));
      await t.tap(find.text('Scarica il PDF, 200Kb'));
      expect(downloaded, isTrue);
      // Activating the download must not have opened the disclosure: two
      // controls, two jobs.
      expect(_collapsedHeight(t, 'Il resto'), 0);
    });
  });

  // ── ItCard ────────────────────────────────────────────────────────────────

  group('ItCard.titleIcon — `.it-card-title-icon`', () {
    testWidgets('trails the title rather than leading it', (t) async {
      await t.pumpWidget(_host(const ItCard(
        title: 'Titolo',
        titleIcon: BootstrapItaliaIcons.it_video,
        body: Text('Testo'),
      )));
      expect(
        t.getTopLeft(find.byIcon(BootstrapItaliaIcons.it_video)).dx,
        greaterThan(t.getTopRight(find.text('Titolo')).dx - 1),
        reason: '`justify-content: space-between` puts the glyph at the far '
            'end — every other icon slot in this package leads, so this is '
            'the one that is easy to get backwards',
      );
    });

    testWidgets('off by default', (t) async {
      await t.pumpWidget(
          _host(const ItCard(title: 'Titolo', body: Text('Testo'))));
      expect(find.byType(Icon), findsNothing);
    });
  });

  group('ItCard.titleHeadingLevel', () {
    testWidgets('the title is a heading, at the level asked for', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(const ItCard(
        title: 'Titolo',
        titleHeadingLevel: 2,
        body: Text('Testo'),
      )));
      final data = t.getSemantics(find.text('Titolo')).getSemanticsData();
      expect(data.hasFlag(SemanticsFlag.isHeader), isTrue,
          reason: '§1.3.1 — a card title heads the card, and a page of cards '
              'with no headings is a flat run of text to anyone navigating by '
              'them');
      expect(data.headingLevel, 2);
      handle.dispose();
    });

    testWidgets('defaults to 3, the level the painted size already implies',
        (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(
          _host(const ItCard(title: 'Titolo', body: Text('Testo'))));
      expect(
          t.getSemantics(find.text('Titolo')).getSemanticsData().headingLevel,
          3);
      handle.dispose();
    });
  });
}

/// The `.rounded-icon` disc: the sized [Container] wrapping the button glyph.
Container _disc(WidgetTester tester) => tester.widget<Container>(
      find
          .ancestor(
            of: find.byIcon(BootstrapItaliaIcons.it_user),
            matching: find.byType(Container),
          )
          .first,
    );

/// The badge's own padding.
EdgeInsets _badgePadding(WidgetTester tester) {
  final container = tester
      .widgetList<Container>(
          find.ancestor(of: find.text('New'), matching: find.byType(Container)))
      .firstWhere((c) => c.decoration is BoxDecoration);
  return container.padding! as EdgeInsets;
}
