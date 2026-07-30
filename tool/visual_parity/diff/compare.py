#!/usr/bin/env python3
"""Compare a React (Playwright) reference PNG against a Flutter golden-capture
PNG and report an SSIM-based similarity percentage plus a visual diff image.

Usage: compare.py <component_key> [--threshold 92]
Looks for:
  reference/<component_key>.png
  flutter_captures/<component_key>.png
Writes:
  diffs/<component_key>_diff.png   (side-by-side + heatmap)
"""
import sys
import argparse
from pathlib import Path

import numpy as np
from PIL import Image
from skimage.metrics import structural_similarity as ssim

ROOT = Path(__file__).resolve().parent.parent


def load_rgb(path: Path) -> Image.Image:
    img = Image.open(path).convert("RGBA")
    bg = Image.new("RGBA", img.size, (255, 255, 255, 255))
    composited = Image.alpha_composite(bg, img).convert("RGB")
    return composited


def normalize_pair(a: Image.Image, b: Image.Image, canvas: tuple = (600, 600)):
    """Scale each image independently to fit within `canvas` preserving its
    own aspect ratio (contain-fit), then center it on a common white canvas.

    Force-stretching both images to a shared blended aspect ratio (the
    previous approach) distorts and misaligns content even when the two
    images are a near-perfect match, producing misleadingly low SSIM scores.
    Contain-fit + center preserves true proportions, so a real match overlaps
    almost exactly, and a genuine size/aspect mismatch shows up honestly as
    a border/edge difference instead of a full-image ghosting artifact.
    """
    cw, ch = canvas

    def fit(img: Image.Image) -> Image.Image:
        scale = min(cw / img.width, ch / img.height)
        new_size = (max(1, round(img.width * scale)), max(1, round(img.height * scale)))
        resized = img.resize(new_size, Image.LANCZOS)
        out = Image.new("RGB", canvas, (255, 255, 255))
        offset = ((cw - new_size[0]) // 2, (ch - new_size[1]) // 2)
        out.paste(resized, offset)
        return out

    return fit(a), fit(b)


def compare(component: str, threshold: float) -> float:
    ref_path = ROOT / "reference" / f"{component}.png"
    flt_path = ROOT / "flutter_captures" / f"{component}.png"

    if not ref_path.exists():
        print(f"MISSING reference: {ref_path}")
        sys.exit(2)
    if not flt_path.exists():
        print(f"MISSING flutter capture: {flt_path}")
        sys.exit(2)

    ref = load_rgb(ref_path)
    flt = load_rgb(flt_path)

    ref_n, flt_n = normalize_pair(ref, flt)

    ref_arr = np.asarray(ref_n)
    flt_arr = np.asarray(flt_n)

    score, diff = ssim(ref_arr, flt_arr, channel_axis=2, full=True)
    similarity_pct = score * 100

    # Build a visual: reference | flutter | heatmap of (1-diff)
    diff_gray = (1 - diff.mean(axis=2))
    heat = (diff_gray * 255).astype(np.uint8)
    heat_img = Image.fromarray(heat).convert("RGB")

    gap = 8
    w, h = ref_n.size
    canvas = Image.new("RGB", (w * 3 + gap * 2, h), (240, 240, 240))
    canvas.paste(ref_n, (0, 0))
    canvas.paste(flt_n, (w + gap, 0))
    canvas.paste(heat_img, (2 * (w + gap), 0))

    diffs_dir = ROOT / "diffs"
    diffs_dir.mkdir(exist_ok=True)
    out_path = diffs_dir / f"{component}_diff.png"
    canvas.save(out_path)

    verdict = "PASS" if similarity_pct >= threshold else "FAIL"
    print(f"{component}: {similarity_pct:.2f}% ({verdict}, threshold {threshold}%) -> {out_path}")
    return similarity_pct


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("component")
    parser.add_argument("--threshold", type=float, default=92.0)
    args = parser.parse_args()
    score = compare(args.component, args.threshold)
    sys.exit(0 if score >= args.threshold else 1)
