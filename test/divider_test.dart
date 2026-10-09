// `.divider { display:block; height:1px; background:hsl(210,4%,78%); margin:8px 0 }`
//
// Material's Divider is 16px tall and takes its colour from the Material theme,
// so a page mixing the two draws two different rules.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('one pixel of hsl(210,4%,78%), with 8px above and below',
      (t) async {
    await t.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 200, child: ItDivider())),
    ));

    final line = t.getRect(find.byType(ColoredBox));
    expect(line.height, 1);
    expect(t.widget<ColoredBox>(find.byType(ColoredBox)).color,
        const Color(0xFFC5C7C9));
    expect(t.getRect(find.byType(ItDivider)).height, 1 + 8 + 8);
  });

  testWidgets('a rule says nothing to a screen reader', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: SizedBox(width: 200, child: ItDivider())),
    ));
    expect(find.byType(ExcludeSemantics), findsOneWidget);
    handle.dispose();
  });
}
