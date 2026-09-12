"""Rule for applying NeoForm source patches."""

load(":runner.bzl", "JAVA_RUNTIME_TOOLCHAIN", "run_java_jar")

def _patch_sources_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".srcjar")
    rejects = ctx.actions.declare_file(ctx.label.name + "_rejects.zip")

    run_java_jar(
        ctx = ctx,
        jar = ctx.file._tool,
        arguments = [
            ctx.file.src,
            ctx.file.patches,
            "--prefix",
            "patches/joined/",
            "--patch",
            "--archive",
            "ZIP",
            "--output",
            output,
            "--log-level",
            "WARN",
            "--mode",
            "OFFSET",
            "--archive-rejects",
            "ZIP",
            "--reject",
            rejects,
        ],
        inputs = [
            ctx.file.src,
            ctx.file.patches,
        ],
        mnemonic = "NeoFormPatchSources",
        outputs = [
            output,
            rejects,
        ],
        progress_message = "Applying NeoForm source patches for %{label}",
    )

    return DefaultInfo(files = depset([output]))

patch_sources = rule(
    implementation = _patch_sources_impl,
    attrs = {
        "patches": attr.label(
            allow_single_file = [".zip"],
            mandatory = True,
        ),
        "src": attr.label(
            allow_single_file = [".jar"],
            mandatory = True,
        ),
        "_tool": attr.label(
            allow_single_file = [".jar"],
            cfg = "exec",
            default = Label("@rules_neoforge_tools//:codechicken_DiffPatch_all"),
        ),
    },
    toolchains = [JAVA_RUNTIME_TOOLCHAIN],
)
