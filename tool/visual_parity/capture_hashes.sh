#!/usr/bin/env bash
# Prints a hash per Flutter capture, for detecting a changed rendering.
#
# `git status tool/visual_parity/flutter_captures` CANNOT do this: that
# directory is in .gitignore (the PNGs are regeneratable), so the command
# always prints nothing and always looks like success. It was used as a
# verification step for a long time and could never have failed.
#
#   tool/visual_parity/capture_hashes.sh > /tmp/before.txt
#   flutter test tool/visual_parity/capture
#   tool/visual_parity/capture_hashes.sh > /tmp/after.txt
#   diff /tmp/before.txt /tmp/after.txt
#
# A non-empty diff means a default rendering moved. That is not automatically
# wrong — but it must be deliberate, and `diff/report.py` is what says whether
# it moved toward the reference or away from it.
set -euo pipefail
cd "$(dirname "$0")/flutter_captures"
for f in *.png; do
  printf '%s  %s\n' "$(shasum -a 256 "$f" | cut -d' ' -f1)" "$f"
done
