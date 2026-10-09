#!/usr/bin/env bash
# WCAG 1.4.4 Resize Text — drives the example app at enlarged text and reports
# any layout that breaks.
#
# Detection is by SCREENSHOT, not logcat, and that distinction is the whole
# point of this script. Flutter's overflow errors do NOT reach logcat on every
# device — verified by planting a guaranteed overflow, confirming it painted,
# and getting zero log lines back. What Flutter always does is paint the hazard
# stripe, RGB (255,255,64). A logcat-based probe reports a clean run on a broken
# layout, which is worse than no probe.
#
# The app supplies the scale itself (a MediaQuery textScaler in example/lib/app.dart)
# because this device's ROM refuses both WRITE_SETTINGS (font_scale) and
# `wm density`.
#
#   1. add the scaler to example/lib/app.dart:
#        builder: (context, child) => MediaQuery(
#          data: MediaQuery.of(context)
#              .copyWith(textScaler: const TextScaler.linear(2.0)),
#          child: child!),
#   2. cd example && flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk
#   3. tool/a11y/text_scale_probe.sh Button Chip Alert …
#   4. REVERT the scaler.
#
# Verify the detector before trusting a clean run: plant an overflowing Row and
# confirm this reports it.
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
PKG=com.example.bootstrap_italia_example

shot() {
  adb shell screencap -p /sdcard/_o.png >/dev/null 2>&1
  adb pull /sdcard/_o.png /tmp/_o.png >/dev/null 2>&1
  python3 -c "
from PIL import Image
from collections import Counter
im = Image.open('/tmp/_o.png').convert('RGB')
n = sum(v for px, v in Counter(im.getdata()).items() if px == (255, 255, 64))
print(f'  OVERFLOW  $1  hazard px: {n}') if n > 50 else None
" 2>/dev/null
}

for page in "$@"; do
  adb shell am force-stop $PKG >/dev/null 2>&1
  adb shell monkey -p $PKG -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1; sleep 4
  for s in 0 1 2 3 4 5 6; do
    adb shell uiautomator dump /sdcard/_s.xml >/dev/null 2>&1
    adb pull /sdcard/_s.xml /tmp/_s.xml >/dev/null 2>&1
    c=$(python3 - "$page" << 'PY'
import re, sys, pathlib
want = sys.argv[1]
for n in re.findall(r'<node[^>]*>', pathlib.Path('/tmp/_s.xml').read_text()):
    m = re.search(r'content-desc="([^"]*)"', n)
    if m and 'clickable="true"' in n and m.group(1).strip() == want:
        b = re.search(r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', n)
        x1, y1, x2, y2 = map(int, b.groups())
        if 260 <= y1 and y2 <= 2150:
            print((x1 + x2) // 2, (y1 + y2) // 2); break
PY
)
    [ -n "$c" ] && { adb shell input tap $c >/dev/null 2>&1; sleep 2.5; break; }
    adb shell input swipe 540 1700 540 800 250 >/dev/null 2>&1; sleep 1
  done
  for i in 1 2 3 4 5; do
    shot "$page step$i"
    adb shell input swipe 540 1800 540 700 200 >/dev/null 2>&1; sleep 0.9
  done
done
echo "(no OVERFLOW lines above = clean)"
