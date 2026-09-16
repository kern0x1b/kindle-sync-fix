# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Built with Charon from `charon.toml` instead of a hand-run clang, ldid and
  dpkg-deb. The minimum iOS recorded in the binary is 6.0 (it was 5.0), the
  dylib's install name is `/Library/MobileSubstrate/DynamicLibraries/kindlesyncfix.dylib`
  instead of a path relative to the old build folder, and every import is
  checked against the iOS 6 dyld shared cache at build time.
- The control file and the MobileSubstrate filter moved to `packaging/`; the
  prebuilt dylib is no longer tracked.

## [1.0.2] - 2026-09-10

### Removed
- The debug log. Every hooked `Expect` header was appended to
  `/tmp/expectfix4.log`, the file was never truncated and nothing ever read
  it. The tweak now writes nothing to disk.
- The link against CydiaSubstrate. The hook goes through the Objective-C
  runtime and used no Substrate symbol, so the build no longer needs a
  `libsubstrate.dylib` pulled off a device.

### Added
- A non-affiliation and trademark notice in the README and in the package
  description, stating that the project is unofficial, that Amazon, Kindle and
  Whispersync are Amazon's trademarks used referentially, that no Amazon
  material is redistributed, and that no protection measure, DRM or licensing
  mechanism is touched.
- `(unofficial)` in the package's display name.

## [1.0.1] - 2026-08-24

### Changed
- Package identifier renamed from `space.kern0x1b.expectfix` to
  `space.kern0x1b.kindlesyncfix`, and the tweak's files along with it. The old
  name described the HTTP header the fix touches rather than what the tweak is
  for. The package declares Replaces/Conflicts/Provides on the old identifier,
  so installing it removes the old one instead of leaving both.
- Ships Depiction, Icon, Homepage and Tag, so the Cydia source shows a real
  page for the tweak.

## [1.0.0] - 2026-08-21

### Added
- Initial release: hooks `-[NSMutableURLRequest setValue:forHTTPHeaderField:]` inside
  the Kindle app to drop the malformed empty `Expect` header that breaks Whispersync
  sync on iOS 6.
