# Flutter capture jobs

These are `testWidgets` calls with **no assertions**. They exist to rasterise
each component and write a PNG for the out-of-band SSIM comparison in `../diff/`.

They live here rather than under `test/` because they are not tests. As files in
`test/golden/` they were ~16% of the suite, could not fail on a visual
regression, and wrote into the working tree as a side effect of every
`flutter test` — so a green suite said nothing about them, and a developer
running the suite got a dirty tree.

Run them explicitly:

    flutter test tool/visual_parity/capture

The scoring step that *can* fail is `../diff/report.py`, and the guard on the
metric itself is `../diff/metric_selftest.py`.
