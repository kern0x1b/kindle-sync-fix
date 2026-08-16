# Kindle Whispersync Fix

MobileSubstrate tweak for jailbroken iOS 6 (armv7). Fixes the Amazon Kindle
app's "Sync to Furthest Page" failing silently with "Retrieval failed, try
again later".

## Cause

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

## Building

Needs an armv7-capable iOS SDK (modern Xcode dropped the armv7 slice; use an
old bundled SDK, e.g. iPhoneOS12.4.sdk with 32-bit libs intact) and
`libsubstrate.dylib` pulled from a jailbroken device (`/usr/lib/libsubstrate.dylib`).

```
SDK=<path to an iOS SDK with an armv7 slice>
clang -arch armv7 -mthumb -O2 -isysroot "$SDK" -miphoneos-version-min=6.0 \
  -dynamiclib -framework Foundation -L. -lsubstrate \
  expectfix4.m -o pkgroot/Library/MobileSubstrate/DynamicLibraries/expectfix4.dylib
ldid -S pkgroot/Library/MobileSubstrate/DynamicLibraries/expectfix4.dylib

dpkg-deb --build --root-owner-group pkgroot \
  dist/space.kern0x1b.expectfix_1.0.0_iphoneos-arm.deb
```

## Distribution

Built `.deb` files land in `dist/` here. Publishing to the
[Cydia repo](https://github.com/kern0x1b/cydia) is manual:

```
cp dist/*.deb ../cydia/debs/
cd ../cydia
dpkg-scanpackages debs /dev/null > Packages
gzip -k -f Packages
git add debs Packages Packages.gz
git commit -m "Publish kindle-sync-fix update"
git push
```
