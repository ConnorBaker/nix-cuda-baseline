{
  perSystem = {pkgs, ...}: {
    config = {
      # Capabilities chosen to match https://github.com/pytorch/builder/blob/78c5ce7d79780daf70b7e66714f30cee221946b1/manywheel/build_cuda.sh#L69
      cudaCapabilities = ["3.7" "5.0" "6.0" "7.0" "7.5" "8.0" "8.6"];
      cudaForwardCompat = false;
      cudaPackages = "cudaPackages_11_7";
      formatter = pkgs.alejandra;
    };
  };
}
