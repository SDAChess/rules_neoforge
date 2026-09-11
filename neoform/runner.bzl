"""Helpers for running external tools."""

JAVA_RUNTIME_TOOLCHAIN = "@bazel_tools//tools/jdk:runtime_toolchain_type"

def run_java_jar(
        ctx,
        jar,
        arguments,
        inputs,
        outputs,
        mnemonic,
        progress_message,
        jvm_args = []):
    """Runs an executable JAR with the configured Java runtime toolchain.

    Args:
      ctx: The rule context used to register the action.
      jar: The executable JAR file.
      arguments: Arguments passed to the JAR.
      inputs: Input files required by the action.
      outputs: Output files produced by the action.
      mnemonic: The action mnemonic.
      progress_message: The message displayed while the action runs.
      jvm_args: Arguments passed to the Java runtime.
    """
    java_runtime = ctx.toolchains[JAVA_RUNTIME_TOOLCHAIN].java_runtime

    args = ctx.actions.args()
    args.add_all(jvm_args)
    args.add("-jar")
    args.add(jar)
    args.add_all(arguments)

    ctx.actions.run(
        executable = java_runtime.java_executable_exec_path,
        arguments = [args],
        inputs = inputs,
        mnemonic = mnemonic,
        outputs = outputs,
        progress_message = progress_message,
        tools = [jar, java_runtime.files],
    )
