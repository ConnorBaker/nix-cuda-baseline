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
    # Create a temporary directory and relevant variables
    + ''
      TMP="$(mktemp -d)"
      TIME_FILE="$TMP/time.json"
      SIZES_FILE="$TMP/sizes.json"
    ''
    # Process the time template
    + ''
      TIME_TEMPLATE="$(tr -d '[:space:]' <<EOF
      ${builtins.readFile ./time-template.txt}
      EOF
      )"
    ''
    # Create the pytorch environment (without printing anything to STDOUT)
    + ''
      /usr/bin/env time \
        --format="$TIME_TEMPLATE" \
        --output="$TIME_FILE" \
        micromamba create -y \
        -n pytorch \
        -c pytorch \
        -c nvidia \
        -c conda-forge \
        pytorch=${pytorchVersion}=${pytorchBuild} \
        1>&2
    ''
    # Get the size of the pytorch environment
    + ''
      ENVIRONMENT_BYTES="$(du -B1 -s "$MAMBA_ROOT_PREFIX/envs/pytorch" | cut -f1)"
      ENVIRONMENT_HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$ENVIRONMENT_BYTES")"
    ''
    # Get the size of the pkgs directory
    + ''
      PACKAGES_BYTES="$(du -B1 -s "$MAMBA_ROOT_PREFIX/pkgs" | cut -f1)"
      PACKAGES_HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$PACKAGES_BYTES")"
    ''
    # Get the size of the compressed files in the pkgs directory
    + ''
      PACKAGES_COMPRESSED_BYTES="$(du -B1 -sS "$MAMBA_ROOT_PREFIX/pkgs" | cut -f1)"
      PACKAGES_COMPRESSED_HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$PACKAGES_COMPRESSED_BYTES")"
    ''
    # Write the size results as JSON
    + ''
      jq -cnr \
        --argjson environment_bytes "$ENVIRONMENT_BYTES" \
        --arg environment_human_readable "$ENVIRONMENT_HUMAN_READABLE" \
        --argjson packages_bytes "$PACKAGES_BYTES" \
        --arg packages_human_readable "$PACKAGES_HUMAN_READABLE" \
        --argjson packages_compressed_bytes "$PACKAGES_COMPRESSED_BYTES" \
        --arg packages_compressed_human_readable "$PACKAGES_COMPRESSED_HUMAN_READABLE" \
      '{
        environment: {
          bytes: $environment_bytes,
          human_readable: $environment_human_readable
        },
        packages: {
          bytes: $packages_bytes,
          human_readable: $packages_human_readable,
        },
        packages_compressed: {
          bytes: $packages_compressed_bytes,
          human_readable: $packages_compressed_human_readable
        }
      }' \
      >"$SIZES_FILE"
    ''
    # Write the output
    + ''
      jq -cnr \
        --slurpfile time "$TIME_FILE" \
        --slurpfile sizes "$SIZES_FILE" \
        '{time: $time[0], sizes: $sizes[0]}'
    ''
    # Cleanup
    + ''
      rm -rf "$MAMBA_ROOT_PREFIX"
      rm -rf "$TMP"
    '';
}
