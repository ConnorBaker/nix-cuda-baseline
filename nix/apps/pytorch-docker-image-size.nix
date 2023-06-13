{
  coreutils,
  jq,
  reg,
  writeShellApplication,
}:
writeShellApplication {
  name = "pytorch-docker-image-size";
  runtimeInputs = [coreutils jq reg];
  text =
    # Variables to fetch the image
    ''
      REPO="pytorch/pytorch"
      TAG="2.0.1-cuda11.7-cudnn8-devel"
      SHA256="4f66166dd757752a6a6a9284686b4078e92337cd9d12d2e14d2d46274dfa9048"
    ''
    # Get the size of the image
    + ''
      SIZE="$(
        reg manifest "$REPO:$TAG@sha256:$SHA256" \
          | jq '[.layers[].size] | add' \
          | numfmt --to iec --format '%.4f'
      )"
    ''
    # Print the size of the image
    + ''
      echo "PyTorch docker compressed image size: $SIZE"
    '';
}
