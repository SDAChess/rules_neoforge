# rules_neoforge

An experimental proof of concept for building Minecraft and, eventually,
NeoForge mods with Bazel.

The goal is to let Bazel own the complete build graph instead of delegating it
to another build driver. Each transformation should be explicit, cacheable,
and reproducible while still consuming the data published by NeoForm.

## Current status

The repository currently reproduces the NeoForm `joined` pipeline for
Minecraft 1.21.1:

```text
download -> extract/split -> merge -> merge mappings -> rename
         -> decompile -> inject -> patch -> recompile
```

The result is a recompiled Minecraft JAR containing 8,270 classes.

This has only been tested on x86-64 Linux. Minecraft launching, assets,
extracted natives, NeoForge's userdev layer, and mod compilation are not
implemented yet. Versions, tools, and some NeoForm libraries are still wired
specifically for this proof of concept; there is no stable public API.

## Building

Enter the Nix development shell and build the final target:

```console
nix develop
bazel build //:recompile
```

The resulting JAR is written to `bazel-bin/librecompile.jar`.

## Credits and third-party projects

This project would not exist without the work of the
[NeoForged](https://neoforged.net/) community.

- [NeoForm](https://github.com/neoforged/NeoForm) provides the configuration,
  mappings, injected sources, and patches used to produce recompilable
  Minecraft sources.
- [NeoFormRuntime](https://github.com/neoforged/NeoFormRuntime) is the reference
  implementation for interpreting NeoForm data and was used to understand the
  intended pipeline and tool invocations.
- The pipeline uses upstream tools including
  [InstallerTools](https://github.com/neoforged/InstallerTools), MergeTool,
  AutoRenamingTool, [Vineflower](https://github.com/Vineflower/vineflower), and
  [DiffPatch](https://github.com/TheCBProject/DiffPatch).

This repository does not redistribute Minecraft or NeoForm artifacts; they are
downloaded from their upstream repositories during dependency resolution.
Those artifacts and tools remain subject to their respective licenses and
terms. The Apache-2.0 license in this repository applies only to this project's
own code.

This is an independent project. It is not affiliated with or endorsed by
NeoForged, Mojang Studios, or Microsoft. Minecraft is a trademark of Microsoft.

## License

Licensed under the [Apache License 2.0](LICENSE).
