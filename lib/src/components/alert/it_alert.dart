import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/widgets.dart';
import '../../l10n/it_localizations.dart';
import '../../a11y/it_activatable.dart';
import '../../tokens/borders.dart';

import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../utilities/interaction_states.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Color variants for [ItAlert].
enum ItAlertVariant {
  /// Primary blue alert.
  primary,

  /// Secondary gray alert.
  ///
  /// Has no counterpart in the design system: the compiled stylesheet contains
  /// no `.alert-secondary` rule, and «Esempi» lists five variants — primary,
  /// info, success, warning, danger. It survives here because removing a public
  /// enum value breaks callers, and because it is harmless: `--bs-secondary` and
  /// `--bs-info` are the same `hsl(210, 17%, 44%)`, so a secondary alert is a
  /// pixel-for-pixel info alert without the icon. Prefer [info].
  secondary,

  /// Green success alert.
  success,

  /// Danger red alert.
  danger,

  /// Warning orange alert.
  warning,

  /// Info alert.
  info,
}

/// Maps [ItAlertVariant] onto the shared semantic colour roles.
///
/// Exhaustive by construction — Dart requires every value to be handled, so
/// adding a variant here without giving it a colour will not compile. The
/// string-keyed lookup this replaced silently rendered such a variant as
/// primary.
extension ItAlertVariantColor on ItAlertVariant {
  /// The semantic colour role this variant paints with.
  ItVariantColor get variantColor => switch (this) {
        ItAlertVariant.primary => ItVariantColor.primary,
        ItAlertVariant.secondary => ItVariantColor.secondary,
        ItAlertVariant.success => ItVariantColor.success,
        ItAlertVariant.danger => ItVariantColor.danger,
        ItAlertVariant.warning => ItVariantColor.warning,
        ItAlertVariant.info => ItVariantColor.info,
      };

  /// The glyph the stylesheet paints for this variant.
  ///
  /// Bootstrap Italia does not treat the alert icon as optional. `.alert`
  /// reserves the space for it unconditionally —
  ///
  /// ```css
  /// .alert { padding-left: 4em;
  ///          background-position: 20px 12px;
  ///          background-size: 32px 32px;
  ///          background-repeat: no-repeat }
  /// ```
  ///
  /// — and each variant supplies the image:
  /// `.alert-primary`, `.alert-info`, `.alert-success`, `.alert-warning` and
  /// `.alert-danger` each carry a `background-image: url("data:image/svg+xml,…")`
  /// inline SVG, tinted with the same colour as their 8px left border.
  ///
  /// The names below were recovered by matching those inline `<path d>` values
  /// against `bootstrap-italia/svg/sprites.svg`, symbol by symbol — the kit
  /// inlines its SVGs rather than referencing the sprite, so there is no id to
  /// read. All four matched exactly, and two of them contradict the obvious
  /// guess: *warning* is `it-warning-circle` (an exclamation in a circle), not
  /// the `it-help-circle` the callout uses for the same word, and *danger* is
  /// `it-error` (an exclamation in an **octagon**), not a circle at all.
  ///
  /// `secondary` returns null because it has no counterpart: the compiled
  /// stylesheet declares no `.alert-secondary` at all, and the docs list five
  /// variants, not six. See the note on [ItAlertVariant.secondary].
  IconData? get defaultIcon => switch (this) {
        ItAlertVariant.primary ||
        ItAlertVariant.info =>
          BootstrapItaliaIcons.it_info_circle,
        ItAlertVariant.success => BootstrapItaliaIcons.it_check_circle,
        ItAlertVariant.warning => BootstrapItaliaIcons.it_warning_circle,
        ItAlertVariant.danger => BootstrapItaliaIcons.it_error,
        ItAlertVariant.secondary => null,
      };
}

/// A Bootstrap Italia alert component.
///
/// Displays feedback messages with color-coded variants, optional icon,
/// title, and dismiss functionality.
///
/// ```dart
/// ItAlert(
///   variant: ItAlertVariant.success,
///   icon: BootstrapItaliaIcons.it_check_circle,
///   title: 'Operazione completata',
///   body: Text('Il documento è stato salvato con successo.'),
/// )
/// ```
class ItAlert extends StatefulWidget {
  /// The alert color variant.
  final ItAlertVariant variant;

  /// Overrides the glyph the variant would paint.
  ///
  /// Leave null and the alert draws [ItAlertVariantColor.defaultIcon], which is
  /// what the stylesheet does. Set this only to say something the variant does
  /// not — and note that the icon is decoration either way: it is excluded from
  /// the semantics tree, because the colour and the glyph both restate what the
  /// text already says, and the docs make the same point under «Trasmettere
  /// significato alle tecnologie assistive».
  ///
  /// Ignored when [showIcon] is false.
  final IconData? icon;

  /// Whether the variant's glyph is painted.
  ///
  /// True by default, because `.alert` reserves `padding-left: 4em` for the
  /// glyph whether or not one is drawn — an alert without it is a box with 64px
  /// of empty gutter, which is what this widget used to render for every caller
  /// who did not pass `icon:`.
  ///
  /// Setting it false keeps the gutter, matching the stylesheet: nothing in
  /// `.alert` narrows the padding when the image is absent, so a `secondary`
  /// alert (which has no glyph at all) indents exactly like the others.
  final bool showIcon;

  /// Optional title text.
  final String? title;

  /// Whether the alert can be dismissed.
  final bool dismissible;

  /// Called when the user asks a *controlled* alert to close — a request.
  ///
  /// Only reachable when [visible] is non-null, because that is the mode in
  /// which the alert will not hide itself. Honour it by rebuilding with
  /// `visible: false`; ignore it and the close button does nothing.
  ///
  /// These two callbacks used to be one, whose meaning flipped depending on
  /// whether [visible] was set — a request in one mode and a notification in
  /// the other, under a single name. Splitting them follows Bootstrap's own
  /// event pairs, where the present tense fires before the fact and the past
  /// participle after it (`hide.bs.modal` / `hidden.bs.navbarcollapsible` are
  /// both in the bundled `bootstrap-italia.min.js`). The same tense rule names
  /// [ItChip.onDismiss] and [ItNotification.onDismissed].
  final VoidCallback? onDismiss;

  /// Called after an *uncontrolled* alert has faded out and removed itself — a
  /// notification.
  ///
  /// Only reachable when [visible] is null. The alert is already gone when this
  /// runs, so there is nothing to honour; it is there to let you release
  /// whatever the alert was reporting on. See [onDismiss] for the naming rule.
  final VoidCallback? onDismissed;

  /// Whether the alert is shown, when the parent wants to own that.
  ///
  /// Leave null (the default) and the alert manages its own visibility: the
  /// close button hides it and [onDismissed] fires afterwards. That is
  /// convenient, and it is a trap for anything that needs to come back —
  /// `_visible` was a one-way latch, so a parent rebuilding this alert with new
  /// content got `SizedBox.shrink()` forever. There is no reliable way to
  /// detect "new content" either, since widgets are fresh instances on every
  /// rebuild.
  ///
  /// Pass a value and the alert becomes controlled: it renders exactly what you
  /// say, [onDismiss] replaces [onDismissed] as the callback that fires, and
  /// re-showing is just passing true again. This matches design-react-kit,
  /// whose `Alert` takes `isOpen`.
  final bool? visible;

  /// Accessible name for the dismiss control.
  ///
  /// An icon-only button with no name is announced as just "button", which
  /// tells a screen-reader user nothing (WCAG 4.1.2). Defaults to
  /// `'Chiudi'`. Set it
  /// Override it to say something more specific, e.g. `'Chiudi l'avviso di
  /// manutenzione'`, or for a non-Italian UI — there is no localisation layer,
  /// so every non-Italian string has to be passed per call site.
  final String? dismissLabel;

  /// The alert content, rendered beneath [title].
  final Widget body;

  /// Creates a Bootstrap Italia alert.
  const ItAlert({
    super.key,
    this.variant = ItAlertVariant.info,
    this.icon,
    this.showIcon = true,
    this.title,
    this.dismissible = false,
    this.onDismiss,
    this.onDismissed,
    this.visible,
    this.dismissLabel,
    required this.body,
  }) : assert(
          visible == null ? onDismiss == null : onDismissed == null,
          'ItAlert: exactly one of these can fire, and `visible` picks which. '
          'Uncontrolled (visible: null) uses onDismissed, after the alert has '
          'gone. Controlled uses onDismiss, to ask you to hide it. Passing the '
          'other one is a silent no-op.',
        );

  @override
  State<ItAlert> createState() => _ItAlertState();
}

/// Width of the coloured variant border on the left edge (`border-left: 8px`).
const double _accentBorderWidth = 8;

/// Left inset for alert content: `.alert` overrides its 1rem padding with
/// `padding-left: 4em` (64px) to leave room for the variant icon.
const double _contentInset = 64;

class _ItAlertState extends State<ItAlert> with SingleTickerProviderStateMixin {
  bool _visible = true;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// True when the parent has not taken over visibility.
  bool get _uncontrolled => widget.visible == null;

  @override
  void didUpdateWidget(ItAlert oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A controlled alert re-shown by its parent must fade back in; without this
    // the controller stays at 0 from the dismissal and the alert occupies its
    // box invisibly.
    if (!_uncontrolled && widget.visible! && _controller.value == 0) {
      _controller.value = 1;
    }
  }

  void _dismiss() {
    if (!_uncontrolled) {
      // Controlled: the parent decides. Announce the request and leave the
      // rendering alone, or the two sources of truth disagree for one frame.
      widget.onDismiss?.call();
      return;
    }
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _visible = false);
        widget.onDismissed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!(widget.visible ?? _visible)) return const SizedBox.shrink();

    final colors = resolveColorScheme(context);
    // Bootstrap Italia alerts are NOT Bootstrap 5's tinted panels. Per
    // bootstrap-italia.min.css, `.alert` is a white box with a 1px neutral
    // border, square corners and body-coloured text; the variant shows up only
    // as an 8px coloured left border (`.alert-primary { border-left: 8px ... }`)
    // plus a matching icon.
    final accentColor = colors.forVariant(widget.variant.variantColor);
    // An explicit `icon:` overrides the variant's own glyph; `showIcon: false`
    // suppresses both.
    final glyph =
        widget.showIcon ? (widget.icon ?? widget.variant.defaultIcon) : null;
    const bgColor = Color(0xFFFFFFFF);
    final fgColor = colors.bodyColor;
    final borderColor = colors.secondary;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Semantics(
        liveRegion: true,
        // `explicitChildNodes`, or the alert becomes ONE node. A `Semantics`
        // that sets neither `container` nor this merges its annotations into
        // the nearest enclosing node, so the dismiss button's `button: true`
        // and its name folded into this live region: a screen reader announced
        // the whole alert as a single focusable button called "Domanda non
        // inviata. Chiudi", and there was no separate control to reach.
        //
        // Found by reading doc/at-announcements.md, not by a failing test —
        // the existing contract matched the dismiss label as a substring, which
        // the merged label still satisfies.
        explicitChildNodes: true,
        child: Container(
          width: double.infinity,
          // .alert: padding 1rem, overridden to padding-left 4em (64px) to
          // clear the icon that CSS paints at background-position 20px 12px.
          padding: const EdgeInsets.fromLTRB(
            _contentInset,
            BootstrapItaliaSpacing.space3,
            BootstrapItaliaSpacing.space3,
            BootstrapItaliaSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              top: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
              bottom: BorderSide(color: borderColor),
              left: BorderSide(color: accentColor, width: _accentBorderWidth),
            ),
            // .alert sets border-radius: 0
          ),
          child: Stack(
            // The icon is positioned at negative offsets so it lands in the
            // box's left padding; the default Clip.hardEdge would erase it.
            clipBehavior: Clip.none,
            children: [
              if (glyph != null)
                Positioned(
                  // background-position: 20px 12px, measured from the padding
                  // box; the Stack is already inset by the box padding.
                  left: 20 - _contentInset,
                  top: 12 - BootstrapItaliaSpacing.space3,
                  // `background-size: 32px 32px`. Decorative: the alert's
                  // meaning is in its text, and `liveRegion` above already makes
                  // that text announce itself.
                  child: ExcludeSemantics(
                    child: Icon(glyph, color: accentColor, size: 32),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.title != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: BootstrapItaliaSpacing.space1),
                            child: Text(
                              widget.title!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                fontFamily: BootstrapItaliaFontFamily.sansSerif,
                                package: BootstrapItaliaFontFamily.package,
                              ).copyWith(color: fgColor),
                            ),
                          ),
                        // .merge, not the default constructor: a plain
                        // DefaultTextStyle REPLACES the ambient style, which
                        // drops the theme's font family and renders every
                        // glyph as a missing-character box.
                        DefaultTextStyle.merge(
                          // line-height 1.5 is Bootstrap Italia's body default
                          // and makes the alert exactly 58px tall as in CSS.
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            // Named explicitly: with no ambient Material,
                            // DefaultTextStyle.fallback() applies and carries NO
                            // font family, so .merge has nothing to inherit.
                            fontFamily: BootstrapItaliaFontFamily.sansSerif,
                            package: BootstrapItaliaFontFamily.package,
                          ).copyWith(color: fgColor),
                          child: widget.body,
                        ),
                      ],
                    ),
                  ),
                  if (widget.dismissible)
                    // Was a bare GestureDetector around an Icon: no role, no
                    // name, and unreachable by keyboard. A screen-reader user
                    // was told nothing and a keyboard user could not dismiss the
                    // alert at all (WCAG 4.1.2, 2.1.1).
                    Semantics(
                      button: true,
                      label: widget.dismissLabel ??
                          ItLocalizations.of(context).close,
                      child: ItActivatable(
                        onPressed: _dismiss,
                        borderRadius: BorderRadius.circular(
                          BootstrapItaliaBorders.radius,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(
                              left: BootstrapItaliaSpacing.space2),
                          child: ExcludeSemantics(
                            // The glyph is decorative; the name is on the
                            // Semantics above, so announcing it twice would just
                            // be noise.
                            child:
                                Icon(BootstrapItaliaIcons.it_close, size: 20),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A link inside an [ItAlert] — `.alert-link`.
///
/// ```css
/// .alert-link { color: #06c; font-weight: 600; text-decoration: underline }
/// ```
///
/// «Link evidenziato» exists because an ordinary link loses against the alert's
/// own emphasis: the 600 weight and the underline are what pull it back out.
///
/// ## Why a widget and not a [TextStyle]
///
/// The docs put the link *inside* the sentence, so the obvious Flutter shape is
/// a [TextSpan] with a `TapGestureRecognizer`. That renders correctly and is
/// inaccessible: a recogniser on a span is reachable by pointer only — no focus
/// node, no Enter/Space, and nothing announced as a link (WCAG §2.1.1 Keyboard,
/// §4.1.2 Name, Role, Value). Flutter has no inline focusable text.
///
/// So this is a real control, placed in the sentence with a [WidgetSpan]:
///
/// ```dart
/// Text.rich(TextSpan(children: [
///   const TextSpan(text: 'Questo è un alert con un esempio di '),
///   WidgetSpan(
///     alignment: PlaceholderAlignment.baseline,
///     baseline: TextBaseline.alphabetic,
///     child: ItAlertLink(label: 'link', onPressed: () {}),
///   ),
///   const TextSpan(text: ' evidenziato.'),
/// ]))
/// ```
///
/// [PlaceholderAlignment.baseline] is not optional there: the default aligns the
/// widget's bottom edge to the line box, which drops the link a few pixels below
/// the words either side of it.
class ItAlertLink extends StatelessWidget {
  /// The link text.
  final String label;

  /// Called when the link is activated, by pointer or by keyboard.
  final VoidCallback? onPressed;

  /// Overrides the announced name.
  ///
  /// Use it where [label] would not stand on its own out of context — "link",
  /// "qui", "leggi tutto" (WCAG §2.4.4 Link Purpose). The visible text is
  /// unchanged.
  final String? semanticLabel;

  /// Creates a `.alert-link`.
  const ItAlertLink({
    super.key,
    required this.label,
    this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    return ItHoverBuilder(
      cursor: onPressed == null ? MouseCursor.defer : SystemMouseCursors.click,
      builder: (context, hovered) {
        // `a:hover { color: var(--bs-link-hover-color) }` —
        // `rgb(0, 81.6, 163.2)`, the link colour at 80%. `.alert-link` adds no
        // hover rule of its own, so it inherits the page's.
        final color = hovered ? itShade(colors.primary, 0.20) : colors.primary;
        return Semantics(
          link: true,
          label: semanticLabel ?? label,
          child: ItActivatable(
            onPressed: onPressed,
            cursor: MouseCursor.defer,
            disabledCursor: MouseCursor.defer,
            // The link sits inside running text, so the ring must hug the
            // glyphs rather than a padded box: no radius, and no layout space,
            // which is what ItFocusRing's stroked painter gives.
            borderRadius: BorderRadius.zero,
            child: ExcludeSemantics(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: color,
                  // Inherits size, family and line height from the alert's own
                  // DefaultTextStyle — `.alert-link` sets none of the three, so
                  // restating them here would make the link a different size
                  // from the sentence it sits in.
                  fontFamily: BootstrapItaliaFontFamily.sansSerif,
                  package: BootstrapItaliaFontFamily.package,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
