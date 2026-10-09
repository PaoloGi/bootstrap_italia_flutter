#!/usr/bin/env bash
# §1.4.4 Resize Text on iOS, driven by the OS rather than by the app.
#
# Unlike the Android device (whose ROM refuses WRITE_SETTINGS), the simulator
# honours `simctl ui content_size`, so the scale comes from iOS itself.
#
# Scale reference, from the engine on this machine — FlutterViewController.mm
# computes textScaleFactor as body-point-size / 17:
#     large                        17/17 = 1.00   (default)
#     accessibility-large          33/17 = 1.94   <-- just UNDER the 200% WCAG asks for
#     accessibility-extra-large    40/17 = 2.35   <-- the smallest category that satisfies it
#     accessibility-XXXL           53/17 = 3.12
# So 1.4.4 is tested at accessibility-extra-large, not accessibility-large.
#
# See tool/a11y/ios_hazard.py for what the pixel test can and cannot see.
set -uo pipefail
cd "$(dirname "$0")/../.."
source tool/a11y/ios_ax_probe.sh

CATEGORY="${1:-accessibility-extra-large}"
# Max scroll steps per page. A page that hits this cap was NOT read to the end,
# and the sweep says so rather than reporting a clean page it never finished.
MAXSTEP="${MAXSTEP:-25}"
PAGES_OVERRIDE="${PAGES:-}"
SHOTS="${SHOTS:-/tmp/ios_scale}"
mkdir -p "$SHOTS"; rm -f "$SHOTS"/*.png

xcrun simctl ui "$UDID" content_size "$CATEGORY" >/dev/null 2>&1
echo "text scale category: $(xcrun simctl ui "$UDID" content_size)"

[ -n "$PAGES_OVERRIDE" ] && IOS_PAGES=($PAGES_OVERRIDE)
for page in "${IOS_PAGES[@]}"; do
  if ! goto "$page"; then printf '  %-18s UNREACHED\n' "$page"; continue; fi
  shots=(); prev=""; capped=""
  for step in $(seq 1 "$MAXSTEP"); do
    sleep 1.2                                   # let the scroll settle
    # 620pt of an 852pt screen: every part of the page appears in at least one
    # screenshot, with ~230pt of overlap so a hazard stripe cannot fall between
    # two shots. Pages that reached their end at a smaller step size remain
    # valid — where a page ENDS does not depend on how far each swipe travels.
    f="$SHOTS/${page}_$step.png"
    xcrun simctl io "$UDID" screenshot "$f" >/dev/null 2>&1

    # Bottom detection compares SCREENSHOTS, not the accessibility tree. On the
    # Header page only 5 of 148 nodes report a non-zero frame, so the tree is
    # identical across three different scroll positions — the first version of
    # this sweep believed it and called the densest page in the catalogue clean
    # after 3 screens, missing 3,577 hazard pixels.
    #
    # An unchanged screenshot is still not proof of the end: a swipe that gets
    # swallowed produces exactly the same evidence. Tipografia stopped at H3
    # that way. So a second swipe is tried from a different origin, and only if
    # THAT also fails to move anything is the page treated as finished.
    if [ -n "$prev" ] && python3 tool/a11y/ios_same.py "$prev" "$f"; then
      idb ui swipe --udid "$UDID" 330 700 330 160 --duration 0.7 >/dev/null 2>&1
      sleep 1.4
      xcrun simctl io "$UDID" screenshot "$f" >/dev/null 2>&1
      if python3 tool/a11y/ios_same.py "$prev" "$f"; then
        rm -f "$f"; break                        # genuinely the end of the page
      fi
    fi
    shots+=("$f"); prev="$f"
    idb ui swipe --udid "$UDID" 200 760 200 140 --duration 0.5 >/dev/null 2>&1
  done
  [ "${#shots[@]}" -ge "$MAXSTEP" ] && capped="  CAPPED - page not read to the end"
  n=$(python3 tool/a11y/ios_hazard.py "${shots[@]}" | tail -1)
  printf '  %-18s %2d screens  hazard=%s%s\n' "$page" "${#shots[@]}" "$n" "$capped"
done
xcrun simctl ui "$UDID" content_size large >/dev/null 2>&1
echo "restored to: $(xcrun simctl ui "$UDID" content_size)"
