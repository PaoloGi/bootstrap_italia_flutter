#!/usr/bin/env python3
"""Count Flutter's overflow hazard-stripe pixels (RGB 255,255,64) in screenshots.

WHAT THIS DETECTS: a RenderFlex/RenderBox overflow, which Flutter paints as a
yellow-and-black stripe in a debug build.

WHAT THIS DOES NOT DETECT: clipping. Text truncated by a ClipRect, a fixed
height, or maxLines is NOT an overflow and paints no stripe. A page can lose
text at large type sizes and score zero here. Screenshots are kept so the
result can be checked by eye; see the iOS device sweep in doc/conformance.md.
"""
import sys
from PIL import Image

HAZARD = (255, 255, 64)
total = 0
for path in sys.argv[1:]:
    im = Image.open(path).convert("RGB")
    n = sum(c for c, px in im.getcolors(maxcolors=1 << 24) if px == HAZARD)
    if n:
        print(f"  {path}: {n} hazard px")
    total += n
print(total)
