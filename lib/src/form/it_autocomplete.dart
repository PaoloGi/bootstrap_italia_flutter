import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/bootstrap_italia_theme_data.dart';
import '../theme/theme_extensions.dart';
import '../tokens/spacing.dart';

/// A Bootstrap Italia autocomplete input.
///
/// Provides a text input with async suggestions displayed in a dropdown.
/// Follows Bootstrap Italia's `.autocomplete` pattern with:
/// - Underline-only input border (matching [ItInput])
/// - Search icon positioned outside the field (`.autocomplete-icon`)
/// - Dropdown with BI shadow and item separators
/// - Keyboard navigation (arrow keys, Enter, Escape)
/// - "No results" state
///
/// Set [big] to `true` for the enlarged variant used in hero/header areas
/// (`.autocomplete-wrapper-big`).
///
/// ```dart
/// ItAutocomplete<City>(
///   label: 'Città',
///   icon: Icons.search,
///   onSearch: (query) async => api.searchCities(query),
///   displayStringForOption: (city) => city.name,
///   onSelected: (city) => print(city),
/// )
/// ```
class ItAutocomplete<T extends Object> extends StatefulWidget {
  /// The floating label text.
  final String? label;

  /// Hint text when empty.
  final String? hint;

  /// Called to fetch suggestions for the given query.
  final Future<List<T>> Function(String query) onSearch;

  /// Converts an option to its display string.
  final String Function(T option) displayStringForOption;

  /// Called when an option is selected.
  final ValueChanged<T>? onSelected;

  /// Custom widget builder for each suggestion.
  final Widget Function(BuildContext context, T option, bool isHighlighted)?
      itemBuilder;

  /// Debounce duration before triggering search.
  final Duration debounce;

  /// Whether to highlight matching text in suggestions.
  final bool highlightMatch;

  /// Minimum query length before searching.
  final int minQueryLength;

  /// Leading icon displayed outside the field (`.autocomplete-icon`).
  final IconData? icon;

  /// Whether the input is enabled.
  final bool enabled;

  /// Enlarged variant for hero/header areas (`.autocomplete-wrapper-big`).
  final bool big;

  /// Text shown when search returns no results.
  final String noResultsText;

  /// Optional external text editing controller.
  final TextEditingController? controller;

  /// Optional external focus node.
  final FocusNode? focusNode;

  /// Creates a Bootstrap Italia autocomplete.
  const ItAutocomplete({
    super.key,
    this.label,
    this.hint,
    required this.onSearch,
    required this.displayStringForOption,
    this.onSelected,
    this.itemBuilder,
    this.debounce = const Duration(milliseconds: 300),
    this.highlightMatch = true,
    this.minQueryLength = 1,
    this.icon,
    this.enabled = true,
    this.big = false,
    this.noResultsText = 'Nessun risultato',
    this.controller,
    this.focusNode,
  });

  @override
  State<ItAutocomplete<T>> createState() => _ItAutocompleteState<T>();
}

class _ItAutocompleteState<T extends Object>
    extends State<ItAutocomplete<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  final LayerLink _layerLink = LayerLink();
  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;
  List<T> _suggestions = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isFocused = false;
  String _lastQuery = '';
  int _highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant ItAutocomplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? TextEditingController();
      _ownsController = widget.controller == null;
    }
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (_ownsFocusNode) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (!_focusNode.hasFocus) {
      // Delay to allow tap on overlay items to register
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          _closeSuggestions();
        }
      });
    }
  }

  void _onTextChanged(String query) {
    _lastQuery = query;
    _debounceTimer?.cancel();

    if (query.length < widget.minQueryLength) {
      _closeSuggestions();
      _hasSearched = false;
      return;
    }

    _debounceTimer = Timer(widget.debounce, () => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final results = await widget.onSearch(query);
      if (!mounted || _lastQuery != query) return;

      _suggestions = results;
      _hasSearched = true;
      _highlightedIndex = -1;
      _showSuggestions();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuggestions() {
    _closeSuggestions();
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _hasSearched = false;
  }

  void _selectOption(T option) {
    _controller.text = widget.displayStringForOption(option);
    _closeSuggestions();
    widget.onSelected?.call(option);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;
    if (_overlayEntry == null) return;

    final itemCount = _suggestions.length;
    if (itemCount == 0) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1).clamp(0, itemCount - 1);
      });
      _overlayEntry?.markNeedsBuild();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _highlightedIndex = (_highlightedIndex - 1).clamp(0, itemCount - 1);
      });
      _overlayEntry?.markNeedsBuild();
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_highlightedIndex >= 0 && _highlightedIndex < itemCount) {
        _selectOption(_suggestions[_highlightedIndex]);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeSuggestions();
    }
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final colors = resolveColorScheme(context);
    final fontSize = widget.big ? 20.0 : 16.0;

    return OverlayEntry(
      builder: (context) {
        final hasSuggestions = _suggestions.isNotEmpty;

        return Stack(
          children: [
            // Dismiss layer
            GestureDetector(
              onTap: _closeSuggestions,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 0,
                color: colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.white,
                    // BI: rgba(0,0,0,0.256863) 0px 2px 6px
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x41000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxWidth: size.width,
                    maxHeight: 342, // BI spec
                  ),
                  child: hasSuggestions
                      ? Semantics(
                          label: 'Suggerimenti',
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _suggestions.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              thickness: 1,
                              color: colors.secondary.withAlpha(51),
                            ),
                            itemBuilder: (context, index) {
                              final option = _suggestions[index];
                              final isHighlighted =
                                  index == _highlightedIndex;

                              if (widget.itemBuilder != null) {
                                return GestureDetector(
                                  onTap: () => _selectOption(option),
                                  child: widget.itemBuilder!(
                                      context, option, isHighlighted),
                                );
                              }

                              final text =
                                  widget.displayStringForOption(option);

                              return _AutocompleteItem(
                                text: text,
                                query: _lastQuery,
                                isHighlighted: isHighlighted,
                                highlightMatch: widget.highlightMatch,
                                fontSize: fontSize,
                                colors: colors,
                                onTap: () => _selectOption(option),
                              );
                            },
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: BootstrapItaliaSpacing.space2,
                          ),
                          child: Text(
                            widget.noResultsText,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: colors.secondary,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _closeSuggestions();
    _focusNode.removeListener(_onFocusChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final fontSize = widget.big ? 20.0 : 16.0;
    final iconSize = widget.big ? 28.0 : 24.0;

    // BI: $input-border: $gray-secondary
    final borderColor = colors.secondary;
    final focusBorderColor = colors.primary;

    // BI: label turns primary on focus, muted gray when disabled
    final Color labelColor;
    if (!widget.enabled) {
      labelColor = colors.gray400;
    } else if (_isFocused) {
      labelColor = colors.primary;
    } else {
      labelColor = colors.bodyColor;
    }
    final floatingLabelColor = labelColor;

    final hasInputGroup = widget.icon != null;

    final textField = KeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKeyEvent: _handleKeyEvent,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onTextChanged,
        enabled: widget.enabled,
        style: TextStyle(
          fontSize: fontSize,
          color: widget.enabled ? colors.bodyColor : colors.gray400,
        ),
        decoration: InputDecoration(
          // BI disabled: gray fill
          filled: !widget.enabled,
          fillColor: colors.gray200,
          labelText: widget.label,
          hintText: widget.hint,
          labelStyle: TextStyle(
            color: labelColor,
            fontSize: fontSize,
          ),
          floatingLabelStyle: TextStyle(
            color: floatingLabelColor,
            fontSize: widget.big ? 16.0 : 14.0,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelBehavior: widget.enabled
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
          hintStyle: TextStyle(
            color: colors.secondary,
            fontSize: fontSize,
          ),
          suffixIcon: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
          // BI: underline-only borders
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: focusBorderColor, width: 2),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.black),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: BootstrapItaliaSpacing.space2,
            vertical: widget.big
                ? BootstrapItaliaSpacing.space3
                : BootstrapItaliaSpacing.space2,
          ),
        ),
      ),
    );

    final inputWidget = hasInputGroup
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: BootstrapItaliaSpacing.space2,
                  bottom: BootstrapItaliaSpacing.space2,
                ),
                child: Icon(
                  widget.icon,
                  size: iconSize,
                  color: !widget.enabled
                      ? colors.gray400
                      : colors.secondary,
                ),
              ),
              Expanded(child: textField),
            ],
          )
        : textField;

    return CompositedTransformTarget(
      link: _layerLink,
      child: inputWidget,
    );
  }
}

/// A single autocomplete suggestion item with hover highlighting.
class _AutocompleteItem extends StatefulWidget {
  final String text;
  final String query;
  final bool isHighlighted;
  final bool highlightMatch;
  final double fontSize;
  final BootstrapItaliaColorScheme colors;
  final VoidCallback onTap;

  const _AutocompleteItem({
    required this.text,
    required this.query,
    required this.isHighlighted,
    required this.highlightMatch,
    required this.fontSize,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_AutocompleteItem> createState() => _AutocompleteItemState();
}

class _AutocompleteItemState extends State<_AutocompleteItem> {
  bool _isHovered = false;

  bool get _active => _isHovered || widget.isHighlighted;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: _active ? widget.colors.primary : null,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: BootstrapItaliaSpacing.space1,
          ),
          child: widget.highlightMatch
              ? _HighlightedText(
                  text: widget.text,
                  query: widget.query,
                  textColor:
                      _active ? widget.colors.white : widget.colors.bodyColor,
                  fontSize: widget.fontSize,
                )
              : Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    color: _active
                        ? widget.colors.white
                        : widget.colors.bodyColor,
                  ),
                ),
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final Color textColor;
  final double fontSize;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.textColor,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: TextStyle(fontSize: fontSize, color: textColor));
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index < 0) {
      return Text(text, style: TextStyle(fontSize: fontSize, color: textColor));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
        ),
        children: [
          if (index > 0) TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (index + query.length < text.length)
            TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}
