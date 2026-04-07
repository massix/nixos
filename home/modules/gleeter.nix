{ pkgs, lib, config, ... }:
let
  cfg = config.my-modules.gleeter;
  inherit (lib) mkEnableOption mkOption mkIf;
  mkIdAlias = { name, type, id }:
    # TOML
    ''
      [[alias]]
      name = "${name}"
      type = "${type}"
      id = ${toString id}
    '';
  allAliases = builtins.concatStringsSep "\n" (map mkIdAlias [
    { name = "wikipedia"; type = "id"; id = 285; }
    { name = "programmers"; type = "id"; id = 378; }
    { name = "compiling"; type = "id"; id = 303; }
    { name = "sudo"; type = "id"; id = 149; }
    { name = "standards"; type = "id"; id = 927; }
    { name = "techsupport"; type = "id"; id = 627; }
    { name = "bobbytables"; type = "id"; id = 327; }
    { name = "tenthousand"; type = "id"; id = 1053; }
    { name = "correlation"; type = "id"; id = 552; }
  ]);
in
{
  options.my-modules.gleeter = {
    enable = mkEnableOption "gleeter";
    random_start = mkOption {
      type = lib.types.int;
      description = "Start with a random number of entries";
      default = 0;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gleeter ];

    my-modules.fish.configuration.extraShellAbbrs = {
      gl = "gleeter";
      glr = "gleeter random";
      gll = "gleeter latest";
    };

    xdg.configFile."gleeter/config.toml".text = builtins.concatStringsSep "\n\n" ([
      "random_start = ${toString cfg.random_start}"
    ] ++ [ allAliases ]);
  };
}
