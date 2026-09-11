"""Rule for extracting the server JAR from the Minecraft server bundle."""

load(":runner.bzl", "JAVA_RUNTIME_TOOLCHAIN", "run_java_jar")

def _bundle_extract_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".jar")

    run_java_jar(
        ctx = ctx,
        jar = ctx.file._tool,
        arguments = [
            "--task",
            "bundler_extract",
            "--input",
            ctx.file.src,
            "--output",
            output,
            "--jar-only",
        ],
        inputs = [ctx.file.src],
        mnemonic = "NeoFormBundleExtract",
        outputs = [output],
        progress_message = "Extracting the server JAR from %{label}",
    )

    return DefaultInfo(files = depset([output]))

bundle_extract = rule(
    implementation = _bundle_extract_impl,
    attrs = {
        "src": attr.label(
            allow_single_file = [".jar"],
            mandatory = True,
        ),
        "_tool": attr.label(
            allow_single_file = [".jar"],
            cfg = "exec",
            default = Label("@rules_neoforge_tools//:net_neoforged_installertools_installertools_fatjar"),
        ),
    },
    toolchains = [JAVA_RUNTIME_TOOLCHAIN],
)
