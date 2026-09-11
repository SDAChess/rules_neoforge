"""Rule for extracting the server JAR from the Minecraft server bundle."""


def _bundle_extract_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".jar")
    java_runtime = ctx.toolchains["@bazel_tools//tools/jdk:runtime_toolchain_type"].java_runtime

    args = ctx.actions.args()
    args.add("-jar")
    args.add(ctx.file._tool)
    args.add_all([
        "--task",
        "bundler_extract",
        "--input",
        ctx.file.src,
        "--output",
        output,
        "--jar-only",
    ])

    ctx.actions.run(
        executable = java_runtime.java_executable_exec_path,
        arguments = [args],
        inputs = [ctx.file.src],
        mnemonic = "NeoFormBundleExtract",
        outputs = [output],
        progress_message = "Extracting the server JAR from %{label}",
        tools = [ctx.file._tool, java_runtime.files],
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
    toolchains = ["@bazel_tools//tools/jdk:runtime_toolchain_type"],
)
