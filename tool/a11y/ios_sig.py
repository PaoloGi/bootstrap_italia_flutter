#!/usr/bin/env python3
"""Structural signature of an AX dump: node count, labels, AND scroll position.

Two things depend on this and each needs a different part of it:

* `wait_stable` needs MOTION to show up, so frames are included — rounded to
  4px, because identical dumps jitter by sub-pixel amounts.
* the text-scale sweep needs to know when a page has stopped scrolling. A
  detail page exposes its ENTIRE tree no matter where it is scrolled, so a
  signature built from labels alone is scroll-invariant: it reported "bottom
  reached" after two screens and the sweep silently checked almost nothing.
"""
import json, sys

nodes = json.load(open(sys.argv[1]))
parts = []
for n in nodes:
    f = n["frame"]
    parts.append("%s@%d,%d" % ((n.get("AXLabel") or "")[:16],
                               round(f["y"] / 4) * 4, round(f["height"] / 4) * 4))
print(len(nodes), "|", "|".join(parts))
