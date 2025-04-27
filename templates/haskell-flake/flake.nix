{
  description = "Project developed using Haskell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;
      in
      {
        devShells.default = with pkgs; mkShell rec {
          packages = [
            ghc
            cabal-install
            haskell-language-server
            haskellPackages.ormolu
            haskellPackages.ghcide
            haskellPackages.haskell-debug-adapter
            haskellPackages.haskell-dap
            haskellPackages.ghci-dap
            haskellPackages.hlint
            haskellPackages.hoogle
          ];

          shellHook = ''
            echo "Haskell development shell activated with following tools:"
            ${lib.getExe' ghc "ghc"} --version
            ${lib.getExe cabal-install} --version
            ${lib.getExe haskellPackages.ormolu} --version
            ${lib.getExe' haskellPackages.ghcide "ghcide"} --version
            ${lib.getExe haskellPackages.haskell-debug-adapter} --version
            ${lib.getExe haskellPackages.hoogle} --version
            ${lib.getExe haskellPackages.hlint} --version
          '';

          env.LD_LIBRARY_PATH = lib.makeLibraryPath packages;
        };
      });
}
