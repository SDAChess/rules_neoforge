"""Helpers for scheduling Minecraft downloads."""

def _schedule_download(repository_ctx, artifact, directory):
    relative_path = artifact.get("path")
    if relative_path == None:
        relative_path = artifact["url"].split("/")[-1]

    path = "%s/%s" % (directory, relative_path)
    return struct(
        path = path,
        token = repository_ctx.download(
            url = artifact["url"],
            output = path,
            canonical_id = "minecraft-%s-%s" % (repository_ctx.attr.version, path),
            block = False,
        ),
    )

def _schedule_library_download(repository_ctx, library):
    download = _schedule_download(
        repository_ctx,
        library["downloads"]["artifact"],
        "libraries",
    )
    return struct(
        path = download.path,
        rules = library.get("rules", []),
        token = download.token,
    )

def download_version_artifacts(repository_ctx, artifacts):
    return [
        _schedule_download(
            repository_ctx,
            artifacts[name],
            "downloads",
        )
        for name in sorted(artifacts)
    ]

def download_libraries(repository_ctx, libraries):
    return [
        _schedule_library_download(repository_ctx, library)
        for library in libraries
    ]
