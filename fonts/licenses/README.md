# Fonts bundled with this package

`pubspec.yaml` ships three families from `fonts/`, because Bootstrap Italia's
type is part of the design system rather than a suggestion: the kit's own CSS
names Titillium Web for everything, Lora for the serif display style, and
Roboto Mono where text has to line up.

| Family | Files | Licence | Copyright |
|---|---|---|---|
| Titillium Web | `TitilliumWeb-*.ttf` | SIL OFL 1.1 | Accademia di Belle Arti di Urbino and students of the MA course of Visual design, 2009–2011 |
| Lora | `Lora-*.ttf` | SIL OFL 1.1 | The Lora Project Authors, 2011 |
| Roboto Mono | `RobotoMono-*.ttf` | SIL OFL 1.1 | The Roboto Mono Project Authors, 2015 |

[OFL-1.1.txt](OFL-1.1.txt) carries all three notices followed by the licence
text, which is what §2 of the OFL requires to travel with the files.

Two things were wrong here before, and both would have shipped:

* **`OFL-1.1.txt` was the unfilled template**, down to
  `Copyright (c) <dates>, <Copyright Holder>`. A licence with no copyright
  holder names nobody and satisfies nothing — the notice is the part the OFL
  asks you to keep.
* **An `Apache-2.0.txt` sat beside it**, presumably for Roboto Mono, which was
  Apache-2.0 in its first release. The files bundled here are not: each one's
  `name` table says "This Font Software is licensed under the SIL Open Font
  License, Version 1.1", so the Apache text documented a licence no font in
  this package is under. It has been removed.

The copyright lines above were read back out of the binaries rather than
copied from a web page, so they describe *these* files.
