"""Rule for merging NeoForm and official Minecraft mappings."""

load(":runner.bzl", "JAVA_RUNTIME_TOOLCHAIN", "run_java_jar")

def _merge_mappings_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".tsrg")

    run_java_jar(
        ctx = ctx,
        jar = ctx.file._tool,
        arguments = [
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
        ],
        inputs = [
            ctx.file.mappings,
            ctx.file.official,
        ],
        mnemonic = "NeoFormMergeMappings",
        outputs = [output],
        progress_message = "Merging NeoForm and official mappings for %{label}",
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
    toolchains = [JAVA_RUNTIME_TOOLCHAIN],
)
