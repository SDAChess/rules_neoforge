"""Rule for merging NeoForm and official Minecraft mappings."""

def _merge_mappings_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".tsrg")
    java_runtime = ctx.toolchains["@bazel_tools//tools/jdk:runtime_toolchain_type"].java_runtime

    args = ctx.actions.args()
    args.add("-jar")
    args.add(ctx.file._tool)
    args.add_all([
        "--task",
        "MERGE_MAPPING",
        "--left",
        ctx.file.mappings,
        "--right",
        ctx.file.official,
        "--right-names",
        "right,left",
        "--classes",
        "--fields",
        "--methods",
        "--output",
        output,
    ])

    ctx.actions.run(
        executable = java_runtime.java_executable_exec_path,
        arguments = [args],
        inputs = [
            ctx.file.mappings,
            ctx.file.official,
        ],
        mnemonic = "NeoFormMergeMappings",
        outputs = [output],
        progress_message = "Merging NeoForm and official mappings for %{label}",
        tools = [ctx.file._tool, java_runtime.files],
    )

    return DefaultInfo(files = depset([output]))

merge_mappings = rule(
    implementation = _merge_mappings_impl,
    attrs = {
        "mappings": attr.label(
            allow_single_file = [".tsrg"],
            mandatory = True,
        ),
        "official": attr.label(
            allow_single_file = [".txt"],
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
