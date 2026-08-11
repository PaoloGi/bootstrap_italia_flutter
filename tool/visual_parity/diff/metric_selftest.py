#!/usr/bin/env python3
"""Guard tests for the similarity metric itself.

The metric deliberately tolerates sub-pixel antialiasing and ~1px alignment
differences between Chromium and Skia. Every such allowance risks turning the
harness into a rubber stamp, so this file pins down BOTH directions:

  - a genuinely correct render must score above the threshold, and
  - each class of real defect must score below it.

Run:  tool/visual_parity/.venv/bin/python tool/visual_parity/diff/metric_selftest.py
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

sys.path.insert(0, str(Path(__file__).resolve().parent))
from compare import (  # noqa: E402
    BLUR_RADIUS,
    COLOUR_DELTA_LIMIT,
    best_aligned_ssim,
    load_rgb,
    max_tile_colour_delta,
    normalize_pair,
)

ROOT = Path(__file__).resolve().parent.parent
THRESHOLD = 95.0
BASE = "badge_primary"


def _prepared(a: Image.Image, b: Image.Image):
    a_n, b_n = normalize_pair(a, b)
    return (
        np.asarray(a_n.filter(ImageFilter.GaussianBlur(BLUR_RADIUS))),
        np.asarray(b_n.filter(ImageFilter.GaussianBlur(BLUR_RADIUS))),
    )


def score_images(a: Image.Image, b: Image.Image) -> float:
    a_arr, b_arr = _prepared(a, b)
    return best_aligned_ssim(a_arr, b_arr)[0] * 100


def verdict(a: Image.Image, b: Image.Image) -> float:
    """Combined gate, mirroring report.py: an SSIM below threshold OR a
    flat-tile colour delta at/above the limit is a failure. Returned as a
    score so a colour-only failure still reads as sub-threshold."""
    a_arr, b_arr = _prepared(a, b)
    score = best_aligned_ssim(a_arr, b_arr)[0] * 100
    if max_tile_colour_delta(a_arr, b_arr) >= COLOUR_DELTA_LIMIT:
        return min(score, THRESHOLD - 0.01)
    return score


def shifted(img: Image.Image, dx: int, dy: int) -> Image.Image:
    """Translate by (dx, dy) with edge replication.

    Pasting onto a blank canvas instead would crop one edge and introduce a
    white band, which is a *content* change, not the pure sub-pixel offset
    this case is meant to model.
    """
    a = np.asarray(img)
    pad = max(abs(dx), abs(dy))
    padded_arr = np.pad(a, ((pad, pad), (pad, pad), (0, 0)), mode="edge")
    y0, x0 = pad - dy, pad - dx
    return Image.fromarray(padded_arr[y0 : y0 + img.height, x0 : x0 + img.width])


def recoloured(img: Image.Image, delta: int) -> Image.Image:
    """Nudge the badge fill, leaving white background alone."""
    a = np.asarray(img).astype(int)
    mask = a.sum(axis=2) < 700
    a[mask] = np.clip(a[mask] + delta, 0, 255)
    return Image.fromarray(a.astype(np.uint8))


def padded(img: Image.Image, px: int) -> Image.Image:
    """Simulate wrong padding: grow the box, keep content centred."""
    out = Image.new("RGB", (img.width + px * 2, img.height), (255, 255, 255))
    edge = img.crop((0, 0, 2, img.height)).resize((px, img.height))
    out.paste(edge, (0, 0))
    out.paste(edge, (img.width + px, 0))
    out.paste(img, (px, 0))
    return out


def resized(img: Image.Image, factor: float) -> Image.Image:
    return img.resize(
        (round(img.width * factor), round(img.height * factor)), Image.LANCZOS
    )


def main() -> int:
    ref = load_rgb(ROOT / "reference" / f"{BASE}.png")
    flt = load_rgb(ROOT / "flutter_captures" / f"{BASE}.png")

    checks = [
        # (name, score, must_pass)
        ("identical image", verdict(ref, ref), True),
        ("real Flutter render vs reference", verdict(ref, flt), True),
        ("1px shift (engine rounding)", verdict(ref, shifted(ref, 1, 1)), True),
        ("wrong fill colour (+18/channel)", verdict(ref, recoloured(ref, 18)), False),
        # SSIM alone rates these ~98-99% because the colour error is small in
        # magnitude or area; they exist to prove the colour gate catches what
        # the structural score dilutes. Without it, a wrong colour token could
        # ship while the report showed a comfortable pass.
        ("subtle fill colour (+6/channel)", verdict(ref, recoloured(ref, 6)), False),
        ("subtle fill colour (+4/channel)", verdict(ref, recoloured(ref, 4)), False),
        ("4px extra horizontal padding", verdict(ref, padded(ref, 4)), False),
        ("10% larger overall", verdict(ref, resized(ref, 1.10)), False),
        ("different component (secondary badge)",
         verdict(ref, load_rgb(ROOT / "reference" / "badge_secondary.png")), False),
    ]

    print(f"threshold = {THRESHOLD}%\n")
    failures = []
    for name, score, must_pass in checks:
        passed = score >= THRESHOLD
        ok = passed == must_pass
        want = "should PASS" if must_pass else "should FAIL"
        print(f"  {'ok  ' if ok else 'BAD '} {name:<40} {score:6.2f}%  ({want})")
        if not ok:
            failures.append(name)

    if failures:
        print(f"\nMetric self-test FAILED for: {', '.join(failures)}")
        return 1
    print("\nMetric self-test passed: tolerant of engine noise, strict on real defects.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
