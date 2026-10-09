import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/parity_fonts.dart';

void main() {
  setUpAll(loadTestFonts);
  for (final which in ['slim', 'center'])
    for (final w in [390.0, 360.0, 768.0]) {
      testWidgets('$which @ $w', (tester) async {
        tester.view.physicalSize = Size(w * 2, 900 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);
        final errs = <String>[];
        final prev = FlutterError.onError;
        FlutterError.onError = (d) => errs.add(d.exception.toString());
        addTearDown(() => FlutterError.onError = prev);

        await tester.pumpWidget(BootstrapItaliaTheme(
          data: BootstrapItaliaThemeData.standard(),
          child: MaterialApp(
            home: Scaffold(
              body: which == 'slim'
                  ? ItSlimHeader(
                      institutionName: 'Ente di prova',
                      accessLabel: 'Accedi',
                      onAccessTap: () {},
                    )
                  : const ItCenterHeader(
                      title: 'Bootstrap Italia Flutter',
                      subtitle: 'Soak test',
                      showSearch: true,
                    ),
            ),
          ),
        ));
        await tester.pump();
        debugPrint(
            'HDR $which w=$w overflows=${errs.length} ${errs.take(2).join(" | ")}');
      });
    }
}
