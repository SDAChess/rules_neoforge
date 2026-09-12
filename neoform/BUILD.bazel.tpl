exports_files(
    [
        "config.json",
        "config/joined.tsrg",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "inject",
    srcs = glob(["config/inject/**"]),
    visibility = ["//visibility:public"],
)
