# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
