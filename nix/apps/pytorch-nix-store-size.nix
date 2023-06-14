{
  nix,
  python3Packages,
  writeShellApplication,
}:
writeShellApplication {
  name = "pytorch-nix-store-size";
  runtimeInputs = [nix];
  text = ''
    SIZE="$(nix path-info -S ${python3Packages.pytorch.outPath} | cut -f2)"
    HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$SIZE")"
    printf '{"size": %d, "human_readable": "%s"}\n' "$SIZE" "$HUMAN_READABLE"
  '';
}
