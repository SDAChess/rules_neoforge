"""Rule for decompiling a Minecraft JAR."""

load(":runner.bzl", "JAVA_RUNTIME_TOOLCHAIN", "run_java_jar")

def _decompile_jar_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".jar")
    config = ctx.actions.declare_file(ctx.label.name + ".cfg")

    ctx.actions.write(
        config,
        "\n".join(["-e=%s" % library.path for library in ctx.files.libraries]),
    )

    run_java_jar(
        ctx = ctx,
        jar = ctx.file._tool,
        arguments = [
            "--decompile-inner",
            "--remove-bridge",
            "--decompile-generics",
            "--ascii-strings",
            "--remove-synthetic",
            "--include-classpath",
            "--variable-renaming=jad",
            "--ignore-invalid-bytecode",
            "--bytecode-source-mapping",
            "--dump-code-lines",
            "--indent-string=    ",
            "--log-level=TRACE",
            "-cfg",
            config,
            ctx.file.src,
            output,
        ],
        inputs = [
            ctx.file.src,
            config,
        ] + ctx.files.libraries,
        jvm_args = ["-Xmx4G"],
        mnemonic = "NeoFormDecompileJar",
        outputs = [output],
        progress_message = "Decompiling the Minecraft JAR for %{label}",
    )

    return DefaultInfo(files = depset([output]))

decompile_jar = rule(
    implementation = _decompile_jar_impl,
    attrs = {
        "libraries": attr.label(
            allow_files = [".jar"],
            mandatory = True,
        ),
        "src": attr.label(
            allow_single_file = [".jar"],
            mandatory = True,
        ),
        "_tool": attr.label(
            allow_single_file = [".jar"],
            cfg = "exec",
            default = Label("@rules_neoforge_tools//:org_vineflower_vineflower"),
        ),
    },
    toolchains = [JAVA_RUNTIME_TOOLCHAIN],
)
