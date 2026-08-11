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
from PIL import Image, ImageFilter
from skimage.metrics import structural_similarity as ssim

ROOT = Path(__file__).resolve().parent.parent


def load_rgb(path: Path) -> Image.Image:
    img = Image.open(path).convert("RGBA")
    bg = Image.new("RGBA", img.size, (255, 255, 255, 255))
    composited = Image.alpha_composite(bg, img).convert("RGB")
    return composited


MAX_DIM = 1600
BLUR_RADIUS = 0.75


def normalize_pair(a: Image.Image, b: Image.Image):
    """Place both images on a common canvas at a SHARED scale, never upscaling.

    Both captures are taken at 2x device pixel ratio, so their native pixel
    sizes are directly comparable. Two rules matter here:

    1. Apply the SAME scale factor to both images. Scaling each to fill a
       fixed canvas would normalise away real size differences — a component
       twice as wide as its reference would score as a perfect match.
    2. Never upscale. Blowing a 118x42 badge up to 600px magnifies sub-pixel
       text antialiasing (which Chromium and Skia will never agree on) into
       huge apparent differences, so correct components scored ~90%. We only
       scale down, and only when a component is too large to compare cheaply.

    Each image is then centred on a white canvas sized to fit both, so a
    genuine geometry difference shows up honestly as an unmatched edge region.
    """
    scale = min(1.0, MAX_DIM / max(a.width, a.height, b.width, b.height))

    def apply(img: Image.Image) -> Image.Image:
        if scale >= 1.0:
            return img
        return img.resize(
            (max(1, round(img.width * scale)), max(1, round(img.height * scale))),
            Image.LANCZOS,
        )

    a_s, b_s = apply(a), apply(b)
    canvas = (max(a_s.width, b_s.width), max(a_s.height, b_s.height))

    def place(img: Image.Image) -> Image.Image:
        out = Image.new("RGB", canvas, (255, 255, 255))
        out.paste(img, ((canvas[0] - img.width) // 2, (canvas[1] - img.height) // 2))
        return out

    return place(a_s), place(b_s)


ALIGN_TOLERANCE = 2


def best_aligned_ssim(ref: np.ndarray, flt: np.ndarray):
    """SSIM maximised over sub-pixel-scale translations of up to
    ALIGN_TOLERANCE pixels.

    Chromium and Skia round glyph baselines and box edges differently, so a
    correct component routinely lands 1px off its reference. On a small,
    high-contrast image (a 118x42 badge) that single pixel of shift is enough
    to drag raw SSIM from ~98% down to ~85% — the metric reports a rendering
    tie-break as if it were a design defect. Allowing a couple of pixels of
    slack keeps the score sensitive to what we actually care about (colour,
    size, spacing, weight) while ignoring what we can never control.

    Only the genuinely overlapping region is compared at each offset. Padding
    the shifted image and comparing full frames instead would pit real content
    against invented background along one edge, so for any component that fills
    its capture (a badge, a filled button) every nonzero offset carried a
    built-in penalty and the search could never actually help.

    Returns (score, diff_map) for the best-aligned offset.
    """
    m = ALIGN_TOLERANCE
    h, w = ref.shape[:2]

    best = (-1.0, None, (0, 0))
    for dy in range(-m, m + 1):
        for dx in range(-m, m + 1):
            ry0, ry1 = max(0, dy), h + min(0, dy)
            rx0, rx1 = max(0, dx), w + min(0, dx)
            fy0, fy1 = max(0, -dy), h + min(0, -dy)
            fx0, fx1 = max(0, -dx), w + min(0, -dx)
            ref_c = ref[ry0:ry1, rx0:rx1]
            flt_c = flt[fy0:fy1, fx0:fx1]
            if min(ref_c.shape[0], ref_c.shape[1]) < 8:
                continue
            score, diff = ssim(ref_c, flt_c, channel_axis=2, full=True)
            if score > best[0]:
                best = (score, diff, (ry0, rx0))

    score, diff, (oy, ox) = best
    # Re-expand the diff map to full canvas size so callers can compose it with
    # the originals; regions outside the compared overlap read as "no difference".
    full = np.ones((h, w, ref.shape[2]), dtype=diff.dtype)
    full[oy : oy + diff.shape[0], ox : ox + diff.shape[1]] = diff
    return score, full


TILE = 16
# A tile counts as a flat fill when its per-channel std is below this.
FLAT_TILE_STD = 6.0
# Correct renders measure at most ~0.9 here; a real colour error scales 1:1 with
# the per-channel mistake, so anything at or above this is a genuine defect.
COLOUR_DELTA_LIMIT = 3.0


def max_tile_colour_delta(ref: np.ndarray, flt: np.ndarray) -> float:
    """Largest per-channel mean colour difference over any TILE x TILE block.

    SSIM is a whole-image average, so a wrong colour confined to a small region
    barely moves it: an 18/channel error on a 20x20 checkbox fill still scored
    98%. Averaging within a tile cancels antialiasing (which perturbs pixels
    symmetrically about the true colour) while preserving a genuine fill or
    border colour error, so this catches exactly what SSIM dilutes.

    Only tiles that are a FLAT fill in both images are considered. Tiles
    containing text or an icon differ legitimately between engines — measured
    at up to ~27/channel on correct renders — so including them would make the
    check meaningless. Restricting to flat regions isolates fills, bars and
    backgrounds, which is where a wrong colour token actually shows up.
    """
    h = min(ref.shape[0], flt.shape[0]) // TILE * TILE
    w = min(ref.shape[1], flt.shape[1]) // TILE * TILE
    if h == 0 or w == 0:
        return 0.0

    def blocks(a: np.ndarray) -> np.ndarray:
        a = a[:h, :w].astype(float)
        return a.reshape(h // TILE, TILE, w // TILE, TILE, a.shape[2])

    rb, fb = blocks(ref), blocks(flt)
    ref_mean, flt_mean = rb.mean(axis=(1, 3)), fb.mean(axis=(1, 3))
    flat = (rb.std(axis=(1, 3)).max(axis=-1) < FLAT_TILE_STD) & (
        fb.std(axis=(1, 3)).max(axis=-1) < FLAT_TILE_STD
    )
    if not flat.any():
        return 0.0
    return float(np.abs(ref_mean - flt_mean).max(axis=-1)[flat].max())


def compare_detail(component: str) -> tuple[float, float]:
    """Score one component and write its diff image.

    Returns (similarity %, max flat-tile colour delta).
    """
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

    # A sub-device-pixel blur absorbs the antialiasing and half-pixel baseline
    # rounding that Chromium and Skia will never agree on, while leaving real
    # differences (a wrong colour, a 1px CSS border, a few px of padding, a
    # different font size) plainly visible. Captures are 2x, so this radius is
    # well under half a CSS pixel. See metric_selftest.py for the guard tests
    # that keep this from silently turning into "everything passes".
    ref_arr = np.asarray(ref_n.filter(ImageFilter.GaussianBlur(BLUR_RADIUS)))
    flt_arr = np.asarray(flt_n.filter(ImageFilter.GaussianBlur(BLUR_RADIUS)))

    score, diff = best_aligned_ssim(ref_arr, flt_arr)
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

    return similarity_pct, max_tile_colour_delta(ref_arr, flt_arr)


def compare_score(component: str) -> float:
    return compare_detail(component)[0]


def compare(component: str, threshold: float) -> float:
    score, delta = compare_detail(component)
    ok = score >= threshold and delta < COLOUR_DELTA_LIMIT
    out_path = ROOT / "diffs" / f"{component}_diff.png"
    print(
        f"{component}: {score:.2f}% dC={delta:.2f} "
        f"({'PASS' if ok else 'FAIL'}, threshold {threshold}%) -> {out_path}"
    )
    return score if ok else min(score, threshold - 0.01)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("component")
    parser.add_argument("--threshold", type=float, default=92.0)
    args = parser.parse_args()
    score = compare(args.component, args.threshold)
    sys.exit(0 if score >= args.threshold else 1)
