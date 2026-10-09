# Font bundled with the example app

`Roboto-Regular.ttf` is Roboto 2.137, Copyright 2011 Google Inc., under the
Apache License 2.0 ([Apache-2.0.txt](Apache-2.0.txt)).

The example bundles it for one reason: on the web, Flutter's CanvasKit renderer
downloads Roboto regular from `fonts.gstatic.com` at startup **unless the app's
own font manifest declares a family named `Roboto`**. Roboto is CanvasKit's
built-in default face, so the request happens even though every widget in this
example paints in Titillium Web, Lora or Roboto Mono. That request would make
the package's "offline, no third-party requests" claim false for any web build
of the example, which is the GDPR point the claim exists for.

The family name has to be exactly `Roboto` — the engine matches that string, and
a package-qualified family (`packages/…/Roboto`) does not satisfy it. For the
same reason this declaration lives in the app's `pubspec.yaml` rather than the
package's: a consumer's font manifest is the app's own.

The licence text travels with the binary, and `pubspec.yaml` ships
`fonts/licenses/` as an asset. The copyright line above was read out of the
font's `name` table rather than copied from a web page, so it describes this
file.
