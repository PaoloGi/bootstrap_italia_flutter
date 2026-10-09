import 'package:flutter/widgets.dart';

/// Marks a subtree as the options of a field group that speaks for them.
///
/// [ItRadioGroup] and [ItCheckboxGroup] already carry the validation message,
/// the instruction and the required state on their own node, because all three
/// describe the *set*. The validation **tint** still reaches every option, and
/// should: `.was-validated :invalid` and `.is-invalid` sit on each
/// `.form-check-input`, so the kit draws every box in the group red.
///
/// What must not reach every option is the semantic invalid flag. A group of
/// three radios with one error announced it four times — once per radio and
/// once for the group — so the user heard "non valido" three more times than
/// there were problems, and still only one message. The markup has no
/// equivalent problem: `aria-invalid` on each input is read as a property of
/// the control the user is on, not as a fresh error each time, because a
/// screen reader voices one control at a time.
///
/// Not exported. Callers never build it; a group puts it around its options
/// and the options read it.
class ItFieldGroupScope extends InheritedWidget {
  /// Wraps a group's options.
  const ItFieldGroupScope({super.key, required super.child});

  /// Whether [context] sits inside a group that reports validity itself.
  static bool spokenFor(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ItFieldGroupScope>() != null;

  @override
  bool updateShouldNotify(ItFieldGroupScope oldWidget) => false;
}
