import 'package:flutter/material.dart';

import '../../theme/bootstrap_italia_theme_data.dart';
import '../../theme/theme_extensions.dart';
import '../../tokens/borders.dart';
import '../../tokens/spacing.dart';

/// A Bootstrap Italia card component.
///
/// A flexible content container with optional image, category, title,
/// body, signature, and footer.
///
/// ```dart
/// ItCard(
///   title: 'Titolo della card',
///   body: Text('Descrizione del contenuto.'),
///   category: ItCardCategory(label: 'Categoria'),
///   onTap: () {},
/// )
/// ```
class ItCard extends StatelessWidget {
  /// Optional image at the top of the card.
  final Widget? image;

  /// Optional category label.
  final ItCardCategory? category;

  /// The card title.
  final String? title;

  /// Optional subtitle below the title.
  final String? subtitle;

  /// The card body content.
  final Widget? body;

  /// Optional signature/author text.
  final String? signature;

  /// Optional footer widget.
  final Widget? footer;

  /// Optional colored top border.
  final Color? borderTopColor;

  /// Whether to use horizontal layout (image left, content right).
  final bool horizontal;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Custom padding for the card body area.
  final EdgeInsetsGeometry? padding;

  /// Creates a Bootstrap Italia card.
  const ItCard({
    super.key,
    this.image,
    this.category,
    this.title,
    this.subtitle,
    this.body,
    this.signature,
    this.footer,
    this.borderTopColor,
    this.horizontal = false,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final cardContent =
        horizontal ? _buildHorizontal(colors) : _buildVertical(colors);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.white,
          border: Border.all(color: const Color(0xFFC4C7CA)),
          borderRadius:
              BorderRadius.circular(BootstrapItaliaBorders.radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (borderTopColor != null)
              Container(height: 6, color: borderTopColor),
            cardContent,
          ],
        ),
      ),
    );
  }

  Widget _buildVertical(BootstrapItaliaColorScheme colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (image != null) image!,
        _buildBody(colors),
        if (footer != null) ...[
          Divider(height: 1, color: colors.gray300),
          footer!,
        ],
      ],
    );
  }

  Widget _buildHorizontal(BootstrapItaliaColorScheme colors) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image != null)
            SizedBox(
              width: 160,
              child: image!,
            ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBody(colors),
                if (footer != null) ...[
                  Divider(height: 1, color: colors.gray300),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BootstrapItaliaColorScheme colors) {
    final effectivePadding =
        padding ?? const EdgeInsets.all(BootstrapItaliaSpacing.space3);

    return Padding(
      padding: effectivePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (category != null) ...[
            category!,
            const SizedBox(height: BootstrapItaliaSpacing.space2),
          ],
          if (title != null)
            Text(
              title!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.neutral1,
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: BootstrapItaliaSpacing.space1),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondary,
              ),
            ),
          ],
          if (body != null) ...[
            const SizedBox(height: BootstrapItaliaSpacing.space2),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 14,
                color: colors.secondary,
                height: 1.5,
              ),
              child: body!,
            ),
          ],
          if (signature != null) ...[
            const SizedBox(height: BootstrapItaliaSpacing.space2),
            Text(
              signature!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.neutral1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A category label for [ItCard].
///
/// Displays a styled text label, typically shown above the card title.
class ItCardCategory extends StatelessWidget {
  /// The category text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Creates a card category label.
  const ItCardCategory({
    super.key,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: colors.secondary),
          const SizedBox(width: 4),
        ],
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.secondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
