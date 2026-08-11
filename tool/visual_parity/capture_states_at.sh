#!/usr/bin/env bash
# Capture one parity key in every interaction state, aiming the pointer at an
# explicit fraction of the component box rather than at its centre.
#   ./capture_states_at.sh <port> <fx,fy> <key> [key...]
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="$1"; shift
AT="$1"; shift
export PARITY_WEB_BASE="http://localhost:${PORT}"
for key in "$@"; do
  for state in default hover active focus; do
    node "$HERE/playwright/capture_flutter_point.mjs" "$key" "$state" \
      --at "$AT" --out flutter_web_states
  done
done
