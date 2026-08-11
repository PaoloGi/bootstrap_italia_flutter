import 'dart:io';

import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_helpers.dart';

const _outDir = 'tool/visual_parity/flutter_captures';

/// The header and footer stories render Bootstrap Italia SVG sprites. The
/// shared `flutter_test_config.dart` only registers the text fonts, so load
/// the icon font here too — otherwise every icon is a missing-glyph box.
Future<void> _loadIconFont() async {
  final home = Platform.environment['HOME'];
  final path = '$home/.pub-cache/hosted/pub.dev/bootstrap_italia_icons-0.0.3'
      '/fonts/BootstrapItaliaIcons.ttf';
  final file = File(path);
  if (!file.existsSync()) return;
  final bytes = await file.readAsBytes();
  for (final family in [
    'BootstrapItaliaIcons',
    'packages/bootstrap_italia_icons/BootstrapItaliaIcons',
  ]) {
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
    await loader.load();
  }
}

/// The three breadcrumb items used by every design-react-kit breadcrumb story.
const _breadcrumbItems = <ItBreadcrumbItem>[
  ItBreadcrumbItem(label: 'Home'),
  ItBreadcrumbItem(label: 'Subsection'),
  ItBreadcrumbItem(label: 'Current section'),
];

void main() {
  setUpAll(_loadIconFont);

  // ── BackToTop ───────────────────────────────────────────────────
  // The reference is the kit's `--esempi-with-nav` story, captured after a Tab
  // because `.visually-hidden-focusable` keeps the bar off-screen until then.
  //
  // ONE link, deliberately. Upstream puts `.visually-hidden-focusable` on each
  // `li`, not on the bar, so only the *focused* link occupies space — the
  // captured `.skiplinks` box is 868x40 with two links in the DOM. This port
  // reveals every link together once any of them has focus, so capturing two
  // here would compare 868x80 against 868x40 and score the divergence as a
  // rendering defect. It is not one: it is a behavioural difference, recorded
  // in doc/quality-plan.md. Captured single-link so this measures what parity
  // is for — colour, padding, typography, alignment.
  testWidgets('capture: nav_skiplinks', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_skiplinks.png',
      surfaceSize: const Size(900, 300),
      child: const SizedBox(
        width: 868,
        child: ItSkiplinks(
          hideUntilFocused: false,
          links: [ItSkiplink(label: 'Skip to main content')],
        ),
      ),
    );
  });

  testWidgets('capture: nav_backtotop', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_backtotop.png',
      surfaceSize: const Size(900, 300),
      child: const ItBackToTopButton(),
    );
  });

  testWidgets('capture: nav_backtotop_dark', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_backtotop_dark.png',
      surfaceSize: const Size(900, 300),
      child: const ItBackToTopButton(dark: true),
    );
  });

  testWidgets('capture: nav_backtotop_small', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_backtotop_small.png',
      surfaceSize: const Size(900, 300),
      child: const ItBackToTopButton(small: true),
    );
  });

  // ── Breadcrumb ──────────────────────────────────────────────────
  testWidgets('capture: nav_breadcrumb', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_breadcrumb.png',
      surfaceSize: const Size(900, 300),
      child: const SizedBox(
        width: 868,
        child: ItBreadcrumb(items: _breadcrumbItems),
      ),
    );
  });

  testWidgets('capture: nav_breadcrumb_dark', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_breadcrumb_dark.png',
      surfaceSize: const Size(900, 300),
      child: const SizedBox(
        width: 868,
        child: ItBreadcrumb(items: _breadcrumbItems, dark: true),
      ),
    );
  });

  // ── Headers ─────────────────────────────────────────────────────
  testWidgets('capture: nav_header_slim', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_header_slim.png',
      surfaceSize: const Size(1248, 400),
      child: const SizedBox(
        width: 1248,
        child: ItSlimHeader(
          institutionName: 'Ente appartenenza',
          links: [
            ItSlimHeaderLink(label: 'Link 1'),
            ItSlimHeaderLink(label: 'Link 2 Active', active: true),
          ],
          dropdownLabel: 'ITA',
          accessLabel: 'Accedi',
        ),
      ),
    );
  });

  testWidgets('capture: nav_header_center', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_header_center.png',
      surfaceSize: const Size(1248, 400),
      child: SizedBox(width: 1248, child: _centerHeader()),
    );
  });

  testWidgets('capture: nav_header_nav', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_header_nav.png',
      surfaceSize: const Size(1248, 400),
      child: SizedBox(width: 1248, child: _navHeader(contentInset: 12)),
    );
  });

  testWidgets('capture: nav_header_complete', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_header_complete.png',
      surfaceSize: const Size(1248, 600),
      child: SizedBox(
        width: 1248,
        child: ItHeader(
          slimHeader: const ItSlimHeader(
            institutionName: 'Ente di appartenenza',
            links: [
              ItSlimHeaderLink(label: 'Link 1'),
              ItSlimHeaderLink(label: 'Link 2 Active', active: true),
            ],
            dropdownLabel: 'ITA',
            accessLabel: 'Accedi',
          ),
          centerHeader: _centerHeader(small: true),
          navHeader: _navHeader(dropdownLabel: 'Menu Dropdown'),
        ),
      ),
    );
  });

  // ── Footer ──────────────────────────────────────────────────────
  testWidgets('capture: nav_footer_brand', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_footer_brand.png',
      surfaceSize: const Size(1248, 400),
      child: const ColoredBox(
        color: _footerMainBg,
        child: SizedBox(
          width: 1152,
          child: ItFooterBrand(
            logo: Icon(BootstrapItaliaIcons.it_pa),
            institutionName: 'Nome del Comune',
            description: 'Uno dei tanti Comuni d Italia',
          ),
        ),
      ),
    );
  });

  testWidgets('capture: nav_footer_links', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_footer_links.png',
      surfaceSize: const Size(1248, 600),
      child: const ColoredBox(
        color: _footerMainBg,
        child: SizedBox(
          width: 1152,
          child: ItFooterLinkColumns(sections: _footerSections),
        ),
      ),
    );
  });

  testWidgets('capture: nav_footer_smallprints', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_footer_smallprints.png',
      surfaceSize: const Size(1248, 400),
      child: const SizedBox(
        width: 1248,
        child: ItFooterSmallPrints(
          links: [
            ItFooterLink(label: 'Media policy'),
            ItFooterLink(label: 'Note legali'),
            ItFooterLink(label: 'Privacy policy'),
            ItFooterLink(label: 'Mappa del sito'),
          ],
        ),
      ),
    );
  });

  // ── Megamenu ────────────────────────────────────────────────────
  // The reference for this key cannot be produced by capture.mjs: the panel
  // is `display: none` until its toggle is clicked, and the shared harness
  // has no interaction hook. See the agent report for how it was captured.
  testWidgets('capture: nav_megamenu_heading', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/nav_megamenu_heading.png',
      surfaceSize: const Size(1280, 600),
      child: const SizedBox(
        width: 1160,
        child: ItMegamenuPanel(
          section: ItMegamenuSection(
            label: 'Megamenu',
            headerCta: ItMegamenuCta(label: 'Esplora la sezione megamenu'),
            columns: [
              ItMegamenuColumn(
                links: [
                  ItMegamenuLink(label: 'Link lista 1'),
                  ItMegamenuLink(label: 'Link lista 2'),
                  ItMegamenuLink(label: 'Link lista 3'),
                ],
              ),
              ItMegamenuColumn(
                links: [
                  ItMegamenuLink(label: 'Link lista 4'),
                  ItMegamenuLink(label: 'Link lista 5'),
                  ItMegamenuLink(label: 'Link lista 6'),
                ],
              ),
              ItMegamenuColumn(
                links: [
                  ItMegamenuLink(label: 'Link lista 7'),
                  ItMegamenuLink(label: 'Link lista 8'),
                  ItMegamenuLink(label: 'Link lista 9'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  });
}

/// `.it-footer-main { background-color: rgb(0,76.5,153) }` — the sections are
/// transparent, so the golden capture needs the parent's blue behind them.
const Color _footerMainBg = Color(0xFF004D99);

/// The four link columns of the `Footer Completo` story.
const _footerSections = <ItFooterSection>[
  ItFooterSection(
    title: 'Amministrazione',
    links: [
      ItFooterLink(label: 'Giunta e consiglio'),
      ItFooterLink(label: 'Aree di competenza'),
      ItFooterLink(label: 'Dipendenti'),
      ItFooterLink(label: 'Luoghi'),
      ItFooterLink(label: 'Associazioni e società partecipate'),
    ],
  ),
  ItFooterSection(
    title: 'Servizi',
    links: [
      ItFooterLink(label: 'Pagamenti'),
      ItFooterLink(label: 'Sostegno'),
      ItFooterLink(label: 'Domande e iscrizioni'),
      ItFooterLink(label: 'Segnalazioni'),
      ItFooterLink(label: 'Autorizzazioni e concessioni'),
      ItFooterLink(label: 'Certificati e dichiarazioni'),
    ],
  ),
  ItFooterSection(
    title: 'Novità',
    links: [
      ItFooterLink(label: 'Notizie'),
      ItFooterLink(label: 'Eventi'),
      ItFooterLink(label: 'Comunicati Stampa'),
    ],
  ),
  ItFooterSection(
    title: 'Documenti',
    links: [
      ItFooterLink(label: 'Progetti e attività'),
      ItFooterLink(label: 'Delibere, determine e ordinanze'),
      ItFooterLink(label: 'Bandi'),
      ItFooterLink(label: 'Concorsi'),
      ItFooterLink(label: 'Albo pretorio'),
    ],
  ),
];

/// The `Nav Header` story's item list.
ItNavHeader _navHeader({
  String dropdownLabel = 'Dropdown Menu',
  double contentInset = 30,
}) {
  return ItNavHeader(
    contentInset: contentInset,
    items: [
      const ItNavItem(label: 'link 1 active', active: true),
      const ItNavItem(label: 'Link 2', disabled: true),
      const ItNavItem(label: 'Link 3'),
      const ItNavItem(label: 'Link 4'),
      ItNavItem(label: dropdownLabel, hasDropdown: true),
      const ItNavItem(
        label: 'Megamenu con Immagine e Descrizione',
        megamenu: true,
      ),
    ],
  );
}

/// The `Center Header Basic` story: `it-code-circle` logo, title, tag line,
/// three social links and the search affordance.
ItCenterHeader _centerHeader({bool small = false}) {
  return ItCenterHeader(
    small: small,
    logo: const Icon(BootstrapItaliaIcons.it_code_circle),
    title: 'Lorem Ipsum Lorem Ipsum',
    subtitle: 'Inserire qui la tag line',
    socialLinks: const [
      ItSocialLink(icon: BootstrapItaliaIcons.it_facebook, label: 'Facebook'),
      ItSocialLink(icon: BootstrapItaliaIcons.it_github, label: 'GitHub'),
      ItSocialLink(icon: BootstrapItaliaIcons.it_twitter, label: 'X'),
    ],
    showSearch: true,
    onSearchTap: () {},
  );
}
