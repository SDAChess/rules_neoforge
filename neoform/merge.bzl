"""Rule for merging the Minecraft client and server JARs."""

def _merge_jars_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".jar")
    java_runtime = ctx.toolchains["@bazel_tools//tools/jdk:runtime_toolchain_type"].java_runtime

    args = ctx.actions.args()
    args.add("-jar")
    args.add(ctx.file._tool)
    args.add_all([
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
    ])

    ctx.actions.run(
        executable = java_runtime.java_executable_exec_path,
        arguments = [args],
        inputs = [
            ctx.file.client,
            ctx.file.server,
        ],
        mnemonic = "NeoFormMergeJars",
        outputs = [output],
        progress_message = "Merging the Minecraft client and server JARs for %{label}",
        tools = [ctx.file._tool, java_runtime.files],
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
    toolchains = ["@bazel_tools//tools/jdk:runtime_toolchain_type"],
)
