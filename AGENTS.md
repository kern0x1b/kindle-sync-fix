# kindle-sync-fix

## 1. What this is

A MobileSubstrate tweak (`src/kindlesyncfix.m`, one file) that fixes the Kindle
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
Distribution is Cydia-only (`https://kern0x1b.github.io/cydia/`); for testing,
the pinned addon's `xmake device install` puts the built `.deb` on a device
(see Traps).

Workspace-wide procedures are skills in `$HOME/Git/projects/ios/.agents/skills/`: `device-session` (claim, run, install, launch, tap on a real device), `canon-install`, `patch-merge`, `worktree-sweep`, `session-handoff`, `band-launch`, `band-supervise`. A session started inside this repository does not list them — read `<name>/SKILL.md` there.

## 2. Layout

- `src/kindlesyncfix.m` — the whole tweak: one Objective-C hook plus its
  constructor.
- `packaging/control` — the dpkg control file (identifiers, description,
  Cydia metadata, Replaces/Conflicts/Provides for old package names).
- `packaging/kindlesyncfix.plist` — the MobileSubstrate filter that scopes the
  hook to the Kindle bundle ID.
- `assets/icon.png` — package icon, also shown at the top of the README.
- `xmake.lua`, `xmake-addons.lock`, `xmake-requires.lock` — build
  configuration and the pinned revenant addon / SDK / linker / signing-tool
  versions.
- `build/`, `dist/`, `.xmake/` — generated, gitignored. Never treat as source.

## 3. Build, package, publish

This repo builds with the [revenant](https://github.com/kern0x1b/revenant)
toolchain from a local checkout, named by `REVENANT_PATH` in `xmake.lua`
(default: the `revenant` checkout beside this repo). `xmake.lua` registers that
checkout as the `revenant` repository and takes the addon from its `toolchain/`
directory; the SDK, `ld64`, `ldid` and LLVM it resolves are recorded in
`xmake-requires.lock`. No Xcode project, no Theos, no CocoaPods.

Once per machine:

```sh
xcode-select --install
```

and copy `dyld_shared_cache_armv7` from an iOS 6 device into the revenant
checkout's dyld cache under `.cache/dyld/` — the toolchain checks every import
the dylib makes against that cache and refuses the build if it is missing.

Build and package through that checkout's `xmakew` (a worktree needs
`REVENANT_PATH` set, since the default is relative to the main checkout):

```sh
"$REVENANT_PATH/xmakew" build -P . -y
"$REVENANT_PATH/xmakew" deb -P . -y
```

Set `REVENANT_PREBUILT=kern0x1b/revenant` and
`REVENANT_PREBUILT_ONLY=llvm,swift,ld64,swift-runtime,libcxx` to take the
toolchain from released prebuilts instead of compiling it from source.

The `.deb` lands in `build/`. The package version comes from `set_version()`
in `xmake.lua`; every other control field (`Package`, `Depends`,
`Replaces`/`Conflicts`/`Provides`, description, homepage) lives in
`packaging/control`, not in `xmake.lua`. The MobileSubstrate filter is
`packaging/kindlesyncfix.plist`, wired in via `set_values("tweak.filter",
...)`.

Publishing is done from the separate `cydia` repository
(`$HOME/Git/projects/ios/cydia`) with `xmake l tools/publish.lua`, following that
repository's `publish-tweak` skill (`.agents/skills/publish-tweak/SKILL.md`
there). There is no CI publish path; do not add one without being asked.

## 4. Conventions

- **Commits**: plain imperative subject, no `feat:`/`fix:`/`chore:` prefix
  (a few early commits used prefixes; the convention since the toolchain
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
  before the xmake/Revenant migration; that format only some dpkg builds can
  read, and this tweak targets exactly the kind of old, minimal dpkg an iOS 6
  jailbreak ships. Don't let a packaging change silently switch it back.
- The build will not link without the dyld cache in the revenant checkout's
  `.cache/dyld/` — the failure is an import-check failure inside the addon,
  not an obviously missing-file error. Fetch the cache from a real iOS 6
  device first.
- The addon from the local checkout has `xmake device install|log|run|where`
  (`-d NAME`, `-s SECONDS`) but no `list`, `claim` or `release`, and checks no
  claim: claim with a current toolchain first, as the workspace `device-session`
  skill says. It also needs a `device.env` in this directory, which a checkout
  does not have — copy the shared one in; `device*.env` is gitignored, never
  commit it.
