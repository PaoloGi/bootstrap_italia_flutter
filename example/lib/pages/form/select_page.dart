import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  String? _selectedCity;
  String? _searchableCity;
  Set<String> _selectedCities = {};

  final _cities = const [
    ItSelectItem(value: 'roma', label: 'Roma'),
    ItSelectItem(value: 'milano', label: 'Milano'),
    ItSelectItem(value: 'napoli', label: 'Napoli'),
    ItSelectItem(value: 'torino', label: 'Torino'),
    ItSelectItem(value: 'firenze', label: 'Firenze'),
  ];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Select',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItSelect<String>(
            label: 'Città',
            hint: 'Seleziona una città',
            items: _cities,
            value: _selectedCity,
            onChanged: (value) => setState(() => _selectedCity = value),
          ),
        ),
        ExampleSection(
          title: 'Con ricerca',
          child: ItSelect<String>(
            label: 'Città',
            hint: 'Cerca una città',
            items: _cities,
            value: _searchableCity,
            searchable: true,
            onChanged: (value) => setState(() => _searchableCity = value),
          ),
        ),
        ExampleSection(
          title: 'Multi selezione',
          child: ItSelect<String>(
            label: 'Città preferite',
            hint: 'Seleziona una o più città',
            items: _cities,
            multiple: true,
            values: _selectedCities,
            onMultiChanged: (values) =>
                setState(() => _selectedCities = values),
          ),
        ),
        ExampleSection(
          title: 'Disabilitato',
          child: ItSelect<String>(
            label: 'Città',
            hint: 'Non disponibile',
            items: _cities,
            disabled: true,
          ),
        ),
      ],
    );
  }
}
