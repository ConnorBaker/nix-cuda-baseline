{
  compression ? "xz",
  compression-level ? "-1",
  nix,
  python3Packages,
  writeShellApplication,
}:
writeShellApplication {
  name = "pytorch-nix-binary-cache-size-${compression}-${compression-level}";
  runtimeInputs = [nix];
  text =
    # Create the temporary binary cache
    ''
      BINARY_CACHE="$(mktemp -d)"
    ''
    # Copy PyTorch to the binary cache (without printing anything to stdout)
    + ''
      nix copy -v ${python3Packages.pytorch.outPath} 1>&2 \
        --to "file:///$BINARY_CACHE?compression=${compression}&compression-level=${compression-level}"
    ''
    # Print the size of the binary cache
    + ''
      SIZE="$(du -B1 -s "$BINARY_CACHE" | cut -f1)"
      HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$SIZE")"
      printf '{"size": %d, "human_readable": "%s"}\n' "$SIZE" "$HUMAN_READABLE"
    ''
    # Cleanup
    + ''
      rm -rf "$BINARY_CACHE"
    '';
}
