package dev.sdachess.rules_neoforge.split;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.jar.JarOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

public final class SplitJar {
    public static void main(String[] args) throws IOException {
        if (args.length != 3) {
            throw new IllegalArgumentException("expected: <input> <classes> <resources>");
        }

        split(Path.of(args[0]), Path.of(args[1]), Path.of(args[2]));
    }

    private static void split(Path input, Path classes, Path resources) throws IOException {
        try (
                var jar = new ZipFile(input.toFile());
                var classesOutput = output(classes);
                var resourcesOutput = output(resources)
        ) {
            var entries = jar.entries();

            while (entries.hasMoreElements()) {
                var entry = entries.nextElement();

                if (entry.isDirectory() || entry.getName().startsWith("META-INF/")) {
                    continue;
                }

                var destination = entry.getName().endsWith(".class") ? classesOutput : resourcesOutput;
                copy(jar, entry, destination);
            }
        }
    }

    private static JarOutputStream output(Path path) throws IOException {
        return new JarOutputStream(new BufferedOutputStream(Files.newOutputStream(path)));
    }

    private static void copy(ZipFile jar, ZipEntry entry, JarOutputStream output) throws IOException {
        output.putNextEntry(new ZipEntry(entry.getName()));
        try (var input = jar.getInputStream(entry)) {
            input.transferTo(output);
        }
        output.closeEntry();
    }
}
