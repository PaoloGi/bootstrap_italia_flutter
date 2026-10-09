#!/usr/bin/env python3
"""Pick the tap point for a label in an `idb ui describe-all` dump.

Only fully-visible elements are eligible. A 12px sliver of "Checkbox" clipped
under the header once won the match and the resulting tap hit the header,
navigating to an unrelated page while the probe reported success.
"""
import json, sys

nodes = json.load(open(sys.argv[1]))
want = sys.argv[2].lower()
role = sys.argv[3] if len(sys.argv) > 3 else ""
# The SCREEN, not the content. A detail page returns its whole scrollable tree
# with real frames, so deriving the viewport from node extents gave the content
# height (~3000px) and elements far below the fold were judged "fully visible".
# The resulting tap fired at an off-screen y and silently did nothing.
app = next((n for n in nodes if (n.get("role") or "") == "AXApplication"), None)
screen_h = app["frame"]["height"] if app else max(
    n["frame"]["y"] + n["frame"]["height"] for n in nodes)

def usable(n):
    f = n["frame"]
    if f["height"] < 20 or f["width"] < 20:      return False  # clipped sliver
    if f["y"] < 115:                             return False  # under the header
    if f["y"] + f["height"] > screen_h - 5:      return False  # under the home bar
    if role and role.lower() not in (n.get("role") or "").lower(): return False
    return True

cands = [n for n in nodes if usable(n)]
exact = [n for n in cands if (n.get("AXLabel") or "").lower() == want]
part  = [n for n in cands if want in (n.get("AXLabel") or "").lower()]
pick = exact or part
if pick:
    f = pick[0]["frame"]
    print(f"{f['x'] + f['width'] / 2:.0f} {f['y'] + f['height'] / 2:.0f}")
