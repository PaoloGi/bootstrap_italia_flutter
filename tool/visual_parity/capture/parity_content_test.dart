import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_helpers.dart';

const _outDir = 'tool/visual_parity/flutter_captures';

/// Body copy reused by the Cards stories.
const _cardText = 'Questo è un testo breve che riassume il contenuto della '
    'pagina di destinazione in massimo tre o quattro righe, senza troncamento.';

/// Body copy reused by the Callout stories.
const _calloutText = 'Maecenas vulputate ante dictum vestibulum volutpat. '
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean non '
    'augue non purus vestibulum varius.';

/// Description reused by the multiline Liste story.
const _listText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit…';

/// Wraps [child] at the exact CSS pixel width the story renders it at, so the
/// Flutter capture and the Playwright reference frame the same geometry.
Widget _sized(double width, Widget child) =>
    SizedBox(width: width, child: child);

void main() {
  // ── Cards ─────────────────────────────────────────────────────────
  // Documentazione/Componenti/Cards :: Editorial Standard (third card,
  // the one without an image).

  testWidgets('capture: card_simple', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/card_simple.png',
      surfaceSize: const Size(700, 400),
      child: _sized(
        472,
        ItCard(
          title: 'Titolo del contenuto',
          body: const Text(_cardText),
          date: '22 aprile 2025',
          onTap: () {},
        ),
      ),
    );
  });

  testWidgets('capture: card_body', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/card_body.png',
      surfaceSize: const Size(700, 300),
      child: _sized(470, const ItCardBody(child: Text(_cardText))),
    );
  });

  testWidgets('capture: card_footer_category', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/card_footer_category.png',
      surfaceSize: const Size(700, 300),
      child: _sized(
        438,
        ItCardFooter(
          category: ItCardCategory(label: 'Categoria', onTap: () {}),
          date: '22 aprile 2025',
        ),
      ),
    );
  });

  // ── Accordion ─────────────────────────────────────────────────────
  // Documentazione/Componenti/Accordion (all panels collapsed, as the
  // stories render them).

  testWidgets('capture: accordion_collapsed', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/accordion_collapsed.png',
      surfaceSize: const Size(1100, 400),
      child: _sized(
        968,
        const ItAccordion(
          items: [
            ItAccordionItem(
              title: 'Accordion Group Item #1',
              body: Text('Vestibulum hendrerit ultrices nibh.'),
            ),
            ItAccordionItem(
              title: 'Accordion Group Item #2',
              body: Text('Ad vegan excepteur butcher vice lomo.'),
            ),
            ItAccordionItem(
              title: 'Accordion Group Item #3',
              body: Text('Food truck quinoa nesciunt laborum eiusmod.'),
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('capture: accordion_groups', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/accordion_groups.png',
      surfaceSize: const Size(1100, 400),
      child: _sized(
        968,
        const ItAccordion(
          items: [
            ItAccordionItem(
              title: 'Elemento Richiudibile #1',
              body: Text('Anim pariatur cliche reprehenderit.'),
            ),
            ItAccordionItem(
              title: 'Elemento Richiudibile #2',
              body: Text('Ad vegan excepteur butcher vice lomo.'),
            ),
            ItAccordionItem(
              title: 'Elemento Richiudibile #3',
              body: Text('Food truck quinoa nesciunt laborum eiusmod.'),
            ),
          ],
        ),
      ),
    );
  });

  // ── Tab ───────────────────────────────────────────────────────────
  // Documentazione/Componenti/Tab

  testWidgets('capture: tab_textual', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/tab_textual.png',
      surfaceSize: const Size(1100, 300),
      child: _sized(
        968,
        ItTabBar(
          selectedIndex: 0,
          onChanged: (_) {},
          tabs: const [
            ItTabItem(label: 'Attivo'),
            ItTabItem(label: 'Link'),
            ItTabItem(label: 'Link'),
            ItTabItem(label: 'Disattivo', disabled: true),
          ],
        ),
      ),
    );
  });

  testWidgets('capture: tab_icon_text', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/tab_icon_text.png',
      surfaceSize: const Size(1100, 300),
      child: _sized(
        968,
        ItTabBar(
          selectedIndex: 0,
          onChanged: (_) {},
          // The story renders the design kit's own SVG icons; the equivalent
          // Flutter glyphs live in the `bootstrap_italia_icons` font.
          tabs: const [
            ItTabItem(label: 'Tab 1', icon: BootstrapItaliaIcons.it_link),
            ItTabItem(label: 'Tab 2', icon: BootstrapItaliaIcons.it_calendar),
            ItTabItem(label: 'Tab 3', icon: BootstrapItaliaIcons.it_comment),
            ItTabItem(
              label: 'Tab 4',
              icon: BootstrapItaliaIcons.it_close,
              disabled: true,
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('capture: tab_panel', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/tab_panel.png',
      surfaceSize: const Size(1100, 400),
      child: _sized(
        968,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ItTabBar(
              selectedIndex: 0,
              onChanged: (_) {},
              tabs: const [
                ItTabItem(label: 'Attivo'),
                ItTabItem(label: 'Link'),
                ItTabItem(label: 'Link'),
                ItTabItem(label: 'Disattivo', disabled: true),
              ],
            ),
            // `.tab-pane.p-4` — 1.5rem of padding around the pane content.
            Padding(
              padding: const EdgeInsets.all(24),
              child: DefaultTextStyle.merge(
                style: BootstrapItaliaTypography.desktop.bodySmall.copyWith(
                  color: BootstrapItaliaColors.bodyColor,
                ),
                child: const ItTabView(
                  selectedIndex: 0,
                  animated: false,
                  children: [
                    Text('Contenuto 1'),
                    Text('Contenuto 2'),
                    Text('Contenuto 3'),
                    Text('Contenuto 4'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  });

  // ── Liste ─────────────────────────────────────────────────────────
  // Documentazione/Organizzare i contenuti/Liste

  testWidgets('capture: list_active', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/list_active.png',
      surfaceSize: const Size(1100, 400),
      child: _sized(
        968,
        ItList(
          showDividers: false,
          items: [
            ItListItem(title: 'Link list 1', onTap: () {}),
            ItListItem(title: 'Link list 2 active', active: true, onTap: () {}),
            ItListItem(title: 'Link list 3', onTap: () {}),
          ],
        ),
      ),
    );
  });

  testWidgets('capture: list_disabled', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/list_disabled.png',
      surfaceSize: const Size(1100, 400),
      child: _sized(
        968,
        ItList(
          showDividers: false,
          items: [
            ItListItem(title: 'Link list 1', onTap: () {}),
            ItListItem(
              title: 'Link list 2 disabled',
              disabled: true,
              onTap: () {},
            ),
            ItListItem(title: 'Link list 3', onTap: () {}),
          ],
        ),
      ),
    );
  });

  testWidgets('capture: list_multiline', (tester) async {
    // `.link-list-wrapper ul li a .icon` is 32x32 and follows the title
    // colour; the disabled modifier greys it to hsl(210, 3%, 85%).
    const activeIcon =
        Icon(Icons.chevron_right, size: 32, color: Color(0xFF00264D));
    const linkIcon =
        Icon(Icons.chevron_right, size: 32, color: Color(0xFF0066CC));
    const disabledIcon =
        Icon(Icons.chevron_right, size: 32, color: Color(0xFFD8D9DA));

    await captureWidget(
      tester,
      outputPath: '$_outDir/list_multiline.png',
      surfaceSize: const Size(1100, 500),
      child: _sized(
        968,
        ItList(
          items: [
            ItListItem(
              title: 'Link list 1 active',
              subtitle: _listText,
              trailing: activeIcon,
              active: true,
              onTap: () {},
            ),
            ItListItem(
              title: 'Link list 2',
              subtitle: _listText,
              trailing: linkIcon,
              onTap: () {},
            ),
            ItListItem(
              title: 'Link list 3 disabled',
              subtitle: _listText,
              trailing: disabledIcon,
              disabled: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  });

  // ── Callout ───────────────────────────────────────────────────────
  // Documentazione/Componenti/Callout

  testWidgets('capture: callout_basic', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/callout_basic.png',
      surfaceSize: const Size(1100, 400),
      child: _sized(
        968,
        const ItCallout(
          title: 'Titolo Callout',
          showIcon: false,
          body: Text(_calloutText),
        ),
      ),
    );
  });

  testWidgets('capture: callout_icon', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/callout_icon.png',
      surfaceSize: const Size(1100, 400),
      child: _sized(
        968,
        const ItCallout(
          title: 'Titolo Callout',
          body: Text(_calloutText),
        ),
      ),
    );
  });

  testWidgets('capture: callout_success', (tester) async {
    await captureWidget(
      tester,
      outputPath: '$_outDir/callout_success.png',
      surfaceSize: const Size(1100, 400),
      child: _sized(
        968,
        const ItCallout(
          variant: ItCalloutVariant.success,
          title: 'Usa',
          body: Text(_calloutText),
        ),
      ),
    );
  });
}
