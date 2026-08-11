#!/usr/bin/env bash
# Reports the project's current numbers, so no document has to quote them.
#
# Counting `testWidgets(` occurrences statically gives the wrong answer — this
# suite generates tests in loops, so the static count reads ~131 where the
# runner reports ~167. Only the runner knows.
set -euo pipefail
cd "$(dirname "$0")/.."

printf 'Tests:                  '
flutter test 2>&1 | grep -oE '\+[0-9]+' | tail -1 | tr -d '+'

printf 'Accessibility contracts: '
flutter test test/a11y 2>&1 | grep -oE '\+[0-9]+' | tail -1 | tr -d '+'

printf 'Visual parity:           '
if [ -d tool/visual_parity/.venv ]; then
  tool/visual_parity/.venv/bin/python tool/visual_parity/diff/report.py 2>/dev/null \
    | grep 'at or above' || echo 'harness not set up'
else
  echo 'run tool/visual_parity/setup.sh first'
fi
