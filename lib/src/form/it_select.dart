import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/it_localizations.dart';
import '../a11y/it_activatable.dart';
import '../a11y/it_focus_ring.dart';
import '../theme/it_default_text_style.dart';
import '../theme/theme_extensions.dart';
import '../tokens/borders.dart';
import '../tokens/spacing.dart';
import '../utilities/interaction_states.dart';
import 'it_field_support.dart';
import 'it_form_metrics.dart';

/// A single option within an [ItSelect].
class ItSelectItem<T> {
  /// The option value.
  final T value;

  /// The display label.
  final String label;

  /// `<optgroup label="…">` — the caption this option is filed under.
  ///
  /// The open list prints the caption once, above the first option carrying it,
  /// and again whenever the value *changes* — which is how `<optgroup>` itself
  /// works. Options of one group therefore have to be adjacent in [items], as
  /// they are in the markup; scattering them produces the caption more than
  /// once, exactly as scattered `<option>` elements between two `<optgroup>`
  /// tags would.
  ///
  /// Null on every option is the ungrouped select, which prints no captions at
  /// all.
  final String? group;

  /// Whether this option is enabled. Same polarity as [ItSelect.enabled], so a
  /// select and its items cannot read in opposite directions.
  final bool enabled;

  /// Creates a select item.
  const ItSelectItem({
    required this.value,
    required this.label,
    this.group,
    this.enabled = true,
  });
}

/// A Bootstrap Italia select dropdown (`.select-wrapper > select`).
///
/// The closed control is 40px tall with a 1px bottom border only, its value
/// rendered in 16px bold, and a chevron on the right. As on the web the label
/// always floats above the control (`.select-wrapper label` has an
/// unconditional `translateY(-75%)`).
///
/// ```dart
/// ItSelect<String>(
///   label: 'Provincia',
///   items: [
///     ItSelectItem(value: 'RM', label: 'Roma'),
///     ItSelectItem(value: 'MI', label: 'Milano'),
///   ],
///   value: 'RM',
///   onChanged: (value) {},
/// )
/// ```
///
/// Options can be filed under `<optgroup>` captions by giving them a
/// [ItSelectItem.group]:
///
/// ```dart
/// ItSelect<String>(
///   label: 'Etichetta',
///   items: [
///     ItSelectItem(value: '1', label: 'Opzione 1', group: 'Gruppo 1'),
///     ItSelectItem(value: '3', label: 'Opzione 3', group: 'Gruppo 2'),
///   ],
/// )
/// ```
///
/// Choosing more than one is [ItMultiSelect], a widget of its own.
///
/// It was `ItSelect.multiple`, a named constructor on this class, and before
/// that a `multiple: true` flag beside `value`, `values`, `onChanged` and
/// `onMultiChanged` — which let `ItSelect(multiple: true, onChanged: …)`
/// compile, run, and silently never fire, because the multi path only ever
/// called the other callback. The named constructor made that unrepresentable,
/// but left the two shapes sharing one field list: four fields each documented
/// as "always null on the other constructor", and a `.multiple(onChanged:)`
/// argument that landed on a field called `onValuesChanged`, because two
/// callbacks of different types cannot share a name. The API you read was not
/// the API you wrote. Two widgets, one selection each, is the version with
/// nothing to explain.
class ItSelect<T> extends StatelessWidget {
  /// The floating label text.
  final String? label;

  /// Hint text when no value is selected.
  final String? hint;

  /// The available options.
  final List<ItSelectItem<T>> items;

  /// Currently selected value.
  final T? value;

  /// Called with the new selection.
  final ValueChanged<T?>? onChanged;

  /// Whether the dropdown carries a filter field.
  final bool searchable;

  /// Whether the control is enabled.
  final bool enabled;

  /// Whether to reserve the `.form-group` bottom margin.
  final bool groupMargin;

  /// `.form-text` — instruction shown below the control.
  final String? helperText;

  /// `.form-feedback` — validation message shown below the control.
  final String? errorText;

  /// Validation appearance, independent of [errorText].
  final ItValidationState? validationState;

  /// Whether a selection must be made before the form can be submitted.
  final bool required;

  /// Overrides what assistive technology announces for the control.
  final String? semanticLabel;

  /// An externally owned focus node.
  final FocusNode? focusNode;

  /// Validates the selection as part of an enclosing [Form], as
  /// `TextFormField.validator` does.
  final FormFieldValidator<T>? validator;

  /// Called by `Form.save()`.
  final FormFieldSetter<T>? onSaved;

  /// When the control re-validates. Defaults to [AutovalidateMode.disabled].
  final AutovalidateMode? autovalidateMode;

  /// Creates a single-selection Bootstrap Italia select.
  const ItSelect({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.searchable = false,
    this.enabled = true,
    this.groupMargin = true,
    this.helperText,
    this.errorText,
    this.validationState,
    this.required = false,
    this.semanticLabel,
    this.focusNode,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) => _SelectCore<T>(
        label: label,
        hint: hint,
        items: items,
        value: value,
        onChanged: onChanged,
        searchable: searchable,
        enabled: enabled,
        groupMargin: groupMargin,
        helperText: helperText,
        errorText: errorText,
        validationState: validationState,
        required: required,
        semanticLabel: semanticLabel,
        focusNode: focusNode,
        validator: validator,
        onSaved: onSaved,
        autovalidateMode: autovalidateMode,
      );
}

/// A Bootstrap Italia select that takes more than one option.
///
/// `<select multiple>`: the closed control reads back every choice, and the
/// list keeps a checkbox against each row.
///
/// ```dart
/// ItMultiSelect<String>(
///   label: 'Province',
///   items: [
///     ItSelectItem(value: 'RM', label: 'Roma'),
///     ItSelectItem(value: 'MI', label: 'Milano'),
///   ],
///   values: {'RM'},
///   onChanged: (values) {},
/// )
/// ```
///
/// `values` and `onChanged` are the shape [ItCheckboxGroup] uses for the same
/// job — one selection, one callback, both named for what they hold.
///
/// The form hooks ([ItSelect.validator] and friends) are single-selection only:
/// a `FormFieldValidator<T>` cannot say anything about a `Set<T>`, and
/// inventing a second validator type to paper over that would be worse than
/// leaving this variant out of the `Form`.
class ItMultiSelect<T> extends StatelessWidget {
  /// The floating label text.
  final String? label;

  /// Hint text when nothing is selected.
  final String? hint;

  /// The available options.
  final List<ItSelectItem<T>> items;

  /// Currently selected values.
  final Set<T> values;

  /// Called with the new selection.
  final ValueChanged<Set<T>>? onChanged;

  /// Whether the dropdown carries a filter field.
  final bool searchable;

  /// Whether the control is enabled.
  final bool enabled;

  /// Whether to reserve the `.form-group` bottom margin.
  final bool groupMargin;

  /// `.form-text` — instruction shown below the control.
  final String? helperText;

  /// `.form-feedback` — validation message shown below the control.
  final String? errorText;

  /// Validation appearance, independent of [errorText].
  final ItValidationState? validationState;

  /// Whether a selection must be made before the form can be submitted.
  final bool required;

  /// Overrides what assistive technology announces for the control.
  final String? semanticLabel;

  /// An externally owned focus node.
  final FocusNode? focusNode;

  /// Creates a multiple-selection Bootstrap Italia select.
  const ItMultiSelect({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.values = const {},
    this.onChanged,
    this.searchable = false,
    this.enabled = true,
    this.groupMargin = true,
    this.helperText,
    this.errorText,
    this.validationState,
    this.required = false,
    this.semanticLabel,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) => _SelectCore<T>.multiple(
        label: label,
        hint: hint,
        items: items,
        values: values,
        onChanged: onChanged,
        searchable: searchable,
        enabled: enabled,
        groupMargin: groupMargin,
        helperText: helperText,
        errorText: errorText,
        validationState: validationState,
        required: required,
        semanticLabel: semanticLabel,
        focusNode: focusNode,
      );
}

/// The one implementation behind [ItSelect] and [ItMultiSelect].
///
/// Private: the two shapes differ only in what they hold and what they emit,
/// and everything below this line is the same dropdown.
class _SelectCore<T> extends StatefulWidget {
  /// The floating label text.
  final String? label;

  /// Hint text when no value is selected.
  final String? hint;

  /// The available options.
  final List<ItSelectItem<T>> items;

  /// Currently selected value. Null when built for [ItMultiSelect].
  final T? value;

  /// Currently selected values. Null when built for [ItSelect].
  final Set<T>? values;

  /// Called with the new selection. Null when built for [ItMultiSelect].
  final ValueChanged<T?>? onChanged;

  /// Called with the new selection set. Null when built for [ItSelect].
  ///
  /// The two callbacks cannot share a field because they cannot share a type.
  /// In here that is a private detail; it used to be the public API, which is
  /// why [ItMultiSelect] exists.
  final ValueChanged<Set<T>>? onValuesChanged;

  /// Validates the selection as part of an enclosing [Form], as
  /// `TextFormField.validator` does. Single-selection only.
  ///
  /// Without this the select is not a [FormField] at all, so a required
  /// dropdown inside a `Form` compiles, looks correct, and is skipped entirely
  /// by `validate()` — the form submits with nothing chosen and says nothing.
  /// That failure is silent by construction, which is why the parameter exists
  /// rather than a note in the docs.
  final FormFieldValidator<T>? validator;

  /// Called by `Form.save()`. Single-selection only.
  final FormFieldSetter<T>? onSaved;

  /// When the field re-validates. Defaults to [AutovalidateMode.disabled].
  final AutovalidateMode? autovalidateMode;

  /// Whether this select takes several values. Derived from the constructor —
  /// there is no way for a caller to set it independently of the callback it
  /// implies.
  final bool multiple;

  /// Whether to show a search/filter field.
  final bool searchable;

  /// Whether the select is enabled.
  ///
  /// A disabled select is skipped by Tab traversal and does not open, but stays
  /// in the semantics tree reporting its value and its disabled state
  /// (WCAG 4.1.2).
  final bool enabled;

  /// `.form-text` — instruction shown below the control.
  final String? helperText;

  /// Validation message (`.form-feedback`) shown below the control.
  ///
  /// It is also carried on the control's own semantics node, so a screen
  /// reader hears it as part of the field (WCAG 3.3.1 Error Identification).
  final String? errorText;

  /// Validation state tinting the control's bottom border. [errorText] implies
  /// [ItValidationState.danger].
  final ItValidationState? validationState;

  /// Whether a value must be chosen before the form can be submitted.
  final bool required;

  /// Accessible name, when it must differ from the visible [label].
  final String? semanticLabel;

  /// Optional external focus node, so the control can be focused
  /// programmatically — moving focus to the first field that failed validation
  /// is the ordinary way a form reports errors (WCAG 3.3.1).
  final FocusNode? focusNode;

  /// Whether to reserve `.form-group { margin-bottom: 3rem }` below the field.
  ///
  /// On by default, and it is not decoration: the NEXT field's floating label
  /// is drawn 33.15px above its own box, unclipped, and this 48px is the space
  /// it rises into. Turn it off and stacked fields overlap — reported twice
  /// from a real form.
  ///
  /// Worth turning off for a field that is the last thing in its container, or
  /// when the surrounding layout supplies its own spacing. Note that the
  /// margin is part of this widget's box, so its centre is below the control
  /// while it is on.
  final bool groupMargin;

  /// Creates a single-selection Bootstrap Italia select.
  const _SelectCore({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.searchable = false,
    this.enabled = true,
    this.groupMargin = true,
    this.helperText,
    this.errorText,
    this.validationState,
    this.required = false,
    this.semanticLabel,
    this.focusNode,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
  })  : values = null,
        onValuesChanged = null,
        multiple = false;

  /// Creates a multiple-selection Bootstrap Italia select.
  ///
  /// Behind [ItMultiSelect].
  const _SelectCore.multiple({
    super.key,
    this.label,
    this.hint,
    required this.items,
    Set<T> this.values = const {},
    ValueChanged<Set<T>>? onChanged,
    this.searchable = false,
    this.enabled = true,
    this.groupMargin = true,
    this.helperText,
    this.errorText,
    this.validationState,
    this.required = false,
    this.semanticLabel,
    this.focusNode,
  })  : value = null,
        // The form hooks are single-selection only: a
        // `FormFieldValidator<T>` cannot say anything about a Set<T>, and
        // inventing a second validator type to paper over that would be worse
        // than leaving the multiple variant out of the Form.
        validator = null,
        onSaved = null,
        autovalidateMode = null,
        // Both right-hand sides below name the *parameter* — an initializer
        // list cannot read a field — so `onChanged` is routed to the set-valued
        // field and the single-valued one is left null.
        onValuesChanged = onChanged,
        onChanged = null,
        multiple = true;

  @override
  State<_SelectCore<T>> createState() => _SelectCoreState<T>();
}

class _SelectCoreState<T> extends State<_SelectCore<T>> {
  bool _isOpen = false;
  String _searchQuery = '';
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  /// The control's own box. Once `helperText`/`errorText` add a line beneath
  /// it this is no longer this State's render object, and measuring the outer
  /// one dropped the option list a feedback-line's height too low — which is
  /// what `errorText` did before it was measured from here.
  final GlobalKey _controlKey = GlobalKey();

  /// Focus for the closed control, so it is reachable by Tab and so focus can
  /// be restored when the list is dismissed (WCAG 2.1.2 No Keyboard Trap).
  ///
  /// Owned only when the caller supplies none — the same contract [ItInput]
  /// keeps: re-listen on swap, dispose only what was created here.
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _showFocus = false;

  @override
  void initState() {
    super.initState();
    _initFocusNode();
  }

  void _initFocusNode() {
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'ItSelect');
  }

  @override
  void didUpdateWidget(covariant _SelectCore<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _initFocusNode();
    }
    ItFieldValidation.announce(context, oldWidget.errorText, widget.errorText);
  }

  /// Keyboard cursor within the open list.
  int _highlighted = -1;

  /// `.select-wrapper label { transform: translateY(-75%) }` of the 39px line.
  static const double _labelOffset = -0.75 * ItFormMetrics.labelLineHeight;

  List<ItSelectItem<T>> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items
        .where(
          (item) =>
              item.label.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  /// The rows the open dropdown paints: the filtered options, with an
  /// `<optgroup>` caption inserted wherever [ItSelectItem.group] changes.
  ///
  /// Emitted on *change* rather than by bucketing, because `<optgroup>` works
  /// the same way: the browser renders the groups in document order and an
  /// option belongs to whichever group encloses it. Re-sorting the list here
  /// would silently reorder options the caller deliberately ordered, and would
  /// also merge two same-named groups the markup keeps apart.
  ///
  /// Options with no [ItSelectItem.group] simply produce no caption, so a list
  /// that mixes grouped and ungrouped options renders the ungrouped ones as
  /// plain rows — which is what a `<select>` does with options outside any
  /// `<optgroup>`.
  List<_SelectRow<T>> get _rows {
    final items = _filteredItems;
    final rows = <_SelectRow<T>>[];
    String? current;
    for (var i = 0; i < items.length; i++) {
      final group = items[i].group;
      if (group != null && group != current) rows.add(_SelectGroupRow(group));
      current = group;
      rows.add(_SelectOptionRow(items[i], i));
    }
    return rows;
  }

  String get _displayText {
    if (widget.multiple) {
      final selected = widget.values ?? {};
      if (selected.isEmpty) return widget.hint ?? '';
      final labels = widget.items
          .where((item) => selected.contains(item.value))
          .map((item) => item.label);
      return labels.join(', ');
    }
    if (widget.value == null) return widget.hint ?? '';
    final item = widget.items.cast<ItSelectItem<T>?>().firstWhere(
          (item) => item!.value == widget.value,
          orElse: () => null,
        );
    return item?.label ?? '';
  }

  void _toggleDropdown() {
    if (!_interactive) return;
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
      _searchQuery = '';
      _highlighted = widget.items.indexWhere((i) => i.value == widget.value);
    });
  }

  void _close({bool restoreFocus = false}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
        _highlighted = -1;
      });
      // WCAG 2.1.2: dismissing the list must not strand the keyboard inside a
      // widget that no longer exists — focus returns to the control.
      if (restoreFocus) _focusNode.requestFocus();
    }
  }

  /// Moves the keyboard cursor over the currently visible options.
  void _moveHighlight(int delta) {
    final items = _filteredItems;
    if (items.isEmpty) return;
    var next = _highlighted;
    for (var step = 0; step < items.length; step++) {
      next = (next + delta) % items.length;
      if (next < 0) next += items.length;
      if (items[next].enabled) break;
    }
    if (!items[next].enabled) return;
    setState(() => _highlighted = next);
    _overlayEntry?.markNeedsBuild();
  }

  void _activate() {
    if (!_interactive) return;
    if (!_isOpen) {
      _open();
      return;
    }
    final items = _filteredItems;
    if (_highlighted >= 0 && _highlighted < items.length) {
      _selectItem(items[_highlighted]);
    } else {
      _close(restoreFocus: true);
    }
  }

  void _selectItem(ItSelectItem<T> item) {
    if (!item.enabled) return;

    if (widget.multiple) {
      final current = Set<T>.from(widget.values ?? {});
      if (current.contains(item.value)) {
        current.remove(item.value);
      } else {
        current.add(item.value);
      }
      widget.onValuesChanged?.call(current);
      _overlayEntry?.markNeedsBuild();
    } else {
      _formState?.didChange(item.value);
      widget.onChanged?.call(item.value);
      _close(restoreFocus: true);
    }
  }

  OverlayEntry _buildOverlay() {
    final renderBox =
        _controlKey.currentContext!.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final colors = resolveColorScheme(context);
    // Read from the *state's* context, not the OverlayEntry builder's: the
    // overlay mounts in the Overlay's subtree, which is a sibling of this
    // control and need not sit under the same Localizations.
    final l10n = ItLocalizations.of(context);

    return OverlayEntry(
      builder: (context) {
        final filtered = _rows;
        return Stack(
          children: [
            // The scrim is a pointer-only affordance; Escape is the keyboard
            // equivalent and is handled on the control itself.
            ExcludeSemantics(
              child: GestureDetector(
                onTap: () => _close(restoreFocus: true),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, size.height + 4),
              // `.bootstrap-select-wrapper .dropdown-menu
              //   { padding: 0; margin: 0; box-shadow: 0 2px 10px 0
              //     rgba(0,0,0,.1) }` over `--bs-dropdown-bg: hsl(0,0%,100%)`
              // and `--bs-dropdown-border-radius: 4px`. Material's
              // `elevation: 4` painted a Material-spec shadow instead — a
              // different blur, spread and opacity from the one declared here.
              child: ItDefaultTextStyle(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.white,
                    borderRadius:
                        BorderRadius.circular(BootstrapItaliaBorders.radius),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: size.width,
                      maxHeight: 300,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.searchable)
                          Padding(
                            padding: const EdgeInsets.all(
                              BootstrapItaliaSpacing.space2,
                            ),
                            // `searchable: true` THREW before this: `TextField`
                            // asserts `debugCheckHasMaterial`, and this field
                            // lives in an OverlayEntry mounted on the
                            // Navigator's overlay — which sits *above* the
                            // host's Scaffold, so there is no Material anywhere
                            // over it. Nothing caught it because no test and no
                            // parity capture used a searchable select; only the
                            // example app did, where it crashed on open.
                            //
                            // The Material is the price of ADR 0001's one
                            // deliberate exception — the ADR keeps `TextField`
                            // rather than reimplementing IME, selection and
                            // autofill. `transparency` paints nothing, so the
                            // surface is exactly the ancestor the assert wants
                            // and no more. `ItDefaultTextStyle` goes back on
                            // INSIDE it, because Material wraps its child in an
                            // `AnimatedDefaultTextStyle` carrying
                            // `ThemeData.textTheme.bodyMedium` and would
                            // otherwise re-leak the typography the enclosing
                            // ItDefaultTextStyle was added to stop.
                            child: Material(
                              type: MaterialType.transparency,
                              child: ItDefaultTextStyle(
                                  child: TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: l10n.searchPlaceholder,
                                  isDense: true,
                                  prefixIcon: const Icon(
                                      BootstrapItaliaIcons.it_search,
                                      size: 18),
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (query) {
                                  _searchQuery = query;
                                  _overlayEntry?.markNeedsBuild();
                                },
                              )),
                            ),
                          ),
                        Flexible(
                          // WCAG 1.3.1: each option carries its own selected
                          // state so AT can report which one is current.
                          //
                          // `SemanticsRole.list`/`listItem` are not used: the
                          // framework requires a listItem's *direct* parent node
                          // to be the list, and the scrollable sits between them.
                          child: Semantics(
                            explicitChildNodes: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: filtered.length,
                              itemBuilder: (context, position) {
                                final row = filtered[position];
                                // `<optgroup label="…">` — a caption, not an
                                // option. `.dropdown-header { display:block;
                                // padding:.5rem 24px; font-size:.875rem }` and
                                // `.dropdown-header .text
                                //   { text-transform:uppercase;
                                //     color:hsl(0,0%,10%); font-weight:600 }`.
                                if (row is _SelectGroupRow<T>) {
                                  return Semantics(
                                    // WCAG 1.3.1: `<optgroup label="…">` is
                                    // structure, not decoration — without a
                                    // node of its own the caption reaches a
                                    // screen reader as an unexplained line
                                    // between two options, and the user cannot
                                    // tell which options it covers. A heading
                                    // is the shape assistive technology already
                                    // navigates by, and it is not offered as a
                                    // choice because it carries no tap action.
                                    header: true,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            BootstrapItaliaSpacing.space4,
                                        vertical: BootstrapItaliaSpacing.space2,
                                      ),
                                      child: Text(
                                        row.label.toUpperCase(),
                                        style: ItFormMetrics.textStyle(
                                          fontSize: 14,
                                          lineHeight: 21,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              ItFormMetrics.textColor(colors),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final optionRow = row as _SelectOptionRow<T>;
                                final item = optionRow.item;
                                final index = optionRow.index;
                                final isSelected = widget.multiple
                                    ? (widget.values ?? {}).contains(item.value)
                                    : widget.value == item.value;

                                return Semantics(
                                  button: true,
                                  selected: isSelected,
                                  enabled: item.enabled,
                                  inMutuallyExclusiveGroup: !widget.multiple,
                                  child: ItHoverBuilder(
                                    enabled: item.enabled,
                                    cursor: !item.enabled
                                        ? SystemMouseCursors.basic
                                        : SystemMouseCursors.click,
                                    builder: (context, hovered) {
                                      // One "pointed at" state for both cursors:
                                      // the mouse pointer and the keyboard
                                      // highlight land on the same row treatment,
                                      // so a keyboard user sees exactly what a
                                      // mouse user does (WCAG 2.4.7).
                                      final pointed =
                                          hovered || index == _highlighted;
                                      // §2.4.7: the option list is reachable with
                                      // the arrow keys, and the row it lands on
                                      // must be visible even when the pointer is
                                      // elsewhere. `_highlighted` already
                                      // repaints the row, so the ring only has to
                                      // cover a row that takes focus directly —
                                      // which is exactly what ItActivatable
                                      // paints, from the focus node it owns.
                                      //
                                      // The row's own fill is resolved below:
                                      // Bootstrap Italia marks the pointed-at row
                                      // with the solid brand blue (the same
                                      // treatment `.autocomplete-list` uses),
                                      // where Material's translucent white
                                      // highlight would instead lighten it.
                                      return ItActivatable(
                                        onPressed: !item.enabled
                                            ? null
                                            : () => _selectItem(item),
                                        // WCAG 2.5.8: the option is 16px of
                                        // padding plus a 24px line box,
                                        // comfortably past the 24x24 minimum.
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                BootstrapItaliaSpacing.space3,
                                            vertical:
                                                BootstrapItaliaSpacing.space2,
                                          ),
                                          color: pointed
                                              ? colors.primary
                                              : isSelected
                                                  ? colors.primary.withAlpha(26)
                                                  : null,
                                          child: Row(
                                            children: [
                                              if (widget.multiple) ...[
                                                ExcludeSemantics(
                                                  child: Icon(
                                                    isSelected
                                                        ? BootstrapItaliaIcons
                                                            .it_check
                                                        : Icons
                                                            .check_box_outline_blank,
                                                    size: 18,
                                                    color: pointed
                                                        ? colors.white
                                                        : isSelected
                                                            ? colors.primary
                                                            : colors.gray400,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Expanded(
                                                child: Text(
                                                  item.label,
                                                  style:
                                                      ItFormMetrics.textStyle(
                                                    fontSize:
                                                        ItFormMetrics.fontSize,
                                                    lineHeight: ItFormMetrics
                                                        .textLineHeight,
                                                    color: pointed
                                                        ? colors.white
                                                        : !item.enabled
                                                            ? colors.gray400
                                                            : ItFormMetrics
                                                                .textColor(
                                                                colors,
                                                              ),
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              if (!widget.multiple &&
                                                  isSelected)
                                                ExcludeSemantics(
                                                  child: Icon(
                                                    BootstrapItaliaIcons
                                                        .it_check,
                                                    size: 18,
                                                    color: pointed
                                                        ? colors.white
                                                        : colors.primary,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
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
    _overlayEntry?.remove();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  /// The message the enclosing [Form] produced, when participating in one.
  String? _formError;
  FormFieldState<T>? _formState;

  /// An explicit [ItSelect.errorText] wins: a caller stating the error is more
  /// specific than a validator that may not have run.
  String? get _errorText => widget.errorText ?? _formError;

  /// Interactive only when enabled AND given a callback.
  ///
  /// `onChanged: null` is Flutter's convention for a disabled control — it is
  /// how `DropdownButton`, `TextField` and `Checkbox` all express read-only,
  /// and how [ItCheckbox], [ItRadio] and [ItToggle] express it here. ItSelect
  /// checked only `enabled`, so a read-only screen that disabled its dropdown
  /// the ordinary way still got a select that opened and let the user pick.
  /// Found in a real application: a document in view-only mode whose
  /// "Evento o manifestazione" dropdown was fully operable.
  bool get _interactive =>
      widget.enabled &&
      // `ItSelect.multiple` routes its callback to [onValuesChanged] and
      // leaves [onChanged] null by construction, so checking only `onChanged`
      // would disable every multi-select outright.
      (widget.multiple
          ? widget.onValuesChanged != null
          : widget.onChanged != null);

  bool get _isFormField => widget.validator != null || widget.onSaved != null;

  @override
  Widget build(BuildContext context) {
    if (!_isFormField) return _buildSelect(context);

    return FormField<T>(
      initialValue: widget.value,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator == null
          ? null
          // The widget's own `value` is the truth: this is a controlled
          // component, and the FormField's copy goes stale the moment the
          // caller rebuilds with a new selection.
          : (_) => widget.validator!(widget.value),
      onSaved:
          widget.onSaved == null ? null : (_) => widget.onSaved!(widget.value),
      builder: (state) {
        _formState = state;
        if (state.errorText != _formError) {
          final previous = _formError;
          _formError = state.errorText;
          // WCAG 4.1.3: a message that appears after the fact takes no focus,
          // so nothing would otherwise announce it. Deferred because this is
          // inside build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ItFieldValidation.announce(context, previous, _formError);
            }
          });
        }
        return _buildSelect(context);
      },
    );
  }

  Widget _buildSelect(BuildContext context) {
    ItFieldValidation.debugCheckConfig(
      label: widget.label,
      required: widget.required,
      optionCount: widget.items.length,
      optionValues: widget.items.map((o) => o.value),
      widgetName: 'ItSelect',
    );
    final colors = resolveColorScheme(context);
    final validation =
        ItFieldValidation.effective(_errorText, widget.validationState);

    final control = SizedBox(
      height: ItFormMetrics.controlHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // .select-wrapper select:disabled { background-color: hsl(210,3%,85%) }
          if (!widget.enabled)
            const Positioned.fill(
              child: ColoredBox(color: ItFormMetrics.disabledBackground),
            ),
          Positioned.fill(
            child: Padding(
              // .select-wrapper select { padding: .375rem .5rem } plus the
              // 4px of inner padding every browser adds inside a native
              // <select>, which is what Bootstrap Italia renders on top of.
              padding: const EdgeInsets.only(
                left: ItFormMetrics.horizontalPadding + 4,
                right: 24,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _displayText,
                  // .select-wrapper select { font-weight:700; color:hsl(0,0%,10%) }
                  // — hsl(0,0%,10%) is the bodyColor token.
                  style: ItFormMetrics.textStyle(
                    fontSize: ItFormMetrics.fontSize,
                    lineHeight: ItFormMetrics.textLineHeight,
                    fontWeight: FontWeight.w700,
                    color: ItFormMetrics.textColor(colors),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ),
          // The dropdown indicator — decorative; the open/closed state is
          // on the control's own node as `expanded`.
          Positioned(
            right: 3,
            top: 17,
            child: CustomPaint(
              size: const Size(10, 6.5),
              painter: _SelectChevronPainter(
                color: ItFormMetrics.textColor(colors),
                flipped: _isOpen,
              ),
            ),
          ),
          // .select-wrapper select { border-bottom: 1px solid rgb(91,110.5,130) }
          // .form-select.is-invalid  { border-color: rgb(204,51,76.5) }
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: ItFormMetrics.borderWidth,
            child: ColoredBox(
              color: validation == null
                  ? ItFormMetrics.selectBorderColor
                  : ItFieldValidation.color(colors, validation),
            ),
          ),
          // .select-wrapper label { font-size:.875rem; font-weight:600;
          //                         color:hsl(0,0%,10%);
          //                         transform:translateY(-75%) }
          // — hsl(0,0%,10%) is the bodyColor token.
          if (widget.label != null)
            Positioned(
              left: 0,
              top: _labelOffset,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ItFormMetrics.horizontalPadding,
                ),
                child: Text(
                  widget.label!,
                  style: ItFormMetrics.textStyle(
                    fontSize: ItFormMetrics.activeLabelFontSize,
                    lineHeight: ItFormMetrics.labelLineHeight,
                    fontWeight: FontWeight.w600,
                    color: ItFormMetrics.textColor(colors),
                  ),
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );

    // WCAG 4.1.2: the whole control is hand-painted, so without this it
    // reached AT as an unnamed tap target with no role, no value and no way
    // to tell whether the list was open.
    //
    // Not `SemanticsRole.comboBox`: the value exists in the enum but Flutter's
    // own debug role checks reject it ("Missing checks for role
    // SemanticsRole.comboBox", `_DebugSemanticsRoleChecks._unimplemented`), so
    // it cannot be used yet. `button` + `expanded` + `value` is what
    // Flutter's own dropdowns expose and carries the same information.
    final semanticControl = MergeSemantics(
      child: Semantics(
        button: true,
        label: widget.semanticLabel ?? widget.label,
        value: _displayText,
        // WCAG 3.3.1 / 3.3.2: the instruction and the validation message are
        // painted below the control, so they are carried here as well.
        hint: ItFieldValidation.hint(_errorText, widget.helperText),
        expanded: _isOpen,
        enabled: widget.enabled,
        isRequired: widget.required,
        validationResult: ItFieldValidation.result(validation),
        onTap: _interactive ? _toggleDropdown : null,
        child: ItFocusRing(
          visible: _showFocus,
          child: FocusableActionDetector(
            focusNode: _focusNode,
            enabled: widget.enabled,
            mouseCursor: !widget.enabled
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            // WCAG 2.1.1: everything a native <select> does from the keyboard.
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
              SingleActivator(LogicalKeyboardKey.arrowDown):
                  _MoveSelectHighlightIntent(1),
              SingleActivator(LogicalKeyboardKey.arrowUp):
                  _MoveSelectHighlightIntent(-1),
            },
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  _activate();
                  return null;
                },
              ),
              DismissIntent: CallbackAction<DismissIntent>(
                onInvoke: (_) {
                  if (_isOpen) _close(restoreFocus: true);
                  return null;
                },
              ),
              _MoveSelectHighlightIntent:
                  CallbackAction<_MoveSelectHighlightIntent>(
                onInvoke: (intent) {
                  if (!_isOpen) {
                    _open();
                  } else {
                    _moveHighlight(intent.delta);
                  }
                  return null;
                },
              ),
            },
            onShowFocusHighlight: (show) {
              if (show != _showFocus) setState(() => _showFocus = show);
            },
            child: GestureDetector(
              onTap: _toggleDropdown,
              behavior: HitTestBehavior.opaque,
              // The label and value are already on the wrapper.
              child: ExcludeSemantics(child: control),
            ),
          ),
        ),
      ),
    );

    // The link target stays *inside* the supporting text: the option list is
    // anchored to the control, not to the control plus a feedback line.
    return ItFieldSupport(
      // `.form-group { margin-bottom: 3rem }` — the space the NEXT
      // field's floating label rises into. Without it that label is
      // painted straight through this control.
      groupMargin: widget.groupMargin,
      helperText: widget.helperText,
      errorText: _errorText,
      child: CompositedTransformTarget(
        key: _controlKey,
        link: _layerLink,
        child: semanticControl,
      ),
    );
  }
}

/// Moves the keyboard cursor within an open [ItSelect] list.
/// One row of an open [ItSelect]'s list.
///
/// A `<select>` has two kinds of child — `<option>` and `<optgroup>` — and the
/// list has to paint both while the keyboard cursor walks only the first. This
/// pair keeps the two indexes from being confused: [_SelectOptionRow.index] is
/// the option's position among the *options*, which is what `_highlighted`
/// holds, while the list view's own index counts captions too.
sealed class _SelectRow<T> {
  const _SelectRow();
}

/// An `<optgroup label="…">` caption.
final class _SelectGroupRow<T> extends _SelectRow<T> {
  const _SelectGroupRow(this.label);

  /// The group name, as given on [ItSelectItem.group].
  final String label;
}

/// An `<option>`, with its position among the visible options.
final class _SelectOptionRow<T> extends _SelectRow<T> {
  const _SelectOptionRow(this.item, this.index);

  /// The option itself.
  final ItSelectItem<T> item;

  /// Its index in `_filteredItems` — the index the keyboard cursor uses.
  final int index;
}

class _MoveSelectHighlightIntent extends Intent {
  const _MoveSelectHighlightIntent(this.delta);

  final int delta;
}

/// The chevron the browser draws for a native `<select>`.
class _SelectChevronPainter extends CustomPainter {
  const _SelectChevronPainter({required this.color, required this.flipped});

  final Color color;
  final bool flipped;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final path = flipped
        ? (Path()
          ..moveTo(0.9, h - 0.9)
          ..lineTo(w / 2, 0.9)
          ..lineTo(w - 0.9, h - 0.9))
        : (Path()
          ..moveTo(0.9, 0.9)
          ..lineTo(w / 2, h - 0.9)
          ..lineTo(w - 0.9, 0.9));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SelectChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.flipped != flipped;
}
