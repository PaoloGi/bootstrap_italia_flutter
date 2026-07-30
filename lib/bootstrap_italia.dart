/// Bootstrap Italia design system for Flutter.
///
/// Provides PA-compliant UI components, design tokens, and theming for
/// Italian government applications built with Flutter.
///
/// ## Getting started
///
/// Wrap your app with [BootstrapItaliaTheme] and apply the Material theme:
///
/// ```dart
/// import 'package:bootstrap_italia/bootstrap_italia.dart';
///
/// void main() {
///   final theme = BootstrapItaliaThemeData.standard();
///   runApp(
///     BootstrapItaliaTheme(
///       data: theme,
///       child: MaterialApp(
///         theme: theme.toThemeData(),
///         home: MyApp(),
///       ),
///     ),
///   );
/// }
/// ```
library;

// ── Design Tokens ────────────────────────────────────────────────
export 'src/tokens/borders.dart';
export 'src/tokens/breakpoints.dart';
export 'src/tokens/colors.dart';
export 'src/tokens/shadows.dart';
export 'src/tokens/spacing.dart';
export 'src/tokens/typography.dart';

// ── Theme System ─────────────────────────────────────────────────
export 'src/theme/bootstrap_italia_theme.dart';
export 'src/theme/bootstrap_italia_theme_data.dart';
export 'src/theme/theme_extensions.dart';

// ── Utilities ────────────────────────────────────────────────────
export 'src/utilities/container.dart';
export 'src/utilities/responsive_builder.dart';

// ── Components ───────────────────────────────────────────────────
export 'src/components/alert/it_alert.dart';
export 'src/components/badge/it_badge.dart';
export 'src/components/button/it_button.dart';
export 'src/components/chip/it_chip.dart';
export 'src/components/icon/it_icon.dart';
export 'src/components/spinner/it_spinner.dart';
export 'src/components/collapse/it_collapse.dart';
export 'src/components/accordion/it_accordion.dart';
export 'src/components/card/it_card.dart';
export 'src/components/tab/it_tab_bar.dart';
export 'src/components/tab/it_tab_view.dart';
export 'src/components/list/it_list.dart';
export 'src/components/callout/it_callout.dart';

// ── Overlays ────────────────────────────────────────────────────
export 'src/components/dropdown/it_dropdown.dart';
export 'src/components/modal/it_modal.dart';
export 'src/components/notification/it_notification.dart';

// ── Navigation ───────────────────────────────────────────────────
export 'src/components/back_to_top/it_back_to_top.dart';
export 'src/components/breadcrumb/it_breadcrumb.dart';
export 'src/components/footer/it_footer.dart';
export 'src/components/header/it_center_header.dart';
export 'src/components/header/it_header.dart';
export 'src/components/header/it_nav_header.dart';
export 'src/components/header/it_slim_header.dart';
export 'src/components/megamenu/it_megamenu.dart';

// ── Form ─────────────────────────────────────────────────────────
export 'src/form/it_autocomplete.dart';
export 'src/form/it_checkbox.dart';
export 'src/form/it_input.dart';
export 'src/form/it_radio.dart';
export 'src/form/it_select.dart';
export 'src/form/it_toggle.dart';
