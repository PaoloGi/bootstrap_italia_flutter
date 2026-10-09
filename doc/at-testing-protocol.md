# Assistive-technology testing protocol (Phase 6)

This is the one thing automation cannot close. The
584 automated tests prove a role and a state are **exposed**. They cannot prove
the announcement is **intelligible**, correctly ordered, or bearable to listen
to. Those are judgements, and they need a person.

What this document does is make that person's time count. Everything mechanical
has been moved out of their way:

| Already checked automatically | Where |
| --- | --- |
| Every interactive node has a name | `test/a11y/announcement_quality_test.dart` |
| No two controls on one screen share a name | same |
| A named wrapper does not repeat its child | same |
| Roles, states and actions per component | `test/a11y/` (≈180 contracts) |
| Keyboard reachability and activation | `test/keyboard_activation_parity_test.dart` |
| Contrast against the tokens | `test/a11y/contrast_audit_test.dart` |
| Target size | `test/a11y/target_size_test.dart` |

So **do not spend a session finding unnamed buttons.** Those are already
failures. Spend it on the four things below, which no test in this repository
can answer.

## What has already been checked on a device

`AccessibilityDumpTest` (instrumented) reads what Android exposes for the
running example app — the tree TalkBack reads. Run it before a session so the
session is not spent finding things a dump would have found:

    cd example && flutter build apk --debug
    adb install -r build/app/outputs/flutter-apk/app-debug.apk
    adb install -r build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk

It needs no screen reader enabled; `uiautomator` connects as an accessibility
client itself, which is what makes Flutter build the tree at all.

Read `AccessibilityNodeInfo` directly, with the instrumented probe:

    adb shell am instrument -w -e page Alert \
      -e class com.example.bootstrap_italia_example.AccessibilityDumpTest \
      com.example.bootstrap_italia_example.test/androidx.test.runner.AndroidJUnitRunner

**Do not reach for `uiautomator dump` for this.** It cannot see `hint` (where
Android carries an editable field's name) or `stateDescription` (where expansion
lives), and Flutter's bridge puts names on containers while a leaf-level filter
throws them away. That combination produced **three false failure reports** here
before it was caught, and the scripts built on it have been deleted.

## Before you start

Generate the expected announcements and read them first:

    flutter test tool/a11y/preview      # writes doc/at-announcements.md

That file lists, per component, every semantics node with a name or role in
tree order, plus the Tab order. Knowing what *should* be said is what makes it
possible to notice what *is*.

**Where the file and the screen reader disagree, the screen reader is right,
and the disagreement is the finding.** The file is derived from Flutter's own
semantics tree; the platform layer that turns that tree into speech is exactly
the part not covered here.

## The four questions

### 1. Is the name meaningful *out of context*?

A screen reader user often meets a control in an element list, with no
surrounding text. "Rimuovi Lazio" survives that; "Rimuovi" does not — which is
why `ItChip` names the chip it removes. Look for names that only make sense
while looking at the screen.

### 2. Is it said once?

Double announcement is the most common defect in hand-built semantics and the
hardest to see in a tree dump, because both nodes are individually correct.
Listen for the label of a card, an alert or a form field arriving twice.

### 3. Does the order match the page?

Tree order and Tab order are computed separately. `doc/at-announcements.md`
prints both — if they already disagree, that is a §2.4.3 finding before the
screen reader is involved. If they agree with each other but not with the
visual layout, only a person will notice.

### 4. Is it exhausting?

The one that matters most and tests least. `ItCard` deliberately announces
"Bando per le scuole. Contributi 2026. 22 aprile 2026" as a single control,
because splitting it would give four stops that each activate the same link.
Whether that is the right trade is a judgement about listening, not about
conformance. Ten such cards in a list is the real test.

## Coverage

Three platforms, because they disagree, and the disagreements are the bugs:

| Platform | Screen reader | Notes |
| --- | --- | --- |
| iOS | VoiceOver | Rotor, and swipe-through order |
| Android | TalkBack | Explore-by-touch as well as swipe |
| Windows | NVDA + Firefox | Flutter Web only; browse vs focus mode |
| macOS | VoiceOver | Flutter Web; the rotor differs from iOS |

### Every bundled language can be heard, and each is its own evidence

The catalogue resolves **it / de / fr** from the device language setting, plus
**en** which this app opts into explicitly. Change the phone's language and the
strings follow.

That is a property worth stating because it was not always true: the example
previously declared no `supportedLocales`, so it resolved to Italian whatever
the device was set to, and the German and French tables shipped without any way
to reach them. `example/test/locale_test.dart` now pins the behaviour.

`en` is deliberately **not** in `ItLocalizations.supportedLocales` and never
auto-resolves — `MaterialApp` defaults to `en-US`, so a package that bundled it
would switch every unconfigured Italian app to English accessible names. The
example declares `en` itself and supplies the strings through
`ItLocalizationsDelegate.resolve`; opting in is those two things together, and
the hook alone does nothing.

German (Alto Adige, D.P.R. 670/1972 art. 99) and French (Valle d'Aosta,
L. cost. 4/1948 art. 38) are statutory and **have never been heard**. A session
covers the language it was run in — record which, and do not generalise one to
the others.

### What the iOS sweep leaves for VoiceOver specifically

The August 2026 iOS sweep read the accessibility tree but heard nothing. It
ended with four questions that only a listener can answer, and they are worth
doing first because each one is already known to be *at risk* rather than
merely unchecked:

1. **A radio group.** Does VoiceOver say which option is chosen? The tree
   suggests not — `ItRadio` sets `checked:` but never `selected:`, and iOS
   returns no value for mutually-exclusive nodes by design. If nothing
   distinguishes the selected option aloud, that is a §4.1.2 failure and the fix
   is a one-line `selected:`.
2. **An accordion header.** Does it say "expanded"/"collapsed"? The iOS engine
   has no code path for expansion at all, so the expected answer is no.
3. **A tab.** Is it announced as a tab, or as bare text? `SemanticsRole` is
   ignored on iOS, so expect bare text.
4. **The indeterminate checkbox** on the Checkbox page. It reports the same
   value as an unchecked box; does it *sound* different?

Record the exact spoken string for each, including when the answer is "nothing".

**Flutter Web deserves particular suspicion.** It renders to canvas with a
separate semantics overlay, and that overlay is what the screen reader reads.
It is the most likely place for the tree and the speech to diverge — and note
that axe-core cannot evaluate contrast there at all, because there are no DOM
pixels to measure, so it reports `incomplete` rather than a pass.

## Recording findings

One line per finding, in `doc/conformance.md` under *Known gaps*:

> **[component] · [platform/AT]** — what was announced, what should have been,
> and the criterion. Include the exact spoken string.

A finding without the spoken string cannot be verified by the next person.

## The claim you may make afterwards

Only what was tested, on the platforms it was tested on. This package is a
derivative work and not an official Bootstrap Italia release, and WCAG 2.1 AA
is legally binding for Italian public administration under Legge 4/2004 and
EN 301 549 — with the reference moving to 2.2. **No conformance claim should be
made before this pass exists**, and after it, the claim is bounded by the table
above rather than by the number of automated tests.
