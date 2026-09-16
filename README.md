<img src="assets/icon.png" width="128" height="128" alt="Kindle Whispersync Fix">

# Kindle Whispersync Fix

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-iOS%206.0%2B%20(armv7)-lightgrey)
![Verified](https://img.shields.io/badge/verified%20on-iOS%206.1.3-brightgreen)

A MobileSubstrate tweak that fixes the Kindle app's "Sync to Furthest Page"
on jailbroken legacy iOS, which fails silently with "Retrieval failed, try
again later".

*Unofficial and independent. Not affiliated with Amazon.com, Inc. — see
[Disclaimer](#disclaimer).*

**Supported vs. verified:** the build targets iOS 6.0 on armv7, the oldest
release the build toolchain supports for that architecture. The code itself
has no iOS 6-specific dependency, and the 1.0.2 package was built by hand
for iOS 5.0, but builds from this repository record 6.0 as their minimum.
It has only been *tested* on iOS 6.1.3 (iPhone 4S).

## Install

Add this Cydia source, then install **Kindle Whispersync Fix (unofficial)**:

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

`kindlesyncfix.m` hooks `-[NSMutableURLRequest setValue:forHTTPHeaderField:]`,
scoped only to the Kindle app (`com.amazon.Lassen` — MobileSubstrate filter
in `packaging/kindlesyncfix.plist`), and
drops the header when it is set with an empty value.

The hooked method is Apple's, not the app's: the malformed header comes from
the system's networking stack, so nothing in the app itself is inspected or
altered. The tweak reads no data, writes no files and no logs, sends nothing
anywhere, and does nothing at all in any other process.

## Building from source

The tweak is built with [Charon](https://github.com/kern0x1b/charon), which
reads `charon.toml`, cross-compiles for armv7, links with ld64, signs with
ldid, checks every import against the iOS 6 dyld shared cache and writes the
`.deb`. Set Charon up once per machine as its README describes: Conan, CMake,
Ninja, the Charon configuration installed into Conan, `charon` on your `PATH`,
and an armv7 `dyld_shared_cache_armv7` from an iOS 6 device at
`~/.charon/dyld/`. The SDK, linker and signing tool come from Conan packages;
Xcode and Theos are not needed.

The hook uses the Objective-C runtime, so it links no Substrate library,
even though MobileSubstrate is what loads it at runtime.

```
charon build
charon package
```

`charon build` writes everything into `build/`, and the device layout it
stages is in `build/armv7/stage/`. `charon package` writes the `.deb` into
the Conan cache and prints that folder as `Package folder`; the archive is in
its `deb/` subfolder. To copy it into `dist/`:

```
mkdir -p dist
deb_dir="$(charon package 2>&1 | sed -n 's/^.*: Package folder //p')/deb"
cp "$deb_dir"/*.deb dist/
```

The package version is `[port] version` in `charon.toml`;
`packaging/control` carries every other field.

## Publishing

Publishing to the [Cydia repo](https://github.com/kern0x1b/cydia) is
manual — set `CYDIA_REPO` to wherever you have that repo checked out:

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

## Disclaimer

This is an independent, unofficial project. It is not affiliated with,
authorized by, endorsed by, sponsored by or in any way officially connected to
Amazon.com, Inc. or any of its subsidiaries or affiliates.

Amazon, Kindle and Whispersync are trademarks of Amazon.com, Inc. or its
affiliates. They are used here only to identify the application this tweak is
compatible with and the service whose behaviour is described — a factual,
referential use, from which no sponsorship or endorsement should be inferred.
This repository contains no Amazon code, binaries, headers, artwork or logos,
and redistributes no part of the Kindle application.

The tweak removes a malformed HTTP header that the operating system's own
networking stack attaches to an outgoing request, making that request conform
to RFC 9110. It circumvents no technical protection measure, touches no DRM or
licensing mechanism, modifies and redistributes no book content, and grants
access to nothing the account holder has not already bought. It is intended to
be used on a device its owner has modified, with that owner's own account.

## License

MIT, see [LICENSE](LICENSE). The MIT license covers this project's own code
only, and grants no rights in anyone's trademarks.
