# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-21

### Added
- Initial release: hooks `-[NSMutableURLRequest setValue:forHTTPHeaderField:]` inside
  the Kindle app to drop the malformed empty `Expect` header that breaks Whispersync
  sync on iOS 6.
