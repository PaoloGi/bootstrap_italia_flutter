# Third-party notices

`bootstrap_italia_flutter` (this package) is licensed under the MIT Licence — see
[LICENSE](LICENSE). It redistributes the third-party material below, each under
its own licence. Licence texts are included in this repository as required.

## Design system

| Component | Version | Author | Licence |
| --- | --- | --- | --- |
| [Bootstrap Italia](https://github.com/italia/bootstrap-italia) | 2.18.0 | [Developers Italia / AgID](https://github.com/italia/bootstrap-italia/blob/main/AUTHORS) | BSD-3-Clause |
| [design-react-kit](https://github.com/italia/design-react-kit) | Storybook `main` | Developers Italia | BSD-3-Clause |

Bootstrap Italia's compiled CSS is the **normative source** for every measurement
in this package: colours, spacing, typography and border values are read from it
rather than eyeballed. `design-react-kit`'s public Storybook is used only as a
rendering reference for automated comparison. Neither is redistributed in the
published package — see `tool/visual_parity/README.md` for how they are fetched.

## Bundled fonts

These ship inside the published package (`fonts/`) so applications work offline
and without third-party requests, which matters for GDPR compliance in public
administration deployments.

| Family | Version | Copyright | Licence |
| --- | --- | --- | --- |
| Titillium Web | 1.002 | Accademia di Belle Arti di Urbino and students of the MA course in Visual Design | [SIL OFL 1.1](fonts/licenses/OFL-1.1.txt) |
| Lora | 3.008 | The Lora Project Authors ([cyrealtype/Lora-Cyrillic](https://github.com/cyrealtype/Lora-Cyrillic)) | [SIL OFL 1.1](fonts/licenses/OFL-1.1.txt) |
| Roboto Mono | 3.001 | The Roboto Mono Project Authors ([googlefonts/robotomono](https://github.com/googlefonts/robotomono)) | [SIL OFL 1.1](fonts/licenses/OFL-1.1.txt) |

All three are under the SIL Open Font Licence. Roboto Mono is listed here as
Apache-2.0 in earlier versions of this file, because its first release was —
but the binary bundled in `fonts/` is not: its own `name` table says "This Font
Software is licensed under the SIL Open Font License, Version 1.1", and the
Apache text that sat beside it documented a licence no font in this package is
under. The copyright lines above were read back out of the binaries rather than
from a web page, so they describe these files.

The OFL requires its licence text and the copyright notices to accompany
redistributed font binaries; [fonts/licenses/](fonts/licenses/) carries both,
and `pubspec.yaml` includes the directory in the published archive.

## Naming and endorsement

**This is an unofficial, community port.** The `_flutter` suffix is deliberate:
it marks this as a derivative work rather than the design system itself, and
leaves the official `bootstrap_italia` name unclaimed on pub.dev. It is not published, endorsed or
maintained by Developers Italia or AgID. "Bootstrap Italia" and the Italian
Republic's visual identity belong to their respective owners; this package
reuses the design specification under BSD-3-Clause but carries no official
status. See [doc/conformance.md](doc/conformance.md) for what has and has not
been verified.
