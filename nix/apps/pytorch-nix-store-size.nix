{
  nix,
  python3Packages,
  writeShellApplication,
}:
writeShellApplication {
  name = "pytorch-nix-store-size";
  runtimeInputs = [nix];
  text = ''
    CLOSURE_SIZE="$(
      nix path-info -S ${python3Packages.pytorch.outPath} \
        | cut -f2 \
        | numfmt --to iec --format '%.4f'
    )"
    echo "PyTorch Nix store closure size: $CLOSURE_SIZE"
  '';
}
