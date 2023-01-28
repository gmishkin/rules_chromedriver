load("@bazel_skylib//rules:native_binary.bzl", "native_binary")
load("@bazel_skylib//lib:selects.bzl", "selects")

selects.config_setting_group(
    name = "linux64",
    match_all = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
)

selects.config_setting_group(
    name = "mac64",
    match_all = [
        "@platforms//cpu:x86_64",
        "@platforms//os:macos",
    ],
)

selects.config_setting_group(
    name = "mac_arm64",
    match_all = [
        "@platforms//cpu:arm64",
        "@platforms//os:macos",
    ],
)

selects.config_setting_group(
    name = "win32",
    match_all = [
        "@platforms//cpu:x86_64",
        "@platforms//os:windows",
    ],
)

native_binary(
    name = "chromedriver",
    src = select({
        ":linux64": "@chromedriver_linux64//:driver",
        ":mac64": "@chromedriver_mac64//:driver",
        ":mac_arm64": "@chromedriver_mac_arm64//:driver",
    }),
    out = "chromedriver",
    visibility = ["//visibility:public"],
)
