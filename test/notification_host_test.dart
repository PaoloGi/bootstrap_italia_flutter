// Where ItNotification.show can be called from.
//
// An app-wide messenger has one context to hand: the Navigator's own, from its
// navigatorKey. `Overlay.of` looks only up the tree, and that context sits
// above the Overlay the Navigator builds — so a real app's every success and
// error message threw "No Overlay widget found", and a save that had already
// succeeded was reported to the user as a failure. Found by the app's
// mock-backend smoke tests, not by anything here: every test in this package
// passed a context from inside a Scaffold.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("show() works from the Navigator's own context", (t) async {
    final nav = GlobalKey<NavigatorState>();
    await t.pumpWidget(MaterialApp(
      navigatorKey: nav,
      home: const Scaffold(body: SizedBox()),
    ));

    ItNotification.show(
      context: nav.currentContext!,
      body: 'Documento inviato con successo',
      duration: const Duration(seconds: 2),
    );
    await t.pump();
    expect(find.text('Documento inviato con successo'), findsOneWidget);

    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
    expect(find.text('Documento inviato con successo'), findsNothing);
  });

  testWidgets('a context with no Overlay and no Navigator gets a clear error',
      (t) async {
    late BuildContext bare;
    await t.pumpWidget(MediaQuery(
      data: const MediaQueryData(),
      child: Builder(builder: (c) {
        bare = c;
        return const SizedBox();
      }),
    ));
    expect(
      () => ItNotification.show(context: bare, body: 'x'),
      throwsA(isA<FlutterError>()
          .having((e) => e.message, 'message', contains('found no Overlay'))),
    );
  });
}
