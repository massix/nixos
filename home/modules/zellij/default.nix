{ pkgs, unstable, lib, config, ... }:
let
  cfg = config.my-modules.zellij;
  inherit (lib) mkEnableOption mkOption types mkIf;
  boolToStr = bool: if bool then "true" else "false";
in
{
  options.my-modules.zellij = {
    enable = mkEnableOption "Activate Zellij module";

    configuration = {
      unstable = mkEnableOption "Use unstable channel";
      enableFishIntegration = mkEnableOption "Fish integration";
      enableZshIntegration = mkEnableOption "Zsh integration";
      enableBashIntegration = mkEnableOption "Bash integration";
      autoAttach = mkEnableOption "Auto-attach to a session";
      autoExit = mkEnableOption "Auto-exit on exit";
      theme = mkOption {
        type = types.str;
        default = "catppuccin-mocha";
        description = "Theme to use for Zellij";
      };
      defaultLayout = mkOption {
        type = types.str;
        default = "compact";
        description = "Default layout to use";
      };
      defaultMode = mkOption {
        type = types.str;
        default = "locked";
        description = "Default mode to use";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      package = if cfg.configuration.unstable then unstable.zellij else pkgs.zellij;
      inherit (cfg.configuration) enableFishIntegration enableZshIntegration enableBashIntegration;
    };

    home.sessionVariables = {
      ZELLIJ_AUTO_ATTACH = boolToStr cfg.configuration.autoAttach;
      ZELLIJ_AUTO_EXIT = boolToStr cfg.configuration.autoExit;
    };

    home.file =
      let
        configDir = ".config/zellij";
        configurableOptions = [
          ''theme "${cfg.configuration.theme}"''
          ''default_layout "${cfg.configuration.defaultLayout}"''
          ''default_mode "${cfg.configuration.defaultMode}"''
        ];
        mkConfig = path: opts: (builtins.readFile path) + lib.strings.concatLines opts;
      in
      {
        "${configDir}/config.kdl".text = mkConfig ./config.kdl configurableOptions;
      };
  };
}
