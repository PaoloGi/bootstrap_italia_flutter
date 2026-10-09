// A "everything at once" page — every component the package exports, on one
// scrolling document.
//
// Two harnesses drive it, and they see different things:
//
//   * `tool/visual_parity/playwright/soak.mjs` builds it for the web and runs a
//     real browser over it with axe;
//   * `example/integration_test/device_soak_test.dart` runs it on a real
//     device, where the fonts, the text metrics and the safe-area insets are
//     the platform's rather than a headless engine's default.
//
// The parity harness mounts ONE component per page on purpose — a pixel
// comparison needs isolation. This is the opposite: every widget the package
// exports, together, on one scrolling document, so the failures that only
// appear in combination have somewhere to appear.
//
//   cd example && flutter build web -t lib/soak.dart --no-tree-shake-icons
//   (cd example/build/web && python3 -m http.server 8788)
//   node ../../tool/soak/soak.mjs
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Conditional: `dart:js_interop` does not exist off the web, and importing it
// unconditionally makes this page uncompilable for a device — which is how the
// first on-device run failed.
import 'soak_text_scale_io.dart'
    if (dart.library.js_interop) 'soak_text_scale_web.dart';

void main() {
  // A release web build minifies the stack, so a raw console error says only
  // "Null check operator used on a null value" with no hint of where. The
  // details object still carries the library, the context and the offending
  // widget as plain strings — printing those is the difference between an
  // unactionable log line and a name.
  FlutterError.onError = (details) {
    // ignore: avoid_print
    print('SOAK-ERROR :: ${details.exceptionAsString()} '
        ':: library=${details.library} '
        ':: context=${details.context} '
        ':: widget=${details.informationCollector == null ? '' : ''}'
        '${_describe(details)}');
    FlutterError.presentError(details);
  };
  runApp(const SoakApp());
}

String _describe(FlutterErrorDetails d) {
  final n = d.context?.toDescription() ?? '';
  return n.isEmpty ? '' : ' :: where=$n';
}

class SoakApp extends StatelessWidget {
  const SoakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = BootstrapItaliaThemeData.standard();
    return BootstrapItaliaTheme(
      data: theme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bootstrap Italia Flutter — soak',
        theme: theme.toThemeData(),
        // `GlobalMaterialLocalizations.delegates` is not optional once
        // `supportedLocales` is Italian: ItInput wraps a Material TextField,
        // which needs MaterialLocalizations, and the built-in fallback only
        // covers `en`. Omitting it crashes the field — and in a release web
        // build the message is a bare "Null check operator used on a null
        // value", which names nothing. The README and the example app both get
        // this right; this page did not.
        localizationsDelegates: const [
          ItLocalizationsDelegate(),
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: ItLocalizations.supportedLocales,
        builder: (context, child) {
          final scale = urlTextScale();
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          );
        },
        home: const SoakPage(),
      ),
    );
  }
}

class SoakPage extends StatefulWidget {
  const SoakPage({super.key});
  @override
  State<SoakPage> createState() => _SoakPageState();
}

class _SoakPageState extends State<SoakPage> {
  final _scroll = ScrollController();
  final _text = TextEditingController(text: 'Testo di prova');
  final _empty = TextEditingController();
  bool _check = false;
  bool _toggle = false;
  int _radio = 1;
  int? _select = 2;
  int _tab = 0;
  int _nav = 1;

  @override
  void dispose() {
    _scroll.dispose();
    _text.dispose();
    _empty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            child: ItContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ItSkiplinks(links: [
                    ItSkiplink(label: 'Vai al contenuto', onActivate: () {}),
                  ]),
                  _s('header', [
                    ItSlimHeader(
                      institutionName: 'Ente di prova',
                      accessLabel: 'Accedi',
                      onAccessTap: () {},
                    ),
                    ItCenterHeader(
                      title: 'Bootstrap Italia Flutter',
                      subtitle: 'Soak test',
                      showSearch: true,
                      onSearchTap: () {},
                    ),
                    ItNavHeader(items: const [
                      ItNavItem(label: 'Uno'),
                      ItNavItem(label: 'Due'),
                    ]),
                  ]),
                  _s('buttons', [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final v in ItButtonVariant.values)
                        ItButton(
                          variant: v,
                          onPressed: () {},
                          child: Text(v.name),
                        ),
                      ItButton(
                        outline: true,
                        onPressed: () {},
                        child: const Text('outline'),
                      ),
                      const ItButton(disabled: true, child: Text('disabled')),
                      ItButton(
                        loading: true,
                        onPressed: () {},
                        child: const Text('loading'),
                      ),
                      ItButton(
                        icon: BootstrapItaliaIcons.it_download,
                        onPressed: () {},
                        child: const Text('con icona'),
                      ),
                    ]),
                  ]),
                  _s('badges & chips', [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final v in ItBadgeVariant.values)
                        ItBadge(variant: v, child: Text(v.name)),
                      const ItNotificationBadge(
                        count: 7,
                        semanticLabel: '7 messaggi non letti',
                        child: Icon(BootstrapItaliaIcons.it_mail, size: 28),
                      ),
                      ItChip(
                          label: 'Chip', dismissible: true, onDismiss: () {}),
                    ]),
                  ]),
                  _s('alerts & callouts', [
                    for (final v in ItAlertVariant.values)
                      ItAlert(
                        variant: v,
                        title: 'Avviso ${v.name}',
                        dismissible: true,
                        body: Text('Corpo dell\'avviso ${v.name}.'),
                      ),
                    for (final v in ItCalloutVariant.values)
                      ItCallout(
                        variant: v,
                        title: 'Callout ${v.name}',
                        body: const Text('Testo del callout.'),
                      ),
                  ]),
                  _s('forms', [
                    ItInput(
                      label: 'Campo di testo',
                      controller: _text,
                      helperText: 'Testo di aiuto',
                      required: true,
                    ),
                    ItInput(
                      label: 'In errore',
                      controller: _empty,
                      errorText: 'Campo obbligatorio',
                    ),
                    ItInput(
                      label: 'Disabilitato',
                      controller: _text,
                      enabled: false,
                    ),
                    ItSelect<int>(
                      label: 'Selezione',
                      value: _select,
                      items: const [
                        ItSelectItem<int>(value: 1, label: 'Uno'),
                        ItSelectItem<int>(value: 2, label: 'Due'),
                        ItSelectItem<int>(value: 3, label: 'Tre'),
                      ],
                      onChanged: (v) => setState(() => _select = v),
                    ),
                    ItAutocomplete<String>(
                      label: 'Autocomplete',
                      onSearch: (q) async => ['Ancona', 'Pesaro', 'Macerata']
                          .where(
                              (e) => e.toLowerCase().contains(q.toLowerCase()))
                          .toList(),
                      displayStringForOption: (o) => o,
                    ),
                    ItCheckbox(
                      label: 'Casella',
                      value: _check,
                      onChanged: (v) => setState(() => _check = v),
                    ),
                    ItToggle(
                      label: 'Interruttore',
                      value: _toggle,
                      onChanged: (v) => setState(() => _toggle = v),
                    ),
                    ItRadioGroup<int>(
                      label: 'Gruppo radio',
                      value: _radio,
                      options: const [
                        ItRadioOption<int>(value: 1, label: 'Primo'),
                        ItRadioOption<int>(value: 2, label: 'Secondo'),
                      ],
                      onChanged: (v) => setState(() => _radio = v),
                    ),
                  ]),
                  _s('content', [
                    ItCard(
                      title: 'Carta',
                      subtitle: 'Sottotitolo',
                      titleVisualLevel: 4,
                      body: const Text('Corpo della carta.'),
                      onTap: () {},
                    ),
                    const ItAccordion(items: [
                      ItAccordionItem(
                        title: 'Sezione uno',
                        body: Text('Contenuto uno.'),
                      ),
                      ItAccordionItem(
                        title: 'Sezione due',
                        body: Text('Contenuto due.'),
                      ),
                    ]),
                    ItList(items: const [
                      ItListItem(title: 'Voce attiva', active: true),
                      ItListItem(title: 'Voce normale'),
                      ItListDivider(),
                      ItListItem(title: 'Voce disabilitata', disabled: true),
                    ]),
                    ItTabBar(
                      selectedIndex: _tab,
                      onChanged: (i) => setState(() => _tab = i),
                      tabs: const [
                        ItTabItem(label: 'Prima'),
                        ItTabItem(label: 'Seconda'),
                      ],
                    ),
                    SizedBox(
                      height: 120,
                      child: ItTabView(
                        selectedIndex: _tab,
                        children: const [
                          Text('Pannello uno'),
                          Text('Pannello due'),
                        ],
                      ),
                    ),
                    const ItBreadcrumb(items: [
                      ItBreadcrumbItem(label: 'Home'),
                      ItBreadcrumbItem(label: 'Sezione'),
                      ItBreadcrumbItem(label: 'Pagina'),
                    ]),
                    ItCarousel(
                      height: 140,
                      items: const [
                        ColoredBox(
                            color: Color(0xFFE8F0FA),
                            child: Center(child: Text('Slide 1'))),
                        ColoredBox(
                            color: Color(0xFFF0E8FA),
                            child: Center(child: Text('Slide 2'))),
                      ],
                    ),
                    ItSidebar(
                      title: 'Barra laterale',
                      lineRight: true,
                      child: ItList(items: const [
                        ItListItem(title: 'Link uno'),
                        ItListItem(title: 'Link due'),
                      ]),
                    ),
                    const ItSpinner(),
                    const ItCollapse(
                      isExpanded: true,
                      child: Text('Contenuto rivelato.'),
                    ),
                  ]),
                  _s('overlays (opened by the driver)', [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      Builder(
                        builder: (c) => ItButton(
                          key: const Key('soak-open-modal'),
                          onPressed: () => ItModal.show<void>(
                            context: c,
                            title: 'Titolo modale',
                            body: const Text('Corpo della modale.'),
                            actions: [
                              ItButton(
                                  onPressed: () {}, child: const Text('Ok')),
                            ],
                          ),
                          child: const Text('Apri modale'),
                        ),
                      ),
                      Builder(
                        builder: (c) => ItButton(
                          key: const Key('soak-open-offcanvas'),
                          onPressed: () => ItOffcanvas.show<void>(
                            context: c,
                            title: 'Pannello',
                            body: const Text('Contenuto del pannello.'),
                          ),
                          child: const Text('Apri pannello'),
                        ),
                      ),
                      Builder(
                        builder: (c) => ItButton(
                          key: const Key('soak-open-notification'),
                          onPressed: () => ItNotification.show(
                            context: c,
                            variant: ItNotificationVariant.success,
                            title: 'Fatto',
                            body: 'Operazione completata.',
                            duration: null,
                          ),
                          child: const Text('Mostra notifica'),
                        ),
                      ),
                      ItDropdown(
                        trigger: const Text('Menu a tendina'),
                        items: const [
                          ItDropdownHeader(label: 'Gruppo'),
                          ItDropdownItem(label: 'Voce uno'),
                          ItDropdownItem(label: 'Voce due'),
                        ],
                      ),
                    ]),
                  ]),
                  _s('footer', [
                    const ItFooter(
                      institutionName: 'Ente di prova',
                      description: 'Footer di prova',
                      sections: [
                        ItFooterSection(
                          title: 'Sezione',
                          links: [
                            ItFooterLink(label: 'Link uno'),
                            ItFooterLink(label: 'Link due'),
                          ],
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          ItBackToTop(scrollController: _scroll),
        ],
      ),
      bottomNavigationBar: ItBottomNav(
        semanticLabel: 'Navigazione secondaria',
        selectedIndex: _nav,
        onSelected: (i) => setState(() => _nav = i),
        items: const [
          ItBottomNavItem(label: 'Uno', icon: BootstrapItaliaIcons.it_file),
          ItBottomNavItem(label: 'Due', icon: BootstrapItaliaIcons.it_pencil),
          ItBottomNavItem(
              label: 'Tre', icon: BootstrapItaliaIcons.it_clock, badge: 3),
        ],
      ),
    );
  }

  Widget _s(String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
              ),
            ),
            for (final c in children)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: c,
              ),
          ],
        ),
      );
}
