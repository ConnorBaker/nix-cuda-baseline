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
    # Create the pytorch environment (without printing anything to STDOUT)
    + ''
      micromamba create -y 1>&2 \
        -n pytorch \
        -c pytorch \
        -c nvidia \
        -c conda-forge \
        pytorch=${pytorchVersion}=${pytorchBuild}
    ''
    # Get the size of the pytorch environment
    + ''
      ENV_SIZE="$(du -B1 -s "$MAMBA_ROOT_PREFIX/envs/pytorch" | cut -f1)"
      ENV_HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$ENV_SIZE")"
    ''
    # Get the size of the pkgs directory
    + ''
      PKGS_SIZE="$(du -B1 -s "$MAMBA_ROOT_PREFIX/pkgs" | cut -f1)"
      PKGS_HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$PKGS_SIZE")"
    ''
    # Get the size of the compressed files in the pkgs directory
    + ''
      PKGS_COMPRESSED_SIZE="$(du -B1 -sS "$MAMBA_ROOT_PREFIX/pkgs" | cut -f1)"
      PKGS_COMPRESSED_HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$PKGS_COMPRESSED_SIZE")"
    ''
    # Print the results as JSON
    + ''
      jq -cnr \
        --argjson env_size "$ENV_SIZE" \
        --arg env_human_readable "$ENV_HUMAN_READABLE" \
        --argjson pkgs_size "$PKGS_SIZE" \
        --arg pkgs_human_readable "$PKGS_HUMAN_READABLE" \
        --argjson pkgs_compressed_size "$PKGS_COMPRESSED_SIZE" \
        --arg pkgs_compressed_human_readable "$PKGS_COMPRESSED_HUMAN_READABLE" \
      '{
        env_size: $env_size,
        env_human_readable: $env_human_readable,
        pkgs_size: $pkgs_size,
        pkgs_human_readable: $pkgs_human_readable,
        pkgs_compressed_size: $pkgs_compressed_size,
        pkgs_compressed_human_readable: $pkgs_compressed_human_readable,
      }'
    ''
    # Cleanup
    + ''
      rm -rf "$MAMBA_ROOT_PREFIX"
    '';
}
