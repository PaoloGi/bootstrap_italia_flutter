import 'package:bootstrap_italia/bootstrap_italia.dart';
import 'package:flutter/material.dart';

import '../../widgets/component_page.dart';
import '../../widgets/example_section.dart';

const _cities = [
  'Roma',
  'Milano',
  'Napoli',
  'Torino',
  'Firenze',
  'Bologna',
  'Genova',
  'Palermo',
  'Bari',
  'Catania',
  'Venezia',
  'Verona',
  'Trieste',
  'Cagliari',
  'Perugia',
];

Future<List<String>> _searchCities(String query) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 200));
  final lower = query.toLowerCase();
  return _cities.where((c) => c.toLowerCase().contains(lower)).toList();
}

class AutocompletePage extends StatelessWidget {
  const AutocompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Autocompletamento',
      children: [
        ExampleSection(
          title: 'Base',
          child: ItAutocomplete<String>(
            label: 'Cerca una città',
            icon: Icons.search,
            onSearch: _searchCities,
            displayStringForOption: (s) => s,
            onSelected: (city) {},
          ),
        ),
        ExampleSection(
          title: 'Senza icona',
          child: ItAutocomplete<String>(
            label: 'Cerca una città',
            hint: 'Digita il nome della città',
            onSearch: _searchCities,
            displayStringForOption: (s) => s,
            onSelected: (city) {},
          ),
        ),
        ExampleSection(
          title: 'Nessun risultato',
          child: ItAutocomplete<String>(
            label: 'Cerca (prova "xyz")',
            icon: Icons.search,
            onSearch: (query) async => [],
            displayStringForOption: (s) => s,
            noResultsText: 'Nessun risultato trovato',
          ),
        ),
        ExampleSection(
          title: 'Variante grande',
          child: ItAutocomplete<String>(
            label: 'Cerca una città',
            icon: Icons.search,
            big: true,
            onSearch: _searchCities,
            displayStringForOption: (s) => s,
            onSelected: (city) {},
          ),
        ),
        const ExampleSection(
          title: 'Disabilitato',
          child: ItAutocomplete<String>(
            label: 'Cerca una città',
            icon: Icons.search,
            enabled: false,
            onSearch: _searchCitiesStub,
            displayStringForOption: _identity,
          ),
        ),
      ],
    );
  }
}

// Top-level functions for const constructor
Future<List<String>> _searchCitiesStub(String query) async => [];
String _identity(String s) => s;
