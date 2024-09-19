{ pkgs }:
let
  inherit (pkgs) callPackage;
in
{
  onedriver = callPackage ./onedriver { };
  lombok = callPackage ./lombok { };
  jdtls = callPackage ./jdtls-helix { };
  codeium-ls = callPackage ./coding/codeiumls.nix { };
  vscode-js-debug = callPackage ./coding/vscodejsdebug.nix { };
  spotube = callPackage ./spotube { };
  tana = callPackage ./tana { };
  warp-terminal = callPackage ./warp-terminal { };
  custom-kernel = callPackage ./kernel { };
  bash-language-server = callPackage ./bash-language-server { };
  tanzu = callPackage ./tanzu { };
  tridentctl = callPackage ./tridentctl { };
}
