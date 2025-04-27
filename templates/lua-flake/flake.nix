{
  description = "Project developed using Lua";
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
            lua
            lua-language-server
            stylua
            luaPackages.luacheck
            luarocks
          ];

          shellHook = ''
            echo "Lua development shell activated with following tools:"
            ${lib.getExe lua} -v
            ${lib.getExe lua-language-server} --version
            ${lib.getExe stylua} --version
            ${lib.getExe luaPackages.luacheck} --version
            ${lib.getExe luarocks} --version
          '';
        };
      });
}
