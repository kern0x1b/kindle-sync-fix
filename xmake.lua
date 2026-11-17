set_project("kindlesyncfix")
set_version("1.0.2")
set_policy("package.requires_lock", true)

local revenant = os.getenv("REVENANT_PATH") or path.directory(os.scriptdir()) .. "/revenant"
add_repositories("revenant " .. revenant)
add_addons("revenant", {sourcedir = path.join(revenant, "toolchain")})
set_config("apple_minimum", "6.0")
includes("@addon/revenant/apple-ios")

set_allowedplats("iphoneos")
set_allowedarchs("iphoneos|armv7")
set_defaultplat("iphoneos")
set_defaultarchs("iphoneos|armv7")

target("kindlesyncfix")
    add_rules("@addon/revenant/tweak")
    add_files("src/kindlesyncfix.m")
    add_frameworks("Foundation")
    set_optimize("faster")
    set_values("tweak.filter", "packaging/kindlesyncfix.plist")
    set_values("revenant.control", "packaging/control")
