// A control that silently opts out of its own Form.
//
// `ItInput` is not a `FormField`. Until these tests existed, swapping a
// `TextFormField` for it compiled cleanly, passed analysis, and quietly stopped
// `Form.validate()` from ever calling the validator — so the form submitted
// invalid data and nothing anywhere said a word. It was found three times in
// one afternoon in one real application (a shared text-field wrapper, a
// description field, and a password field that lost `onSaved` as well).
//
// The failure mode is what makes it worth a dedicated file: there is no
// crash, no warning and no visual difference. Only a test that actually calls
// `validate()` can see it.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ItInput participates in an enclosing Form', () {
    testWidgets('validate() calls the validator and blocks on failure',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      var calls = 0;

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: ItInput(
            label: 'Nome',
            validator: (v) {
              calls++;
              return (v == null || v.isEmpty) ? 'Campo obbligatorio' : null;
            },
          ),
        ),
      ));

      expect(formKey.currentState!.validate(), isFalse);
      expect(calls, 1,
          reason: 'if this is 0 the field is not registered with the Form at '
              'all, which is the whole defect this file exists for');

      await tester.pump();
      expect(find.text('Campo obbligatorio'), findsOneWidget,
          reason: 'the message must reach the field, not just the Form');
    });

    testWidgets('validate() passes once the field is filled', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: 'Paolo');

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: ItInput(
            label: 'Nome',
            controller: controller,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Campo obbligatorio' : null,
          ),
        ),
      ));

      expect(formKey.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Campo obbligatorio'), findsNothing);
    });

    testWidgets('the validator reads the CONTROLLER, not a stale copy',
        (tester) async {
      // Application code sets `controller.text` directly all the time. A
      // FormField keeps its own value, and the two diverge the moment that
      // happens — so the validator has to be handed the controller's text.
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: ItInput(
            label: 'Nome',
            controller: controller,
            validator: (v) =>
                (v == null || v.length < 3) ? 'Troppo corto' : null,
          ),
        ),
      ));

      expect(formKey.currentState!.validate(), isFalse);

      controller.text = 'Paolo';
      await tester.pump();

      expect(formKey.currentState!.validate(), isTrue,
          reason: 'the validator saw the FormField\'s own value instead of the '
              'controller the caller actually writes to');
    });

    testWidgets('save() calls onSaved with the current text', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: 'Paolo');
      String? saved;

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: ItInput(
            label: 'Nome',
            controller: controller,
            onSaved: (v) => saved = v,
          ),
        ),
      ));

      formKey.currentState!.save();
      expect(saved, 'Paolo',
          reason: 'onSaved alone must also make the field a form participant — '
              'the password field that lost this had no validator at all');
    });

    testWidgets('typing clears a message under autovalidate', (tester) async {
      await tester.pumpWidget(_host(
        Form(
          child: ItInput(
            label: 'Nome',
            autovalidateMode: AutovalidateMode.always,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Campo obbligatorio' : null,
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('Campo obbligatorio'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'Paolo');
      await tester.pump();
      expect(find.text('Campo obbligatorio'), findsNothing,
          reason: 'without didChange the FormField never re-validates and a '
              'message that has been fixed stays on screen');
    });
  });

  // The same trap, the same shape, on every other control that can be a form
  // field. A required dropdown or an unticked consent box inside a `Form` is
  // exactly as easy to get wrong as a text field, and just as quiet about it.
  group('the other controls participate too', () {
    testWidgets('ItSelect validates and blocks on an empty selection',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      var calls = 0;

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: ItSelect<int>(
            hint: 'Seleziona il Comune',
            items: const [ItSelectItem<int>(value: 1, label: 'Ancona')],
            validator: (v) {
              calls++;
              return v == null ? 'Selezione obbligatoria' : null;
            },
          ),
        ),
      ));

      expect(formKey.currentState!.validate(), isFalse);
      expect(calls, 1);
      await tester.pump();
      expect(find.text('Selezione obbligatoria'), findsOneWidget);
    });

    testWidgets('ItSelect passes once something is chosen', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: ItSelect<int>(
            value: 1,
            items: const [ItSelectItem<int>(value: 1, label: 'Ancona')],
            validator: (v) => v == null ? 'Selezione obbligatoria' : null,
          ),
        ),
      ));

      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('ItCheckbox validates — the unticked consent box',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: ItCheckbox(
            label: 'Accetto le condizioni',
            value: false,
            onChanged: (_) {},
            validator: (v) => v == true ? null : 'Devi accettare',
          ),
        ),
      ));

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Devi accettare'), findsOneWidget);
    });

    testWidgets('ItToggle validates', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: ItToggle(
            label: 'Notifiche',
            value: false,
            onChanged: (_) {},
            validator: (v) => v == true ? null : 'Attiva le notifiche',
          ),
        ),
      ));

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Attiva le notifiche'), findsOneWidget);
    });

    testWidgets('ItRadio validates', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: ItRadio<int>(
            label: 'Prima opzione',
            value: 1,
            groupValue: 0,
            onChanged: (_) {},
            validator: (v) => v == true ? null : 'Scegli una opzione',
          ),
        ),
      ));

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Scegli una opzione'), findsOneWidget);
    });

    testWidgets('save() reaches every control', (tester) async {
      final formKey = GlobalKey<FormState>();
      bool? box;
      int? comune;

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: Column(children: [
            ItCheckbox(
              label: 'Accetto',
              value: true,
              onChanged: (_) {},
              onSaved: (v) => box = v,
            ),
            ItSelect<int>(
              value: 7,
              items: const [ItSelectItem<int>(value: 7, label: 'Ancona')],
              onSaved: (v) => comune = v,
            ),
          ]),
        ),
      ));

      formKey.currentState!.save();
      expect(box, isTrue);
      expect(comune, 7);
    });
  });

  group('nothing changes for a field that is not in a Form', () {
    testWidgets('no validator means no FormField and no behaviour change',
        (tester) async {
      await tester.pumpWidget(_host(const ItInput(label: 'Nome')));
      await tester.pump();

      expect(find.byType(FormField<String>), findsNothing,
          reason: 'the wrapper is opt-in; a plain ItInput must stay a plain '
              'ItInput so the parity captures keep describing it');
      expect(tester.takeException(), isNull);
    });

    testWidgets('an explicit errorText still wins over the validator',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_host(
        Form(
          key: formKey,
          child: ItInput(
            label: 'Nome',
            errorText: 'Errore dal server',
            validator: (_) => 'Errore dal validatore',
          ),
        ),
      ));

      formKey.currentState!.validate();
      await tester.pump();

      // A caller stating the error outright is more specific than a validator:
      // a server-side rejection should not be overwritten by a local rule.
      expect(find.text('Errore dal server'), findsOneWidget);
      expect(find.text('Errore dal validatore'), findsNothing);
    });
  });
}
