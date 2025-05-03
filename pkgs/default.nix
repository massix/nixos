{ pkgs }:
let
  inherit (pkgs) callPackage stdenv;
  onlyLinuxPkgs = {
    onedriver = callPackage ./onedriver { };
    custom-kernel = callPackage ./kernel { };
    tana = callPackage ./tana { };
  };
  commonPkgs = {
    lombok = callPackage ./lombok { };
    codeium-ls = callPackage ./coding/codeiumls.nix { };
    vscode-js-debug = callPackage ./coding/vscodejsdebug.nix { };
    tanzu = callPackage ./tanzu { };
    tridentctl = callPackage ./tridentctl { };
  };
in
if stdenv.hostPlatform.isLinux then (onlyLinuxPkgs // commonPkgs) else commonPkgs
