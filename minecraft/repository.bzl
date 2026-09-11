"""Defines the repository rule for a resolved Minecraft version."""

load(":download.bzl", "download_libraries", "download_version_artifacts")

_OS_NAMES = ["linux", "osx", "windows"]

def _library_os(library):
    if not library.rules:
        return None

    rule = library.rules[0]
    os = rule.get("os")

    return os["name"]

def _build_substitutions(downloads, libraries):
    common_libraries = []
    platform_libraries = {
        os: []
        for os in _OS_NAMES
    }

    for library in libraries:
        os = _library_os(library)
        if os == None:
            common_libraries.append(library.path)
        else:
            platform_libraries[os].append(library.path)

    return {
        "{{COMMON_LIBRARIES}}": str(sorted(common_libraries)),
        "{{DOWNLOADS}}": str(["version.json"] + sorted([download.path for download in downloads])),
        "{{LINUX_LIBRARIES}}": str(sorted(platform_libraries["linux"])),
        "{{MACOS_LIBRARIES}}": str(sorted(platform_libraries["osx"])),
        "{{WINDOWS_LIBRARIES}}": str(sorted(platform_libraries["windows"])),
    }

def _minecraft_repository_impl(repository_ctx):
    repository_ctx.download(
        url = repository_ctx.attr.url,
        output = "version.json",
        sha256 = repository_ctx.attr.sha256,
        canonical_id = "minecraft-%s-version-json" % repository_ctx.attr.version,
    )
    version = json.decode(repository_ctx.read("version.json"))

    artifacts = download_version_artifacts(repository_ctx, version["downloads"])
    libraries = download_libraries(repository_ctx, version["libraries"])
    downloads = artifacts + libraries

    for download in downloads:
        download.token.wait()

    repository_ctx.template(
        "BUILD.bazel",
        repository_ctx.attr._build_template,
        substitutions = _build_substitutions(downloads, libraries),
        executable = False,
    )

minecraft_repository = repository_rule(
    implementation = _minecraft_repository_impl,
    attrs = {
        "_build_template": attr.label(
            default = Label("//minecraft:BUILD.bazel.tpl"),
            allow_single_file = True,
        ),
        "sha256": attr.string(mandatory = True),
        "url": attr.string(mandatory = True),
        "version": attr.string(mandatory = True),
    },
)
