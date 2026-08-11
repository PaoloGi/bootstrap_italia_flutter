#!/usr/bin/env bash
#
# Fetches the exact Bootstrap Italia release this port is verified against.
#
# The compiled stylesheet is the NORMATIVE source for every colour, size,
# padding and border in this package — values are read from it rather than
# eyeballed from a screenshot. It is not committed (it is a third-party build
# artifact, ~6 MB), so this script makes it reproducible instead: pinned to an
# exact version, verified, and refetchable from a clean clone.
#
# Without this, "we matched the CSS" is unverifiable by a reviewer, because the
# CSS they have might not be the CSS we read.
#
#   ./tool/fetch_bootstrap_italia.sh
#
set -euo pipefail

# Keep in sync with doc/conformance.md and NOTICE.md. Bumping this is a
# deliberate act: re-run the parity report afterwards, because upstream changing
# a token is exactly the drift the harness exists to catch.
VERSION="2.18.0"

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO/bootstrap-italia"
TARBALL_URL="https://registry.npmjs.org/bootstrap-italia/-/bootstrap-italia-${VERSION}.tgz"

if [ -f "$DEST/version.js" ] && grep -q "'${VERSION}'" "$DEST/version.js" 2>/dev/null; then
  echo "bootstrap-italia ${VERSION} already present at $DEST"
  exit 0
fi

echo "Fetching bootstrap-italia ${VERSION}…"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$TARBALL_URL" -o "$TMP/bi.tgz"
tar -xzf "$TMP/bi.tgz" -C "$TMP"

# npm tarballs unpack into package/; we want its dist/ as bootstrap-italia/.
SRC="$TMP/package/dist"
[ -d "$SRC" ] || { echo "unexpected tarball layout: no package/dist" >&2; exit 1; }

rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$SRC/." "$DEST/"

# Verify we got what we pinned, rather than trusting the URL.
if ! grep -q "'${VERSION}'" "$DEST/version.js"; then
  echo "ERROR: fetched tree does not report version ${VERSION}" >&2
  exit 1
fi

echo "bootstrap-italia ${VERSION} -> $DEST"
echo "Normative stylesheet: $DEST/css/bootstrap-italia.min.css"
