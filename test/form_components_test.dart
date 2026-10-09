import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    ))),
  );
}

void main() {
  group('ItInput', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItInput(groupMargin: false, label: 'Nome'),
      ));

      expect(find.text('Nome'), findsOneWidget);
    });

    testWidgets('calls onChanged when text entered', (tester) async {
      String? result;
      await tester.pumpWidget(_wrap(
        ItInput(
          groupMargin: false,
          label: 'Email',
          onChanged: (v) => result = v,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'test@example.com');
      expect(result, 'test@example.com');
    });

    testWidgets('shows helper text', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItInput(
          groupMargin: false,
          label: 'CF',
          helperText: 'Codice fiscale di 16 caratteri',
        ),
      ));

      expect(find.text('Codice fiscale di 16 caratteri'), findsOneWidget);
    });

    testWidgets('shows error text', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItInput(
          groupMargin: false,
          label: 'Email',
          errorText: 'Email non valida',
        ),
      ));

      expect(find.text('Email non valida'), findsOneWidget);
    });

    testWidgets('shows prefix icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItInput(groupMargin: false, label: 'Cerca', icon: Icons.search),
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('password toggle works', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItInput(
          groupMargin: false,
          label: 'Password',
          obscureText: true,
          showPasswordToggle: true,
        ),
      ));

      // Initially obscured — the "reveal" eye is shown.
      expect(
        find.byIcon(BootstrapItaliaIcons.it_password_visible),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(BootstrapItaliaIcons.it_password_visible));
      await tester.pump();

      expect(
        find.byIcon(BootstrapItaliaIcons.it_password_invisible),
        findsOneWidget,
      );
    });

    testWidgets('disabled state works', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItInput(groupMargin: false, label: 'Disabled', enabled: false),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('validation state shows icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItInput(
          groupMargin: false,
          label: 'Valid',
          validationState: ItValidationState.success,
        ),
      ));

      expect(
        find.byIcon(BootstrapItaliaIcons.it_check_circle),
        findsOneWidget,
      );
    });
  });

  group('ItCheckbox', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItCheckbox(value: false, label: 'Accept terms'),
      ));

      expect(find.text('Accept terms'), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(_wrap(
        ItCheckbox(
          value: false,
          label: 'Check me',
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.text('Check me'));
      expect(result, isTrue);
    });

    testWidgets('unchecks when tapped while checked', (tester) async {
      bool? result;
      await tester.pumpWidget(_wrap(
        ItCheckbox(
          value: true,
          label: 'Uncheck me',
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.text('Uncheck me'));
      expect(result, isFalse);
    });

    testWidgets('disabled does not call onChanged', (tester) async {
      bool? result;
      await tester.pumpWidget(_wrap(
        ItCheckbox(
          value: false,
          label: 'Disabled',
          enabled: false,
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.text('Disabled'));
      expect(result, isNull);
    });
  });

  group('ItCheckboxGroup', () {
    testWidgets('renders all options', (tester) async {
      await tester.pumpWidget(_wrap(
        ItCheckboxGroup<String>(
          options: const [
            ItCheckboxOption(value: 'a', label: 'Option A'),
            ItCheckboxOption(value: 'b', label: 'Option B'),
          ],
          values: const {},
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
    });

    testWidgets('calls onChanged with updated values', (tester) async {
      Set<String>? result;
      await tester.pumpWidget(_wrap(
        ItCheckboxGroup<String>(
          options: const [
            ItCheckboxOption(value: 'a', label: 'Option A'),
            ItCheckboxOption(value: 'b', label: 'Option B'),
          ],
          values: const {'a'},
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.text('Option B'));
      expect(result, containsAll(['a', 'b']));
    });

    testWidgets('renders group label', (tester) async {
      await tester.pumpWidget(_wrap(
        ItCheckboxGroup<String>(
          label: 'Select options',
          options: const [
            ItCheckboxOption(value: 'a', label: 'A'),
          ],
          values: const {},
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Select options'), findsOneWidget);
    });
  });

  group('ItRadioGroup', () {
    testWidgets('renders all options', (tester) async {
      await tester.pumpWidget(_wrap(
        ItRadioGroup<String>(
          options: const [
            ItRadioOption(value: 'M', label: 'Maschio'),
            ItRadioOption(value: 'F', label: 'Femmina'),
          ],
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Maschio'), findsOneWidget);
      expect(find.text('Femmina'), findsOneWidget);
    });

    testWidgets('calls onChanged when option tapped', (tester) async {
      String? result;
      await tester.pumpWidget(_wrap(
        ItRadioGroup<String>(
          options: const [
            ItRadioOption(value: 'M', label: 'Maschio'),
            ItRadioOption(value: 'F', label: 'Femmina'),
          ],
          value: 'M',
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.text('Femmina'));
      expect(result, 'F');
    });

    testWidgets('renders group label', (tester) async {
      await tester.pumpWidget(_wrap(
        ItRadioGroup<String>(
          label: 'Genere',
          options: const [
            ItRadioOption(value: 'M', label: 'M'),
          ],
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Genere'), findsOneWidget);
    });
  });

  group('ItToggle', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItToggle(value: false, label: 'Notifications'),
      ));

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(_wrap(
        ItToggle(
          value: false,
          label: 'Toggle me',
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.text('Toggle me'));
      expect(result, isTrue);
    });

    testWidgets('disabled does not call onChanged', (tester) async {
      bool? result;
      await tester.pumpWidget(_wrap(
        ItToggle(
          value: false,
          label: 'Disabled',
          enabled: false,
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.text('Disabled'));
      expect(result, isNull);
    });

    testWidgets('renders the .toggles lever at its CSS size', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItToggle(value: true),
      ));

      // .toggles label { height: 32px }
      expect(tester.getSize(find.byType(ItToggle)).height, 32);
      // .lever:after — the 26px thumb, filled with the primary colour when on.
      final thumb = tester.widgetList<Container>(find.byType(Container)).last;
      final decoration = thumb.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, BootstrapItaliaColors.primary);
    });
  });

  group('ItSelect', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(
        ItSelect<String>(
          groupMargin: false,
          label: 'Provincia',
          items: [
            ItSelectItem(value: 'RM', label: 'Roma'),
            ItSelectItem(value: 'MI', label: 'Milano'),
          ],
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Provincia'), findsOneWidget);
    });

    testWidgets('shows selected value', (tester) async {
      await tester.pumpWidget(_wrap(
        ItSelect<String>(
          groupMargin: false,
          label: 'Provincia',
          items: [
            ItSelectItem(value: 'RM', label: 'Roma'),
            ItSelectItem(value: 'MI', label: 'Milano'),
          ],
          value: 'RM',
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Roma'), findsOneWidget);
    });

    testWidgets('opens dropdown on tap', (tester) async {
      await tester.pumpWidget(_wrap(
        ItSelect<String>(
          groupMargin: false,
          label: 'Provincia',
          items: [
            ItSelectItem(value: 'RM', label: 'Roma'),
            ItSelectItem(value: 'MI', label: 'Milano'),
          ],
          onChanged: (_) {},
        ),
      ));

      await tester.tap(find.byType(ItSelect<String>));
      await tester.pumpAndSettle();

      // Overlay should show options
      expect(find.text('Roma'), findsOneWidget);
      expect(find.text('Milano'), findsOneWidget);
    });

    testWidgets('disabled does not open', (tester) async {
      await tester.pumpWidget(_wrap(
        ItSelect<String>(
          groupMargin: false,
          label: 'Disabled',
          items: [
            ItSelectItem(value: 'RM', label: 'Roma'),
          ],
          enabled: false,
          onChanged: (_) {},
        ),
      ));

      await tester.tap(find.byType(ItSelect<String>));
      await tester.pumpAndSettle();

      // Should only find one 'Roma' instance (none from overlay)
      expect(find.text('Roma'), findsNothing);
    });
  });

  group('ItAutocomplete', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(
        ItAutocomplete<String>(
          groupMargin: false,
          label: 'Città',
          onSearch: (_) async => [],
          displayStringForOption: (s) => s,
        ),
      ));

      expect(find.text('Città'), findsOneWidget);
    });

    testWidgets('renders TextField', (tester) async {
      await tester.pumpWidget(_wrap(
        ItAutocomplete<String>(
          groupMargin: false,
          label: 'Search',
          onSearch: (_) async => [],
          displayStringForOption: (s) => s,
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders icon outside TextField in Row', (tester) async {
      await tester.pumpWidget(_wrap(
        ItAutocomplete<String>(
          groupMargin: false,
          label: 'Search',
          icon: Icons.search,
          onSearch: (_) async => [],
          displayStringForOption: (s) => s,
        ),
      ));

      // Icon should exist
      expect(find.byIcon(Icons.search), findsOneWidget);
      // Should be in a Row (input-group pattern), not a prefixIcon
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('uses underline border not outline', (tester) async {
      await tester.pumpWidget(_wrap(
        ItAutocomplete<String>(
          groupMargin: false,
          label: 'Test',
          onSearch: (_) async => [],
          displayStringForOption: (s) => s,
        ),
      ));

      // Bootstrap Italia draws no input box at all: the only border is the
      // 1px bottom rule the widget paints itself.
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration!.border, InputBorder.none);
      expect(
        find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == const Color(0xFF5D7083),
        ),
        findsOneWidget,
      );
    });

    testWidgets('disabled state shows gray fill', (tester) async {
      await tester.pumpWidget(_wrap(
        ItAutocomplete<String>(
          groupMargin: false,
          label: 'Test',
          enabled: false,
          onSearch: (_) async => [],
          displayStringForOption: (s) => s,
        ),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
      // .form-control:disabled { background-color: hsl(210,3%,85%) }
      expect(
        find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == const Color(0xFFD8D9DA),
        ),
        findsOneWidget,
      );
    });

    testWidgets('large variant uses larger font', (tester) async {
      await tester.pumpWidget(_wrap(
        ItAutocomplete<String>(
          groupMargin: false,
          label: 'Grande',
          large: true,
          onSearch: (_) async => [],
          displayStringForOption: (s) => s,
        ),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style!.fontSize, 20.0);
    });

    testWidgets('shows suggestions after search', (tester) async {
      await tester.pumpWidget(_wrap(
        ItAutocomplete<String>(
          groupMargin: false,
          label: 'City',
          onSearch: (_) async => ['Roma', 'Milano'],
          displayStringForOption: (s) => s,
          highlightMatch: false,
          debounce: Duration.zero,
          minQueryLength: 1,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Ro');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Roma'), findsOneWidget);
      expect(find.text('Milano'), findsOneWidget);
    });

    testWidgets('shows no results message', (tester) async {
      await tester.pumpWidget(_wrap(
        ItAutocomplete<String>(
          groupMargin: false,
          label: 'City',
          onSearch: (_) async => [],
          displayStringForOption: (s) => s,
          noResultsText: 'Nessun risultato',
          debounce: Duration.zero,
          minQueryLength: 1,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Nessun risultato'), findsOneWidget);
    });

    testWidgets('selects option on tap', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(
        ItAutocomplete<String>(
          groupMargin: false,
          label: 'City',
          onSearch: (_) async => ['Roma', 'Milano'],
          displayStringForOption: (s) => s,
          highlightMatch: false,
          onSelected: (s) => selected = s,
          debounce: Duration.zero,
          minQueryLength: 1,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Ro');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Roma'));
      await tester.pumpAndSettle();

      expect(selected, 'Roma');
    });
  });
}
