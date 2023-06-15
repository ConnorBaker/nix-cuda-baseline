{
  jq,
  nix,
  python3Packages,
  writeShellApplication,
}:
writeShellApplication {
  name = "pytorch-nix-store-size";
  runtimeInputs = [jq nix];
  text =
    # Create a temporary directory and relevant variables
    ''
      TMP="$(mktemp -d)"
      PATH_INFO_FILE="$TMP/path_info.txt"
      TIME_FILE="$TMP/time.json"
      SIZE_FILE="$TMP/size.json"
    ''
    # Process the time template
    + ''
      TIME_TEMPLATE="$(tr -d '[:space:]' <<EOF
      ${builtins.readFile ./time-template.txt}
      EOF
      )"
    ''
    # Time and get the size of the path
    + ''
      /usr/bin/env time \
        --format="$TIME_TEMPLATE" \
        --output="$TIME_FILE" \
        nix path-info -S ${python3Packages.pytorch.outPath} \
        1>"$PATH_INFO_FILE"
    ''
    # Extract the size info of the path
    + ''
      BYTES="$(cut -f2 <"$PATH_INFO_FILE")"
      HUMAN_READABLE="$(numfmt --to iec --format '%.4f' <<< "$BYTES")"
    ''
    # Write the size info to a JSON file
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
