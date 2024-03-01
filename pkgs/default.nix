{ stable, unstable }: {
  onedriver = import ./onedriver { inherit stable unstable; };
  lombok = import ./lombok { inherit stable unstable; };
  jdtls = import ./jdtls-helix { inherit stable unstable; };
  codeium-ls = import ./coding/codeiumls.nix { inherit stable unstable; };
  vscode-js-debug = import ./coding/vscodejsdebug.nix { inherit stable unstable; };
  spotube = import ./spotube { inherit stable unstable; };
  tana = import ./tana { inherit stable unstable; };
}
