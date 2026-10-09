#!/usr/bin/env bash
# Proves the guards can fail.
#
# A guard nobody has seen red is a guess. In one session this project produced
# five checks that could not fail or actively lied:
#
#   * `git status` on a gitignored directory — visual parity fell from 73/74 to
#     65/74 behind it, with no test red
#   * unnamed *leaf* nodes counted as defects, when Flutter's Android bridge
#     puts names on containers — three false failure reports
#   * Flutter overflow errors read from logcat, which never receives them
#   * `uiautomator` unable to report `hint`, so a correctly-named field looked
#     unnamed
#   * a stale APK, so a reverted experiment still appeared present
#
# Two hid real regressions; two invented failures that were reported as real.
#
# So: for each guard, plant the defect it exists to catch, assert it turns red,
# and restore. A guard that stays green under its own mutation is broken, and
# this script fails the build for it.
#
#   tool/mutation_check.sh            # all mutations
#   tool/mutation_check.sh tokens     # one, by name
set -uo pipefail
cd "$(dirname "$0")/.."

PASS=0; FAIL=0
only="${1:-}"

# run_mutation <name> <target-file> <mutate-fn> <test-command>
run_mutation() {
  local name="$1" file="$2" mutate="$3" cmd="$4"
  [ -n "$only" ] && [ "$only" != "$name" ] && return 0

  # BASELINE FIRST. A guard that is broken for an unrelated reason — a missing
  # interpreter, an absent venv, a renamed test path — also exits non-zero after
  # the mutation, and would be scored as having caught it. That is the very
  # failure this script exists to catch, and it was present here: `parity_cmd`
  # falls back to a bare `python3`, so on a machine without the harness deps it
  # would have reported `caught` while never scoring anything.
  #
  # So the command must PASS on clean code before its failure means anything.
  if ! eval "$cmd" >/dev/null 2>&1; then
    printf '  \033[31mBROKEN\033[0m         %-26s (fails on CLEAN code - the guard, not the code)\n' \
      "$name"
    FAIL=$((FAIL + 1))
    return 0
  fi

  local backup; backup="$(mktemp)"
  cp "$file" "$backup"
  "$mutate" "$file"

  # The mutation must actually change something. These are string replacements
  # against real source, and source drifts: a target that no longer matches
  # leaves the file untouched, the guard then passes for the honest reason, and
  # the run reports STAYED GREEN as though the guard were broken. Worse, a
  # `replace(..., 1)` that silently no-ops is indistinguishable from a guard
  # that works. Say so instead.
  if cmp -s "$file" "$backup"; then
    printf '  \033[31mNO-OP\033[0m          %-26s (mutation no longer applies - target moved)\n' \
      "$name"
    FAIL=$((FAIL + 1))
    cp "$backup" "$file"; rm -f "$backup"
    return 0
  fi

  # The guard MUST fail now. Output is discarded; only the exit code matters.
  if eval "$cmd" >/dev/null 2>&1; then
    printf '  \033[31mSTAYED GREEN\033[0m  %-26s (%s)\n' "$name" "${file#./}"
    FAIL=$((FAIL + 1))
  else
    printf '  caught         %-26s (%s)\n' "$name" "${file#./}"
    PASS=$((PASS + 1))
  fi

  cp "$backup" "$file"; rm -f "$backup"
}

# ── mutations ───────────────────────────────────────────────────────────────

mutate_token() {   # a palette hex written literally in a component
  python3 - "$1" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); s = p.read_text()
s = s.replace('class ItBadge extends StatelessWidget {',
              'class ItBadge extends StatelessWidget {\n'
              '  static const _mut = Color(0xFF0066CC);\n', 1)
p.write_text(s)
PY
}

mutate_import() {  # material.dart imported without a Material symbol
  python3 - "$1" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); s = p.read_text()
s = s.replace("import 'package:flutter/widgets.dart';",
              "import 'package:flutter/material.dart';", 1)
p.write_text(s)
PY
}

mutate_api() {     # a renamed public parameter
  python3 - "$1" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); s = p.read_text()
s = s.replace('  final int max;', '  final int maximum;', 1)
s = s.replace('this.max = 99,', 'this.maximum = 99,', 1)
s = s.replace('count > max ? ', 'count > maximum ? ', 1)
s = s.replace("'$max+'", "'$maximum+'", 1)
p.write_text(s)
PY
}

mutate_font() {    # a component stops naming its font family
  python3 - "$1" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1]); s = p.read_text()
s = re.sub(r'\n\s*fontFamily: BootstrapItaliaFontFamily\.sansSerif,'
           r'\n\s*package: BootstrapItaliaFontFamily\.package,', '', s, count=1)
p.write_text(s)
PY
}

mutate_formfield() { # a field silently opts out of its enclosing Form
  python3 - "$1" <<'PY'
import sys, pathlib, re
p = pathlib.Path(sys.argv[1]); s = p.read_text()
s = re.sub(r'bool get _isFormField =>\s*\n?\s*widget\.validator != null \|\| widget\.onSaved != null;',
           'bool get _isFormField => false;', s, count=1)
p.write_text(s)
PY
}

mutate_textscale() { # a band goes back to a pinned height
  python3 - "$1" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); s = p.read_text()
s = s.replace('height: MediaQuery.textScalerOf(context).scale(_height),',
              'height: _height,', 1)
p.write_text(s)
PY
}

mutate_keyboard() { # a control loses one activation intent
  python3 - "$1" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); s = p.read_text()
s = s.replace('        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(\n'
              '          onInvoke: (_) {\n'
              '            widget.onPressed?.call();\n'
              '            return null;\n'
              '          },\n'
              '        ),\n', '', 1)
s = s.replace('        ActivateIntent: CallbackAction<ActivateIntent>(\n'
              '          onInvoke: (_) {\n'
              '            widget.onPressed?.call();\n'
              '            return null;\n'
              '          },\n'
              '        ),\n', '', 1)
p.write_text(s)
PY
}

mutate_a11y_coverage() {  # a new exported widget with no contract
  python3 - "$1" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); s = p.read_text()
s += ('\n\n/// Planted by tool/mutation_check.sh.\n'
      'class ItMutationWidget extends StatelessWidget {\n'
      '  const ItMutationWidget({super.key});\n'
      '  @override\n'
      '  Widget build(BuildContext context) => const SizedBox.shrink();\n'
      '}\n')
p.write_text(s)
PY
}

mutate_parity() {  # a component's fill changed to a different scheme colour
  # Deliberately NOT a hex literal: that would trip token hygiene instead, and
  # this mutation must reach the parity harness specifically.
  python3 -c "
import pathlib
p = pathlib.Path('$1'); s = p.read_text()
# The variant fill every solid button paints. The previous target lived
# inside \`if (w.link)\`, and the core group has no link-button capture — so the
# planted defect reached a code path nothing measures and the guard was
# correct to stay green. A mutation has to land where the metric can see it.
s = s.replace('var bgColor =\n        w.backgroundColor ?? colors.forVariant(w.variant.variantColor);',
              'var bgColor = w.backgroundColor ?? colors.success;', 1)
p.write_text(s)
"
}

# Visual parity is the guard that once failed silently: it fell from 73/74 to
# 65/74 behind a \`git status\` on a gitignored directory, with nothing red.
# Captures must be REGENERATED before scoring, or the score reflects stale PNGs
# and passes regardless of the mutation.
# Is the visual-parity harness actually installed here? `parity_cmd` falls back
# to a bare `python3`, which exists everywhere and imports none of what the
# scorer needs — so without this the parity guard would run, fail for the wrong
# reason, and be reported as BROKEN on any machine that has not run setup.sh.
parity_harness_ready() {
  local py=tool/visual_parity/.venv/bin/python
  [ -x "$py" ] || py=python3
  "$py" -c 'import numpy, PIL, skimage' >/dev/null 2>&1
}

parity_cmd() {
  flutter test tool/visual_parity/capture/parity_core_test.dart >/dev/null 2>&1
  local py=tool/visual_parity/.venv/bin/python
  [ -x "$py" ] || py=python3
  # Threshold 94, NOT the project's 95, and deliberately so. `badge_pill` is a
  # known 94.91% miss (a 1px text-advance rounding difference) and it lives in
  # the core group, so at 95 this command exits non-zero on CLEAN code. That is
  # exactly what it did: red before the mutation and red after it, which the
  # checker scored as `caught`. The guard protecting against the parity
  # regression that once went from 73/74 to 65/74 unnoticed was itself unable
  # to notice anything.
  #
  # 94 lets the known miss through while still catching the mutation, which
  # moves a component's fill a whole step and drops it far below either number.
  "$py" tool/visual_parity/diff/report.py core --threshold 94
}

echo "planting defects; each guard must turn red"
echo

run_mutation tokens    lib/src/components/badge/it_badge.dart \
             mutate_token    "flutter test test/token_hygiene_test.dart"

run_mutation imports   lib/src/components/chip/it_chip.dart \
             mutate_import   "flutter test test/import_hygiene_test.dart"

run_mutation api       lib/src/components/badge/it_badge.dart \
             mutate_api      "flutter test test/public_api_snapshot_test.dart"

run_mutation font      lib/src/components/chip/it_chip.dart \
             mutate_font     "flutter test test/no_ambient_material_test.dart"

run_mutation keyboard  lib/src/a11y/it_activatable.dart \
             mutate_keyboard "flutter test test/keyboard_activation_parity_test.dart"

run_mutation a11y-coverage lib/src/components/badge/it_badge.dart \
             mutate_a11y_coverage "flutter test test/a11y_coverage_test.dart"

run_mutation textscale lib/src/components/header/it_center_header.dart \
             mutate_textscale \
             "flutter test test/a11y/text_scale_overflow_test.dart"

# One guard per control, not one for the group: they are separate
# implementations of the same opt-in, and a guard that only ever sees ItInput
# would let the other four rot without a word.
for _ff in it_input:input it_select:select it_checkbox:checkbox \
           it_radio:radio it_toggle:toggle; do
  run_mutation "formfield-${_ff##*:}" "lib/src/form/${_ff%%:*}.dart" \
               mutate_formfield \
               "flutter test test/a11y/form_participation_test.dart"
done

if parity_harness_ready; then
  run_mutation parity    lib/src/components/button/it_button.dart \
               mutate_parity   "parity_cmd"
else
  # Announced, not silent. A guard that quietly disappears is how a suite ends
  # up protecting less than its output suggests.
  printf '  SKIPPED        %-26s (parity harness not installed - see tool/visual_parity/setup.sh)\n' \
    "parity"
fi

# The captures now hold the mutated button; regenerate from restored source.
if [ -z "$only" ] || [ "$only" = "parity" ]; then
  flutter test tool/visual_parity/capture/parity_core_test.dart >/dev/null 2>&1
fi

echo
if [ "$FAIL" -gt 0 ]; then
  echo "$FAIL guard(s) did not detect their own defect — they are not protecting anything."
  exit 1
fi
echo "all $PASS guards caught their planted defect"
