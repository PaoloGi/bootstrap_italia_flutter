# Bootstrap Italia for Flutter — Execution Plan

> **Status:** FINALIZED — All decisions locked in.

## Overview

Port the [Bootstrap Italia](https://italia.github.io/bootstrap-italia/) design system (v2.18.0, based on Bootstrap 5.2.3) to a native Flutter widget library. This package provides PA (Pubblica Amministrazione) compliant UI components for Italian government applications built with Flutter.

**Reference implementations:**
- [bootstrap-italia](https://github.com/italia/bootstrap-italia) — Original SCSS/JS library
- [design-react-kit](https://github.com/italia/design-react-kit) — React component port (50+ components)

---

## Decisions Log

| # | Decision | Choice |
|---|----------|--------|
| 1 | Package name | `bootstrap_italia` |
| 2 | Min SDK | Flutter 3.22+ / Dart 3.4+ |
| 3 | Target platforms | Web + Mobile + Desktop |
| 4 | Theming | Extend `ThemeData` + custom `BootstrapItaliaTheme` InheritedWidget |
| 5 | Fonts | **Bundled inside the package** (Titillium Web, Lora, Roboto Mono) — offline-ready, GDPR-safe, no runtime network calls |
| 6 | Widget prefix | `It` (e.g., `ItButton`, `ItCard`) |
| 7 | Icons | `bootstrap_italia_icons` (primary) + `bootstrap_icons` (fallback) |
| 8 | Scope | **MVP first** (~25 core components), then full suite |
| 9 | Responsive | **Native Flutter layout** — `ItResponsiveBuilder`, `ItContainer`, `context.breakpoint` extension. NO 12-column grid. |
| 10 | Catalog app | Yes, from day one (inside `example/`) |
| 11 | pub.dev | Yes, publish from start |
| 12 | License | **MIT** (most permissive, same as Bootstrap Italia) |
| 13 | Dependencies | Minimal — only `bootstrap_italia_icons`, `bootstrap_icons`, Flutter SDK |
| 14 | Form internals | Use Flutter's `TextField`/`Checkbox`/etc with custom styling, not from scratch |
| 15 | Responsive impl | `LayoutBuilder` (not `MediaQuery`) for widget-level responsiveness |
| 16 | Animations | Match Bootstrap Italia CSS transition durations and curves |

---

## MVP Scope (~25 Components)

### Foundation
- Theme system (tokens, colors, typography, spacing, breakpoints, shadows, borders)
- Responsive utilities (`ItResponsiveBuilder`, `ItContainer`, breakpoint extensions)

### Core UI (6)
- `ItButton` — All variants, sizes, states, outline, icon support
- `ItBadge` — Color variants, pill, notification positioned
- `ItAlert` — Dismissible, with icon, color variants
- `ItSpinner` — Standard, small, active (double ring)
- `ItIcon` — Wrapper around bootstrap_italia_icons/bootstrap_icons with sizing
- `ItChip` — Simple, dismissible, with icon, group

### Navigation (4)
- `ItHeader` — Composed: `ItSlimHeader` + `ItCenterHeader` + `ItNavHeader`
- `ItFooter` — PA-standard footer structure
- `ItBreadcrumb` — Standard, with icon, dark variant
- `ItBackToTop` — Scroll-triggered floating button

### Content (6)
- `ItCard` — All sub-components: Header, Body, Image, Category, Signature
- `ItAccordion` — Single/multi open, nested, with icon
- `ItCollapse` — Animated expand/collapse
- `ItTab` — `ItTabBar` + `ItTabView`, horizontal/vertical, with icon
- `ItList` — With links, avatars, icons, metadata
- `ItCallout` — Color variants, highlight, collapsible

### Forms (6)
- `ItInput` — Animated label, icon, validation states, password toggle
- `ItSelect` — Single/multi, searchable, grouped
- `ItCheckbox` — Standard, indeterminate, group, inline
- `ItRadio` — Standard, group, inline
- `ItToggle` — On/off with label
- `ItAutocomplete` — Async suggestions, highlight match

### Overlays (3)
- `ItModal` — Sizes, scrollable, centered, with icon
- `ItDropdown` — With icons, headers/dividers, directional
- `ItNotification` — Dismissible, with icon, auto-dismiss, positioned

**Post-MVP** (Phase 2): Avatar, Stepper, Carousel, Timeline, Hero, Section, Dimmer, Rating, Pagination, Sidebar, BottomNav, Toolbar, Megamenu, Cookiebar, Tooltip, Popover, Upload, NumericInput, DatePicker, TimePicker, Transfer, VideoPlayer, Sticky, Affix, Skiplink, NavScroll, Forward, GoBack, ThumbNav, Overlay, Table

---

## Phase 0 — Project Setup

### 0.1 Flutter Package Scaffold
```
bootstrap_italia/
├── lib/
│   ├── bootstrap_italia.dart          # Main barrel export
│   ├── src/
│   │   ├── theme/                     # Theme system
│   │   ├── tokens/                    # Design tokens
│   │   ├── components/                # UI widgets by category
│   │   ├── form/                      # Form widgets
│   │   └── utilities/                 # Responsive helpers, extensions
├── fonts/                             # Bundled fonts
│   ├── TitilliumWeb-*.ttf
│   ├── Lora-*.ttf
│   └── RobotoMono-*.ttf
├── example/                           # Catalog/demo app
├── test/                              # Widget tests
├── pubspec.yaml
├── analysis_options.yaml
├── CHANGELOG.md
├── LICENSE                            # MIT
└── README.md
```

### 0.2 pubspec.yaml
```yaml
name: bootstrap_italia
description: Bootstrap Italia design system for Flutter — PA-compliant UI components for Italian government apps.
version: 0.1.0
homepage: https://github.com/<org>/bootstrap-italia-flutter
repository: https://github.com/<org>/bootstrap-italia-flutter
issue_tracker: https://github.com/<org>/bootstrap-italia-flutter/issues

environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter
  bootstrap_italia_icons: ^0.0.3
  bootstrap_icons: ^1.11.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  fonts:
    - family: TitilliumWeb
      fonts:
        - asset: fonts/TitilliumWeb-Light.ttf
          weight: 300
        - asset: fonts/TitilliumWeb-Regular.ttf
          weight: 400
        - asset: fonts/TitilliumWeb-SemiBold.ttf
          weight: 600
        - asset: fonts/TitilliumWeb-Bold.ttf
          weight: 700
        - asset: fonts/TitilliumWeb-LightItalic.ttf
          weight: 300
          style: italic
        - asset: fonts/TitilliumWeb-Italic.ttf
          weight: 400
          style: italic
        - asset: fonts/TitilliumWeb-SemiBoldItalic.ttf
          weight: 600
          style: italic
        - asset: fonts/TitilliumWeb-BoldItalic.ttf
          weight: 700
          style: italic
    - family: Lora
      fonts:
        - asset: fonts/Lora-Regular.ttf
          weight: 400
        - asset: fonts/Lora-Bold.ttf
          weight: 700
        - asset: fonts/Lora-Italic.ttf
          weight: 400
          style: italic
        - asset: fonts/Lora-BoldItalic.ttf
          weight: 700
          style: italic
    - family: RobotoMono
      fonts:
        - asset: fonts/RobotoMono-Regular.ttf
          weight: 400
        - asset: fonts/RobotoMono-Bold.ttf
          weight: 700
```

### 0.3 Linting
- `analysis_options.yaml` with strict rules
- `public_member_api_docs` enabled for all public APIs

### 0.4 CI/CD
- GitHub Actions: lint → test → build example
- Auto-publish to pub.dev on version tag

---

## Phase 1 — Design Tokens & Theme System

### 1.1 Color Tokens (`lib/src/tokens/colors.dart`)

```dart
/// All Bootstrap Italia design system colors.
abstract final class BootstrapItaliaColors {
  // ── Primary & Semantic ──
  static const Color primary      = Color(0xFF0066CC); // Blu Italia — hsl(210, 100%, 40%)
  static const Color secondary    = Color(0xFF5D7083); // hsl(210, 17%, 44%)
  static const Color success      = Color(0xFF008055); // hsl(160, 100%, 25%)
  static const Color info         = Color(0xFF5D7083); // hsl(210, 17%, 44%)
  static const Color warning      = Color(0xFF995C00); // hsl(36, 100%, 30%)
  static const Color danger       = Color(0xFFCC334D); // hsl(350, 60%, 50%)
  static const Color light        = Color(0xFFE9E6F2); // hsl(255, 32%, 93%)
  static const Color dark         = Color(0xFF17334F); // hsl(210, 54%, 20%)

  // ── Gray Scale ──
  static const Color gray100 = Color(0xFFF5F5F5); // hsl(0, 0%, 96%)
  static const Color gray200 = Color(0xFFE6E6E6); // hsl(0, 0%, 90%)
  static const Color gray300 = Color(0xFFD4D4D4); // hsl(0, 0%, 83%)
  static const Color gray400 = Color(0xFFA3A3A3); // hsl(0, 0%, 64%)
  static const Color gray500 = Color(0xFF737373); // hsl(0, 0%, 45%)
  static const Color gray600 = Color(0xFF525252); // hsl(0, 0%, 32%)
  static const Color gray700 = Color(0xFF404040); // hsl(0, 0%, 25%)
  static const Color gray800 = Color(0xFF262626); // hsl(0, 0%, 15%)
  static const Color gray900 = Color(0xFF1A1A1A); // hsl(0, 0%, 10%)

  // ── Accent ──
  static const Color indigo = Color(0xFF4D4DFF); // hsl(243, 100%, 65%)
  static const Color purple = Color(0xFF9999FF); // hsl(243, 100%, 80%)
  static const Color pink   = Color(0xFFFFB3BF); // hsl(350, 100%, 85%)
  static const Color orange = Color(0xFF995C00); // hsl(36, 100%, 30%)
  static const Color teal   = Color(0xFF08A3A0); // hsl(178, 90%, 32%)
  static const Color cyan   = Color(0xFF00FFFA); // hsl(178, 100%, 50%)

  // ── Italia-Specific ──
  static const Color analogue1      = Color(0xFF3126FF);
  static const Color analogue2      = Color(0xFF0BD9D2);
  static const Color complementary1 = Color(0xFFF73E5A);
  static const Color complementary2 = Color(0xFFFF9900);
  static const Color complementary3 = Color(0xFF00CF86);
  static const Color neutral1       = Color(0xFF17324D);
  static const Color neutral2       = Color(0xFFE6ECF2);
}
```

### 1.2 Typography Tokens (`lib/src/tokens/typography.dart`)

| Style | Mobile (< 576px) | Desktop (≥ 576px) | Weight |
|-------|-------------------|-------------------|--------|
| h1 | 40px / 48px lh | 48px / 60px lh | Bold (700) |
| h2 | 32px / 40px lh | 40px / 48px lh | Bold (700) |
| h3 | 28px / 32px lh | 32px / 40px lh | Bold (700) |
| h4 | 24px / 28px lh | 28px / 40px lh | SemiBold (600) |
| h5 | 20px / 24px lh | 24px / 40px lh | Regular (400) |
| h6 | 16px / 24px lh | 18px / 28px lh | SemiBold (600) |
| body | 16px / 24px lh | 18px / 28px lh | Regular (400) |

Font families:
- **TitilliumWeb** — Default sans-serif (all UI text)
- **Lora** — Serif (long-form reading)
- **RobotoMono** — Monospace (code, numbers)

```dart
class BootstrapItaliaTypography {
  final TextStyle h1, h2, h3, h4, h5, h6;
  final TextStyle bodyText, bodySmall, lead;
  final TextStyle display1;

  /// Mobile styles (< 576px)
  const BootstrapItaliaTypography.mobile();

  /// Desktop styles (≥ 576px)
  const BootstrapItaliaTypography.desktop();

  /// Auto-select based on screen width
  factory BootstrapItaliaTypography.responsive(double width);
}
```

### 1.3 Spacing Tokens (`lib/src/tokens/spacing.dart`)
```dart
abstract final class BootstrapItaliaSpacing {
  static const double space0 = 0;
  static const double space1 = 4;   // 0.25rem
  static const double space2 = 8;   // 0.5rem
  static const double space3 = 16;  // 1rem
  static const double space4 = 24;  // 1.5rem
  static const double space5 = 48;  // 3rem
}
```

### 1.4 Breakpoints (`lib/src/tokens/breakpoints.dart`)
```dart
enum ItBreakpoint {
  xs(0),    // < 576px
  sm(576),  // ≥ 576px
  md(768),  // ≥ 768px
  lg(992),  // ≥ 992px
  xl(1200), // ≥ 1200px
  xxl(1400); // ≥ 1400px

  final double minWidth;
  const ItBreakpoint(this.minWidth);
}

/// Container max-widths per breakpoint
abstract final class ItContainerWidths {
  static const double sm  = 540;
  static const double md  = 720;
  static const double lg  = 960;
  static const double xl  = 1176;
  static const double xxl = 1320;
}
```

### 1.5 Shadows & Borders (`lib/src/tokens/shadows.dart`, `borders.dart`)
```dart
abstract final class BootstrapItaliaShadows {
  static const BoxShadow sm = ...;
  static const BoxShadow md = ...;
  static const BoxShadow lg = ...;
}

abstract final class BootstrapItaliaBorders {
  static const double radiusSm = 2;
  static const double radius   = 4;
  static const double radiusLg = 8;
  static const double radiusPill = 50; // percentage-like
}
```

### 1.6 Theme System (`lib/src/theme/`)

```dart
/// Holds all Bootstrap Italia design tokens.
class BootstrapItaliaThemeData {
  final BootstrapItaliaColorScheme colors;
  final BootstrapItaliaTypography typography;

  /// Converts to Material ThemeData for compatibility.
  ThemeData toThemeData();

  /// Standard Bootstrap Italia theme.
  factory BootstrapItaliaThemeData.standard();
}

/// InheritedWidget to provide theme down the tree.
class BootstrapItaliaTheme extends InheritedWidget {
  final BootstrapItaliaThemeData data;

  static BootstrapItaliaThemeData of(BuildContext context);
}
```

**Usage:**
```dart
BootstrapItaliaTheme(
  data: BootstrapItaliaThemeData.standard(),
  child: MaterialApp(
    theme: BootstrapItaliaThemeData.standard().toThemeData(),
    home: MyApp(),
  ),
)
```

---

## Phase 2 — Responsive Utilities (No Grid)

### 2.1 `ItResponsiveBuilder`
```dart
/// Builds different layouts based on current breakpoint.
ItResponsiveBuilder(
  xs: (context) => MobileLayout(),
  sm: (context) => MobileLayout(),       // optional, falls back to xs
  md: (context) => TabletLayout(),
  lg: (context) => DesktopLayout(),
  xl: (context) => DesktopLayout(),      // optional, falls back to lg
  xxl: (context) => WideDesktopLayout(), // optional, falls back to xl
)
```

Uses `LayoutBuilder` internally, NOT `MediaQuery`.

### 2.2 `ItContainer`
```dart
/// Centered container with max-width matching Bootstrap Italia breakpoints.
ItContainer(
  child: content,
  // Max-widths: sm=540, md=720, lg=960, xl=1176, xxl=1320
  // Fluid below sm (no max-width)
)
```

### 2.3 Breakpoint Extensions
```dart
extension BootstrapItaliaContext on BuildContext {
  /// Current breakpoint based on screen width.
  ItBreakpoint get breakpoint;

  /// Quick checks
  bool get isMobile;  // xs, sm
  bool get isTablet;  // md
  bool get isDesktop; // lg, xl, xxl

  /// Access theme
  BootstrapItaliaThemeData get bootstrapItaliaTheme;
}
```

---

## Phase 3 — Core UI Components (MVP)

### 3.1 `ItButton`
```dart
ItButton(
  variant: ItButtonVariant.primary,  // primary|secondary|success|danger|warning|info|light|dark
  size: ItButtonSize.md,             // sm|md|lg
  outline: false,
  block: false,                      // full-width
  disabled: false,
  loading: false,                    // shows spinner
  icon: BootstrapItaliaIcons.check,  // leading icon
  trailingIcon: null,
  onPressed: () {},
  child: Text('Conferma'),
)
```

Also: `ItButtonGroup` for grouped buttons.

### 3.2 `ItBadge`
```dart
ItBadge(
  variant: ItBadgeVariant.primary,
  pill: false,       // rounded-pill shape
  child: Text('42'),
)

// Positioned notification badge
ItNotificationBadge(
  count: 3,
  child: ItIcon(BootstrapItaliaIcons.bell),
)
```

### 3.3 `ItAlert`
```dart
ItAlert(
  variant: ItAlertVariant.success,
  icon: BootstrapItaliaIcons.checkCircle,
  dismissible: true,
  onDismissed: () {},
  title: 'Operazione completata',
  child: Text('Il documento è stato salvato.'),
)
```

### 3.4 `ItSpinner`
```dart
ItSpinner(
  variant: ItSpinnerVariant.primary,
  size: ItSpinnerSize.md,  // sm|md
  active: true,            // double-ring active variant
)
```

### 3.5 `ItIcon`
```dart
/// Wrapper with Bootstrap Italia sizing and color defaults.
ItIcon(
  BootstrapItaliaIcons.document, // tries bootstrap_italia_icons first, falls back to bootstrap_icons
  size: ItIconSize.md,           // xs=16, sm=24, md=32, lg=48, xl=64
  color: null,                   // defaults to theme
)
```

### 3.6 `ItChip`
```dart
ItChip(
  label: 'Flutter',
  icon: BootstrapItaliaIcons.tag,
  dismissible: true,
  onDismissed: () {},
  large: false,
  disabled: false,
  selected: false,
)
```

---

## Phase 4 — Navigation Components (MVP)

### 4.1 `ItHeader` (Composed)
```dart
ItHeader(
  slimHeader: ItSlimHeader(
    institutionName: 'Repubblica Italiana',
    // ... links, language switcher
  ),
  centerHeader: ItCenterHeader(
    logo: Image.asset('assets/logo.png'),
    title: 'Nome del Comune',
    subtitle: 'Comune di ...',
    // ... social links, search
  ),
  navHeader: ItNavHeader(
    items: [
      ItNavItem(label: 'Amministrazione', href: '/amm'),
      ItNavItem(label: 'Servizi', href: '/servizi'),
      // ...
    ],
  ),
)
```

Each sub-component (`ItSlimHeader`, `ItCenterHeader`, `ItNavHeader`) usable independently.

Mobile behavior: hamburger menu triggers offcanvas/drawer.

### 4.2 `ItFooter`
```dart
ItFooter(
  logo: Image.asset('assets/logo.png'),
  institutionName: 'Comune di ...',
  sections: [...],       // ItFooterSection with links
  socialLinks: [...],    // ItSocialLink
  legalInfo: [...],      // Bottom bar text/links
)
```

### 4.3 `ItBreadcrumb`
```dart
ItBreadcrumb(
  items: [
    ItBreadcrumbItem(label: 'Home', href: '/'),
    ItBreadcrumbItem(label: 'Servizi', href: '/servizi'),
    ItBreadcrumbItem(label: 'Anagrafe'),  // current (no href)
  ],
  icon: BootstrapItaliaIcons.house,  // optional leading icon
  dark: false,
)
```

### 4.4 `ItBackToTop`
```dart
ItBackToTop(
  scrollController: _scrollController,
  showAfter: 200,  // pixels
)
```

---

## Phase 5 — Content Components (MVP)

### 5.1 `ItCard`
```dart
ItCard(
  image: ItCardImage(src: 'https://...', alt: '...'),
  category: ItCardCategory(label: 'Categoria', icon: ...),
  title: 'Titolo della card',
  subtitle: 'Sottotitolo',
  body: Text('Descrizione...'),
  signature: 'di Mario Rossi',
  footer: ItCardFooter(child: ...),
  borderTopColor: BootstrapItaliaColors.primary,
  horizontal: false,
  onTap: () {},
)
```

### 5.2 `ItAccordion`
```dart
ItAccordion(
  allowMultipleOpen: false,
  items: [
    ItAccordionItem(
      title: 'Sezione 1',
      icon: BootstrapItaliaIcons.folder,
      child: Text('Contenuto...'),
    ),
    // ...
  ],
)
```

### 5.3 `ItCollapse`
```dart
ItCollapse(
  isExpanded: _expanded,
  duration: Duration(milliseconds: 300),
  child: Text('Contenuto nascosto'),
)
```

### 5.4 `ItTab`
```dart
ItTabBar(
  tabs: [
    ItTabItem(label: 'Tab 1', icon: ...),
    ItTabItem(label: 'Tab 2', icon: ...),
  ],
  selectedIndex: 0,
  onChanged: (index) {},
  style: ItTabStyle.underline, // underline|card|button
)

ItTabView(
  selectedIndex: 0,
  children: [Page1(), Page2()],
)
```

### 5.5 `ItList`
```dart
ItList(
  items: [
    ItListItem(
      title: 'Elemento',
      subtitle: 'Descrizione',
      leading: ItAvatar(initials: 'MR'),
      trailing: ItIcon(BootstrapItaliaIcons.chevronRight),
      onTap: () {},
    ),
    // ...
  ],
)
```

### 5.6 `ItCallout`
```dart
ItCallout(
  variant: ItCalloutVariant.success,
  title: 'Nota bene',
  collapsible: false,
  child: Text('Testo della callout...'),
)
```

---

## Phase 6 — Form Components (MVP)

### 6.1 `ItInput`
```dart
ItInput(
  label: 'Nome completo',           // animated floating label
  hint: 'Inserisci il tuo nome',
  icon: BootstrapItaliaIcons.person,
  helperText: 'Come da documento',
  errorText: null,                   // shows danger state
  obscureText: false,                // for password
  showPasswordToggle: false,
  controller: _controller,
  onChanged: (value) {},
  enabled: true,
  readOnly: false,
  validationState: null,             // success|warning|danger
)
```
Internally wraps Flutter's `TextField` with custom `InputDecoration`.

### 6.2 `ItSelect`
```dart
ItSelect<String>(
  label: 'Provincia',
  items: [
    ItSelectItem(value: 'RM', label: 'Roma'),
    ItSelectItem(value: 'MI', label: 'Milano'),
    // ...
  ],
  value: 'RM',
  onChanged: (value) {},
  searchable: true,
  multiple: false,
)
```

### 6.3 `ItCheckbox`
```dart
ItCheckbox(
  value: true,
  tristate: false,  // enables indeterminate
  label: 'Accetto i termini',
  onChanged: (value) {},
)

ItCheckboxGroup(
  label: 'Seleziona opzioni',
  options: [...],
  values: {...},
  onChanged: (values) {},
  inline: false,
)
```

### 6.4 `ItRadio`
```dart
ItRadioGroup<String>(
  label: 'Genere',
  options: [
    ItRadioOption(value: 'M', label: 'Maschio'),
    ItRadioOption(value: 'F', label: 'Femmina'),
  ],
  value: 'M',
  onChanged: (value) {},
  inline: false,
)
```

### 6.5 `ItToggle`
```dart
ItToggle(
  value: true,
  label: 'Notifiche email',
  onChanged: (value) {},
  disabled: false,
)
```

### 6.6 `ItAutocomplete`
```dart
ItAutocomplete<City>(
  label: 'Città',
  onSearch: (query) async => api.searchCities(query),
  itemBuilder: (city) => Text(city.name),
  onSelected: (city) {},
  debounce: Duration(milliseconds: 300),
  highlightMatch: true,
)
```

---

## Phase 7 — Overlay Components (MVP)

### 7.1 `ItModal`
```dart
ItModal.show(
  context: context,
  size: ItModalSize.md,  // sm|md|lg|xl
  title: 'Conferma operazione',
  icon: BootstrapItaliaIcons.warningCircle,
  scrollable: false,
  centered: true,
  body: Text('Sei sicuro?'),
  actions: [
    ItButton(variant: ItButtonVariant.secondary, child: Text('Annulla'), onPressed: () => Navigator.pop(context)),
    ItButton(variant: ItButtonVariant.primary, child: Text('Conferma'), onPressed: () {}),
  ],
)
```

### 7.2 `ItDropdown`
```dart
ItDropdown(
  trigger: ItButton(child: Text('Azioni')),
  direction: ItDropdownDirection.down,
  items: [
    ItDropdownHeader(label: 'Sezione'),
    ItDropdownItem(label: 'Modifica', icon: BootstrapItaliaIcons.pencil, onTap: () {}),
    ItDropdownDivider(),
    ItDropdownItem(label: 'Elimina', icon: BootstrapItaliaIcons.trash, onTap: () {}, danger: true),
  ],
)
```

### 7.3 `ItNotification`
```dart
ItNotification.show(
  context: context,
  variant: ItNotificationVariant.success,
  title: 'Salvato',
  message: 'Il documento è stato salvato.',
  icon: BootstrapItaliaIcons.checkCircle,
  dismissible: true,
  duration: Duration(seconds: 5),
  position: ItNotificationPosition.topRight,
)
```

---

## Phase 8 — Example / Catalog App

### Structure
```
example/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── routes.dart
│   ├── pages/
│   │   ├── home_page.dart
│   │   ├── theme/
│   │   │   ├── colors_page.dart
│   │   │   ├── typography_page.dart
│   │   │   └── spacing_page.dart
│   │   ├── components/
│   │   │   ├── button_page.dart
│   │   │   ├── badge_page.dart
│   │   │   ├── alert_page.dart
│   │   │   ├── card_page.dart
│   │   │   ├── ... (one page per component)
│   │   ├── form/
│   │   │   ├── input_page.dart
│   │   │   ├── select_page.dart
│   │   │   └── ...
│   │   └── navigation/
│   │       ├── header_page.dart
│   │       └── ...
│   └── widgets/
│       ├── component_page.dart      # Reusable page template
│       └── code_preview.dart        # Code + live preview
```

Each component page shows:
1. Live interactive examples (all variants)
2. Source code snippets
3. API reference summary

Works on all platforms (mobile, tablet, desktop, web).

---

## Phase 9 — Testing & Quality

### Widget Tests
- Every MVP component has at least one test
- Test: rendering, user interactions, variant switching, state changes
- Test: theme application, responsive behavior
- Golden tests for key components (optional)

### Accessibility
- All interactive widgets have `Semantics`
- Keyboard navigation works
- Focus management correct
- Color contrast meets WCAG AA

### pub.dev Readiness
- Score 130+ (max 160)
- `dart analyze` clean
- `dart doc` generates correctly
- All public APIs documented
- Example app demonstrates usage
- Screenshots in pub.dev listing

---

## Implementation Order (Sprints)

| Sprint | What | Deliverable |
|--------|------|-------------|
| **1** | Phase 0 + 1 | Package scaffold + design tokens + theme system |
| **2** | Phase 2 | Responsive utilities (ItResponsiveBuilder, ItContainer, extensions) |
| **3** | Phase 3 | Button, Badge, Alert, Spinner, Icon, Chip |
| **4** | Phase 5 | Card, Accordion, Collapse, Tab, List, Callout |
| **5** | Phase 6 | Input, Select, Checkbox, Radio, Toggle, Autocomplete |
| **6** | Phase 4 | Header (Slim+Center+Nav), Footer, Breadcrumb, BackToTop |
| **7** | Phase 7 | Modal, Dropdown, Notification |
| **8** | Phase 8 | Example/Catalog app |
| **9** | Phase 9 | Tests, docs, pub.dev prep, first publish |

---

## Naming Conventions

| Concept | Convention | Example |
|---------|-----------|---------|
| Widget class | `It` prefix + PascalCase | `ItButton`, `ItCard` |
| Theme class | `BootstrapItalia` prefix | `BootstrapItaliaThemeData` |
| Color constants | camelCase | `BootstrapItaliaColors.primary` |
| File names | snake_case | `it_button.dart` |
| Enum values | camelCase | `ItButtonVariant.primary` |
| Private classes | underscore prefix | `_ItButtonState` |

---

## Key Technical Decisions

### 1. Composability over Monoliths
Complex components decompose into independent sub-widgets:
```dart
// Full header
ItHeader(slimHeader: ..., centerHeader: ..., navHeader: ...)
// Or use parts independently
ItSlimHeader(...)
```

### 2. Variant Pattern via Enums
```dart
enum ItButtonVariant { primary, secondary, success, danger, warning, info, light, dark }
enum ItButtonSize { sm, md, lg }
```

### 3. Theme Defaults + Per-Instance Overrides
Components read defaults from theme but accept overrides:
```dart
ItButton(variant: ItButtonVariant.primary)  // from theme
ItButton(backgroundColor: Colors.red)       // override
```

### 4. Accessibility First
Every interactive widget:
- Has `Semantics` labels
- Supports keyboard navigation
- Manages focus correctly
- Meets WCAG AA contrast

### 5. Zero Unnecessary Dependencies
Only: Flutter SDK + `bootstrap_italia_icons` + `bootstrap_icons`.
No state management, no HTTP, no platform plugins.

---

## File Organization (Complete MVP)

```
lib/
├── bootstrap_italia.dart
├── src/
│   ├── tokens/
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   ├── spacing.dart
│   │   ├── breakpoints.dart
│   │   ├── shadows.dart
│   │   └── borders.dart
│   ├── theme/
│   │   ├── bootstrap_italia_theme.dart
│   │   ├── bootstrap_italia_theme_data.dart
│   │   └── theme_extensions.dart
│   ├── utilities/
│   │   ├── responsive_builder.dart
│   │   ├── container.dart
│   │   └── extensions.dart
│   ├── components/
│   │   ├── button/
│   │   │   ├── it_button.dart
│   │   │   └── it_button_group.dart
│   │   ├── badge/
│   │   │   └── it_badge.dart
│   │   ├── alert/
│   │   │   └── it_alert.dart
│   │   ├── spinner/
│   │   │   └── it_spinner.dart
│   │   ├── icon/
│   │   │   └── it_icon.dart
│   │   ├── chip/
│   │   │   └── it_chip.dart
│   │   ├── card/
│   │   │   ├── it_card.dart
│   │   │   ├── it_card_body.dart
│   │   │   ├── it_card_header.dart
│   │   │   ├── it_card_image.dart
│   │   │   ├── it_card_category.dart
│   │   │   └── it_card_signature.dart
│   │   ├── accordion/
│   │   │   └── it_accordion.dart
│   │   ├── collapse/
│   │   │   └── it_collapse.dart
│   │   ├── tab/
│   │   │   ├── it_tab_bar.dart
│   │   │   └── it_tab_view.dart
│   │   ├── list/
│   │   │   └── it_list.dart
│   │   ├── callout/
│   │   │   └── it_callout.dart
│   │   ├── header/
│   │   │   ├── it_header.dart
│   │   │   ├── it_slim_header.dart
│   │   │   ├── it_center_header.dart
│   │   │   └── it_nav_header.dart
│   │   ├── footer/
│   │   │   └── it_footer.dart
│   │   ├── breadcrumb/
│   │   │   └── it_breadcrumb.dart
│   │   ├── back_to_top/
│   │   │   └── it_back_to_top.dart
│   │   ├── modal/
│   │   │   └── it_modal.dart
│   │   ├── dropdown/
│   │   │   └── it_dropdown.dart
│   │   └── notification/
│   │       └── it_notification.dart
│   └── form/
│       ├── it_input.dart
│       ├── it_select.dart
│       ├── it_checkbox.dart
│       ├── it_radio.dart
│       ├── it_toggle.dart
│       └── it_autocomplete.dart
```

**Total MVP files:** ~45 source files + tests + example app
