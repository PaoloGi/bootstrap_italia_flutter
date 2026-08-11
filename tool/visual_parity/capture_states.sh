#!/usr/bin/env bash
# Capture a set of parity keys in every interaction state.
#   ./capture_states.sh <port> <key> [key...]
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="$1"; shift
export PARITY_WEB_BASE="http://localhost:${PORT}"
for key in "$@"; do
  for state in default hover active focus; do
    node "$HERE/playwright/capture_flutter_web.mjs" "$key" "$state" \
      --out flutter_web_states
  done
done
