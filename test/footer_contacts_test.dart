// The footer's contacts band and the free paragraph inside a column.
//
// From the Bootstrap Italia docs page for Footer, which the example app
// mirrors. The kit closes the footer with a second `<section>` —
// `class="py-4 border-white border-top"` — holding the administration's postal
// address, its contact links and the social icons. Neither the band nor the
// paragraph had any expression here before, which is why the example app could
// show neither the complete footer nor the contacts-only one.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  final data = BootstrapItaliaThemeData.standard();
  return BootstrapItaliaTheme(
    data: data,
    child: MaterialApp(
      theme: data.toThemeData(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(width: 1176, child: child),
        ),
      ),
    ),
  );
}

List<ItFooterSection> _contacts() => [
      ItFooterSection(
        title: 'Contatti',
        content: const Text('Via Roma 0 - 00000 Lorem Ipsum'),
        links: [
          ItFooterLink(label: 'Posta Elettronica Certificata', onTap: () {}),
        ],
      ),
      const ItFooterSection(title: 'Lorem Ipsum', links: []),
    ];

List<ItSocialLink> _socials() => [
      ItSocialLink(
        icon: BootstrapItaliaIcons.it_medium,
        label: 'Medium (link esterno)',
        onTap: () {},
      ),
    ];

void main() {
  group('ItFooterSection.content — the contacts paragraph', () {
    testWidgets('it renders between the heading and the links', (t) async {
      await t.pumpWidget(_host(ItFooter(
        institutionName: 'Lorem Ipsum',
        contactSections: _contacts(),
      )));

      final heading = t.getCenter(find.text('CONTATTI'));
      final paragraph =
          t.getCenter(find.text('Via Roma 0 - 00000 Lorem Ipsum'));
      final link = t.getCenter(find.text('Posta Elettronica Certificata'));

      expect(paragraph.dy, greaterThan(heading.dy));
      expect(link.dy, greaterThan(paragraph.dy),
          reason:
              'the kit orders them `<h4>`, `<p>`, `<ul class="link-list">`');
    });

    testWidgets('it inherits the band foreground rather than restating it',
        (t) async {
      // `.it-footer-main { color: #fff }`. Caller content should not have to
      // know it is being placed on a dark blue band.
      await t.pumpWidget(_host(ItFooter(
        institutionName: 'Lorem Ipsum',
        contactSections: _contacts(),
      )));

      final style = DefaultTextStyle.of(
        t.element(find.text('Via Roma 0 - 00000 Lorem Ipsum')),
      ).style;
      expect(style.color, const Color(0xFFFFFFFF));
      expect(style.fontSize, 16);
    });

    testWidgets('a column without content is unchanged', (t) async {
      // Additive: `nav_footer_links.png` is captured from these columns.
      await t.pumpWidget(_host(ItFooter(
        institutionName: 'Lorem Ipsum',
        sections: [
          ItFooterSection(
            title: 'Amministrazione',
            links: [ItFooterLink(label: 'Giunta e consiglio', onTap: () {})],
          ),
        ],
      )));

      final heading = t.getRect(find.text('AMMINISTRAZIONE'));
      final link = t.getRect(find.text('Giunta e consiglio'));
      expect(link.top - heading.bottom, lessThan(16),
          reason: 'no paragraph slot means no extra gap');
    });
  });

  group('contactSections — `<section class="py-4 border-white border-top">`',
      () {
    /// The band's own box: the one with a white top border.
    Container _band(WidgetTester tester) =>
        tester.widgetList<Container>(find.byType(Container)).firstWhere((c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).border?.top.color ==
                const Color(0xFFFFFFFF));

    testWidgets('it is separated by a white rule and 24px of padding',
        (t) async {
      await t.pumpWidget(_host(ItFooter(
        institutionName: 'Lorem Ipsum',
        contactSections: _contacts(),
      )));

      final band = _band(t);
      expect((band.decoration! as BoxDecoration).border!.top.width, 1.0,
          reason: '`.border-top.border-white { border-top: 1px solid #fff }`');
      expect(band.padding, const EdgeInsets.symmetric(vertical: 24),
          reason: '`.py-4 { padding-top: 24px; padding-bottom: 24px }`');
    });

    testWidgets('the socials join the band as its last column', (t) async {
      await t.pumpWidget(_host(ItFooter(
        institutionName: 'Lorem Ipsum',
        contactSections: _contacts(),
        socialLinks: _socials(),
      )));

      expect(find.text('SEGUICI SU'), findsOneWidget);
      expect(t.getCenter(find.text('SEGUICI SU')).dx,
          greaterThan(t.getCenter(find.text('CONTATTI')).dx),
          reason: 'the kit puts them in the third `.col-lg-4` of the band');

      // Same row, not stacked under it.
      expect(
        (t.getCenter(find.text('SEGUICI SU')).dy -
                t.getCenter(find.text('CONTATTI')).dy)
            .abs(),
        lessThan(1),
      );
    });

    testWidgets('without the band the socials keep the inline row', (t) async {
      // The compromise the kit does not have, kept so that an application
      // already passing only `socialLinks` does not change appearance.
      await t.pumpWidget(_host(ItFooter(
        institutionName: 'Lorem Ipsum',
        socialLinks: _socials(),
      )));

      expect(find.text('SEGUICI SU'), findsOneWidget);
      expect(
        t.widgetList<Container>(find.byType(Container)).where((c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).border?.top.color ==
                const Color(0xFFFFFFFF)),
        isEmpty,
        reason: 'no contact columns means no band to rule off',
      );
    });

    testWidgets('a footer with neither is what it always was', (t) async {
      await t.pumpWidget(_host(const ItFooter(institutionName: 'Lorem Ipsum')));

      expect(find.text('Lorem Ipsum'), findsOneWidget);
      expect(find.text('SEGUICI SU'), findsNothing);
    });
  });

  group('a11y: the band carries real headings and named links', () {
    List<SemanticsData> _all(WidgetTester tester) {
      final out = <SemanticsData>[];
      void walk(SemanticsNode node) {
        out.add(node.getSemanticsData());
        node.visitChildren((c) {
          walk(c);
          return true;
        });
      }

      walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
      return out;
    }

    testWidgets('1.3.1: "Seguici su" is an h4, not styled text', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(ItFooter(
        institutionName: 'Lorem Ipsum',
        contactSections: _contacts(),
        socialLinks: _socials(),
      )));

      final heading = _all(t).firstWhere((d) => d.label == 'SEGUICI SU');
      expect(heading.hasFlag(SemanticsFlag.isHeader), isTrue);
      expect(heading.headingLevel, 4,
          reason: 'the kit marks it `<h4>`, and a footer navigated by heading '
              'is the point of exposing the level at all');
      handle.dispose();
    });

    testWidgets('2.4.4: each social icon is a link with its own name',
        (t) async {
      // The glyph carries no text, so the label supplied here — which the kit
      // provides as a `.visually-hidden` span — is the only accessible name
      // this control will ever have.
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(ItFooter(
        institutionName: 'Lorem Ipsum',
        contactSections: _contacts(),
        socialLinks: _socials(),
      )));

      final link =
          _all(t).firstWhere((d) => d.label == 'Medium (link esterno)');
      expect(link.hasFlag(SemanticsFlag.isLink), isTrue);
      handle.dispose();
    });

    testWidgets('2.5.8: the social target clears 24x24', (t) async {
      await t.pumpWidget(_host(ItFooter(
        institutionName: 'Lorem Ipsum',
        contactSections: _contacts(),
        socialLinks: _socials(),
      )));

      final size = t.getSize(find
          .ancestor(
            of: find.byIcon(BootstrapItaliaIcons.it_medium),
            matching: find.byType(Padding),
          )
          .first);
      expect(size.width, greaterThanOrEqualTo(24));
      expect(size.height, greaterThanOrEqualTo(24),
          reason: '`<a class="p-2">` puts 8px around a 24px glyph, so the '
              'target is 40x40');
    });
  });
}
