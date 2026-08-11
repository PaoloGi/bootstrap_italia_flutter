#!/usr/bin/env bash
# Capture every interaction-state probe key, each aimed at the point that
# actually lands on its target. Written as one script so the "before" and
# "after" passes are byte-for-byte the same procedure.
#   ./capture_all_states.sh <port> <outDir>
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="$1"
OUT="$2"
export PARITY_WEB_BASE="http://localhost:${PORT}"
POINT="$HERE/playwright/capture_flutter_point.mjs"

shoot() { # key aim
  for state in default hover active focus; do
    node "$POINT" "$1" "$state" --at "$2" --out "$OUT"
  done
}

# Shrink-wrapped components: the centre is the target.
shoot hover_chip 0.5,0.5
shoot hover_chip_disabled 0.5,0.5
shoot hover_backtotop 0.5,0.5
shoot hover_backtotop_dark 0.5,0.5
shoot hover_card_category 0.5,0.5
shoot hover_dropdown_item 0.5,0.5
shoot hover_list_item 0.5,0.5
shoot hover_list_item_active 0.5,0.5
shoot hover_accordion_header 0.5,0.5
shoot hover_footer_link 0.5,0.5

# Full-bleed components whose target sits at the left edge.
shoot hover_tab 0.03,0.5
shoot hover_tab_active 0.03,0.5
shoot hover_nav_header_link 0.05,0.5
shoot hover_breadcrumb_link 0.05,0.5
# The slim header pushes its link list past a Spacer, so the target sits at the
# right edge, not the left.
shoot hover_slim_header_link 0.89,0.5
