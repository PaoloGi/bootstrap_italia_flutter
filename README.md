# bootstrap_italia

Bootstrap Italia design system for Flutter — PA-compliant UI components for Italian government applications.

[![Pub Version](https://img.shields.io/pub/v/bootstrap_italia)](https://pub.dev/packages/bootstrap_italia)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter Platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://flutter.dev)

## Features

- PA-compliant UI components following Bootstrap Italia v2.18.0
- 28 ready-to-use widgets (buttons, alerts, badges, cards, forms, modals, dropdowns, notifications, and more)
- Complete theme system with customizable color scheme
- Responsive utilities (`ItResponsiveBuilder`, `ItContainer`, breakpoint extensions)
- Design tokens (colors, typography, spacing, shadows, borders)
- Bundled fonts (TitilliumWeb, Lora, RobotoMono) — offline-ready, GDPR-safe
- Accessibility: Semantics on all interactive widgets
- Works on Web, Mobile, and Desktop

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  bootstrap_italia: ^0.1.0
```

Then wrap your app with the Bootstrap Italia theme:

```dart
import 'package:bootstrap_italia/bootstrap_italia.dart';

void main() {
  final theme = BootstrapItaliaThemeData.standard();
  runApp(
    BootstrapItaliaTheme(
      data: theme,
      child: MaterialApp(
        theme: theme.toThemeData(),
        home: MyApp(),
      ),
    ),
  );
}
```

## Components Overview

### Core UI

`ItButton`, `ItBadge`, `ItAlert`, `ItSpinner`, `ItIcon`, `ItChip`

### Content

`ItCard`, `ItAccordion`, `ItCollapse`, `ItTabBar`, `ItTabView`, `ItList`, `ItCallout`

### Form

`ItInput`, `ItSelect`, `ItCheckbox`, `ItCheckboxGroup`, `ItRadioGroup`, `ItToggle`, `ItAutocomplete`

### Navigation

`ItHeader`, `ItSlimHeader`, `ItCenterHeader`, `ItNavHeader`, `ItFooter`, `ItBreadcrumb`, `ItBackToTop`

### Overlays

`ItModal`, `ItDropdown`, `ItNotification`

## Usage Examples

### Button with variants

```dart
ItButton(
  variant: ItButtonVariant.primary,
  onPressed: () {},
  child: Text('Conferma'),
)

ItButton(
  variant: ItButtonVariant.danger,
  outline: true,
  icon: Icons.delete,
  onPressed: () {},
  child: Text('Elimina'),
)

ItButton(
  variant: ItButtonVariant.secondary,
  disabled: true,
  child: Text('Disabilitato'),
)
```

### Alert with icon

```dart
ItAlert(
  variant: ItAlertVariant.success,
  icon: Icons.check_circle,
  title: 'Operazione completata',
  child: Text('Il documento e stato salvato con successo.'),
)

ItAlert(
  variant: ItAlertVariant.danger,
  icon: Icons.error,
  dismissible: true,
  child: Text('Si e verificato un errore.'),
)
```

### Form input with validation

```dart
ItInput(
  label: 'Email',
  hint: 'Inserisci la tua email',
  icon: Icons.email,
  validationState: ItValidationState.success,
  helperText: 'Email valida',
  onChanged: (value) {},
)
```

### Modal dialog

```dart
ItModal.show(
  context: context,
  title: 'Conferma operazione',
  icon: Icons.warning,
  body: Text('Sei sicuro di voler procedere?'),
  actions: [
    ItButton(
      variant: ItButtonVariant.secondary,
      onPressed: () => Navigator.pop(context),
      child: Text('Annulla'),
    ),
    ItButton(
      variant: ItButtonVariant.primary,
      onPressed: () {
        // Handle confirmation
        Navigator.pop(context);
      },
      child: Text('Conferma'),
    ),
  ],
);
```

## Custom Theming

You can customize the color scheme to match your brand:

```dart
final customTheme = BootstrapItaliaThemeData(
  colors: BootstrapItaliaColorScheme.standard.copyWith(
    primary: Color(0xFF0066CC), // Your brand color
  ),
);
```

Then apply it the same way as the standard theme:

```dart
BootstrapItaliaTheme(
  data: customTheme,
  child: MaterialApp(
    theme: customTheme.toThemeData(),
    home: MyApp(),
  ),
)
```

## Contributing

Contributions are welcome. Please open issues and pull requests on the [GitHub repository](https://github.com/nickt92/bootstrap_italia_flutter).

## License

MIT. See [LICENSE](LICENSE) for details.
