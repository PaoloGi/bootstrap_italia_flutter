import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../a11y/it_focus_ring.dart';
import '../../l10n/it_localizations.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/it_default_text_style.dart';
import '../../theme/theme_extensions.dart';
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

  /// `.btn-close` occupies a 16x16 slot flush with the header padding edge.
  static const double _closeBoxSize = 16;

  /// `.modal-header .btn-close { padding: calc(--bs-modal-header-padding * .5) }`
  /// — a 12px inset on every side, cancelled for layout purposes by equal
  /// negative margins. The button therefore *occupies* 16x16 of the header row
  /// but is *clickable* across 40x40.
  ///
  /// Reproducing the inset is what keeps the control above the 24x24 floor of
  /// WCAG 2.5.8 Target Size (Minimum): the painted glyph alone is 16x16.
  static const double _closeHitInset = 12;

  /// The Bootstrap Italia `it-close` glyph covers ~9/24 of its em box, so it
  /// has to be scaled up to fill the 16x16 `.btn-close` background artwork.
  static const double _closeGlyphSize = _closeBoxSize * 24 / 9;

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

    final colors = resolveColorScheme(context);
    // Read here, from the *caller's* context: the dialog's own context is a
    // route below the navigator and the barrier label is needed before it
    // exists.
    final l10n = ItLocalizations.of(context);
    // Bootstrap Italia: --bs-backdrop-opacity: 0.8
    final effectiveBarrierColor = barrierColor ?? colors.black.withAlpha(204);

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      // `MaterialLocalizations.of` ASSERTS when absent, so this line alone made
      // ItModal.show unusable outside a MaterialApp — contradicting the
      // package's claim that its components need no Scaffold. `ItLocalizations`
      // exists partly for this: it never returns null and never asserts, and
      // with no delegate installed it answers in Italian (ADR 0002).
      //
      // A name of its own rather than `closeModal`: the barrier and the header
      // close button are two nodes in the same dialog, and one name across both
      // gives AT two indistinguishable targets (WCAG 4.1.2).
      barrierLabel: l10n.dismissModalBarrier,
      barrierColor: effectiveBarrierColor,
      // Bootstrap Italia: .modal-dialog { transition: transform .3s ease-out }
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        // Bootstrap Italia: $modal-fade-transform: translate(0, -50px)
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.05),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
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
        );

        return SafeArea(
          child: Padding(
            // `.modal .modal-dialog { margin: 48px }`
            padding: const EdgeInsets.all(BootstrapItaliaSpacing.space5),
            child: centered
                ? Center(child: modal)
                : Align(alignment: Alignment.topCenter, child: modal),
          ),
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
      // paragraph type scale used inside modals.
      style: TextStyle(
        fontFamily: BootstrapItaliaFontFamily.sansSerif,
        package: BootstrapItaliaFontFamily.package,
        fontSize: 18,
        height: 28 / 18,
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
                maxWidth: size.maxWidth,
                maxHeight: MediaQuery.sizeOf(context).height,
              ),
              child: Container(
                // `.modal-content { width: 100% }` inside a `.modal-dialog`
                // capped at `--bs-modal-width`.
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.white,
                  // `.modal .modal-dialog .modal-content` renders square corners
                  // and no border, only the dialog drop shadow.
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasHeader) _buildHeader(context, colors),

                    // `.modal-body { padding: 24px 24px 0 }`. The 16px gap before
                    // the footer comes from the body paragraph's `margin-bottom`,
                    // which Bootstrap Italia always has in this position.
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          _sectionPadding,
                          _sectionPadding,
                          _sectionPadding,
                          hasFooter
                              ? BootstrapItaliaSpacing.space3
                              : _sectionPadding,
                        ),
                        child: bodyContent,
                      ),
                    ),

                    if (hasFooter)
                      Padding(
                        // `.modal-footer { padding: 12px 24px }`
                        padding: const EdgeInsets.symmetric(
                          horizontal: _sectionPadding,
                          vertical: _footerPaddingY,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BootstrapItaliaColorScheme colors) {
    final hasIcon = icon != null;
    return Padding(
      // `.modal-header { padding: 24px 24px 0 }`
      padding: const EdgeInsets.fromLTRB(
        _sectionPadding,
        _sectionPadding,
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
            _CloseButton(onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

/// Internal `.btn-close` used in the modal header.
///
/// `.modal-header .btn-close` has a 12px inset and equal negative margins, so
/// it occupies a 16x16 slot flush with the header's right padding edge while
/// remaining clickable across 40x40. [_ExpandedHitTarget] reproduces exactly
/// that split, which is what lifts the control over the 24x24 minimum of
/// WCAG 2.5.8 without moving a single painted pixel.
///
/// It is a real focus target too: the previous `GestureDetector` could only be
/// operated with a pointer, so a keyboard user could never close the dialog
/// from its header (WCAG 2.1.1 Keyboard).
class _CloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _focused = false;

  void _setFocused(bool value) {
    if (_focused != value) setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    return _ExpandedHitTarget(
      // `.modal-header .btn-close { padding: 12px; margin: -12px }`.
      expansion: const EdgeInsets.all(ItModal._closeHitInset),
      // The label, the button role and the focusability all have to land on a
      // single node: split across two, AT announces an unnamed focusable child
      // inside a button it cannot reach (WCAG 4.1.2).
      child: MergeSemantics(
        child: Semantics(
          label: ItLocalizations.of(context).closeModal,
          button: true,
          enabled: true,
          onTap: widget.onPressed,
          child: FocusableActionDetector(
            onShowFocusHighlight: _setFocused,
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  widget.onPressed();
                  return null;
                },
              ),
              ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
                onInvoke: (_) {
                  widget.onPressed();
                  return null;
                },
              ),
            },
            // WCAG 2.4.7 Focus Visible. The design system's own indicator is
            // painted only while the control holds keyboard focus, so the
            // default rendering — and therefore visual parity — is untouched.
            child: ItFocusRing(
              visible: _focused,
              child: GestureDetector(
                onTap: widget.onPressed,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: ItModal._closeBoxSize,
                  height: ItModal._closeBoxSize,
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: Icon(
                      BootstrapItaliaIcons.it_close,
                      // `.btn-close` paints a black glyph at 50% opacity.
                      color: Color(0x80000000),
                      size: ItModal._closeGlyphSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays out exactly like its child but accepts pointer events across a larger
/// rectangle, reproducing a CSS `padding` + equal negative `margin` pair.
///
/// Flutter clips hit testing to a render object's own box, so the usual tricks
/// (`OverflowBox`, an oversized `Stack` child) cannot enlarge a tap target
/// without also enlarging the layout box — which would move neighbouring
/// content. This widget keeps the layout box untouched and instead widens the
/// region it answers `hitTest` for, clamping the hit back into the child so the
/// child's own gesture recognisers still receive it.
///
/// Note that ancestors still bound hit testing to *their* boxes, so the usable
/// target is the expansion intersected with the parent's rect. For the modal
/// close button that yields roughly 28x36 against a 16x16 painted glyph, which
/// clears the 24x24 floor of WCAG 2.5.8 Target Size (Minimum).
class _ExpandedHitTarget extends SingleChildRenderObjectWidget {
  /// How far beyond the child's box pointer events are still accepted.
  final EdgeInsets expansion;

  const _ExpandedHitTarget({required this.expansion, required super.child});

  @override
  _RenderExpandedHitTarget createRenderObject(BuildContext context) =>
      _RenderExpandedHitTarget(expansion);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderExpandedHitTarget renderObject,
  ) {
    renderObject.expansion = expansion;
  }
}

class _RenderExpandedHitTarget extends RenderProxyBox {
  _RenderExpandedHitTarget(this._expansion);

  EdgeInsets _expansion;

  EdgeInsets get expansion => _expansion;

  set expansion(EdgeInsets value) {
    if (_expansion == value) return;
    _expansion = value;
    markNeedsLayout();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!_expansion.inflateRect(Offset.zero & size).contains(position)) {
      return false;
    }
    // Clamp into the painted box so the child's recognisers accept the hit.
    // A tap only needs to be on the recogniser's hit path, so nudging the
    // local coordinates costs nothing.
    final clamped = Offset(
      position.dx.clamp(0.0, size.width - _kHitEpsilon),
      position.dy.clamp(0.0, size.height - _kHitEpsilon),
    );
    return super.hitTest(result, position: clamped);
  }

  /// Keeps a clamped position strictly inside the box: `size.contains` treats
  /// the right and bottom edges as outside.
  static const double _kHitEpsilon = 0.01;
}
