{
  description = "Project developed using NodeJS";
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
        devShells.default = with pkgs; mkShell {
          packages = [
            nodejs
            typescript-language-server

            # Remove unwanted package managers from the list
            yarn
            pnpm
          ];

          shellHook = ''
            echo "Node development shell activated with following tools:"
            ${lib.getExe nodejs} --version
            ${lib.getExe typescript-language-server} --version
          '';
        };
      });
}
