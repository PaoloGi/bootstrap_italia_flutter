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
/// import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
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
// ── Accessibility primitives ─────────────────────────────────────
//
// Exported deliberately. An application building a control this package does not
// ship still has to make it keyboard operable and give it the same focus
// indicator, or the result is an app that is inconsistent with the design system
// and inaccessible in a way its own audit will not explain. Handing over the
// primitives is the difference between a design system and a widget dump.
export 'src/a11y/it_activatable.dart';
export 'src/a11y/it_focus_ring.dart';
export 'src/a11y/it_icon_action.dart';
// An overlay/dialog built by an application sits outside this package's widgets
// and therefore outside any ambient text style. Without this it inherits
// DefaultTextStyle.fallback(), which has NO font family — the text renders in
// the wrong face, or as missing-glyph boxes. Exported so applications can avoid
// the trap this package itself fell into.
export 'src/theme/it_default_text_style.dart';
export 'src/components/spinner/progress_spinner.dart';
export 'src/utilities/interaction_states.dart';

// ── Localisation ─────────────────────────────────────────────────
//
// The strings this package speaks on an application's behalf — nearly all of
// them accessible names, and so a conformance surface rather than a cosmetic
// one. Optional: with no delegate installed every component renders in Italian.

export 'src/l10n/it_localizations.dart';

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
export 'src/components/offcanvas/it_offcanvas.dart';
export 'src/components/sidebar/it_sidebar.dart';
export 'src/components/spinner/it_spinner.dart';
export 'src/components/collapse/it_collapse.dart';
export 'src/components/accordion/it_accordion.dart';
export 'src/components/card/it_card.dart';
export 'src/components/tab/it_tab_bar.dart';
export 'src/components/tab/it_tab_view.dart';
export 'src/components/list/it_content_list.dart';
export 'src/components/list/it_list.dart';
export 'src/components/callout/it_callout.dart';
export 'src/components/carousel/it_carousel.dart';

// ── Overlays ────────────────────────────────────────────────────
export 'src/components/divider/it_divider.dart';
export 'src/components/dropdown/it_dropdown.dart';
export 'src/components/modal/it_modal.dart';
export 'src/components/notification/it_notification.dart';

// ── Navigation ───────────────────────────────────────────────────
export 'src/components/back_to_top/it_back_to_top.dart';
export 'src/components/bottom_nav/it_bottom_nav.dart';
export 'src/components/breadcrumb/it_breadcrumb.dart';
export 'src/components/footer/it_footer.dart';
export 'src/components/header/header_glyphs.dart';
export 'src/components/header/it_center_header.dart';
export 'src/components/header/it_header.dart';
export 'src/components/header/it_nav_header.dart';
export 'src/components/header/it_slim_header.dart';
export 'src/components/megamenu/it_megamenu.dart';
export 'src/components/skiplinks/it_skiplinks.dart';
// Shared by ItCenterHeader and ItFooter, and owned by neither.
export 'src/components/social_link/it_social_link.dart';

// ── Form ─────────────────────────────────────────────────────────
export 'src/form/it_autocomplete.dart';
export 'src/form/it_checkbox.dart';
export 'src/form/it_date_field.dart';
// The validation/helper surface every form control shares. Exported for the
// same reason as the a11y primitives: an application building a control this
// package does not ship still has to render `.form-text` and `.form-feedback`
// the way the kit does, or its own fields look like a different design system.
export 'src/form/it_field_support.dart';
export 'src/form/it_input.dart';
export 'src/form/it_form_spacing.dart';
export 'src/form/it_radio.dart';
export 'src/form/it_select.dart';
export 'src/form/it_toggle.dart';
