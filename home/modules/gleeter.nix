{ pkgs, lib, config, ... }:
let
  cfg = config.my-modules.gleeter;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.my-modules.gleeter.enable = mkEnableOption "gleeter";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gleeter ];

    my-modules.fish.configuration.extraShellAbbrs = {
      gl = "gleeter";
      glr = "gleeter random";
      gll = "gleeter latest";
    };

    xdg.configFile."fish/functions/gleeter.fish".text = ''
      function gleeter -a command -d "Wraps gleeter and creates aliases for known comics"
        switch $command
          case "bobbytables"
            command gleeter id 327
          case "standards"
            command gleeter id 927
          case "techsupport"
            command gleeter id 627
          case "compiling"
            command gleeter id 303
          case "sudo"
            command gleeter id 149
          case "wikipedia"
            command gleeter id 285
          case "programmers"
            command gleeter id 378
          case '*'
            command gleeter $argv
        end
      end
    '';
  };
}
