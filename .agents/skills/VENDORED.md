# Vendored skills

Copied verbatim (not modified) from [xmake-io/xmake-skills](https://github.com/xmake-io/xmake-skills),
commit `ef67caa`, under the Apache License 2.0 (see that project's `LICENSE.md`).

## Vendored here

- `xmake-addons` — Use when installing or using an Xmake addon — `xmake addon --install/--list/--remove/--upgrade/--search`, declaring `add_addons(...)` in a project, and referencing addon payloads with `@addon/<name>/<rule>`, `@addon.<name>.<module>` or `@self`. For writing and publishing one, see xmake-addon-development.
- `xmake-objc` — Use when building Objective-C or Objective-C++ projects with xmake — `.m` / `.mm` sources, Cocoa / Foundation frameworks via `add_frameworks`, mixing with C++, and targeting macOS / iOS / tvOS.
- `xmake-commands` — Use when invoking Xmake from the command line — configuring, building, running, cleaning, installing, packing, or inspecting a project. Covers the common flags for `xmake f`, `xmake`, `xmake run`, `xmake install`, `xmake pack`, and friends.

To update: re-clone the source repo at a newer commit and replace these directories wholesale;
do not hand-edit vendored skill text. A workspace or repository rule always overrides a vendored
skill's advice where the two conflict (see this repository's AGENTS.md).
