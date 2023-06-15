{inputs, ...}: {
  imports = [
    ./options.nix
    ./config.nix
    ./apps
    ./devShells
  ];

  perSystem = {
    config,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        # Change the default version of CUDA used
        (_: prev: {
          cudaPackages = prev.${config.cudaPackages};
        })
        # Use a newer version of Nix to take advantage of max-substitution-jobs
        (_: prev: {
          nix =
            if prev.lib.strings.versionAtLeast prev.nix.version "2.16"
            then prev.nix
            else prev.nixVersions.nix_2_16;
        })
      ];
      config = {
        inherit (config) cudaCapabilities cudaForwardCompat;
        allowUnfree = true;
        cudaSupport = true;
      };
    };
  };
}
