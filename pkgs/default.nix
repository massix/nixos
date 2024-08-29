{ pkgs }: {
  onedriver = import ./onedriver { inherit pkgs; };
  lombok = import ./lombok { inherit pkgs; };
  jdtls = import ./jdtls-helix { inherit pkgs; };
  codeium-ls = import ./coding/codeiumls.nix { inherit pkgs; };
  vscode-js-debug = import ./coding/vscodejsdebug.nix { inherit pkgs; };
  spotube = import ./spotube { inherit pkgs; };
  tana = import ./tana { inherit pkgs; };
  warp-terminal = import ./warp-terminal { inherit pkgs; };
  custom-kernel = pkgs.callPackage ./kernel { };
  bash-language-server = pkgs.callPackage ./bash-language-server { };
  tanzu = pkgs.callPackage ./tanzu { };
}
