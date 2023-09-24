{ config, lib, pkgs, unstable, ... }:
let
  cfg = config.my-modules.helix;
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types;
in
{
  options.my-modules.helix = {
    enable = mkEnableOption "Enable Helix";
    defaultEditor = mkEnableOption "Set Helix as default editor";
    package = mkPackageOption pkgs "helix" {
      default = [ "helix" ];
    };
    configuration.unstable = mkEnableOption "Install from the unstable channel";
    configuration.theme = mkOption {
      type = types.str;
      default = "everforest_dark";
      description = "Helix theme";
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = mkIf cfg.defaultEditor {
      EDITOR = "hx";
    };

    home.packages =
      let
        channel = if cfg.configuration.unstable then unstable else pkgs;
      in
      with channel; [ nil rnix-lsp ];

    programs.helix = {
      inherit (cfg) enable package;
      settings = {
        inherit (cfg.configuration) theme;
        editor = {
          line-number = "relative";
          mouse = true;
          true-color = true;
          cursorline = true;
          cursorcolumn = false;
          gutters = [ "diff" "diagnostics" "line-numbers" "spacer" "spacer" ];

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          file-picker.hidden = false;

          statusline = {
            left = [ "mode" "spinner" "file-modification-indicator" "version-control" ];
            center = [ "file-name" "total-line-numbers" ];
            right = [ "diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type" ];
            separator = "|";
            mode.normal = "NORMAL";
            mode.insert = "INSERT";
            mode.select = "SELECT";
          };

          lsp = {
            enable = true;
            display-messages = true;
            display-inlay-hints = true;
          };

          indent-guides = {
            render = false;
            skip-level = 1;
          };
        };
      };
    };
  };
}
