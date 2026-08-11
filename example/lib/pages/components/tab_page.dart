import 'package:flutter/material.dart';
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _underlineIndex = 0;
  int _cardIndex = 0;
  int _buttonIndex = 0;

  static const _tabs = [
    ItTabItem(label: 'Panoramica'),
    ItTabItem(label: 'Dettagli'),
    ItTabItem(label: 'Contatti'),
  ];

  static const _tabContents = [
    Padding(
      padding: EdgeInsets.all(BootstrapItaliaSpacing.space3),
      child: Text('Contenuto della sezione Panoramica.'),
    ),
    Padding(
      padding: EdgeInsets.all(BootstrapItaliaSpacing.space3),
      child: Text('Contenuto della sezione Dettagli.'),
    ),
    Padding(
      padding: EdgeInsets.all(BootstrapItaliaSpacing.space3),
      child: Text('Contenuto della sezione Contatti.'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Tab',
      children: [
        ExampleSection(
          title: 'Underline',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItTabBar(
                tabs: _tabs,
                selectedIndex: _underlineIndex,
                style: ItTabStyle.underline,
                onChanged: (i) => setState(() => _underlineIndex = i),
              ),
              ItTabView(
                selectedIndex: _underlineIndex,
                children: _tabContents,
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Card',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItTabBar(
                tabs: _tabs,
                selectedIndex: _cardIndex,
                style: ItTabStyle.card,
                onChanged: (i) => setState(() => _cardIndex = i),
              ),
              ItTabView(
                selectedIndex: _cardIndex,
                children: _tabContents,
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'Button',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItTabBar(
                tabs: _tabs,
                selectedIndex: _buttonIndex,
                style: ItTabStyle.button,
                onChanged: (i) => setState(() => _buttonIndex = i),
              ),
              ItTabView(
                selectedIndex: _buttonIndex,
                children: _tabContents,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
