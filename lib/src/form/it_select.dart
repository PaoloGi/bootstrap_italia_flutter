import 'package:bootstrap_italia_icons/bootstrap_italia_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../a11y/it_activatable.dart';
import '../a11y/it_focus_ring.dart';
import '../l10n/it_localizations.dart';
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

  /// Optional group name for grouped options.
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
/// Multiple selection is a *different constructor*, not a flag:
///
/// ```dart
/// ItSelect<String>.multiple(
///   label: 'Province',
///   items: [...],
///   values: {'RM', 'MI'},
///   onChanged: (values) {},
/// )
/// ```
///
/// This is what removed the defect the two shapes used to share. The control
/// once took `value`, `values`, `onChanged` and `onMultiChanged` together,
/// gated by a `multiple` flag, so `ItSelect(multiple: true, onChanged: …)`
/// compiled, ran, and silently never fired: the multi-select path only ever
/// called `onMultiChanged`. Splitting the constructors makes that combination
/// **unrepresentable** — `multiple` is no longer a parameter at all, and the
/// single-select `onChanged` does not exist on `.multiple`, so the mistake is a
/// compile error rather than a form that does nothing when the user clicks. The
/// callback is named `onChanged` on both, matching [ItCheckboxGroup], which
/// solved the same problem first.
class ItSelect<T> extends StatefulWidget {
  /// The floating label text.
  final String? label;

  /// Hint text when no value is selected.
  final String? hint;

  /// The available options.
  final List<ItSelectItem<T>> items;

  /// Currently selected value. Always null on [ItSelect.multiple].
  final T? value;

  /// Currently selected values. Always null on the single-select constructor.
  final Set<T>? values;

  /// Called with the new selection. Always null on [ItSelect.multiple], whose
  /// `onChanged:` argument lands on [onValuesChanged] instead.
  final ValueChanged<T?>? onChanged;

  /// Called with the new selection set. Always null on the single-select
  /// constructor. This is where [ItSelect.multiple]'s `onChanged:` argument
  /// goes: the two callbacks cannot share a field because they cannot share a
  /// type, which is precisely why the flag-gated version could drop one.
  final ValueChanged<Set<T>>? onValuesChanged;

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
    this.helperText,
    this.errorText,
    this.validationState,
    this.required = false,
    this.semanticLabel,
    this.focusNode,
  })  : values = null,
        onValuesChanged = null,
        multiple = false;

  /// Creates a multiple-selection Bootstrap Italia select.
  ///
  /// Takes one selection ([values]) and one callback (`onChanged`), the shape
  /// [ItCheckboxGroup] already uses for the same job.
  const ItSelect.multiple({
    super.key,
    this.label,
    this.hint,
    required this.items,
    Set<T> this.values = const {},
    ValueChanged<Set<T>>? onChanged,
    this.searchable = false,
    this.enabled = true,
    this.helperText,
    this.errorText,
    this.validationState,
    this.required = false,
    this.semanticLabel,
    this.focusNode,
  })  : value = null,
        // Both right-hand sides below name the *parameter* — an initializer
        // list cannot read a field — so `onChanged` is routed to the set-valued
        // field and the single-valued one is left null.
        onValuesChanged = onChanged,
        onChanged = null,
        multiple = true;

  @override
  State<ItSelect<T>> createState() => _ItSelectState<T>();
}

class _ItSelectState<T> extends State<ItSelect<T>> {
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
  void didUpdateWidget(covariant ItSelect<T> oldWidget) {
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
    if (!widget.enabled) return;
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
    if (!widget.enabled) return;
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
      widget.onChanged?.call(item.value);
      _close(restoreFocus: true);
    }
  }

  OverlayEntry _buildOverlay() {
    final renderBox =
        _controlKey.currentContext!.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final colors = resolveColorScheme(context);
    // Both read from the *state's* context, not the OverlayEntry builder's:
    // the overlay is mounted in the Overlay's subtree, which is a sibling of
    // this control and need not sit under the same Localizations.
    final l10n = ItLocalizations.of(context);

    return OverlayEntry(
      builder: (context) {
        final filtered = _filteredItems;
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
                              itemBuilder: (context, index) {
                                final item = filtered[index];
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

  @override
  Widget build(BuildContext context) {
    final colors = resolveColorScheme(context);
    final validation =
        ItFieldValidation.effective(widget.errorText, widget.validationState);

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
        hint: ItFieldValidation.hint(widget.errorText, widget.helperText),
        expanded: _isOpen,
        enabled: widget.enabled,
        isRequired: widget.required,
        validationResult: ItFieldValidation.result(validation),
        onTap: widget.enabled ? _toggleDropdown : null,
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
      helperText: widget.helperText,
      errorText: widget.errorText,
      child: CompositedTransformTarget(
        key: _controlKey,
        link: _layerLink,
        child: semanticControl,
      ),
    );
  }
}

/// Moves the keyboard cursor within an open [ItSelect] list.
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
