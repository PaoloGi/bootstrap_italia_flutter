// `.collapse` / `.collapsing`, and the relationship a trigger owes its panel.
//
// Two things came out of mirroring the Bootstrap Italia docs page for Collapse.
// The transition was wrong on both counts — 300ms `ease-in-out` against the
// stylesheet's `.35s ease` — and the docs' longest section is about the trigger
// rather than the panel: `aria-expanded`, `aria-controls`, `role="button"`.
// None of that could be expressed here, so every caller was writing raw
// `Semantics` or, more often, nothing at all.
import 'package:bootstrap_italia_flutter/bootstrap_italia_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => BootstrapItaliaTheme(
      data: BootstrapItaliaThemeData.standard(),
      child: MaterialApp(
        theme: BootstrapItaliaThemeData.standard().toThemeData(),
        home: Scaffold(body: SizedBox(width: 600, child: child)),
      ),
    );

void main() {
  group('the transition matches `.collapsing`', () {
    test('.35s, not .3s', () {
      const collapse = ItCollapse(isExpanded: false, child: SizedBox());
      expect(collapse.duration, const Duration(milliseconds: 350),
          reason: '`.collapsing { transition: height .35s ease }`');
    });

    test('`ease`, not `ease-in-out`', () {
      const collapse = ItCollapse(isExpanded: false, child: SizedBox());
      expect(collapse.curve, Curves.ease);
      // The two are genuinely different curves, not two names for one: CSS
      // `ease` is cubic-bezier(.25,.1,.25,1) and `ease-in-out` is
      // cubic-bezier(.42,0,.58,1), which is why the panel used to feel slower
      // off the mark than the kit's.
      expect(const Cubic(0.25, 0.1, 0.25, 1.0).transform(0.25),
          Curves.ease.transform(0.25));
      expect(Curves.easeInOut.transform(0.25),
          isNot(closeTo(Curves.ease.transform(0.25), 0.02)));
    });

    testWidgets('the panel is fully open once the duration has elapsed',
        (t) async {
      // Measured on the ItCollapse, not on its child: SizeTransition clips
      // rather than resizing, so the child reports its full 60px throughout
      // and only the collapse's own box tells you how much of it is showing.
      double revealed() => t.getSize(find.byType(ItCollapse)).height;

      await t.pumpWidget(_host(const _Toggler()));
      expect(revealed(), 0);

      await t.tap(find.text('Apri'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 340));
      expect(revealed(), lessThan(60),
          reason: 'still in flight ten milliseconds before the end');

      await t.pumpAndSettle();
      expect(revealed(), 60);
    });
  });

  group('semanticsIdentifier — the `id` an `aria-controls` points at', () {
    testWidgets('exposed when given', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(const ItCollapse(
        isExpanded: true,
        semanticsIdentifier: 'dettagli',
        child: Text('Contenuto'),
      )));
      await t.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier('dettagli'),
        findsOneWidget,
        reason: 'the kit\'s docs call this out as what lets a screen reader '
            'offer a jump straight to the collapsible element',
      );
      handle.dispose();
    });

    testWidgets('adds no node when omitted', (t) async {
      // Every accordion panel, callout body and megamenu section in the package
      // wraps an ItCollapse. An unconditional Semantics node would put one
      // extra node under each of them for the sake of a string none of them
      // passes.
      await t.pumpWidget(_host(const ItCollapse(
        isExpanded: true,
        child: Text('Contenuto'),
      )));
      expect(
        find.descendant(
            of: find.byType(ItCollapse), matching: find.byType(Semantics)),
        findsNothing,
      );
    });
  });
}

/// A button and the panel it opens, wired the way the docs' example is.
class _Toggler extends StatefulWidget {
  const _Toggler();

  @override
  State<_Toggler> createState() => _TogglerState();
}

class _TogglerState extends State<_Toggler> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ItCollapseToggle(
          expanded: _open,
          controls: const {'esempio'},
          child: ItButton(
            onPressed: () => setState(() => _open = !_open),
            child: const Text('Apri'),
          ),
        ),
        ItCollapse(
          isExpanded: _open,
          semanticsIdentifier: 'esempio',
          child: const SizedBox(key: ValueKey('body'), height: 60),
        ),
      ],
    );
  }
}
