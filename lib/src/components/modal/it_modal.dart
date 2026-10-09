import 'package:flutter/widgets.dart';

import '../common/it_close_button.dart';
import '../../l10n/it_localizations.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/it_default_text_style.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Size presets for [ItModal].
///
/// Each value maps to a maximum width that the modal dialog will occupy.
/// Values match Bootstrap Italia's `--bs-modal-width` overrides:
/// `.modal-sm { 300px }`, default `500px`, `.modal-lg { 800px }`,
/// `.modal-xl { 1140px }`.
///
/// Spelled out rather than carrying the CSS suffix; the `.modal-*` classes stay
/// in the citation above, where they are evidence. See [ItButtonSize].
enum ItModalSize {
  /// Small modal: 300px max width.
  small(300),

  /// Medium modal (default): 500px max width.
  medium(500),

  /// Large modal: 800px max width.
  large(800),

  /// Extra-large modal: 1140px max width.
  extraLarge(1140);

  /// The maximum width in logical pixels for this size.
  final double maxWidth;

  const ItModalSize(this.maxWidth);
}

/// Where an [ItModal] sits in the viewport.
///
/// [center] and [top] are the two placements [ItModal.show]'s `centered` flag
/// has always chosen between. [left] and [right] are Bootstrap Italia's
/// `.modal-dialog-left` / `.modal-dialog-right`: full-height side sheets that
/// slide in from their own edge.
enum ItModalAlignment {
  /// `.modal-dialog-centered` — vertically centred.
  center,

  /// The default `.modal-dialog`, near the top of the viewport.
  top,

  /// `.modal-dialog-left { margin: 0 24px 0 0 }` with
  /// `.modal-content { height: 100vh }` — flush with the left edge, full
  /// height, entering from `translateX(-100%)`.
  left,

  /// `.modal-dialog-right { margin: 0 0 0 24px; float: right }` with
  /// `.modal-content { height: 100vh }` — flush with the right edge, full
  /// height, entering from `translateX(100%)`.
  right;

  /// Whether this placement makes the panel fill the viewport height.
  ///
  /// `.modal .modal-dialog.modal-dialog-left .modal-content { height: 100vh }`
  /// and its right-hand twin; the centred and top placements size to content.
  bool get isFullHeight => this == left || this == right;
}

/// A Bootstrap Italia modal dialog.
///
/// Renders the `.modal-content` panel: an optional header (icon, title and
/// close button), a body, and a right-aligned footer of action buttons.
///
/// Use the static [show] method to present the modal:
///
/// ```dart
/// ItModal.show(
///   context: context,
///   title: 'Titolo della modale',
///   body: Text('Woohoo, stai leggendo questo testo in una modale!'),
///   actions: [
///     ItButton(
///       onPressed: () => Navigator.pop(context),
///       child: Text('Salva modifiche'),
///     ),
///   ],
/// );
/// ```
class ItModal extends StatelessWidget {
  // ── Bootstrap Italia `.modal-*` metrics ───────────────────────────
  // Source: bootstrap-italia.min.css
  //   .modal .modal-dialog .modal-content { border: none;
  //     box-shadow: 0 2px 10px 0 rgba(0,0,0,.1) }
  //   .modal .modal-dialog .modal-content .modal-header { padding: 24px 24px 0 }
  //   .modal .modal-dialog .modal-content .modal-body   { padding: 24px 24px 0 }
  //   .modal .modal-dialog .modal-content .modal-footer { padding: 12px 24px }
  //   .modal-header .icon { fill: #06c; margin-right: 16px }
  //   --bs-modal-footer-gap: 0.5rem  ->  .modal-footer > * { margin: 4px }

  /// `--bs-modal-padding: 1.5rem` — the shared 24px inset of every section.
  static const double _sectionPadding = BootstrapItaliaSpacing.space4;

  /// `.modal-footer { padding: 12px 24px }`.
  static const double _footerPaddingY = 12;

  /// Half of `--bs-modal-footer-gap` (0.5rem), applied around each action.
  static const double _footerActionMargin = 4;

  /// `.modal-header .icon { width: 32px; height: 32px }`.
  static const double _headerIconSize = 32;

  /// `.modal-header .icon { margin-right: 16px }`.
  static const double _headerIconGap = BootstrapItaliaSpacing.space3;

  // ── `.popconfirm-modal` ───────────────────────────────────────────
  //   .modal.popconfirm-modal .modal-dialog { max-width: 300px }
  //   .modal.popconfirm-modal .modal-dialog .modal-content
  //     { border-radius: 4px }
  //   .modal.popconfirm-modal .modal-dialog .modal-header
  //     { padding-top: 16px; margin-bottom: -4px }
  //   .modal.popconfirm-modal .modal-dialog .modal-body { padding-top: 16px }
  //   @media (min-width: 576px) { … .modal-body p { font-size: 1rem } }
  //   .modal.popconfirm-modal .modal-dialog .modal-footer
  //     { padding-bottom: 24px }

  /// `.modal.popconfirm-modal .modal-dialog { max-width: 300px }` — narrower
  /// than every [ItModalSize], and applied instead of the chosen size.
  static const double _popconfirmMaxWidth = 300;

  /// `.modal.popconfirm-modal … .modal-header { padding-top: 16px }`, which is
  /// also the body's `padding-top`.
  static const double _popconfirmPaddingTop = BootstrapItaliaSpacing.space3;

  /// `.modal.popconfirm-modal … .modal-header { margin-bottom: -4px }` — the
  /// title is pulled back down towards the message.
  static const double _popconfirmHeaderPullUp = 4;

  /// `.modal.popconfirm-modal … .modal-footer { padding-bottom: 24px }`.
  static const double _popconfirmFooterPaddingBottom = _sectionPadding;

  /// `.modal-footer.modal-footer-shadow
  ///   { box-shadow: 0 15px 25px 5px rgba(0,0,0,.3) }`
  ///
  /// The rule the docs point at for *"meglio distinguere l'elemento footer"*
  /// when a long body scrolls behind it. A drop shadow is not a palette
  /// colour, so the `rgba()` stays a literal.
  static const BoxShadow _footerShadow = BoxShadow(
    color: Color(0x4D000000),
    blurRadius: 25,
    spreadRadius: 5,
    offset: Offset(0, 15),
  );

  /// Optional title displayed in the modal header.
  final String? title;

  /// Optional icon displayed before the title.
  ///
  /// When set, the modal uses Bootstrap Italia's `alert-modal` header layout:
  /// a 32px primary-coloured icon top-aligned with the title.
  final IconData? icon;

  /// The main content of the modal.
  final Widget body;

  /// Action buttons displayed in the modal footer.
  ///
  /// Typically a list of `ItButton` widgets. Defaults to an empty list.
  final List<Widget> actions;

  /// The size preset controlling the modal's maximum width.
  ///
  /// Defaults to [ItModalSize.medium].
  final ItModalSize size;

  /// Whether the body content should be scrollable.
  ///
  /// When true, wraps the body in a [SingleChildScrollView].
  /// Defaults to false.
  final bool scrollable;

  /// Whether the modal can be dismissed by tapping outside or via
  /// the close button.
  ///
  /// Defaults to true.
  final bool dismissible;

  /// The `.popconfirm-modal` design: a 300px confirmation panel with rounded
  /// corners, tighter header and body insets, and a 16px message.
  ///
  /// The title is optional here in a way it is not elsewhere — the docs say to
  /// *"rimuovere l'intero elemento `<div class="modal-header">`"* when it is not
  /// needed, which is what passing no [title] does. With no header there is
  /// also no close button, so a popconfirm has to carry a dismissing action;
  /// that is the same requirement [show]'s assert already enforces.
  ///
  /// Overrides [size]: `max-width: 300px` is stated on `.modal-dialog` itself.
  final bool popconfirm;

  /// Paints `.modal-footer-shadow` beneath the footer.
  ///
  /// Only meaningful with [scrollable]: the shadow exists to separate a pinned
  /// footer from body content sliding underneath it.
  final bool footerShadow;

  /// Whether the panel fills the viewport height.
  ///
  /// Set by [show] for the side-sheet alignments, where
  /// `.modal-content { height: 100vh }`. The body then takes the slack and the
  /// footer is pinned to the bottom edge, which is the flex-column layout
  /// `.it-dialog-scrollable` describes.
  final bool fullHeight;

  /// Creates a Bootstrap Italia modal widget.
  ///
  /// Prefer using [ItModal.show] to display the modal as a dialog.
  const ItModal({
    super.key,
    this.title,
    this.icon,
    required this.body,
    this.actions = const [],
    this.size = ItModalSize.medium,
    this.scrollable = false,
    this.dismissible = true,
    this.popconfirm = false,
    this.footerShadow = false,
    this.fullHeight = false,
  });

  /// Displays an [ItModal] as a dialog.
  ///
  /// Returns a [Future] that completes with the value passed to
  /// [Navigator.pop] when the dialog is closed.
  ///
  /// When [centered] is true (default), the modal is vertically centered.
  /// When false, it is positioned near the top of the screen.
  ///
  /// ## Escape and WCAG 2.1.2 No Keyboard Trap
  ///
  /// A modal route traps focus by design — that is the point of a dialog — so
  /// there must always be a keyboard way back out. With the default
  /// `dismissible: true` that route is Escape, which Flutter's [ModalRoute]
  /// wires to the barrier.
  ///
  /// `dismissible: false` deliberately removes every dismissal affordance:
  /// no close button, a barrier that ignores taps, and no Escape. That is a
  /// legitimate "you must choose" pattern *only* while the dialog still offers
  /// a keyboard-reachable control that closes it. With no [actions] at all it
  /// is an inescapable focus trap, so that combination is asserted against
  /// rather than silently shipped.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    IconData? icon,
    required Widget body,
    List<Widget> actions = const [],
    ItModalSize size = ItModalSize.medium,
    bool scrollable = false,
    bool centered = true,
    bool dismissible = true,
    Color? barrierColor,
    ItModalAlignment? alignment,
    bool popconfirm = false,
    bool footerShadow = false,
    bool animated = true,
  }) {
    assert(
      dismissible || actions.isNotEmpty,
      'A non-dismissible ItModal must provide at least one action.\n'
      'With `dismissible: false` there is no close button, the barrier ignores '
      'taps, and Escape does not pop the route — so a modal with no actions '
      'traps keyboard focus with no way out (WCAG 2.1.2 No Keyboard Trap). '
      'Either give the dialog an action that closes it, or leave `dismissible` '
      'at its default.',
    );

    // `alignment` supersedes `centered`, which predates it and can only
    // express two of the four placements. Left null — which is what every
    // existing call site passes, because it did not exist — the flag keeps its
    // original meaning exactly.
    final effectiveAlignment = alignment ??
        (centered ? ItModalAlignment.center : ItModalAlignment.top);

    // Read here, from the *caller's* context: the dialog's own context is a
    // route below the navigator, and the barrier label is needed before it
    // exists.
    final l10n = ItLocalizations.of(context);
    final colors = resolveColorScheme(context);
    // Bootstrap Italia: --bs-backdrop-opacity: 0.8
    final effectiveBarrierColor = barrierColor ?? colors.black.withAlpha(204);

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      // `MaterialLocalizations.of` ASSERTS when absent, so reading the barrier
      // label from it made ItModal.show unusable outside a MaterialApp —
      // contradicting the package's claim that its components need no Scaffold.
      // `ItLocalizations.of` cannot assert and cannot return null; with no
      // delegate installed it answers in Italian.
      //
      // A name of its own rather than `closeModal`: the barrier and the header
      // close button are two nodes in the same dialog, and one name across both
      // leaves AT with two indistinguishable targets (WCAG 4.1.2).
      barrierLabel: l10n.dismissModalBarrier,
      barrierColor: effectiveBarrierColor,
      // Bootstrap Italia: .modal-dialog { transition: transform .3s ease-out },
      // and *"per avere modali che appaiono semplicemente senza dissolvenza,
      // rimuovi la classe .fade"* — which is `animated: false`, a duration of
      // zero rather than a second code path.
      transitionDuration:
          animated ? const Duration(milliseconds: 300) : Duration.zero,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (!animated) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        // The side sheets enter along their own axis:
        // `.modal.fade .modal-dialog.modal-dialog-left
        //   { transform: translateX(-100%) }` and its right-hand twin, easing
        // to `translateX(0)` on `.show`. Everything else uses
        // `$modal-fade-transform: translate(0, -50px)`.
        final begin = switch (effectiveAlignment) {
          ItModalAlignment.left => const Offset(-1, 0),
          ItModalAlignment.right => const Offset(1, 0),
          _ => const Offset(0, -0.05),
        };
        final slide = SlideTransition(
          position:
              Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
          child: child,
        );
        // A sheet that slides the full width of itself does not also fade —
        // `.modal-dialog-left` overrides the `.fade` opacity transition with a
        // pure `transform` one.
        return effectiveAlignment.isFullHeight
            ? slide
            : FadeTransition(opacity: curved, child: slide);
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        final modal = ItModal(
          title: title,
          icon: icon,
          body: body,
          actions: actions,
          size: size,
          scrollable: scrollable,
          dismissible: dismissible,
          popconfirm: popconfirm,
          footerShadow: footerShadow,
          fullHeight: effectiveAlignment.isFullHeight,
        );

        return SafeArea(
          child: switch (effectiveAlignment) {
            // `.modal .modal-dialog { margin: 48px }`
            ItModalAlignment.center => Padding(
                padding: const EdgeInsets.all(BootstrapItaliaSpacing.space5),
                child: Center(child: modal),
              ),
            ItModalAlignment.top => Padding(
                padding: const EdgeInsets.all(BootstrapItaliaSpacing.space5),
                child: Align(alignment: Alignment.topCenter, child: modal),
              ),
            // `.modal-dialog-left { margin: 0 24px 0 0 }` — flush with the
            // left edge, a single 24px gutter on the inner side, and no
            // vertical margin at all because the panel is the viewport's
            // height.
            ItModalAlignment.left => Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: BootstrapItaliaSpacing.space4,
                  ),
                  child: modal,
                ),
              ),
            // `.modal-dialog-right { margin: 0 0 0 24px; float: right }`
            ItModalAlignment.right => Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: BootstrapItaliaSpacing.space4,
                  ),
                  child: modal,
                ),
              ),
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);

    final hasHeader = title != null;
    final hasFooter = actions.isNotEmpty;

    Widget bodyContent = DefaultTextStyle(
      // `.modal-body { color: hsl(0,0%,10%) }` with the default 1.125rem/1.75rem
      // paragraph type scale used inside modals — dropped to 1rem by
      // `@media (min-width: 576px) { .modal.popconfirm-modal … .modal-body p
      //   { font-size: 1rem } }`, on a body line-height of 1.5.
      style: TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        fontSize: popconfirm ? 16 : 18,
        height: popconfirm ? 24 / 16 : 28 / 18,
        leadingDistribution: TextLeadingDistribution.even,
        // Bootstrap Italia: letter-spacing: normal. Set explicitly so the
        // ambient Material text theme cannot leak its 0.25px tracking.
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        // `--bs-modal-color` is unset, so `.modal-content` inherits
        // `--bs-body-color`, hsl(0, 0%, 10%).
        color: colors.bodyColor,
      ),
      child: body,
    );
    if (scrollable) {
      bodyContent = SingleChildScrollView(child: bodyContent);
    }

    // WCAG 4.1.2 Name, Role, Value / 1.3.1 Info and Relationships: the dialog
    // must expose both the route (dialog) role and an accessible name. Before
    // this, `scopesRoute` was set but `namesRoute` was not, so the node was
    // announced as an unnamed route — a screen-reader user entering the dialog
    // was told nothing about what it was. The name is the visible title, which
    // also satisfies 2.5.3 Label in Name.
    final routeLabel = title ?? ItLocalizations.of(context).dialog;

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: routeLabel,
      explicitChildNodes: true,
      // WCAG 2.4.3 Focus Order / 2.4.11 Focus Not Obscured: focus has to land
      // inside the dialog when it opens, otherwise it stays on the control
      // behind the barrier — which is both out of order and, since the barrier
      // covers it, entirely obscured. Flutter's ModalRoute only focuses its
      // own FocusScope, which is not a real node, so nothing is announced;
      // this Focus gives AT something concrete to land on.
      //
      // `skipTraversal` keeps the dialog container out of the Tab ring, so the
      // first Tab still reaches the first real control (2.1.1).
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        // Without this the Focus node swallows every non-container annotation
        // beneath it, so the title's heading role and the body text collapse
        // into the focus node itself and AT announces one run-on string.
        child: Semantics(
          explicitChildNodes: true,
          // No `Material` above the dialog: it was a
          // `MaterialType.transparency` surface, so it painted nothing and
          // existed only to host ink the dialog never asked for. The content's
          // own decoration below carries the fill and the drop shadow.
          //
          // Its text style, though, has to be restored: `showGeneralDialog`
          // pushes a route above the app's Scaffold, so the dialog — and the
          // caller-supplied body content in particular — would otherwise render
          // with no font family and no line-height at all.
          child: ItDefaultTextStyle(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // `.modal.popconfirm-modal .modal-dialog { max-width: 300px }`
                // is stated on the dialog itself, so it wins over whichever
                // `--bs-modal-width` the size preset asked for.
                maxWidth: popconfirm ? _popconfirmMaxWidth : size.maxWidth,
                maxHeight: MediaQuery.sizeOf(context).height,
              ),
              child: Container(
                // `.modal-content { width: 100% }` inside a `.modal-dialog`
                // capped at `--bs-modal-width`.
                width: double.infinity,
                // `.modal .modal-dialog.modal-dialog-left .modal-content
                //   { height: 100vh }` — a side sheet is as tall as the window.
                height: fullHeight ? double.infinity : null,
                decoration: BoxDecoration(
                  color: colors.white,
                  // `.modal .modal-dialog .modal-content` renders square corners
                  // and no border, only the dialog drop shadow —
                  // `.popconfirm-modal … .modal-content { border-radius: 4px }`
                  // being the one design that rounds them.
                  borderRadius: popconfirm
                      ? BorderRadius.circular(BootstrapItaliaBorders.radius)
                      : null,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  // A content-sized panel shrink-wraps; a full-height one has
                  // slack to distribute, which the body below takes.
                  mainAxisSize:
                      fullHeight ? MainAxisSize.max : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasHeader) _buildHeader(context, colors),

                    // `.modal-body { padding: 24px 24px 0 }`, or `16px` at the
                    // top under `.popconfirm-modal` — less the 4px its header
                    // pulls back up with `margin-bottom: -4px`. The 16px gap
                    // before the footer comes from the body paragraph's
                    // `margin-bottom`, which Bootstrap Italia always has in
                    // this position.
                    _bodySlot(
                      fullHeight: fullHeight,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          _sectionPadding,
                          popconfirm
                              ? _popconfirmPaddingTop -
                                  (hasHeader ? _popconfirmHeaderPullUp : 0)
                              : _sectionPadding,
                          _sectionPadding,
                          hasFooter
                              ? BootstrapItaliaSpacing.space3
                              : _sectionPadding,
                        ),
                        child: bodyContent,
                      ),
                    ),

                    if (hasFooter)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          // `.it-dialog-scrollable … .modal-footer
                          //   { background: #fff }` — the shadow needs an
                          // opaque footer to sit on, or the body shows through
                          // it as it scrolls past.
                          color: footerShadow ? colors.white : null,
                          boxShadow:
                              footerShadow ? const [_footerShadow] : null,
                        ),
                        child: Padding(
                          // `.modal-footer { padding: 12px 24px }`, with
                          // `.popconfirm-modal … { padding-bottom: 24px }`.
                          padding: EdgeInsets.fromLTRB(
                            _sectionPadding,
                            _footerPaddingY,
                            _sectionPadding,
                            popconfirm
                                ? _popconfirmFooterPaddingBottom
                                : _footerPaddingY,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // `.modal-footer > * { margin: calc(gap * .5) }`
                              for (final action in actions)
                                Padding(
                                  padding:
                                      const EdgeInsets.all(_footerActionMargin),
                                  child: action,
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The body's slot in the panel column.
  ///
  /// [Flexible] when the panel sizes to its content — the body may shrink
  /// below its natural height but never claims the leftovers. [Expanded] when
  /// the panel is the viewport's height, so the slack goes to the body and the
  /// footer stays pinned to the bottom edge rather than floating under a
  /// short message.
  static Widget _bodySlot({required bool fullHeight, required Widget child}) =>
      fullHeight ? Expanded(child: child) : Flexible(child: child);

  Widget _buildHeader(BuildContext context, BootstrapItaliaColorScheme colors) {
    final hasIcon = icon != null;
    return Padding(
      // `.modal-header { padding: 24px 24px 0 }`, tightened to `16px` at the
      // top by `.popconfirm-modal … .modal-header { padding-top: 16px }`.
      padding: EdgeInsets.fromLTRB(
        _sectionPadding,
        popconfirm ? _popconfirmPaddingTop : _sectionPadding,
        _sectionPadding,
        0,
      ),
      child: Row(
        // The default header centres its children; the icon (`alert-modal`)
        // variant switches to `align-items: start`.
        crossAxisAlignment:
            hasIcon ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (hasIcon) ...[
            Icon(
              icon,
              // `.modal-header .icon { fill: #06c }`
              color: colors.primary,
              size: _headerIconSize,
            ),
            const SizedBox(width: _headerIconGap),
          ],
          Expanded(
            // `.modal-title` is an `<h5>` upstream. WCAG 1.3.1: the heading
            // relationship has to survive into the semantics tree, otherwise
            // the dialog's title is announced as ordinary text and cannot be
            // reached with a screen reader's heading navigation.
            child: Semantics(
              header: true,
              child: Text(
                title!,
                // `.modal-title.h5` renders at 1.5rem / 1.5 semibold.
                style: TextStyle(
                  fontFamily: BootstrapItaliaFontFamily.sansSerif,
                  package: BootstrapItaliaFontFamily.package,
                  fontSize: 24,
                  height: 36 / 24,
                  leadingDistribution: TextLeadingDistribution.even,
                  // Bootstrap Italia: letter-spacing: normal. Set explicitly so the
                  // ambient Material text theme cannot leak its 0.25px tracking.
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  // `.modal-title` declares no colour and inherits
                  // `--bs-body-color`, hsl(0, 0%, 10%).
                  color: colors.bodyColor,
                ),
              ),
            ),
          ),
          if (dismissible)
            ItCloseButton(
              onPressed: () => Navigator.pop(context),
              label: ItLocalizations.of(context).closeModal,
            ),
        ],
      ),
    );
  }
}
