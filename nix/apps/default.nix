{
  inputs,
  lib,
  ...
}: let
  mkApp = drv: inputs.flake-utils.lib.mkApp {inherit drv;};

  # Common utilities
  inherit
    (builtins)
    concatLists
    listToAttrs
    map
    mapAttrs
    toString
    ;
  inherit (lib.attrsets) cartesianProductOfSets;

  # xz, bzip2, gzip, zstd, or none
  # compressionSettings :: List (AttrSet {compression, compression-level})
  compressionSettings = concatLists [
    (cartesianProductOfSets {
      compression = ["xz"];
      compression-level = map toString (lib.lists.range 0 9);
    })
    (cartesianProductOfSets {
      compression = ["bzip2"];
      compression-level = map toString (lib.lists.range 1 9);
    })
    (cartesianProductOfSets {
      compression = ["gzip"];
      compression-level = map toString (lib.lists.range 1 9);
    })
    (cartesianProductOfSets {
      compression = ["zstd"];
      compression-level = map toString (lib.lists.range 1 19);
    })
    [
      {
        compression = "none";
        compression-level = "-1";
      }
    ]
  ];
in {
  perSystem = {pkgs, ...}: let
    inherit (pkgs) callPackage;
    mkNixBinaryCacheSize = attrs: let
      drv = callPackage ./pytorch-nix-binary-cache-size.nix attrs;
    in {
      name = drv.name;
      value = drv;
    };
    nixBinaryCaches = listToAttrs (map mkNixBinaryCacheSize compressionSettings);
  in {
    apps = mapAttrs (_: mkApp) ({
        pytorch-conda-size = callPackage ./pytorch-conda-size.nix {};
        pytorch-docker-image-size = callPackage ./pytorch-docker-image-size.nix {};
        pytorch-nix-store-size = callPackage ./pytorch-nix-store-size.nix {};
      }
      // nixBinaryCaches);
  };
}
