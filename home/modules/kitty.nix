{ pkgs, lib, config, ... }:
let
  cfg = config.my-modules.kitty;
  inherit (lib) mkOption types mkIf;
in
{
  options.my-modules.kitty = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not to enable Kitty terminal";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.kitty;
      description = "Kitty package to use";
    };

    theme = mkOption {
      type = types.str;
      default = "Catppuccin-Macchiato";
      description = "Theme to use";
    };

    font = {
      name = mkOption {
        type = types.str;
        description = "Name of the font to use";
      };

      size = mkOption {
        type = types.int;
        description = "Size of the font to use";
      };

      packages = mkOption {
        type = types.listOf types.package;
        description = "Font packages to use";
        default = [ ];
      };

      italic = mkOption {
        type = types.str;
        default = "${cfg.font.name} Italic";
      };

      bold = mkOption {
        type = types.str;
        default = "${cfg.font.name} Bold";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.font.packages;
    programs.kitty =
      let
        fontFeatures = ffs: builtins.concatStringsSep "\n" (builtins.map (ff: "font_features ${ff}") ffs);
      in
      {
        enable = true;
        inherit (cfg) package;

        themeFile = cfg.theme;

        shellIntegration = {
          mode = "enabled";
          enableFishIntegration = true;
        };

        font = {
          inherit (cfg.font) name size;
        };

        settings = {
          italic_font = "${cfg.font.italic}";
          bold_font = "${cfg.font.bold}";

          cursor_shape = "beam";
          cursor_beam_thickness = "2.0";
          cursor_trail = 1;
          scrollback_lines = 10000;

          tab_bar_style = "powerline";
          tab_bar_align = "left";

          background_opacity = "0.9";
          dynamic_background_opacity = true;
          enable_audio_bell = false;

          disable_ligatures = "cursor";

          allow_remote_control = true;
          listen_on = "unix:$\{HOME}/.kitty-{kitty_pid}";

          # UI Tweaks
          hide_window_decorations = false;
          draw_minimal_borders = true;
          inactive_text_alpha = "0.6";
          remember_window_size = true;

          window_margin_width = "2";
          single_window_margin_width = "2";
          window_padding_width = "2";
          single_window_padding_width = "2";
          window_border_width = "1";
        };
        extraConfig = builtins.concatStringsSep "\n" [
          (fontFeatures (builtins.map (style: "RecursiveMonoCslSt-${style} +liga +dlig +ss10 +ss20") [ "Regular" "Italic" "Bold" "BdItalic" "Med" ]))
          (fontFeatures (builtins.map (style: "0xProto${style} +ss01") [ "Regular" "Italic" ]))
          (fontFeatures (builtins.map (style: "MonaspaceNeon-${style} +liga +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +ss09 +cv61") [ "Regular" "Italic" "Bold" ]))
          "symbol_map U+e000-U+e00a,U+ea60-U+ebeb,U+e0a0-U+e0c8,U+e0ca,U+e0cc-U+e0d4,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b1,U+e700-U+e7c5,U+f000-U+f2e0,U+f300-U+f372,U+f400-U+f532,U+f0001-U+f1af0 Symbols Nerd Font Mono"
        ];
      };
  };
}
