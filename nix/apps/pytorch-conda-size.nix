{
  coreutils,
  micromamba,
  pytorchBuild ? "py3.10_cuda11.8_cudnn8.7.0_0",
  pytorchVersion ? "2.0.1",
  writeShellApplication,
}:
writeShellApplication {
  name = "pytorch-conda-size-${pytorchVersion}-${pytorchBuild}";
  runtimeInputs = [coreutils micromamba];
  text =
    # Export the root prefix so that micromamba will use it
    ''
      MAMBA_ROOT_PREFIX="$(mktemp -d)"
      export MAMBA_ROOT_PREFIX
    ''
    # Initialize micromamba
    + ''
      eval "$(micromamba shell hook -s posix)"
    ''
    # Create the pytorch environment
    + ''
      micromamba create -y \
        -n pytorch \
        -c pytorch \
        -c nvidia \
        -c conda-forge \
        pytorch=${pytorchVersion}=${pytorchBuild}
    ''
    # Get the size of the pytorch environment
    + ''
      ENV_SIZE="$(
        du -B1 -s "$MAMBA_ROOT_PREFIX/envs/pytorch" \
          | cut -f1 \
          | numfmt --to iec --format '%.4f'
      )"
      echo "PyTorch conda environment size: $ENV_SIZE"
    ''
    # Get the size of the pkgs directory
    + ''
      PKGS_SIZE="$(
        du -B1 -s "$MAMBA_ROOT_PREFIX/pkgs" \
          | cut -f1 \
          | numfmt --to iec --format '%.4f'
      )"
      echo "PyTorch conda pkgs directory size: $PKGS_SIZE"
    ''
    # Get the size of the compressed files in the pkgs directory
    + ''
      PKGS_COMPRESSED_SIZE="$(
        du -B1 -sS "$MAMBA_ROOT_PREFIX/pkgs" \
          | cut -f1 \
          | numfmt --to iec --format '%.4f'
      )"
      echo "PyTorch conda pkgs directory compressed files size (download size): $PKGS_COMPRESSED_SIZE"
    ''
    # Cleanup
    + ''
      rm -rf "$MAMBA_ROOT_PREFIX"
    '';
}
