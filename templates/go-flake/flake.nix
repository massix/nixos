{
  description = "Project developed using Golang";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;
        hardeningDisable = [ "fortify" ];
      in
      {
        devShells.default = with pkgs; mkShell {
          inherit hardeningDisable;
          packages = [
            go
            gofumpt
            gopls
            delve
            golangci-lint
          ];

          shellHook = ''
            echo "Go development shell activated with following tools:"
            ${lib.getExe go} version
            ${lib.getExe gofumpt} --version
            ${lib.getExe gopls} version
            ${lib.getExe delve} version
            ${lib.getExe golangci-lint} --version
          '';
        };
      });
}
