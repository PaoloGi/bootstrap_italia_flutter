import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/spacing.dart';

/// Size presets for [ItModal].
///
/// Each value maps to a maximum width that the modal dialog will occupy.
/// Values match Bootstrap Italia's `$modal-sm`, `$modal-md`, `$modal-lg`,
/// `$modal-xl` SCSS variables.
enum ItModalSize {
  /// Small modal: 300px max width.
  sm(300),

  /// Medium modal (default): 500px max width.
  md(500),

  /// Large modal: 800px max width.
  lg(800),

  /// Extra-large modal: 1140px max width.
  xl(1140);

  /// The maximum width in logical pixels for this size.
  final double maxWidth;

  const ItModalSize(this.maxWidth);
}

/// A Bootstrap Italia modal dialog.
///
/// Displays a dialog overlay with optional title, icon, body content,
/// and action buttons. Follows the Bootstrap Italia design system.
///
/// Use the static [show] method to present the modal:
///
/// ```dart
/// ItModal.show(
///   context: context,
///   size: ItModalSize.md,
///   title: 'Conferma operazione',
///   icon: Icons.warning,
///   body: Text('Sei sicuro?'),
///   actions: [
///     ItButton(
///       variant: ItButtonVariant.secondary,
///       child: Text('Annulla'),
///       onPressed: () => Navigator.pop(context),
///     ),
///     ItButton(
///       variant: ItButtonVariant.primary,
///       child: Text('Conferma'),
///       onPressed: () {},
///     ),
///   ],
/// );
/// ```
class ItModal extends StatelessWidget {
  /// Optional title displayed in the modal header.
  final String? title;

  /// Optional icon displayed before the title.
  ///
  /// When set, the modal uses the Bootstrap Italia alert-modal layout
  /// where the icon is displayed at the start of the header row.
  final IconData? icon;

  /// The main content of the modal.
  final Widget body;

  /// Action buttons displayed in the modal footer.
  ///
  /// Typically a list of [ItButton] widgets. Defaults to an empty list.
  final List<Widget> actions;

  /// The size preset controlling the modal's maximum width.
  ///
  /// Defaults to [ItModalSize.md].
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

  /// Custom barrier (overlay) color.
  ///
  /// If null, defaults to 80% opaque black per Bootstrap Italia's
  /// `$modal-backdrop-opacity: 0.8`.
  final Color? barrierColor;

  /// Creates a Bootstrap Italia modal widget.
  ///
  /// Prefer using [ItModal.show] to display the modal as a dialog.
  const ItModal({
    super.key,
    this.title,
    this.icon,
    required this.body,
    this.actions = const [],
    this.size = ItModalSize.md,
    this.scrollable = false,
    this.dismissible = true,
    this.barrierColor,
  });

  /// Displays an [ItModal] as a dialog.
  ///
  /// Returns a [Future] that completes with the value passed to
  /// [Navigator.pop] when the dialog is closed.
  ///
  /// When [centered] is true (default), the modal is vertically centered.
  /// When false, it is positioned near the top of the screen.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    IconData? icon,
    required Widget body,
    List<Widget> actions = const [],
    ItModalSize size = ItModalSize.md,
    bool scrollable = false,
    bool centered = true,
    bool dismissible = true,
    Color? barrierColor,
  }) {
    final colors = resolveColorScheme(context);
    // Bootstrap Italia: $modal-backdrop-opacity: 0.8
    final effectiveBarrierColor =
        barrierColor ?? colors.black.withAlpha(204);

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: effectiveBarrierColor,
      // Bootstrap Italia: $modal-transition: transform 0.3s ease-out
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
          barrierColor: barrierColor,
        );

        return SafeArea(
          child: centered
              ? Center(child: modal)
              : Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: BootstrapItaliaSpacing.space5,
                    ),
                    child: modal,
                  ),
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

    Widget bodyContent = body;
    if (scrollable) {
      bodyContent = SingleChildScrollView(child: bodyContent);
    }

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: Material(
        type: MaterialType.transparency,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.maxWidth,
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: BootstrapItaliaSpacing.space3,
            ),
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadius.circular(
                BootstrapItaliaBorders.radiusLg,
              ),
              // Bootstrap Italia: $dialog-shadow: 0 2px 10px 0 rgba(0,0,0,0.1)
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                if (hasHeader)
                  Padding(
                    // Bootstrap Italia: $modal-inner-padding: 1.5rem (24px)
                    padding: const EdgeInsets.all(
                      BootstrapItaliaSpacing.space4,
                    ),
                    child: Row(
                      crossAxisAlignment: icon != null
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            // Bootstrap Italia: $modal-icon-color: $primary
                            color: colors.primary,
                            size: 24,
                          ),
                          // $modal-icon-distance: $v-gap * 2 = 16px
                          const SizedBox(
                            width: BootstrapItaliaSpacing.space3,
                          ),
                        ],
                        Expanded(
                          child: Text(
                            title!,
                            style: TextStyle(
                              // Bootstrap Italia: modal-title h5
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              // $modal-heading-color: $color-text-base
                              color: colors.bodyColor,
                            ),
                          ),
                        ),
                        if (dismissible)
                          _CloseButton(
                            color: colors.bodyColor,
                            onPressed: () => Navigator.pop(context),
                          ),
                      ],
                    ),
                  ),

                // Body
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      BootstrapItaliaSpacing.space4,
                      hasHeader ? 0 : BootstrapItaliaSpacing.space4,
                      BootstrapItaliaSpacing.space4,
                      BootstrapItaliaSpacing.space4,
                    ),
                    child: bodyContent,
                  ),
                ),

                // Footer
                if (hasFooter)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      BootstrapItaliaSpacing.space4,
                      0,
                      BootstrapItaliaSpacing.space4,
                      BootstrapItaliaSpacing.space4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      // $modal-footer-margin-between: 0.5rem (8px)
                      children: _spaceActions(actions),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Intersperses [SizedBox] gaps between action widgets.
  static List<Widget> _spaceActions(List<Widget> actions) {
    if (actions.length <= 1) return actions;
    return [
      for (int i = 0; i < actions.length; i++) ...[
        if (i > 0)
          const SizedBox(width: BootstrapItaliaSpacing.space2),
        actions[i],
      ],
    ];
  }
}

/// Internal close button used in the modal header.
class _CloseButton extends StatelessWidget {
  final Color color;
  final VoidCallback onPressed;

  const _CloseButton({
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chiudi finestra modale',
      button: true,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(BootstrapItaliaSpacing.space1),
          child: Icon(
            Icons.close,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }
}
