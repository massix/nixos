_:
let
  mkDesc = tpl: "nix flake new -t github:massix/nixos#${tpl} .";
in
{
  templates = {
    go = {
      path = ./go-flake;
      description = mkDesc "go";
    };

    gleam = {
      path = ./gleam-flake;
      description = mkDesc "gleam";
    };

    haskell = {
      path = ./haskell-flake;
      description = mkDesc "haskell";
    };

    lua = {
      path = ./lua-flake;
      description = mkDesc "lua";
    };

    node = {
      path = ./node-flake;
      description = mkDesc "node";
    };
  };
}
