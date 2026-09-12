"""Rule for renaming a Minecraft JAR."""

load(":runner.bzl", "JAVA_RUNTIME_TOOLCHAIN", "run_java_jar")

def _rename_jar_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".jar")
    config = ctx.actions.declare_file(ctx.label.name + ".cfg")

    config_args = ctx.actions.args()
    config_args.add_all(ctx.files.libraries, before_each = "--lib")
    ctx.actions.write(config, config_args)

    run_java_jar(
        ctx = ctx,
        jar = ctx.file._tool,
        arguments = [
            "--input",
            ctx.file.src,
            "--output",
            output,
            "--map",
            ctx.file.mappings,
            "--cfg",
            config,
            "--ann-fix",
            "--ids-fix",
            "--src-fix",
            "--record-fix",
            "--unfinal-params",
        ],
        inputs = [
            ctx.file.src,
            ctx.file.mappings,
            config,
        ] + ctx.files.libraries,
        mnemonic = "NeoFormRenameJar",
        outputs = [output],
        progress_message = "Renaming the Minecraft JAR for %{label}",
    )

    return DefaultInfo(files = depset([output]))

rename_jar = rule(
    implementation = _rename_jar_impl,
    attrs = {
        "libraries": attr.label(
            allow_files = [".jar"],
            mandatory = True,
        ),
        "mappings": attr.label(
            allow_single_file = [".tsrg"],
            mandatory = True,
        ),
        "src": attr.label(
            allow_single_file = [".jar"],
            mandatory = True,
        ),
        "_tool": attr.label(
            allow_single_file = [".jar"],
            cfg = "exec",
            default = Label("@rules_neoforge_tools//:net_neoforged_AutoRenamingTool_all"),
        ),
    },
    toolchains = [JAVA_RUNTIME_TOOLCHAIN],
)
