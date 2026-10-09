#!/usr/bin/env python3
"""Exit 0 if two screenshots show the same page content, ignoring the status bar.

Used to detect "this page has stopped scrolling". The AX tree CANNOT do this:
on the Header page only 5 of 148 nodes report a non-zero frame, so the tree is
byte-identical across three different scroll positions while every screenshot
differs. The sweep believed it and reported the page finished after 3 screens,
still near the top.

The status bar is excluded because its clock changes every minute, which would
otherwise make a settled page look like it was still moving.
"""
import sys
from PIL import Image, ImageChops

TOP = 300  # device px: status bar + app bar, static or irrelevant

a = Image.open(sys.argv[1]).convert("RGB")
b = Image.open(sys.argv[2]).convert("RGB")
if a.size != b.size:
    sys.exit(1)
w, h = a.size
box = (0, TOP, w, h)
sys.exit(0 if ImageChops.difference(a.crop(box), b.crop(box)).getbbox() is None else 1)
