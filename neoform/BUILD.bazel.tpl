exports_files(
    [
        "config.json",
        "config/joined.tsrg",
        "neoform.zip",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "inject",
    srcs = glob(["config/inject/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "patches_joined",
    srcs = glob(["patches/joined/**"]),
    visibility = ["//visibility:public"],
)
