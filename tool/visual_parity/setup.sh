#!/usr/bin/env bash
# Prepare a checkout (main repo or a git worktree) to run the visual-parity
# harness. The Python venv and node_modules are gitignored and expensive to
# rebuild, so a worktree symlinks them from the primary checkout instead.
set -euo pipefail

PRIMARY="${VISUAL_PARITY_PRIMARY:-/Users/paologianfelici/Development/Test/bootstrap_italia_flutter}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

mkdir -p "$HERE/reference" "$HERE/flutter_captures" "$HERE/diffs"

if [ "$REPO" != "$PRIMARY" ]; then
  [ -e "$HERE/.venv" ] || ln -s "$PRIMARY/tool/visual_parity/.venv" "$HERE/.venv"
  [ -e "$HERE/playwright/node_modules" ] || \
    ln -s "$PRIMARY/tool/visual_parity/playwright/node_modules" "$HERE/playwright/node_modules"
  # tool/a11y/axe_audit.mjs resolves axe-core through its own node_modules;
  # without this it dies with ERR_MODULE_NOT_FOUND in a fresh worktree.
  [ -e "$REPO/tool/a11y/node_modules" ] || \
    ln -s "$PRIMARY/tool/visual_parity/playwright/node_modules" "$REPO/tool/a11y/node_modules"
  # Reference PNGs are deterministic upstream output; reuse to avoid refetching.
  for png in "$PRIMARY/tool/visual_parity/reference"/*.png; do
    [ -e "$png" ] && ln -sf "$png" "$HERE/reference/" || true
  done

  # Sync shared harness code from the primary checkout so every worktree runs
  # an identical harness even when it is newer than the branch point. Group
  # configs and per-group test files are NOT synced: those are each agent's own.
  mkdir -p "$HERE/playwright/components" "$HERE/diff" "$HERE/capture"
  cp "$PRIMARY/tool/visual_parity/playwright"/*.mjs "$HERE/playwright/"
  cp "$PRIMARY/tool/visual_parity/playwright/package.json" "$HERE/playwright/"
  cp "$PRIMARY/tool/visual_parity/diff"/*.py "$HERE/diff/"
  cp "$PRIMARY/tool/visual_parity/capture/capture_helpers.dart" "$HERE/capture/"
  cp "$PRIMARY/test/flutter_test_config.dart" "$REPO/test/"
fi

# The compiled Bootstrap Italia stylesheet is the normative source for every
# value in this package. It is a third-party build artifact so it is not
# committed; fetch it pinned instead, or "we matched the CSS" is unverifiable.
bash "$REPO/tool/fetch_bootstrap_italia.sh"

cd "$REPO"
flutter pub get >/dev/null

echo "ready: $REPO"
echo "  capture refs : node tool/visual_parity/playwright/capture.mjs <group>"
echo "  capture dart : flutter test tool/visual_parity/capture/parity_<group>_test.dart"
echo "  score        : tool/visual_parity/.venv/bin/python tool/visual_parity/diff/report.py <group> --threshold 95"
