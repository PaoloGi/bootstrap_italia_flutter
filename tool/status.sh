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
  # `report.py` exits non-zero whenever a key is below threshold, which is a
  # normal state — one is. Under `set -o pipefail` that made the pipeline fail
  # and the `||` fire, so the script printed a correct parity number AND
  # "harness not set up" underneath it. Capture first, then decide.
  parity=$(tool/visual_parity/.venv/bin/python \
    tool/visual_parity/diff/report.py 2>/dev/null | grep 'at or above' || true)
  if [ -n "$parity" ]; then
    echo "$parity"
  else
    echo 'harness not set up'
  fi
else
  echo 'run tool/visual_parity/setup.sh first'
fi

printf 'Device soak:             '
if xcrun simctl list devices booted 2>/dev/null | grep -q iPhone; then
  echo 'cd example && flutter test integration_test/device_soak_test.dart -d <id>'
else
  echo 'boot a simulator or attach a device first'
fi

printf 'Web soak:                '
if [ -d tool/visual_parity/playwright/node_modules ]; then
  echo 'node tool/visual_parity/playwright/soak.mjs (needs the page served)'
else
  echo 'npm ci --prefix tool/visual_parity/playwright first'
fi
