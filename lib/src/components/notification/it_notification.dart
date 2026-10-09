import 'dart:async';

import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/semantics.dart';

import '../bottom_nav/bottom_nav_clearance.dart';
import '../../l10n/it_localizations.dart';
import '../../a11y/it_focus_ring.dart';
import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/it_default_text_style.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Color variants for [ItNotification].
enum ItNotificationVariant {
  /// Green success notification.
  success,

  /// Orange warning notification.
  warning,

  /// Red danger notification (`.notification.error` in Bootstrap Italia).
  danger,

  /// Blue info notification.
  info,
}

/// Screen position for overlay notifications.
///
/// The first six values float the card clear of the viewport edge, which is
/// Bootstrap Italia's default placement — *"la posizione predefinita delle
/// notifiche è nella parte destra inferiore della finestra"*, with all four
/// corners rounded.
///
/// The four `…Fix` values are the kit's `.top-fix` / `.bottom-fix` /
/// `.left-fix` / `.right-fix` modifiers: the card sits flush against that edge
/// and the two corners touching it are squared off, so it reads as attached to
/// the window rather than floating above it.
enum ItNotificationPosition {
  /// Top-right corner.
  topRight,

  /// Top-left corner.
  topLeft,

  /// Top center.
  topCenter,

  /// Bottom-right corner.
  bottomRight,

  /// Bottom-left corner.
  bottomLeft,

  /// Bottom center.
  bottomCenter,

  /// `.notification.top-fix { border-top-left-radius: 0;
  ///   border-top-right-radius: 0; top: 0; left: 50%;
  ///   transform: translateX(-50%) }` — flush with the top edge, centred.
  topFix,

  /// `.notification.bottom-fix { border-bottom-left-radius: 0;
  ///   border-bottom-right-radius: 0; left: 50%; bottom: 0;
  ///   transform: translateX(-50%) }` — flush with the bottom edge, centred.
  bottomFix,

  /// `.notification.left-fix { border-top-left-radius: 0;
  ///   border-bottom-left-radius: 0; border-left: none;
  ///   border-right-style: solid; border-right-width: 4px; left: 0; top: 50%;
  ///   transform: translateY(-50%) }` — flush with the left edge, vertically
  /// centred.
  ///
  /// Note the accent: the 4px variant border moves to the *right* of the card,
  /// because the left edge is the one against the window.
  leftFix,

  /// `.notification.right-fix { border-top-right-radius: 0;
  ///   border-bottom-right-radius: 0; right: 0; top: 50%;
  ///   transform: translateY(-50%) }` — flush with the right edge, vertically
  /// centred.
  rightFix;

  /// The corners this placement leaves rounded.
  ///
  /// `border-radius: 4px` on all four by default; each `…Fix` modifier zeroes
  /// the pair that meets the window edge.
  BorderRadius get borderRadius {
    const r = Radius.circular(BootstrapItaliaBorders.radius);
    return switch (this) {
      topFix => const BorderRadius.vertical(bottom: r),
      bottomFix => const BorderRadius.vertical(top: r),
      leftFix => const BorderRadius.horizontal(right: r),
      rightFix => const BorderRadius.horizontal(left: r),
      _ => const BorderRadius.all(r),
    };
  }

  /// Whether the 4px variant accent is painted on the card's right edge.
  ///
  /// Only `.left-fix` moves it: `{ border-left: none; border-right-style:
  /// solid; border-right-width: 4px }`.
  bool get accentOnRight => this == leftFix;
}

/// A Bootstrap Italia notification (toast) component.
///
/// Displays a transient feedback message with an uppercase title, an optional
/// message body, an optional variant icon (which also colours the left accent
/// border) and a dismiss button.
///
/// Use [ItNotification.show] to display a notification as an overlay:
///
/// ```dart
/// ItNotification.show(
///   context: context,
///   variant: ItNotificationVariant.success,
///   title: 'Titolo notifica',
///   body: 'Il documento è stato salvato.',
///   icon: BootstrapItaliaIcons.it_check_circle,
///   position: ItNotificationPosition.topRight,
/// );
/// ```
class ItNotification extends StatefulWidget {
  // ── Bootstrap Italia `.notification` metrics ──────────────────────
  // Source: bootstrap-italia.min.css
  //   @media (min-width: 768px) .notification { width: 376px;
  //     border-radius: 4px; box-shadow: 0 0 1rem rgba(0,0,0,.15) }
  //   @media (min-width: 576px) .notification { padding: 1.333rem;
  //     padding-right: 3.556rem }

  /// Default width of the notification card: 376px.
  static const double defaultWidth = 376;

  /// `$notification-padding: 1.333rem`.
  static const double _padding = 21.328;

  /// `padding-right: 3.556rem` — reserves room for the close button.
  static const double _paddingRight = 56.896;

  /// `.notification.with-icon h5/p { margin-left: 1.778rem }`.
  static const double _iconTextOffset = 28.448;

  /// `.notification.with-icon { border-left: 4px solid <variant> }`.
  static const double _accentWidth = 4;

  /// `.notification.with-icon h5 .icon { top: -8px; left: -38px }`,
  /// relative to the title, which itself sits at [_padding] + [_iconTextOffset]
  /// inside the padding box (i.e. already past the accent border).
  static const double _iconLeft = _padding + _iconTextOffset - 38;
  static const double _iconTop = _padding - 8;

  /// `.icon { width: 32px; height: 32px }`.
  static const double _iconSize = 32;

  /// `.notification.dismissable .notification-close
  ///    { right: 20px; top: 15px; width: 32px; height: 32px }`.
  static const double _closeRight = 20;
  static const double _closeTop = 15;
  static const double _closeSize = 32;

  /// The notification color variant.
  final ItNotificationVariant variant;

  /// Optional title text. Rendered uppercase and bold, per
  /// `.notification h5 { text-transform: uppercase; font-weight: 700 }`.
  final String? title;

  /// Optional message body, rendered beneath [title].
  ///
  /// A `String` rather than a `Widget`, unlike the other `body` slots in this
  /// package: `.notification p` is a single styled paragraph and the widget
  /// also folds this text into the WCAG 4.1.3 announcement below, which it
  /// could not do with arbitrary children.
  final String? body;

  /// Optional leading icon.
  ///
  /// When set the notification renders the Bootstrap Italia `with-icon`
  /// variant: a 32px variant-coloured icon plus a 4px left accent border.
  final IconData? icon;

  /// Whether the notification can be dismissed via a close button.
  final bool dismissible;

  /// Called after the exit animation completes when the notification
  /// is dismissed (either manually or by auto-dismiss timer).
  ///
  /// A *notification*, not a request: the widget has already taken itself off
  /// screen, and this is where [show] removes the spent [OverlayEntry]. Past
  /// tense marks that throughout this package — compare [ItChip.onDismiss],
  /// which asks the parent to act because the chip cannot.
  final VoidCallback? onDismissed;

  /// Auto-dismiss duration. When non-null the notification dismisses
  /// automatically after this duration. Pass `null` for a persistent
  /// notification.
  ///
  /// ## WCAG 2.2.1 Timing Adjustable
  ///
  /// A notification that removes itself on a timer imposes a time limit on
  /// reading it. The widget mitigates this in two ways: the timer is paused
  /// while the notification is hovered or holds focus, and it is not started
  /// at all when the platform reports an assistive technology in use
  /// (`MediaQuery.accessibleNavigationOf`), because a screen-reader user may
  /// still be working through the announcement when it would have expired.
  ///
  /// Those mitigations do **not** make an arbitrary [duration] conformant on
  /// their own. If the notification carries information that is not available
  /// anywhere else in the interface, pass `null` and let the user dismiss it —
  /// that is the only unconditionally conformant configuration.
  final Duration? duration;

  /// Width of the notification card. Defaults to [defaultWidth] (376px).
  final double width;

  /// Where the card sits, which decides how it is *drawn*.
  ///
  /// [show] uses this to place the overlay; the card itself reads only the two
  /// things the CSS modifiers change about its own painting —
  /// [ItNotificationPosition.borderRadius] and
  /// [ItNotificationPosition.accentOnRight]. The default is the kit's own
  /// default placement, so a card built directly (outside [show]) renders
  /// exactly as it always has: four rounded corners, accent on the left.
  final ItNotificationPosition position;

  /// Creates a Bootstrap Italia notification widget.
  const ItNotification({
    super.key,
    this.variant = ItNotificationVariant.info,
    this.title,
    this.body,
    this.icon,
    this.dismissible = true,
    this.onDismissed,
    this.duration,
    this.width = defaultWidth,
    this.position = ItNotificationPosition.bottomRight,
  });

  /// Where [show] puts the card.
  ///
  /// [clearance] is the height of a bottom navigation bar on the current page,
  /// 0 with none. Bottom placements sit on top of it rather than over it, and
  /// since the bar already reaches the screen's edge and clears the home
  /// indicator, the card stops padding for the indicator itself.
  static Widget _place(
    Widget child,
    ItNotificationPosition position,
    EdgeInsets padding,
    double clearance,
  ) {
    const inset = BootstrapItaliaSpacing.space3;
    final bottomEdge = clearance > 0 ? 0.0 : padding.bottom;

    // The `…Fix` placements sit flush against their edge, so they take no
    // gap: `top: 0` means the window's top, and insetting the box would
    // undo the squared corners the modifier exists for. The box stays
    // flush; its content is padded clear of the status bar and the home
    // indicator, which is a different thing from a gap.
    switch (position) {
      case ItNotificationPosition.topFix:
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          // As bottomFix: flush to the edge, content below the status bar.
          child: Padding(
            padding: EdgeInsets.only(top: padding.top),
            child: Center(child: child),
          ),
        );
      case ItNotificationPosition.bottomFix:
        return Positioned(
          bottom: clearance,
          left: 0,
          right: 0,
          // Flush to the edge — or to the bar — but the CONTENT clears the
          // home indicator. Without the padding this cleared it by 3px on an
          // iPhone — whatever internal padding the card happened to have, not
          // a decision, and gone on any device with a deeper inset.
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomEdge),
            child: Center(child: child),
          ),
        );
      case ItNotificationPosition.leftFix:
        return Positioned(
          left: 0,
          top: 0,
          bottom: clearance,
          child: Center(child: child),
        );
      case ItNotificationPosition.rightFix:
        return Positioned(
          right: 0,
          top: 0,
          bottom: clearance,
          child: Center(child: child),
        );
      default:
        break;
    }

    final isTop = position == ItNotificationPosition.topRight ||
        position == ItNotificationPosition.topLeft ||
        position == ItNotificationPosition.topCenter;
    final isBottom = !isTop;
    final isCenter = position == ItNotificationPosition.topCenter ||
        position == ItNotificationPosition.bottomCenter;
    final isLeft = position == ItNotificationPosition.topLeft ||
        position == ItNotificationPosition.bottomLeft;
    final isRight = position == ItNotificationPosition.topRight ||
        position == ItNotificationPosition.bottomRight;

    return Positioned(
      top: isTop ? inset + padding.top : null,
      bottom: isBottom ? inset + clearance + bottomEdge : null,
      left: isCenter ? 0 : (isLeft ? inset : null),
      right: isCenter ? 0 : (isRight ? inset : null),
      child: isCenter ? Center(child: child) : child,
    );
  }

  /// Shows a notification as an overlay positioned on screen.
  ///
  /// Returns the [OverlayEntry] so the caller can remove it programmatically.
  ///
  /// Persistent by default: [duration] is `null`, so the notification stays
  /// until dismissed or until the returned [OverlayEntry] is removed.
  ///
  /// **Passing a [duration] transfers a WCAG 2.2.1 (Timing Adjustable)
  /// obligation to you.** An auto-dismissing notification is a time limit set by
  /// content, and none of the SC's exceptions (real-time, essential, 20-hour)
  /// cover a toast. The widget pauses the countdown on hover/focus and disables
  /// it entirely under `MediaQuery.accessibleNavigationOf`, but neither is
  /// sufficient in general: pausing on hover assumes the user notices and
  /// reaches it in time, and the accessible-navigation check only helps users
  /// who have assistive technology switched on — someone who simply reads
  /// slowly still loses the message. Use a [duration] only when the same
  /// information remains available elsewhere in the interface.
  /// [onDismissed] fires after the entry has been removed, whether the user
  /// dismissed it or [duration] elapsed. The widget has always carried this
  /// callback; `show` simply consumed it to remove the overlay entry and gave
  /// callers no way to learn the notification had gone — which is what a
  /// caller replacing `ScaffoldMessenger.showSnackBar(...).closed` needs.
  ///
  /// Bottom placements sit on top of an `ItBottomNav` whose page is current,
  /// the way a SnackBar sits above a bottom navigation bar; with none on
  /// screen they sit at the screen's edge.
  static OverlayEntry show({
    required BuildContext context,
    ItNotificationVariant variant = ItNotificationVariant.info,
    String? title,
    String? body,
    IconData? icon,
    bool dismissible = true,
    Duration? duration,
    ItNotificationPosition position = ItNotificationPosition.bottomRight,
    VoidCallback? onDismissed,
  }) {
    late final OverlayEntry entry;
    final padding = MediaQuery.of(context).padding;

    entry = OverlayEntry(
      builder: (context) {
        final child = ItNotification(
          variant: variant,
          title: title,
          body: body,
          icon: icon,
          dismissible: dismissible,
          duration: duration,
          position: position,
          onDismissed: () {
            entry.remove();
            onDismissed?.call();
          },
        );

        // Bottom placements sit on top of the app's bottom navigation while
        // its page is on screen — see BottomNavClearance. Without it, an
        // app-wide message covered the tab bar for as long as it showed, where
        // the SnackBar it replaced floated above it.
        return ValueListenableBuilder<double>(
          valueListenable: BottomNavClearance.height,
          builder: (context, clearance, _) =>
              _place(child, position, padding, clearance),
        );
      },
    );

    // `Overlay.of` only looks *up* the tree, so it cannot find the Overlay
    // from the Navigator's own context — which sits above the Overlay the
    // Navigator builds. That is exactly the context an app-wide messenger has
    // (`navigatorKey.currentContext`), and a real app's every success and error
    // message went through it and threw "No Overlay widget found". Navigator
    // recognises its own element, so its overlay is the fallback.
    final overlay =
        Overlay.maybeOf(context) ?? Navigator.maybeOf(context)?.overlay;
    if (overlay == null) {
      throw FlutterError.fromParts([
        ErrorSummary('ItNotification.show() found no Overlay to insert into.'),
        ErrorDescription(
          'The context must be inside a Navigator or an Overlay, or be the '
          "Navigator's own context (for example navigatorKey.currentContext).",
        ),
      ]);
    }
    overlay.insert(entry);
    return entry;
  }

  @override
  State<ItNotification> createState() => _ItNotificationState();
}

class _ItNotificationState extends State<ItNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();

    // WCAG 4.1.3 Status Messages. `Semantics(liveRegion: true)` alone is not
    // enough here: the node is created with its text already in place, and a
    // live region that has never *changed* is routinely not announced — on the
    // web the aria-live container has to exist before the content lands in it.
    // An explicit announcement is the only reliable way to get the message
    // read out, and it does so without moving focus.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final announcement = _announcementText();
      if (announcement.isEmpty) return;
      SemanticsService.sendAnnouncement(
        View.of(context),
        announcement,
        Directionality.of(context),
      );
      _startAutoDismiss();
    });
  }

  /// The text a screen reader should read when the notification appears.
  String _announcementText() {
    // The visible title is upper-cased purely presentationally; announce the
    // authored casing so AT does not spell it out letter by letter.
    return [widget.title, widget.body]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join('. ');
  }

  /// Starts (or restarts) the auto-dismiss countdown.
  ///
  /// WCAG 2.2.1 Timing Adjustable: no countdown runs while an assistive
  /// technology is active, because the user may still be working through the
  /// announcement when it would have expired.
  void _startAutoDismiss() {
    _autoDismissTimer?.cancel();
    final duration = widget.duration;
    if (duration == null) return;
    if (!mounted) return;
    if (MediaQuery.accessibleNavigationOf(context)) return;
    if (_held) return;
    _autoDismissTimer = Timer(duration, _dismiss);
  }

  /// Whether the user is currently hovering or focusing the notification.
  bool _held = false;

  /// WCAG 2.2.1: pointing at or focusing the notification pauses the
  /// countdown, so a slow reader is never raced by the timer.
  void _setHeld(bool value) {
    if (_held == value) return;
    _held = value;
    if (_held) {
      _autoDismissTimer?.cancel();
    } else {
      _startAutoDismiss();
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed?.call();
      }
    });
  }

  /// The accent colour used for the left border and the icon.
  ///
  /// Bootstrap Italia maps these explicitly — note that `info` resolves to the
  /// primary blue (`#06c`), not to the `$info` gray:
  ///   `.notification.with-icon.success { border-color: rgb(0,127.5,85) }`
  ///   `.notification.with-icon.error   { border-color: rgb(204,51,76.5) }`
  ///   `.notification.with-icon.info    { border-color: #06c }`
  ///   `.notification.with-icon.warning { border-color: rgb(153,91.8,0) }`
  Color _accentColor(BootstrapItaliaColorScheme colors) {
    return switch (widget.variant) {
      ItNotificationVariant.success => colors.success,
      ItNotificationVariant.danger => colors.danger,
      ItNotificationVariant.warning => colors.warning,
      ItNotificationVariant.info => colors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final accentColor = _accentColor(colors);
    final hasIcon = widget.icon != null;
    // `.notification.with-icon h5, .notification.with-icon p
    //    { margin-left: 1.778rem }`
    final textInset = hasIcon ? ItNotification._iconTextOffset : 0.0;

    final blocks = <Widget>[];
    if (widget.title != null) {
      blocks.add(
        Padding(
          padding: EdgeInsets.only(left: textInset),
          child: Text(
            widget.title!.toUpperCase(),
            // `text-transform: uppercase` is presentational only — keep the
            // original casing for assistive technology.
            semanticsLabel: widget.title,
            // `.notification h5 { font-size: .875rem; line-height: 1rem;
            //   font-weight: 700; color: hsl(0,0%,10%); letter-spacing: 0 }`
            style: TextStyle(
              fontFamily: BootstrapItaliaFontFamily.sansSerif,
              package: BootstrapItaliaFontFamily.package,
              fontSize: 14,
              height: 16 / 14,
              leadingDistribution: TextLeadingDistribution.even,
              // Bootstrap Italia: letter-spacing: normal. Set explicitly so the
              // ambient Material text theme cannot leak its 0.25px tracking.
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              // `.notification h5 { color: hsl(0, 0%, 10%) }` = --bs-body-color.
              color: colors.bodyColor,
            ),
          ),
        ),
      );
    }
    if (widget.body != null) {
      // `.notification p { margin-top: 1rem; font-size: .875rem;
      //   line-height: 1.5rem; color: hsl(210,33%,28%) }`
      // and `.notification p:last-child { margin-bottom: 0 }` — the close
      // button follows the paragraph, so the bottom margin only collapses on
      // non-dismissible notifications.
      if (blocks.isNotEmpty) {
        blocks.add(const SizedBox(height: BootstrapItaliaSpacing.space3));
      }
      blocks.add(
        Padding(
          padding: EdgeInsets.only(left: textInset),
          child: Text(
            widget.body!,
            style: const TextStyle(
              fontFamily: BootstrapItaliaFontFamily.sansSerif,
              package: BootstrapItaliaFontFamily.package,
              fontSize: 14,
              height: 24 / 14,
              leadingDistribution: TextLeadingDistribution.even,
              // Bootstrap Italia: letter-spacing: normal. Set explicitly so the
              // ambient Material text theme cannot leak its 0.25px tracking.
              letterSpacing: 0,
              fontWeight: FontWeight.w400,
              color: Color(0xFF30475F),
            ),
          ),
        ),
      );
      if (widget.dismissible) {
        blocks.add(const SizedBox(height: BootstrapItaliaSpacing.space3));
      }
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        // WCAG 2.2.1: hovering pauses the auto-dismiss countdown.
        child: MouseRegion(
          onEnter: (_) => _setHeld(true),
          onExit: (_) => _setHeld(false),
          // WCAG 2.2.1: so does keyboard focus landing anywhere inside.
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: _setHeld,
            // WCAG 4.1.3 Status Messages / 4.1.2 Name, Role, Value.
            //
            // The previous `Semantics(liveRegion: true)` used the default
            // `container: false`, so its annotation coalesced with the close
            // button's `button: true` and every Text below it. The entire card
            // collapsed into ONE node exposed as a *button* whose name was
            // "Titolo Messaggio Chiudi notifica" — a screen-reader user was
            // offered a button that read out the whole notification.
            //
            // `container` forces a node of its own and `explicitChildNodes`
            // stops the close button from being absorbed into it.
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              liveRegion: true,
              label: _announcementText(),
              // No `Material` above the card: it was transparent, so it painted
              // nothing, and the card's own decoration below already carries the
              // fill, radius, shadow and accent edge. The one thing it did
              // contribute — the ambient text style — is restored explicitly,
              // because a notification is shown in an OverlayEntry and so has no
              // other Material above it.
              child: ItDefaultTextStyle(
                child: Container(
                  width: widget.width,
                  decoration: BoxDecoration(
                    color: colors.white,
                    // `border-radius: 4px`, squared on the pair of corners the
                    // `…-fix` placements push against the window edge.
                    borderRadius: widget.position.borderRadius,
                    // `box-shadow: 0 0 1rem rgba(0,0,0,.15)`
                    boxShadow: const [
                      BoxShadow(color: Color(0x26000000), blurRadius: 16),
                    ],
                    // `.notification.with-icon { border-left: 4px solid }`,
                    // which `.left-fix` moves to the right edge — the left one
                    // is the side against the window.
                    border: hasIcon
                        ? Border(
                            left: widget.position.accentOnRight
                                ? BorderSide.none
                                : BorderSide(
                                    color: accentColor,
                                    width: ItNotification._accentWidth,
                                  ),
                            right: widget.position.accentOnRight
                                ? BorderSide(
                                    color: accentColor,
                                    width: ItNotification._accentWidth,
                                  )
                                : BorderSide.none,
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // The card's own node already carries the full text as its
                      // label, so the individual runs are excluded to stop AT
                      // reading the notification twice.
                      ExcludeSemantics(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ItNotification._padding,
                            ItNotification._padding,
                            ItNotification._paddingRight,
                            ItNotification._padding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: blocks,
                          ),
                        ),
                      ),
                      if (hasIcon)
                        Positioned(
                          left: ItNotification._iconLeft,
                          top: ItNotification._iconTop,
                          // Decorative: the variant is already conveyed by the
                          // message text, so the glyph stays out of the AT tree.
                          child: ExcludeSemantics(
                            child: Icon(
                              widget.icon,
                              color: accentColor,
                              size: ItNotification._iconSize,
                            ),
                          ),
                        ),
                      if (widget.dismissible)
                        Positioned(
                          right: ItNotification._closeRight,
                          top: ItNotification._closeTop,
                          child: _NotificationCloseButton(
                            onPressed: _dismiss,
                            color: colors.secondary,
                          ),
                        ),
                    ],
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

/// The `.notification-close` button.
///
/// A [GestureDetector] cannot be reached with the keyboard, so before this the
/// only way to dismiss a persistent notification was a mouse or a touch
/// screen (WCAG 2.1.1 Keyboard). The painted box is already 32x32 —
/// `.notification.dismissable .notification-close { width: 32px; height: 32px }`
/// — which clears the 24x24 minimum of WCAG 2.5.8 Target Size, so only the
/// keyboard path needed fixing.
class _NotificationCloseButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;

  const _NotificationCloseButton({
    required this.onPressed,
    required this.color,
  });

  @override
  State<_NotificationCloseButton> createState() =>
      _NotificationCloseButtonState();
}

class _NotificationCloseButtonState extends State<_NotificationCloseButton> {
  bool _focused = false;

  void _setFocused(bool value) {
    if (_focused != value) setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: true,
        label: ItLocalizations.of(context).closeNotification,
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
          // WCAG 2.4.7 Focus Visible — the design system's own indicator,
          // painted only while the control holds keyboard focus, so the
          // default rendering is byte-for-byte what it was.
          child: ItFocusRing(
            visible: _focused,
            child: GestureDetector(
              onTap: widget.onPressed,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: ItNotification._closeSize,
                height: ItNotification._closeSize,
                child: Center(
                  // The Bootstrap Italia close glyph paints ~12px
                  // wide inside its 32px `.icon` box.
                  child: Icon(
                    BootstrapItaliaIcons.it_close,
                    color: widget.color,
                    size: ItNotification._closeSize,
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
