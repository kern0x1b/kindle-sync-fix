# kindle-sync-fix

## 1. What this is

A MobileSubstrate tweak (`kindlesyncfix.m`, one file) that fixes the Kindle
app's "Sync to Furthest Page" on jailbroken legacy iOS. Old CFNetwork attaches
an empty `Expect:` HTTP header to the Kindle app's sync POST request; the real
Whispersync endpoint rejects it with `417 Expectation Failed`. The tweak hooks
`-[NSMutableURLRequest setValue:forHTTPHeaderField:]`, scoped to
`com.amazon.Lassen` only, and drops the header when its value is empty. It
reads no data, writes no files, and sends nothing anywhere. Full background
(the trace that found the bug, the trademark/non-affiliation position) is in
`README.md`; release history is in `CHANGELOG.md` — read both before changing
behaviour or packaging metadata.

Target: armv7, iOS 6.0+ deployment, verified on iOS 6.1.3 (iPhone 4S).
Distribution is Cydia-only (`https://kern0x1b.github.io/cydia/`); there is no
direct device-install tooling in this repo.

## 2. Layout

- `kindlesyncfix.m` — the whole tweak: one Objective-C hook plus its
  constructor.
- `packaging/control` — the dpkg control file (identifiers, description,
  Cydia metadata, Replaces/Conflicts/Provides for old package names).
- `packaging/kindlesyncfix.plist` — the MobileSubstrate filter that scopes the
  hook to the Kindle bundle ID.
- `assets/icon.png` — package icon, also shown at the top of the README.
- `xmake.lua`, `xmake-addons.lock`, `xmake-requires.lock` — build
  configuration and the pinned Charon addon / SDK / linker / signing-tool
  versions.
- `build/`, `dist/`, `.xmake/` — generated, gitignored. Never treat as source.

## 3. Build, package, publish

This repo builds with [xmake](https://xmake.io) and the
[Charon](https://github.com/kern0x1b/charon) addon (`add_addons("charon
v0.2.1")` in `xmake.lua`, pinned by commit in `xmake-addons.lock`; the SDK,
`ld64` and `ldid` it fetches are pinned in `xmake-requires.lock`). No Xcode
project, no Theos, no CocoaPods.

Once per machine:

```sh
brew install xmake llvm
xcode-select --install
```

and copy `dyld_shared_cache_armv7` from an iOS 6 device to `~/.charon/dyld/`
— Charon checks every import the dylib makes against that cache and refuses
the build if it is missing.

Build and package:

```sh
xmake
xmake deb
```

The `.deb` lands in `build/`. The package version comes from `set_version()`
in `xmake.lua`; every other control field (`Package`, `Depends`,
`Replaces`/`Conflicts`/`Provides`, description, homepage) lives in
`packaging/control`, not in `xmake.lua`. The MobileSubstrate filter is
`packaging/kindlesyncfix.plist`, wired in via `set_values("tweak.filter",
...)`.

Publishing to the Cydia repo is manual, not scripted here — see the
**Publishing** section of `README.md` for the exact steps
(`CYDIA_REPO=... ; cp build/*.deb ...; dpkg-scanpackages; gzip; git commit;
git push` against the separate `kern0x1b/cydia` checkout). There is no CI
publish path; do not add one without being asked.

## 4. Conventions

- **Commits**: plain imperative subject, no `feat:`/`fix:`/`chore:` prefix
  (a few early commits used prefixes; the convention since the Charon
  migration is a bare imperative line). The body is prose explaining *why*,
  not a bullet log of *what* — read `git log` before writing one.
- **No real name in any tracked file or identifier.** Package IDs
  (`space.kern0x1b.*`), `Maintainer`/`Author` in `packaging/control`, the
  README, and the LICENSE copyright line all use the `kern0x1b` handle only.
  This repo's history includes two commits (`Drop Havrysh branding`, `scrub
  real name from docs/metadata`) undoing a real name that leaked in; do not
  reintroduce one in any form (commit body, control file, URLs, comments).
- **Package renames carry their history forward.** If the package identifier
  or dylib name ever changes again, add the old identifier to
  `Replaces`/`Conflicts`/`Provides` in `packaging/control` rather than leaving
  the old package to coexist on-device — this is precedent, not a one-off.
- Version is bumped in exactly one place, `set_version()` in `xmake.lua`; keep
  `CHANGELOG.md` in Keep-a-Changelog format in sync with it.

## 5. Traps

- The package's data archive must stay `data.tar.gz`. It was `data.tar.lzma`
  before the xmake/Charon migration; that format only some dpkg builds can
  read, and this tweak targets exactly the kind of old, minimal dpkg an iOS 6
  jailbreak ships. Don't let a packaging change silently switch it back.
- `xmake` will not build without `~/.charon/dyld/dyld_shared_cache_armv7`
  present — the failure is an import-check failure inside the Charon addon,
  not an obviously missing-file error. Fetch the cache from a real iOS 6
  device first.
- There is no `device.env` or SSH device-deploy step in this repo (unlike
  some sibling repos in this workspace). Testing happens by installing the
  built `.deb` through Cydia (or `dpkg -i` it by hand on a jailbroken
  device) — do not assume a `charon device run/copy` style CLI exists here;
  that belongs to a different, Conan-based generation of the Charon
  toolchain used elsewhere in this workspace, not the xmake addon this repo
  pins.
