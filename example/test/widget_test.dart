// Smoke test for the catalog app.
//
// This replaces the `flutter create` counter-app template, which referenced a
// nonexistent `MyApp` and could not compile — 17 analyzer errors that were
// invisible because the example was never analysed in CI.
//
// The value here is integration: it is the only test that boots the whole
// catalog, so it catches an export missing from `bootstrap_italia.dart` or a
// breaking constructor change that the package's own unit tests, which import
// widgets directly, would not notice.
import 'package:bootstrap_italia_example/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('catalog boots and renders its home page', (tester) async {
    await tester.pumpWidget(const BootstrapItaliaCatalog());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Bootstrap Italia Flutter'), findsWidgets);
  });
}
