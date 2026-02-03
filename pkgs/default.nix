{ pkgs }:
let
  inherit (pkgs) callPackage stdenv;
  onlyLinuxPkgs = {
    onedriver = callPackage ./onedriver { };
    custom-kernel = callPackage ./kernel { };
  };
  commonPkgs = {
    tanzu = callPackage ./tanzu { };
    tridentctl = callPackage ./tridentctl { };
  };
in
if stdenv.hostPlatform.isLinux then (onlyLinuxPkgs // commonPkgs) else commonPkgs
