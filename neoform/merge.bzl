"""Rule for merging the Minecraft client and server JARs."""

load(":runner.bzl", "JAVA_RUNTIME_TOOLCHAIN", "run_java_jar")

def _merge_jars_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".jar")

    run_java_jar(
        ctx = ctx,
        jar = ctx.file._tool,
        arguments = [
            "--client",
            ctx.file.client,
            "--server",
            ctx.file.server,
            "--ann",
            ctx.attr.version,
            "--output",
            output,
            "--inject",
            "false",
        ],
        inputs = [
            ctx.file.client,
            ctx.file.server,
        ],
        mnemonic = "NeoFormMergeJars",
        outputs = [output],
        progress_message = "Merging the Minecraft client and server JARs for %{label}",
    )

    return DefaultInfo(files = depset([output]))

merge_jars = rule(
    implementation = _merge_jars_impl,
    attrs = {
        "client": attr.label(
            allow_single_file = [".jar"],
            mandatory = True,
        ),
        "server": attr.label(
            allow_single_file = [".jar"],
            mandatory = True,
        ),
        "version": attr.string(mandatory = True),
        "_tool": attr.label(
            allow_single_file = [".jar"],
            cfg = "exec",
            default = Label("@rules_neoforge_tools//:net_neoforged_mergetool_fatjar"),
        ),
    },
    toolchains = [JAVA_RUNTIME_TOOLCHAIN],
)
