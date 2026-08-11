#!/usr/bin/env python3
"""Report the fill and ink colours of a captured component, per interaction state.

A screenshot alone proves nothing about a colour bug — the point of this script
is to turn the capture into numbers that can be diffed against the value the
stylesheet declares.

  fill : the most common colour in the sampled region (the background)
  ink  : the most common colour that is *not* the fill and is far enough from it
         to be glyph/border pixels rather than antialiasing

Usage:
  sample_state.py <key> [--states default,hover,active] [--dir flutter_web_captures]
                        [--box x0,y0,x1,y1]   # fractions of the image, default whole
"""
import argparse
import sys
from collections import Counter
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent


def analyse(path: Path, box: tuple[float, float, float, float]):
    img = Image.open(path).convert("RGB")
    w, h = img.size
    x0, y0, x1, y1 = box
    crop = img.crop(
        (int(x0 * w), int(y0 * h), max(1, int(x1 * w)), max(1, int(y1 * h)))
    )
    counts = Counter(crop.getdata())
    fill, fill_n = counts.most_common(1)[0]

    def dist(c):
        return sum(abs(a - b) for a, b in zip(c, fill))

    ink = None
    ink_n = 0
    for colour, n in counts.most_common():
        if dist(colour) >= 90:
            ink, ink_n = colour, n
            break
    total = sum(counts.values())
    return {
        "fill": fill,
        "fill_pct": 100.0 * fill_n / total,
        "ink": ink,
        "ink_pct": 100.0 * ink_n / total if ink else 0.0,
        "size": (w, h),
    }


def changed_against_default(default_path: Path, state_path: Path):
    """What the interaction actually repainted, relative to the resting frame.

    Reports the number of differing pixels, their bounding box, and the colour
    those pixels became. A fill change lights up the whole box; an underline
    lights up a thin strip under the label. Either way the answer is a number,
    not an impression.
    """
    a = Image.open(default_path).convert("RGB")
    b = Image.open(state_path).convert("RGB")
    if a.size != b.size:
        return {"resized": (a.size, b.size)}
    pa, pb = a.load(), b.load()
    w, h = a.size
    changed = []
    for y in range(h):
        for x in range(w):
            if pa[x, y] != pb[x, y]:
                changed.append((x, y, pb[x, y]))
    if not changed:
        return {"n": 0}
    xs = [c[0] for c in changed]
    ys = [c[1] for c in changed]
    counts = Counter(c[2] for c in changed)
    return {
        "n": len(changed),
        "pct": 100.0 * len(changed) / (w * h),
        "box": (min(xs), min(ys), max(xs), max(ys)),
        "top": counts.most_common(3),
    }


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("key", nargs="+")
    p.add_argument("--states", default="default,hover,active")
    p.add_argument("--dir", default="flutter_web_captures")
    p.add_argument("--box", default="0,0,1,1")
    p.add_argument(
        "--diff",
        action="store_true",
        help="also report what each state repainted relative to `default`",
    )
    args = p.parse_args()

    box = tuple(float(v) for v in args.box.split(","))
    outdir = ROOT / args.dir
    for key in args.key:
        for state in args.states.split(","):
            suffix = "" if state == "default" else f"__{state}"
            path = outdir / f"{key}{suffix}.png"
            if not path.exists():
                print(f"{key:<26} {state:<8} MISSING {path.name}")
                continue
            r = analyse(path, box)
            ink = f"rgb{r['ink']}" if r["ink"] else "-"
            print(
                f"{key:<26} {state:<8} "
                f"fill=rgb{r['fill']} ({r['fill_pct']:5.1f}%)  "
                f"ink={ink} ({r['ink_pct']:4.1f}%)  {r['size'][0]}x{r['size'][1]}"
            )
            if args.diff and state != "default":
                base = outdir / f"{key}.png"
                if base.exists():
                    d = changed_against_default(base, path)
                    if d.get("n") == 0:
                        print(f"{'':<26} {'':<8} repainted: nothing")
                    elif "resized" in d:
                        print(f"{'':<26} {'':<8} repainted: size {d['resized']}")
                    else:
                        top = ", ".join(
                            f"rgb{c}x{n}" for c, n in d["top"]
                        )
                        print(
                            f"{'':<26} {'':<8} repainted: {d['n']} px "
                            f"({d['pct']:.2f}%) box={d['box']} -> {top}"
                        )
        print()


if __name__ == "__main__":
    sys.exit(main())
