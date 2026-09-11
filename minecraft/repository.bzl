"""Defines the repository rule for a resolved Minecraft version."""

load(":download.bzl", "download_libraries", "download_version_artifacts")

def _minecraft_repository_impl(repository_ctx):
    repository_ctx.download(
        url = repository_ctx.attr.url,
        output = "version.json",
        sha256 = repository_ctx.attr.sha256,
        canonical_id = "minecraft-%s-version-json" % repository_ctx.attr.version,
    )
    version = json.decode(repository_ctx.read("version.json"))

    pending = []
    pending.extend(download_version_artifacts(repository_ctx, version["downloads"]))
    pending.extend(download_libraries(repository_ctx, version["libraries"]))

    for download in pending:
        download.token.wait()

    repository_ctx.file(
        "BUILD.bazel",
        'exports_files(%s, visibility = ["//visibility:public"])\n' % (
            ["version.json"] + [download.path for download in pending]
        ),
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
