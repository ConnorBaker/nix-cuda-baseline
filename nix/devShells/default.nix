{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [black ruff (python3.withPackages (ps: with ps; [pydantic]))];
    };
  };
}
