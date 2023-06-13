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
    # Copy PyTorch to the binary cache
    + ''
      time nix copy ${python3Packages.pytorch.outPath} \
        --print-build-logs \
        --to "file:///$BINARY_CACHE?compression=${compression}&compression-level=${compression-level}"
    ''
    # Print the size of the binary cache
    + ''
      CACHE_SIZE="$(
        du -B1 -s "$BINARY_CACHE" \
          | cut -f1 \
          | numfmt --to iec --format '%.4f'
      )"
      echo "PyTorch Nix binary cache size: $CACHE_SIZE"
    ''
    # Cleanup
    + ''
      rm -rf "$BINARY_CACHE"
    '';
}
