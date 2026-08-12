# Assistive-technology testing protocol (Phase 6)

This is the one item in `quality-plan.md` that automation cannot close. The
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
