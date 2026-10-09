#!/usr/bin/env python3
"""Summarise the iOS AX dumps produced by ios_ax_probe.sh's `sweep`.

Reports UNNAMED INTERACTIVE elements only. Containers are deliberately not
reported: `idb ui describe-all` returns a FLAT list with no parent/child links,
so "this group has no name of its own" cannot be judged here at all. On Android
the mirror-image mistake — treating named containers as unnamed leaves —
produced three false findings that had to be retracted.
"""
import glob, json, os, sys
from collections import Counter

# Roles a user can operate. An unnamed one of these is a real §4.1.2 problem;
# an unnamed AXGroup/AXScrollArea usually is not, and cannot be judged here.
# NOTE: tabs are NOT here. iOS ignores `SemanticsRole`, so a tab arrives as
# `AXGenericElement` — indistinguishable by role from a plain container. Adding
# it would make every unnamed container a finding, which is the exact mistake
# that produced three retracted Android findings. Tabs are checked by hand
# instead; see the iOS section of doc/accessibility-audit.md.
INTERACTIVE = {"AXButton", "AXCheckBox", "AXTextField", "AXSecureTextField",
               "AXLink", "AXSlider", "AXSwitch", "AXSearchField", "AXPopUpButton"}

rows, roles_all, total_unnamed = [], Counter(), 0
for path in sorted(glob.glob(sys.argv[1] if len(sys.argv) > 1
                             else "/tmp/ios_a11y/page_*.json")):
    page = os.path.basename(path)[5:-5]
    try:
        nodes = json.load(open(path))
    except Exception as e:
        rows.append((page, "-", "-", f"unreadable dump: {e}")); continue
    inter = [n for n in nodes if (n.get("role") or "") in INTERACTIVE]
    unnamed = [n for n in inter if not (n.get("AXLabel") or "").strip()]
    roles_all.update((n.get("role") or "?") for n in nodes)
    total_unnamed += len(unnamed)
    note = "" if not unnamed else "  <-- " + ", ".join(
        f'{(n.get("role") or "").replace("AX","")}@{n["frame"]["y"]:.0f}'
        for n in unnamed[:4])
    rows.append((page, len(nodes), f"{len(inter) - len(unnamed)}/{len(inter)}", note))

print(f'{"page":<18} {"nodes":>6} {"named/interactive":>18}')
print("-" * 64)
for page, n, named, note in rows:
    print(f"{page:<18} {n:>6} {named:>18}{note}")
print("-" * 64)
print(f"pages: {len(rows)}   unnamed interactive elements: {total_unnamed}")
print("\nrole histogram:", dict(roles_all.most_common(12)))
