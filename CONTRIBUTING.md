# Contributing

Thanks for looking at this. Two things are worth knowing before you start,
because they shape almost every rule below.

**1. Accessibility is the acceptance criterion, not a later phase.** Italian
public administration services are bound by Legge 4/2004 and EU Directive
2016/2102 to EN 301 549, whose web clauses are satisfied by WCAG AA. A pull
request that improves how something *looks* while degrading how it is
*announced* is a regression, no matter how good the screenshot is.

**2. Bootstrap Italia's compiled CSS is normative.** Not the React kit's
rendering, not intuition, and not Bootstrap 5 defaults — Bootstrap Italia
overrides many of them. Every value in this package should be traceable to a
rule in `bootstrap-italia.min.css`, and by convention the rule is quoted in a
comment at the point of use.

## Setup

```bash
flutter pub get
bash tool/visual_parity/setup.sh    # Python venv, Playwright, Chromium
```

`setup.sh` also runs `tool/fetch_bootstrap_italia.sh`, which pins and downloads
the exact Bootstrap Italia release (**2.18.0**) this port is verified against.
That stylesheet is the normative source for every value here; it is a
third-party build artifact so it is not committed, and fetching it pinned is
what makes "we matched the CSS" checkable by someone else.

## The checks, and what each is for

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos lib test
flutter test
```

Then, for anything visual or interactive:

```bash
# Guards the similarity metric itself — run this FIRST. A metric that has
# quietly become permissive makes every number after it meaningless.
tool/visual_parity/.venv/bin/python tool/visual_parity/diff/metric_selftest.py

flutter test tool/visual_parity/capture     # capture the Flutter side
node tool/visual_parity/playwright/capture.mjs   # capture the reference
tool/visual_parity/.venv/bin/python tool/visual_parity/diff/report.py --threshold 95
```

And for anything that changes interaction, focus or semantics:

```bash
cd example && flutter build web -t lib/parity_harness.dart --no-tree-shake-icons
(cd example/build/web && python3 -m http.server 8777 &)
node tool/a11y/axe_audit.mjs
```

See [`tool/visual_parity/README.md`](tool/visual_parity/README.md) for how the
harness works and why it is shaped the way it is.

## Rules that exist because something went wrong

Each of these is a real defect this package shipped. They are not style
preferences.

- **Never replace a Material widget with custom painting without carrying over
  its semantics.** Doing exactly that removed checked state, focus, keyboard
  operability and hit-target expansion from every form control. Custom painting
  is fine and often necessary — silent loss of role or state is not.
- **Use `DefaultTextStyle.merge`, never the bare constructor**, and always set
  `fontFamily`/`package` on a `TextStyle` you hand to a Flutter API that
  *replaces* rather than merges. Otherwise the font is dropped and text renders
  as missing-glyph boxes.
- **Do not port CSS `transform: translateY(...)` nudges literally.** They usually
  compensate for flexbox baseline behaviour Flutter does not share, so copying
  them shifts the widget the wrong way.
- **A `border` in `BoxDecoration` is laid out.** Where the CSS uses an *inset*
  box-shadow, use `foregroundDecoration` — otherwise the control grows and no
  longer matches its filled counterpart.
- **Set `height:` (line-height) explicitly** on any control that does not inherit
  a Material text theme, or the font's own metrics change the box size.
- **`Container` with an `alignment` expands to fill its constraints.** Wrap in
  `IntrinsicWidth` when you want content-sized-with-a-minimum.
- **`Stack` clips by default** — `clipBehavior: Clip.none` for anything positioned
  at a negative offset.
- **A screenshot is not evidence of a colour.** Sample the pixel and compare it
  numerically against the CSS value.
- **A passing test run is not evidence of a correct merge.** Two separate merges
  in this repo looked clean while silently deleting work; both were caught by
  counting tests, not by the suite going red.
- **There is exactly one focus-ring implementation**
  (`lib/src/a11y/it_focus_ring.dart`). Extend it; do not add a second.

## Accessibility contracts

`test/a11y/semantics_contract_test.dart` asserts role, name, state and actions on
Flutter's own semantics tree — which means the contracts hold on Android and iOS,
where there is no DOM. Extend it for anything you add.

**axe-core is necessary but not sufficient.** It passed a checkbox exposed as a
named button, because that is valid ARIA — just wrong for a screen-reader user,
who is never told whether the box is checked. Only explicit role/state contracts
catch that class of defect, so never treat a clean axe run as proof.

If you believe a contract is wrong, say so and argue it from the WCAG success
criterion. Do not weaken it to make a build pass.

## Relationship to the official design system

This is an unofficial port (see [`NOTICE.md`](NOTICE.md)). It reuses the design
specification under BSD-3-Clause and claims no endorsement. If Developers Italia
would like to adopt, fork or replace it, that is a welcome outcome — their
existing convention would make it `italia/design-flutter-kit`, alongside
`design-react-kit`, `design-angular-kit` and `design-vue-kit`. Until then it is
deliberately named `bootstrap_italia_flutter` — derivative and unmistakably
unofficial — rather than claiming either their package name or their namespace.

Open questions that need a maintainer's judgement rather than more code are
listed at the end of [`doc/conformance.md`](doc/conformance.md).
