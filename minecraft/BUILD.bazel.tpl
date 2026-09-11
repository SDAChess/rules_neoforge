exports_files(
    {{DOWNLOADS}},
    visibility = ["//visibility:public"],
)

filegroup(
    name = "libraries",
    srcs = {{COMMON_LIBRARIES}} + select({
        "@platforms//os:linux": {{LINUX_LIBRARIES}},
        "@platforms//os:macos": {{MACOS_LIBRARIES}},
        "@platforms//os:windows": {{WINDOWS_LIBRARIES}},
        "//conditions:default": [],
    }),
    visibility = ["//visibility:public"],
)
