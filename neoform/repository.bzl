"""Defines the repository rule for NeoForm data."""

def _neoform_repository_impl(repository_ctx):
    version = repository_ctx.attr.version
    repository_ctx.download_and_extract(
        url = "https://maven.neoforged.net/releases/net/neoforged/neoform/%s/neoform-%s.zip" % (version, version),
        sha256 = repository_ctx.attr.sha256,
        canonical_id = "neoform-%s" % version,
    )

    repository_ctx.file(
        "BUILD.bazel",
        'exports_files(["config.json", "config/joined.tsrg"], visibility = ["//visibility:public"])\n',
        executable = False,
    )

neoform_repository = repository_rule(
    implementation = _neoform_repository_impl,
    attrs = {
        "sha256": attr.string(mandatory = True),
        "version": attr.string(mandatory = True),
    },
)
