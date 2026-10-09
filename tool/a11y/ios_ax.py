#!/usr/bin/env python3
"""Render an `idb ui describe-all` dump as a readable table.

Read the header of ios_ax_probe.sh for what this tool can and cannot see.
"""
import json, sys

def load(path):
    with open(path) as f:
        return json.load(f)

def main():
    nodes = load(sys.argv[1])
    only = sys.argv[2] if len(sys.argv) > 2 else None
    print(f"{'role':<22} {'label':<52} {'value':<14} act")
    print("-" * 100)
    for n in nodes:
        role = (n.get("role") or "").replace("AX", "")
        label = n.get("AXLabel") or ""
        value = n.get("AXValue")
        value = "" if value is None else str(value)
        acts = ",".join(a.get("name", "?") for a in (n.get("custom_actions") or []))
        if only and only.lower() not in (label or "").lower():
            continue
        label = label.replace("\n", " / ")
        print(f"{role:<22} {label[:52]:<52} {value[:14]:<14} {acts[:24]}")

if __name__ == "__main__":
    main()
