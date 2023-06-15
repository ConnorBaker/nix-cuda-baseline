{
  coreutils,
  jq,
  reg,
  dockerRepo ? "pytorch/pytorch",
  dockerTag ? "2.0.1-cuda11.7-cudnn8-devel",
  dockerSha256 ? "4f66166dd757752a6a6a9284686b4078e92337cd9d12d2e14d2d46274dfa9048",
  writeShellApplication,
}:
writeShellApplication {
  name = "pytorch-docker-image-size";
  runtimeInputs = [coreutils jq reg];
  text =
    # Create a temporary directory and relevant variables
    ''
      TMP="$(mktemp -d)"
      TIME_FILE="$TMP/time.json"
      SIZE_FILE="$TMP/size.json"
      MANIFEST_FILE="$TMP/manifest.json"
      REG_LOG_FILE="$TMP/reg.log"
    ''
    # Process the time template
    + ''
      TIME_TEMPLATE="$(tr -d '[:space:]' <<EOF
      ${builtins.readFile ./time-template.txt}
      EOF
      )"
    ''
    # Time and get the size of the image
    + ''
      /usr/bin/env time \
        --format="$TIME_TEMPLATE" \
        --output="$TIME_FILE" \
        reg manifest "${dockerRepo}:${dockerTag}@sha256:${dockerSha256}" \
        2>"$REG_LOG_FILE" \
        1>"$MANIFEST_FILE"
    ''
    # Extract the size of the image
    + ''
      BYTES="$(jq '[.layers[].size] | add' <"$MANIFEST_FILE")"
      HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$BYTES")"
    ''
    # Write the size of the image in JSON
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
        --slurpfile time "$TIME_FILE" \
        --slurpfile size "$SIZE_FILE" \
        '{time: $time[0], size: $size[0]}'
    ''
    # Remove the temporary directory
    + ''
      rm -rf "$TMP"
    '';
}
