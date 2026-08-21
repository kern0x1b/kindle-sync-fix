# Kindle Whispersync Fix

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-iOS%205.0%2B%20(armv7)-lightgrey)
![Verified](https://img.shields.io/badge/verified%20on-iOS%206.1.3-brightgreen)

A MobileSubstrate tweak that fixes Amazon Kindle's "Sync to Furthest Page"
on jailbroken legacy iOS, which fails silently with "Retrieval failed, try
again later".

**Supported vs. verified:** the code has no iOS 6-specific dependency and
builds down to `-miphoneos-version-min=5.0` (armv7's practical floor with
the SDK used here — iOS 4.3 fails to link, missing `libgcc_s.1` in that
SDK). It has only been *tested* on iOS 6.1.3 (iPhone 4S). The underlying
CFNetwork bug this fixes may or may not exist on iOS 5.x — if it doesn't,
the hook is a no-op there, not a break. If you run this on iOS 5, please
report back either way.

## Install

Add this Cydia source, then install **Kindle Whispersync Fix**:

```
https://kern0x1b.github.io/cydia/
```

Sources → Edit → Add → paste the URL above → search the package name →
Install → relaunch Kindle.

## Problem

Old CFNetwork on iOS 6 attaches an empty `Expect:` header to the Kindle
app's sync POST request. Amazon's legacy logging endpoint tolerates it, but
the real Whispersync endpoint
(`cde-ta-g7g.amazon.com/FionaCDEServiceEngine/sidecar`) now rejects it
outright with `417 Expectation Failed`, every time. Confirmed by tracing the
request with mitmproxy + tcpdump.

## Fix

`expectfix4.m` hooks `-[NSMutableURLRequest setValue:forHTTPHeaderField:]`,
scoped only to the Kindle app (`com.amazon.Lassen` — MobileSubstrate filter
in `pkgroot/Library/MobileSubstrate/DynamicLibraries/expectfix4.plist`), and
drops the header when Kindle tries to set it with an empty value.

## Building from source

Needs an armv7-capable iOS SDK (modern Xcode dropped the armv7 slice; use an
old bundled SDK, e.g. iPhoneOS12.4.sdk with 32-bit libs intact) and
`libsubstrate.dylib` pulled from a jailbroken device (`/usr/lib/libsubstrate.dylib`).

```
SDK=<path to an iOS SDK with an armv7 slice>
clang -arch armv7 -mthumb -O2 -isysroot "$SDK" -miphoneos-version-min=5.0 \
  -dynamiclib -framework Foundation -L. -lsubstrate \
  expectfix4.m -o pkgroot/Library/MobileSubstrate/DynamicLibraries/expectfix4.dylib
ldid -S pkgroot/Library/MobileSubstrate/DynamicLibraries/expectfix4.dylib

dpkg-deb --build --root-owner-group pkgroot \
  dist/space.kern0x1b.expectfix_1.0.0_iphoneos-arm.deb
```

## Publishing

Built `.deb` files land in `dist/`. Publishing to the
[Cydia repo](https://github.com/kern0x1b/cydia) is manual — set `CYDIA_REPO`
to wherever you have that repo checked out:

```
CYDIA_REPO=/path/to/your/cydia/checkout

cp dist/*.deb "$CYDIA_REPO/debs/"
cd "$CYDIA_REPO"
dpkg-scanpackages debs /dev/null > Packages
gzip -k -f Packages
git add debs Packages Packages.gz
git commit -m "Publish kindle-sync-fix update"
git push
```

## Contributing

Issues and PRs welcome — this is a single, narrow fix, so keep changes
scoped to it.

## License

MIT, see [LICENSE](LICENSE).
