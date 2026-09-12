"""Rule for injecting files into a source JAR."""

def _resource(file):
    return "%s:%s" % (file.path, file.path.split("config/inject/")[-1])

def _inject_sources_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".jar")

    args = ctx.actions.args()
    args.add("--output")
    args.add(output)
    args.add("--sources")
    args.add(ctx.file.src)
    args.add("--resources")
    args.add_all(ctx.files.inject, map_each = _resource)
    args.add("--normalize")

    ctx.actions.run(
        executable = ctx.file._singlejar,
        arguments = [args],
        inputs = [ctx.file.src] + ctx.files.inject,
        mnemonic = "NeoFormInjectSources",
        outputs = [output],
        progress_message = "Injecting sources into %{label}",
    )

    return DefaultInfo(files = depset([output]))

inject_sources = rule(
    implementation = _inject_sources_impl,
    attrs = {
        "inject": attr.label(
            allow_files = True,
            mandatory = True,
        ),
        "src": attr.label(
            allow_single_file = [".jar"],
            mandatory = True,
        ),
        "_singlejar": attr.label(
            allow_single_file = True,
            cfg = "exec",
            default = Label("@bazel_tools//tools/jdk:singlejar"),
        ),
    },
)
