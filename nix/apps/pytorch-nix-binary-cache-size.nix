{
  compression ? "xz",
  compression-level ? "-1",
  jq,
  nix,
  parallel-compression ? false,
  python3Packages,
  writeShellApplication,
}:
let
  scheme = "file://";
  cache-path = "$BINARY_CACHE";
  query-string = "?" + builtins.concatStringsSep "&" [
    "compression=${compression}"
    "compression-level=${compression-level}"
    "parallel-compression=${if parallel-compression then "true" else "false"}"
  ];
  cache-url = "${scheme}${cache-path}${query-string}";
in

writeShellApplication {
  name = "pytorch-nix-binary-cache-size-${compression}-${compression-level}";
  runtimeInputs = [jq nix];
  text =
    # Create the temporary binary cache
    ''
      BINARY_CACHE="$(mktemp -d)"
    ''
    # Create a temporary directory and relevant variables
    + ''
      TMP="$(mktemp -d)"
      META_FILE="$TMP/meta.json"
      SIZE_FILE="$TMP/size.json"
      TIME_FILE="$TMP/time.json"
    ''
    # Process the time template
    + ''
      TIME_TEMPLATE="$(tr -d '[:space:]' <<EOF
      ${builtins.readFile ./time-template.txt}
      EOF
      )"
    ''
    # Create the meta file
    + ''
      jq -cnr \
        --arg compression "${compression}" \
        --argjson compression_level "${compression-level}" \
        --argjson parallel_compression "${if parallel-compression then "true" else "false"}" \
      '{
        compression: $compression,
        compression_level: $compression_level,
        parallel_compression: $parallel_compression
      }' \
      >"$META_FILE"
    ''
    # Time copy PyTorch to the binary cache (without printing anything to stdout)
    + ''
      /usr/bin/env time \
        --format="$TIME_TEMPLATE" \
        --output="$TIME_FILE" \
        nix copy -v ${python3Packages.pytorch.outPath} \
        --to "${cache-url}" \
        1>&2
    ''
    # Compute the size info
    + ''
      BYTES="$(du -B1 -s "$BINARY_CACHE" | cut -f1)"
      HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$BYTES")"
    ''
    # Write the size info to a file
    + ''
      jq -cnr \
        --argjson bytes "$BYTES" \
        --arg human_readable "$HUMAN_READABLE" \
        '{bytes: $bytes, human_readable: $human_readable}' \
        >"$SIZE_FILE"
    ''
    # Write the output
    + ''
      jq -cnr \
        --slurpfile meta "$META_FILE" \
        --slurpfile size "$SIZE_FILE" \
        --slurpfile time "$TIME_FILE" \
        '{meta: $meta[0], size: $size[0], time: $time[0]}'
    ''
    # Cleanup
    + ''
      rm -rf "$BINARY_CACHE"
      rm -rf "$TMP"
    '';
}
