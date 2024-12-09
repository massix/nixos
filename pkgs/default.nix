{ pkgs }:
let
  inherit (pkgs) callPackage stdenv;
  onlyLinuxPkgs = {
    onedriver = callPackage ./onedriver { };
    custom-kernel = callPackage ./kernel { };
    spotube = callPackage ./spotube { };
    tana = callPackage ./tana { };
  };
  commonPkgs = {
    lombok = callPackage ./lombok { };
    jdtls = callPackage ./jdtls-helix { };
    codeium-ls = callPackage ./coding/codeiumls.nix { };
    vscode-js-debug = callPackage ./coding/vscodejsdebug.nix { };
    bash-language-server = callPackage ./bash-language-server { };
    tanzu = callPackage ./tanzu { };
    tridentctl = callPackage ./tridentctl { };
  };
in
if stdenv.hostPlatform.isLinux then (onlyLinuxPkgs // commonPkgs) else commonPkgs
