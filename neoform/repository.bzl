"""Defines the repository rule for NeoForm data."""

def _neoform_repository_impl(repository_ctx):
    version = repository_ctx.attr.version
    repository_ctx.download_and_extract(
        url = "https://maven.neoforged.net/releases/net/neoforged/neoform/%s/neoform-%s.zip" % (version, version),
        sha256 = repository_ctx.attr.sha256,
        canonical_id = "neoform-%s" % version,
    )

    repository_ctx.template(
        "BUILD.bazel",
        repository_ctx.attr._build_template,
        executable = False,
    )

neoform_repository = repository_rule(
    implementation = _neoform_repository_impl,
    attrs = {
        "_build_template": attr.label(
            default = Label("//neoform:BUILD.bazel.tpl"),
            allow_single_file = True,
        ),
        "sha256": attr.string(mandatory = True),
        "version": attr.string(mandatory = True),
    },
)
