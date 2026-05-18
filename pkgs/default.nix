{ pkgs }:
let
  inherit (pkgs) callPackage stdenv;
  onlyLinuxPkgs = {
    custom-kernel = callPackage ./kernel { };
  };
  commonPkgs = {
    tanzu = callPackage ./tanzu { };
    tridentctl = callPackage ./tridentctl { };
  };
in
if stdenv.hostPlatform.isLinux then (onlyLinuxPkgs // commonPkgs) else commonPkgs
