#!/usr/bin/env python3
"""Score every component in a group (or all groups) and print a pass/fail table.

Usage:
  report.py                 # all groups
  report.py core            # only playwright/components/core.json
  report.py --threshold 95  # custom threshold (default 95)

Exit code 0 only if every scored component meets the threshold.
"""
import argparse
import json
import sys
from pathlib import Path

from compare import COLOUR_DELTA_LIMIT, compare_detail

ROOT = Path(__file__).resolve().parent.parent
CONFIG_DIR = ROOT / "playwright" / "components"


def load_keys(group: str | None) -> list[str]:
    files = sorted(CONFIG_DIR.glob("*.json"))
    if group:
        files = [f for f in files if f.stem == group]
        if not files:
            print(f"No config for group '{group}' in {CONFIG_DIR}")
            sys.exit(2)
    keys: list[str] = []
    for f in files:
        keys.extend(json.loads(f.read_text()).keys())
    return keys


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("group", nargs="?", default=None)
    parser.add_argument("--threshold", type=float, default=95.0)
    args = parser.parse_args()

    keys = load_keys(args.group)
    rows, missing, failures = [], [], []

    for key in keys:
        ref = ROOT / "reference" / f"{key}.png"
        flt = ROOT / "flutter_captures" / f"{key}.png"
        if not ref.exists() or not flt.exists():
            which = "reference" if not ref.exists() else "flutter"
            missing.append(f"{key} (no {which} capture)")
            continue
        score, delta = compare_detail(key)
        # Two independent gates. SSIM is a whole-image average, so a wrong
        # colour confined to a small element barely dents it; the flat-tile
        # colour delta catches precisely that case.
        ok = score >= args.threshold and delta < COLOUR_DELTA_LIMIT
        rows.append((key, score, delta, ok))
        if not ok:
            failures.append(key)

    width = max((len(k) for k, _, _, _ in rows), default=10)
    for key, score, delta, ok in sorted(rows, key=lambda r: r[1]):
        flag = "" if delta < COLOUR_DELTA_LIMIT else "  <- colour delta"
        print(f"{'PASS' if ok else 'FAIL'}  {key:<{width}}  {score:6.2f}%  dC={delta:5.2f}{flag}")

    if missing:
        print("\nMissing captures:")
        for m in missing:
            print(f"  - {m}")

    scored = len(rows)
    passed = scored - len(failures)
    print(f"\n{passed}/{scored} at or above {args.threshold}%")
    if failures:
        print(f"Below threshold: {', '.join(failures)}")

    sys.exit(1 if (failures or missing) else 0)


if __name__ == "__main__":
    main()
