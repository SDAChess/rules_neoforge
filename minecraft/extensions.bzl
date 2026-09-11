"""Defines the Bzlmod extension for resolving Minecraft versions."""

load(":repository.bzl", "minecraft_repository")

_VERSION_MANIFEST_URL = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"

def _find_version(manifest, version):
    for release in manifest["versions"]:
        if release["id"] == version:
            return release

    fail("Minecraft version %s was not found" % version)

def _resolve_version(module_ctx, manifest, version):
    release = _find_version(manifest, version)
    download = module_ctx.download(
        url = release["url"],
        output = "%s.json" % version,
        canonical_id = "minecraft-%s-version-json" % version,
    )

    # TODO: Verify Mojang's SHA-1 before accepting Bazel's computed SHA-256.
    return {
        "sha256": download.sha256,
        "url": release["url"],
    }

def _repository_name(version):
    return "minecraft_%s" % version.replace(".", "_").replace("-", "_")

def _minecraft_impl(module_ctx):
    # Download manifest of Minecraft versions.
    module_ctx.download(
        url = _VERSION_MANIFEST_URL,
        output = "version_manifest_v2.json",
    )
    manifest = json.decode(module_ctx.read("version_manifest_v2.json"))

    # Filter unique versions
    versions = sorted({
        tag.id: None
        for module in module_ctx.modules
        for tag in module.tags.version
    }.keys())

    # Resolve unique version.
    for version in versions:
        resolved = _resolve_version(module_ctx, manifest, version)
        minecraft_repository(
            name = _repository_name(version),
            sha256 = resolved["sha256"],
            url = resolved["url"],
            version = version,
        )

    # TODO: Use facts to avoid resolving unchanged versions after tags change.

minecraft = module_extension(
    implementation = _minecraft_impl,
    tag_classes = {
        "version": tag_class(
            attrs = {
                "id": attr.string(mandatory = True),
            },
        ),
    },
)
