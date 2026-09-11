"""Rule for splitting classes and resources from a JAR."""

def _split_jar_impl(ctx):
    args = ctx.actions.args()
    args.add(ctx.file.src)
    args.add(ctx.outputs.classes)
    args.add(ctx.outputs.resources)

    ctx.actions.run(
        executable = ctx.attr._tool[DefaultInfo].files_to_run,
        arguments = [args],
        inputs = [ctx.file.src],
        mnemonic = "NeoFormSplitJar",
        outputs = [
            ctx.outputs.classes,
            ctx.outputs.resources,
        ],
        progress_message = "Splitting classes and resources from %{label}",
    )

    return DefaultInfo(files = depset([
        ctx.outputs.classes,
        ctx.outputs.resources,
    ]))

split_jar = rule(
    implementation = _split_jar_impl,
    attrs = {
        "classes": attr.output(mandatory = True),
        "resources": attr.output(mandatory = True),
        "src": attr.label(
            allow_single_file = [".jar"],
            mandatory = True,
        ),
        "_tool": attr.label(
            cfg = "exec",
            default = Label("//tools/split_jar"),
            executable = True,
        ),
    },
)
