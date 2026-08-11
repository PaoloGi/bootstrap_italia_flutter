import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../components/spinner/progress_spinner.dart';
import '../l10n/it_localizations.dart';
import '../theme/bootstrap_italia_theme_data.dart';
import '../theme/it_default_text_style.dart';
import '../theme/theme_extensions.dart';
import '../tokens/spacing.dart';
import 'it_field_support.dart';
import 'it_form_metrics.dart';

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
/// Set [large] to `true` for the enlarged variant used in hero/header areas
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
  ///
  /// Named for the concept, not for the CSS class: `ItChip.large` and
  /// `ItButtonSize.large` describe the same "one size up" idea, and it once had
  /// three spellings (`big`/`large`/`lg`), which was two too many. The
  /// stylesheet's own `-big` suffix stays in the citation above, where it
  /// belongs.
  final bool large;

  /// Text shown when search returns no results.
  ///
  /// Defaults to [ItLocalizations.noResults] — `'Nessun risultato'` with no
  /// delegate installed.
  final String? noResultsText;

  /// Optional external text editing controller.
  final TextEditingController? controller;

  /// Optional external focus node.
  final FocusNode? focusNode;

  /// Whether a value must be chosen before the form can be submitted.
  final bool required;

  /// `.form-text` — instruction shown below the field.
  final String? helperText;

  /// `.form-feedback` — validation message shown below the field.
  ///
  /// It is also carried on the field's own semantics node, so a screen reader
  /// hears it as part of the field (WCAG 3.3.1 Error Identification).
  final String? errorText;

  /// Validation state tinting the field's bottom border. [errorText] implies
  /// [ItValidationState.danger].
  final ItValidationState? validationState;

  /// Accessible name, when it must differ from the visible [label].
  final String? semanticLabel;

  /// Builds the message announced when suggestions arrive (WCAG 4.1.3).
  ///
  /// Defaults to [ItLocalizations.searchResults], which selects a plural form
  /// rather than interpolating one template — the old default said
  /// "1 risultato disponibile" correctly only because it special-cased 1 by
  /// hand, and German and French inflect the noun as well.
  final String Function(int count)? resultsAnnouncement;

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
    this.large = false,
    this.noResultsText,
    this.controller,
    this.focusNode,
    this.required = false,
    this.helperText,
    this.errorText,
    this.validationState,
    this.semanticLabel,
    this.resultsAnnouncement,
  });

  @override
  State<ItAutocomplete<T>> createState() => _ItAutocompleteState<T>();
}

class _ItAutocompleteState<T extends Object> extends State<ItAutocomplete<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  final LayerLink _layerLink = LayerLink();

  /// The field's own box, which is no longer this State's render object once
  /// `helperText`/`errorText` add a line beneath it. Measuring the outer box
  /// would drop the suggestion list a helper-line's height too low.
  final GlobalKey _controlKey = GlobalKey();

  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;
  List<T> _suggestions = [];
  bool _isLoading = false;
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
    ItFieldValidation.announce(context, oldWidget.errorText, widget.errorText);
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
      _highlightedIndex = -1;
      _showSuggestions();
      // WCAG 4.1.3 Status Messages: the list appears without taking focus, so
      // a screen-reader user is otherwise never told anything happened.
      if (mounted) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          (widget.resultsAnnouncement ??
              ItLocalizations.of(context).searchResults)(results.length),
          Directionality.of(context),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuggestions() {
    _removeOverlay();
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    // The field's `expanded` state is derived from the overlay, so opening and
    // closing has to rebuild it (WCAG 4.1.2).
    if (mounted) setState(() {});
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _closeSuggestions() {
    final wasOpen = _overlayEntry != null;
    _removeOverlay();
    if (wasOpen && mounted) setState(() {});
  }

  void _selectOption(T option) {
    _controller.text = widget.displayStringForOption(option);
    _closeSuggestions();
    widget.onSelected?.call(option);
  }

  /// Keys the open suggestion list consumes, so they are not also passed on to
  /// the text field or to the enclosing scroll view.
  static final Set<LogicalKeyboardKey> _handledKeys = {
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.escape,
  };

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;
    if (_overlayEntry == null) return;

    // WCAG 2.1.2 No Keyboard Trap: Escape always dismisses the list, including
    // the "no results" panel, which has no items to move through.
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeSuggestions();
      return;
    }

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
    }
  }

  OverlayEntry _buildOverlay() {
    final renderBox =
        _controlKey.currentContext!.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final colors = resolveColorScheme(context);
    final fontSize = widget.large ? 20.0 : 16.0;

    return OverlayEntry(
      builder: (context) {
        final hasSuggestions = _suggestions.isNotEmpty;

        return Stack(
          children: [
            // Dismiss layer
            // Pointer-only dismissal; Escape is the keyboard equivalent.
            ExcludeSemantics(
              child: GestureDetector(
                onTap: _closeSuggestions,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, size.height + 4),
              // No `Material` above the list: it was `elevation: 0` in the same
              // white the Container below already paints, so it added a
              // redundant surface and nothing else. The text style it did
              // supply is restored explicitly — this panel is an overlay entry,
              // so it has no other Material to inherit one from.
              child: ItDefaultTextStyle(
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
                          label: ItLocalizations.of(context).suggestions,
                          explicitChildNodes: true,
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _suggestions.length,
                            // A 1px separator between suggestions. Decorative,
                            // so it carries no semantics — and a plain box
                            // rather than Material's Divider, which resolves
                            // its geometry through DividerThemeData.
                            separatorBuilder: (_, __) => ExcludeSemantics(
                              child: SizedBox(
                                height: 1,
                                child: ColoredBox(
                                  color: colors.secondary.withAlpha(51),
                                ),
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final option = _suggestions[index];
                              final isHighlighted = index == _highlightedIndex;

                              if (widget.itemBuilder != null) {
                                return Semantics(
                                  button: true,
                                  selected: isHighlighted,
                                  label: widget.displayStringForOption(option),
                                  onTap: () => _selectOption(option),
                                  child: GestureDetector(
                                    onTap: () => _selectOption(option),
                                    child: widget.itemBuilder!(
                                        context, option, isHighlighted),
                                  ),
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
                      // WCAG 4.1.3 Status Messages: an empty result set is a
                      // status, so it is announced without taking focus.
                      // (`SemanticsRole.status` cannot be combined with
                      // `liveRegion` — the framework rejects the pair — and
                      // the live region is what actually reaches AT.)
                      : Semantics(
                          liveRegion: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: BootstrapItaliaSpacing.space2,
                            ),
                            child: Text(
                              widget.noResultsText ??
                                  ItLocalizations.of(context).noResults,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: colors.secondary,
                              ),
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
    // Not `_closeSuggestions`: the element is already defunct here, so its
    // `setState` would assert.
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  /// Bootstrap Italia floats the label (`label.active`) whenever the control
  /// is focused, holds a value, or shows a placeholder.
  bool get _labelIsFloating =>
      _isFocused || _controller.text.isNotEmpty || widget.hint != null;

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    // .autocomplete-wrapper-big scales the control up; the default variant is
    // a plain .form-control.
    final fontSize = widget.large ? 20.0 : ItFormMetrics.fontSize;
    final lineHeight = widget.large ? 30.0 : ItFormMetrics.textLineHeight;
    final controlHeight = widget.large ? 56.0 : ItFormMetrics.controlHeight;
    final floating = _labelIsFloating;
    final validation =
        ItFieldValidation.effective(widget.errorText, widget.validationState);

    // WCAG 2.1.1 Keyboard: this used to be a `KeyboardListener` whose focus
    // node was built fresh on every rebuild and never focused, so it received
    // no key events at all — the arrow/Enter/Escape handling below was dead.
    // A non-focusable `Focus` sits in the focus chain above the field instead,
    // which is what makes the events bubble to it.
    final textField = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
        return _handledKeys.contains(event.logicalKey) && _overlayEntry != null
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      },
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onTextChanged,
        enabled: widget.enabled,
        cursorColor: colors.primary,
        // .form-control { color: hsl(0,0%,10%) } — the bodyColor token.
        style: ItFormMetrics.textStyle(
          fontSize: fontSize,
          lineHeight: lineHeight,
          color: ItFormMetrics.textColor(colors),
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: floating ? widget.hint : null,
          hintStyle: ItFormMetrics.textStyle(
            fontSize: fontSize,
            lineHeight: lineHeight,
            color: ItFormMetrics.borderColor,
          ),
        ),
      ),
    );

    // WCAG 1.3.1 / 3.3.2 / 4.1.2: as in [ItInput], the visible label is a
    // sibling `Text` and gives the field no accessible name on its own.
    // `MergeSemantics` folds the name — and the combobox role and expanded
    // state that describe the suggestion list — onto the field's own node.
    //
    // Not `SemanticsRole.comboBox`: the value exists in the enum but Flutter's
    // debug role checks reject it as unimplemented, so `expanded` on the text
    // field is what carries "this field has a suggestion list" for now.
    final labelledField = MergeSemantics(
      child: Semantics(
        label: widget.semanticLabel ?? widget.label,
        isRequired: widget.required,
        // WCAG 3.3.1 / 3.3.2: the instruction and the validation message are
        // painted below the field, so they are carried here too — as in
        // [ItInput], which this control otherwise mirrors.
        hint: ItFieldValidation.hint(widget.errorText, widget.helperText),
        validationResult: ItFieldValidation.result(validation),
        expanded: _overlayEntry != null,
        child: textField,
      ),
    );

    final control = DecoratedBox(
      // .form-control:focus { box-shadow: 0 0 0 .25rem rgba(0,102,204,.25) }
      // — rgba() of the primary token, so it comes from the scheme.
      decoration: BoxDecoration(
        boxShadow: _isFocused && widget.enabled
            ? [
                BoxShadow(
                  color: ItFormMetrics.focusRingColor(colors),
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: SizedBox(
        height: controlHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (!widget.enabled)
              const Positioned.fill(
                child: ColoredBox(color: ItFormMetrics.disabledBackground),
              ),
            // Excluded: re-attached to the field itself above, which is the
            // association assistive technology needs.
            if (widget.label != null)
              Positioned(
                left: widget.icon != null && !floating
                    ? ItFormMetrics.inputGroupLabelLeft
                    : 0,
                top: floating ? ItFormMetrics.activeLabelOffset : 0,
                child: ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ItFormMetrics.horizontalPadding,
                    ),
                    child: Text(
                      widget.label!,
                      maxLines: 1,
                      // .form-group label.active { color: hsl(0,0%,10%) } is
                      // the bodyColor token; the resting label's
                      // hsl(210,17%,44%) is the grey, not the secondary accent.
                      style: floating
                          ? ItFormMetrics.textStyle(
                              fontSize: ItFormMetrics.activeLabelFontSize,
                              lineHeight: ItFormMetrics.labelLineHeight,
                              fontWeight: FontWeight.w600,
                              color: ItFormMetrics.textColor(colors),
                            )
                          : ItFormMetrics.textStyle(
                              fontSize: ItFormMetrics.labelFontSize,
                              lineHeight: ItFormMetrics.labelLineHeight,
                              color: ItFormMetrics.borderColor,
                            ),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Row(
                children: [
                  // .input-group .input-group-text { min-width: 40px }
                  if (widget.icon != null)
                    SizedBox(
                      width: ItFormMetrics.inputGroupTextWidth,
                      // WCAG 1.1.1: decorative — the field is already named.
                      child: ExcludeSemantics(
                        child: Center(
                          child: Icon(
                            widget.icon,
                            size: widget.large ? 28.0 : ItFormMetrics.iconSize,
                            color: ItFormMetrics.borderColor,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ItFormMetrics.horizontalPadding,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: labelledField,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Semantics(
                        label: ItLocalizations.of(context).searching,
                        // As in the button, this is an affix inside a field
                        // rather than a standalone `.progress-spinner`, so the
                        // CSS track ring is suppressed: at 16px it would read
                        // as a solid grey ring rather than a track.
                        child: ItProgressSpinner(
                          diameter: 16,
                          strokeWidth: 2,
                          color: colors.primary,
                          trackColor: const Color(0x00000000),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // input[type=text] { border-bottom: 1px solid hsl(210,17%,44%) }
            // .form-control.is-invalid { border-color: rgb(204,51,76.5) }
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: ItFormMetrics.borderWidth,
              child: ColoredBox(
                color: validation == null
                    ? ItFormMetrics.borderColor
                    : ItFieldValidation.color(colors, validation),
              ),
            ),
          ],
        ),
      ),
    );

    // WCAG 3.3.1 / 3.3.2: both lines are excluded from the semantics tree by
    // [ItFieldSupport] and carried on the field's own node as its hint above.
    //
    // The link target stays *inside* the supporting text, and the suggestion
    // list measures [_controlKey] rather than this State's own render object:
    // with a helper line present the two are no longer the same box, and
    // anchoring to the outer one would drop the list a helper-line's height
    // below the field it belongs to.
    return ItFieldSupport(
      helperText: widget.helperText,
      errorText: widget.errorText,
      child: CompositedTransformTarget(
        key: _controlKey,
        link: _layerLink,
        child: control,
      ),
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
    // Not `SemanticsRole.listItem`: the framework requires such a node's
    // *direct* parent to carry `SemanticsRole.list`, and the scrollable's own
    // node sits between them.
    return Semantics(
      button: true,
      // The keyboard cursor is the option's selected state, so a screen reader
      // follows the arrow keys.
      selected: widget.isHighlighted,
      label: widget.text,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: _active ? widget.colors.primary : null,
            // WCAG 2.5.8: 4px of padding either side of a >=24px line box
            // clears the 24x24 minimum, and the row spans the list's width.
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: BootstrapItaliaSpacing.space1,
            ),
            // The wrapper already names the option.
            child: ExcludeSemantics(
              child: widget.highlightMatch
                  ? _HighlightedText(
                      text: widget.text,
                      query: widget.query,
                      textColor: _active
                          ? widget.colors.white
                          : widget.colors.bodyColor,
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
