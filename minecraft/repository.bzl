"""Defines the repository rule for a resolved Minecraft version."""

def _minecraft_repository_impl(repository_ctx):
    repository_ctx.download(
        url = repository_ctx.attr.url,
        output = "version.json",
        sha256 = repository_ctx.attr.sha256,
        canonical_id = "minecraft-%s-version-json" % repository_ctx.attr.version,
    )

    repository_ctx.file(
        "BUILD.bazel",
        'exports_files(["version.json"], visibility = ["//visibility:public"])\n',
        executable = False,
    )

minecraft_repository = repository_rule(
    implementation = _minecraft_repository_impl,
    attrs = {
        "sha256": attr.string(mandatory = True),
        "url": attr.string(mandatory = True),
        "version": attr.string(mandatory = True),
    },
)
