{ pkgs }: {
  onedriver = import ./onedriver { inherit pkgs; };
  lombok = import ./lombok { inherit pkgs; };
  jdtls = import ./jdtls-helix { inherit pkgs; };
}

