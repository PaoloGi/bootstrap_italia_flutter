import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression tests for the ItHeader.sticky crash.
//
// `sticky: true` used to return a SliverAppBar from a box-context build, so the
// widget threw wherever it was placed. No test covered it, which is exactly why
// it survived. ItSliverHeader is the working replacement.
void main() {
  testWidgets('ItHeader(sticky: true) no longer crashes', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        // ignore: deprecated_member_use
        body: ItHeader(
            sticky: true, slimHeader: ItSlimHeader(institutionName: 'Ente')),
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ItSliverHeader pins inside a CustomScrollView', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CustomScrollView(slivers: [
          ItSliverHeader(slimHeader: ItSlimHeader(institutionName: 'Ente')),
          SliverToBoxAdapter(child: SizedBox(height: 2000)),
        ]),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(ItSlimHeader), findsOneWidget);
  });
}
