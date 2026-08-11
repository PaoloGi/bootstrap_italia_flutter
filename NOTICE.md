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
| Roboto Mono | 3.001 | The Roboto Mono Project Authors ([googlefonts/robotomono](https://github.com/googlefonts/robotomono)) | [Apache-2.0](fonts/licenses/Apache-2.0.txt) |

Both the SIL Open Font Licence and Apache-2.0 require their licence text to
accompany redistributed font binaries; `fonts/licenses/` satisfies that, and
`pubspec.yaml` includes it in the published archive.

## Naming and endorsement

**This is an unofficial, community port.** The `_flutter` suffix is deliberate:
it marks this as a derivative work rather than the design system itself, and
leaves the official `bootstrap_italia` name unclaimed on pub.dev. It is not published, endorsed or
maintained by Developers Italia or AgID. "Bootstrap Italia" and the Italian
Republic's visual identity belong to their respective owners; this package
reuses the design specification under BSD-3-Clause but carries no official
status. See [doc/conformance.md](doc/conformance.md) for what has and has not
been verified.
