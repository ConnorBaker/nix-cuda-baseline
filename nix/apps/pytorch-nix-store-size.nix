{
  jq,
  nix,
  python3Packages,
  writeShellApplication,
}:
writeShellApplication {
  name = "pytorch-nix-store-size";
  runtimeInputs = [jq nix];
  text = ''
    SIZE="$(nix path-info -S ${python3Packages.pytorch.outPath} | cut -f2)"
    HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$SIZE")"
    jq -cnr \
      --argjson size "$SIZE" \
      --arg human_readable "$HUMAN_READABLE" \
      '{size: $size, human_readable: $human_readable}'
  '';
}
