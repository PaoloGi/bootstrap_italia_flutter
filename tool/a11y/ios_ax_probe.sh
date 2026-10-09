#!/usr/bin/env bash
# iOS accessibility probe — reads the simulator's real AX tree via `idb`.
#
# WHAT THIS SEES
#   `idb ui describe-all` returns what the iOS accessibility runtime exposes:
#   role (AXButton/AXStaticText/...), AXLabel, AXValue, custom_actions, enabled,
#   and the on-screen frame. This is the iOS analogue of reading
#   `AccessibilityNodeInfo` directly on Android — not an inference from a
#   screenshot or a log.
#
# WHAT THIS CANNOT SEE  (state these limits before quoting any result)
#   * NO HIERARCHY. The dump is a flat list; there is no parent/child link.
#     So "this Group has no name" can never be judged here — and, unlike the
#     Android sweep, absence of a name on a container must NOT be reported as a
#     finding. Only positively-identified roles are evidence.
#   * ONLY WHAT IS ON SCREEN. Off-viewport content is absent from the dump.
#     An empty result means "not scrolled to", never "missing".
#   * NO RAW UIAccessibilityTraits BITMASK. State (selected/checked/expanded)
#     is only visible where iOS surfaces it through AXValue or role_description.
#
# VERIFIED BEFORE USE
#   `--self-test` plants an unnamed button in the example app, rebuilds, and
#   asserts this probe reports it. A probe that has never been seen red is a
#   guess. See the iOS device sweep in doc/conformance.md.
set -uo pipefail

# The booted simulator, or $IOS_UDID to pick one explicitly. Do not hard-code a
# UDID here: they are per-machine, so a default that works for the author is a
# default that silently targets nothing for everyone else.
UDID="${IOS_UDID:-$(xcrun simctl list devices booted -j 2>/dev/null \
  | python3 -c "import json,sys
d=json.load(sys.stdin)['devices']
print(next((x['udid'] for v in d.values() for x in v if x.get('state')=='Booted'), ''))" 2>/dev/null)}"
if [ -z "$UDID" ]; then
  echo "No booted iOS simulator. Boot one, or set IOS_UDID=<udid>." >&2
  return 1 2>/dev/null || exit 1
fi
BUNDLE="com.example.bootstrapItaliaExample"
OUT="${OUT_DIR:-/tmp/ios_a11y}"
mkdir -p "$OUT"

dump() {  # dump <name> -> $OUT/<name>.json
  idb ui describe-all --udid "$UDID" > "$OUT/$1.json" 2>/dev/null
}

# tap_label <text> [role] : tap the centre of a FULLY-VISIBLE element whose
# AXLabel matches exactly (falling back to substring). Partially-scrolled
# elements are skipped: a 12px sliver of "Checkbox" clipped under the header
# once caused a tap on the header instead, silently navigating elsewhere.
tap_label() {
  dump _cur
  local xy
  xy=$(python3 tool/a11y/ios_pick.py "$OUT/_cur.json" "$1" "${2:-}")
  [ -z "$xy" ] && return 1
  # Split into two arguments explicitly. `idb ui tap ... $xy` looks correct and
  # is not: zsh does not word-split unquoted expansions, so idb received
  # "196 632" as a single x and errored. With stderr discarded and an
  # unconditional `return 0`, every tap "succeeded" while nothing was tapped.
  local tx ty
  read -r tx ty <<< "$xy"
  idb ui tap --udid "$UDID" "$tx" "$ty" >/dev/null 2>&1 || return 1
  sleep 1.2
  return 0
}

relaunch() {
  idb terminate --udid "$UDID" "$BUNDLE" >/dev/null 2>&1
  sleep 1
  idb launch --udid "$UDID" "$BUNDLE" >/dev/null 2>&1
  sleep 4
}

# on_detail_page : true once a detail page is showing (the catalogue root has
# no Back button). Used to VERIFY navigation rather than assume it.
on_detail_page() {
  dump _nav
  python3 - "$OUT/_nav.json" <<'PYNAV'
import json,sys
nodes=json.load(open(sys.argv[1]))
labels={(n.get("AXLabel") or "") for n in nodes}
sys.exit(0 if "Back" in labels else 1)
PYNAV
}

# goto <page label> : from a fresh launch, scroll the catalogue in SMALL steps
# until the entry is fully visible, tap it, and CONFIRM the detail page opened.
#
# Three things this had to learn the hard way:
#  * Step size. A full-height swipe jumps straight to the end of the list, where
#    "Checkbox" sits clipped to a 12px sliver under the header, untappable.
#  * `--duration`. Without it the swipe is a fling and overshoots the target.
#  * Momentum. A tap delivered while the list is still settling CANCELS the
#    scroll instead of activating the row. The tap "succeeds" and the probe
#    reports the wrong page. Hence the settle delay and the verify-and-retry.
goto() {
  relaunch
  for _ in $(seq 1 20); do
    if tap_label "$1" Button; then
      on_detail_page && return 0
      # Tap was swallowed by momentum: settle, then try the same row again.
      sleep 1.0
      tap_label "$1" Button && on_detail_page && return 0
    fi
    idb ui swipe --udid "$UDID" 200 600 200 450 --duration 0.5 >/dev/null 2>&1
    sleep 1.0
  done
  echo "!! could not reach page: $1" >&2
  return 1
}

# Pages of the example catalogue, by their catalogue label.
IOS_PAGES=(Colori Tipografia Spaziatura Button Badge Alert Spinner Chip Card
  Accordion Collapse Tab Liste Callout Input Autocompletamento Select Checkbox
  Radio Toggle Header Footer Breadcrumb Megamenu Modal Dropdown Notification)

# sweep : visit every page and record its AX tree.
sweep() {
  local failed=()
  for page in "${IOS_PAGES[@]}"; do
    if goto "$page"; then
      dump "page_$page"
      printf '  %-18s ok\n' "$page"
    else
      failed+=("$page")
      printf '  %-18s UNREACHED\n' "$page"
    fi
  done
  if [ ${#failed[@]} -gt 0 ]; then
    echo "UNREACHED PAGES (absence of findings here means nothing): ${failed[*]}"
  fi
}

# wait_stable : block until two consecutive dumps are structurally identical.
#
# This is what makes taps reliable. After a swipe the tree keeps changing for
# a while — semantics nodes materialise as they scroll in (75 nodes, then 77) —
# and a tap delivered during that window is swallowed by the scroll momentum.
# Worse, the same settling makes a naive before/after comparison report that
# the tap "worked". Settling first removes both failures at once.
wait_stable() {
  local prev="" cur
  for _ in $(seq 1 12); do
    dump _cur
    cur=$(python3 tool/a11y/ios_sig.py "$OUT/_cur.json" 2>/dev/null)
    [ -n "$cur" ] && [ "$cur" = "$prev" ] && return 0
    prev="$cur"
    sleep 0.5
  done
  return 0   # proceed anyway; the caller still verifies the outcome
}

# scroll_to_tap <label> [role] : scroll the CURRENT page until the control is
# fully on screen, tap it, and CONFIRM the tree changed as a result.
#
# A detail page exposes its WHOLE scrollable tree, so presence in the dump says
# nothing about reachability — off-screen nodes report a {0,0,0,0} frame.
scroll_to_tap() {
  local before
  for _ in $(seq 1 25); do
    wait_stable
    before=$(python3 tool/a11y/ios_sig.py "$OUT/_cur.json" 2>/dev/null)
    if tap_label "$1" "${2:-}"; then
      sleep 1.0
      dump _after
      [ "$before" != "$(python3 tool/a11y/ios_sig.py "$OUT/_after.json" 2>/dev/null)" ] \
        && return 0
    fi
    idb ui swipe --udid "$UDID" 200 600 200 450 --duration 0.5 >/dev/null 2>&1
    sleep 1.0
  done
  return 1
}
